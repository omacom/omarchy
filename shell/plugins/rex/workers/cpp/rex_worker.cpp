// Rex worker for the C++ standard library's std::regex (libstdc++), with the
// default ECMAScript grammar. Same protocol as rex_worker.py: one JSON
// request per line on stdin, replies one per line on stdout, match offsets
// in UTF-16 code units. std::regex works on bytes, so a non-ASCII character
// is several "characters" to it, as it is to any C++ program using it.

#include <algorithm>
#include <chrono>
#include <cmath>
#include <cstdio>
#include <fstream>
#include <iterator>
#include <iostream>
#include <map>
#include <memory>
#include <regex>
#include <sstream>
#include <string>
#include <variant>
#include <vector>

struct Json;
using Object = std::map<std::string, Json>;
using Array = std::vector<Json>;
struct Json {
  std::variant<std::nullptr_t, bool, double, std::string, std::shared_ptr<Array>, std::shared_ptr<Object>> v;
};

struct Reader {
  const std::string &s;
  size_t at = 0;

  void ws() { while (at < s.size() && std::string(" \t\r\n").find(s[at]) != std::string::npos) at++; }

  static void utf8(std::string &out, unsigned cp) {
    if (cp < 0x80) out += char(cp);
    else if (cp < 0x800) { out += char(0xC0 | (cp >> 6)); out += char(0x80 | (cp & 63)); }
    else if (cp < 0x10000) { out += char(0xE0 | (cp >> 12)); out += char(0x80 | ((cp >> 6) & 63)); out += char(0x80 | (cp & 63)); }
    else { out += char(0xF0 | (cp >> 18)); out += char(0x80 | ((cp >> 12) & 63)); out += char(0x80 | ((cp >> 6) & 63)); out += char(0x80 | (cp & 63)); }
  }

  std::string string() {
    at++;
    std::string out;
    for (;;) {
      char c = s.at(at++);
      if (c == '"') return out;
      if (c != '\\') { out += c; continue; }
      char e = s.at(at++);
      switch (e) {
        case 'n': out += '\n'; break;
        case 't': out += '\t'; break;
        case 'r': out += '\r'; break;
        case 'b': out += '\b'; break;
        case 'f': out += '\f'; break;
        case 'u': {
          unsigned cp = std::stoul(s.substr(at, 4), nullptr, 16);
          at += 4;
          if (cp >= 0xD800 && cp < 0xDC00 && s.compare(at, 2, "\\u") == 0) {
            unsigned low = std::stoul(s.substr(at + 2, 4), nullptr, 16);
            cp = 0x10000 + ((cp - 0xD800) << 10) + (low - 0xDC00);
            at += 6;
          }
          utf8(out, cp);
          break;
        }
        default: out += e;
      }
    }
  }

  Json value() {
    ws();
    char c = s.at(at);
    if (c == '{') {
      at++;
      auto object = std::make_shared<Object>();
      for (;;) {
        ws();
        if (s.at(at) == '}') { at++; return Json{object}; }
        std::string key = string();
        ws();
        at++;
        (*object)[key] = value();
        ws();
        if (s.at(at) == ',') at++;
      }
    }
    if (c == '[') {
      at++;
      auto array = std::make_shared<Array>();
      for (;;) {
        ws();
        if (s.at(at) == ']') { at++; return Json{array}; }
        array->push_back(value());
        ws();
        if (s.at(at) == ',') at++;
      }
    }
    if (c == '"') return Json{string()};
    if (s.compare(at, 4, "true") == 0) { at += 4; return Json{true}; }
    if (s.compare(at, 5, "false") == 0) { at += 5; return Json{false}; }
    if (s.compare(at, 4, "null") == 0) { at += 4; return Json{nullptr}; }
    size_t used = 0;
    double number = std::stod(s.substr(at), &used);
    at += used;
    return Json{number};
  }
};

static std::string quote(const std::string &s) {
  std::string out = "\"";
  for (unsigned char c : s) {
    if (c == '"') out += "\\\"";
    else if (c == '\\') out += "\\\\";
    else if (c == '\n') out += "\\n";
    else if (c == '\r') out += "\\r";
    else if (c == '\t') out += "\\t";
    else if (c < 0x20) { char buffer[8]; std::snprintf(buffer, sizeof buffer, "\\u%04x", c); out += buffer; }
    else out += char(c);
  }
  return out + "\"";
}

// Byte offsets to UTF-16 units, moving forward from the last conversion.
struct Offsets {
  const std::string &text;
  bool ascii;
  long at_byte = 0, at_unit = 0;

