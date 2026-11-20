# 双启动安装

你可以将 Omarchy 安装到单个分区，与 Windows 或其他已安装的系统并存。

这种安装方式默认仍为该分区提供 LUKS 加密，因此实际上与全盘安装没有区别，只是要求磁盘上有可用的空闲空间。

## 在 Windows 上腾出空间

要与 Windows 并存安装，在开始菜单中输入 `disk management`，并选择 **创建并格式化硬盘分区** 选项。

 ![dual-boot-1](images/dual-boot-1.webp)

找到合适的分区，右键单击，并选择 **压缩卷**。

![dual-boot-2](images/dual-boot-2.webp)

 输入你想要压缩的容量。注意，这将是你未来 Omarchy 安装的大小，包含启动分区。

 ![dual-boot-3](images/dual-boot-3.webp)

完成后，你应该会看到类似这样的界面，其中 50GB 的部分就是本例中我们将安装 Omarchy 的位置。

 ![dual-boot-4](images/dual-boot-4.webp)

## 安装 Omarchy

Omarchy 的安装过程实际上与正常安装相同。选择磁盘后，你会看到 **空闲空间安装** 选项。选择该选项，以防止擦除整个磁盘。

 ![dual-boot-5](images/dual-boot-5.webp)

确认一切无误，然后像平常一样等待安装完成。在这里，你也可以选择不加密安装（不推荐），就像全盘安装一样。
 ![dual-boot-6](images/dual-boot-6.webp)

## 将其他系统添加到引导加载程序

完成 Omarchy 安装后，你会注意到 Limine 引导加载程序现在是默认引导。你还可以通过它为 Windows 等其他已安装的系统添加 Limine 选项。

要添加其他操作系统，运行 `limine-scan`，并按照提示将所需条目添加到你的 Limine 配置中。引导菜单默认保持隐藏，并在一秒后启动 Omarchy。要选择 Windows 或其他条目，在 Limine 启动时立即按任意键；菜单出现后，使用方向键选择条目并按 Enter。如果 Omarchy 在你按键之前已经启动，重启后再试一次。

## Bitlocker

需要注意的是，这种安装方式与 Bitlocker 不兼容，因为它加密的是整个驱动器，而不仅仅是分区。如果遇到提示 Bitlocker 已启用的错误，启动进入 Windows，进入 **设置 -> 隐私和安全性 -> 设备加密**，并关闭 Bitlocker。解密驱动器可能需要一些时间。

 ![dual-boot-7](images/dual-boot-7.webp)
