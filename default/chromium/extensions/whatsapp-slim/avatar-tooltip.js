// Shows the chat/contact name in a floating tooltip when hovering an avatar in
// the collapsed (rail) layout. Only active when the chat list is narrowed to the
// avatar rail (window <= 1100px), matching whatsapp.css's collapse breakpoint.
(function () {
  const RAIL_QUERY = "(max-width: 1100px)";
  let railMode = window.matchMedia(RAIL_QUERY).matches;
  window.matchMedia(RAIL_QUERY).addEventListener("change", (e) => {
    railMode = e.matches;
    hide();
  });

  const tip = document.createElement("div");
  tip.id = "wa-slim-tooltip";
  Object.assign(tip.style, {
    position: "fixed",
    zIndex: "2147483647",
    display: "none",
    maxWidth: "240px",
    padding: "6px 10px",
    borderRadius: "8px",
    background: "rgba(32,44,51,0.96)",
    color: "#e9edef",
    font: "500 13px/1.3 'Helvetica Neue',Arial,sans-serif",
    boxShadow: "0 2px 12px rgba(0,0,0,0.4)",
    pointerEvents: "none",
    whiteSpace: "nowrap",
    overflow: "hidden",
    textOverflow: "ellipsis",
  });
  document.documentElement.appendChild(tip);

  function getName(cell) {
    // The avatar image's title is the contact/group name. An unread row can
    // instead surface an indicator image (muted/pinned/etc.), so only trust the
    // title when it reads like a name rather than a count or status word.
    const img = cell.querySelector("img[title]");
    if (img) {
      const t = img.getAttribute("title").trim();
      if (t && !/^\d+$/.test(t) && !/unread|message|muted|pinned|archived/i.test(t)) {
        return t;
      }
    }
    // Fallback: first text span that isn't the unread badge or a bare count,
    // either of which would otherwise masquerade as the name in the tooltip.
    const spans = cell.querySelectorAll("span");
    for (const s of spans) {
      if (s.matches('[aria-label*="unread"]')) continue;
      const x = s.textContent.trim();
      if (x && !/^\d+$/.test(x)) return x;
    }
    return "";
  }

  function tag(cell) {
    if (cell.dataset.waName !== undefined) return;
    cell.dataset.waName = "";
    cell.addEventListener("mouseenter", () => {
      if (railMode) show(cell);
    });
    cell.addEventListener("mouseleave", hide);
  }

  function show(cell) {
    const name = getName(cell);
    if (!name) return;
    tip.textContent = name;
    tip.style.display = "block";
    const r = cell.getBoundingClientRect();
    // Measure the clamped tooltip and keep it within the viewport so a long
    // name or a row near the bottom edge doesn't run off-screen in the narrow
    // windows this rail mode targets.
    const w = tip.offsetWidth;
    const h = tip.offsetHeight;
    tip.style.left = Math.min(r.right + 8, window.innerWidth - w - 8) + "px";
    tip.style.top = Math.min(Math.max(8, r.top), window.innerHeight - h - 8) + "px";
  }

  function hide() {
    tip.style.display = "none";
  }

  const root = document.querySelector("#pane-side") || document.body;
  const io = new MutationObserver((mutations) => {
    for (const mutation of mutations) {
      for (const node of mutation.addedNodes) {
        // Tag the node directly when it is a chat row, otherwise descend into
        // any chat rows nested inside the added subtree. Only newly added
        // nodes are visited, so this stays cheap as previews, timestamps, and
        // unread state churn during normal messaging.
        if (node.nodeType === 1) {
          if (node.matches('[data-testid="cell-frame-container"]')) {
            tag(node);
          } else {
            node.querySelectorAll('[data-testid="cell-frame-container"]').forEach(tag);
          }
        }
      }
    }
  });
  io.observe(root, { childList: true, subtree: true });
  root.querySelectorAll('[data-testid="cell-frame-container"]').forEach(tag);
})();
