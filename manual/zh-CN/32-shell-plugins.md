# Shell 插件

Omarchy 桌面作为单个长期运行的 Quickshell 进程运行，名为 `omarchy-shell`，你在屏幕上看到的几乎一切都是其中的插件。栏是一个插件。从栏下拉的面板、全屏覆盖层（如表情选择器和剪贴板管理器）、Omarchy 菜单本身、锁定屏幕、polkit 对话框，以及监视你的电池并在夜间让屏幕变暖的无头服务也是。

这不仅仅是一个实现细节。这意味着你可以关闭桌面的某些部分、将它们换掉，或者编写你自己的，而无需触碰 Omarchy 源码的一行。

第一方插件随 Omarchy 附带，位于 `$OMARCHY_PATH/shell/plugins/`。你自己添加的任何东西——你自己的实验，或者你在 GitHub 上找到的东西——位于 `~/.config/omarchy/plugins/`。两者在启动时以相同方式被发现，但内置插件获得受信任的 shell 接口，而第三方插件获得限定于其自身服务和生命周期的有限接口。内置插件的克隆仅保留原始行为所需的源特定配置和 UI 调用。

## 查看你拥有的内容

```
omarchy plugin list
```

这会打印每个被发现的插件及其 id、是否启用、是第一方还是第三方、它的种类和它的显示名称。如果你要将它提供给其他东西，添加 `--json`。

插件 id 是有命名空间的。内置插件都以 `omarchy.` 开头——`omarchy.clock`、`omarchy.network`、`omarchy.notifications`——而且该命名空间是保留的，所以第三方插件永远无法占用它。

## 打开和关闭它们

```
omarchy plugin enable omarchy.tailscale
omarchy plugin disable omarchy.weather
```

或使用菜单：_Setup > Plugins_ 包含 Enable、Disable、Add、Clone 和 Remove，每个都带有一个选择器，只提供对该操作有意义的插件。

启用状态存储在 `~/.config/omarchy/shell.json` 中，且对于这两类插件规则略有不同。第三方插件正好在它的 id 出现在那个文件中的某处时被启用——作为栏布局条目、作为 `plugins[]` 中的条目，或作为 `bar.id`。不是栏小部件的第一方插件则相反：它们默认开启，只有被列在 `disabledPlugins[]` 中时才关闭。

完整的栏插件根本没有关闭状态。总是有且只有一个栏，所以你通过启用另一个来替换它。栏小部件的放置在[菜单栏](05-the-top-bar.md)中介绍。

## 从 git 添加插件

第三方插件只是一个在根目录有一个 `manifest.json` 的 git 仓库。

```
omarchy plugin add https://github.com/acme/omarchy-weather.git --enable
```

在做任何事情之前，它会直言不讳地告诉你插件作为任意、非沙盒代码在你的长期运行 shell 进程内运行，向你显示 URL，并要求你确认。认真对待这一点。第三方插件接口不直接暴露认证服务，替代栏仅获得已配置的非认证 UI 的有限能力。视觉插件仍然共享 shell 的 QML 场景，并且可以遍历普通的父对象，而所有插件代码都以你的用户账户可以访问的一切运行。认证状态通过将这些服务保持在可到达的主机对象图之外而得到单独保护。只添加你愿意运行的仓库，并在启用它们之前阅读它们。

替代栏可以渲染已安装的小部件，但服务支持的第三方小部件在那里可能功能减少，因为栏不被允许请求另一个插件的活动服务对象。如果这样的小部件需要其配套服务，切换回内置的 `omarchy.bar`。

然后它将仓库克隆到一个临时目录，验证清单，如果另一个插件已经占用那个 id 就拒绝安装，并将其移动到 `~/.config/omarchy/plugins/<id>/`。没有 `--enable` 时，它会询问你是否希望现在开启它，你可以说不，先去读代码。它从不运行插件中的任何东西，从不执行安装钩子，也从不要求 sudo——它克隆文件、检查清单，并通过 IPC 翻转一个位。

