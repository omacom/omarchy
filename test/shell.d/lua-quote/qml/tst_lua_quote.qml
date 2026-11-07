import QtQuick
import QtTest
import "../../../../shell/Commons"

// A monitor name reaches the Lua expression the bar dispatches, so a quote, a
// backslash or a control character must stay inside the literal instead of
// closing it and becoming code.
TestCase {
  name: "LuaQuote"

  function test_plainConnectorName() {
    compare(Util.luaQuote("DP-1"), "\"DP-1\"")
  }

  function test_emptyName() {
    compare(Util.luaQuote(""), "\"\"")
  }

  function test_quoteAndBackslash() {
    compare(Util.luaQuote("DP-1\""), "\"DP-1\\\"\"")
    compare(Util.luaQuote("DP\\1"), "\"DP\\\\1\"")
  }

  function test_controlCharacters() {
    compare(Util.luaQuote("DP-1\nx"), "\"DP-1\\nx\"")
    compare(Util.luaQuote("DP-1\tx"), "\"DP-1\\tx\"")
    compare(Util.luaQuote("DP\u0001"), "\"DP\\001\"")
  }

  function test_expressionCannotLeaveTheLiteral() {
    compare(Util.luaQuote("\" }); os.execute(\"id\") --"),
            "\"\\\" }); os.execute(\\\"id\\\") --\"")
  }
}
