-- Hold audio outputs while Omarchy has the displays blanked.
--
-- A blanked display stops presenting HDMI/DP audio, which looks exactly like
-- an unplugged monitor from here: the port goes unavailable, the card profile
-- is re-selected and the default sink moves to whatever is left (usually the
-- speakers). omarchy-brightness-display sets omarchy.displays-blanked around
-- the blanking, and while it is set the active profile of each ALSA card and
-- the current default nodes are kept as they are.

cutils = require ("common-utils")
log = Log.open_topic ("s-omarchy")

-- The setting is cleared as the displays are told to wake, before their audio
-- is back. Keep holding this long so the wake itself doesn't cause the switch.
local RELEASE_DELAY_MS = 10000

local holding = false
local release_source = nil
-- default.configured.* as the hold began; a change since is the user's own pick
local configured_at_hold = nil

local function default_metadata ()
  local source = Plugin.find ("standard-event-source")
  local metadata_om = source and source:call ("get-object-manager", "metadata")
  return metadata_om and metadata_om:lookup { Constraint { "metadata.name", "=", "default" } }
end

local function configured_default (metadata, def_node_type)
  local obj = metadata:find (0, "default.configured." .. def_node_type)
  return obj and Json.Raw (obj):parse ().name or false
end

local function snapshot_configured ()
  local metadata = default_metadata ()
  if not metadata then
    return nil
  end

  local configured = {}
  for _, def_node_type in ipairs { "audio.sink", "audio.source", "video.source" } do
    configured [def_node_type] = configured_default (metadata, def_node_type)
  end
  return configured
end

local function reevaluate ()
  local source = Plugin.find ("standard-event-source")
  local device_om = source:call ("get-object-manager", "device")
  -- only ALSA cards were held; a Bluetooth headset in a call must keep its profile
  for device in device_om:iterate { Constraint { "device.api", "=", "alsa" } } do
    source:call ("push-event", "select-profile", device, nil)
  end
  source:call ("schedule-rescan", "default-nodes")
end

local function update ()
  if Settings.get_boolean ("omarchy.displays-blanked") then
    if release_source then
      release_source:destroy ()
      release_source = nil
    end
    holding = true
    configured_at_hold = snapshot_configured ()
  elseif holding and not release_source then
    release_source = Core.timeout_add (RELEASE_DELAY_MS, function ()
      release_source = nil
      holding = false
      -- catch up with anything that really was unplugged in the meantime
      reevaluate ()
      return false
    end)
  end
end

SimpleEventHook {
  name = "omarchy/hold-profile-while-blanked",
  before = { "device/find-calling-profile", "device/find-stored-profile",
             "device/find-preferred-profile", "device/find-best-profile" },
  interests = {
    EventInterest {
      Constraint { "event.type", "=", "select-profile" },
    },
  },
  execute = function (event)
    if not holding then
      return
    end

    local device = event:get_subject ()
    if device.properties ["device.api"] ~= "alsa" then
      return
    end

    for p in device:iterate_params ("Profile") do
      local active = cutils.parseParam (p, "Profile")
      if active and active.name ~= "off" then
        log:info (device, string.format ("Displays blanked, holding profile '%s' on '%s'",
            active.name, device.properties ["device.name"] or ""))
        event:set_data ("selected-profile", active)
      end
    end
  end
}:register ()

SimpleEventHook {
  name = "omarchy/hold-default-node-while-blanked",
  after = { "default-nodes/find-selected-default-node",
            "default-nodes/find-stored-default-node",
            "default-nodes/find-best-default-node" },
  before = "default-nodes/apply-default-node",
  interests = {
    EventInterest {
      Constraint { "event.type", "=", "select-default-node" },
    },
  },
  execute = function (event)
    if not holding then
      return
    end

    local source = event:get_source ()
    local def_node_type = event:get_properties () ["default-node.type"]
    local metadata_om = source:call ("get-object-manager", "metadata")
    local metadata = metadata_om:lookup { Constraint { "metadata.name", "=", "default" } }
    local obj = metadata and metadata:find (0, "default." .. def_node_type)
    if not obj then
      return
    end

    -- a device picked during the hold applies now, not when the hold ends
    if configured_at_hold and
        configured_default (metadata, def_node_type) ~= configured_at_hold [def_node_type] then
      -- forgotten, so picking the original device back applies too
      configured_at_hold [def_node_type] = nil
      return
    end

    local current = Json.Raw (obj):parse ().name
    if not current or current == event:get_data ("selected-node") then
      return
    end

    -- only hold a node that still exists; a removed one must fall back
    local si_om = source:call ("get-object-manager", "session-item")
    local si = si_om:lookup {
      type = "SiLinkable",
      Constraint { "node.name", "=", current },
    }
    if si then
      log:info (string.format ("Displays blanked, holding default %s '%s'",
          def_node_type, current))
      event:set_data ("selected-node", current)
    end
  end
}:register ()

Settings.subscribe ("omarchy.displays-blanked", update)
update ()
