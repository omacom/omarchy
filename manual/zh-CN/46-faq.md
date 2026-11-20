# 常见问题

### 如何在键盘布局之间切换？

编辑你的 `~/.config/hypr/input.lua` 文件，并添加以下内容，即可使用 `Left Alt + Right Alt` 在布局之间切换：

```
hl.config({
  input = {
    -- Use multiple keyboard layouts and switch between them with Left Alt + Right Alt
    kb_layout = "us,fr",
    kb_options = "omarchy:shift_caps_compose,grp:alts_toggle",
  },
})
```

配置多个布局后，状态栏会自动显示你当前的键盘布局（你也可以点击它进行切换）。

### 如何将时钟格式更改为 12 小时制？

右键点击状态栏中的时钟，即可循环切换常见格式，包括 12 小时制格式。你也可以直接设置格式：

```
omarchy bar set omarchy.clock format "dddd h:mm AP"
```

这将显示为星期日 10:55 AM。

### 如何更改我的时区？

在 Omarchy 菜单中运行 _Setup > Region > Timezone_，然后从列表中选择。如果时区正确，但时钟本身出现了偏移，_Update > Time_ 会为你重启时间同步。

### 如何更改我的 DNS、共享我的 Wi-Fi 或检查我的连接速度？

这些都在[网络](35-networking.md)中。

### 如何检查我的磁盘速度有多快？

_Trigger > Speed Test > Disk Speed Test_ 会实时测量你的驱动器的读取和写入速度，或者从终端运行 `omarchy disk speedtest`。

### 如何添加打印机？

打印功能已经开箱即用地设置好并正在运行，你可以从应用启动器（`Super + Space`）中的 _Print Settings_ 自行添加每台打印机。

选择 _Add_，并给它一点时间进行查找：通过 USB 连接的打印机，以及大多数网络打印机，都会自动为你找到。如果你的打印机不在列表中，选择 _Network Printer > Internet Printing Protocol (ipp)_ 并输入它的地址——打印机自身的显示屏或它的网页会告诉你那是什么，通常类似 `192.168.1.50`，队列为 `ipp/print`。然后 _Forward_ 会提供一个驱动程序，其中现代打印机使用免驱动程序的 _IPP Everywhere_ 配置文件效果最好，而较旧的打印机需要该型号自带的驱动程序。

右键点击打印机并选择 _Set as Default_，可选择你的应用首先使用哪一台，选择 _Properties_ 可设置纸张大小、双面打印和质量。

自动发现功能，即网络上的打印机无需添加即可出现，在重做期间已暂时关闭，这就是为什么上面的第一步需要你自己完成而不是自动完成的原因。打印到 PDF 文件完全不需要任何打印机也可以完成。

### 如何更改截图或屏幕录制的保存位置？

保存的截图默认进入 `~/Pictures/Screenshots`。要使用另一个目录，请将以下内容添加到 `~/.config/uwsm/env.d/` 下的文件中（比如 `~/.config/uwsm/env.d/capture`）：

```
export OMASNAP_SCREENSHOT_DIR="$HOME/Pictures/Captures"
```

你也可以使用 `OMARCHY_SCREENRECORD_DIR` 对屏幕录制做同样的事情。

Omasnap 会自动创建它的截图目录。你自己创建屏幕录制目录，然后重启 Omarchy，任何一个环境更改都会生效。

### 如何让我的 Apple Studio Display 上的扬声器 + 摄像头正常工作？

你以为只要插上 USB C 一切就应该能工作，但遗憾的是情况并非如此。我发现的能让它可靠工作的解决方案是使用[WJESOG DisplayPort + USB-A => USB-C 线缆](https://www.amazon.com/WJESOG-DisplayPort-Adapter-Converter-Thunderbolt/dp/B0BNX7MS6N/)。然后扬声器和摄像头就能完美地工作。

请记住，Omarchy 为 Apple 显示器（Studio 和 XDR 两者都有）内置了亮度控制，使用常规的键盘亮度按钮即可。

### 如何移除所有额外的软件？

如果你不想要 Obsidian 或 LibreOffice 或任何其他预装的东西等程序，你可以非常轻松地移除它。

运行 _Remove > Package_ 来查看每一个已安装的软件包。然后你可以用 tab 选择任何你想移除的软件包，并用 return 开始移除你已选择的一切。

你也可以使用 Omarchy 菜单中的 _Remove > Web App_ 来移除任何你不想要的预装 Web 应用。

或者运行 _Remove > Preinstalls_，一次性扫除所有预装的额外内容——Web 应用、TUI 和可选应用程序。启动它们的快捷键会随之消失，因此你将得到一份干净的绑定清单，可以在 `~/.config/hypr/bindings.lua` 中用你自己的绑定来填满它。

---

有关错误和损坏的部分，请参阅[故障排查部分](45-troubleshooting.md)。
