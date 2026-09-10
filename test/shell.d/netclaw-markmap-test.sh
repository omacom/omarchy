#!/bin/bash

set -euo pipefail
source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

python3 - "$ROOT/default/netclaw" <<'PYTHON'
import json
from pathlib import Path
import shutil
import subprocess
import sys
import tempfile

with tempfile.TemporaryDirectory() as directory:
    root = Path(directory)
    package = root / "backend"
    workspace = root / "workspace"
    workspace.mkdir()
    files = {
        "package.json": '{"type":"module"}',
        "node_modules/@modelcontextprotocol/sdk/package.json": json.dumps({"type": "module", "exports": {
            "./server/index.js": {"import": "./dist/esm/server/index.js", "require": "./dist/cjs/server/index.cjs"},
            "./types.js": {"import": "./dist/esm/types.js", "require": "./dist/cjs/types.cjs"},
        }}),
        "node_modules/@modelcontextprotocol/sdk/dist/esm/server/index.js": 'export class Server { handlers = new Map(); setRequestHandler(schema, handler) { this.handlers.set(schema, handler); } }',
        "node_modules/@modelcontextprotocol/sdk/dist/cjs/server/index.cjs": 'exports.Server = class { setRequestHandler() {} };',
        "node_modules/@modelcontextprotocol/sdk/dist/esm/types.js": 'export const ListToolsRequestSchema = {}; export const CallToolRequestSchema = {};',
        "node_modules/@modelcontextprotocol/sdk/dist/cjs/types.cjs": 'exports.ListToolsRequestSchema = {}; exports.CallToolRequestSchema = {};',
        "node_modules/jsdom/index.js": '''exports.JSDOM = {fragment(content) { return {content, querySelectorAll() { return []; }, ownerDocument: {createElement() { return {append(fragment) { this.innerHTML = fragment.content; }}; }}}; }};''',
        "node_modules/d3/dist/d3.min.js": '/* fixture d3 */',
        "node_modules/markmap-view/dist/browser/index.js": '/* fixture markmap */',
        "dist/lib/markmap-handler.js": 'export class MarkmapHandler { parseMarkdown(content) { return {root: {content, children: []}}; } }',
        "dist/index.js": '''
import {Server} from '@modelcontextprotocol/sdk/server/index.js';
import {ListToolsRequestSchema, CallToolRequestSchema} from '@modelcontextprotocol/sdk/types.js';
import {MarkmapHandler} from './lib/markmap-handler.js';
const server = new Server();
server.setRequestHandler(ListToolsRequestSchema, async () => ({tools: [{name: 'markmap_generate', description: 'Generate SVG', inputSchema: {properties: {}}}]}));
server.setRequestHandler(CallToolRequestSchema, async request => ({content: [], structuredContent: {svg_content: await new MarkmapHandler().renderToSVG(request.params.arguments.markdown_content), node_count: 1}}));
const call = async output_path => {
  try { return await server.handlers.get(CallToolRequestSchema)({params: {name: 'markmap_generate', arguments: {markdown_content: 'Observed facts', output_path}}}); }
  catch (error) { return {error: error.message}; }
};
console.log(JSON.stringify({
  tools: await server.handlers.get(ListToolsRequestSchema)(),
  rendered: await call('showcase/map.html'),
  traversal: await call('../outside.html'),
  svg: await call('showcase/map.svg'),
  symlink: await call('linked/outside.html'),
  overwrite: await call('showcase/map.html')
}));
''',
    }
    for relative, content in files.items():
        path = package / relative
        path.parent.mkdir(parents=True, exist_ok=True)
        path.write_text(content)
    launchers = root / "launchers"
    launchers.mkdir()
    for name in ("markmap-launcher.mjs", "markmap-document.mjs"):
        shutil.copyfile(Path(sys.argv[1]) / name, launchers / name)
    (launchers / "markmap-launcher.json").write_text(json.dumps({"backend": str(package / "dist/index.js")}))
    (workspace / "linked").symlink_to(root, target_is_directory=True)
    result = subprocess.run(["node", str(launchers / "markmap-launcher.mjs")], cwd=workspace, capture_output=True, text=True, timeout=15)
    assert result.returncode == 0, result.stderr
    output = json.loads(result.stdout)
    assert 'HTML' in output['tools']['tools'][0]['description']
    artifact = workspace / "showcase/map.html"
    assert artifact.read_text().startswith('<!doctype html>')
    assert Path(output['rendered']['structuredContent']['saved_path']).resolve() == artifact.resolve()
    assert output['rendered']['structuredContent']['mime_type'] == 'text/html'
    assert 'svg_content' not in output['rendered']['structuredContent'], 'Large HTML must not enter model context'
    assert output['traversal']['isError'] and output['svg']['isError']
    assert output['symlink']['error'] and not (root / 'outside.html').exists()
    assert output['overwrite']['error'], 'Existing artifacts must be preserved'
PYTHON
pass 'Markmap intercepts the ESM MCP, saves HTML artifacts, and protects output paths'
