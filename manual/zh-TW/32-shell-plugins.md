# Shell 外掛程式

Omarchy 桌面作為一個稱為 `omarchy-shell` 的單一長期執行的 Quickshell 處理程序運作，而你在畫面上看到的幾乎一切都是它裡面的一個外掛程式。選單列是一個外掛程式。那些從列上掉下來的面板、像表情符號選擇器和剪貼簿管理器這類全螢幕覆蓋層、Omarchy 選單本身、鎖定畫面、polkit 對話框，以及那些關注你電池、並在夜間讓螢幕變暖的無頭服務，也都是外掛程式。

這不只是一個實作細節。這意味著你可以關閉桌面的某些部分、將它們換掉，或撰寫你自己的，而不必動一行 Omarchy 的原始碼。

第一方外掛程式隨 Omarchy 一起提供，並位於 `$OMARCHY_PATH/shell/plugins/`。任何你自己加入的東西——你自己的實驗，或你在 GitHub 上找到的東西——位於 `~/.config/omarchy/plugins/`。兩者都在啟動時以相同的方式被探索，但內建外掛程式會獲得受信任的 shell 介面，而第三方外掛程式則會獲得限於其自身服務和生命週期的受限介面。內建外掛程式的副本只會保留原始行為所需的特定於來源的設定和 UI 調用。

## 查看你擁有什麼

```
omarchy plugin list
```

那會印出每一個被探索到的外掛程式，包含其 id、是否啟用、是第一方還是第三方、其種類及其顯示名稱。如果你要將它餵給其他東西，加上 `--json`。

外掛程式 id 是有命名空間的。內建項目全部以 `omarchy.` 開頭——`omarchy.clock`、`omarchy.network`、`omarchy.notifications`——而且該命名空間是保留的，所以第三方外掛程式永遠無法聲稱擁有它。

## 開啟和關閉它們

```
omarchy plugin enable omarchy.tailscale
omarchy plugin disable omarchy.weather
```

或者使用選單：_設定 > Plugins_ 中有 Enable、Disable、Add、Clone 和 Remove，每一個都帶有一個選擇器，該選擇器只提供對該操作有意義的外掛程式。

啟用狀態儲存在 `~/.config/omarchy/shell.json` 中，而且規則對這兩種外掛程式稍有不同。第三方外掛程式恰好在其 id 出現在該檔案某處時被啟用——作為選單列版面配置項目、作為 `plugins[]` 中的項目，或作為 `bar.id`。不屬於選單列小工具的第一方外掛程式則相反：它們預設為開啟，只有在被列入 `disabledPlugins[]` 時才關閉。

完整的選單列外掛程式根本沒有關閉狀態。永遠恰好有一個選單列，所以你透過啟用另一個來取代它。選單列小工具的放置在[選單列](05-the-top-bar.md)中有說明。

## 從 git 加入外掛程式

第三方外掛程式就是一個 git 儲存庫，其根目錄有一個 `manifest.json`。

```
omarchy plugin add https://github.com/acme/omarchy-weather.git --enable
```

在做任何事情之前，它會明確地告訴你，外掛程式會作為任意的、未經沙盒化的程式碼在你的長期執行的 shell 處理程序內執行，顯示 URL，並要求你確認。請認真對待這一點。第三方外掛程式介面不會直接暴露驗證服務，而替代選單列只會獲得針對已設定的非驗證 UI 的有限能力。視覺外掛程式仍會共享 shell 的 QML 場景，並能遍歷一般的父物件，而所有外掛程式程式碼都會帶著你的使用者帳戶所能觸及的一切執行。驗證狀態透過將這些服務保持在可觸及的主機物件圖之外而得到單獨保護。只加入你願意執行的儲存庫，並在啟用它們之前先閱讀它們。

替代選單列可以渲染已安裝的小工具，但有服務支援的第三方小工具在那裡的功能可能會減少，因為選單列不被允許要求另一個外掛程式的即時服務物件。如果這類小工具需要其配套服務，請切換回內建的 `omarchy.bar`。

然後它會將儲存庫複製到暫存目錄，驗證 manifest，如果另一個外掛程式已聲稱擁有該 id 就拒絕安裝，並將其移入 `~/.config/omarchy/plugins/<id>/`。不加 `--enable` 時，它會詢問你是否想現在就開啟它，你可以說不要，先去閱讀程式碼。它永遠不會執行外掛程式中的任何東西、永遠不會執行安裝 hook、也永遠不會要求 sudo——它複製檔案、檢查 manifest，並透過 IPC 翻轉一個位元。

