# Desktop dashboard API

Browser entry is `/` on the configured private `desktops.example.com` service. Same-origin requests use the configured gateway access boundary. No browser token entry. No frontend secrets. Backend ownership and transcript endpoints under `/hypr-desktop/viewer/agents` still require bearer authentication.

## Fleet

`GET /api/desktops` → `{hosts:[{id,online}],desktops:[{host,desktop,generation,owner,held,ready,idleMs,title,icon,agentStatus,agentId,chatAvailable}]}`.

`agentId` identifies a verified conversation across machines; null means unverified. Never group by title. `title` is the session name; `icon` is a data URI or empty. Status examples: Working, Waiting for you, Finished, Stopped, Needs attention, Ready, Unknown. Stable desktop key is host + desktop + generation. A reused desktop number is a different session. Discovery does not create streams.

Poll every 3–5 seconds while visible. Update existing rows without replacing focused buttons. When a host goes offline, retain its previously known desktops as reconnecting; remove them only after a successful online snapshot confirms closure. No active desktops is an empty state, not a connection error.

## Streams

`GET /api/desktops/:host/:desktop/connect?generation=...` → `{generation,password}`. Then noVNC RFB connects to same-origin `ws(s)://HOST/view/:host/:desktop?generation=...&profile=preview|full`. `/novnc/core/rfb.js` is available. Preview/full select separate lower/higher quality WayVNC encoders. Watch by default; human input requires explicit Take control. Escape returns to watch mode. Disconnect on pagehide/background; never release agent leases from the viewer. Reconnect must use the exact generation. Retain existing mobile typing, fit/actual size, and video fullscreen support from old app.js.

## Built-in Markdown chat

`POST /api/chats` with JSON `{host,desktop,generation}` → `{id,title,agentId}`. Only a current verified desktop can bind a chat; unsupported ownership returns 409, ended desktop returns 404. Cache this binding by agent ID; it stays with the original conversation after a desktop closes or its number is reused. It is an opaque signed capability, not a desktop number. Browser JSON POST requests must carry the same Origin; ordinary same-origin fetch does this automatically.

`GET /api/chats/:id` → recent turn. `GET /api/chats/:id?before=CURSOR` → eight older turns.

Response follows the existing native app's T3 paging contract: `{thread:{id,title,messages:[{id,role,text,createdAt,updatedAt,streaming}],...},page:{beforeCursor,hasMore},snapshotSequence,...}`. The native implementation in `../app/web/chat.js` is the reference for paging, gap filling, chronological merge, viewport anchoring, bounded rendered Markdown and cache, drafts, and idempotent retry. Keep full history available on demand; do not fetch/render entire long threads at startup. No full-thread search.

`POST /api/chats/:id/messages` JSON `{text,commandId,messageId}` → T3 dispatch result. Use crypto.randomUUID() for IDs on a new send. Retrying an unconfirmed send MUST keep text and both IDs unchanged. Clear the draft only after success. 100,000 character limit; preserve draft and retry state on errors. Backend preserves the original model/runtime and sends to the original thread. Never send real test messages to an unrelated agent.

Markdown vendor modules: `/vendor/marked.js` exports `marked`; `/vendor/purify.js` default export DOMPurify. Use a same-origin module worker for parsing, sanitize before inserting HTML, bounded rendered DOM/cache. CSP allows self scripts/workers and self/data images, no inline scripts or remote assets. Errors use `{error:string}` with non-2xx status.
