# FAQ

### 如何在键盘布局之间切换？

编辑你的 `~/.config/hypr/input.lua` 文件，并添加以下内容，以便用 `Left Alt + Right Alt` 在布局之间切换：

```
hl.config({
  input = {
    -- Use multiple keyboard layouts and switch between them with Left Alt + Right Alt
    kb_layout = "us,fr",
    kb_options = "omarchy:shift_caps_compose,grp:alts_toggle",
  },
})
```

一旦你配置了多个布局，状态栏会自动显示你当前的键盘布局（你也可以点击它来切换）。

### 如何将时钟格式改为 12 小时制？

右键单击状态栏中的时钟，可在常见格式之间循环切换，包括 12 小时制格式。你也可以直接设置格式：

```
omarchy bar set omarchy.clock format "dddd h:mm AP"
```

这将显示星期日 10:55 AM。

### 如何更改我的时区？

在 Omarchy 菜单中运行 _更新 > 时区_，并从列表中选择。如果时区正确但时钟本身已经漂移，_更新 > 时间_ 会为你重启时间同步。

### 如何更改我的 DNS、共享我的 Wi-Fi 或检查我的连接速度？

这些都在[网络](35-networking.md)中。

### 如何检查我的磁盘有多快？

_触发 > 速度测试 > 磁盘速度测试_ 可测量你的驱动器的实时读写速度，或者在终端中运行 `omarchy disk speedtest`。

### 如何添加打印机？

打印功能开箱即用，已经设置好并正在运行，你可以从应用启动器（`Super + Space`）中的 _打印设置_ 自行添加每一台打印机。

选择 _添加_，并给它一点时间查找：通过 USB 插入的打印机，以及大多数网络打印机，都会为你自动找到。如果你的打印机不在列表中，选择 _网络打印机 > Internet Printing Protocol (ipp)_ 并输入其地址——打印机自身的显示屏或其网页会告诉你该地址是什么，通常类似 `192.168.1.50`，队列为 `ipp/print`。随后 _下一步_ 会提供一个驱动程序，其中现代打印机使用无驱动的 _IPP Everywhere_ 配置效果最佳，而较旧的打印机则需要该型号自带的驱动程序。

右键单击打印机，选择 _设为默认_ 以选定你的应用优先使用哪一台，并选择 _属性_ 来设置纸张大小、双面打印和质量。

自动发现——即网络上的打印机无需添加即可出现——在重构期间暂时关闭，这就是为什么上面的第一步需要你自己完成，而不是自动完成。打印到 PDF 文件则完全不需要任何打印机。

### 如何更改截图或录屏的保存位置？

保存的截图默认去往 `~/Pictures/Screenshots`。要使用另一个目录，请将以下内容添加到 `~/.config/uwsm/env.d/` 下的一个文件中（例如 `~/.config/uwsm/env.d/capture`）：

```
export OMASNAP_SCREENSHOT_DIR="$HOME/Pictures/Captures"
```

你也可以对录屏做同样的操作，使用 `OMARCHY_SCREENRECORD_DIR`。

Omasnap 会自动创建其截图目录。录屏目录需要你自己创建，然后重启 Omarchy，任一环境更改才会生效。

### 如何让 Apple Studio Display 的扬声器 + 摄像头工作？

你可能会以为只需插入 USB C 就应该全部能工作，但遗憾的是并非如此。我找到的能让它可靠工作的解决方案是使用 [WJESOG DisplayPort + USB-A => USB-C 线缆](https://www.amazon.com/WJESOG-DisplayPort-Adapter-Converter-Thunderbolt/dp/B0BNX7MS6N/)。然后扬声器和摄像头就能完美工作了。

请记住，Omarchy 为 Apple Displays（包括 Studio 和 XDR）内置了亮度控制，使用常规的键盘亮度按钮即可。

### 如何摆脱所有多余的软件？

如果你不想要 Obsidian、LibreOffice 或其他任何预装的东西，你可以非常轻松地将其移除。

运行 _移除 > 软件包_ 可查看每一个已安装的软件包。然后你可以用 Tab 选择任何你想移除的软件包，并用 Return 开始移除你选择的所有内容。

你还可以使用 Omarchy 菜单中的 _移除 > Web 应用_ 来移除任何你不想要的预装 Web 应用。

或者运行 _移除 > 预装项_，一次性清扫所有预装的额外内容——Web 应用、TUI 和可选应用程序。启动它们的快捷键会随之消失，这样你就可以在 `~/.config/hypr/bindings.lua` 中用你自己的绑定来填补这块干净的白板。

---

如遇错误和故障，请参阅[故障排查章节](45-troubleshooting.md)。
