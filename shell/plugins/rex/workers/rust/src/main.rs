//! Rex worker for Rust's regex crate. Same protocol as rex_worker.py: one
//! JSON request per line on stdin, replies one per line on stdout, match
//! offsets in UTF-16 code units. The requests are simple enough that a small
//! reader here saves a dependency on serde.

use regex::RegexBuilder;
use std::collections::BTreeMap;
use std::io::{self, BufRead, Write};
use std::time::Instant;

#[derive(Debug, Clone)]
enum Json {
    Null,
    Bool(bool),
    Number(f64),
    Str(String),
    Array(Vec<Json>),
    Object(BTreeMap<String, Json>),
}

struct Reader<'a> {
    bytes: &'a [u8],
    at: usize,
}

impl<'a> Reader<'a> {
    fn ws(&mut self) {
        while self.at < self.bytes.len() && b" \t\r\n".contains(&self.bytes[self.at]) {
            self.at += 1;
        }
    }

    fn value(&mut self) -> Option<Json> {
        self.ws();
        match *self.bytes.get(self.at)? {
            b'{' => {
                self.at += 1;
                let mut map = BTreeMap::new();
                loop {
                    self.ws();
                    if self.bytes.get(self.at) == Some(&b'}') {
                        self.at += 1;
                        return Some(Json::Object(map));
                    }
                    let key = match self.value()? {
                        Json::Str(s) => s,
                        _ => return None,
                    };
                    self.ws();
                    self.at += 1; // :
                    let value = self.value()?;
                    map.insert(key, value);
                    self.ws();
                    if self.bytes.get(self.at) == Some(&b',') {
                        self.at += 1;
                    }
                }
            }
            b'[' => {
                self.at += 1;
                let mut items = Vec::new();
                loop {
                    self.ws();
                    if self.bytes.get(self.at) == Some(&b']') {
                        self.at += 1;
                        return Some(Json::Array(items));
                    }
                    items.push(self.value()?);
                    self.ws();
                    if self.bytes.get(self.at) == Some(&b',') {
                        self.at += 1;
                    }
                }
            }
            b'"' => self.string().map(Json::Str),
            b't' => {
                self.at += 4;
                Some(Json::Bool(true))
            }
            b'f' => {
                self.at += 5;
                Some(Json::Bool(false))
            }
            b'n' => {
                self.at += 4;
                Some(Json::Null)
            }
            _ => {
                let start = self.at;
                while self.at < self.bytes.len() && b"-+.eE0123456789".contains(&self.bytes[self.at]) {
                    self.at += 1;
                }
                std::str::from_utf8(&self.bytes[start..self.at]).ok()?.parse().ok().map(Json::Number)
            }
        }
    }

    fn hex4(&mut self) -> Option<u32> {
        let s = std::str::from_utf8(self.bytes.get(self.at..self.at + 4)?).ok()?;
        self.at += 4;
        u32::from_str_radix(s, 16).ok()
    }

    fn string(&mut self) -> Option<String> {
        self.at += 1;
        let mut out = String::new();
        loop {
            let start = self.at;
            while self.at < self.bytes.len() && self.bytes[self.at] != b'"' && self.bytes[self.at] != b'\\' {
                self.at += 1;
            }
            out.push_str(std::str::from_utf8(&self.bytes[start..self.at]).ok()?);
            match *self.bytes.get(self.at)? {
                b'"' => {
                    self.at += 1;
                    return Some(out);
                }
                _ => {
                    let escape = *self.bytes.get(self.at + 1)?;
                    self.at += 2;
                    match escape {
                        b'n' => out.push('\n'),
                        b't' => out.push('\t'),
                        b'r' => out.push('\r'),
                        b'b' => out.push('\u{8}'),
                        b'f' => out.push('\u{c}'),
                        b'u' => {
                            let mut code = self.hex4()?;
                            if (0xD800..0xDC00).contains(&code) && self.bytes.get(self.at..self.at + 2) == Some(b"\\u") {
                                self.at += 2;
                                let low = self.hex4()?;
                                code = 0x10000 + ((code - 0xD800) << 10) + (low - 0xDC00);
                            }
                            out.push(char::from_u32(code).unwrap_or('\u{FFFD}'));
                        }
                        other => out.push(other as char),
                    }
                }
            }
        }
    }
}

fn parse(line: &str) -> Option<BTreeMap<String, Json>> {
    match (Reader { bytes: line.as_bytes(), at: 0 }).value()? {
        Json::Object(map) => Some(map),
        _ => None,
    }
}

fn quote(s: &str) -> String {
    let mut out = String::with_capacity(s.len() + 2);
    out.push('"');
    for c in s.chars() {
        match c {
            '"' => out.push_str("\\\""),
            '\\' => out.push_str("\\\\"),
            '\n' => out.push_str("\\n"),
            '\r' => out.push_str("\\r"),
            '\t' => out.push_str("\\t"),
            c if (c as u32) < 0x20 => out.push_str(&format!("\\u{:04x}", c as u32)),
            c => out.push(c),
        }
    }
    out.push('"');
    out
}

