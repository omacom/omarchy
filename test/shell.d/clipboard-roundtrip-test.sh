#!/bin/bash

set -euo pipefail
source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

run_node_test <<'JS'
const fs = require('fs')
const cp = require('child_process')
const c = requireFromRoot('shell/plugins/clipboard/ClipboardHistory.js')
const temp = fs.mkdtempSync('/tmp/clipboard-roundtrip-')
try {
  for (const [name, unit, length] of [['CJK','中',87000], ['emoji','😀',50000], ['escaped controls','\u0001',200000]]) {
    let history=[]
    for (let i=0;i<96;i++) history=c.addEntry(history,{type:'text',text:i+':'+unit.repeat(length)},500)
    const file=path.join(temp,'history.json')
    const saved=cp.spawnSync('bash',[path.join(root,'shell/plugins/clipboard/save-history.sh'),file,String(c.historyFileLimit)],{input:JSON.stringify(history),encoding:'utf8'})
    assertEqual(saved.status,0,'clipboard saves its own '+name+' history: '+saved.stderr)
    const result=cp.spawnSync('bash',[path.join(root,'shell/plugins/clipboard/load-history.sh'),file,String(c.historyFileLimit)],{encoding:'utf8',maxBuffer:32*1024*1024,env:{...process.env,XDG_STATE_HOME:temp}})
    assertEqual(result.status,0,'clipboard reloads its own '+name+' history: '+result.stderr)
    const loaded=c.parseHistory(result.stdout,500)
    assertDeepEqual(loaded.map(e=>e.type==='text'?e.text:fs.readFileSync(e.path,'utf8')),history.map(e=>e.text),'clipboard restart preserves every retained '+name+' copy')
    assert(Buffer.byteLength(JSON.stringify(history))<=c.historyBudget,'clipboard writer enforces the UTF-8 byte budget for '+name)
  }
  const legacy=Array.from({length:96},(_,i)=>({type:'text',text:i+':'+ '中'.repeat(87000)}))
  const legacyFile=path.join(temp,'legacy.json')
  fs.writeFileSync(legacyFile,JSON.stringify(legacy))
  const migrated=cp.spawnSync('bash',[path.join(root,'shell/plugins/clipboard/load-history.sh'),legacyFile,String(c.historyFileLimit)],{encoding:'utf8',maxBuffer:32*1024*1024,env:{...process.env,XDG_STATE_HOME:temp}})
  assertEqual(migrated.status,0,'clipboard migrates history written with the former UTF-16 budget')
  const entries=c.parseHistory(migrated.stdout,500)
  assertDeepEqual(entries.map(e=>e.type==='text'?e.text:fs.readFileSync(e.path,'utf8')),legacy.map(e=>e.text),'clipboard preserves all 96 legacy CJK copies across migration')
} finally { fs.rmSync(temp,{recursive:true,force:true}) }
JS
