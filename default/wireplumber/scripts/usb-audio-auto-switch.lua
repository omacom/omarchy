-- WirePlumber
--
-- SPDX-License-Identifier: MIT

-- Promote a newly connected USB audio device to the default sink/source.
--
-- WirePlumber keeps the last device the user selected as the configured
-- default and gives it a large priority bonus, so a USB headset (or a USB-C
-- DAC) plugged in later would otherwise stay silent until it was picked by
-- hand. Selecting it as soon as its node appears is what desktop environments
-- do, and is enough to move both playback and capture over to the headset.

log = Log.open_topic ("s-default-nodes")

-- WirePlumber also emits session-item-added while it discovers devices that
-- are already connected at startup. Switching on those would replace the
-- user's saved choice on every login or audio restart, so keep the hook
-- disarmed until the startup burst has gone quiet. Resetting on each event
-- lets slower enumerations finish before the hook is armed.
local settling = true
local settle_source = nil

local function arm_when_settled ()
  if settle_source then
    settle_source:destroy ()
  end
  settle_source = Core.timeout_add (3000, function ()
    settling = false
    settle_source = nil
  end)
end

arm_when_settled ()

local function defaultTypesFor (media_class)
  if media_class == "Audio/Source" then
    return { "audio.source" }
  elseif media_class == "Audio/Duplex" then
    return { "audio.sink", "audio.source" }
  end
  return { "audio.sink" }
end

local function isUsbAudio (props)
  if props ["device.bus"] == "usb" then
    return true
  end

  -- ALSA names USB devices alsa_output.usb-... / alsa_input.usb-...
  -- (Bluetooth's bluez_output.* and built-in pci-* devices are deliberately
  -- left alone.)
  local node_name = props ["node.name"]
  return node_name ~= nil and node_name:find ("%.usb%-", 1, false) ~= nil
end

SimpleEventHook {
  name = "usb-audio-auto-switch/select-default-node",
  interests = {
    EventInterest {
      Constraint { "event.type", "=", "session-item-added" },
      Constraint { "event.session-item.interface", "=", "linkable" },
      Constraint { "media.class", "c", "Audio/Sink", "Audio/Source", "Audio/Duplex" },
    },
  },
  execute = function (event)
    if settling then
      arm_when_settled ()
      return
    end

    local props = event:get_properties ()
    local node_name = props ["node.name"]

    if not node_name or not isUsbAudio (props) then
      return
    end

    local source = event:get_source ()
    local om = source:call ("get-object-manager", "metadata")
    local metadata = om:lookup { Constraint { "metadata.name", "=", "default" } }
    if metadata == nil then
      return
    end

    for _, node_type in ipairs (defaultTypesFor (props ["media.class"])) do
      local key = "default.configured." .. node_type
      metadata:set (0, key, "Spa:String:JSON",
          Json.Object { ["name"] = node_name }:to_string ())
      log:info ("auto-selected " .. node_name .. " for " .. key)
    end
  end
}:register ()