/// Byte offsets to UTF-16 units, moving forward from the last conversion.
struct Offsets<'a> {
    text: &'a str,
    ascii: bool,
    at_byte: usize,
    at_unit: usize,
}

impl<'a> Offsets<'a> {
    fn convert(&mut self, b: usize) -> usize {
        if self.ascii {
            return b;
        }
        if b < self.at_byte {
            self.at_byte = 0;
            self.at_unit = 0;
        }
        self.at_unit += self.text[self.at_byte..b].chars().map(char::len_utf16).sum::<usize>();
        self.at_byte = b;
        self.at_unit
    }
}

fn run(request: &BTreeMap<String, Json>, id: i64, text: &str) -> String {
    let pattern = match request.get("pattern") {
        Some(Json::Str(s)) => s.as_str(),
        _ => "",
    };
    let mut builder = RegexBuilder::new(pattern);
    if let Some(Json::Array(flags)) = request.get("flags") {
        for flag in flags {
            if let Json::Str(f) = flag {
                match f.as_str() {
                    "i" => { builder.case_insensitive(true); }
                    "m" => { builder.multi_line(true); }
                    "s" => { builder.dot_matches_new_line(true); }
                    "x" => { builder.ignore_whitespace(true); }
                    "U" => { builder.swap_greed(true); }
                    "R" => { builder.crlf(true); }
                    _ => {}
                }
            }
        }
    }
    builder.size_limit(64 << 20);
    let re = match builder.build() {
        Ok(re) => re,
        Err(e) => return format!("{{\"id\":{},\"ok\":false,\"done\":true,\"error\":{},\"matches\":[],\"stride\":2}}", id, quote(&e.to_string())),
    };
    let limit = match request.get("limit") {
        Some(Json::Number(n)) if *n > 0.0 => *n as usize,
        _ => 100_000,
    };
    let limit = if let Some(Json::Bool(false)) = request.get("all") { 1 } else { limit };
    let started = Instant::now();
    let groups = re.captures_len();
    let mut offsets = Offsets { text, ascii: text.is_ascii(), at_byte: 0, at_unit: 0 };
    let mut matches = String::new();
    for (count, caps) in re.captures_iter(text).enumerate() {
        if count >= limit {
            break;
        }
        for g in 0..groups {
            let (s, e) = match caps.get(g) {
                Some(m) => (offsets.convert(m.start()) as i64, offsets.convert(m.end()) as i64),
                None => (-1, -1),
            };
            if !matches.is_empty() {
                matches.push(',');
            }
            matches.push_str(&format!("{},{}", s, e));
        }
    }
    let mut names = Vec::new();
    for (i, name) in re.capture_names().enumerate() {
        if let Some(name) = name {
            names.push(format!("{}:{}", quote(name), i));
        }
    }
    format!(
        "{{\"id\":{},\"ok\":true,\"done\":true,\"matches\":[{}],\"stride\":{},\"elapsed\":{},\"names\":{{{}}}}}",
        id,
        matches,
        groups * 2,
        started.elapsed().as_secs_f64() * 1000.0,
        names.join(",")
    )
}

fn main() {
    let stdin = io::stdin();
    let stdout = io::stdout();
    let mut out = stdout.lock();
    let mut text = String::new();
    let mut text_id = f64::NAN;
    for line in stdin.lock().lines() {
        let Ok(line) = line else { break };
        let Some(request) = parse(&line) else { continue };
        let id = match request.get("id") {
            Some(Json::Number(n)) => *n as i64,
            _ => 0,
        };
        let reply = if matches!(request.get("op"), Some(Json::Str(op)) if op == "info") {
            format!("{{\"id\":{},\"ok\":true,\"done\":true,\"versions\":{{\"rust\":\"regex crate 1.x\"}}}}", id)
        } else {
            let from_file = match request.get("textPath") {
                // A file opened in Rex is read here rather than sent over the pipe.
                Some(Json::Str(path)) => std::fs::read(path).ok().map(|bytes| String::from_utf8_lossy(&bytes).into_owned()),
                _ => None,
            };
            if let Some(t) = from_file.or_else(|| match request.get("text") {
                Some(Json::Str(t)) => Some(t.clone()),
                _ => None,
            }) {
                text = t;
                text_id = match request.get("textId") {
                    Some(Json::Number(n)) => *n,
                    _ => f64::NAN,
                };
            }
            let wanted = match request.get("textId") {
                Some(Json::Number(n)) => *n,
                _ => f64::NAN,
            };
            if wanted != text_id {
                format!("{{\"id\":{},\"ok\":false,\"done\":true,\"error\":\"missing-text\",\"matches\":[],\"stride\":2}}", id)
            } else {
                run(&request, id, &text)
            }
        };
        let _ = writeln!(out, "{}", reply);
        let _ = out.flush();
    }
}
