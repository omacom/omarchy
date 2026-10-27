pragma Singleton

import QtQuick

QtObject {
  enum State { Charging = 1, Discharging = 2, FullyCharged = 3, PendingCharge = 4 }
}
