# Web Apps

You can add your own web apps using _Install > Web App_ in the Omarchy menu (`Super + Space`). It'll ask you for the app name, app URL, and the icon URL, if it can't retrieve it via favicon. You can get great PNG icons for many popular web apps on [Dashboard Icons](https://dashboardicons.com).

They'll then be accessible through the app launcher (`Super + Space`), and use the beautiful frameless web-app window.

If you wish to remove a web app, just go to _Remove > Web App_ in the Omarchy menu.

It's best if you log into all your accounts using a regular browser before using the web app shortcuts. The thin wrapper frame doesn't work well with 1password, so just easier to be logged in directly first.

All the keyboard hotkeys for these web apps can be changed in `~/.config/hypr/bindings.lua`.

When you're in a web app, you can copy the current URL to the clipboard using `Shift + Alt + L`.

## Choosing the web app browser

Use _Setup > Defaults > Web App Browser_ to choose an installed app-mode browser separately from your normal browser. For example, you can use Zen for links and Helium for web apps:

```bash
omarchy default browser zen
omarchy default webapp-browser helium
```

This applies when opening existing web-app shortcuts too. Custom launch commands supplied when creating a shortcut keep their own behavior. Cookies, extensions, and sign-ins come from the selected browser, so sign in there first. Helium is also available under _Setup > Defaults > Browser_ for normal browsing; choosing it there installs it if needed.

The web-app setting starts at **Automatic**. In this mode, Omarchy uses the regular browser if it supports Chromium's app-window mode, otherwise Chromium. Run `omarchy default webapp-browser auto` to restore this behavior. With no argument, the command prints `auto` or the selected desktop entry ID. If a selected browser is removed, choose another browser or Automatic before opening web apps.

### Experimental Zen web apps

Zen has a separate native web-app feature. In Zen's `about:config`, set `browser.taskbarTabs.enabled` to `true`, then use the app button in the address bar on an HTTPS site. Zen creates its own app shortcut and uses that browser profile. Set the preference back to `false` to disable the feature.

This is separate from Omarchy's _Install > Web App_ command. In Zen 1.22.1b, the native command-line recovery path drops URL paths and query strings, and the app window can show an empty sidebar. Omarchy therefore does not list Zen as an app-mode browser. See [Zen’s layout issue](https://github.com/zen-browser/desktop/issues/14314) and [Mozilla’s start-page issue](https://bugzilla.mozilla.org/show_bug.cgi?id=2035949).

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
