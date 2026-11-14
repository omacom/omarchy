# Bàn phím, Chuột, Trackpad

Hyprland cho phép bạn cấu hình mọi thiết bị đầu vào của mình với chi tiết tuyệt vời. Bạn có thể thay đổi tốc độ lặp phím thành nhanh siêu tốc hoặc khiến trackpad dùng cuộn tự nhiên. Bạn thay đổi tất cả trong `~/.config/hypr/input.lua`, mà bạn cũng có thể truy cập qua _Setup > Input_ trong menu Omarchy (`Super + Space`). Bất cứ điều gì bạn đặt ở đó sẽ thay thế các mặc định của Omarchy.

Đây là một ví dụ:

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

Bạn có thể [xem tất cả các tùy chọn đầu vào](https://wiki.hypr.land/Configuring/Basics/Variables/#input) trên wiki Hyprland dành cho đầu vào.

CapsLock hoạt động như một phím Caps Lock thông thường, và `Shift + CapsLock` là phím compose cho [emoji nhanh](07-hotkeys.md#quick-emojis) và [các gợi ý hoàn thành khác](07-hotkeys.md#quick-completions). Nếu bạn muốn đặt phím compose ở nơi khác, hãy thay thế `omarchy:shift_caps_compose` trong `kb_options`. Ví dụ, đoạn này di chuyển phím compose sang Right Alt:

```lua
hl.config({
  input = {
    kb_options = "compose:ralt",
  },
})
```

### Phím chức năng

Hàng phím trên cùng của bàn phím laptop gửi các phím media (âm lượng, độ sáng và vân vân) theo mặc định, và giữ `Fn` sẽ cho F1-F12; `Fn + Esc` khóa nó theo chiều ngược lại cho đến khi bạn nhấn lại. Hầu hết các bàn phím tự ghi nhớ khóa đó. Laptop ASUS và bàn phím kiểu Apple để việc đó cho Linux, hệ điều hành khởi động chúng ở các phím media mỗi lần khởi động. Để chúng khởi động ở F1-F12 thay vào đó, hãy chạy `omarchy keyboard toprow fnkeys` (và `omarchy keyboard toprow mediakeys` để quay lại); trên một số laptop, nó có hiệu lực sau khi khởi động lại. Các máy Mac Apple Silicon giữ cài đặt riêng của chúng.

### Cử chỉ trackpad

Vuốt trên trackpad để di chuyển quanh desktop:

| Cử chỉ | Hành động |
| --- | --- |
| Ba ngón tay sang trái / phải | Workspace trước / tiếp theo, bao gồm cả những workspace trống |
| Ba ngón tay lên | Bật/tắt AI console |
| Ba ngón tay xuống | Mở menu Omarchy |
| Bốn ngón tay sang trái / phải | Di chuyển cửa sổ đang hoạt động sang workspace trước / tiếp theo |
| Bốn ngón tay xuống | Bật/tắt toàn màn hình |

Để thay đổi một cử chỉ, hãy hủy đặt nó trong `~/.config/hypr/input.lua` trước khi thêm [cử chỉ touchpad](https://wiki.hypr.land/Configuring/Advanced-and-Cool/Gestures/) của riêng bạn, vì Hyprland sẽ không chấp nhận hai cử chỉ trên cùng số ngón tay và cùng một hướng:

```lua
hl.gesture({ fingers = 3, direction = "up", action = "unset" })
hl.gesture({ fingers = 3, direction = "up", action = "fullscreen" })
```

Để tắt tất cả các cử chỉ của Omarchy, hãy đặt `omarchy_default_gestures = false` gần đầu `~/.config/hypr/hyprland.lua`, trước khi các mặc định của Omarchy tải.

Trên laptop Dell XPS với touchpad xúc giác, bạn cũng có thể đặt độ mạnh của cú nhấp thành low, mid, hoặc high dưới _Trigger > Hardware > Touchpad Haptics_.

### Gõ tiếng Trung, tiếng Nhật, và các ngôn ngữ khác

Chọn Japanese, Korean, Chinese (Simplified, Pinyin), Taiwan (Zhuyin), hoặc Hong Kong (Cangjie) khi trình cài đặt hỏi về bàn phím của bạn. Omarchy cấu hình bàn phím và bộ máy đầu vào phù hợp một cách tự động, kể cả trong quá trình thiết lập lần khởi động đầu tiên ngoại tuyến. Japanese dùng Mozc, Korean dùng Hangul hai bộ tiêu chuẩn, Simplified Chinese dùng Pinyin, Taiwan dùng cách sắp xếp Zhuyin tiêu chuẩn của Chewing, và Hong Kong dùng Cangjie với các dạng ký tự Hong Kong. Japanese (US keyboard) cung cấp Mozc với bố cục bàn phím US. Các phím Hangul, Zhuyin, và Cangjie giữ nguyên vị trí tiêu chuẩn của chúng ngay cả khi bạn gõ chữ Latin bằng Dvorak, Colemak, hoặc AZERTY. Nếu bạn đã thêm Hangul hoặc Chewing trước đây, hãy bỏ chọn và chọn lại nó dưới _Setup > Keyboard > Input Methods_ để di chuyển các phím của nó đến đó; Omarchy để yên một bộ máy mà bạn đã gõ với nó.

Việc gõ bắt đầu ở chế độ Latin. Nhấn `Super + I` để chuyển vòng qua các phương thức đầu vào đã cấu hình, và `Super + Shift + I` để chuyển vòng ngược lại. Nhấn `Shift` riêng để bước ra khỏi một phương thức đầu vào như Pinyin sang chữ Latin, và nhấn lại để quay lại, theo cách Sogou, Microsoft Pinyin, và macOS hoạt động; `Shift` cộng một chữ cái vẫn gõ một chữ hoa. Trên bàn phím Japanese, 全角/半角 bật/tắt đầu vào, 変換 bật nó, và 無変換 tắt nó. Với Korean, 한/영 chuyển Hangul và 한자 chuyển đổi sang Hanja, dù bàn phím của bạn có phím chuyên dụng hay gửi Right Alt và Right Ctrl cho chúng, như nhiều laptop làm, vì vậy Right Alt và Right Ctrl không phải là phím modifier thuần túy ở đó; đọc chính tả bật/tắt bằng Alt + Space thay vào đó. `Ctrl + Space` vẫn khả dụng cho Tmux và Herdr; `Shift + CapsLock` vẫn là phím compose.

Chỉ báo bàn phím xuất hiện ở phía bên phải của thanh khi bạn có nhiều bố cục bàn phím hoặc phương thức đầu vào. Nhấp vào nó để chuyển ngôn ngữ đầu vào; Japanese hiển thị あ cho hiragana. Đối với các lựa chọn ký tự Japanese, hãy chuyển sang Japanese, gõ một từ như `nihongo`, sau đó nhấn Space hai lần. Nhấn Enter để chấp nhận lựa chọn của bạn. Nếu bạn cũng có nhiều bố cục bàn phím, hãy nhấp chuột phải vào chỉ báo để chuyển vòng qua chúng.

Dùng _Setup > Keyboard > Keyboard Inputs_ để chọn các bố cục như English và French, từ cùng các lựa chọn được cung cấp trong quá trình cài đặt. Dùng _Setup > Keyboard > Input Methods_ để chọn bộ máy soạn thảo nào đang hoạt động. Cả hai bộ chọn đều mở bên trong menu Omarchy với các lựa chọn hiện tại của bạn được đánh dấu. Nhấp hoặc nhấn Enter để bật/tắt một lựa chọn; mỗi thay đổi áp dụng ngay lập tức. Bỏ chọn một phương thức đầu vào sẽ loại bỏ nó khỏi vòng chuyển đổi mà không gỡ cài đặt nó; bàn phím vẫn khả dụng.

Chạy `omarchy setup keyboard` hoặc `omarchy setup input` để mở cùng các bộ chọn đó. Để thêm một ngôn ngữ từ dòng lệnh, dùng `omarchy setup input mozc`, `hangul`, `pinyin`, `chewing`, hoặc `cangjie5`. Quick, Boshiamy, và Array đi kèm trong cùng gói với Cangjie và xuất hiện trong bộ chọn Input Methods. Các phím chuyển đổi tùy chỉnh của bạn được giữ nguyên. Đối với bố cục hoặc phím của bộ máy thay thế, hãy cài đặt `fcitx5-configtool` bằng `omarchy pkg add fcitx5-configtool` và khởi chạy nó từ terminal. Chọn một ngôn ngữ đầu vào không thay đổi ngôn ngữ desktop. Chọn Japanese, Korean, hoặc Chinese dưới _Setup > Language_ sẽ thêm phương thức đầu vào của nó khi bạn chưa có phương thức nào.

Dùng `Super + I` để chuyển vòng qua các phương thức đầu vào hoặc bố cục bàn phím, và `Super + Shift + I` để đi ngược lại chiều kia, vì vậy với ba mục đã cấu hình, bạn có thể di chuyển giữa hai mục kề nhau. Chỉ báo đầu vào xuất hiện ở phía bên phải của thanh chỉ khi có nhiều hơn một phương thức đầu vào hoặc bố cục được cấu hình. Phím tắt desktop này hoạt động cùng với các phím chuyển đổi Fcitx hiện có của bạn; bạn có thể ghi đè nó trong `~/.config/hypr/bindings.lua`. Các bộ máy đầu vào và các chuỗi compose dùng dịch vụ [Fcitx5](https://fcitx-im.org/) đã chạy trong mọi phiên.

### Dùng ALT làm SUPER

Trên một số bàn phím, việc dùng phím meta chính (phím Windows/cmd) làm SUPER không thuận tiện. Bạn có thể thay đổi điều này thành ALT thay vào đó bằng thay đổi này:

```lua
hl.config({
  input = {
    kb_options = "omarchy:shift_caps_compose,altwin:swap_alt_win",
  },
})
```
