// Limited shell word scanner: quotes and nested substitutions remain one argument.
// This deliberately does not execute shell code or infer the provenance of variables.
function words(source, substitutionEnd = () => {}) {
  const out = []
  let word = '', quote = '', depth = 0, stack = []
  for (let i = 0; i < source.length; i++) {
    const c = source[i]
    if (!quote && !depth && !word && /[0-9]/.test(c) && /[<>]/.test(source[i + 1] || '')) break
    if (c === '\\') { word += c + (source[++i] || ''); continue }
    if (quote !== "'" && c === '$' && source[i + 1] === '(') {
      stack.push(quote); quote = ''; depth++; word += '$('; i++; continue
    }
    if (!quote && depth && c === '(') { stack.push(''); depth++; word += c; continue }
    if (!quote && depth && c === ')') {
      depth--; quote = stack.pop(); word += c
      if (!depth) substitutionEnd(i)
      continue
    }
    if (c === quote) { quote = ''; word += c; continue }
    if (!quote && (c === '"' || c === "'")) { quote = c; word += c; continue }
    if (!quote && !depth && /[\s;|&<>)]/.test(c)) {
      if (word) { out.push(word); word = '' }
      if (!/\s/.test(c)) break
    } else word += c
  }
  if (word) out.push(word)
  return out
}
const unquote = s => /^(["']).*\1$/s.test(s) ? s.slice(1, -1) : s
function argumentsFor(command, source) {
  const args = words(source), result = []
  if (command === 'omarchy-menu-select') return [{ role: 'prompt', value: args[0] || '' }]
  if (command === 'omarchy-file-select') {
    for (let i = 0; i < args.length; i++) {
      if (args[i] === '--title') result.push({ role: 'title', value: args[++i] || '' })
      else if (args[i].startsWith('--title=')) result.push({ role: 'title', value: args[i].slice(8) })
      else if (args[i].includes('[@]')) result.push({ role: 'title', value: args[i] })
    }
    return result.length ? result : [{ role: 'title', value: 'Select file' }]
  }
  if (command === 'omarchy-osd') {
    for (let i = 0; i < args.length; i++) if (args[i] === '-m') result.push({ role: 'message', value: args[++i] || '' })
    return result
  }
  const options = new Set(['-g','--glyph','-u','--urgency','--app-name','-i','--icon','--image','-r','--replace-id','-t','--expire-time'])
  for (let i = 0; i < args.length; i++) {
    const arg = args[i]
    if (arg === '--exec') break
    if (options.has(arg)) { i++; continue }
    if (options.has(arg.split('=')[0]) || ['-p','--print-id'].includes(arg)) continue
    result.push({ role: result.length ? 'body' : 'title', value: arg })
    if (result.length === 2) break
  }
  return result
}
function classifyArgument(arg, file, surface, catalog, allowlist) {
  const value = unquote(arg.value)
  const allow = allowlist.find(a => a.file === file && a.surface === surface && a.role === arg.role && a.pattern === value)
  if (allow) return allow.type
  // Only a complete translation substitution qualifies; surrounding raw wording does not.
  if (/^\$\(omarchy-i18n\s[\s\S]*\)$/.test(value)) {
    const ends = []
    words(value, index => ends.push(index))
    if (ends[0] !== value.length - 1) return 'UNCLASSIFIED'
    const key = value.match(/^\$\(omarchy-i18n\s+\$?(["'])(.*?)\1/)
    if (!key) return 'UNCLASSIFIED'
    const decoded = key[2].replace(/\\n/g, '\n').replace(/\\t/g, '\t')
    return decoded in catalog ? 'LOCALIZED' : 'MISSING'
  }
  if (/[$`]/.test(value)) return 'UNCLASSIFIED'
  if (!/[\p{L}]/u.test(value)) return 'PRESERVED'
  return 'MISSING'
}
function auditStatement(stmt, file, catalog, allowlist) {
  const results = []
  const re = /\bomarchy-(notification-send|osd|menu-select|file-select)(?=\s)/g
  let match
  while ((match = re.exec(stmt))) {
    const command = match[0]
    const surface = match[1] === 'notification-send' ? 'notification' : match[1] === 'osd' ? 'osd' : 'selector'
    let source = stmt.slice(re.lastIndex)
    for (const entry of allowlist.filter(a => a.file === file && a.surface === surface && a.role === 'options' && a.type === 'OPTIONS')) {
      source = source.replace('"' + entry.pattern + '"', '')
    }
    let args = argumentsFor(command, source)
    // An argv array may contain both title and body. Require separate documented roles.
    if (surface === 'notification' && args[0]?.value.includes('[@]')) args = [args[0], { role: 'body', value: args[0].value }]
    results.push({ surface, args: args.map(arg => ({ ...arg, status: classifyArgument(arg, file, surface, catalog, allowlist) })) })
    // Nested translation commands contain no graphical invocations in current conventions.
  }
  return results
}
function classifyQml(literal, catalog, preserved) {
  const str = literal.trim()
  if (preserved.has(str)) return 'PRESERVED'
  if (!str || !/[\p{L}]/u.test(str) || /^(\\u[0-9a-fA-F]{4})+$/.test(str) || /^[\d.]+\s*(?:%|MB|GB|KB|s|ms|h|m|W|Wh|°C|px|pt)?$/i.test(str)) return 'IGNORED'
  return str in catalog ? 'TRANSLATED' : 'MISSING'
}
function auditQmlLine(line, catalog, preserved) {
  const regex = /(?:^|\s)(text|title|label|tooltipText|placeholderText|description|headerText)\s*:\s*(?:(["'])((?:\\.|(?!\2).)*)\2|I18n\.(trc?)\(([^)]+)\)|([a-zA-Z0-9_$.]+))/g
  return [...line.matchAll(regex)].map(m => ({
    prop: m[1], literal: m[3],
    status: m[4] ? 'TRANSLATED' : m[3] !== undefined ? classifyQml(m[3], catalog, preserved) : m[6] ? 'DYNAMIC' : 'UNCLASSIFIED'
  }))
}
module.exports = { words, argumentsFor, auditStatement, classifyQml, auditQmlLine }
