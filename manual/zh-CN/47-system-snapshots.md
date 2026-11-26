# 系统快照

我们会在每次 Omarchy 更新时自动创建快照，但如果你想自己创建，可以使用 `omarchy-snapshot create`。

你如何启动和恢复快照，取决于你的机器启动时使用的引导程序。新的 UEFI 安装使用 systemd-boot；旧的安装和 BIOS 机器使用 Limine。`omarchy-boot-backend` 会告诉你你用的是哪一个。

## 使用 systemd-boot 时

在 Omarchy 菜单中选择 _System > Snapshots_，然后选择你想启动进入的快照。机器会重启一次并进入它。或者在机器启动时按住 Space 查看启动菜单，其中每个快照都按从新到旧的顺序列出，并显示其 Omarchy 版本和日期。

快照启动时顶部会有一个临时层，所以你可以像平时一样使用它，但你所做的任何更改都会在下次重启时消失。要保留它，就把它设为你的系统：点击登录时出现的通知，选择 _System > Snapshots > Restore This Snapshot_，或运行 `omarchy-snapshot restore`。恢复会在机器重启时进行。恢复前的系统会以 _Before restore_ 的形式保留在启动菜单中，而 `omarchy-snapshot restore backup` 可以把它恢复回来。

从终端：

- `omarchy-snapshot list` 列出你可以启动的快照；
- `omarchy-snapshot boot 12` 重启一次并进入快照 12；
- `omarchy-snapshot restore 12` 在下次重启时将快照 12 设为系统，而 `omarchy-snapshot restore --cancel` 可以在那次重启之前让你改变主意。

## 使用 Limine 时

要启动和恢复快照，你需要从 Limine 引导程序中选择它。启动菜单默认保持隐藏，所以在 Limine 一启动时就按任意键将其调出。

在该界面中，根据日期和版本选择你想启动进入的快照。快照创建时的 Omarchy 版本可以在左下角看到。

 ![snapshots-bootloader](images/snapshots-bootloader.webp)

当你进入后，会弹出一个通知，告知你正处于一个可启动的快照中，如果你点击它，就会开始恢复过程。或者，你可以使用 `omarchy-snapshot restore`。

 ![snapshots-restore](images/snapshots-restore.webp)

## 恢复涵盖哪些内容

恢复会还原你的根文件系统，但不会还原你的 `/home`。所以它适用于撤销一次出问题的系统更新，但不适用于恢复丢失的个人文件。

这也意味着你的 `~/.config` 目录会保持原样。所以如果你回滚到某个库或应用程序的较早版本，而它以新格式存储配置文件，你就必须手动处理这个问题。

Omarchy 自己记录哪些迁移已经运行过的记录也是如此：它位于你的主目录中，所以会在恢复后保留。快照创建之后运行过的迁移会保持标记为已完成，尽管它们对根文件系统所做的更改已经回滚，而下一次 `omarchy update` 也不会再次运行它们。所以如果你在恢复后再次更新，而某次较早更新本应设置好的东西仍然缺失，这很可能就是原因。
