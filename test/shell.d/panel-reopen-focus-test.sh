#!/bin/bash
set -euo pipefail
source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"
node - "$ROOT/test/acceptance.d/fixtures/panel-reopen/PanelReopen.qml" <<'JS'
const fs = require('fs'), vm = require('vm'), assert = require('assert');
const source = fs.readFileSync(process.argv[2], 'utf8');
function fixture() {
  let sends = 0;
  const root = {phase:'waiting-for-escape', escapeDelay:1, escapePending:false,
    activationLost:false, activationGained:false, observedWindowActive:true,
    abort(error) { this.error=error; this.phase='failed'; this.escapePending=false; }};
  const panel={focusPrimed:false};
  const escapeProcess={set running(v) { if(v) sends++; }};
  const scope=vm.createContext({root,panel,escapeProcess});
  for(const name of ['sendEscapeWhenReady','observeWindowActivation']) {
    const match=source.match(new RegExp('  function '+name+'\\([^)]*\\) \\{([\\s\\S]*?)\\n  \\}'));
    if(match) root[name]=vm.runInContext('(function() {'+match[1]+'\n})',scope);
  }
  const timer=source.match(/id: sendEscape\n([\s\S]*?)\n  \}/)[1];
  const handler=timer.match(/onTriggered: (.*)/)[1];
  return {root,panel,get sends(){return sends},timer(){vm.runInContext(handler,scope)},
    active(value){root.observedWindowActive=value;if(root.observeWindowActivation)root.observeWindowActivation();}};
}
{
 const f=fixture(); f.timer();
 assert.equal(f.sends,0,'stale activity from the previous opening must not send Escape');
 f.active(false); assert.equal(f.sends,0);
 f.active(true); assert.equal(f.sends,1,'reacquisition releases the pending single Escape');
 f.active(false);f.active(true);assert.equal(f.sends,1,'later focus events cannot send a second Escape');
 console.log('ok - input waits for a fresh activation handoff and sends once');
}
{
 const f=fixture();f.timer();f.active(false);f.panel.focusPrimed=true;f.active(true);
 assert.equal(f.sends,0);assert.equal(f.root.phase,'failed');
 assert.match(f.root.error,/prime/);
 console.log('ok - ownership acquired after the early prime window fails without input');
}
{
 const f=fixture();f.root.escapeDelay=110;f.active(false);f.active(true);f.panel.focusPrimed=true;
 assert.equal(f.sends,0);f.timer();assert.equal(f.sends,1);
 console.log('ok - late case retains its scheduled input after activation');
}
{
 const f=fixture();f.timer();f.active(false);f.root.phase='idle';f.root.escapePending=false;f.active(true);
 assert.equal(f.sends,0);
 console.log('ok - cancellation prevents delayed input');
}
JS
