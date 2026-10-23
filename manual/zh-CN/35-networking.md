# 网络

Omarchy 的网络由 NetworkManager 处理，你可以通过[菜单栏](05-the-top-bar.md)中的网络图标或使用 `Super + Ctrl + W` 来操作它。

该面板会扫描 Wi-Fi 网络、显示信号强度并进行连接。以太网完全不需要任何操作——插上就能用。如果你更愿意待在终端里，`nmtui` 提供了相同的控制功能，还有 `omarchy network` 命令组可用。

## 分享你的 Wi-Fi

与其大声读出长长的密码，不如在连接 Wi-Fi 时运行 _设置 > 网络 > QR 码_。这会在屏幕上显示一个 QR 码，任何手机摄像头都可以扫描加入。一旦知道它在那里，你会比预想的更频繁地使用这个功能。

如果你确实需要密码本身，`omarchy network password <interface>` 会打印它。

## DNS

Omarchy 使用你的网络通过 DHCP 分发的 DNS。你可以在 _设置 > 网络 > DNS_ 里为整台机器覆盖这一设置，Cloudflare 和 Google 都只需点一下即可。选择 _自定义_ 输入你自己的服务器。

在终端中，`omarchy dns` 会打印当前的提供商，`omarchy dns Cloudflare` 则设置一个提供商。

## 固定 Wi-Fi 频段

如果你的路由器将 2.4GHz、5GHz 和 6GHz 放在同一个网络名称下，你的笔记本电脑有时会固守在慢的那个频段上。`omarchy network band` 会显示你当前所在的频段，`omarchy network band 5` 会将其固定。使用 `auto` 可以让它重新自行选择。

它固定的是频段而不是特定的接入点，所以你仍能正常在各个 AP 之间漫游。

## 有多快？

_触发 > 测速 > 网络测速_ 会用一对表盘测量你的实际上传和下载速度。在终端中则是 `omarchy network speedtest down` 或 `up`。（该菜单里旁边还有一个磁盘测速，如果你要测试另一个瓶颈的话。）

## 防火墙

防火墙默认开启并阻止所有入站流量，只有一个例外：端口 53317，这样 [LocalSend](22-guis.md) 开箱即用。

SSH 在你通过 _设置 > 安全 > SSHD_ 开启之前是关闭的，开启后会启动守护进程，打开对暴力破解限速的端口 22，并授权一个密钥。Docker 也被锁定，这样容器就不会意外暴露给外界。完整说明参见[安全](48-security.md)。

## Tailscale

[Tailscale](https://tailscale.com/) 是一个网状 VPN，让通过互联网访问你所有的电脑和服务器变得简单而安全。通过 _安装 > 服务 > Tailscale_ 安装它。

这会在栏中给你一个 Tailscale 面板，它可以连接和断开 tailnet、切换账户并选择出口节点——你自己的机器和 Mullvad 区域都会出现在列表中。它还能浏览你的机器，而这正是 Taildrop 所在之处：选择一台机器并按下 `s` 向它发送文件，或按 `c`、`n` 和 `d` 复制其 IP、名称或完整 DNS 名称。终端等价命令是 `omarchy tailscale send <machine> [file...]`，发送给你的文件会自动落入 `~/Downloads`。宣布文件到达的通知会等到你点击打开或将其关闭，所以当你离开机器时到达的文件在你回来时仍然在那里等待处理。

安装它还会添加一个用于 Tailscale 管理控制台的网页应用。

## 当它停止工作时

在重启之前，试着单独重启出问题的那部分。_更新 > 硬件_ 有 Wi-Fi、Bluetooth、音频和触控板，重新加载其中之一能解决大多数“五分钟前还好好的”情况。参见[故障排除](45-troubleshooting.md)。
