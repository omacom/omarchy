# FAQ

### 如何在键盘布局之间切换？

编辑你的 `~/.config/hypr/input.lua` 文件，并添加以下内容以在 `Left Alt + Right Alt` 时切换布局：

```
hl.config({
  input = {
    -- Use multiple keyboard layouts and switch between them with Left Alt + Right Alt
    kb_layout = "us,fr",
    kb_options = "omarchy:shift_caps_compose,grp:alts_toggle",
  },
})
```

一旦你配置了多个布局，栏会自动显示你当前的键盘布局（你也可以点击它来切换）。

### 如何将时钟格式改为 12 小时制？

右键点击栏中的时钟，以循环切换到常见格式，包括 12 小时制。你也可以直接设置格式：

```
omarchy bar set omarchy.clock format "dddd h:mm AP"
```

这会显示 Sunday 10:55 AM。

### 如何更改我的时区？

在 Omarchy 菜单里运行 _更新 > 时区_ 并从列表中选择。如果时区是对的但时钟本身漂移了，_更新 > 时间_ 会为你重启时间同步。

### 如何更改我的 DNS、分享我的 Wi-Fi，或检查我的连接速度？

这些都位于[网络](35-networking.md)里。

### 如何检查我的磁盘速度？

_触发 > 测速 > 磁盘测速_ 测量你硬盘的实时读写速度，或在终端中运行 `omarchy disk speedtest`。

### 为什么我无法在 Chromium 中登录我的 Google 账户？

纯开源的 Chromium 构建版本不附带 Google 账户登录所要求的 OAuth 凭据。在 Omarchy 菜单里运行 _安装 > 服务 > Chromium 账户_ 添加它们，重启浏览器，登录就会成功。

### 如何添加打印机？

打印功能开箱已设置并正在运行，你可以从应用启动器（`Super + Space`）中的 _Print Settings_ 自行添加每台打印机。

选择 _Add_，给它一些时间查找：通过 USB 连接的打印机，以及大多数网络打印机，都会被找到。如果你的不在列表中，选择 _Network Printer > Internet Printing Protocol (ipp)_ 并输入其地址——打印机自己的显示屏或其网页会告诉你那是什么，通常像是 `192.168.1.50`，队列为 `ipp/print`。然后 _Forward_ 会提供一个驱动程序，现代打印机在无驱动的 _IPP Everywhere_ 配置文件上工作得最好，而旧打印机则需要该型号自己的驱动程序。

右键点击打印机并选择 _Set as Default_ 以选择你的应用首先使用哪一台，以及选择 _Properties_ 以设置纸张尺寸、双面打印和质量。

自动发现（即网络上的打印机在未添加时出现）暂时被关闭了，因为它正在重新改造，这就是为什么上面第一步需要由你完成而不是自动完成。打印到 PDF 文件完全无需任何打印机也可以进行。

### 如何更改截图或录屏的保存位置？

已保存的截图默认保存到 `~/Pictures/Screenshots`。要使用另一个目录，请将以下内容添加到 `~/.config/uwsm/env.d/` 下的一个文件中（比如 `~/.config/uwsm/env.d/capture`）：

```
export OMASNAP_SCREENSHOT_DIR="$HOME/Pictures/Captures"
```

你也可以对录屏使用 `OMARCHY_SCREENRECORD_DIR` 做同样的事。

Omasnap 会自动创建其截图目录。录屏目录需要你自己创建，然后重启 Omarchy 使环境更改生效。

### 如何让我的 Apple Studio Display 上的扬声器 + 摄像头工作？

你可能会以为插上 USB C 就该全部工作，但不幸的是并非如此。我找到的可靠解决方案是使用 [WJESOG DisplayPort + USB-A => USB-C 线缆](https://www.amazon.com/WJESOG-DisplayPort-Adapter-Converter-Thunderbolt/dp/B0BNX7MS6N/)。然后扬声器和摄像头就都能完美工作了。

记住，Omarchy 内置了对 Apple Displays（包括 Studio 和 XDR）的亮度控制，使用普通的键盘亮度按钮即可。

### 如何去除所有额外软件？

如果你不想要像 Obsidian 或 LibreOffice 或其他任何预装软件那样的程序，你可以非常轻松地移除它们。

运行 _移除 > 软件包_ 查看每一个已安装的软件包。然后你可以按 tab 选择任何你想要移除的软件包，并按 return 开始移除所有已选内容。

你也可以从 Omarchy 菜单使用 _移除 > 网页应用_ 移除任何你不想要的预装网页应用。

或者运行 _移除 > 预装应用_ 一次性扫除所有预装的额外项——网页应用、TUI 和可选应用程序。启动它们的快捷键也会随之消失，这样你就会得到一片干净的快捷键画布，可以在 `~/.config/hypr/bindings.lua` 里填入你自己的内容。

---

对于错误和损坏的部分，参见[故障排除部分](45-troubleshooting.md)。
