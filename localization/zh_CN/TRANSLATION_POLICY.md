# Omarchy 简体中文本地化规范 (Translation Policy)

## 1. 核心原则

> **翻译用户交互动词与通用 GUI 概念；完整保留技术专有名词、产品名称、命令行与系统机器标识。**
> Translate user actions and generic UI concepts. Preserve technical proper nouns, product names, commands, and identifiers.

本地化必须服务于真实开发者工作流：中文用户能够自然理解桌面核心交互，同时在终端排错、阅读官方文档、搜索 Arch Wiki / GitHub 时不产生任何认知断层与割裂。

---

## 2. 严禁翻译的技术实体与专有名词 (0% 翻译)

以下词汇在任何界面、菜单、提示、文档引用中**必须保持英文原样**：

### 核心系统与发行版
- `Omarchy`
- `Arch Linux`
- `Hyprland`
- `Quickshell`
- `Wayland`
- `XWayland`

### 智能体与模型工具 (Agents & Models)
- `Codex`
- `Claude Code`
- `Gemini CLI`
- `OpenCode`
- `Grok`
- `Copilot`
- `Hermes`
- `Crush`
- `Pi` / `Oh My Pi`

### 开发与运行时工具
- `Git`, `GitHub`, `GitHub CLI`
- `Docker`
- `systemd`, `pacman`, `AUR`, `mise`
- `Neovim`, `Vim`, `Emacs`, `VS Code`, `Cursor`, `Zed`

### 底层框架、驱动与音频网络栈
- `PipeWire`, `WirePlumber`
- `NetworkManager`
- `Fcitx`, `Fcitx 5`
- `QEMU`, `VirGL`, `ANGLE`, `Metal`

### 绝对禁止的翻译反例 (视为严重 Bug)
- ❌ Gemini CLI → 双子星命令行
- ❌ Codex → 法典
- ❌ Claude Code → 克劳德代码
- ❌ OpenCode → 开放代码
- ❌ Docker → 码头工
- ❌ Shell → 壳
- ❌ Hyprland → Hypr 大陆
- ❌ Arch Linux → 拱形 Linux

---

## 3. 边界划分：GUI vs CLI vs 系统环境

> **核心判定准则：看最终输出展示在哪里（Destination-driven localization）。**
> `Bash != automatically English`。脚本如果产生的是最终显示在桌面 GUI 的通知、OSD 或图形选择器，必须本地化；如果是终端口令、CLI 帮助、终端日志或终端提示符，保持英文。

| 层次 | 语言策略 | 说明 |
| :--- | :--- | :--- |
| **Shell GUI 表现层 (QML)** | 简体中文 | 顶层菜单、系统菜单、核心控制面板、确认对话框、通用操作按钮、状态提示、占位文本、空状态 |
| **图形通知与桌面 OSD (Shell Scripts)** | 简体中文 | `omarchy-notification-send`、`omarchy-osd`、`omarchy-menu-select` 等产生的桌面图形提示通过 `omarchy-i18n` 本地化 |
| **第三方通知与应用内容** | 保持原样 (English) | Notification Server 绝不能全局调用 `I18n.tr` 篡改第三方应用发送的通知 summary/body |
| **搜索别名 (Aliases)** | 英文 + 中文并存 | 允许用户输入 `Setup` 或 `设置` 均能匹配，不破坏英文文档可搜索性 |
| **CLI 命令行** | 英文 (English) | `omarchy --help`、子命令、参数、终端输出、gum 终端选择器保持官方英文 |
| **系统日志 / 报错** | 英文 (English) | `systemctl`、`journalctl`、调试输出保持英文，便于搜索定位 |
| **机器标识与配置键** | 英文 (English) | 菜单 ID、插件 ID、命令名、环境变量、JSON 键绝对不得翻译 |
| **动态用户数据** | 保持原样 (Dynamic) | SSID、蓝牙设备名、IP、网关、时区标识、用户名、主机名、文件路径等严禁翻译 |

---

## 4. 推荐通用词汇映射

- **Settings / Setup** → 设置
- **Install** → 安装
- **Remove** → 卸载 (软件) / 移除 (条目) / 删除 (文件)
- **Update** → 更新
- **Style** → 外观
- **Theme** → 主题
- **Background** → 背景
- **Network** → 网络
- **Bluetooth** → 蓝牙
- **Audio** → 音频
- **Display / Monitor** → 显示 / 显示器
- **Power** → 电源
- **Power Profile** → 电源模式
- **Workspace** → 工作区
- **Terminal** → 终端
- **Package** → 软件包
- **Plugin** → 插件
- **Connect / Disconnect** → 连接 / 断开连接
- **Pair / Forget** → 配对 / 忘记 (忘记设备 / 忘记此网络)
- **Enable / Disable** → 启用 / 禁用
- **Save / Cancel / Confirm / Close** → 保存 / 取消 / 确认 / 关闭
- **Search** → 搜索
- **Restart / Reboot** → 重启
- **Shutdown** → 关机
- **Suspend / Hibernate / Logout** → 挂起 / 休眠 / 退出登录

---

## 5. 占位符与参数一致性 (Placeholder Parity)

所有翻译字符串中的占位符（如 `%1`、`%2`、`${name}`、`{count}`）必须完整保留且语义对应，严禁漏掉或篡改参数索引。
