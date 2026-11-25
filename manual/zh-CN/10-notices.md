# 通知

通知会出现在当前聚焦显示器的右上角。你也可以通过快捷键通知快速查看日期和时间、电池状态以及当前天气。

## 通知

来自同一应用或网站的通知会堆叠成一组卡片，这样话痨的 Slack 频道就不会把你的构建失败通知挤出屏幕。将鼠标悬停在一组卡片上即可将其展开；当你正在阅读时，不会有新通知滑到你的指针下方。点击卡片可跳转到它的来源，右键点击、中键点击或点 ✕ 即可将其关闭。

卡片会提供它所携带的操作：验证码的 _复制代码_（不会进入[剪贴板历史](08-unified-clipboard-history.md)，并会在一分钟后清除），以及应用提供的任何按钮。点击通知文本中的链接即可打开。

`Super + ,` 会关闭最新的一条通知，或者在通知提供该操作时打开它指向的内容，`Super + Alt + ,` 只会关闭最后一条，`Super + Shift + ,` 会关闭全部通知，`Super + Shift + Alt + ,` 则会打开历史记录。不用鼠标也能操作：按下 `Super + Ctrl + ,`。最新的一条通知会被选中，它上面的按钮会被编号：按数字即可使用对应按钮，按 `Enter` 点击通知，按 `↑` 和 `↓` 在通知之间移动，按 `Delete` 关闭一条，按 `Esc` 将键盘交还回去。闲置几秒后，它也会自动退出。

将通知静音后，通知会被拦住，但 Omarchy 自己的确认通知、紧急警报以及你刚刚索要的验证码除外。用 `Super + Shift + Alt + ,` 将最近的几条重新显示到屏幕上，不管它们是否被拦住。历史记录保留一天。

## 快捷键通知

### 日期与时间

`Super + Ctrl + Alt + T`

 ![notice-datetime](images/notice-datetime.webp)

### 天气

`Super + Ctrl + Alt + W`

 ![notice-weather](images/notice-weather.webp)

位置是根据你的 IP 地址检测出来的，通常足够接近，但并不总是如此。你可以用 `omarchy weather location --set Malibu` 将其固定下来，或者加上坐标来精确指定：`omarchy weather location --set Malibu 34.0259,-118.7798`。单独运行 `omarchy weather location` 可以查看它认为你所在的位置，使用 `--clear` 则可恢复自动检测。

### 电池

`Super + Ctrl + Alt + B`

 ![notice-battery](images/notice-battery.webp)