  long convert(long b) {
    if (b < 0 || ascii) return b;
    if (b < at_byte) at_byte = at_unit = 0;
    for (long i = at_byte; i < b;) {
      unsigned char c = text[i];
      int size = c < 0x80 ? 1 : c >= 0xF0 ? 4 : c >= 0xE0 ? 3 : c >= 0xC0 ? 2 : 1;
      at_unit += size == 4 ? 2 : 1;
      i += size;
    }
    at_byte = b;
    return at_unit;
  }
};

static const Json *get(const Object &o, const char *key) {
  auto it = o.find(key);
  return it == o.end() ? nullptr : &it->second;
}

static std::string failure(long id, const std::string &error) {
  return "{\"id\":" + std::to_string(id) + ",\"ok\":false,\"done\":true,\"error\":" + quote(error) + ",\"matches\":[],\"stride\":2}";
}

static std::string run(const Object &request, long id, const std::string &text) {
  auto flags = std::regex::ECMAScript;
  if (auto f = get(request, "flags"); f && std::holds_alternative<std::shared_ptr<Array>>(f->v)) {
    for (auto &flag : *std::get<std::shared_ptr<Array>>(f->v)) {
      auto name = std::get<std::string>(flag.v);
      if (name == "i") flags |= std::regex::icase;
      if (name == "m") flags |= std::regex::multiline;
    }
  }
  std::regex re;
  try {
    re = std::regex(std::get<std::string>(get(request, "pattern")->v), flags);
  } catch (const std::regex_error &e) {
    return failure(id, e.what());
  }
  long limit = 100000;
  if (auto l = get(request, "limit"); l && std::holds_alternative<double>(l->v) && std::get<double>(l->v) > 0) limit = long(std::get<double>(l->v));
  if (auto a = get(request, "all"); a && std::holds_alternative<bool>(a->v) && !std::get<bool>(a->v)) limit = 1;
  auto started = std::chrono::steady_clock::now();
  Offsets offsets{text, std::all_of(text.begin(), text.end(), [](char c) { return (unsigned char)c < 0x80; })};
  size_t groups = re.mark_count();
  std::ostringstream matches;
  bool first = true;
  long count = 0;
  try {
    for (auto it = std::sregex_iterator(text.begin(), text.end(), re); it != std::sregex_iterator() && count < limit; ++it, ++count) {
      const auto &m = *it;
      for (size_t g = 0; g <= groups; g++) {
        if (!first) matches << ',';
        first = false;
        if (m[g].matched) {
          long start = m.position(g);
          matches << offsets.convert(start) << ',' << offsets.convert(start + m.length(g));
        } else {
          matches << "-1,-1";
        }
      }
    }
  } catch (const std::regex_error &e) {
    return failure(id, std::string("std::regex gave up: ") + e.what());
  }
  double elapsed = std::chrono::duration<double, std::milli>(std::chrono::steady_clock::now() - started).count();
  return "{\"id\":" + std::to_string(id) + ",\"ok\":true,\"done\":true,\"matches\":[" + matches.str() + "],\"stride\":" +
         std::to_string((groups + 1) * 2) + ",\"elapsed\":" + std::to_string(elapsed) + ",\"names\":{}}";
}

int main() {
  std::ios::sync_with_stdio(false);
  std::string line, text;
  double text_id = NAN;
  bool have_text = false;
  while (std::getline(std::cin, line)) {
    Object request;
    try {
      Reader reader{line};
      request = *std::get<std::shared_ptr<Object>>(reader.value().v);
    } catch (...) {
      continue;
    }
    long id = 0;
    if (auto i = get(request, "id"); i && std::holds_alternative<double>(i->v)) id = long(std::get<double>(i->v));
    std::string reply;
    if (auto op = get(request, "op"); op && std::holds_alternative<std::string>(op->v) && std::get<std::string>(op->v) == "info") {
      reply = "{\"id\":" + std::to_string(id) + ",\"ok\":true,\"done\":true,\"versions\":{\"cpp\":\"libstdc++ " + std::to_string(__GLIBCXX__) + "\"}}";
    } else {
      if (auto p = get(request, "textPath"); p && std::holds_alternative<std::string>(p->v)) {
        // A file opened in Rex is read here rather than sent over the pipe.
        std::ifstream file(std::get<std::string>(p->v), std::ios::binary);
        text.assign(std::istreambuf_iterator<char>(file), std::istreambuf_iterator<char>());
        text_id = std::get<double>(get(request, "textId")->v);
        have_text = true;
      } else if (auto t = get(request, "text"); t && std::holds_alternative<std::string>(t->v)) {
        text = std::get<std::string>(t->v);
        text_id = std::get<double>(get(request, "textId")->v);
        have_text = true;
      }
      auto wanted = get(request, "textId");
      if (!have_text || !wanted || std::get<double>(wanted->v) != text_id) reply = failure(id, "missing-text");
      else reply = run(request, id, text);
    }
    std::cout << reply << '\n' << std::flush;
  }
}
