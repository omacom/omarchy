# Các công tắc bật/tắt, Idle & Trình bảo vệ màn hình

Nhiều thứ bạn thay đổi hằng ngày thực ra không phải là một cài đặt. Đó là một chế độ bạn bật lên trong một giờ rồi lại tắt đi: ánh sáng ban đêm khi bạn làm việc muộn, không làm phiền khi bạn đang thuyết trình, giữ thức khi bạn đang xem gì đó. Omarchy gọi những thứ đó là toggle, và tất cả chúng đều hoạt động theo cùng một cách — một phím tắt, một mục trong menu, và một lệnh, tất cả đều tác động lên cùng một công tắc.

### Menu toggle

`Super + Ctrl + O` mở trực tiếp _Trigger > Toggle_, hoặc bạn có thể đi tới đó từ menu Omarchy (`Super + Space`). Mọi thứ trong danh sách đó đều là một công tắc bạn có thể bật/tắt mà không cần nghĩ về nơi trạng thái được lưu trữ. Các công tắc cho cách desktop trông như thế nào nằm ngay bên cạnh nó, dưới _Appearance_.

Từ terminal, các công tắc tương tự là `omarchy toggle <thing>`. Chạy `omarchy toggle` riêng lẻ để xem toàn bộ nhóm.

| Toggle | Hotkey | Command |
| ------ | ------ | ------- |
| Ánh sáng ban đêm | — | `omarchy toggle nightlight` |
| Tắt tiếng thông báo | `Super + Ctrl + Alt + ,` | `omarchy toggle notification silencing` |
| Giữ thức (không khóa khi idle) | `Super + Ctrl + I` | `omarchy toggle idle` |
| Ghi lại sự cố | — | `omarchy toggle crash-capture` |
| Trình bảo vệ màn hình | — | `omarchy toggle screensaver` |
| Đồng bộ theme [Herdr](https://herdr.dev) | — | `omarchy toggle theme sync` |
| Thanh menu | `Super + Shift + Space` | `omarchy toggle bar` |
| Touchpad | `XF86TouchpadToggle` | `omarchy toggle touchpad` |
| Màn hình cảm ứng | — | `omarchy toggle touchscreen` |
| Suspend | — | `omarchy toggle suspend` |
| Hybrid GPU | — | `omarchy toggle hybrid gpu` |

Các công tắc touchpad, màn hình cảm ứng, và hybrid GPU nằm dưới _Trigger > Hardware_ (`Super + Ctrl + H`) chứ không phải dưới Toggle, vì chúng chỉ xuất hiện khi bạn thực sự có phần cứng đó. Các công tắc touchpad và màn hình cảm ứng vẫn tồn tại sau khi Hyprland tải lại — tên của thiết bị đã tắt được lưu vào một file trạng thái nhỏ mà Hyprland đọc khi khởi động để tắt nó lại.

_Appearance_ chứa thanh menu và hiệu ứng chuyển động, cộng với một vài thứ không phải là lệnh `omarchy toggle` nhưng hoạt động giống như vậy: phần trăm pin trong thanh, bố cục workspace mặc định, và dưới _Windows_, khoảng cách cửa sổ (`Super + Shift + Backspace`) và tỷ lệ khung hình vuông 1 cửa sổ (`Super + Ctrl + Backspace`).

Hầu hết những thứ này chỉ là một file cờ dưới `~/.local/state/omarchy/toggles/`. Nếu bạn muốn rẽ nhánh dựa trên một trong số chúng trong một script, `omarchy-toggle-enabled` cung cấp cho bạn mã thoát thay vì bắt bạn phải đi tìm:

```bash
omarchy-toggle-enabled screensaver-off && echo "screensaver is off"
```

Các cờ được đặt tên cho trạng thái tắt — `screensaver-off`, `suspend-off`, `bar-off` — vì vậy sự hiện diện của chúng có nghĩa là tính năng đã bị tắt.

### Các chỉ báo trong thanh

Khi một chế độ đang bật, bạn nhận được một ký tự nhỏ ở giữa thanh trên cùng bên cạnh đồng hồ. Đó là widget chỉ báo, và nó mang theo tính năng đọc chính tả, quay màn hình, lời nhắc đang chờ, ánh sáng ban đêm, không làm phiền, và giữ thức.

Các chỉ báo không hoạt động sẽ bị ẩn. Di chuột lên bất cứ đâu trên thanh và chúng sẽ mờ dần hiện ra, để bạn có thể nhấp vào một cái để bật nó lên mà không cần biết phím tắt của nó. Nhấp vào một chỉ báo đang hoạt động sẽ tắt nó trở lại. Nếu bạn muốn luôn thấy tất cả chúng mọi lúc, hãy đặt `alwaysShow` thành `true` trên mục `omarchy.indicators` trong `~/.config/omarchy/shell.json` — xem [thanh trên cùng](05-the-top-bar.md) để biết cách các widget trên thanh được cấu hình.

### Ánh sáng ban đêm

Ánh sáng ban đêm làm ấm màn hình lên 4000K, và bật/tắt lại sẽ đưa nó trở về 6500K. Bật/tắt nó từ menu toggle (`Super + Ctrl + O`) hoặc bằng `omarchy toggle nightlight`. Nó được điều khiển bởi hyprsunset, mà công tắc sẽ khởi động cho bạn nếu nó chưa chạy.

Theo mặc định, hyprsunset hoàn toàn không làm gì với màn hình của bạn. `~/.config/hypr/hyprsunset.conf` đi kèm với một hồ sơ danh tính chính xác để màn hình vẫn không bị động vào cho đến khi bạn yêu cầu sự ấm áp. Nếu bạn muốn nó chuyển đổi theo đồng hồ, hãy thay thế nó bằng một hồ sơ thời gian:

```
profile {
    time = 20:00
    temperature = 4000
}
```

Sau đó khởi động hyprsunset khi đăng nhập bằng cách thêm `o.launch_on_start("hyprsunset")` vào `~/.config/hypr/autostart.lua`. Cặp 4000K/6500K được sử dụng bởi công tắc là cố định, vì vậy file cấu hình là nơi bạn đến nếu bạn muốn một nhiệt độ khác.

### Không làm phiền

`Super + Ctrl + Alt + ,` tắt tiếng thông báo. Không có thông báo bật lên nào xuất hiện khi nó đang bật, và chỉ báo chuông bị gạch chéo nằm trong thanh để nhắc bạn tại sao desktop đã trở nên yên tĩnh.

Tuy nhiên, không có gì bị mất. Các thông báo bị tắt tiếng sẽ bị giữ lại: đưa vài thông báo cuối cùng trở lại màn hình bằng `Super + Shift + Alt + ,`. Xem [thông báo](10-notices.md) để biết phần còn lại.

Hai loại tin nhắn vẫn được phép thông qua: các thông báo xác nhận của chính Omarchy cho việc bạn vừa làm ("Theme changed", "Screenshot saved"), và các cảnh báo quan trọng được gửi từ dòng lệnh. Các ứng dụng trò chuyện đánh dấu mọi thứ là quan trọng để ép buộc xuất hiện trước mặt bạn không đủ điều kiện.

### Idle

Shell Omarchy sở hữu hành vi idle, và thời gian là một khối `idle` cấp cao nhất trong `~/.config/omarchy/shell.json`:

```json
{
  "version": 1,
  "idle": {
    "screensaver": 150,
    "lock": 300
  }
}
```

Cả hai con số đều là giây được tính từ thời điểm bạn chuyển sang idle — không phải tính từ nhau. Vì vậy với các giá trị mặc định, trình bảo vệ màn hình xuất hiện sau hai phút rưỡi và màn hình khóa tiếp quản ở phút thứ năm, bất kể trình bảo vệ màn hình có chạy hay không. Lưu file và shell sẽ nhận thời gian mới ngay lập tức.

Nếu bạn tắt trình bảo vệ màn hình trước thời hạn khóa, điều đó được tính là hoạt động và việc khóa đang chờ sẽ bị hủy. Bạn không bị khóa ngoài vì liếc nhìn máy của mình.

Để ngừng khóa khi idle hoàn toàn, `Super + Ctrl + I` — hoặc `omarchy toggle idle` — bật chế độ giữ thức, và chỉ báo tách cà phê xuất hiện trong thanh. Đó là cái cần nhấn trước một buổi thuyết trình dài hoặc một bản build bạn muốn theo dõi. Nhấn lại để quay lại bình thường. `omarchy toggle idle status` in trạng thái hiện tại dưới dạng JSON nếu bạn cần nó từ một script.

Điều này là về khóa và trình bảo vệ màn hình, không phải về nguồn điện. Suspend và hibernation có thiết lập riêng trong [system sleep](36-system-sleep.md).

### Trình bảo vệ màn hình

Trình bảo vệ màn hình của Omarchy là nghệ thuật ASCII chạy qua các hiệu ứng văn bản ngẫu nhiên, một phiên bản cho mỗi màn hình. Bất kỳ phím hoặc chuyển động chuột nào cũng thoát khỏi nó.

Bạn có thể khởi động nó theo yêu cầu từ _System > Screensaver_ (`Super + Esc`), điều này buộc nó xuất hiện ngay cả khi bạn đã tắt trình bảo vệ màn hình idle. Theo mặc định, không có phím tắt nào được gán cho nó.

`omarchy toggle screensaver` là thứ tắt trình bảo vệ màn hình idle, nếu bạn muốn đi thẳng từ làm việc đến bị khóa. Nó cần một terminal mà nó biết cách cấu hình — Alacritty, Foot, Ghostty, hoặc Kitty — và sẽ cho bạn biết nếu terminal mặc định của bạn là một thứ khác.

Logo mà nó vẽ là của bạn để thay đổi, dưới _Appearance > Branding > Screensaver_. Tải lên một png hoặc svg và Omarchy chuyển đổi nó thành ASCII. Xem [branding](41-branding.md).

### Màn hình khóa

`Super + Ctrl + L` khóa máy. Điều đó chạy màn hình khóa từ shell Omarchy, làm trống màn hình, đặt lại bố cục bàn phím của bạn về bố cục đầu tiên để bạn không gõ mật khẩu của mình bằng bảng chữ cái sai, và — nếu bạn đang chạy nó — khóa 1Password trên đường ra.

Màn hình khóa chấp nhận mật khẩu, và nó cũng sẽ chấp nhận dấu vân tay sau khi bạn đã thiết lập một cái. Điều đó, và các cách khác để xác thực, được đề cập trong [hardware authentication](37-hardware-authentication.md).
