# Các công tắc bật/tắt, Chế độ rảnh & Trình bảo vệ màn hình

Phần lớn những thứ bạn thay đổi hằng ngày thực ra không phải là một cài đặt. Đó là một chế độ bạn bật lên trong một giờ rồi lại tắt đi: đèn đêm khi bạn làm việc khuya, không làm phiền khi bạn đang thuyết trình, giữ thức khi bạn đang xem gì đó. Omarchy gọi chúng là các công tắc bật/tắt, và tất cả đều hoạt động theo cùng một cách — một phím tắt, một mục trong menu, và một lệnh, tất cả đều tác động vào cùng một công tắc.

### Menu công tắc bật/tắt

`Super + Ctrl + O` mở trực tiếp _Trigger > Toggle_, hoặc bạn có thể đi tới đó từ menu Omarchy (`Super + Space`). Mọi thứ trong danh sách đó đều là một công tắc bạn có thể bật/tắt mà không cần nghĩ xem trạng thái được lưu ở đâu. Các công tắc cho giao diện của desktop nằm ngay bên cạnh, dưới _Appearance_.

Từ terminal, các công tắc tương tự là `omarchy toggle <thing>`. Chạy riêng `omarchy toggle` để xem toàn bộ nhóm.

| Công tắc | Phím tắt | Lệnh |
| ------ | ------ | ------- |
| Đèn đêm | — | `omarchy toggle nightlight` |
| Tắt tiếng thông báo | `Super + Ctrl + Alt + ,` | `omarchy toggle notification silencing` |
| Giữ thức (không khóa khi rảnh) | `Super + Ctrl + I` | `omarchy toggle idle` |
| Ghi lại sự cố | — | `omarchy toggle crash-capture` |
| Trình bảo vệ màn hình | — | `omarchy toggle screensaver` |
| [Herdr](https://herdr.dev) đồng bộ theme | — | `omarchy toggle theme sync` |
| Thanh menu | `Super + Shift + Space` | `omarchy toggle bar` |
| Desktop toàn màn hình (không thanh, không khoảng trống) | `Super + Ctrl + Alt + F` | `omarchy toggle fullscreen desktop` |
| Hiệu ứng chuyển động, làm mờ và bóng đổ | — | `omarchy toggle animations` |
| Bàn di chuột | `XF86TouchpadToggle` | `omarchy device touchpad` |
| Màn hình cảm ứng | — | `omarchy device touchscreen` |
| Tạm dừng | — | `omarchy toggle suspend` |
| GPU lai | — | `omarchy device gpu hybrid` |

Các công tắc bàn di chuột, màn hình cảm ứng và GPU lai nằm dưới _Trigger > Hardware_ (`Super + Ctrl + H`) thay vì dưới Toggle, vì chúng chỉ xuất hiện khi bạn thực sự có phần cứng đó. Các công tắc bàn di chuột và màn hình cảm ứng vẫn giữ nguyên sau khi Hyprland tải lại — tên của thiết bị đã tắt được lưu vào một file trạng thái nhỏ mà Hyprland đọc lúc khởi động để tắt lại thiết bị đó.

_Appearance_ chứa thanh menu và hiệu ứng chuyển động, cùng một vài thứ không phải là lệnh `omarchy toggle` nhưng hoạt động tương tự: phần trăm pin trên thanh, bố cục workspace mặc định, và dưới _Windows_, khoảng trống giữa các cửa sổ (`Super + Shift + Backspace`) và tỷ lệ vuông 1 cửa sổ (`Super + Ctrl + Backspace`).

Khi Hyprland không có GPU để vẽ và thay vào đó kết xuất bằng CPU (llvmpipe), như trên các máy Mac mà GPU chưa được hỗ trợ, trong hầu hết các máy ảo, hoặc khi driver đồ họa không tải được, Omarchy sẽ tắt hiệu ứng chuyển động, làm mờ và bóng đổ trong phiên đó và thông báo cho bạn một lần bằng một thông báo. _Appearance > Animations On_ sẽ bật lại chúng, và Omarchy cũng ghi nhớ điều đó cho các phiên sau.

Hầu hết các công tắc này chỉ là một file cờ dưới `~/.local/state/omarchy/toggles/`. Nếu bạn muốn rẽ nhánh dựa trên một công tắc trong một script, `omarchy-toggle-enabled` sẽ cho bạn một mã thoát thay vì bắt bạn tự đi tìm:

```bash
omarchy-toggle-enabled screensaver-off && echo "screensaver is off"
```

Các cờ được đặt tên theo trạng thái tắt — `screensaver-off`, `suspend-off`, `bar-off` — vì vậy sự hiện diện của chúng có nghĩa là tính năng đã bị tắt.

### Các chỉ báo trên thanh

Khi một chế độ đang bật, bạn sẽ thấy một biểu tượng nhỏ ở giữa thanh trên cùng, bên cạnh đồng hồ. Đó là widget chỉ báo, và nó chứa ghi màn hình, lời nhắc đang chờ, đèn đêm, không làm phiền, và giữ thức, cùng các cảnh báo khi sudo không cần mật khẩu đang bật hoặc ai đó đang kết nối tới một phiên từ xa.

Các chỉ báo không hoạt động sẽ bị ẩn. Di chuột tới bất kỳ đâu trên thanh và chúng sẽ mờ hiện ra, để bạn có thể nhấp vào một cái để bật nó mà không cần biết phím tắt của nó. Nhấp vào một chỉ báo đang hoạt động sẽ tắt nó trở lại. Nếu bạn muốn luôn thấy tất cả chúng, hãy đặt `alwaysShow` thành `true` trên mục `omarchy.indicators` trong `~/.config/omarchy/shell.json` — xem [thanh trên cùng](05-the-top-bar.md) để biết cách cấu hình các widget trên thanh.

### Đèn đêm

Đèn đêm làm ấm màn hình tới 4000K, và bật/tắt lại sẽ đưa nó trở về 6500K. Bật/tắt nó từ menu công tắc (`Super + Ctrl + O`) hoặc bằng `omarchy toggle nightlight`. Nó được điều khiển bởi hyprsunset, và công tắc sẽ khởi động hyprsunset cho bạn nếu nó chưa chạy.

Theo mặc định, hyprsunset hoàn toàn không làm gì với màn hình của bạn. `~/.config/hypr/hyprsunset.conf` đi kèm với một profile đồng nhất chính xác để màn hình không bị chạm tới cho đến khi bạn yêu cầu sự ấm áp. Nếu bạn muốn nó tự chuyển theo đồng hồ, hãy thay thế profile đó bằng một profile theo thời gian:

```
profile {
    time = 20:00
    temperature = 4000
}
```

Sau đó khởi động hyprsunset lúc đăng nhập bằng cách thêm `o.launch_on_start("hyprsunset")` vào `~/.config/hypr/autostart.lua`. Cặp 4000K/6500K mà công tắc sử dụng là cố định, vì vậy file cấu hình là nơi bạn cần tới nếu muốn một nhiệt độ khác.

### Không làm phiền

`Super + Ctrl + Alt + ,` tắt tiếng thông báo. Không có thông báo nổi nào bật lên khi nó đang bật, và chỉ báo chuông bị gạch chéo nằm trên thanh để nhắc bạn vì sao desktop trở nên yên lặng.

Tuy nhiên, không có gì bị mất. Các thông báo bị tắt tiếng sẽ được giữ lại: đưa vài thông báo gần nhất trở lại màn hình bằng `Super + Shift + Alt + ,`. Xem [thông báo](10-notices.md) để biết phần còn lại.

Ba loại tin nhắn vẫn được phép lọt qua: các thông báo xác nhận của chính Omarchy cho việc bạn vừa làm ("Đã đổi theme", "Đã lưu ảnh chụp màn hình"), các cảnh báo nghiêm trọng được gửi từ dòng lệnh, và mã xác minh. Các ứng dụng chat đánh dấu mọi thứ là nghiêm trọng để ép buộc chen lên trước mặt bạn thì không đủ điều kiện.

### Chế độ rảnh

Shell Omarchy quản lý hành vi khi rảnh, và các mốc thời gian là một khối `idle` ở cấp cao nhất trong `~/.config/omarchy/shell.json`:

```json
{
  "version": 1,
  "idle": {
    "screensaver": 150,
    "lock": 300
  }
}
```

Cả hai con số đều là số giây được tính từ thời điểm bạn bắt đầu rảnh — không phải tính từ nhau. Vì vậy với các giá trị mặc định, trình bảo vệ màn hình xuất hiện sau hai phút rưỡi và màn hình khóa tiếp quản ở phút thứ năm, dù trình bảo vệ màn hình có chạy hay không. Lưu file và shell sẽ áp dụng các mốc thời gian mới ngay lập tức.

Nếu bạn tắt trình bảo vệ màn hình trước thời hạn khóa, điều đó được tính là hoạt động và việc khóa đang chờ sẽ bị hủy. Bạn sẽ không bị khóa chỉ vì liếc nhìn máy của mình.

Để ngừng hoàn toàn việc khóa khi rảnh, `Super + Ctrl + I` — hoặc `omarchy toggle idle` — bật chế độ giữ thức, và chỉ báo tách cà phê xuất hiện trên thanh. Đó là phím cần bấm trước một buổi thuyết trình dài hoặc một bản build bạn muốn theo dõi. Bấm lại để trở về bình thường. `omarchy toggle idle status` in trạng thái hiện tại dưới dạng JSON nếu bạn cần nó từ một script.

Điều này liên quan đến khóa và trình bảo vệ màn hình, không phải nguồn điện. Tạm dừng và ngủ đông có phần thiết lập riêng trong [ngủ hệ thống](36-system-sleep.md).

### Trình bảo vệ màn hình

Trình bảo vệ màn hình của Omarchy là nghệ thuật ASCII chạy qua các hiệu ứng văn bản ngẫu nhiên, mỗi màn hình một thực thể. Bất kỳ phím nào hoặc chuyển động chuột nào cũng thoát khỏi nó.

Bạn có thể khởi động nó theo yêu cầu từ _System > Screensaver_ (`Super + Esc`), thao tác này ép nó hiện lên ngay cả khi bạn đã tắt trình bảo vệ màn hình khi rảnh. Theo mặc định, không có phím tắt nào được gán cho nó.

`omarchy toggle screensaver` là lệnh tắt trình bảo vệ màn hình khi rảnh, nếu bạn muốn đi thẳng từ đang làm việc tới bị khóa. Bất kỳ phím, cú nhấp, cuộn hoặc chuyển động chuột nào cũng đóng nó.

Logo mà nó vẽ là của bạn để thay đổi, dưới _Appearance > Branding > Screensaver_. Tải lên một png hoặc svg và Omarchy sẽ chuyển đổi nó thành ASCII. Xem [nhận diện thương hiệu](41-branding.md).

### Màn hình khóa

`Super + Ctrl + L` khóa máy. Thao tác đó chạy màn hình khóa từ shell Omarchy, làm trống màn hình, đặt lại bố cục bàn phím của bạn về bố cục đầu tiên để bạn không gõ mật khẩu bằng bảng chữ cái sai, và — nếu bạn đang chạy nó — khóa 1Password trên đường thoát.

Màn hình khóa chấp nhận mật khẩu, và nó cũng sẽ chấp nhận dấu vân tay một khi bạn đã thiết lập một dấu. Điều đó, và các cách xác thực khác, được trình bày trong [xác thực phần cứng](37-hardware-authentication.md).
