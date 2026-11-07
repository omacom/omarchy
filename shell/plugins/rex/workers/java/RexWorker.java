// Rex worker for java.util.regex. Same protocol as rex_worker.py: one JSON
// request per line on stdin, replies one per line on stdout. Java strings
// are UTF-16, so offsets need no conversion.

import java.io.BufferedReader;
import java.io.InputStreamReader;
import java.io.PrintStream;
import java.nio.charset.StandardCharsets;
import java.util.ArrayList;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;
import java.util.regex.Matcher;
import java.util.regex.Pattern;
import java.util.regex.PatternSyntaxException;

public class RexWorker {
  static final PrintStream OUT = new PrintStream(System.out, false, StandardCharsets.UTF_8);

  // ---- a small JSON reader: requests are objects of strings, numbers,
  // booleans, and arrays of strings ----

  static final class Reader {
    final String s;
    int at;

    Reader(String s) { this.s = s; }

    void ws() { while (at < s.length() && " \t\r\n".indexOf(s.charAt(at)) >= 0) at++; }

    Object value() {
      ws();
      char c = s.charAt(at);
      if (c == '{') {
        at++;
        Map<String, Object> map = new LinkedHashMap<>();
        for (;;) {
          ws();
          if (s.charAt(at) == '}') { at++; return map; }
          String key = (String) value();
          ws();
          at++;
          map.put(key, value());
          ws();
          if (s.charAt(at) == ',') at++;
        }
      }
      if (c == '[') {
        at++;
        List<Object> list = new ArrayList<>();
        for (;;) {
          ws();
          if (s.charAt(at) == ']') { at++; return list; }
          list.add(value());
          ws();
          if (s.charAt(at) == ',') at++;
        }
      }
      if (c == '"') return string();
      if (s.startsWith("true", at)) { at += 4; return Boolean.TRUE; }
      if (s.startsWith("false", at)) { at += 5; return Boolean.FALSE; }
      if (s.startsWith("null", at)) { at += 4; return null; }
      int start = at;
      while (at < s.length() && "-+.eE0123456789".indexOf(s.charAt(at)) >= 0) at++;
      return Double.parseDouble(s.substring(start, at));
    }

    String string() {
      at++;
      StringBuilder out = new StringBuilder();
      for (;;) {
        char c = s.charAt(at++);
        if (c == '"') return out.toString();
        if (c != '\\') { out.append(c); continue; }
        char e = s.charAt(at++);
        switch (e) {
          case 'n' -> out.append('\n');
          case 't' -> out.append('\t');
          case 'r' -> out.append('\r');
          case 'b' -> out.append('\b');
          case 'f' -> out.append('\f');
          case 'u' -> { out.append((char) Integer.parseInt(s.substring(at, at + 4), 16)); at += 4; }
          default -> out.append(e);
        }
      }
    }
  }

  static String quote(String s) {
    StringBuilder out = new StringBuilder("\"");
    for (int i = 0; i < s.length(); i++) {
      char c = s.charAt(i);
      switch (c) {
        case '"' -> out.append("\\\"");
        case '\\' -> out.append("\\\\");
        case '\n' -> out.append("\\n");
        case '\r' -> out.append("\\r");
        case '\t' -> out.append("\\t");
        default -> {
          if (c < 0x20) out.append(String.format("\\u%04x", (int) c));
          else out.append(c);
        }
      }
    }
    return out.append('"').toString();
  }

  static void send(String json) {
    OUT.print(json);
    OUT.print('\n');
    OUT.flush();
  }

  static String failure(long id, String error) {
    return "{\"id\":" + id + ",\"ok\":false,\"done\":true,\"error\":" + quote(error) + ",\"matches\":[],\"stride\":2}";
  }

  // Named groups in source order, numbered as Java numbers them.
  static String names(String pattern) {
    StringBuilder out = new StringBuilder();
    int index = 0;
    Matcher m = Pattern.compile("\\\\.|\\[(?:\\\\.|[^\\]\\\\])*\\]|\\((\\?<([A-Za-z][A-Za-z0-9]*)>|(?!\\?))").matcher(pattern);
    while (m.find()) {
      if (m.group(1) == null) continue;
      index++;
      if (m.group(2) != null) {
        if (out.length() > 0) out.append(',');
        out.append(quote(m.group(2))).append(':').append(index);
      }
    }
    return "{" + out + "}";
  }

