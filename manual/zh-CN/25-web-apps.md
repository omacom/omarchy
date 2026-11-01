# 网页应用

你可以使用 Omarchy 菜单（`Super + Space`）中的 _安装 > Web App_ 添加你自己的网页应用。它会询问你应用名称、应用 URL 和图标 URL（如果它无法通过 favicon 获取）。你可以在 [Dashboard Icons](https://dashboardicons.com) 上为许多流行的网页应用找到精美的 PNG 图标。

它们之后将通过应用程序启动器（`Super + Space`）访问，并使用漂亮的无边框网页应用窗口。

如果你想删除一个网页应用，只需进入 Omarchy 菜单中的 _移除 > Web App_。

最好在使用网页应用快捷方式之前，先用普通浏览器登录你所有的账户。这个薄包装框与 1password 配合不好，所以直接先登录更简单。

所有这些网页应用的键盘快捷键都可以在 `~/.config/hypr/bindings.lua` 中更改。

当你在网页应用中时，你可以用 `Shift + Alt + L` 将当前 URL 复制到剪贴板。

默认情况下，Omarchy 已经附带了一系列默认应用：

## HEY

[HEY](https://www.hey.com/) 是一项电子邮件和日历服务，是厌倦了 Gmail、Outlook 或 Apple Mail 的人的绝佳替代品。它由 Omarchy 起源的 [37signals](https://37signals.com/) 制作。

你可以用 `Super + Shift + E` 启动 HEY Email，用 `Super + Shift + Alt + E` 直接跳转到撰写新邮件，并用 `Super + Shift + C` 启动 HEY Calendar。

## Basecamp

[Basecamp](https://basecamp.com/) 是一项项目管理服务，帮助小团队更快地推进并取得更多进展。你无需将 Trello、Slack、Asana、Notion 或其他什么拼凑在一起，Basecamp 可以将一切放在一处。它由 Omarchy 起源的 [37signals](https://37signals.com/) 制作。

你可以使用应用程序启动器（`Super + Space`）启动 Basecamp

## ChatGPT

[ChatGPT](https://chatgpt.com) 是世界上最受欢迎的 AI 聊天机器人。

你可以用 `Super + Shift + A` 启动 ChatGPT。

## Grok

[Grok](https://grok.com) 是 xAI 的聊天机器人。

你可以用 `Super + Shift + Alt + A` 启动 Grok。

## WhatsApp

[WhatsApp](https://www.whatsapp.com/) 是世界上最受欢迎的消息服务之一，而网页版是 Linux 的绝佳选择。

你可以用 `Super + Shift + Alt + G` 启动 WhatsApp。

## Google 应用

Google Messages、Google Photos、Google Maps 和 Google Contacts 也都作为网页应用包含在内。

你可以用 `Super + Shift + Ctrl + G` 启动 Google Messages，用 `Super + Shift + P` 启动 Google Photos，并用 `Super + Shift + S` 启动 Google Maps。Google Contacts 通过应用程序启动器（`Super + Space`）可用。

## X

X 是新闻爆发的地方。

你可以用 `Super + Shift + X` 启动 X，并用 `Super + Shift + Alt + X` 直接去写一篇新帖子。

## YouTube

[YouTube](https://youtube.com/) 是世界上最受欢迎的视频平台。

你可以用 `Super + Shift + Y` 启动 YouTube。

## Zoom

[Zoom](https://zoom.us/) 是美国最受欢迎的视频聊天系统。全球连接出色。而且无需付费账户即可举行 40 分钟的会议。Omarchy 包装了 Zoom 的网页客户端，zoom 会议链接将直接打开到其中。

你使用应用程序启动器（`Super + Space`）启动 Zoom。

## Discord

[Discord](https://discord.com/) 是大多数游戏和开源社区聚集的地方，包括 [Omarchy 自己的](https://discord.gg/tXFUdasqhY)。

你使用应用程序启动器（`Super + Space`）启动 Discord。

## Microsoft 应用

选择 _Install > Service > Microsoft_ 以将 Outlook、Word、Excel、PowerPoint、Teams 和 OneDrive 作为网页应用添加。每个应用都有自己的启动器并直接打开，使用商业 Microsoft 365 URL 和你现有的浏览器配置文件。它们打开在与 Omarchy 其他网页应用相同的浏览器应用窗口中；它们不会安装单独的 Teams for Linux 客户端。

用 _Remove > Service > Microsoft_ 删除整个套件，或者用 _Remove > Web App_ 删除单个应用。你也可以通过 _Install > Web App_ 只安装你想要的应用。

对于政府或主权云，使用你的组织提供的 URL，编辑 `~/.local/share/applications/` 下相关启动器中 `Exec=` 行上的 URL，例如 `Microsoft Teams.desktop`。将该行中的任何字面量 `%` 写为 `%%`。更改在下一次启动时生效。再次运行套件安装程序会将其启动器替换为默认 URL。

为了将工作登录分开，将浏览器数据目录追加到每个启动器的 `Exec=` 行：

```ini
Exec=omarchy-launch-webapp "https://teams.cloud.microsoft/" --user-data-dir=/absolute/path/to/work-browser-profile
```

将示例目录替换为你选择的一个绝对路径，并对所有六个启动器使用相同的路径，以在它们之间共享工作登录。网页应用使用 Omarchy 选择的受支持浏览器，当默认浏览器不受支持时回退到 Chromium。
