-- Omarchy replacement for WirePlumber's node/suspend-node.lua.
--
-- Behaves like the stock hook: an idle audio or video node is suspended after
-- "session.suspend-timeout-seconds" (default 5). The difference is that ALSA
-- capture sources are kept ready, never suspended, while any PipeWire client
-- that set the client property "session.keep-inputs-ready" to "true" is
-- connected. Waking a suspended microphone can take hundreds of milliseconds,
-- which clips the start of dictation. An idle source streams nothing, so no audio
-- reaches any client while it is kept ready. When the last such client
-- disconnects, idle sources suspend on their normal timeout again.
--
-- Based on node/suspend-node.lua, Copyright © 2021 Collabora Ltd.,
-- George Kiagiadakis <george.kiagiadakis@collabora.com>, MIT licensed.
--
-- SPDX-License-Identifier: MIT

log = Log.open_topic ("s-node")

timers = {}

keep_ready_clients = ObjectManager {
  Interest {
    type = "client",
    Constraint { "session.keep-inputs-ready", "=", "true", type = "pw" },
  }
}

capture_sources = ObjectManager {
  Interest {
    type = "node",
    Constraint { "media.class", "matches", "Audio/Source*", type = "pw" },
    Constraint { "device.api", "=", "alsa", type = "pw" },
  }
}

function keeping_inputs_ready ()
  return keep_ready_clients:get_n_objects () > 0
end

function is_capture_source (node)
  local props = node.properties
  return props ["device.api"] == "alsa" and
      (props ["media.class"] or ""):find ("^Audio/Source") ~= nil
end

function cancel_timer (node)
  local id = node ["bound-id"]
  if timers [id] then
    timers [id]:destroy ()
    timers [id] = nil
  end
end

function schedule_suspend (node)
  cancel_timer (node)

  if is_capture_source (node) and keeping_inputs_ready () then
    log:debug (node, "idle, kept ready for a client that asked for it")
    return
  end

  local timeout = tonumber (node.properties ["session.suspend-timeout-seconds"]) or 5
  if timeout == 0 then
    return
  end

  local id = node ["bound-id"]
  timers [id] = Core.timeout_add (timeout * 1000, function ()
    if (node:get_active_features () & Feature.Proxy.BOUND) ~= 0 then
      log:info (node, "was idle for a while; suspending ...")
      node:send_command ("Suspend")
    end
    timers [id] = nil
    return false
  end)
end

SimpleEventHook {
  name = "node/suspend-node",
  interests = {
    EventInterest {
      Constraint { "event.type", "=", "node-state-changed" },
      Constraint { "media.class", "matches", "Audio/*" },
    },
    EventInterest {
      Constraint { "event.type", "=", "node-state-changed" },
      Constraint { "media.class", "matches", "Video/*" },
    },
  },
  execute = function (event)
    local node = event:get_subject ()
    local new_state = event:get_properties () ["event.subject.new-state"]

    log:debug (node, "changed state to " .. new_state)

    if new_state == "idle" or new_state == "error" then
      schedule_suspend (node)
    else
      cancel_timer (node)
    end
  end
}:register ()

-- A source that went idle before the first keep-ready client connected still
-- has a suspend timer pending; cancel it.
keep_ready_clients:connect ("object-added", function (_, client)
  log:info ("keeping capture sources ready for " ..
      (client.properties ["application.name"] or "a client"))
  for node in capture_sources:iterate () do
    cancel_timer (node)
  end
end)

-- Sources left idle while kept ready get no further state change, so start
-- their normal timeout once nobody asks to keep them ready.
keep_ready_clients:connect ("object-removed", function (_, client)
  if keeping_inputs_ready () then
    return
  end
  log:info ("no client keeps capture sources ready any more")
  for node in capture_sources:iterate () do
    if node ["state"] == "idle" then
      schedule_suspend (node)
    end
  end
end)

keep_ready_clients:activate ()
capture_sources:activate ()
