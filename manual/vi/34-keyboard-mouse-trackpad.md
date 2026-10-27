# Bàn phím, Chuột, Trackpad

Hyprland cho phép bạn cấu hình mọi thiết bị đầu vào của mình với chi tiết rất lớn. Bạn có thể khiến tốc độ lặp phím nhanh đến mức siêu thanh hoặc khiến trackpad dùng cuộn tự nhiên. Bạn thay đổi tất cả những điều đó trong `~/.config/hypr/input.lua`, nơi bạn cũng có thể truy cập qua _Setup > Input_ trong menu Omarchy (`Super + Space`). Bất cứ thứ gì bạn đặt ở đó đều thay thế các mặc định của Omarchy.

Sau đây là một ví dụ:

```lua
hl.config({
  input = {
    -- Use multiple keyboard layouts and switch between them with Left Alt + Right Alt
    kb_layout = "us,dk",
    kb_options = "omarchy:shift_caps_compose,grp:alts_toggle",

    -- Change speed of keyboard repeat
    repeat_rate = 40,
    repeat_delay = 600,

    -- Increase sensitivity for mouse/trackpad (default: 0)
    sensitivity = 0.35,

    touchpad = {
      -- Use natural (inverse) scrolling
      natural_scroll = true,

      -- Use two-finger clicks for right-click instead of lower-right corner
      clickfinger_behavior = true,

      -- Control the speed of your scrolling
      scroll_factor = 0.3,
    },
  },
})

-- Scroll faster in the terminal
o.window("(Alacritty|kitty|foot)", { scroll_touchpad = 1.5 })
```

