#!/bin/bash

set -euo pipefail

source "$(dirname "$0")/base-test.sh"

# web_fetch hands the model Markdown made by default/agents/pi/lib/html-to-markdown.ts.
# It imports nothing from pi, so it runs under plain Node, which strips the types.
ROOT="$ROOT" run_node_test <<'JS'
import(path.join(root, 'default/agents/pi/lib/html-to-markdown.ts')).then(({ htmlToMarkdown, titleOf }) => {
  const page = `<html><head><title>Docs &amp; more</title><script>tracker()</script></head><body>
    <nav><a href="/">Home</a></nav>
    <main>
      <h1>Install</h1>
      <p>Read <a href="../guide">the guide</a> or jump to <a href="#steps">the steps</a>.<i class="icon"></i></p>
      <pre><code class="language-bash">pi install ./pkg</code></pre>
      <table>
        <tr><th>Header type</th><td>Request</td></tr>
        <tr><td><h3>Spec</h3></td><td>RFC 9110</td></tr>
      </table>
    </main>
    <footer>Copyright</footer>
  </body></html>`
  const markdown = htmlToMarkdown(page, 'https://example.com/docs/install')

  assertEqual(titleOf(page), 'Docs & more', 'the title is read from <title> with entities decoded')
  assert(!/tracker|Home|Copyright/.test(markdown), 'scripts, navigation and footers are dropped', markdown)
  assert(markdown.startsWith('# Install'), 'the page is read from its <main>', markdown)
  assert(markdown.includes('[the guide](https://example.com/guide)'), 'links resolve against the page URL', markdown)
  assert(markdown.includes('jump to the steps.') && !markdown.includes('**'), 'in-page links and empty icon tags leave plain text', markdown)
  assert(markdown.includes('```bash\npi install ./pkg\n```'), 'code blocks keep the language from their <code>', markdown)
  assert(
    markdown.includes('| Header type | Request |\n| --- | --- |\n| Spec | RFC 9110 |'),
    'a table gets a header separator as wide as its first row, and a heading in a cell stays on its row',
    markdown
  )

  // Minified scripts compare with < and attributes hold >; neither may swallow
  // or leak into the page.
  const tricky = htmlToMarkdown(
    '<body><script>if (a<b) { go() }</script><div x-show="count > 0"><p>After the script</p></div></body>'
  )
  assertEqual(tricky, 'After the script', 'a < in a script or a > in an attribute leaves the rest of the page intact')

  // Inactive tabs are hidden, not gone: docs put the other install commands there.
  const tabs = htmlToMarkdown('<main><div><p>npm i pkg</p></div><div hidden><p>pacman -S pkg</p></div><span aria-hidden="true">★</span></main>')
  assert(tabs.includes('pacman -S pkg') && !tabs.includes('★'), 'hidden tab panels stay, aria-hidden decoration goes', tabs)

  // A <main> holding only a stub falls back to the whole body.
  const stub = htmlToMarkdown(`<body><main><p>Hi</p></main><div><p>${'The real article text. '.repeat(20)}</p></div></body>`)
  assert(stub.includes('The real article text.'), 'a nearly empty <main> falls back to the body', stub)

  // <base href> sets what relative links resolve against.
  const based = htmlToMarkdown('<head><base href="https://docs.example.com/v2/"></head><body><a href="intro">Intro</a></body>', 'https://example.com/x')
  assertEqual(based, '[Intro](https://docs.example.com/v2/intro)', 'relative links resolve against <base href>')

  // Code comes through exactly: trailing spaces and blank lines kept, and a
  // fence longer than any backticks inside, such as a Markdown example's own.
  const code = htmlToMarkdown('<body><pre>a  \n\n\n\nb\n```\nc\n```</pre></body>')
  assertEqual(code, '````\na  \n\n\n\nb\n```\nc\n```\n````', 'code blocks keep their whitespace and fence around inner backticks')

  // HTML may leave out </tr> and </td>.
  const loose = htmlToMarkdown('<body><table><tr><td>A<td>B<tr><td>C<td>D</table></body>')
  assertEqual(loose, '| A | B |\n| --- | --- |\n| C | D |', 'table rows end without </tr>')
})
JS
