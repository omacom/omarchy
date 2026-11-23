# Windows VM

Omarchy 提供了一种简单的方法，可以在 x86_64 机器上通过 Docker VM 运行 Windows。你可以从 Omarchy 菜单（`Super + Space`）中使用 _Install > Windows_ 来安装它。

你的机器需要 KVM 虚拟化支持，大多数机器都有——但它有时会在 BIOS 中被关闭，如果是这种情况，安装程序会告诉你。你还需要磁盘空间：你分给 Windows 的空间，再加上大约 10GB 用于镜像本身。

安装程序会询问要分配多少 RAM、多少个 CPU 核心和多少磁盘空间（64GB 或更多是合理的下限），然后询问 Windows 用户名和密码。将它们留空，你就会得到 `docker` / `admin`。下载需要一段时间——10-15 分钟很正常——你可以在浏览器中通过 `http://127.0.0.1:8006` 查看进度。在打开控制台之前，浏览器会提示输入相同的用户名和密码。

 ![windows-vm](images/windows-vm.webp)

## 使用方法

安装完成后，从应用启动器启动 _Windows_。这会启动 VM（如果它尚未运行），并通过 RDP 以全屏方式将你连接进去。冷启动时给它 15-30 秒。

RDP 会话会传输声音、你的麦克风和共享剪贴板，因此在 Linux 和 Windows 之间复制文本直接就能用。分辨率会跟随你的窗口，Omarchy 还会传递你的显示缩放设置，因此在 HiDPI 屏幕上不会糊成一团。

当你关闭 RDP 窗口时，VM 会自动关机。如果你更希望让它继续运行——比如里面有东西正在工作——请改用 `omarchy windows vm launch --keep-alive` 来启动它。

其余控制都在同一个命令上：

```bash
omarchy windows vm status    # is it running?
omarchy windows vm stop      # shut it down
omarchy windows vm launch    # start and connect
```

## 共享文件

你的主目录中的 `~/Windows` 目录会自动与 VM 共享。把文件放在那里，就能让 Windows 访问它们。VM 无权访问你文件系统的任何其他部分，因此你不用担心 Windows 那边有什么恶意东西。它自己的虚拟磁盘位于 `~/.windows`。

这些熟悉的主目录路径各自保留在自己的文件系统上。它们也可以是指向你自己拥有的目录的符号链接，当虚拟磁盘位于容量更大的驱动器上时，这很有用。安装程序测量的是实际包含 `~/.windows` 的文件系统上的可用空间，而不一定是包含你的主目录的文件系统。

请将磁盘路径和共享路径保持为独立、不重叠的目录。删除操作会有意清空磁盘目录，但保留共享目录。就在删除之前，Omarchy 会执行一次受限的包含范围检查，如果该检查超时，或无法证明这两棵目录树彼此独立，就会拒绝删除任何内容。

在 VM 启动之前，Omarchy 会打开并固定这两个目录，然后将确切的目录 inode 绑定挂载到 `/var/lib/omarchy/windows/mounts` 下的每用户私有锚点上。Docker 只能看到那些受 root 保护的锚点。这样既保留了自定义磁盘位置，也能防止以你的身份运行的另一个进程在特权容器使用已检查的路径之前将其替换掉。在迁移期间，现有磁盘目录和共享目录的权限会被收紧为模式 `0700`，这样其他本地账户就无法浏览其中的内容。

VM 的端口仅绑定到 localhost，因此你网络上的任何东西都无法访问这台 Windows 机器。Web 控制台还要求输入已配置的 Windows 用户名和密码，从而防止另一个本地账户通过 8006 端口操控 VM。

## 限制与许可

此设置没有 GPU 直通，因此不适合游戏或视频编辑。它是运行 Microsoft Office 或其他你非用不可的东西的好方法。

安装的版本是未激活的 Windows 11 Pro。你需要自己的许可证密钥才能使用那些受许可限制的功能。

如果这台电脑出厂时预装了 Windows，即使安装了 Omarchy，OEM 密钥仍保留在固件中。使用 `omarchy windows key` 打印它。该密钥与这台机器绑定——它可以激活在这台硬件上重新安装的 Windows，但通常无法激活 VM。

你之后可以通过在终端中运行 `omarchy windows vm install` 来更改资源分配，它会根据你的回答重写 VM 的配置。compose 文件本身现在位于 `/var/lib/omarchy/windows/docker-compose.yml`，并归 root 所有——这是故意的，这样以你的身份运行的进程就无法重写它，并让特权启动过程将你的整个磁盘挂载进容器。如果你需要手动编辑它（例如挂载一个 USB 设备），请使用 `sudo` 编辑它，并在 [Dockur Windows 项目](https://github.com/dockur/windows) 上查看所有选项。

要彻底删除它，请从 Omarchy 菜单中使用 _Remove > Windows_。这会删除 `~/.windows` 中的 VM 磁盘以及 Windows 内部安装的所有内容，因此请先将你需要的任何东西从 VM 中复制出来。你共享的 `~/Windows` 文件夹不会被动。
