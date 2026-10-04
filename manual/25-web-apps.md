# Web Apps

You can add your own web apps using _Install > Web App_ in the Omarchy menu (`Super + Space`). It'll ask you for the app name, app URL, and the icon URL, if it can't retrieve it via favicon. You can get great PNG icons for many popular web apps on [Dashboard Icons](https://dashboardicons.com).

They'll then be accessible through the app launcher (`Super + Space`), and use the beautiful frameless web-app window.

If you wish to remove a web app, just go to _Remove > Web App_ in the Omarchy menu.

It's best if you log into all your accounts using a regular browser before using the web app shortcuts. The thin wrapper frame doesn't work well with 1password, so just easier to be logged in directly first.

All the keyboard hotkeys for these web apps can be changed in `~/.config/hypr/bindings.lua`.

When you're in a web app, you can copy the current URL to the clipboard using `Shift + Alt + L`.

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

## Microsoft apps

Select _Install > Service > Microsoft_ to add Outlook, Office, Teams, and OneDrive as web apps. These use the commercial Microsoft 365 URLs and your existing browser profile. They open in the same browser app windows as Omarchy's other web apps; they do not install the separate Teams for Linux client.

Remove the bundle with _Remove > Service > Microsoft_, or remove individual apps with _Remove > Web App_. You can also install just the apps you want through _Install > Web App_.

For a government or sovereign cloud, edit the URL on the `Exec=` line in the relevant launcher under `~/.local/share/applications/`, such as `Microsoft Teams.desktop`, using the URL supplied by your organization. Write any literal `%` in that line as `%%`. Changes apply on the next launch. Running the bundle installer again replaces its launchers with the default URLs.

To keep work sign-ins separate, append a browser data directory to each launcher's `Exec=` line:

```ini
Exec=omarchy-launch-webapp "https://teams.cloud.microsoft/" --user-data-dir=/absolute/path/to/work-browser-profile
```

Replace the example directory with an absolute path of your choice and use the same path for all four launchers to share work sign-ins between them. The web apps use Omarchy's selected supported browser, falling back to Chromium when the default browser is unsupported.
