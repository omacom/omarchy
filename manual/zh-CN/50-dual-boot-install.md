# 双启动安装

你可以将 Omarchy 安装到单个分区上，与 Windows 或其他系统并存。

这种安装方式默认仍为该分区提供 LUKS 加密，因此它实际上与整盘安装没有区别，只是要求磁盘上有可用的空闲空间。

## 在 Windows 上腾出空间

要与 Windows 并存安装，请在开始菜单中输入 `disk management`，然后选择 **创建并格式化硬盘分区** 选项。

 ![dual-boot-1](images/dual-boot-1.webp)

找到合适的分区，右键单击，然后选择 **压缩卷**。

![dual-boot-2](images/dual-boot-2.webp)

 输入你想要压缩的容量。请注意，这将是你未来 Omarchy 安装的大小，其中包含启动分区。

 ![dual-boot-3](images/dual-boot-3.webp)

完成后，你应该会看到类似这样的界面，在本示例中，50GB 的部分就是我们将要安装 Omarchy 的位置。

 ![dual-boot-4](images/dual-boot-4.webp)

## 安装 Omarchy

Omarchy 的安装过程与正常安装基本相同。选择磁盘后，你会看到 **空闲空间安装** 选项。选择该选项可防止抹除整个磁盘。

 ![dual-boot-5](images/dual-boot-5.webp)

确认一切无误，然后像平常一样等待安装完成。在这里，你也可以像整盘安装时一样选择不加密安装（不推荐）。
 ![dual-boot-6](images/dual-boot-6.webp)

## 将其他系统添加到引导加载程序

完成 Omarchy 安装后，你会注意到 Limine 引导加载程序现在是默认引导程序。有了它，你还可以为其他系统（如 Windows）向 Limine 中添加选项。

要添加其他操作系统，请运行 `limine-scan`，并按照提示将你想要的条目添加到 Limine 配置中。引导菜单默认保持隐藏，并会在一秒后启动 Omarchy。要选择 Windows 或其他条目，请在 Limine 启动后立即按任意键；当菜单出现时，使用方向键选择一个条目并按 Enter。如果 Omarchy 在你按键之前就已启动，请重启并重试。如果你开启了 _Setup > Direct Boot_，固件会完全跳过 Limine，因此请从 BIOS 引导菜单中选择 Limine，或者再次运行 _Setup > Direct Boot_ 以移除该条目。

## Bitlocker

需要注意的是，这种安装方式与 Bitlocker 不兼容，因为它加密的是整个驱动器，而不仅仅是分区。如果你遇到提示 Bitlocker 已启用的错误，请启动到 Windows，进入 **设置 -> 隐私和安全性 -> 设备加密**，然后关闭 Bitlocker。解密驱动器可能需要一些时间。

 ![dual-boot-7](images/dual-boot-7.webp)
