// Only generated, escaped markup reaches the StyledText preview.
function escape(text) {
  return String(text).replace(/&/g, "&amp;").replace(/</g, "&lt;")
    .replace(/>/g, "&gt;").replace(/"/g, "&quot;").replace(/'/g, "&#39;");
}

function palette(toml) {
  var result = {};
  var pattern = /^\s*(red|green|yellow|blue|magenta|cyan)\s*=\s*["'](#[0-9a-fA-F]{6})["']/gm;
  var match;
  while ((match = pattern.exec(toml)) !== null) result[match[1]] = match[2];
  return result;
}

function highlight(text, enabled, colors) {
  if (!enabled) return escape(text);
  // A small lexer for the fixed Ruby, Rust, TypeScript, Go, PHP, C++ and Java samples.
  var tokens = /("(?:\\.|[^"\\])*"|'(?:\\.|[^'\\])*'|`(?:\\.|[^`\\])*`)|(\$[A-Za-z_]\w*)|\b(const|let|echo)\b|\b(string|Vec|System)\b|\b\d+\b|\b[A-Za-z_]\w*(?=\s*\()|\b(puts|map|collect|cout|endl)\b|(?:=>|->|!=|<<|::|\.\.=|[=+*|])/g;
  var output = "";
  var end = 0;
  var match;
  while ((match = tokens.exec(text)) !== null) {
    var token = match[0];
    var role = match[1] ? "green" : match[2] ? "red" : match[3] ? "magenta"
      : match[4] ? "yellow" : /^\d/.test(token) ? "yellow"
      : /^[A-Za-z_]/.test(token) ? "blue" : "cyan";
    var color = colors[role];
    output += escape(text.slice(end, match.index));
    output += /^#[0-9a-fA-F]{6}$/.test(color || "")
      ? '<font color="' + color + '">' + escape(token) + '</font>' : escape(token);
    end = tokens.lastIndex;
  }
  return output + escape(text.slice(end));
}
