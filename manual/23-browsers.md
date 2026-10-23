# Browsers

Omarchy ships with [Chromium](https://www.chromium.org/) as the default browser. It's the plain open-source build, themed to match the rest of your system, and it's what `Super + Shift + Return` opens and what every [web app](25-web-apps.md) runs inside.

If Chromium isn't your taste, you're not stuck with it. Under _Install > Browser_ in the Omarchy menu you'll find Chrome, Edge, Brave, Brave Origin, Firefox, and [Zen](https://zen-browser.app/). Pick one and Omarchy installs it, sets up its policy directory, and applies your current theme to it.

Every Chromium-family browser also gets a managed privacy policy at install time: it turns off search suggestions, prefetch and prediction, third-party cookies, spell-check uploads, and limits WebRTC to your public interface. Edge honours `AlternateErrorPagesEnabled`, `BlockThirdPartyCookies`, `NetworkPredictionOptions`, and `SearchSuggestEnabled`; its WebRTC and spell-check settings stay at their defaults.

Chromium uses the value from the managed JSON file whose name sorts last in byte order. To override `privacy.json`, add a root-owned file named after it, such as `/etc/chromium/policies/managed/zz-local.json`; the managed-policy directory is root-owned, and Omarchy's policy-directory purge removes files not owned by root. For example: `sudo install -o root -g root -m 0644 zz-local.json /etc/chromium/policies/managed/zz-local.json`.

## Making one the default

Installing a browser doesn't promote it. Once it's on the machine, go to _Setup > Defaults > Browser_ and pick it — the menu only lists browsers you actually have installed, and marks the current default with a check.

From the terminal it's:

```bash
omarchy default browser firefox
```

Run it with no argument and it tells you the current default. This sets the XDG handler, so it's not just Omarchy's hotkeys that follow along — anything that opens a link, from a chat app to a terminal command, goes to the browser you picked.

## Copy URL and Download Video

The Chromium-family browsers (Chromium itself, Chrome, Edge, and Brave) come with two Omarchy extensions that reach out of the browser and into the rest of your system.

**Copy URL** puts the current tab's address on your clipboard with `Alt + Shift + L`. That's faster than clicking into the address bar and copying, and because it goes through the system clipboard rather than the browser's, you get an Omarchy notification confirming it and the URL is immediately available in [clipboard history](08-unified-clipboard-history.md) and every other app. There's a toolbar button too, if you prefer clicking.

**Download Video** grabs the video playing on the page you're looking at with `Alt + Shift + D`. It hands the URL to [yt-dlp](https://github.com/yt-dlp/yt-dlp), so it works on far more than YouTube, and the download lands in `~/Videos`. Progress shows up in the same on-screen display that volume and brightness use, updating in place rather than stacking up notifications. Set `OMARCHY_YTDLP_DIR` if you'd rather the files went somewhere else — see the [FAQ](46-faq.md) for where to put environment variables.

Both extensions talk to Omarchy through a small native messaging host, which gets installed for you along with the browser. That's the piece that lets a web page's video end up in your home directory and a URL end up in your clipboard manager, which a normal extension can't do on its own.

These are Chromium-family only. Firefox and Zen don't get them.

## Firefox and Zen

Firefox and Zen are a different family, so they get different treatment: Omarchy installs a policies file for sensible defaults and switches them into native Wayland mode, which you want for fractional scaling and smooth trackpad scrolling.

They don't get the Chromium extensions above, and they're not themed by Omarchy, so those parts of the experience are yours to set up.

## Removing one again

Anything you installed here can be taken back off under _Remove > Browser_. Chromium isn't in that list — it's part of the base system.
