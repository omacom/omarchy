# 系统快照

我们每次更新 Omarchy 时都会自动创建快照，但如果你想创建自己的快照，你可以使用 `omarchy-snapshot create`。

要启动并恢复快照，你从 Limine 引导程序中选择它。（如果你目前直接启动到 Omarchy 解密屏幕，你需要先通过 BIOS 将 Limine 选为启动选项）。

从该屏幕，根据日期和版本选择你想要启动的快照。快照生成时的 Omarchy 版本可以在左下角看到。

 ![snapshots-bootloader](images/snapshots-bootloader.webp)

当你到达内部后，会弹出一个通知，告诉你正在一个可启动的快照中，如果你点击它，会启动恢复过程。或者，你可以使用 `omarchy-snapshot restore`。

 ![snapshots-restore](images/snapshots-restore.webp)

这将恢复你的根文件系统，但不是你的 `/home`。所以它适用于还原一次损坏的系统更新，但不适用于恢复丢失的个人文件。

这也意味着你的 `~/.config` 目录保持原样。所以如果你回滚到了某个以新格式存储配置文件的库或应用程序的早期版本，你将必须手动处理这一问题。

_注意：此功能仅在那些使用 Limine 引导程序的安装中可用，该引导程序自 Omarchy 2.0 以来已成为默认选项。如果你使用的是 GRUB 或 systemd-boot，则不可用。_

### 跳过启动菜单

如果你从不碰启动菜单，只是想让机器直接进入解密屏幕，在 Omarchy 菜单中运行 _设置 > 直接启动_。这会添加一个直接指向 Omarchy 的 EFI 条目，这样固件就会绕过 Limine 直接启动它。

代价是顶部提到的那个：直接启动开启后，要到达快照意味着先从你的 BIOS 启动菜单中选择 Limine。再次运行 _设置 > 直接启动_ 即可移除该条目并回到通过 Limine 启动。有些固件不喜欢自定义 EFI 条目，所以设置过程会拒绝在 American Megatrends 和 Apple 固件上运行。
