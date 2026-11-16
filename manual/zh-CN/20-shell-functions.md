# Shell 函数

Omarchy 自带一组 shell 函数，用于简化常见任务并封装复杂的参数调用。

## 压缩

- `compress [file/dir]`：从文件/目录创建 tar.gz 归档。
- `decompress [file.tar.gz]`：解压 tar.gz 文件。

## 驱动器

- `iso2sd [image.iso]`：使用引用的 iso 文件并以交互方式选择驱动器，在 SD 卡上创建可启动驱动器。
- `format-drive [device] [name]`：将整个磁盘格式化为单个 exFAT 分区（在 Windows 和 macOS 上也能用）。不带参数运行可查看可用驱动器。小心！

## 开发布局

Tmux 的即时多窗格开发布局：

- `tdl [ai]`：创建一个 Tmux Dev Layout，包含你的编辑器、一个 AI 智能体和一个终端。使用智能体别名，如 `tdl c` 表示 opencode 或 `tdl cx` 表示 Claude Code，或传入第二个智能体同时运行，如 `tdl c cx`。
- `tds`：创建一个 Tmux Dev Square，包含编辑器、diff 监视（通过 `hunk diff --watch`）、终端和 opencode。
- `tdlm [ai]`：为当前目录中的每个子目录创建一个 `tdl` 窗口。
- `tsl [count] [command]`：创建一组以网格平铺的窗格，全部运行相同的命令（非常适合 AI 智能体）。

同样的布局在 Herdr 中对应 `hdl`、`hds`、`hdlm` 和 `hsl`。

## Git 工作树

- `ga [branch]`：在当前仓库旁边创建一个新的工作树和分支并跳入其中。
- `gd`：删除当前工作树及其分支（会先请求确认）。

## Rsync 监视器

- `rsw [source] [destination]`：启动一个后台监视器，每当有任何变化时就将源 rsync 到目标。目标可以是远程主机，如 `rsw ~/Work/app nyc-dev:Work/app`。
- `lsw`：列出所有活跃的监视器。
- `dsw`：停止所有活跃的监视器。

## SSH 端口转发

非常适合在远程机器上以 localhost 安全上下文特权做 Web 开发。

- `fip`：通过 SSH 将一个或多个端口从远程主机转发到 localhost。
- `dip`：断开一个或多个已转发的端口。
- `lip`：列出所有活跃的 SSH 端口转发。

比如你在一台可通过 `nyc-dev` 访问的机器上在端口 `3000` 启动一个开发服务器，然后你可以运行 `fip nyc-dev 3000` 转发该端口，这样 `localhost:3000` 实际上会到达 `nyc-dev:3000`，但不需要 SSL 证书来建立测试 Web 套接字等所需的安全上下文。

## SSH 重连

`ssh` 本身被包装在一个函数中，如果连接在远程 tmux、Herdr 或编辑器占用时断开，该函数会清理终端，然后在交互式会话断开时自动重连（Ctrl-C 停止重试循环）。
