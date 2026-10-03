#!/usr/bin/env node
import { Client, StreamableHTTPClientTransport } from '@modelcontextprotocol/client';
import { existsSync, mkdtempSync, readFileSync, writeFileSync } from 'node:fs';
import { homedir, tmpdir } from 'node:os';
import { join, resolve } from 'node:path';
import { fileURLToPath } from 'node:url';

export async function invokeDesktop(name, args, { state = process.env.HYPR_DESKTOP_STATE || join(homedir(), '.local/share/hypr-desktop'), fetch } = {}) {
  const endpoint = existsSync(join(state, 'local-url')) ? 'local-url' : 'url';
  const url = new URL(readFileSync(join(state, endpoint), 'utf8').trim());
  const token = readFileSync(join(state, 'token'), 'utf8').trim();
  const client = new Client({ name: 'agent-desktop-cli', version: '1' }, { versionNegotiation: { mode: 'auto' } });
  try {
    await client.connect(new StreamableHTTPClientTransport(url, {
      fetch,
      requestInit: { headers: { Authorization: `Bearer ${token}` }, redirect: 'error', signal: AbortSignal.timeout(150000) }
    }));
    return await client.callTool({ name, arguments: args }, undefined, { timeout: 150000 });
  } finally {
    await client.close();
  }
}

export function saveImages(result) {
  let directory;
  return {
    ...result,
    content: result.content.map((block, index) => {
      if (block.type !== 'image') return block;
      if (block.mimeType !== 'image/png') throw new Error(`unsupported screenshot type: ${block.mimeType}`);
      directory ??= mkdtempSync(join(tmpdir(), 'agent-desktop-capture-'));
      const path = join(directory, `${index}.png`);
      writeFileSync(path, Buffer.from(block.data, 'base64'), { mode: 0o600 });
      return { type: 'text', text: `Screenshot saved to ${path}. Open this image before using coordinates.` };
    })
  };
}

if (process.argv[1] && resolve(process.argv[1]) === fileURLToPath(import.meta.url)) {
  try {
    const [name, json = '{}'] = process.argv.slice(2);
    if (!name) throw new Error("usage: agent-desktop tool NAME 'JSON_ARGUMENTS'");
    const args = JSON.parse(json);
    if (!args || typeof args !== 'object' || Array.isArray(args)) throw new Error('tool arguments must be a JSON object');
    const result = saveImages(await invokeDesktop(name, args));
    console.log(JSON.stringify(result, null, 2));
    if (result.isError) process.exitCode = 1;
  } catch (error) {
    console.error(`agent-desktop tool: ${error.message}`);
    process.exitCode = 1;
  }
}
