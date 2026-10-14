#!/bin/bash
set -euo pipefail
source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"
run_node_test <<'JS'
const fs = require('fs'), vm = require('vm')
const service = fs.readFileSync(path.join(root,'shell/services/BackgroundIntro.qml'),'utf8')
const shell = fs.readFileSync(path.join(root,'shell/shell.qml'),'utf8')
const colors = []
const intro = vm.createContext({themeToken:'old',transitionToken:'old',themeColors:'old colors',themeShell:'old shell',themeBackground:'/old.png',cover:false,startupPending:false,framePoll:{stop(){}},themeFallback:{stop(){}},themeFade:{stop(){},restart(){}},Commons:{Color:{loadColors(v){colors.push(v)},loadShell(){}}},Util:{decodeBase64(v){return v}},Style:{scheduleRefresh(){}}})
for (const name of ['cancelTheme','finishTheme','revealTheme']) vm.runInContext(service.match(new RegExp('function '+name+'\\([^]*?\\n  }'))[0],intro)
const method = shell.match(/function cancelThemeIntro\(\): void \{([^]*?)\n    }/)[1]
vm.runInNewContext(method,{shell:{bootIntro:intro}})
intro.finishTheme('old');intro.revealTheme()
assertEqual(colors.length,0,'superseded intro completion and fallback cannot reapply old colors')
assertEqual(intro.themeToken,'','cancellation-only IPC retires the previous intro token')
JS
