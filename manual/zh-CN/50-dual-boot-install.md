# 双启动安装

你可以将 Omarchy 安装到一个单独的分区上，与 Windows 或其他安装共存。

此安装方法默认仍为该分区提供 LUKS 加密，所以它实际上与全盘安装没有区别，只需磁盘上有可用空间即可。

## 在 Windows 上腾出空间

要在 Windows 旁边安装，在开始菜单中输入 `disk management` 并选择 **Create and format hard disk partitions** 选项。

 ![dual-boot-1](images/dual-boot-1.webp)

找到适当的分区，右键点击，并选择 **Shrink Volume**。

![dual-boot-2](images/dual-boot-2.webp)

 输入你希望卷缩减的量。请注意，这将是你未来 Omarchy 安装的大小，包括启动分区。

 ![dual-boot-3](images/dual-boot-3.webp)

当你完成后，你应该会看到类似这样的界面，其中 50GB 部分是本示例中我们安装 Omarchy 的位置。

 ![dual-boot-4](images/dual-boot-4.webp)

## 安装 Omarchy

Omarchy 的安装过程实际上与正常情况相同。在你选择磁盘后，你会看到 **Free space install** 选项。选择该选项以防止擦除整个磁盘。

 ![dual-boot-5](images/dual-boot-5.webp)

确认一切看起来正常，并等待安装完成，与正常情况一样。你也可以在此处选择安装为未加密（不推荐），就像在全盘安装中一样。
 ![dual-boot-6](images/dual-boot-6.webp)

## 将其他安装添加到引导程序

当你完成 Omarchy 安装时，你会注意到 Limine 引导程序现在是默认引导程序了。有了它，你还可以向 Limine 添加其他安装（如 Windows）的选项。

为此，运行 `limine-scan` 并按照提示将任何你想要的项目添加到你的 limine 配置中。然后当你启动时，你会看到正常的 Omarchy 选项，以及 Windows Boot Manager 或其他。

## Bitlocker

需要注意的是，此安装方法与 Bitlocker 不兼容，因为它加密的是整个驱动器，而不仅仅是分区。如果遇到指出 Bitlocker 已启用的错误，请启动到 Windows，前往 **Settings -> Privacy & Security -> Device encryption** 并关闭 Bitlocker。解密驱动器可能需要一些时间。

 ![dual-boot-7](images/dual-boot-7.webp)
