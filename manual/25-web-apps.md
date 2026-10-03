# Web Apps

You can add your own web apps using _Install > Web App_ in the Omarchy menu (`Super + Space`). It'll ask you for the app name, app URL, and the icon URL, if it can't retrieve it via favicon. You can get great PNG icons for many popular web apps on [Dashboard Icons](https://dashboardicons.com).

They'll then be accessible through the app launcher (`Super + Space`), and use the beautiful frameless web-app window.

If you wish to remove a web app, just go to _Remove > Web App_ in the Omarchy menu.

It's best if you log into all your accounts using a regular browser before using the web app shortcuts. The thin wrapper frame doesn't work well with 1password, so just easier to be logged in directly first.

All the keyboard hotkeys for these web apps can be changed in `~/.config/hypr/bindings.lua`.

When you're in a web app, you can copy the current URL to the clipboard using `Shift + Alt + L`.

## Open external links in your default browser

By default, web apps keep their links in the app window. If you prefer links to other sites to open in your system's default browser, enable the optional Chromium-family extension with `omarchy toggle webapp-links on`. Restart Chromium, Chrome, Brave, or Edge (including existing browser windows) afterward. To return to the original behavior, use `omarchy toggle webapp-links off` and restart the browser. This also works when your default browser is the same browser used for web apps: the external link opens in a regular browser window or tab, not another app window.

The extension affects only links clicked in app windows and new windows opened by app pages; ordinary browser tabs are unaffected. Same-origin links, form submissions, and automatic redirects stay in the app. Other origins (even subdomains) open in your default browser unless you allow them for that app. For example, to keep an app's `www` subdomain and an identity provider's sign-in pages in the app, create `~/.config/omarchy/webapp-links.json` containing:

```json
{
  "https://app.example.com": [
    "https://www.example.com",
    "https://login.identity.example"
  ]
}
```

Use the actual HTTP(S) origins (scheme, hostname, and optional port, without a path) for your app and its sign-in provider. Both directions within each configured group stay in the app. Restart the app window after editing the file. Cross-origin OAuth redirects already stay in the app without this configuration, but a sign-in flow that *starts with a clicked link or popup* at another origin needs that origin in the list. If the native host or default browser is unavailable, links remain navigable in Chromium. The option supports Omarchy's Chromium, Chrome, Brave, and Edge flag files and remains enabled after refreshing Chromium if you left the option on.

## Included web apps

By default, Omarchy already ships with an assortment of default apps:

## HEY

[HEY](https://www.hey.com/) is an email and calendar service that serves as a great alternative to people tired of Gmail, Outlook, or Apple Mail. It's made by [37signals](https://37signals.com/) where Omarchy originated.

You can start HEY Email using `Super + Shift + E`, jump straight to composing a new email using `Super + Shift + Alt + E`, and start HEY Calendar using `Super + Shift + C`.

## Basecamp

[Basecamp](https://basecamp.com/) is a project management service that helps small teams move faster and make more progress. Instead of patching together a mishmash of Trello, Slack, Asana, Notion, or whatever, you can have it all in one place with Basecamp. It's made by [37signals](https://37signals.com/) where Omarchy originated.

You can start Basecamp using the application launcher (`Super + Space`)

## ChatGPT

[ChatGPT](https://chatgpt.com) is the most popular AI chat bot in the world.

You can start ChatGPT using `Super + Shift + A`.

## Grok

[Grok](https://grok.com) is xAI's chat bot.

You can start Grok using `Super + Shift + Alt + A`.

## WhatsApp

[WhatsApp](https://www.whatsapp.com/) is one of the most popular messaging services in the world, and the web version is a great option for Linux.

You can start WhatsApp using `Super + Shift + Alt + G`.

## Google apps

Google Messages, Google Photos, Google Maps, and Google Contacts are all included as web apps too.

You can start Google Messages using `Super + Shift + Ctrl + G`, Google Photos using `Super + Shift + P`, and Google Maps using `Super + Shift + S`. Google Contacts is available through the app launcher (`Super + Space`).

## X

X is where news break.

You can start X using `Super + Shift + X` and go straight to writing a new post with `Super + Shift + Alt + X`.

## YouTube

[YouTube](https://youtube.com/) is the most popular video platform in the world.

You can start YouTube using `Super + Shift + Y`.

## Zoom

[Zoom](https://zoom.us/) is the most popular video chat system used in the US. Great connections across the world. And 40-minute meetings can be held without a paying account. Omarchy wraps Zoom's web client, and zoom meeting links will open straight into it.

You start Zoom using the application launcher (`Super + Space`).

## Discord

[Discord](https://discord.com/) is where most gaming and open source communities hang out, including [Omarchy's own](https://discord.gg/tXFUdasqhY).

You start Discord using the application launcher (`Super + Space`).
