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
--
-- Devices that were already connected when WirePlumber started must not
-- replace the user's saved choice, though. udev records when it initialized
-- each device in device.plugged.usec, and this script notes the monotonic
-- time it was loaded. A device whose udev timestamp predates the script was
-- part of the startup enumeration and is left alone; a device plugged in
-- later has a newer timestamp and is selected. This distinguishes startup
-- devices from real hotplug events without a settling timer, so a device
-- connected right after startup is still picked up.

log = Log.open_topic ("s-default-nodes")

local started_usec = GLib.get_monotonic_time ()

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

-- Returns true if the device behind this node was already known to udev when
-- WirePlumber started, in which case it is part of the startup enumeration
-- and the saved default must win. Nodes without a device, or whose udev
-- timestamp is missing, are treated the same way, to be safe.
local function wasConnectedAtStartup (source, props)
  local device_id = props ["device.id"]
  if not device_id then
    return true
  end

  local om = source:call ("get-object-manager", "device")
  local device = om:lookup {
    Constraint { "bound-id", "=", device_id, type = "gobject" },
  }
  local plugged_usec = device and tonumber (device.properties ["device.plugged.usec"])

  return plugged_usec == nil or plugged_usec < started_usec
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

    if not node_name or not isUsbAudio (props) then
      return
    end

    local source = event:get_source ()
    if wasConnectedAtStartup (source, props) then
      log:info ("keeping saved default for startup device " .. node_name)
      return
    end

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
