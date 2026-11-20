# Công tắc bật/tắt, Idle và Trình bảo vệ màn hình

Phần lớn những thứ bạn thay đổi hằng ngày thực ra không phải là một cài đặt. Đó là một chế độ bạn bật lên trong một giờ rồi lại tắt đi: đèn đêm khi bạn làm việc khuya, không làm phiền khi bạn đang thuyết trình, giữ tỉnh táo khi bạn đang xem gì đó. Omarchy gọi những thứ đó là công tắc bật/tắt, và tất cả chúng đều hoạt động theo cùng một cách — một phím tắt, một mục trong menu, và một lệnh, tất cả đều tác động lên cùng một công tắc.

### Menu công tắc bật/tắt

`Super + Ctrl + O` mở trực tiếp _Trigger > Toggle_, hoặc bạn có thể đi tới đó từ menu Omarchy (`Super + Space`). Mọi thứ trong danh sách đó đều là một công tắc bạn có thể bật/tắt mà không cần nghĩ xem trạng thái được lưu ở đâu. Các công tắc cho cách desktop hiển thị nằm ngay bên cạnh, dưới _Appearance_.

Từ terminal, các công tắc tương tự là `omarchy toggle <thing>`. Chạy `omarchy toggle` một mình để xem toàn bộ nhóm.

