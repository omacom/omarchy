#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

run_node_test <<'JS'
const menu = requireFromRoot('shell/plugins/menu/MenuModel.js')

assertEqual(menu.urlFor('github.com'), 'https://github.com', 'bare hosts open over https')
assertEqual(menu.urlFor('omarchy.org/manual'), 'https://omarchy.org/manual', 'bare hosts keep their path')
assertEqual(menu.urlFor('news.ycombinator.com'), 'https://news.ycombinator.com', 'subdomains are hosts')
assertEqual(menu.urlFor('http://example.com/a?b=1'), 'http://example.com/a?b=1', 'full URLs pass through')
assertEqual(menu.urlFor('localhost:3000'), 'http://localhost:3000', 'localhost opens over http')
assertEqual(menu.urlFor('192.168.1.1'), 'http://192.168.1.1', 'IPv4 addresses open over http')
assertEqual(menu.urlFor('localhost:3000?view=logs'), 'http://localhost:3000?view=logs', 'local addresses keep a query with no path')
assertEqual(menu.urlFor('192.168.1.1#status'), 'http://192.168.1.1#status', 'IPv4 addresses keep a fragment with no path')
assertEqual(menu.urlFor('github.com?tab=repos'), 'https://github.com?tab=repos', 'bare hosts keep a query with no path')
assertEqual(menu.urlFor('zen'), '', 'a word is not an address')
assertEqual(menu.urlFor('v1.2'), '', 'a version number is not an address')
assertEqual(menu.urlFor('github .com'), '', 'text with spaces is not an address')
assertEqual(menu.urlFor('https://'), '', 'a scheme alone is not an address')

const url = menu.quickRows('github.com')
assertEqual(url.top.length, 1, 'an address gives one top row')
assertEqual(url.top[0].action, "omarchy-launch-browser 'https://github.com'", 'the address row opens the default browser')
assertEqual(url.fallback, null, 'an address offers no web search')

const search = menu.quickRows("it's zen")
assertEqual(search.top.length, 0, 'plain text gives no top row')
assertEqual(
  search.fallback.action,
  "omarchy-launch-browser 'https://www.google.com/search?q=it'\\''s%20zen'",
  'web search encodes and shell-quotes the query'
)
assertEqual(search.fallback.kind, 'action', 'quick rows run like menu actions')

const empty = menu.quickRows('   ')
assertEqual(empty.top.length + (empty.fallback ? 1 : 0), 0, 'an empty query gives no quick rows')
JS
