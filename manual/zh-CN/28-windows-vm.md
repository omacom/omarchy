# Windows 虚拟机

Omarchy 提供了一种通过 Docker 虚拟机运行 Windows 的简便方法。你可以使用 Omarchy 菜单（`Super + Space`）中的 _Install > Windows_ 安装它。

你的机器需要为此提供 KVM 虚拟化，大多数机器都有——但它有时在 BIOS 中被关闭，安装程序会告诉你是否是这种情况。你还需要磁盘空间：你给 Windows 的空间，外加约 10GB 的镜像本身。

安装程序会询问你要分配多少内存、多少 CPU 核心和多少磁盘（64GB 或更多是合理的下限），然后询问 Windows 用户名和密码。将这些留空，你会得到 `docker` / `admin`。下载需要一段时间——10-15 分钟是正常的——你可以在浏览器中跟踪进度，地址为 `http://127.0.0.1:8006`. 浏览器在打开控制台前会提示相同的用户名和密码。

 ![windows-vm](images/windows-vm.webp)

## 使用它

安装后，从应用程序启动器启动 _Windows_。这会启动虚拟机（如果它还没有运行的话）并通过 RDP 全屏连接你。冷启动给它 15-30 秒。

RDP 会话携带声音、你的麦克风和共享剪贴板，所以在 Linux 和 Windows 之间复制文本可以直接工作。分辨率跟随你的窗口，Omarchy 会将你的显示缩放传递过去，所以它在 HiDPI 屏幕上不会是一团模糊。

当你关闭 RDP 窗口时，虚拟机会自动关闭。如果你更愿意让它保持运行——比如里面有什么东西在运行——改用 `omarchy windows vm launch --keep-alive` 启动它。

其余的控件都在同一个命令上：

```bash
omarchy windows vm status    # is it running?
omarchy windows vm stop      # shut it down
omarchy windows vm launch    # start and connect
```

## 共享文件

你主目录中的 `~/Windows` 目录会自动与虚拟机共享。将文件放在那里，如果你希望它们能被 Windows 访问。虚拟机无法访问你的文件系统的任何其他部分，所以你不受 Windows 端任何恶意东西的威胁。它自己的虚拟磁盘在 `~/.windows` 处可用。

那些熟悉的主目录路径保留在它们自己的文件系统上。它们也可以是指向你拥有的目录的符号链接，当虚拟磁盘位于更大的驱动器上时这很有用。安装程序测量实际包含 `~/.windows` 的文件系统上的可用空间，而不一定是包含你主目录的文件系统。

使磁盘和共享路径保持为独立、不重叠的目录。删除会故意清空磁盘目录，但保留共享目录。在删除之前，Omarchy 会执行一次有界的包含检查，如果该检查超时或无法证明这两棵树是分开的，它会拒绝删除任何东西。

在虚拟机启动之前，Omarchy 会打开并固定这两个目录，然后将确切的目录 inode 绑定挂载到 `/var/lib/omarchy/windows/mounts` 下的私有每用户锚点上。Docker 只能看到那些受 root 保护的锚点。这保留了自定义磁盘位置，同时防止另一个以你身份运行的进程在特权容器使用之前交换已检查的路径。现有的磁盘和共享目录在迁移期间会被收紧为 `0700` 模式，这样其他本地账户无法浏览它们的内容。

虚拟机的端口仅绑定到 localhost，所以你的网络上的任何东西都无法访问 Windows 机器。Web 控制台还需要配置的 Windows 用户名和密码，防止另一个本地账户通过 8006 端口驱动虚拟机。

## 限制和许可

此设置没有 GPU 直通，所以它不适合游戏或视频编辑。这是运行 Microsoft Office 或其他你绝对必须拥有的东西的好方法。

安装的版本是 Windows 11 Pro，未激活。你需要自己的许可证密钥才能使用受限功能。

如果这台电脑随附 Windows，即使在安装 Omarchy 之后，OEM 密钥仍在固件中。用 `omarchy windows key` 打印它。该密钥与这台机器绑定——它将激活在此硬件上重新安装的 Windows，但它通常不会激活虚拟机。

你之后可以通过重新运行 `omarchy-windows-vm install` 更改资源分配，它会根据你的答案重写虚拟机的配置。compose 文件本身现在位于 `/var/lib/omarchy/windows/docker-compose.yml` 并归 root 所有——这是故意的，这样以你身份运行的进程无法重写它并让特权启动将你的整个磁盘挂载到容器中。如果你需要手动编辑它（例如挂载 USB 设备），用 `sudo` 编辑它并在 [Dockur Windows 项目](https://github.com/dockur/windows)上查看所有选项。

要彻底删除它，使用 Omarchy 菜单中的 _Remove > Windows_。这会删除虚拟机的磁盘及其所有数据，所以先确保任何你在乎的东西都已从 `~/Windows` 中移出。
