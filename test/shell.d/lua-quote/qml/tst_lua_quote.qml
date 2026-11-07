import QtQuick
import QtTest
import "../../../../shell/Commons/Lua.js" as Lua

// A monitor name reaches the Lua expression the bar dispatches, so a quote, a
// backslash or a control character must stay inside the literal instead of
// closing it and becoming code.
TestCase {
  name: "LuaQuote"

  function test_plainConnectorName() {
    compare(Lua.quote("DP-1"), "\"DP-1\"")
  }

  function test_emptyName() {
    compare(Lua.quote(""), "\"\"")
  }

  function test_quoteAndBackslash() {
    compare(Lua.quote("DP-1\""), "\"DP-1\\\"\"")
    compare(Lua.quote("DP\\1"), "\"DP\\\\1\"")
  }

  function test_controlCharacters() {
    compare(Lua.quote("DP-1\nx"), "\"DP-1\\nx\"")
    compare(Lua.quote("DP-1\tx"), "\"DP-1\\tx\"")
    compare(Lua.quote("DP\u0001"), "\"DP\\001\"")
  }

  function test_expressionCannotLeaveTheLiteral() {
    compare(Lua.quote("\" }); os.execute(\"id\") --"),
            "\"\\\" }); os.execute(\\\"id\\\") --\"")
  }
}
