# 系统快照

每次 Omarchy 更新时，我们都会自动创建快照，但如果你想创建自己的快照，可以使用 `omarchy-snapshot create`。

要启动并恢复某个快照，你可以从 Limine 引导加载器中选择它。（如果你当前是直接启动进入 Omarchy 解密界面，你需要先通过 BIOS 选择 Limine 作为启动选项）。

在该界面中，根据日期和版本选择你想要启动进入的快照。快照创建时的 Omarchy 版本可以在左下角看到。

 ![snapshots-bootloader](images/snapshots-bootloader.webp)

进入系统后，会弹出一条通知，告诉你当前正处于可启动的快照中，点击它就会开始恢复过程。或者，你也可以使用 `omarchy-snapshot restore`。

 ![snapshots-restore](images/snapshots-restore.webp)

这会恢复你的根文件系统，但不会恢复你的 `/home`。所以它适用于撤销有问题的系统更新，但不适用于恢复丢失的个人文件。

这也意味着你的 `~/.config` 目录会保持原样。所以如果你回滚到某个库或应用程序的早期版本，而它们的配置文件使用了新格式，你就得自己手动处理了。

Omarchy 自己记录哪些迁移已经运行过的记录也是如此：它位于你的主目录中，所以恢复后它依然存在。在快照创建之后运行过的迁移仍会标记为已完成，即使它们对根文件系统所做的更改已经被回滚，下一次 `omarchy update` 也不会再次运行它们。所以如果你在恢复后再次更新，而某个早期更新原本应该设置好的东西仍然缺失，很可能就是这个原因。

_注意：此功能仅适用于使用 Limine 引导加载器的安装，自 Omarchy 2.0 起这已是默认设置。如果你使用的是 GRUB 或 systemd-boot，则无法使用此功能。_

### 跳过启动菜单

如果你从来不碰启动菜单，只想让机器直接进入解密界面，在 Omarchy 菜单中运行 _Setup > Direct Boot_。这会添加一个直接指向 Omarchy 的 EFI 条目，这样固件就会直接启动它，而不会停在 Limine。

代价就是开头提到的那个：开启直接启动后，要进入快照就得先从你的 BIOS 启动菜单中选择 Limine。再次运行 _Setup > Direct Boot_ 可以删除该条目，恢复通过 Limine 启动。有些固件对自定义 EFI 条目不太友好，所以该设置程序会拒绝在 American Megatrends 和 Apple 固件上运行。
