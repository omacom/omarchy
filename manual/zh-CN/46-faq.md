# 常见问题解答

### 如何切换键盘布局？

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

一旦你配置了多个布局，状态栏就会自动显示你当前的键盘布局（你也可以点击它来切换）。

### 如何将时钟格式改为 12 小时制？

右键点击状态栏中的时钟，可在常用格式之间循环切换，包括 12 小时制格式。你也可以直接设置格式：

```
omarchy bar set omarchy.clock format "dddd h:mm AP"
```

这将显示为星期日 10:55 AM。

### 如何更改我的时区？

在 Omarchy 菜单中运行 _设置 > 区域 > 时区_，并从列表中选择。如果时区正确，但时钟本身已经漂移，_更新 > 时间_ 会为你重启时间同步。

### 如何更改我的 DNS、共享我的 Wi-Fi 或检查我的连接速度？

这些都位于[网络](35-networking.md)中。

### 如何检查我的磁盘速度有多快？

_触发 > 速度测试 > 磁盘速度测试_ 可以实时测量你驱动器上的读取和写入速度，或者在终端中运行 `omarchy disk speedtest`。

### 如何添加打印机？

打印功能开箱即已设置好并正在运行，你可以在应用启动器（`Super + Alt + Space`）中从 _打印设置_ 自行添加每台打印机。

选择 _添加_，并给它一点时间查找：通过 USB 插入的打印机以及大多数网络打印机都会为你找到。如果你的打印机不在列表中，请选择 _网络打印机 > Internet Printing Protocol (ipp)_ 并输入其地址——打印机自身的显示屏或其网页会告诉你那是什么，通常类似 `192.168.1.50`，队列为 `ipp/print`。然后 _下一步_ 会提供一个驱动程序，其中现代打印机使用无驱动的 _IPP Everywhere_ 配置文件效果最佳，而较旧的打印机则需要该型号自带的驱动程序。

右键点击打印机并选择 _设为默认_，以选择你的应用优先使用哪一台，并选择 _属性_ 来设置纸张大小、双面打印和质量。

自动发现（即网络上的打印机无需添加即可出现）目前暂时关闭，正在重新改造，这就是为什么上面的第一步需要你自己完成，而不是自动完成。打印到 PDF 文件则完全不需要任何打印机。

### 如何更改截图或录屏的保存位置？

默认情况下，保存的截图会存到 `~/Pictures/Screenshots`。要使用另一个目录，请将以下内容添加到 `~/.config/uwsm/env.d/` 下的一个文件中（如 `~/.config/uwsm/env.d/capture`）：

```
export OMASNAP_SCREENSHOT_DIR="$HOME/Pictures/Captures"
```

你也可以使用 `OMARCHY_SCREENRECORD_DIR` 对录屏做同样的操作。

Omasnap 会自动创建其截图目录。录屏目录请自行创建，然后重启 Omarchy，让任一环境更改生效。

### 如何让我的 Apple Studio Display 上的扬声器 + 摄像头正常工作？

你会以为只要插上 USB C 就应该一切正常，但遗憾的是并非如此。我发现能让它可靠工作的方法是使用 [WJESOG DisplayPort + USB-A => USB-C 线缆](https://www.amazon.com/WJESOG-DisplayPort-Adapter-Converter-Thunderbolt/dp/B0BNX7MS6N/)。然后扬声器和摄像头就运转得无比顺畅。

请记住，Omarchy 为 Apple Displays（Studio 和 XDR 均包括在内）内置了亮度控制，使用常规的键盘亮度按钮即可。

### 如何去掉所有多余的软件？

如果你不想要 Obsidian 或 LibreOffice 等程序，或任何其他预装的东西，你可以非常轻松地将其移除。

运行 _移除 > 软件包_ 可查看已安装的每一个软件包。然后你可以用 tab 选择任何你想要移除的软件包，并用 return 开始移除你选中的所有内容。

你也可以使用 Omarchy 菜单中的 _移除 > Web 应用_ 来移除任何你不想要的预装 Web 应用。

或者运行 _移除 > 预装软件_，一次性扫除所有预装的额外内容——Web 应用、TUIs 和可选应用程序。启动它们的热键也会随之消失，因此你会得到一份干净的绑定空白清单，可以在 `~/.config/hypr/bindings.lua` 中填入你自己的绑定。

---

如需处理错误和损坏的部分，请参见[故障排除部分](45-troubleshooting.md)。
