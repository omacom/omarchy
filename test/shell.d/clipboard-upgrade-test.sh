#!/bin/bash

set -euo pipefail
source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

run_node_test <<'JS'
const fs = require('fs')
const os = require('os')
const cp = require('child_process')
const c = requireFromRoot('shell/plugins/clipboard/ClipboardHistory.js')
const vm = require('vm')
const qml = fs.readFileSync(path.join(root,'shell/plugins/clipboard/Clipboard.qml'),'utf8')
function qmlFunction(name, context) {
  const start=qml.indexOf('function '+name+'(')
  const end=qml.indexOf('\n  }',start)+4
  return vm.runInNewContext('('+qml.slice(start,end)+')',context)
}
const actions=[]
const component={createObject:(_parent,properties)=>{const action={...properties,stdinEnabled:true};actions.push(action);return action}}
const ui={historyWritable:true,opened:true,history:[{type:'text',text:'selected snapshot'}]}
ui.runEntryAction=qmlFunction('runEntryAction',{root:ui,entryActionComponent:component})
ui.omarchyPath=root
qmlFunction('copySelected',{root:ui,Quickshell:{execDetached:()=>fail('inline copy should use the selected snapshot')}})({entryType:'text',fullText:'selected snapshot',historyIndex:0})
const action=actions[0]
assertEqual(JSON.parse(action.entryJson).text,'selected snapshot','clipboard picker sends the full selected entry rather than a saved position')
assert(action.running && action.stdinEnabled,'clipboard picker opens the action pipe')
assert(action.command.includes('--stdin') && action.command.includes('--copy-only'),'clipboard picker requests snapshot copy without typing')
ui.opened=true
qmlFunction('openSelected',{root:ui})({entryType:'text',historyIndex:0})
qmlFunction('copySelected',{root:ui})({entryType:'text',fullText:'selected snapshot',historyIndex:0})
assertEqual(actions.length,3,'clipboard copy starts while an earlier editor action remains running')
assert(actions[1].running && actions[2].running,'clipboard actions have independent process lifetimes')
ui.historyWritable=false
ui.opened=true
qmlFunction('copySelected',{root:ui})({entryType:'text',fullText:'selected snapshot',historyIndex:0})
assert(actions.length===3 && ui.opened,'clipboard picker waits for a successful load before actions')
const loadProc={running:false},saveProc={running:false}
const pending={historyWritable:false,history:[{type:'text',text:'pending'}],historyLimit:500,saveRequested:false,reloadRequested:false}
pending.pumpStorage=qmlFunction('pumpStorage',{root:pending,loadProc,saveProc})
pending.saveHistory=qmlFunction('saveHistory',{root:pending})
pending.saveHistory()
assert(!saveProc.running,'clipboard picker does not overwrite a history that failed to load')
pending.historyWritable=true
pending.saveHistory()
assertEqual(JSON.parse(saveProc.snapshot)[0].text,'pending','clipboard picker saves only after a successful load')
pending.history=[{type:'text',text:'newest'}]
pending.saveHistory()
pending.reloadRequested=true
pending.pumpStorage()
assert(!loadProc.running,'clipboard defers a reload until the save finishes')
saveProc.running=false
pending.pumpStorage()
assertEqual(JSON.parse(saveProc.snapshot)[0].text,'newest','clipboard queued save includes the newest capture')
saveProc.running=false
pending.pumpStorage()
assert(loadProc.running && !pending.historyWritable,'clipboard reload starts after queued saves complete')
loadProc.running=false
pending.historyWritable=true
pending.clearBackupsRequested=true
pending.saveHistory()
assert(saveProc.clearBackups===true && !pending.clearBackupsRequested,'clipboard clear asks one save to remove recovery backups')
saveProc.running=false
pending.saveHistory()
assert(saveProc.clearBackups===false,'clipboard later saves keep recovery backups')
saveProc.running=false
assert(/historyNotice === root\.saveFailedNotice\) root\.historyNotice = ""/.test(qml),'clipboard clears the save failure notice after a successful save')
const temp = fs.mkdtempSync(path.join(os.tmpdir(), 'clipboard-upgrade-'))
const state = path.join(temp, 'omarchy')
const textDir = path.join(state, 'clipboard-text')
const historyPath = path.join(state, 'clipboard-history.json')
fs.mkdirSync(textDir, {recursive:true})
function load(raw, ceiling = c.historyFileLimit) {
  fs.writeFileSync(historyPath, raw)
  return cp.spawnSync('bash', [path.join(root, 'shell/plugins/clipboard/load-history.sh'), historyPath, String(ceiling)], {encoding:'utf8', maxBuffer:c.historyFileLimit + 1024, env:{...process.env, XDG_STATE_HOME:temp}})
}
function prune(...names) {
  const result = cp.spawnSync('bash', [path.join(root, 'shell/plugins/clipboard/prune-text.sh'), textDir, historyPath, ...names], {encoding:'utf8'})
  assertEqual(result.status, 0, 'clipboard prune completes')
}
function stale(letter) {
  const name = letter.repeat(64) + '.txt'
  fs.writeFileSync(path.join(textDir, name), letter)
  const then = new Date(Date.now()-180000)
  fs.utimesSync(path.join(textDir, name), then, then)
  return name
}
try {
  const largeText = 'x'.repeat(3 * 1024 * 1024) + '\n日本 😀\u0000'
  let result = load(JSON.stringify([{type:'text',text:'newest'},{type:'text',text:largeText},{type:'text',text:'older'}]))
  assertEqual(result.status, 0, 'clipboard migrates existing history')
  let entries = c.parseHistory(result.stdout, 500)
  assertEqual(entries.length, 3, 'clipboard upgrade preserves oversized old entries')
  assertEqual(entries[1].type, 'largetext', 'clipboard upgrade stores oversized text as a file')
  assertEqual(fs.readFileSync(entries[1].path,'utf8'), largeText, 'clipboard upgrade preserves full Unicode and control text')
  assertDeepEqual(JSON.parse(fs.readFileSync(historyPath,'utf8')), entries, 'clipboard upgrade synchronizes disk and picker before load')
  const row = c.displayRows(entries,'older',50)[0]
  assertEqual(JSON.parse(fs.readFileSync(historyPath,'utf8'))[row.index].text,'older', 'clipboard selection reads the correct migrated position')
  const original = fs.readFileSync(historyPath,'utf8')
  result = cp.spawnSync('bash',[path.join(root,'shell/plugins/clipboard/load-history.sh'),historyPath,String(c.historyFileLimit)],{encoding:'utf8',env:{...process.env,XDG_STATE_HOME:temp}})
  assertEqual(fs.readFileSync(historyPath,'utf8'),original,'clipboard migration is idempotent')
  assertEqual(result.status,0,'clipboard reload succeeds')

  result = load(JSON.stringify(Array.from({length:34},(_,i)=>({type:'text',text:i+':'+ 'z'.repeat(1024*1024)}))))
  assertEqual(result.status,0,'clipboard streams legacy history above the loader ceiling')
  entries = c.parseHistory(result.stdout,500)
  assertEqual(entries.length,34,'clipboard migration preserves history above the old byte budget')
  assert(Buffer.byteLength(result.stdout)<=c.historyFileLimit,'clipboard migration returns bounded history')
  const overCount = JSON.stringify(Array.from({length:501},(_,i)=>'entry '+i))
  result = load(overCount)
  assertEqual(result.status,0,'clipboard loads history above the entry limit')
  assertEqual(JSON.parse(result.stdout).length,500,'clipboard retains the newest entries within the limit')
  assert(fs.readdirSync(state).filter(n=>n.startsWith('clipboard-history.json.migrated-')).some(n=>fs.readFileSync(path.join(state,n),'utf8')===overCount),'clipboard backs up every entry before applying retention')
  assert(result.stderr.includes('some entries kept only'),'clipboard explains the recovery backup')
  result = load(JSON.stringify(['a'.repeat(65533)+'\\\"\n😀日本','\u0085','\ufeff']))
  entries = c.parseHistory(result.stdout,500)
  assertEqual(entries.length,2,'clipboard loader agrees with JavaScript whitespace rules')
  assertEqual(entries[0].text,'a'.repeat(65533)+'\\\"\n😀日本','clipboard streaming decoder preserves text across chunk boundaries')
  result = load('["'+ 'x'.repeat(65530)+'\\ud83d\\ude00'+'"]')
  assertEqual(c.parseHistory(result.stdout,500)[0].text,'x'.repeat(65530)+'😀','clipboard streaming decoder preserves escaped surrogate pairs across chunk boundaries')
  for (const raw of ['[NaN]','[][]','[Infinity]','["unterminated]','[1,]']) {
    result=load(raw)
    assertEqual(result.stdout,'[]','clipboard loader rejects malformed JSON '+raw)
    assert(!fs.existsSync(historyPath),'clipboard preserves rejected original '+raw)
    assert(result.stderr.length>0,'clipboard rejection explains recovery '+raw)
  }
  result=load(' \n\t ')
  assertEqual(result.stdout,'[]','clipboard loads whitespace-only history as empty')
  assert(fs.existsSync(historyPath),'clipboard does not reject whitespace-only history')

  const protectedName=stale('a'), orphan=stale('b')
  fs.writeFileSync(historyPath,'[]')
  fs.writeFileSync(historyPath+'.rejected-probe','broken '+protectedName)
  prune()
  assert(fs.existsSync(path.join(textDir,protectedName)),'clipboard protects files referenced by rejected histories')
  assert(!fs.existsSync(path.join(textDir,orphan)),'clipboard still cleans unreferenced files after rejection')
  const onDisk=stale('c')
  fs.writeFileSync(historyPath,JSON.stringify([{type:'largetext',path:path.join(textDir,onDisk),bytes:1,preview:'c'}]))
  prune()
  assert(fs.existsSync(path.join(textDir,onDisk)),'clipboard protects files referenced by the last successful save')
  const invalidGuard=stale('d')
  fs.writeFileSync(historyPath,'invalid')
  prune()
  assert(fs.existsSync(path.join(textDir,invalidGuard)),'clipboard does not prune when the saved history is unreadable')

  const large={type:'text',text:'x'.repeat(c.entryTextLimit)}
  const costly={type:'text',text:'\u0001'.repeat(c.entryTextLimit)}
  const history=Array.from({length:100},()=>costly).concat([{type:'text',text:'small'}])
  assert(c.addEntry(history,large,500).some(e=>e.text==='small'),'clipboard keeps small entries beyond entries that do not fit')
  assert(c.parseHistory(JSON.stringify(history),500).some(e=>e.text==='small'),'clipboard load keeps small entries beyond entries that do not fit')
  assert(c.entryTextLimit*6<c.historyBudget,'clipboard one inline copy cannot consume the entire budget')
} finally {
  fs.rmSync(temp,{recursive:true,force:true})
}
JS