| Công tắc | Phím tắt | Lệnh |
| ------ | ------ | ------- |
| Đèn đêm | — | `omarchy toggle nightlight` |
| Tắt tiếng thông báo | `Super + Ctrl + Alt + ,` | `omarchy toggle notification silencing` |
| Giữ tỉnh táo (không khóa khi idle) | `Super + Ctrl + I` | `omarchy toggle idle` |
| Ghi lại sự cố | — | `omarchy toggle crash-capture` |
| Trình bảo vệ màn hình | — | `omarchy toggle screensaver` |
| Đồng bộ theme của [Herdr](https://herdr.dev) | — | `omarchy toggle theme sync` |
| Thanh menu | `Super + Shift + Space` | `omarchy toggle bar` |
| Bàn di chuột | `XF86TouchpadToggle` | `omarchy device touchpad` |
| Màn hình cảm ứng | — | `omarchy device touchscreen` |
| Tạm dừng hệ thống | — | `omarchy toggle suspend` |
| GPU lai | — | `omarchy toggle hybrid gpu` |

Các công tắc bàn di chuột, màn hình cảm ứng và GPU lai nằm dưới _Trigger > Hardware_ (`Super + Ctrl + H`) thay vì dưới Toggle, vì chúng chỉ xuất hiện khi bạn thực sự có phần cứng đó. Các công tắc bàn di chuột và màn hình cảm ứng vẫn duy trì sau khi Hyprland tải lại — tên của thiết bị đã tắt được lưu vào một tệp trạng thái nhỏ mà Hyprland đọc lúc khởi động để tắt nó lại.

_Appearance_ chứa thanh menu và hoạt ảnh, cùng một vài thứ không phải là lệnh `omarchy toggle` nhưng hoạt động giống như vậy: phần trăm pin trên thanh, bố cục workspace mặc định, và dưới _Windows_, khoảng cách giữa các cửa sổ (`Super + Shift + Backspace`) và tỉ lệ khung hình vuông cho 1 cửa sổ (`Super + Ctrl + Backspace`).

Khi Hyprland không có GPU để vẽ và thay vào đó kết xuất bằng CPU (llvmpipe), như trên các máy Mac mà GPU chưa được hỗ trợ, trong hầu hết các máy ảo, hoặc khi driver đồ họa không tải được, Omarchy tắt hoạt ảnh, hiệu ứng mờ và bóng đổ cho phiên đó và thông báo cho bạn một lần bằng một thông báo. _Appearance > Animations On_ sẽ bật chúng trở lại, và Omarchy cũng ghi nhớ điều đó cho các phiên sau.

Hầu hết những thứ này chỉ là một tệp cờ dưới `~/.local/state/omarchy/toggles/`. Nếu bạn muốn rẽ nhánh dựa trên một cờ trong một script, `omarchy-toggle-enabled` sẽ cho bạn một mã thoát thay vì bắt bạn tự đi tìm:

```bash
omarchy-toggle-enabled screensaver-off && echo "screensaver is off"
```

Các cờ được đặt tên theo trạng thái tắt — `screensaver-off`, `suspend-off`, `bar-off` — nên sự hiện diện của chúng có nghĩa là tính năng đã bị tắt.

### Các chỉ báo trên thanh

Khi một chế độ đang bật, bạn sẽ thấy một glyph nhỏ ở giữa thanh trên cùng, bên cạnh đồng hồ. Đó là widget chỉ báo, và nó mang theo đọc chính tả, ghi màn hình, nhắc nhở đang chờ, đèn đêm, không làm phiền và giữ tỉnh táo.

Các chỉ báo không hoạt động sẽ bị ẩn. Di chuột lên bất kỳ đâu trên thanh và chúng sẽ hiện mờ dần, để bạn có thể nhấp vào một cái để bật nó mà không cần biết phím tắt của nó. Nhấp vào một chỉ báo đang hoạt động sẽ tắt nó trở lại. Nếu bạn muốn luôn thấy tất cả chúng, hãy đặt `alwaysShow` thành `true` trên mục `omarchy.indicators` trong `~/.config/omarchy/shell.json` — xem [thanh trên cùng](05-the-top-bar.md) để biết cách cấu hình các widget trên thanh.

### Đèn đêm

Đèn đêm làm màn hình ấm hơn ở 4000K, và bật/tắt lại sẽ đưa nó về 6500K. Bật/tắt nó từ menu công tắc bật/tắt (`Super + Ctrl + O`) hoặc bằng `omarchy toggle nightlight`. Nó được điều khiển bởi hyprsunset, thứ mà công tắc sẽ khởi động cho bạn nếu nó chưa chạy.

Mặc định hyprsunset hoàn toàn không làm gì với màn hình của bạn. `~/.config/hypr/hyprsunset.conf` đi kèm với một profile danh tính chính xác để màn hình vẫn không bị động vào cho đến khi bạn yêu cầu sự ấm áp. Nếu bạn muốn nó chuyển theo đồng hồ, hãy thay thế bằng một profile theo thời gian:

```
profile {
    time = 20:00
    temperature = 4000
}
```

Sau đó khởi động hyprsunset lúc đăng nhập bằng cách thêm `o.launch_on_start("hyprsunset")` vào `~/.config/hypr/autostart.lua`. Cặp 4000K/6500K mà công tắc sử dụng là cố định, nên tệp cấu hình là nơi bạn đến nếu muốn một nhiệt độ khác.

### Không làm phiền

`Super + Ctrl + Alt + ,` tắt tiếng thông báo. Không có toast nào bật lên khi nó đang bật, và chỉ báo chuông bị gạch chéo nằm trên thanh để nhắc bạn vì sao desktop đã trở nên yên lặng.

Tuy nhiên không có gì bị mất cả. Các thông báo bị tắt tiếng sẽ được giữ lại: đưa vài thông báo cuối cùng trở lại màn hình bằng `Super + Shift + Alt + ,`. Xem [thông báo](10-notices.md) để biết phần còn lại.

Hai loại tin nhắn vẫn lọt qua: toast xác nhận của chính Omarchy cho việc bạn vừa làm ("Theme changed", "Screenshot saved"), và cảnh báo nghiêm trọng gửi từ dòng lệnh. Các ứng dụng chat đánh dấu mọi thứ là nghiêm trọng để ép đường vào trước mặt bạn thì không đủ điều kiện.

### Idle

Shell của Omarchy sở hữu hành vi idle, và các khoảng thời gian là một khối `idle` ở cấp cao nhất trong `~/.config/omarchy/shell.json`:

```json
{
  "version": 1,
  "idle": {
    "screensaver": 150,
    "lock": 300
  }
}
```

Cả hai số đều là giây tính từ thời điểm bạn bắt đầu rảnh — không phải tính từ nhau. Vì vậy với các mặc định, trình bảo vệ màn hình xuất hiện sau hai phút rưỡi và màn hình khóa tiếp quản ở phút thứ năm, bất kể trình bảo vệ màn hình có chạy hay không. Lưu tệp và shell sẽ áp dụng các khoảng thời gian mới ngay lập tức.

Nếu bạn tắt trình bảo vệ màn hình trước hạn khóa, điều đó được tính là hoạt động và lệnh khóa đang chờ sẽ bị hủy. Bạn sẽ không bị khóa ngoài chỉ vì liếc nhìn máy của mình.

Để ngừng hoàn toàn việc khóa khi rảnh, `Super + Ctrl + I` — hoặc `omarchy toggle idle` — bật chế độ giữ tỉnh táo, và chỉ báo tách cà phê xuất hiện trên thanh. Đó là cái cần nhấn trước một buổi thuyết trình dài hoặc một bản build bạn muốn theo dõi. Nhấn lại để quay về bình thường. `omarchy toggle idle status` in trạng thái hiện tại dưới dạng JSON nếu bạn cần nó từ một script.

Đây là về khóa và trình bảo vệ màn hình, không phải về nguồn điện. Tạm dừng hệ thống và ngủ đông có thiết lập riêng trong [chế độ ngủ của hệ thống](36-system-sleep.md).

### Trình bảo vệ màn hình

Trình bảo vệ màn hình của Omarchy là nghệ thuật ASCII chạy qua các hiệu ứng văn bản ngẫu nhiên, một instance cho mỗi màn hình. Bất kỳ phím nào hoặc di chuyển chuột đều thoát khỏi nó.

Bạn có thể khởi động nó theo yêu cầu từ _System > Screensaver_ (`Super + Esc`), điều này ép nó hiện lên ngay cả khi bạn đã tắt trình bảo vệ màn hình khi rảnh. Mặc định không có phím tắt nào được gán cho nó.

`omarchy toggle screensaver` là thứ tắt trình bảo vệ màn hình khi rảnh, nếu bạn muốn đi thẳng từ đang làm việc sang bị khóa. Bất kỳ phím, cú nhấp, cuộn hay di chuyển chuột nào cũng đóng nó.

Logo mà nó vẽ là của bạn để thay đổi, dưới _Appearance > Branding > Screensaver_. Tải lên một png hoặc svg và Omarchy chuyển đổi nó thành ASCII. Xem [thương hiệu](41-branding.md).

### Màn hình khóa

`Super + Ctrl + L` khóa máy. Điều đó chạy màn hình khóa từ shell của Omarchy, làm trống màn hình, đặt lại bố cục bàn phím của bạn về bố cục đầu tiên để bạn không gõ mật khẩu bằng bảng chữ cái sai, và — nếu bạn đang chạy nó — khóa 1Password trên đường ra.

Màn hình khóa chấp nhận mật khẩu, và nó cũng sẽ chấp nhận dấu vân tay khi bạn đã thiết lập một cái. Điều đó, và các cách xác thực khác, được đề cập trong [xác thực phần cứng](37-hardware-authentication.md).
