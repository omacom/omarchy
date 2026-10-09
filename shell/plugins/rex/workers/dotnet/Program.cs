// Rex worker for .NET's System.Text.RegularExpressions. Same protocol as
// rex_worker.py: one JSON request per line on stdin, replies one per line on
// stdout. .NET strings are UTF-16, so offsets need no conversion.

using System;
using System.Collections.Generic;
using System.Diagnostics;
using System.IO;
using System.Text;
using System.Text.Json;
using System.Text.Json.Nodes;
using System.Text.RegularExpressions;

static class RexWorker
{
    static readonly TimeSpan Timeout = TimeSpan.FromSeconds(10);

    static void Send(TextWriter output, JsonObject reply)
    {
        output.Write(reply.ToJsonString());
        output.Write('\n');
        output.Flush();
    }

    static JsonObject Failure(long id, string error, string kind = null)
    {
        var reply = new JsonObject { ["id"] = id, ["ok"] = false, ["done"] = true, ["error"] = error, ["matches"] = new JsonArray(), ["stride"] = 2 };
        if (kind != null) reply["kind"] = kind;
        return reply;
    }

    static JsonObject Run(JsonNode request, long id, string text)
    {
        var options = RegexOptions.None;
        foreach (var flag in request["flags"]?.AsArray() ?? new JsonArray())
        {
            switch ((string)flag)
            {
                case "i": options |= RegexOptions.IgnoreCase; break;
                case "m": options |= RegexOptions.Multiline; break;
                case "s": options |= RegexOptions.Singleline; break;
                case "x": options |= RegexOptions.IgnorePatternWhitespace; break;
                case "n": options |= RegexOptions.ExplicitCapture; break;
                case "r": options |= RegexOptions.RightToLeft; break;
                case "e": options |= RegexOptions.ECMAScript; break;
                case "c": options |= RegexOptions.CultureInvariant; break;
                case "b": options |= RegexOptions.NonBacktracking; break;
            }
        }
        Regex regex;
        try
        {
            regex = new Regex((string)request["pattern"], options, Timeout);
        }
        catch (ArgumentException e)
        {
            var message = e.Message;
            var cut = message.IndexOf(" - ", StringComparison.Ordinal);
            return Failure(id, cut >= 0 ? message.Substring(cut + 3) : message);
        }
        int limit = request["limit"] is JsonNode l && (int)l > 0 ? (int)l : 100000;
        if (request["all"] is JsonNode all && !(bool)all) limit = 1;
        var groups = regex.GetGroupNumbers();
        int highest = 0;
        foreach (var g in groups) highest = Math.Max(highest, g);
        var matches = new JsonArray();
        var watch = Stopwatch.StartNew();
        try
        {
            int count = 0;
            for (var m = regex.Match(text); m.Success && count < limit; m = m.NextMatch(), count++)
            {
                for (int g = 0; g <= highest; g++)
                {
                    var group = m.Groups[g];
                    if (group.Success) { matches.Add(group.Index); matches.Add(group.Index + group.Length); }
                    else { matches.Add(-1); matches.Add(-1); }
                }
            }
        }
        catch (RegexMatchTimeoutException)
        {
            return Failure(id, ".NET's regex timeout stopped the search", "limit");
        }
        var names = new JsonObject();
        foreach (var name in regex.GetGroupNames())
        {
            if (!int.TryParse(name, out _)) names[name] = regex.GroupNumberFromName(name);
        }
        return new JsonObject
        {
            ["id"] = id, ["ok"] = true, ["done"] = true, ["matches"] = matches,
            ["stride"] = (highest + 1) * 2, ["elapsed"] = watch.Elapsed.TotalMilliseconds, ["names"] = names,
        };
    }

    static void Main()
    {
        var input = new StreamReader(Console.OpenStandardInput(), new UTF8Encoding(false), false, 1 << 20);
        var output = new StreamWriter(Console.OpenStandardOutput(), new UTF8Encoding(false), 1 << 16);
        string text = null;
        double textId = double.NaN;
        for (string line; (line = input.ReadLine()) != null;)
        {
            JsonNode request;
            try { request = JsonNode.Parse(line); } catch (JsonException) { continue; }
            if (request == null) continue;
            long id = request["id"] is JsonNode i ? (long)(double)i : 0;
            if ((string)request["op"] == "info")
            {
                Send(output, new JsonObject { ["id"] = id, ["ok"] = true, ["done"] = true, ["versions"] = new JsonObject { ["dotnet"] = ".NET " + Environment.Version } });
                continue;
            }
            if (request["text"] != null)
            {
                text = (string)request["text"];
                textId = (double)request["textId"];
            }
            double wanted = request["textId"] is JsonNode w ? (double)w : double.NaN;
            if (text == null || wanted != textId)
            {
                Send(output, Failure(id, "missing-text"));
                continue;
            }
            try { Send(output, Run(request, id, text)); }
            catch (Exception e) { Send(output, Failure(id, e.Message)); }
        }
    }
}