更新是對同一個副本進行快速轉發拉取：

```
omarchy plugin update acme.weather
omarchy plugin update
```

不加 id 時，它會更新你擁有的每一個由 git 管理的外掛程式。它會在套用之前向你展示差異，如果你有無法快速轉發通過的本地變更就拒絕更新，並在新修訂版本驗證失敗時還原。

```
omarchy plugin remove acme.weather
```

移除會先停用外掛程式，然後如果它是 git 副本就刪除它（儲存庫仍然在上游），如果它是符號連結就解除連結它。一個沒有 git 儲存庫的手工外掛程式資料夾會被移到外掛程式目錄內一個帶有時間戳記的備份中，而不是直接被刪除。

## 複製一個內建外掛程式來修改它

這是我最喜歡的部分。如果你想更改某個內建小工具的行為，不要編輯 `$OMARCHY_PATH` 下的檔案——那些屬於套件，下一次更新會覆寫它們。改為複製它：

```
omarchy plugin clone omarchy.clock
```

那會將整個外掛程式複製到 `~/.config/omarchy/plugins/dhh.clock`（是你的使用者名稱，不是我的），將其重新命名為 "My Clock"，啟用它，並將 shell 從內建版本切換到你的副本——同時保留現有選單列小工具的位置和設定。加上 `--edit` 可立即在你的 `$EDITOR` 中開啟新目錄，這正是選單的 _設定 > Plugins > Clone Plugin_ 為你做的事。

使用者名稱前綴讓你副本的 id 保持屬於你，所以分享它不會與任何其他人的相衝突。對原始內建 id 進行的調用會被轉送到你的副本，所以任何引用過 `omarchy.clock` 的東西都不需要更新。而且如果你把它弄亂了，`omarchy plugin remove dhh.clock` 會把內建版本放回去。

在 `~/.config/omarchy/plugins/` 下任何地方儲存檔案都會自動重新載入外掛程式碼，所以你可以讓編輯器開著，看著你的變更生效。

## 撰寫你自己的

一個外掛程式是一個帶有 `manifest.json` 和一些 QML 的目錄。manifest 宣告 `schemaVersion: 1`、一個 `id`、`name`、`version`、一個或多個 `kinds`，以及一個 `entryPoints` 物件，指向每個種類的 QML 檔案：

| 種類 | 它是什麼 |
|------|------------|
| `bar-widget` | 作用中的選單列可以放入某區段的元件 |
| `panel` | 持續性或被召喚出的浮動視窗 |
| `overlay` | 全螢幕覆蓋層 |
| `menu` | 被召喚出的選單介面 |
| `service` | 沒有 UI 的無頭單例 |
| `bar` | 取代內建選單列的完整選單列 |

一個外掛程式可以同時宣告多個種類——媒體外掛程式同時是 `service` 和 `bar-widget`。選單列小工具會獲得一個額外的 `barWidget` 區塊，包含顯示名稱、類別、可選的 `defaultSection`，以及 `allowMultiple`，後者說明在選單列上放置多個是否有意義。大多數小工具都將其設為 `false`；間隔工具和指示器則將其設為 `true`。

在你發布任何東西之前，先檢查它：

```
omarchy plugin validate ./my-plugin
```

那會執行 shell 在載入時執行的相同檢查：綱要版本、必填欄位、未被保留的 id、安全的相對路徑且實際存在的進入點、你所聲稱的每個種類都有進入點，以及資料夾內任何地方都沒有符號連結。

關於外掛程式開發，請參閱 [shell 參考文件](https://github.com/omacom/omarchy/blob/quattro/docs/omarchy-shell.md)和[第一方外掛程式目錄](https://github.com/omacom/omarchy/blob/quattro/shell/plugins/README.md)。

## 與世界分享你的成果

一旦你做出了喜歡的東西，就把它放在公開的 git 儲存庫中。這就是整個散佈機制——然後任何人都可以對你的 URL 執行 `omarchy plugin add`，並在幾秒內讓它執行起來。

為了幫助人們實際找到它，將它列在 [plugins.omarchy.org](https://plugins.omarchy.org) 上。那裡是 Omarchy shell 外掛程式的市集，當你在想是否已經有人製作了你正要撰寫的小工具時，那也是你首先要看的地方。在開始之前先瀏覽它！
