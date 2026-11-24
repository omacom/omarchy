# Commercial apps/services

Omarchy is mostly focused on providing free, open source software, but it's not religious about it. Sometimes the best solution is a commercial offering, and that's just fine. Here are some of the options we provide an easy installation for.

## 1Password

Keeping your passwords in a password manager is a best practice. Doubly so if you're working with a team. And [1password](https://1password.com/) is a great solution, which also comes with a command line tool for integrating key lookups in scripts.

You start 1Password with `Super + Shift + /`. If it isn't installed yet, that hotkey kicks off the installation first (you can also use _Install > Service > 1Password_ from the Omarchy menu). The installer also brings the 1Password command line tool and sets up the 1Password extension for Chrome and Chromium; restart your browser to load it.

## Bitwarden

[Bitwarden](https://bitwarden.com/) is the open source alternative in the password manager space, with a free tier that covers most personal use. Install it with _Install > Service > Bitwarden_ from the Omarchy menu, which brings along the Bitwarden command line tool as well.

## Spotify

[Spotify](https://spotify.com/) is the world's most popular streaming music service. Omarchy ships it as a web app, which gives you the full player, media keys, and Spotify Connect, but not offline downloads. Start it with `Super + Shift + M`.

## Slack

[Slack](https://slack.com/) is where a lot of teams do their chatting, both inside the company and with outside collaborators. Install it with _Install > Service > Slack_ from the Omarchy menu, and it'll open as soon as it's ready.

## Notion

[Notion](https://www.notion.com/) is a workspace for notes, docs, and projects. Install its desktop app with _Install > Service > Notion_ from the Omarchy menu.

## WeChat

[WeChat](https://www.wechat.com/) is the messaging app most of China runs on, for chatting, calls, and staying in touch with anyone who lives there. Install Tencent's official Linux client with _Install > Service > WeChat_ from the Omarchy menu, and it'll open as soon as it's ready. It's only available on x86 computers.

## Dropbox

[Dropbox](https://www.dropbox.com/) is a great way to sync files between machines while keeping a backup in the cloud. To set it up, select _Install > Service > Dropbox_ from the Omarchy menu. It adds a Dropbox icon to the bar: click it to log in, then use the same panel to check your storage and open recently synced files.

## Tailscale

[Tailscale](https://tailscale.com/) is a mesh VPN that makes getting access to all your computers and servers over the internet securely super simple. To set it up, select _Install > Service > Tailscale_ from the Omarchy menu.

It gets a panel in the bar, a web app for the admin console, and Taildrop for sending files between your machines — see [networking](35-networking.md).

## ONCE

[ONCE](https://github.com/basecamp/once) installs and manages self-hosted applications such as Writebook, including updates and backups. Select _Install > Service > ONCE_ to install the patched `once` package and enable its rootless user service. Package installation and enabling startup before login need administrator access once; ONCE and its applications then run as your user.

Run `omarchy launch once` to open the interface, or pass ONCE commands such as `omarchy launch once list`. Local applications use addresses like `http://writebook.localhost:8080`. The proxy binds only to your computer's loopback address; public hosting and automatic public HTTPS are not configured by this installer. Background work continues after logout.

Existing rootful ONCE installations need an explicit backup/restore migration. The engine migration stays pending for a legacy ONCE package or an active or enabled legacy system service. The rootless `once` package alone does not block migration. The installer also refuses an active or enabled legacy system service. It never silently disables that service or moves its application data. Test restored applications before retiring the old deployment.

## NordVPN

[NordVPN](https://nordvpn.com/) is a standard VPN service that lets you exit your traffic from most regions around the world. To set it up, select _Install > Service > NordVPN_ from the Omarchy menu. After the reboot it asks for, run `nordvpn login` to authenticate.