  @SuppressWarnings("unchecked")
  static String run(Map<String, Object> request, long id, String text) {
    int flags = 0;
    for (Object f : (List<Object>) request.getOrDefault("flags", List.of())) {
      switch ((String) f) {
        case "i" -> flags |= Pattern.CASE_INSENSITIVE;
        case "m" -> flags |= Pattern.MULTILINE;
        case "s" -> flags |= Pattern.DOTALL;
        case "x" -> flags |= Pattern.COMMENTS;
        case "u" -> flags |= Pattern.UNICODE_CASE;
        case "U" -> flags |= Pattern.UNICODE_CHARACTER_CLASS;
        case "d" -> flags |= Pattern.UNIX_LINES;
        default -> { }
      }
    }
    String source = (String) request.get("pattern");
    Pattern pattern;
    try {
      pattern = Pattern.compile(source, flags);
    } catch (PatternSyntaxException e) {
      return failure(id, e.getDescription() + (e.getIndex() >= 0 ? " near index " + e.getIndex() : ""));
    }
    int limit = request.get("limit") instanceof Double d && d > 0 ? d.intValue() : 100000;
    if (Boolean.FALSE.equals(request.get("all"))) limit = 1;
    long started = System.nanoTime();
    Matcher m = pattern.matcher(text);
    int groups = m.groupCount();
    StringBuilder matches = new StringBuilder();
    int count = 0;
    while (count < limit && m.find()) {
      for (int g = 0; g <= groups; g++) {
        if (matches.length() > 0) matches.append(',');
        matches.append(m.start(g)).append(',').append(m.end(g));
      }
      count++;
    }
    double elapsed = (System.nanoTime() - started) / 1e6;
    return "{\"id\":" + id + ",\"ok\":true,\"done\":true,\"matches\":[" + matches + "],\"stride\":" + (groups + 1) * 2
      + ",\"elapsed\":" + elapsed + ",\"names\":" + names(source) + "}";
  }

  @SuppressWarnings("unchecked")
  public static void main(String[] args) throws Exception {
    BufferedReader in = new BufferedReader(new InputStreamReader(System.in, StandardCharsets.UTF_8), 1 << 20);
    String text = null;
    double textId = Double.NaN;
    for (String line; (line = in.readLine()) != null; ) {
      Map<String, Object> request;
      try {
        request = (Map<String, Object>) new Reader(line).value();
      } catch (RuntimeException e) {
        continue;
      }
      long id = request.get("id") instanceof Double d ? d.longValue() : 0;
      if ("info".equals(request.get("op"))) {
        send("{\"id\":" + id + ",\"ok\":true,\"done\":true,\"versions\":{\"java\":" + quote("Java " + Runtime.version()) + "}}");
        continue;
      }
      if (request.get("textPath") instanceof String path) {
        // A file opened in Rex is read here rather than sent over the pipe.
        request.put("text", new String(java.nio.file.Files.readAllBytes(java.nio.file.Path.of(path)), StandardCharsets.UTF_8));
      }
      if (request.containsKey("text")) {
        text = (String) request.get("text");
        textId = request.get("textId") instanceof Double d ? d : Double.NaN;
      }
      double wanted = request.get("textId") instanceof Double d ? d : Double.NaN;
      if (text == null || wanted != textId) {
        send(failure(id, "missing-text"));
        continue;
      }
      try {
        send(run(request, id, text));
      } catch (StackOverflowError e) {
        send("{\"id\":" + id + ",\"ok\":false,\"done\":true,\"kind\":\"limit\",\"error\":\"Java's regex engine ran out of stack: the pattern recurses too deeply on this text\",\"matches\":[],\"stride\":2}");
      } catch (RuntimeException e) {
        send(failure(id, String.valueOf(e.getMessage())));
      }
    }
  }
}
