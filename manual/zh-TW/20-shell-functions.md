# Shell 函式

Omarchy 附帶了一組 shell 函式，用來簡化常見任務並封裝繁瑣的參數調用。

## 壓縮

- `compress [file/dir]`：從檔案/目錄建立 tar.gz 壓縮檔。
- `decompress [file.tar.gz]`：展開 tar.gz 檔案。

## 磁碟機

- `iso2sd [image.iso]`：使用指定的 iso 檔案在 SD 卡上建立可開機磁碟機，並以互動方式選取磁碟機。
- `format-drive [device] [name]`：將整個磁碟格式化為單一 exFAT 分割區（在 Windows 和 macOS 上也能用）。不帶參數執行可查看可用的磁碟機。請小心！

## 開發版面配置

適用於 tmux 的即時多窗格開發版面配置：

- `tdl [ai]`：建立一個包含你的編輯器、一個 AI 代理程式和一個終端機的 Tmux Dev Layout。使用代理程式別名，例如用 `tdl c` 代表 opencode、用 `tdl cx` 代表 Claude Code，或傳入第二個代理程式來同時執行兩個，例如 `tdl c cx`。
- `tds`：建立一個包含編輯器、差異監看（透過 `hunk diff --watch`）、終端機和 opencode 的 Tmux Dev Square。
- `tdlm [ai]`：為目前目錄中的每個子目錄各建立一個 `tdl` 視窗。
- `tsl [count] [command]`：建立一群以格狀平鋪的窗格，全部執行相同的命令（非常適合 AI 代理程式）。

相同的版面配置在 Herdr 中以 `hdl`、`hds`、`hdlm` 和 `hsl` 提供。

## Git worktree

- `ga [branch]`：在目前儲存庫旁邊建立新的 worktree 和分支，並跳進去。
- `gd`：移除目前的 worktree 及其分支（會先要求確認）。

## Rsync 監看器

- `rsw [source] [destination]`：啟動一個背景監看器，只要有任何變更就把來源 rsync 到目的地。目的地可以是遠端主機，例如 `rsw ~/Work/app nyc-dev:Work/app`。
- `lsw`：列出所有作用中的監看器。
- `dsw`：停止所有作用中的監看器。

## SSH 連接埠轉發

非常適合針對遠端機器進行具有 localhost 安全上下文權限的網頁開發。

- `fip`：透過 SSH 將一個或多個連接埠從遠端主機轉發到 localhost。
- `dip`：中斷一個或多個已轉發的連接埠。
- `lip`：列出所有作用中的 SSH 連接埠轉發。

假設你在一台可透過 `nyc-dev` 存取的機器上、在連接埠 `3000` 啟動了一個開發伺服器，那麼你可以執行 `fip nyc-dev 3000` 來轉發該連接埠，這樣 `localhost:3000` 實際上就能連到 `nyc-dev:3000`，而且不需要 SSL 憑證來建立測試 WebSocket 之類功能所需的安全上下文。

## SSH 重新連線

`ssh` 本身被包裝在一個函式中：如果連線在遠端 tmux、Herdr 或編輯器佔用終端機時中斷，它會清理終端機，然後在互動式工作階段斷線時自動重新連線（按 Ctrl-C 可停止重試迴圈）。
