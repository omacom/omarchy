import QtQuick
import Quickshell

ShellRoot {
  Helpers { id: helpers }

  function check(value, message) {
    if (!value) throw new Error(message)
  }

  Component.onCompleted: {
    try {
      var date = helpers.recentDateStrings()[6]
      var snapshots = [
        JSON.parse('{"deviceId":"a","providers":{"constructor":{"todayPrompts":2,"modelUsage":{"toString":{"inputTokens":3}}},"__proto__":{"totalPrompts":4}}}'),
        { deviceId: "b", providers: { alpha: { todayPrompts: 5, recentDays: [{ date: date, messageCount: 2 }] } } }
      ]
      var merged = helpers.aggregateSnapshots(snapshots)
      check(Object.keys(merged.providers).length === 3, "collision providers")
      check(merged.providers.constructor.todayPrompts === 2, "constructor count")
      check(merged.providers.__proto__.totalPrompts === 4, "prototype name count")
      check(merged.providers.constructor.modelUsage.toString.inputTokens === 3, "model usage count")
      check(merged.providers.alpha.recentDays[6].messageCount === 2, "recent day count")
      check(helpers.aggregateSnapshots([null, [], { providers: [] }, { providers: { bad: null, good: { todayPrompts: "3" } } }]).providers.good.todayPrompts === 3, "malformed shapes and valid count")
      helpers.agents = [{ record: { id: "constructor", todayPrompts: 1 } }]
      check(helpers.localSnapshot().providers.constructor.todayPrompts === 1, "local snapshot")
      console.log("RESULT pass")
    } catch (error) {
      console.log("RESULT fail " + error)
    }
    Quickshell.execDetached(["quickshell", "kill", "-p", Quickshell.env("OMARCHY_AGENTS_TEST_PATH")])
  }
}
