pragma Singleton

import QtQuick
import "CursorPolicy.js" as Policy

// Shared pointer-to-cursor handoff for panel rows and controls.
//
// A pointer enter claims the panel's single keyboard cursor; a pointer leave
// releases it when the item still owns it. Moving between rows, or from a row
// to an inline action button, hands the cursor over instead of clearing the
// new target. See CursorPolicy.js for the ownership rule.
QtObject {
  function applyHover(on, owns, claim, release) {
    Policy.applyHover(on, owns, claim, release)
  }
}