Bạn có thể [xem tất cả các tùy chọn đầu vào](https://wiki.hypr.land/Configuring/Basics/Variables/#input) trên wiki Hyprland dành cho thiết bị đầu vào.

CapsLock hoạt động như một phím Caps Lock bình thường, và `Shift + CapsLock` là phím compose cho [emoji nhanh](07-hotkeys.md#quick-emojis) và [các gợi ý hoàn thiện khác](07-hotkeys.md#quick-completions). Nếu bạn muốn đặt phím compose ở nơi khác, hãy thay thế `omarchy:shift_caps_compose` trong `kb_options`. Ví dụ, đoạn này di chuyển phím compose sang Right Alt:

```lua
hl.config({
  input = {
    kb_options = "compose:ralt",
  },
})
```

### Cử chỉ trackpad

Bạn cũng có thể bật [cử chỉ touchpad](https://wiki.hypr.land/Configuring/Advanced-and-Cool/Gestures/), như vuốt bằng ba ngón tay để thay đổi workspace:

```lua
hl.gesture({ fingers = 3, direction = "horizontal", action = "workspace" })
```

Trên các laptop Dell XPS có touchpad haptic, bạn cũng có thể đặt lực nhấn thành low, mid, hoặc high trong _Trigger > Hardware > Touchpad Haptics_.

### Gõ tiếng Trung, tiếng Nhật và các ngôn ngữ khác

Hãy chọn Japanese, Korean, Chinese (Simplified, Pinyin), Taiwan (Zhuyin), hoặc Hong Kong (Cangjie) khi trình cài đặt hỏi về bàn phím của bạn. Omarchy tự động cấu hình bàn phím và bộ gõ phù hợp, kể cả trong quá trình thiết lập ngoại tuyến ở lần khởi động đầu tiên. Tiếng Nhật dùng Mozc, tiếng Hàn dùng Hangul hai bộ tiêu chuẩn, tiếng Trung Giản thể dùng Pinyin, Đài Loan dùng cách bố trí Zhuyin tiêu chuẩn của Chewing, và Hong Kong dùng Cangjie với các dạng chữ Hong Kong. Japanese (US keyboard) cung cấp Mozc với bố cục bàn phím US. Các phím Hangul, Zhuyin và Cangjie vẫn ở các vị trí tiêu chuẩn của chúng ngay cả khi bạn gõ chữ Latin bằng Dvorak, Colemak, hoặc AZERTY. Nếu trước đây bạn đã thêm Hangul hoặc Chewing, hãy bỏ chọn rồi chọn lại nó trong _Setup > Typing > Input Methods_ để di chuyển các phím của nó tới đó; Omarchy sẽ không động vào một bộ gõ mà bạn đã dùng để gõ.

Việc gõ bắt đầu ở chế độ Latin. Nhấn `Super + I` để chuyển qua các phương thức nhập đã cấu hình, và `Super + Shift + I` để chuyển ngược lại. Chạm `Shift` một mình để bước ra khỏi một phương thức nhập như Pinyin sang chữ Latin, và chạm lại để quay trở lại, giống cách Sogou, Microsoft Pinyin và macOS hoạt động; `Shift` cộng với một chữ cái vẫn gõ chữ hoa. Trên bàn phím tiếng Nhật, 全角/半角 bật/tắt chế độ nhập, 変換 bật nó lên, và 無変換 tắt nó đi. Với tiếng Hàn, 한/영 chuyển đổi Hangul và 한자 chuyển đổi sang Hanja, dù bàn phím của bạn có các phím riêng hay gửi Right Alt và Right Ctrl cho chúng, như nhiều laptop vẫn làm, vì vậy Right Alt và Right Ctrl không phải là các phím bổ trợ thuần túy ở đó; tính năng giữ để nói của dictation vẫn nằm trên F9. `Ctrl + Space` vẫn khả dụng cho Tmux và Herdr; `Shift + CapsLock` vẫn là phím compose.

Chỉ báo bàn phím xuất hiện ở phía bên phải của thanh khi bạn có nhiều bố cục bàn phím hoặc phương thức nhập. Nhấp vào nó để chuyển đổi ngôn ngữ nhập; tiếng Nhật hiển thị あ cho hiragana. Đối với các lựa chọn ký tự tiếng Nhật, hãy chuyển sang tiếng Nhật, gõ một từ như `nihongo`, rồi nhấn Space hai lần. Nhấn Enter để chấp nhận lựa chọn của bạn. Nếu bạn cũng có nhiều bố cục bàn phím, hãy nhấp chuột phải vào chỉ báo để chuyển qua chúng.

Dùng _Setup > Typing > Keyboard Layouts_ để chọn các bố cục như English và French, từ cùng những lựa chọn được cung cấp trong quá trình cài đặt. Dùng _Setup > Typing > Input Methods_ để chọn những bộ máy soạn thảo nào đang hoạt động. Cả hai trình chọn đều mở bên trong menu Omarchy với các lựa chọn hiện tại của bạn được đánh dấu. Nhấp hoặc nhấn Enter để bật/tắt một lựa chọn; mỗi thay đổi đều áp dụng ngay lập tức. Bỏ chọn một phương thức nhập sẽ loại bỏ nó khỏi chu trình mà không gỡ cài đặt nó; bàn phím vẫn khả dụng.

Chạy `omarchy setup keyboard` hoặc `omarchy setup input` để mở cùng các trình chọn đó. Để thêm một ngôn ngữ từ dòng lệnh, hãy dùng `omarchy setup input mozc`, `hangul`, `pinyin`, `chewing`, hoặc `cangjie5`. Quick, Boshiamy và Array đi kèm trong cùng một gói với Cangjie và xuất hiện trong trình chọn Input Methods. Các phím chuyển đổi tùy chỉnh của bạn được giữ nguyên. Đối với các bố cục hoặc phím bộ gõ thay thế, hãy cài đặt `fcitx5-configtool` bằng `omarchy pkg add fcitx5-configtool` và khởi chạy nó từ một terminal. Chọn một ngôn ngữ nhập không làm thay đổi ngôn ngữ desktop. Chọn Japanese, Korean, hoặc Chinese trong _Setup > Language_ sẽ thêm phương thức nhập của nó khi bạn chưa có phương thức nào.

Dùng `Super + I` để chuyển qua các phương thức nhập hoặc bố cục bàn phím, và `Super + Shift + I` để quay lại theo chiều ngược lại, vì vậy với ba mục đã cấu hình, bạn có thể di chuyển giữa hai mục kề nhau. Chỉ báo đầu vào chỉ xuất hiện ở phía bên phải của thanh khi có nhiều hơn một phương thức nhập hoặc bố cục được cấu hình. Phím tắt desktop này hoạt động cùng với các phím chuyển đổi Fcitx hiện có của bạn; bạn có thể ghi đè nó trong `~/.config/hypr/bindings.lua`. Các bộ gõ và các chuỗi compose sử dụng dịch vụ [Fcitx5](https://fcitx-im.org/) đã chạy trong mọi phiên.

### Dùng ALT làm SUPER

Trên một số bàn phím, việc dùng phím meta chính (phím Windows/cmd) làm SUPER không thuận tiện. Bạn có thể thay đổi điều này thành ALT thay vào đó bằng thay đổi sau:

```lua
hl.config({
  input = {
    kb_options = "omarchy:shift_caps_compose,altwin:swap_alt_win",
  },
})
```
