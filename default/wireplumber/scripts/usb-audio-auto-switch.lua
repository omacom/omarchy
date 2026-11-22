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

local function defaultTypesFor (media_class)
  if media_class == "Audio/Source" then
    return { "audio.source" }
  elseif media_class == "Audio/Duplex" then
    return { "audio.sink", "audio.source" }
  end
  return { "audio.sink" }
end

local function isUsbNode (node_name)
  -- ALSA names USB devices alsa_output.usb-... / alsa_input.usb-...
  -- (Bluetooth's bluez_output.* and built-in pci-* devices are deliberately
  -- left alone.)
  return node_name:find ("%.usb%-", 1, false) ~= nil
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
    local props = event:get_properties ()
    local node_name = props ["node.name"]

    if not node_name or not isUsbNode (node_name) then
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
