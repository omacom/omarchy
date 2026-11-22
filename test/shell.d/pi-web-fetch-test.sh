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
})
JS
