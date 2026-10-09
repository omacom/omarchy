# Rex worker for Ruby's regex engine (Onigmo). Same protocol as
# rex_worker.py: one JSON request per line on stdin, replies one per line on
# stdout, match offsets in UTF-16 code units.

require "json"

SLICE_SECONDS = 0.05

$stdin.binmode
$stdout.sync = true

def send_reply(object)
  $stdout.write(JSON.generate(object) + "\n")
end

# Code point offsets to UTF-16: astral characters take two units.
class CodePoints
  def initialize(text)
    @astral = []
    return if text.ascii_only?
    text.each_char.with_index { |c, i| @astral << i if c.ord > 0xFFFF }
  end

  def utf16(cp)
    return cp if cp.nil? || cp < 0 || @astral.empty?
    cp + (@astral.bsearch_index { |a| a >= cp } || @astral.size)
  end
end

class Lines
  def initialize
    @buffer = +""
  end

  def waiting?
    return true if @buffer.include?("\n")
    !IO.select([$stdin], nil, nil, 0).nil?
  end

  def read
    until @buffer.include?("\n")
      chunk = $stdin.readpartial(1 << 20) rescue nil
      return nil if chunk.nil?
      @buffer << chunk
    end
    line, @buffer = @buffer.split("\n", 2)
    line.force_encoding(Encoding::UTF_8)
  end
end

def monotonic
  Process.clock_gettime(Process::CLOCK_MONOTONIC)
end

def run_match(request, text, convert, lines)
  id = request["id"]
  options = 0
  flags = request["flags"] || []
  options |= Regexp::IGNORECASE if flags.include?("i")
  options |= Regexp::EXTENDED if flags.include?("x")
  options |= Regexp::MULTILINE if flags.include?("m")
  begin
    re = Regexp.new(request["pattern"], options)
  rescue RegexpError, ArgumentError => e
    send_reply({ id: id, ok: false, done: true, error: e.message, matches: [], stride: 2 })
    return
  end
  limit = request["limit"] || 100_000
  all = request.fetch("all", true)
  # Ruby numbers groups only by name once any group is named.
  names = {}
  re.named_captures.each { |name, indices| names[name] = indices.first }
  started = monotonic
  slice = started
  out = []
  count = 0
  stride = nil
  position = 0
  while position <= text.length
    m = re.match(text, position)
    break if m.nil?
    stride ||= m.size * 2
    m.size.times do |g|
      if m.begin(g).nil?
        out << -1 << -1
      else
        out << convert.utf16(m.begin(g)) << convert.utf16(m.end(g))
      end
    end
    count += 1
    break if count >= limit || !all
    position = m.end(0) == m.begin(0) ? m.end(0) + 1 : m.end(0)
    if monotonic - slice > SLICE_SECONDS
      send_reply({ id: id, ok: true, done: false, matches: out, stride: stride, elapsed: (monotonic - started) * 1000 })
      out = []
      slice = monotonic
      return if lines.waiting?
    end
  end
  stride ||= (groups_in(re) + 1) * 2
  send_reply({ id: id, ok: true, done: true, matches: out, stride: stride, elapsed: (monotonic - started) * 1000, names: names })
rescue Regexp::TimeoutError
  send_reply({ id: id, ok: false, done: true, kind: "limit", error: "Ruby's regexp timeout stopped the search", matches: out, stride: stride || 2 })
end

# A pattern that can match nothing still has groups; matching it or nothing
# against the empty string reports how many.
def groups_in(re)
  Regexp.new("(?:#{re.source})|", re.options).match("").size - 1
rescue RegexpError
  0
end

Regexp.timeout = 10.0 if Regexp.respond_to?(:timeout=)

lines = Lines.new
texts = {}
loop do
  line = lines.read
  break if line.nil?
  request = JSON.parse(line) rescue next
  id = request["id"]
  if request["op"] == "info"
    send_reply({ id: id, ok: true, done: true, versions: { ruby: RUBY_VERSION } })
    next
  end
  if request.key?("text")
    texts.clear
    text = request["text"]
    texts[request["textId"]] = [text, CodePoints.new(text)]
  end
  entry = texts[request["textId"]]
  if entry.nil?
    send_reply({ id: id, ok: false, done: true, error: "missing-text", matches: [], stride: 2 })
    next
  end
  begin
    run_match(request, entry[0], entry[1], lines)
  rescue StandardError => e
    send_reply({ id: id, ok: false, done: true, error: e.message, matches: [], stride: 2 })
  end
end
