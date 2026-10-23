# Bàn phím, Chuột, Bàn di chuột

Hyprland cho phép bạn cấu hình mọi thiết bị đầu vào của mình rất chi tiết. Bạn có thể thay đổi tốc độ lặp lại của bàn phím để nhanh siêu tốc hoặc làm cho bàn di chuột dùng cuộn tự nhiên. Bạn thay đổi mọi thứ trong `~/.config/hypr/input.lua`, mà bạn cũng có thể đến qua _Thiết lập > Đầu vào_ trong menu Omarchy (`Super + Space`). Bất cứ thứ gì bạn đặt ở đó đều thay thế các mặc định của Omarchy.

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

Bạn có thể [xem mọi tùy chọn đầu vào](https://wiki.hypr.land/Configuring/Basics/Variables/#input) trên wiki của Hyprland về đầu vào.

CapsLock hoạt động như một Caps Lock thông thường, và `Shift + CapsLock` là phím soạn thảo (compose key) cho [emoji nhanh](07-hotkeys.md#quick-emojis) và [các cách hoàn thành khác](07-hotkeys.md#quick-completions). Nếu bạn muốn phím soạn thảo ở nơi khác, hãy thay thế `omarchy:shift_caps_compose` trong `kb_options`. Ví dụ, điều này di chuyển phím soạn thảo đến Right Alt:

```lua
hl.config({
  input = {
    kb_options = "compose:ralt",
  },
})
```

### Cử chỉ bàn di chuột

Bạn cũng có thể bật [cử chỉ bàn di chuột](https://wiki.hypr.land/Configuring/Advanced-and-Cool/Gestures/), như vuốt bằng ba ngón tay để thay đổi workspace:

```lua
hl.gesture({ fingers = 3, direction = "horizontal", action = "workspace" })
```

Trên các máy tính xách tay Dell XPS với bàn di chuột cảm ứng lực (haptic), bạn cũng có thể đặt cường độ nhấp thành thấp, trung bình hoặc cao trong _Kích hoạt > Phần cứng > Phản hồi xúc giác của bàn di chuột_.

### Gõ tiếng Trung, tiếng Nhật và các ngôn ngữ khác

Chọn tiếng Nhật, tiếng Hàn, tiếng Trung (Giản thể, Pinyin), hoặc tiếng Trung (Phồn thể, Zhuyin) khi trình cài đặt hỏi về bàn phím của bạn. Omarchy tự động cấu hình bàn phím và bộ máy nhập liệu tương ứng, kể cả trong quá trình thiết lập lần khởi động đầu tiên ngoại tuyến. Tiếng Nhật dùng Mozc, tiếng Hàn dùng Hangul hai bộ tiêu chuẩn, tiếng Trung Giản thể dùng Pinyin, và tiếng Trung Phồn thể dùng cách sắp xếp Zhuyin tiêu chuẩn của Chewing. Tiếng Nhật (bàn phím US) cung cấp Mozc với bố cục bàn phím US.

Việc gõ bắt đầu ở chế độ Latin. Nhấn `Super + I` để luân chuyển qua các phương thức nhập đã cấu hình, và `Super + Shift + I` để luân chuyển ngược lại. Chạm `Shift` một mình để bước ra khỏi một phương thức nhập như Pinyin sang các chữ cái Latin, và chạm lại để quay lại, theo cách Sogou, Microsoft Pinyin và macOS hoạt động; `Shift` cộng với một chữ cái vẫn gõ ra một chữ hoa. Trên bàn phím tiếng Nhật, 全角/半角 bật/tắt đầu vào, 変換 bật nó, và 無変換 tắt nó. Trên bố cục bàn phím tiếng Hàn, các phím dành riêng 한/영 và 한자 chuyển đổi Hangul và chuyển đổi sang Hanja. `Ctrl + Space` vẫn khả dụng cho Tmux và Herdr; `Shift + CapsLock` vẫn là phím soạn thảo.

Chỉ báo bàn phím xuất hiện ở phía bên phải của thanh khi bạn có nhiều bố cục bàn phím hoặc phương thức nhập. Nhấp vào nó để chuyển đổi ngôn ngữ nhập; tiếng Nhật hiển thị あ cho hiragana. Đối với các lựa chọn ký tự tiếng Nhật, chuyển sang tiếng Nhật, gõ một từ như `nihongo`, rồi nhấn Space hai lần. Nhấn Enter để chấp nhận lựa chọn của bạn. Nếu bạn cũng có nhiều bố cục bàn phím, hãy nhấp chuột phải vào chỉ báo để luân chuyển chúng.

Dùng _Thiết lập > Gõ > Bố cục bàn phím_ để chọn các bố cục như English và French, từ cùng các lựa chọn được cung cấp trong quá trình cài đặt. Dùng _Thiết lập > Gõ > Phương thức nhập_ để chọn những bộ máy soạn thảo nào đang hoạt động. Cả hai bộ chọn đều mở bên trong menu Omarchy với các lựa chọn hiện tại của bạn đã được đánh dấu. Nhấp hoặc nhấn Enter để bật/tắt một lựa chọn; mỗi thay đổi có hiệu lực ngay lập tức. Bỏ chọn một phương thức nhập sẽ loại bỏ nó khỏi chu trình mà không gỡ cài đặt nó; bàn phím vẫn khả dụng.

Chạy `omarchy setup keyboard` hoặc `omarchy setup input` để mở các bộ chọn tương tự. Để thêm một ngôn ngữ từ dòng lệnh, dùng `omarchy setup input mozc`, `hangul`, `pinyin`, hoặc `chewing`. Các phím chuyển đổi tùy chỉnh của bạn được bảo toàn. Đối với các bố cục hoặc phím thay thế của bộ máy, cài đặt `fcitx5-configtool` bằng `omarchy pkg add fcitx5-configtool` và khởi chạy nó từ một terminal. Việc chọn một ngôn ngữ nhập không thay đổi ngôn ngữ của màn hình nền.

Dùng `Super + I` để luân chuyển qua các phương thức nhập hoặc bố cục bàn phím, và `Super + Shift + I` để đi theo hướng ngược lại, vì vậy với ba thứ đã cấu hình bạn có thể di chuyển giữa hai thứ kề nhau. Chỉ báo đầu vào chỉ xuất hiện ở phía bên phải của thanh khi có nhiều hơn một phương thức nhập hoặc bố cục được cấu hình. Ràng buộc màn hình nền này hoạt động cùng với các phím chuyển đổi Fcitx hiện có của bạn; bạn có thể ghi đè nó trong `~/.config/hypr/bindings.lua`. Các bộ máy nhập và các chuỗi soạn thảo sử dụng dịch vụ [Fcitx5](https://fcitx-im.org/) đã chạy trong mọi phiên.

### Dùng ALT làm SUPER

Trên một số bàn phím, việc dùng phím meta chính (phím Windows/cmd) làm SUPER không thuận tiện. Bạn có thể thay đổi điều này thành ALT thay thế bằng thay đổi này:

```lua
hl.config({
  input = {
    kb_options = "omarchy:shift_caps_compose,altwin:swap_alt_win",
  },
})
```
