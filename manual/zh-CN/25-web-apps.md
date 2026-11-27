# Web 应用

你可以通过 Omarchy 菜单（`Super + Space`）中的 _安装 > Web 应用_ 添加你自己的 Web 应用。它会让你输入应用名称、应用 URL，如果无法通过 favicon 获取图标，还会让你输入图标 URL。你可以在 [Dashboard Icons](https://dashboardicons.com) 上找到许多热门 Web 应用的优质 PNG 图标。

之后，你可以通过应用启动器（`Super + Space`）访问它们，并使用漂亮的无边框 Web 应用窗口。

如果你想移除某个 Web 应用，只需前往 Omarchy 菜单中的 _移除 > Web 应用_。

最好先使用普通浏览器登录你的所有账户，然后再使用 Web 应用快捷方式。这个轻量封装框架与 1password 配合得不太好，所以直接先登录会更省事。

这些 Web 应用的所有键盘快捷键都可以在 `~/.config/hypr/bindings.lua` 中更改。

当你在某个 Web 应用中时，可以使用 `Shift + Alt + L` 将当前 URL 复制到剪贴板。

默认情况下，Omarchy 已经附带了一系列默认应用：

## HEY

[HEY](https://www.hey.com/) 是一款电子邮件和日历服务，对于厌倦了 Gmail、Outlook 或 Apple Mail 的人来说，是一个很好的替代选择。它由 [37signals](https://37signals.com/) 开发，Omarchy 也起源于那里。

你可以使用 `Super + Shift + E` 启动 HEY Email，使用 `Super + Shift + Alt + E` 直接跳转到撰写新邮件，并使用 `Super + Shift + C` 启动 HEY Calendar。

## Basecamp

[Basecamp](https://basecamp.com/) 是一款项目管理服务，可帮助小团队更快地推进工作并取得更多进展。你无需将 Trello、Slack、Asana、Notion 或其他什么工具拼凑在一起，而是可以在 Basecamp 中将一切集中在一个地方。它由 [37signals](https://37signals.com/) 开发，Omarchy 也起源于那里。

你可以使用应用启动器（`Super + Space`）启动 Basecamp

## ChatGPT

[ChatGPT](https://chatgpt.com) 是世界上最受欢迎的 AI 聊天机器人。

你可以使用 `Super + Shift + A` 启动 ChatGPT。

## Grok

[Grok](https://grok.com) 是 xAI 的聊天机器人。

你可以使用 `Super + Shift + Alt + A` 启动 Grok。

## WhatsApp

[WhatsApp](https://www.whatsapp.com/) 是世界上最受欢迎的消息服务之一，其 Web 版本是 Linux 上的一个很好的选择。

你可以使用 `Super + Shift + Alt + G` 启动 WhatsApp。它会通过 Omarchy 的 WhatsApp Slim 扩展打开，该扩展会让它跟随你的主题，并在窗口较窄时折叠聊天列表。

## Google 应用

Google Messages、Google Photos、Google Maps 和 Google Contacts 也都作为 Web 应用包含在内。

你可以使用 `Super + Shift + Ctrl + G` 启动 Google Messages，使用 `Super + Shift + P` 启动 Google Photos，并使用 `Super + Shift + S` 启动 Google Maps。Google Contacts 可通过应用启动器（`Super + Space`）访问。

## X

X 是新闻最先发布的地方。

你可以使用 `Super + Shift + X` 启动 X，并使用 `Super + Shift + Alt + X` 直接撰写新帖子。

## YouTube

[YouTube](https://youtube.com/) 是世界上最受欢迎的视频平台。

你可以使用 `Super + Shift + Y` 启动 YouTube。

## Netflix

[Netflix](https://www.netflix.com/) 在新安装中作为 Web 应用包含在内。

你使用应用启动器（`Super + Space`）启动 Netflix。

## Zoom

[Zoom](https://zoom.us/) 是美国最受欢迎的视频聊天系统。在全球范围内连接效果出色。而且无需付费账户即可举行 40 分钟的会议。Omarchy 封装了 Zoom 的 Web 客户端，Zoom 会议链接会直接在其中打开。

你使用应用启动器（`Super + Space`）启动 Zoom。

## Discord

[Discord](https://discord.com/) 是大多数游戏和开源社区聚集的地方，包括 [Omarchy 自己的社区](https://discord.gg/tXFUdasqhY)。

你使用应用启动器（`Super + Space`）启动 Discord。

## Microsoft 应用

选择 _安装 > 服务 > Microsoft_，即可将 Outlook、Word、Excel、PowerPoint、Teams 和 OneDrive 添加为 Web 应用。每个应用都有自己的启动器，并会使用商业版 Microsoft 365 URL 和你现有的浏览器配置文件直接打开。它们会在与 Omarchy 其他 Web 应用相同的浏览器应用窗口中打开；它们不会安装单独的 Teams for Linux 客户端。

使用 _移除 > 服务 > Microsoft_ 移除该套件，或使用 _移除 > Web 应用_ 移除单个应用。你也可以通过 _安装 > Web 应用_ 只安装你想要的应用。

对于政府或主权云，请编辑 `~/.local/share/applications/` 下相关启动器中 `Exec=` 行上的 URL，例如 `Microsoft Teams.desktop`，并使用你的组织提供的 URL。在该行中，任何字面意义的 `%` 都应写为 `%%`。更改将在下次启动时生效。再次运行套件安装程序会将其启动器替换为默认 URL。

若要将工作登录保持独立，请将浏览器数据目录附加到每个启动器的 `Exec=` 行：

```ini
Exec=omarchy-launch-webapp "https://teams.cloud.microsoft/" --user-data-dir=/absolute/path/to/work-browser-profile
```

将示例目录替换为你选择的绝对路径，并为全部六个启动器使用相同的路径，以便在它们之间共享工作登录。这些 Web 应用使用 Omarchy 所选的受支持浏览器，当默认浏览器不受支持时，则回退到 Chrome。
