"use strict";
const steps = [
  ["welcome", "Welcome"],
  ["icloud", "Your iCloud"],
  ["email", "Your email"],
  ["files", "Your files"],
  ["desktop", "Feel at home"],
  ["apps", "Everyday apps"],
  ["ready", "Ready to go"],
];
const labels = {
  drive: "I can access my iCloud Drive",
  photos: "I can access my iCloud Photos",
  email: "I’ve sent and received a test email",
  "local-files": "I’ve copied my important local files",
  bookmarks: "My browser bookmarks are here",
  passwords: "I can access my passwords",
  desktop: "I’ve tried the desktop shortcuts",
  backup: "I have a backup plan",
};
let sessionToken = location.hash.slice(1);
if (sessionToken && !steps.some(([id]) => id === sessionToken))
  sessionStorage.setItem("wizard-token", sessionToken);
else sessionToken = sessionStorage.getItem("wizard-token") || "";
history.replaceState(null, "", location.pathname);
let snapshot,
  state,
  working = false,
  toastTimer;
const content = document.querySelector("#content");
const escapeHTML = (value) =>
  String(value).replace(
    /[&<>"']/g,
    (c) =>
      ({ "&": "&amp;", "<": "&lt;", ">": "&gt;", '"': "&quot;", "'": "&#39;" })[
        c
      ],
  );
const external = (url, label) =>
  `<a href="${url}" target="_blank" rel="noreferrer">${label} ↗</a>`;
const heading = (n, title, intro) =>
  `<p class="eyebrow">${n}</p><h1>${title}</h1><p class="intro">${intro}</p>`;
const available = (action) =>
  snapshot.capabilities[action]
    ? ""
    : ' disabled title="Available when running on an Omarchy desktop"';
const actionButton = (action, label, style = "secondary") =>
  `<button class="${style}" data-action="${action}"${available(action)}>${label}</button>`;
function notify(message, error = false) {
  const toast = document.querySelector("#toast");
  toast.textContent = message;
  toast.className = `visible${error ? " error" : ""}`;
  clearTimeout(toastTimer);
  toastTimer = setTimeout(
    () => {
      toast.className = "";
    },
    error ? 10000 : 5500,
  );
}
async function api(path, data) {
  const response = await fetch(`/api/${path}`, {
    method: data === undefined ? "GET" : "POST",
    headers: {
      "X-Wizard-Token": sessionToken,
      ...(data === undefined ? {} : { "Content-Type": "application/json" }),
    },
    ...(data === undefined ? {} : { body: JSON.stringify(data) }),
  });
  const result = await response.json();
  if (!response.ok)
    throw new Error(result.error || "Something went wrong. Please try again.");
  return result;
}
async function save(next) {
  document.querySelector("#save-status").textContent = "Saving progress…";
  try {
    await api("state", next);
    state = next;
    document.querySelector("#save-status").textContent =
      "Progress saved on this device";
  } catch (error) {
    document.querySelector("#save-status").textContent =
      "Progress could not be saved";
    throw error;
  }
}
function checklist(keys) {
  return `<div class="checklist">${keys.map((key) => `<label class="check"><input type="checkbox" data-task="${key}" ${state.tasks.includes(key) ? "checked" : ""}><span>${labels[key]}${key === "backup" ? "<small>Keep a separate, verified copy of your important files.</small>" : ""}</span></label>`).join("")}</div>`;
}
function serviceCard(id, title, symbol, description) {
  const installed = snapshot.installed.includes(id);
  return `<article class="service"><div class="service-top"><span class="icon" aria-hidden="true">${symbol}</span><span class="badge">${installed ? "SHORTCUT ADDED" : "WEB APP"}</span></div><h2>${title}</h2><p>${description}</p><div class="actions"><button class="primary" data-action="open" data-service="${id}"${available("webapps")}>Open ${title.replace("iCloud ", "")} ↗</button><button class="text-button" data-action="${installed ? "remove" : "install"}" data-service="${id}"${available("webapps")}>${installed ? "Remove shortcut" : "+ Add to launcher"}</button></div></article>`;
}
const pages = {
  welcome:
    () => `${heading("A FRESH START. A FAMILIAR FEEL.", "New system.<br><em>Same you.</em>", "Bring the things you love from your Mac. We’ll help you find your files, reconnect with iCloud, and settle into Omarchy — one small step at a time.")}
    <div class="hero"><div class="hero-copy"><span class="tiny">LESS FRICTION. MORE FLOW.</span><h2>A space to make your own.</h2><p>A beautiful, keyboard-first desktop.<br>Ready for your next chapter.</p><div class="pill-line"><span>LINUX</span><span class="mini-dot"></span><span>HYPRLAND</span><span class="mini-dot"></span><span>YOU</span></div></div><div class="desktop-art" aria-hidden="true"><div class="art-bar"><span>● &nbsp; 1 &nbsp; 2 &nbsp; 3</span><span>omarchy &nbsp; ◇</span></div><div class="art-windows"><div class="art-terminal">~ ❯ hello, omarchy<br><br><span>A fresh start.<br>A little curiosity.<br>Endless possibilities.</span><br><br>~ ❯ ▋</div><div class="art-right"><div class="art-block">⌘ → ◇</div><div class="art-block">make it yours.</div></div></div></div></div>
    <div class="section-label">LET’S BRING YOU HOME <span>AT YOUR OWN PACE</span></div><div class="cards"><article class="card"><span class="icon" aria-hidden="true">☁</span><h3>Your iCloud, close by</h3><p>Drive, Photos, and the essentials. Still part of your everyday.</p></article><article class="card"><span class="icon" aria-hidden="true">⌘</span><h3>A few new shortcuts</h3><p>Keep your muscle memory. Learn a handful of new moves.</p></article><article class="card"><span class="icon" aria-hidden="true">⌂</span><h3>Your kind of setup</h3><p>Bring your files and find the apps that feel like home.</p></article></div><p class="note"><span class="note-icon">◈</span>Every step is optional. Your progress stays on this device, so you can pick up where you left off.</p><p class="joke">Regrets? We’ve left room for those. Right next to your old dongles.</p>`,
  icloud:
    () => `${heading("01 / KEEP WHAT CONNECTS YOU", "Your cloud.<br><em>Still right here.</em>", "Use your Apple Account directly on iCloud.com. Add your favorite services to the app launcher so they’re always a shortcut away.")}
    <div class="service-grid">${serviceCard("drive", "iCloud Drive", "☁", "Browse, upload, and download your documents in Apple’s web app.")}${serviceCard("photos", "iCloud Photos", "✿", "See your library, upload new memories, and download photos from the web.")}</div>
    <div class="callout"><strong>A web app, with an honest label.</strong> These shortcuts open iCloud in a browser window. They don’t mount a folder or sync files in the background. Sign in and complete two-factor authentication only on Apple’s site; this wizard never sees your password.</div>
    ${checklist(["drive", "photos"])}
    <details class="detail"><summary>Using Advanced Data Protection?</summary><p>Keep it enabled. If web access is off, enable “Access iCloud Data on the Web” in your iCloud settings on a trusted Apple device, then approve access when Apple asks. This temporarily gives Apple access to the keys needed to display that data on the web. ${external("https://support.apple.com/en-us/102651", "Read Apple’s explanation")}.</p></details>
    <details class="detail"><summary>Want local copies of your photos or documents?</summary><p>The next step covers downloading files and exporting original photos from your Mac. Automated downloads with community tools such as ${external("https://github.com/icloud-photos-downloader/icloud_photos_downloader", "icloudpd")} are a separate, advanced setup. They can require renewed authentication and may not support your account’s protection settings. This wizard does not install them or change your Apple security settings.</p></details>`,
  email:
    () => `${heading("02 / YOU’VE STILL GOT MAIL", "New desktop.<br><em>Same inbox.</em>", "Keep your address, your messages, and your contacts. Start with webmail, or connect a desktop mail client for an inbox that lives here.")}
    <div class="service-grid">${serviceCard("mail", "iCloud Mail", "✉", "Read and send mail on iCloud.com. Sign in with Apple, then send yourself a quick test message.")}<article class="service"><div class="service-top"><span class="icon" aria-hidden="true">▣</span><span class="badge">DESKTOP CLIENT</span></div><h2>Thunderbird</h2><p>${snapshot.capabilities["email-client"] ? "Thunderbird is installed. Open it and add your existing email account to get started." : "Prefer a desktop inbox? Install Thunderbird through Omarchy’s Install menu, then reopen this wizard."}</p><div class="actions">${actionButton("email-client", "Open Thunderbird ↗", "primary")}${external("https://www.thunderbird.net/", "About Thunderbird")}</div></article></div>
    <details class="detail" open><summary>Connect iCloud Mail to a desktop client</summary><ol><li>At ${external("https://account.apple.com/", "your Apple Account")}, choose Sign-In and Security → App-Specific Passwords. Create one for your mail client. Two-factor authentication must be on.</li><li>Add your iCloud email account in the client. Enter the app-specific password there, never in this wizard.</li><li>Use the settings below if automatic setup needs a hand. Send and receive a test message before marking email complete.</li></ol><div class="table-wrap"><table><caption>iCloud Mail connection settings</caption><thead><tr><th>Direction</th><th>Server</th><th>Port / encryption</th></tr></thead><tbody><tr><td>Incoming · IMAP</td><td><code>imap.mail.me.com</code></td><td>993 · SSL/TLS</td></tr><tr><td>Outgoing · SMTP</td><td><code>smtp.mail.me.com</code></td><td>587 · STARTTLS</td></tr></tbody></table></div><p>Incoming username: usually the part before @; try the full iCloud address if needed. Outgoing username: your full iCloud address, with authentication enabled. Both use the app-specific password. ${external("https://support.apple.com/en-us/102525", "Apple’s server settings")} · ${external("https://support.apple.com/en-us/102654", "App-specific password help")}.</p></details>
    <details class="detail"><summary>Gmail, Outlook, work email, or another provider?</summary><p>You can keep using ${external("https://mail.google.com/", "Gmail")} or ${external("https://outlook.live.com/mail/", "Outlook")} in your browser. In a desktop client, add your existing account and use the provider’s sign-in flow where supported. Work accounts may require your organization’s approved app or administrator setup.</p><p>Mail stored only under “On My Mac” won’t appear through IMAP. Keep the Mac and export those local mailboxes before retiring it. Verify the import in your chosen client.</p></details>
    <div class="callout"><strong>Your mail stays with your provider.</strong> This wizard opens apps and explains setup. It doesn’t store your address or password, import mailboxes, or change your default mail app.</div>${checklist(["email"])}<p class="joke">A fresh start, sadly, does not unsubscribe you from newsletters.</p>`,
  files:
    () => `${heading("03 / BRING THE IMPORTANT THINGS", "A new home<br><em>for your files.</em>", "Keep your Mac and its backup until you’ve opened and checked your important files here. Copy first, verify, then decide what to keep.")}
    <div class="rows"><article class="row"><span class="icon" aria-hidden="true">▱</span><div class="row-text"><h3>Bring documents from your Mac</h3><p>Copy Desktop, Documents, and Downloads to an external drive. Connect it here, open Files, and copy them into your home folder. exFAT is useful for sharing drives; formatting erases existing data.</p></div>${actionButton("files", "Open Files ↗")}</article><article class="row"><span class="icon" aria-hidden="true">✿</span><div class="row-text"><h3>Give your photos a portable home</h3><p>On your Mac, select photos in Photos → File → Export → Export Unmodified Original. Export edited versions separately if you want them too. Copy the exported files, then check photos and videos on Omarchy.</p></div></article><article class="row"><span class="icon" aria-hidden="true">☁</span><div class="row-text"><h3>Download cloud-only files first</h3><p>Make sure files are actually downloaded before copying them from your Mac. You can also download from iCloud Drive and Photos on the web. A Photos Library bundle isn’t a portable folder of pictures.</p></div></article></div>
    <div class="callout"><strong>${snapshot.free_gb} GB free in your home filesystem.</strong> Check that there’s enough space for your export and keep a separate backup. iCloud is a synced library; it isn’t a substitute for that backup.</div>${checklist(["local-files", "backup"])}
    <p class="note">${external("https://support.apple.com/guide/photos/export-photos-videos-and-slideshows-pht6e157c5f/mac", "Apple’s photo export guide")}</p>`,
  desktop:
    () => `${heading("04 / A LITTLE MUSCLE MEMORY", "You already know<br><em>more than you think.</em>", "The Super key is your starting point. On most Apple keyboards, that’s ⌘ Command. On PC keyboards, it’s the Windows key.")}
    <div class="shortcut-grid">${[
      ["Open app launcher", "Super", "Space"],
      ["Open terminal", "Super", "Enter"],
      ["Open browser", "Super", "Shift", "B"],
      ["Open Files", "Super", "Shift", "F"],
      ["Close a window", "Super", "W"],
      ["Change workspace", "Super", "1…9"],
    ]
      .map(
        ([label, ...keys]) =>
          `<div class="shortcut"><span>${label}</span><span>${keys.map((k) => `<kbd>${k}</kbd>`).join(" ")}</span></div>`,
      )
      .join("")}</div>
    <p class="keyboard-note">These are stock Omarchy shortcuts; your configuration may differ. Most Linux apps use <kbd>Ctrl</kbd> <kbd>C</kbd> and <kbd>Ctrl</kbd> <kbd>V</kbd>. Omarchy 4 also provides Super+C / Super+V. Terminals commonly use Ctrl+Shift+C / Ctrl+Shift+V.</p>
    <div class="rows"><article class="row"><span class="icon" aria-hidden="true">⌨</span><div class="row-text"><h3>See the shortcuts on this machine</h3><p>Open Omarchy’s own shortcut reference for your current configuration.</p></div>${actionButton("shortcuts", "View shortcuts ↗")}</article><article class="row"><span class="icon" aria-hidden="true">⚙</span><div class="row-text"><h3>Make the desktop comfortable</h3><p>Use Setup for keyboard and trackpad input, displays, and other preferences. Pair headphones and choose your network from the desktop bar.</p></div>${actionButton("settings", "Open Setup ↗")}</article></div>
    <div class="callout"><strong>Windows arrange themselves.</strong> Omarchy tiles apps side by side. Switch workspaces to give different projects their own space. Try opening a terminal, then return here through the app switcher.</div>${checklist(["desktop"])}`,
  apps: () => `${heading("05 / YOUR EVERYDAY, REIMAGINED", "Familiar essentials.<br><em>New possibilities.</em>", "Start with the services you already use. Then bring your bookmarks and make sure you can sign in to the accounts that matter.")}
    <div class="rows">${[
      ["calendar", "▦", "iCloud Calendar", "Your events, still in one place."],
      ["notes", "▤", "iCloud Notes", "Keep your notes within reach."],
    ]
      .map(
        ([id, icon, title, description]) =>
          `<article class="row"><span class="icon" aria-hidden="true">${icon}</span><div class="row-text"><h3>${title}</h3><p>${description}</p></div><button class="secondary" data-action="open" data-service="${id}"${available("webapps")}>Open ↗</button><button class="text-button" data-action="${snapshot.installed.includes(id) ? "remove" : "install"}" data-service="${id}"${available("webapps")}>${snapshot.installed.includes(id) ? "Remove shortcut" : "+ Add shortcut"}</button></article>`,
      )
      .join("")}</div>
    <details class="detail" open><summary>Bring your browser bookmarks</summary><p>Export bookmarks as an HTML file from your Mac’s browser. In Chromium, open the bookmark manager (Ctrl+Shift+O), use its menu, and choose “Import bookmarks.” If you already use Firefox or Chrome sync, sign in through that browser instead.</p></details>
    <details class="detail"><summary>Make a plan for passwords and passkeys</summary><p>iCloud Keychain does not become a Linux password manager when you sign in to iCloud.com. Set up a password manager with Linux support and verify your important logins. Password CSV exports are unencrypted: never upload them here, keep them out of synced folders, and remove them after a verified import. Passkeys may need to be enrolled again; keep a working recovery method.</p></details>
    <details class="detail"><summary>What about AirDrop, iMessage, and Mac apps?</summary><p>This wizard does not provide AirDrop, iMessage, or FaceTime. Use a shared drive or a transfer app available on both devices. macOS applications do not run natively here; use a service’s web app or look for a Linux version. Keep a Mac available for workflows that still need it.</p></details><div class="split-heading"><h2>Make yourself at home</h2></div>${checklist(["bookmarks", "passwords"])}`,
  ready: () => {
    const count = state.tasks.length;
    return `${heading("06 / YOUR NEXT CHAPTER", state.finished ? "Welcome home.<br><em>Make it yours.</em>" : "A good start.<br><em>At your own pace.</em>", "Your setup doesn’t have to happen all at once. Here’s your personal checklist — come back whenever you’re ready for the next step.")}
      <div class="ready-banner"><span class="ready-symbol" aria-hidden="true">${count === Object.keys(labels).length ? "✓" : "◈"}</span><div><h2>${count} of ${Object.keys(labels).length} things feel like home.</h2><p>${snapshot.installed.length} iCloud shortcut${snapshot.installed.length === 1 ? "" : "s"} added. ${count === Object.keys(labels).length ? "Your checklist is complete." : "Anything unchecked is saved for later."}</p></div></div>${checklist(Object.keys(labels))}
      <div class="split-heading"><h2>A little help, always nearby.</h2>${external("https://learn.omacom.io/", "Explore the Omarchy manual")}</div><div class="actions"><button class="secondary" data-export>Save my checklist ↓</button>${actionButton("shortcuts", "View shortcuts ↗", "text-button")}</div><p class="note"><span class="note-icon">◈</span>Your choices are stored locally. Adding a shortcut doesn’t confirm an Apple sign-in; the checklist records what you’ve verified yourself.</p><p class="joke">If you miss your Mac, that’s normal. If you miss its price tag, we have questions.</p>`;
  },
};
function render(focus = false) {
  const active = document.activeElement;
  // Rebuilding the page must not send keyboard users back to the document.
  let restoreFocus;
  if (!focus && content.contains(active)) {
    if (active.dataset.task)
      restoreFocus = `[data-task="${active.dataset.task}"]`;
    else if (active.dataset.action) {
      const action = active.dataset.action;
      const replacement =
        action === "install"
          ? "remove"
          : action === "remove"
            ? "install"
            : action;
      restoreFocus = `[data-action="${replacement}"]${active.dataset.service ? `[data-service="${active.dataset.service}"]` : ""}`;
    }
  }
  const index = steps.findIndex(([id]) => id === state.step);
  document.querySelector("#steps").innerHTML = steps
    .map(
      ([id, label], i) =>
        `<button class="step" data-step="${id}" ${id === state.step ? 'aria-current="step"' : ""}><span class="step-number">${state.completed.includes(id) ? "✓" : String(i + 1).padStart(2, "0")}</span><span class="step-label">${label}</span></button>`,
    )
    .join("");
  content.innerHTML = pages[state.step]();
  document.querySelector("#version").textContent = snapshot.version
    ? `OMARCHY ${snapshot.version}`
    : "OMARCHY WELCOME · PREVIEW";
  document.querySelector("#step-count").textContent =
    `STEP ${String(index + 1).padStart(2, "0")} OF ${String(steps.length).padStart(2, "0")}`;
  document.querySelector("#back").disabled = index === 0;
  document.querySelector("#next").innerHTML =
    index === 0
      ? "Let’s get started →"
      : index === steps.length - 1
        ? state.finished
          ? "All saved ✓"
          : "Finish for now ✓"
        : "Continue →";
  document.querySelector("#next").disabled =
    index === steps.length - 1 && state.finished;
  if (focus) {
    content.focus();
    window.scrollTo({ top: 0, behavior: "instant" });
  } else if (restoreFocus) content.querySelector(restoreFocus)?.focus();
}
async function go(step, complete = false) {
  const next = {
    ...state,
    step,
    completed: complete
      ? [...new Set([...state.completed, state.step])]
      : [...state.completed],
  };
  await save(next);
  clearTimeout(toastTimer);
  document.querySelector("#toast").className = "";
  render(true);
}
async function guarded(fn, element) {
  if (working) return;
  working = true;
  element?.classList.add("busy");
  try {
    await fn();
  } catch (error) {
    notify(
      error.message || "Cannot reach the wizard. Reopen it to continue.",
      true,
    );
  } finally {
    working = false;
    element?.classList.remove("busy");
  }
}
document.addEventListener("click", (event) => {
  const button = event.target.closest("button");
  const home = event.target.closest(".brand");
  if (home) {
    event.preventDefault();
    if (state) guarded(() => go("welcome"), home);
    return;
  }
  if (!button || button.disabled || !state) return;
  if (button.dataset.step) guarded(() => go(button.dataset.step), button);
  else if (button.id === "back")
    guarded(
      () => go(steps[steps.findIndex(([id]) => id === state.step) - 1][0]),
      button,
    );
  else if (button.id === "next")
    guarded(async () => {
      const index = steps.findIndex(([id]) => id === state.step);
      if (index < steps.length - 1) await go(steps[index + 1][0], true);
      else {
        await save({
          ...state,
          finished: true,
          completed: [...new Set([...state.completed, "ready"])],
        });
        render();
        notify(
          "Your progress is saved. You can close this window and come back anytime.",
        );
      }
    }, button);
  else if (button.dataset.action)
    guarded(async () => {
      const result = await api("action", {
        action: button.dataset.action,
        service: button.dataset.service,
      });
      snapshot = await api("state");
      render();
      notify(result.message);
    }, button);
  else if ("export" in button.dataset) {
    const text = `MY OMARCHY CHECKLIST\n\n${Object.entries(labels)
      .map(
        ([key, label]) => `[${state.tasks.includes(key) ? "x" : " "}] ${label}`,
      )
      .join(
        "\n",
      )}\n\nDesktop shortcuts: ${snapshot.installed.join(", ") || "None"}\nShortcuts provide web access, not background sync.\n\nManual: https://learn.omacom.io/\n`;
    const url = URL.createObjectURL(new Blob([text], { type: "text/plain" }));
    const a = document.createElement("a");
    a.href = url;
    a.download = "my-omarchy-checklist.txt";
    a.click();
    setTimeout(() => URL.revokeObjectURL(url), 1000);
  }
});
document.addEventListener("change", (event) => {
  const input = event.target.closest("[data-task]");
  if (!input) return;
  if (working) {
    input.checked = state.tasks.includes(input.dataset.task);
    return;
  }
  guarded(async () => {
    const tasks = input.checked
      ? [...new Set([...state.tasks, input.dataset.task])]
      : state.tasks.filter((t) => t !== input.dataset.task);
    try {
      await save({ ...state, tasks });
      if (state.step === "ready") render();
    } catch (error) {
      input.checked = state.tasks.includes(input.dataset.task);
      throw error;
    }
  }, input);
});
async function start() {
  try {
    snapshot = await api("state");
    state = snapshot.state;
    render();
    if (snapshot.warning) notify(snapshot.warning, true);
    setInterval(() => api("state").catch(() => {}), 60000);
  } catch (error) {
    content.innerHTML = `<div class="error-panel"><h1>Let’s reconnect.</h1><p>${escapeHTML(error.message)}</p><p>Open <strong>Omarchy Welcome</strong> from your app launcher, or run <code>bin/omarchy-welcome</code> from the project directory.</p></div>`;
    document.querySelector("#next").disabled = true;
    document.querySelector("#back").disabled = true;
  }
}
start();
