# Bật/tắt, Nhàn rỗi & Trình bảo vệ màn hình

Rất nhiều thứ bạn thay đổi hằng ngày không thực sự là một cài đặt. Đó là một chế độ bạn bật trong một giờ rồi tắt đi: đèn đêm trong khi bạn làm việc muộn, không làm phiền trong khi bạn đang thuyết trình, giữ thức trong khi bạn đang xem thứ gì đó. Omarchy gọi đó là các chuyển đổi, và tất cả chúng đều hoạt động theo cùng một cách — một phím tắt, một mục menu và một lệnh, tất cả đều chạm tới cùng một công tắc.

### Menu bật/tắt

`Super + Ctrl + O` mở _Kích hoạt > Bật/tắt_ trực tiếp, hoặc bạn có thể đi tới đó từ menu Omarchy (`Super + Space`). Mọi thứ trong danh sách đó đều là một công tắc bạn có thể lật mà không cần nghĩ về nơi trạng thái tồn tại. Các công tắc cho cách desktop trông như thế nào nằm bên cạnh nó, trong _Kích hoạt > Giao diện_.

Từ terminal, các công tắc tương tự là `omarchy toggle <thing>`. Chạy `omarchy toggle` riêng để xem toàn bộ nhóm.

| Chuyển đổi | Phím tắt | Lệnh |
| ------ | ------ | ------- |
| Đèn đêm | `Super + Ctrl + N` | `omarchy toggle nightlight` |
| Tắt thông báo | `Super + Ctrl + ,` | `omarchy toggle notification silencing` |
| Giữ thức (không khóa khi nhàn rỗi) | `Super + Ctrl + I` | `omarchy toggle idle` |
| Ghi sự cố | — | `omarchy toggle crash-capture` |
| Trình bảo vệ màn hình | — | `omarchy toggle screensaver` |
| Đồng bộ chủ đề [Herdr](https://herdr.dev) | — | `omarchy toggle theme sync` |
| Thanh menu | `Super + Shift + Space` | `omarchy toggle bar` |
| Bàn di chuột | `XF86TouchpadToggle` | `omarchy toggle touchpad` |
| Màn hình cảm ứng | — | `omarchy toggle touchscreen` |
| Tạm dừng | — | `omarchy toggle suspend` |
| GPU lai | — | `omarchy toggle hybrid gpu` |

Các công tắc bàn di chuột, màn hình cảm ứng và GPU lai nằm trong _Kích hoạt > Phần cứng_ (`Super + Ctrl + H`) thay vì trong Bật/tắt, vì chúng chỉ xuất hiện khi bạn thực sự có phần cứng đó. Các công tắc bàn di chuột và màn hình cảm ứng tồn tại sau khi Hyprland tải lại — tên của thiết bị đã vô hiệu hóa được lưu vào một tệp trạng thái nhỏ mà Hyprland đọc khi khởi động để vô hiệu hóa nó lần nữa.

_Kích hoạt > Giao diện_ chứa thanh menu và hiệu ứng, cộng với một vài thứ không phải là lệnh `omarchy toggle` nhưng hành xử tương tự: phần trăm pin trên thanh, bố cục không gian làm việc mặc định, khoảng cách cửa sổ (`Super + Shift + Backspace`), và tỷ lệ khung hình vuông 1 cửa sổ (`Super + Ctrl + Backspace`).

Hầu hết những thứ này chỉ là một tệp cờ trong `~/.local/state/omarchy/toggles/`. Nếu bạn muốn phân nhánh theo một cờ trong một tập lệnh, `omarchy-toggle-enabled` cho bạn một mã thoát thay vì bắt bạn đi tìm:

```bash
omarchy-toggle-enabled screensaver-off && echo "screensaver is off"
```

Các cờ được đặt tên theo trạng thái tắt — `screensaver-off`, `suspend-off`, `bar-off` — vì vậy sự hiện diện của chúng có nghĩa là tính năng đã bị vô hiệu hóa.

### Chỉ báo trên thanh

Khi một chế độ đang bật, bạn nhận được một ký tự nhỏ ở giữa thanh trên cùng bên cạnh đồng hồ. Đó là tiện ích chỉ báo, và nó mang theo đọc chính tả, ghi màn hình, lời nhắc đang chờ, đèn đêm, không làm phiền và giữ thức.

Các chỉ báo không hoạt động bị ẩn. Di chuột vào khu vực xung quanh chúng và chúng hiện ra mờ, vì vậy bạn có thể nhấp vào một chỉ báo để bật nó mà không cần biết phím tắt của nó. Nhấp vào một chỉ báo đang hoạt động sẽ tắt nó. Nếu bạn muốn thấy tất cả chúng mọi lúc, đặt `alwaysShow` thành `true` trên mục `omarchy.indicators` trong `~/.config/omarchy/shell.json` — xem [thanh trên cùng](05-the-top-bar.md) để biết cách các tiện ích thanh được cấu hình.

### Đèn đêm

`Super + Ctrl + N` làm ấm màn hình tới 4000K, và nhấn lại đưa nó trở lại 6500K. Nó được điều khiển bởi hyprsunset, chương trình mà chuyển đổi khởi động cho bạn nếu nó chưa chạy.

Theo mặc định hyprsunset hoàn toàn không làm gì với màn hình của bạn. `~/.config/hypr/hyprsunset.conf` đi kèm với một cấu hình danh tính chính xác để màn hình không bị chạm tới cho đến khi bạn yêu cầu sự ấm áp. Nếu bạn muốn nó chuyển đổi theo đồng hồ, thay thế điều đó bằng một cấu hình theo thời gian:

```
profile {
    time = 20:00
    temperature = 4000
}
```

Sau đó khởi động hyprsunset khi đăng nhập bằng cách thêm `o.launch_on_start("hyprsunset")` vào `~/.config/hypr/autostart.lua`. Cặp 4000K/6500K được dùng bởi chuyển đổi là cố định, vì vậy tệp cấu hình là nơi bạn đến nếu bạn muốn một nhiệt độ khác.

### Không làm phiền

`Super + Ctrl + ,` tắt thông báo. Không có thông báo bật lên nào xuất hiện trong khi nó đang bật, và chỉ báo chuông bị gạch chéo nằm trên thanh để nhắc bạn lý do desktop đã im lặng.

Tuy nhiên, không có gì bị mất. Một thông báo bị tắt tiếng được ghi thẳng vào lịch sử thông báo của bạn, đó chính xác là bản ghi bạn muốn khi bạn quay lại và tự hỏi mình đã bỏ lỡ điều gì. Mở nó bằng `Super + Shift + Alt + ,`. Xem [thông báo nhanh](10-notices.md) để biết phần còn lại của câu chuyện thông báo.

Hai loại thông báo vẫn lọt qua: các thông báo xác nhận của riêng Omarchy cho thứ gì đó bạn vừa làm ("Đã thay đổi chủ đề", "Đã lưu ảnh chụp màn hình"), và các cảnh báo quan trọng được gửi từ dòng lệnh. Các ứng dụng trò chuyện đánh dấu mọi thứ là quan trọng để ép mình lên trước mặt bạn thì không đủ điều kiện.

### Nhàn rỗi

Shell Omarchy sở hữu hành vi nhàn rỗi, và các thời gian là một khối `idle` ở cấp cao nhất trong `~/.config/omarchy/shell.json`:

```json
{
  "version": 1,
  "idle": {
    "screensaver": 150,
    "lock": 300
  }
}
```

Cả hai con số đều là giây được đếm từ thời điểm bạn nhàn rỗi — không phải từ nhau. Vì vậy với các mặc định, trình bảo vệ màn hình xuất hiện sau hai phút rưỡi và màn hình khóa tiếp quản ở năm phút, dù trình bảo vệ màn hình có chạy hay không. Lưu tệp và shell tiếp nhận các thời gian mới ngay lập tức.

Nếu bạn loại bỏ trình bảo vệ màn hình trước thời hạn khóa, điều đó được tính là hoạt động và khóa đang chờ bị hủy. Bạn không bị khóa ngoài vì liếc nhìn máy của mình.

Để dừng hoàn toàn việc khóa khi nhàn rỗi, `Super + Ctrl + I` — hoặc `omarchy toggle idle` — bật giữ thức, và chỉ báo tách cà phê xuất hiện trên thanh. Đó là cái cần nhấn trước một buổi thuyết trình dài hoặc một bản dựng bạn muốn xem. Nhấn lại để quay lại bình thường. `omarchy toggle idle status` in trạng thái hiện tại dưới dạng JSON nếu bạn cần nó từ một tập lệnh.

Điều này liên quan đến việc khóa và trình bảo vệ màn hình, không phải nguồn điện. Tạm dừng và ngủ đông có thiết lập riêng trong [ngủ hệ thống](36-system-sleep.md).

### Trình bảo vệ màn hình

Trình bảo vệ màn hình của Omarchy là nghệ thuật ASCII chạy qua các hiệu ứng văn bản ngẫu nhiên, một phiên bản cho mỗi màn hình. Bất kỳ phím hoặc chuyển động chuột nào cũng thoát khỏi nó.

Bạn có thể khởi động nó theo yêu cầu từ _Hệ thống > Bảo vệ màn hình_ (`Super + Esc`), điều này ép nó xuất hiện ngay cả khi bạn đã tắt trình bảo vệ màn hình khi nhàn rỗi. Không có phím tắt nào được gán cho nó theo mặc định.

`omarchy toggle screensaver` là lệnh tắt trình bảo vệ khi nhàn rỗi, nếu bạn muốn đi thẳng từ làm việc sang bị khóa. Nó cần một terminal mà nó biết cách cấu hình — Alacritty, Foot, Ghostty hoặc Kitty — và sẽ cho bạn biết như vậy nếu terminal mặc định của bạn là thứ khác.

Logo nó vẽ là của bạn để thay đổi, trong _Phong cách > Bảo vệ màn hình_. Tải lên một tệp png hoặc svg và Omarchy chuyển đổi nó thành ASCII. Xem [thương hiệu](41-branding.md).

### Màn hình khóa

`Super + Ctrl + L` khóa máy. Điều đó chạy màn hình khóa từ shell Omarchy, làm trống màn hình, đặt lại bố cục bàn phím của bạn về bố cục đầu tiên để bạn không gõ mật khẩu bằng bảng chữ cái sai, và — nếu bạn đang chạy nó — khóa 1Password trên đường ra.

Màn hình khóa nhận một mật khẩu, và nó cũng sẽ nhận một dấu vân tay khi bạn đã thiết lập một dấu. Điều đó, và các cách khác để xác thực, được trình bày trong [xác thực phần cứng](37-hardware-authentication.md).
