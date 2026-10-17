import net from "node:net"

export default async () => {
  const path = process.env.SCREENSAVER_CONTROL_SOCKET
  if (!path) return {}
  const sessions = new Map()
  const pending = new Map()
  let connection
  const state = () => pending.size ? "waiting" : [...sessions.values()].some(value => value === "busy" || value === "retry") ? "busy" : "idle"
  const notify = () => {
    if (!connection || connection.destroyed) {
      connection = net.createConnection(path)
      connection.on("error", () => {})
      connection.unref()
    }
    connection.write(JSON.stringify({ pid: process.pid, state: state() }) + "\n")
  }
  const heartbeat = setInterval(notify, 2000)
  heartbeat.unref()
  notify()
  return {
    event: async ({ event }) => {
      const data = event.properties || {}
      if (event.type === "session.status") sessions.set(data.sessionID, data.status?.type || "idle")
      if (["session.idle", "session.error", "session.deleted"].includes(event.type)) {
        const id = data.sessionID || data.info?.id
        sessions.delete(id)
        for (const [request, session] of pending) if (session === id) pending.delete(request)
      }
      if (["question.asked", "permission.asked"].includes(event.type)) pending.set(data.id, data.sessionID)
      if (["question.replied", "question.rejected", "permission.replied"].includes(event.type)) pending.delete(data.requestID)
      notify()
    },
  }
}
