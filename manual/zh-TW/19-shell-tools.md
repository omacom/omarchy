# Shell 工具

除了標準的 Linux 工具外，Omarchy 還附帶了一大堆強化版的 shell 工具。以下是重點幾個。

## fzf

[fzf](https://junegunn.github.io/fzf/) 讓你透過 `ff` 別名對檔案進行模糊搜尋。前往任何目錄，輸入 `ff`，你就能模糊搜尋到該目錄樹中的任何檔案，同時在右側看到正在篩選的檔案預覽。

你可以用 `Ctrl + R` 透過 fzf 對命令歷史進行模糊搜尋。

當你在 Neovim 中輸入 `Space Space` 時，也會用到這個工具。

完整手冊可透過 `man fzf` 查看。

## Zoxide

[Zoxide](https://github.com/ajeetdsouza/zoxide) 是 cd 的替代品。它會記住你去過的目錄，讓你下次能更輕鬆地跳過去。假設你執行過一次 `cd ~/.config/omarchy`。下次你只要執行 `cd omarchy`（甚至只要 `cd oma`），Zoxide 就會直接把你帶到那裡。

完整手冊可透過 `man zoxide` 查看。

## ripgrep

[ripgrep](https://github.com/BurntSushi/ripgrep) 使用 `rg <pattern> <path>` 搜尋檔案內容，例如 `rg Controller app/` 可找出 app 目錄中所有提到 `Controller` 的地方。

當你在 Neovim 中輸入 `Space S G` 時，也會用到這個工具。

完整手冊可透過 `man rg` 查看。

## eza

[eza](https://eza.rocks/) 是 ls 的替代品。它提供資訊更豐富、帶有色彩和圖示的目錄列表。預設情況下，eza 已被設為 ls 的別名。你也可以用 `lt` 取得兩層深的巢狀列表。`lsa` 會給你包含隱藏檔案的列表。而 `lta` 則是包含隱藏檔案的巢狀列表。

完整手冊可透過 `man eza` 查看。

## fd

[fd](https://github.com/sharkdp/fd) 是更易用的 `find` 替代品。用 `fd person.rb` 在目前目錄樹中尋找名為 `person.rb` 的檔案。`fd person.rb /` 會搜尋整個檔案系統。`fd person.rb / -H` 會搜尋整個檔案系統，包括隱藏目錄。

完整手冊可透過 `man fd` 查看。

## bat

[bat](https://github.com/sharkdp/bat) 是帶有語法醒目提示、行號和分頁功能的 `cat`。執行 `bat somefile.rb`，你就會明白為什麼用過就回不去了。它還在其他地方默默為你工作：它負責為你的 man 頁面上色，也負責渲染 `ff` 中的預覽。

完整手冊可透過 `man bat` 查看。

## tldr

[tldr](https://tldr.sh/) 是那種開頭先講三個畫面的歷史、才給你看一個範例的 man 頁面的解藥。`tldr tar` 會給你真正想要的那幾種調用方式。

## yt-dlp

[yt-dlp](https://github.com/yt-dlp/yt-dlp) 可從 YouTube 和數百個其他網站下載影片。`yt-dlp <url>` 會將可取得的最高品質下載到目前目錄。

完整手冊可透過 `man yt-dlp` 查看。

## try

[try](https://github.com/tobi/try) 讓你輕鬆地用帶日期戳記的目錄管理程式設計實驗。所有實驗都位於 `~/Work/tries`，你可以透過 `try` 存取它們。

Omarchy 不會自動將專案的 `bin/` 目錄加入 `PATH`。請用明確的相對路徑執行可信任的專案本地工具，例如 `bin/rails` 或 `./bin/dev`。
