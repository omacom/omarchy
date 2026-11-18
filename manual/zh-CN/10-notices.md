# 通知

通知会出现在当前焦点显示器的右上角。你也可以使用快捷键通知快速查看日期和时间、电池状态以及当前天气。

## 通知

来自同一应用或网站的通知会堆叠成一组，因此热闹的 Slack 频道不会把你的构建失败通知挤出屏幕。将鼠标悬停在一组通知上即可将其展开；当你正在阅读时，不会有新通知滑到你的指针下方。单击卡片可跳转到它的来源，右键单击、中键单击或点击 ✕ 即可将其关闭。

卡片会提供其所携带的操作：用于验证码的 _Copy code_（不会保留在[剪贴板历史记录](08-unified-clipboard-history.md)中，并在一分钟后清除），以及应用提供的任何按钮。点击通知文本中的链接即可打开。

要在不使用鼠标的情况下使用它们，请按 `Super + Ctrl + ,`。最新的通知会被选中，其按钮会被编号：按数字键可使用其中一个按钮，按 `Enter` 可点击该通知，按 `↑` 和 `↓` 可在通知之间移动，按 `Delete` 可关闭一条通知，按 `Esc` 可交还键盘控制。它也会在闲置几秒后自动释放。

静默通知会将它们拦截，但 Omarchy 自身的确认、紧急警报和你刚刚请求的验证码除外。使用 `Super + Shift + Alt + ,` 可将最近几条重新显示在屏幕上，无论它们是否被拦截。历史记录会保留一天。

## 快捷键通知

### 日期和时间

`Super + Ctrl + Alt + T`

 ![notice-datetime](images/notice-datetime.webp)

### 天气

`Super + Ctrl + Alt + W`

 ![notice-weather](images/notice-weather.webp)

位置是根据你的 IP 地址检测的，通常足够接近，但并不总是如此。你可以使用 `omarchy weather location --set Malibu` 将其固定下来，或者通过添加坐标来精确指定：`omarchy weather location --set Malibu 34.0259,-118.7798`。单独运行 `omarchy weather location` 可查看它认为你所在的位置，使用 `--clear` 可恢复为自动检测。

### 电池

`Super + Ctrl + Alt + B`

 ![notice-battery](images/notice-battery.webp)
