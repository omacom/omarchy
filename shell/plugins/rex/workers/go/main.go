// Rex worker for Go's regexp package (RE2 syntax). Same protocol as
// rex_worker.py: one JSON request per line on stdin, replies one per line on
// stdout, match offsets in UTF-16 code units.
package main

import (
	"bufio"
	"encoding/json"
	"os"
	"regexp"
	"runtime"
	"strings"
	"time"
	"unicode/utf8"
)

type request struct {
	Op      string   `json:"op"`
	ID      int      `json:"id"`
	Pattern string   `json:"pattern"`
	Flags   []string `json:"flags"`
	Text    *string  `json:"text"`
	TextID  int      `json:"textId"`
	Path    string   `json:"textPath"`
	All     *bool    `json:"all"`
	Limit   int      `json:"limit"`
}

type reply struct {
	ID       int               `json:"id"`
	OK       bool              `json:"ok"`
	Done     bool              `json:"done"`
	Error    string            `json:"error,omitempty"`
	Matches  []int             `json:"matches"`
	Stride   int               `json:"stride"`
	Elapsed  float64           `json:"elapsed"`
	Names    map[string]int    `json:"names,omitempty"`
	Versions map[string]string `json:"versions,omitempty"`
}

var out = bufio.NewWriterSize(os.Stdout, 1<<16)

func send(r reply) {
	if r.Matches == nil {
		r.Matches = []int{}
	}
	encoder := json.NewEncoder(out)
	encoder.SetEscapeHTML(false)
	encoder.Encode(r)
	out.Flush()
}

// utf16Offsets converts byte offsets to UTF-16 units, moving forward from
// the last conversion as offsets mostly do.
type utf16Offsets struct {
	text   string
	ascii  bool
	atByte int
	atUnit int
}

func newOffsets(text string) *utf16Offsets {
	ascii := true
	for i := 0; i < len(text); i++ {
		if text[i] >= 0x80 {
			ascii = false
			break
		}
	}
	return &utf16Offsets{text: text, ascii: ascii}
}

func (o *utf16Offsets) units(from, to int) int {
	n := 0
	for i := from; i < to; {
		r, size := utf8.DecodeRuneInString(o.text[i:])
		if r >= 0x10000 {
			n += 2
		} else {
			n++
		}
		i += size
	}
	return n
}

func (o *utf16Offsets) convert(b int) int {
	if b < 0 || o.ascii {
		return b
	}
	if b < o.atByte {
		o.atByte, o.atUnit = 0, 0
	}
	o.atUnit += o.units(o.atByte, b)
	o.atByte = b
	return o.atUnit
}

func run(req request, text string, offsets *utf16Offsets) {
	prefix := ""
	posix := false
	for _, f := range req.Flags {
		switch f {
		case "i", "m", "s", "U":
			prefix += f
		case "L":
			posix = true
		}
	}
	pattern := req.Pattern
	if prefix != "" {
		pattern = "(?" + prefix + ")" + pattern
	}
	var re *regexp.Regexp
	var err error
	if posix {
		re, err = regexp.CompilePOSIX(pattern)
	} else {
		re, err = regexp.Compile(pattern)
	}
	if err != nil {
		send(reply{ID: req.ID, Done: true, Error: strings.TrimPrefix(err.Error(), "error parsing regexp: "), Stride: 2})
		return
	}
	limit := req.Limit
	if limit <= 0 {
		limit = 100000
	}
	if req.All != nil && !*req.All {
		limit = 1
	}
	started := time.Now()
	groups := re.NumSubexp()
	matches := []int{}
	for _, m := range re.FindAllStringSubmatchIndex(text, limit) {
		for _, b := range m {
			matches = append(matches, offsets.convert(b))
		}
	}
	names := map[string]int{}
	for i, name := range re.SubexpNames() {
		if name != "" {
			if _, seen := names[name]; !seen {
				names[name] = i
			}
		}
	}
	send(reply{ID: req.ID, OK: true, Done: true, Matches: matches, Stride: (groups + 1) * 2, Elapsed: float64(time.Since(started).Microseconds()) / 1000, Names: names})
}

func main() {
	in := bufio.NewReaderSize(os.Stdin, 1<<20)
	var text string
	textID := -1
	var offsets *utf16Offsets
	for {
		line, err := in.ReadString('\n')
		if len(line) > 0 {
			var req request
			if json.Unmarshal([]byte(line), &req) == nil {
				if req.Op == "info" {
					send(reply{ID: req.ID, OK: true, Done: true, Versions: map[string]string{"go": runtime.Version()}})
				} else {
					if req.Path != "" {
						// A file opened in Rex is read here rather than sent over the pipe.
						if data, err := os.ReadFile(req.Path); err == nil {
							s := strings.ToValidUTF8(string(data), "\uFFFD")
							req.Text = &s
						}
					}
					if req.Text != nil {
						text, textID, offsets = *req.Text, req.TextID, newOffsets(*req.Text)
					}
					if textID != req.TextID {
						send(reply{ID: req.ID, Done: true, Error: "missing-text", Stride: 2})
					} else {
						run(req, text, offsets)
					}
				}
			}
		}
		if err != nil {
			return
		}
	}
}
