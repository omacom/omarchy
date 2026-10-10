pragma Singleton
import QtQml

QtObject {
  function env(name) { return name === "OMARCHY_PATH" ? "/fixture/omarchy" : "" }
}
