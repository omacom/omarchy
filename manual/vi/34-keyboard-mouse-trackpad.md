# Bàn phím, Chuột, Trackpad

Hyprland cho phép bạn cấu hình mọi thiết bị đầu vào của mình rất chi tiết. Bạn có thể thay đổi tốc độ lặp phím thành nhanh siêu tốc hoặc khiến trackpad dùng cuộn tự nhiên. Bạn thay đổi tất cả trong `~/.config/hypr/input.lua`, nơi bạn cũng có thể truy cập qua _Setup > Input_ trong menu Omarchy (`Super + Space`). Bất cứ thứ gì bạn đặt ở đó sẽ thay thế mặc định của Omarchy.

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

Bạn có thể [xem mọi tùy chọn đầu vào](https://wiki.hypr.land/Configuring/Basics/Variables/#input) trên wiki Hyprland dành cho đầu vào.

CapsLock hoạt động như một phím Caps Lock bình thường, và `Shift + CapsLock` là phím compose cho [emoji nhanh](07-hotkeys.md#quick-emojis) và [các cách hoàn thiện khác](07-hotkeys.md#quick-completions). Nếu bạn muốn đặt phím compose ở nơi khác, hãy thay thế `omarchy:shift_caps_compose` trong `kb_options`. Ví dụ, đoạn này chuyển phím compose sang Right Alt:

```lua
hl.config({
  input = {
    kb_options = "compose:ralt",
  },
})
```

### Cử chỉ trackpad

Vuốt trên trackpad để di chuyển quanh màn hình desktop:

| Cử chỉ | Hành động |
| --- | --- |
| Ba ngón sang trái / phải | Workspace trước / tiếp theo, kể cả workspace trống |
| Ba ngón lên | Bật/tắt bảng điều khiển AI |
| Ba ngón xuống | Mở menu Omarchy |
| Bốn ngón sang trái / phải | Di chuyển cửa sổ đang hoạt động tới workspace trước / tiếp theo |
| Bốn ngón xuống | Bật/tắt toàn màn hình |

Để thay đổi một cử chỉ, hãy bỏ đặt nó trong `~/.config/hypr/input.lua` trước khi thêm [cử chỉ trackpad](https://wiki.hypr.land/Configuring/Advanced-and-Cool/Gestures/) của riêng bạn, vì Hyprland sẽ không chấp nhận hai cử chỉ trên cùng số ngón tay và cùng hướng:

```lua
hl.gesture({ fingers = 3, direction = "up", action = "unset" })
hl.gesture({ fingers = 3, direction = "up", action = "fullscreen" })
```

Để tắt mọi cử chỉ của Omarchy, hãy đặt `omarchy_default_gestures = false` gần đầu `~/.config/hypr/hyprland.lua`, trước khi các mặc định của Omarchy được tải.

Trên laptop Dell XPS có trackpad xúc giác, bạn cũng có thể đặt độ mạnh của cú nhấp thành low, mid, hoặc high trong _Trigger > Hardware > Touchpad Haptics_.

### Gõ tiếng Trung, tiếng Nhật và các ngôn ngữ khác

Hãy chọn Japanese, Korean, Chinese (Simplified, Pinyin), Taiwan (Zhuyin), hoặc Hong Kong (Cangjie) khi trình cài đặt hỏi về bàn phím của bạn. Omarchy tự động cấu hình bàn phím và engine nhập liệu khớp với lựa chọn đó, kể cả trong quá trình thiết lập lần khởi động đầu tiên ngoại tuyến. Tiếng Nhật dùng Mozc, tiếng Hàn dùng Hangul hai bộ tiêu chuẩn, tiếng Trung giản thể dùng Pinyin, Đài Loan dùng bố cục Zhuyin tiêu chuẩn của Chewing, và Hong Kong dùng Cangjie với dạng ký tự Hong Kong. Japanese (US keyboard) cung cấp Mozc với bố cục bàn phím US. Các phím Hangul, Zhuyin và Cangjie vẫn giữ nguyên vị trí tiêu chuẩn ngay cả khi bạn gõ ký tự Latin bằng Dvorak, Colemak hoặc AZERTY. Nếu bạn đã thêm Hangul hoặc Chewing trước đó, hãy bỏ chọn rồi chọn lại nó trong _Setup > Typing > Input Methods_ để dời các phím của nó tới đó; Omarchy sẽ để yên một engine mà bạn đã dùng để gõ.

Việc gõ bắt đầu ở chế độ Latin. Nhấn `Super + I` để luân chuyển qua các phương thức nhập đã cấu hình, và `Super + Shift + I` để luân chuyển ngược lại. Chạm `Shift` một mình để bước ra khỏi một phương thức nhập như Pinyin sang ký tự Latin, và chạm lại lần nữa để quay lại, giống cách Sogou, Microsoft Pinyin và macOS hoạt động; `Shift` cộng với một chữ cái vẫn gõ chữ hoa. Trên bàn phím tiếng Nhật, 全角/半角 bật/tắt nhập liệu, 変換 bật nó, và 無変換 tắt nó. Với tiếng Hàn, 한/영 chuyển đổi Hangul và 한자 chuyển sang Hanja, dù bàn phím của bạn có phím chuyên dụng hay gửi Right Alt và Right Ctrl cho chúng, như nhiều laptop vẫn làm, nên Right Alt và Right Ctrl không phải là phím bổ trợ đơn thuần ở đó; việc đọc chính tả bật/tắt bằng Alt + Space thay thế. `Ctrl + Space` vẫn khả dụng cho Tmux và Herdr; `Shift + CapsLock` vẫn là phím compose.

Chỉ báo bàn phím xuất hiện ở bên phải của thanh khi bạn có nhiều bố cục bàn phím hoặc phương thức nhập. Nhấp vào nó để chuyển ngôn ngữ nhập; tiếng Nhật hiển thị あ cho hiragana. Để chọn ký tự tiếng Nhật, hãy chuyển sang Japanese, gõ một từ như `nihongo`, rồi nhấn Space hai lần. Nhấn Enter để chấp nhận lựa chọn của bạn. Nếu bạn cũng có nhiều bố cục bàn phím, hãy nhấp chuột phải vào chỉ báo để luân chuyển qua chúng.

Dùng _Setup > Typing > Keyboard Layouts_ để chọn các bố cục như English và French, từ cùng những lựa chọn được đưa ra trong lúc cài đặt. Dùng _Setup > Typing > Input Methods_ để chọn engine soạn thảo nào đang hoạt động. Cả hai trình chọn đều mở bên trong menu Omarchy với các lựa chọn hiện tại của bạn đã được đánh dấu. Nhấp hoặc nhấn Enter để bật/tắt một lựa chọn; mỗi thay đổi áp dụng ngay lập tức. Bỏ chọn một phương thức nhập sẽ loại nó khỏi vòng luân chuyển mà không gỡ cài đặt nó; bàn phím vẫn khả dụng.

Chạy `omarchy setup keyboard` hoặc `omarchy setup input` để mở cùng các trình chọn đó. Để thêm một ngôn ngữ từ dòng lệnh, hãy dùng `omarchy setup input mozc`, `hangul`, `pinyin`, `chewing`, hoặc `cangjie5`. Quick, Boshiamy và Array nằm trong cùng gói với Cangjie và xuất hiện trong trình chọn Input Methods. Các phím chuyển đổi tùy chỉnh của bạn được giữ nguyên. Đối với bố cục hoặc phím engine thay thế, hãy cài đặt `fcitx5-configtool` bằng `omarchy pkg add fcitx5-configtool` và khởi chạy nó từ terminal. Chọn một ngôn ngữ nhập không thay đổi ngôn ngữ desktop. Chọn Japanese, Korean, hoặc Chinese trong _Setup > Language_ sẽ thêm phương thức nhập của nó khi bạn chưa có phương thức nào.

Dùng `Super + I` để luân chuyển qua các phương thức nhập hoặc bố cục bàn phím, và `Super + Shift + I` để đi ngược lại, nên khi đã cấu hình ba mục, bạn có thể di chuyển giữa hai mục kề nhau. Chỉ báo đầu vào chỉ xuất hiện ở bên phải của thanh khi có nhiều hơn một phương thức nhập hoặc bố cục được cấu hình. Phím tắt desktop này hoạt động cùng với các phím chuyển đổi Fcitx hiện có của bạn; bạn có thể ghi đè nó trong `~/.config/hypr/bindings.lua`. Các engine nhập liệu và chuỗi compose dùng dịch vụ [Fcitx5](https://fcitx-im.org/) đã chạy trong mọi phiên.

### Dùng ALT làm SUPER

Trên một số bàn phím, việc dùng phím meta chính (phím Windows/cmd) làm SUPER không thuận tiện. Bạn có thể thay đổi nó thành ALT thay thế bằng thay đổi này:

```lua
hl.config({
  input = {
    kb_options = "omarchy:shift_caps_compose,altwin:swap_alt_win",
  },
})
```