更新是对那个同一检出的快进拉取：

```
omarchy plugin update acme.weather
omarchy plugin update
```

没有 id 时，它会更新你拥有的每个 git 管理的插件。它在应用之前向你展示 diff，如果你有它无法快进越过的本地更改就拒绝更新，如果新修订未通过验证就回滚。

```
omarchy plugin remove acme.weather
```

删除会先禁用插件，然后如果它是 git 检出就删除它（仓库仍在上游），如果它是符号链接就解除链接。没有 git 仓库的手工制作插件文件夹会被移到插件目录内一个带时间戳的备份中，而不是被直接删除。

## 克隆内置插件以修改它

这是我最喜欢的部分。如果你想更改内置小部件的行为，不要编辑 `$OMARCHY_PATH` 下的文件——那些属于软件包，下一次更新会覆盖它们。取而代之克隆它：

```
omarchy plugin clone omarchy.clock
```

这会将整个插件复制到 `~/.config/omarchy/plugins/dhh.clock`（你的用户名，不是我的），将其重命名为 "My Clock"，启用它，并将 shell 从内置插件切换到你的副本——保留现有栏小部件的位置和设置。添加 `--edit` 立即在你的 `$EDITOR` 中打开新目录，这正是菜单中的 _Setup > Plugins > Clone Plugin_ 为你做的事情。

用户名前缀让你的克隆的 id 保持为你的，所以分享它不会与任何其他人的冲突。对原始内置 id 的调用会被路由到你的克隆，所以引用了 `omarchy.clock` 的任何东西都不需要更新。如果你把它弄乱了，`omarchy plugin remove dhh.clock` 会把内置插件放回来。

在 `~/.config/omarchy/plugins/` 下任何地方保存文件会自动重新加载插件代码，所以你可以让编辑器开着，看着你的更改生效。

## 编写你自己的插件

插件是一个带有 `manifest.json` 和一些 QML 的目录。清单声明 `schemaVersion: 1`、一个 `id`、`name`、`version`、一种或多种 `kinds`，以及一个 `entryPoints` 对象，为每种 kind 指向 QML 文件：

| Kind | What it is |
|------|------------|
| `bar-widget` | 活动栏可以放入一个区段的组件 |
| `panel` | 持久或唤起的浮动窗口 |
| `overlay` | 全屏覆盖层 |
| `menu` | 唤起的菜单界面 |
| `service` | 没有 UI 的无头单例 |
| `bar` | 替代内置栏的完整栏 |

插件可以同时声明多种类型——媒体插件既是 `service` 又是 `bar-widget`。栏小部件会获得一个额外的 `barWidget` 块，包含显示名称、类别、可选的 `defaultSection` 和 `allowMultiple`，后者表示在栏上放多个是否有意义。大多数小部件将其设为 `false`；间隔符和指示器将其设为 `true`。

在发布任何东西之前，检查它：

```
omarchy plugin validate ./my-plugin
```

这会运行 shell 在加载时做的相同检查：架构版本、必需字段、未被保留的 id、安全相对路径且确实存在的入口点、你声明的每个 kind 都有一个入口点，以及文件夹内任何地方都没有符号链接。

有关插件开发，请参阅 [shell 参考](https://github.com/omacom/omarchy/blob/quattro/docs/omarchy-shell.md) 和[第一方插件目录](https://github.com/omacom/omarchy/blob/quattro/shell/plugins/README.md)。

## 与全世界分享你的插件

一旦你做出了喜欢的东西，把它放到一个公开的 git 仓库里。这就是整个分发机制——任何人都可以对你的 URL 运行 `omarchy plugin add`，并在几秒钟内运行它。

为了帮助人们真正找到它，在 [plugins.omarchy.org](https://plugins.omarchy.org) 上列出它。这是 Omarchy shell 插件的市场，当你在想是否有人已经构建了你即将要写的小部件时，这是首先要看的地方。在开始之前浏览它！
