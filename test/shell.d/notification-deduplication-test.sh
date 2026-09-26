#!/bin/bash
source "$(dirname "$0")/base-test.sh"
run_node_test <<'JS'
const fs = require('fs'), vm = require('vm')
const logic = requireFromRoot('shell/plugins/notifications/NotificationLogic.js')
const qml = fs.readFileSync(path.join(root, 'shell/plugins/notifications/Service.qml'), 'utf8')
const model = {
 rows: [], get count() { return this.rows.length },
 get(i) { return this.rows[i] }, insert(i,v) { this.rows.splice(i,0,{...v}) },
 remove(i) { this.rows.splice(i,1) }, setProperty(i,k,v) { this.rows[i][k]=v }
}
const persisted = [], archived = []
const ctx = {NotificationLogic:logic, NotificationUrgency:{Normal:1}, popupModel:model,
 popupGroups:{}, liveRefs:{}, restoredPopups:{}, deduplicationWindowMs:-1,
 persistPopupFile(v) { persisted.push({...v}) }, archivePopupFileFor(v) { archived.push({...v}) },
 Date, console}
ctx.service=ctx
vm.createContext(ctx)
for (const name of ['groupIndex','popupRef','updateGroup','detachMember','insertGrouped','insertSingleton','refreshPopup','isRestoredRow','removePopup']) {
 const start=qml.indexOf('  function '+name+'('), end=qml.indexOf('\n  }',start)+4
 vm.runInContext(qml.slice(start,end),ctx)
}
function member(id, body='Hello',time=1000) {
 const n={id,appName:'Teams',summary:'Chat',body,urgency:1,tracked:true,
 dismiss(){this.tracked=false},expire(){this.tracked=false}}
 ctx.liveRefs[id]=n
 return logic.snapshotOf(n,time)
}
ctx.insertGrouped(member(1))
ctx.insertGrouped(member(2,'Hello',100000))
assertEqual(model.count,1,'default groups matching arrivals beyond two seconds')
assertEqual(model.get(0).duplicateCount,2,'counts distinct arrivals')
const writes=persisted.length
ctx.refreshPopup(ctx.liveRefs[2],2,100000)
assertEqual(persisted.length,writes,'unchanged updates neither increment nor rewrite')
ctx.liveRefs[2].body='Updated'
ctx.refreshPopup(ctx.liveRefs[2],2,100000)
assertEqual(model.count,2,'an updated duplicate splits into its own popup')
assertEqual(model.get(1).duplicateCount,1,'old group count decreases after split')
assertEqual(model.get(0).body,'Updated','split popup shows updated content')
ctx.insertGrouped(member(3,'Hello',200000))
ctx.liveRefs[1].body='First changed'
ctx.refreshPopup(ctx.liveRefs[1],1,1000)
assertEqual(model.count,3,'updating the original member also splits correctly')
assertEqual(ctx.popupRef(model.get(ctx.groupIndex(3))),ctx.liveRefs[3],'remaining member supplies the original group action')
ctx.insertGrouped(member(4,'Hello',300000))
const group=ctx.groupIndex(3)
ctx.removePopup(group,'dismiss')
assert(!ctx.liveRefs[3].tracked && !ctx.liveRefs[4].tracked,'dismissing a group closes every member')
ctx.deduplicationWindowMs=2000
ctx.insertGrouped(member(5,'Timed',1000));ctx.insertGrouped(member(6,'Timed',4000))
assert(ctx.groupIndex(5)!==ctx.groupIndex(6),'configured window keeps later messages separate')
ctx.deduplicationWindowMs=0
ctx.insertGrouped(member(7,'Disabled'));ctx.insertGrouped(member(8,'Disabled'))
assert(ctx.groupIndex(7)!==ctx.groupIndex(8),'zero disables grouping')
ctx.deduplicationWindowMs=-1
ctx.insertGrouped(member(11,'Closing'));ctx.insertGrouped(member(12,'Closing'))
delete ctx.liveRefs[11];ctx.detachMember(11)
assertEqual(model.get(ctx.groupIndex(12)).duplicateCount,1,'sender closure decreases the count')
assertEqual(ctx.popupRef(model.get(ctx.groupIndex(12))),ctx.liveRefs[12],'sender closure promotes the remaining live action')
ctx.removePopup(ctx.groupIndex(12),'expire')
assert(!ctx.liveRefs[12].tracked,'expiry releases the remaining member')
const restored=logic.historyEntry(member(13,'History'),1)
ctx.restoredPopups[logic.popupFileName(restored)]=true
model.insert(0,restored)
assertEqual(ctx.popupRef(restored),null,'restored ID collision cannot invoke a fresh object')
ctx.insertGrouped(member(14,'History'))
assertEqual(model.rows.filter(r=>r.body==='History').length,2,'restored popups never absorb new arrivals')
// A changed member must not inherit an older matching popup's countdown.
const oldTime=Date.now()-8000
ctx.insertGrouped(member(20,'Older match',oldTime))
ctx.insertGrouped(member(21,'New group',oldTime+7000))
ctx.insertGrouped(member(22,'New group',oldTime+7001))
const updateTime=Date.now()
ctx.liveRefs[22].body='Older match'
ctx.refreshPopup(ctx.liveRefs[22],22,oldTime+7001)
assert(ctx.groupIndex(20)!==ctx.groupIndex(22),'changed member remains separate from older matching popup')
const split=model.get(ctx.groupIndex(22))
assert(split.timestamp>=updateTime,'split receives a fresh lifetime timestamp')
assertEqual(split.duplicateCount,1,'split starts as a singleton')
assertEqual(model.get(ctx.groupIndex(20)).timestamp,oldTime,'older popup keeps its existing countdown')
ctx.removePopup(ctx.groupIndex(20),'expire')
assert(!ctx.liveRefs[20].tracked,'older matching popup expires')
assert(ctx.liveRefs[22].tracked&&ctx.groupIndex(22)>=0,'split survives older matching popup expiry')
assert(ctx.liveRefs[21].tracked&&ctx.groupIndex(21)>=0,'original group survives independently')
ctx.removePopup(ctx.groupIndex(22),'expire')
assert(!ctx.liveRefs[22].tracked,'split expires independently')
const a=member(9),b=member(10)
for (const changed of [{app:'Other'},{desktopEntry:'other'},{summary:'Different'},{body:'Different'},{urgency:2},{execArgv:'["other"]'},{originalId:9}])
 assert(!logic.duplicateMatches(a,{...b,...changed},-1),'different identity/content and replacement IDs do not group')
assertEqual(logic.countedSummary('Chat',3),'Chat (3)','title shows grouped count')
assertEqual(logic.historyEntry({...a,duplicateCount:3},1).duplicateCount,3,'count survives history serialization')
assertEqual(logic.deduplicationWindow(undefined),-1,'omitted setting defaults to until dismissed')
assertEqual(logic.deduplicationWindow('bad'),-1,'invalid setting falls back safely')
JS
