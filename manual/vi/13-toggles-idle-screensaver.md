# Các chế độ bật/tắt, thời gian rảnh & trình bảo vệ màn hình

Phần lớn những thứ bạn thay đổi hằng ngày thực ra không phải là một cài đặt. Đó là một chế độ bạn bật lên trong một giờ rồi lại tắt đi: ánh sáng đêm khi bạn làm việc khuya, không làm phiền khi bạn đang thuyết trình, giữ máy thức khi bạn đang xem thứ gì đó. Omarchy gọi những thứ đó là các chế độ bật/tắt, và tất cả đều hoạt động theo cùng một cách — một phím tắt, một mục trong menu, và một lệnh, tất cả cùng tác động lên một công tắc.

### Menu bật/tắt

`Super + Ctrl + O` mở trực tiếp _Trigger > Toggle_, hoặc bạn có thể đi tới đó từ menu Omarchy (`Super + Space`). Mọi thứ trong danh sách đó đều là một công tắc bạn có thể gạt mà không cần nghĩ xem trạng thái của nó được lưu ở đâu. Các công tắc cho diện mạo của desktop nằm ngay bên cạnh nó, dưới _Appearance_.

Từ terminal, các công tắc tương tự là `omarchy toggle <thing>`. Chạy `omarchy toggle` một mình để xem toàn bộ nhóm.

| Chế độ bật/tắt | Phím tắt | Lệnh |
| ------ | ------ | ------- |
| Ánh sáng đêm | — | `omarchy toggle nightlight` |
| Tắt tiếng thông báo | `Super + Ctrl + Alt + ,` | `omarchy toggle notification silencing` |
| Giữ máy thức (không khóa khi rảnh) | `Super + Ctrl + I` | `omarchy toggle idle` |
| Ghi lại sự cố | — | `omarchy toggle crash-capture` |
| Trình bảo vệ màn hình | — | `omarchy toggle screensaver` |
| Đồng bộ theme của [Herdr](https://herdr.dev) | — | `omarchy toggle theme sync` |
| Thanh menu | `Super + Shift + Space` | `omarchy toggle bar` |
| Bàn di chuột | `XF86TouchpadToggle` | `omarchy toggle touchpad` |
| Màn hình cảm ứng | — | `omarchy toggle touchscreen` |
| Tạm dừng | — | `omarchy toggle suspend` |
| GPU lai | — | `omarchy toggle hybrid gpu` |

Các công tắc bàn di chuột, màn hình cảm ứng và GPU lai nằm dưới _Trigger > Hardware_ (`Super + Ctrl + H`) thay vì dưới Toggle, vì chúng chỉ xuất hiện khi bạn thực sự có phần cứng đó. Các công tắc bàn di chuột và màn hình cảm ứng vẫn giữ nguyên sau khi Hyprland tải lại — tên của thiết bị đã bị tắt được lưu vào một file trạng thái nhỏ mà Hyprland đọc khi khởi động để tắt nó lại.

_Appearance_ chứa thanh menu và các hiệu ứng chuyển động, cùng với vài thứ không phải là lệnh `omarchy toggle` nhưng hoạt động giống như vậy: phần trăm pin trên thanh, bố cục workspace mặc định, và dưới _Windows_, khoảng hở giữa các cửa sổ (`Super + Shift + Backspace`) và tỉ lệ vuông cho 1 cửa sổ (`Super + Ctrl + Backspace`).

Hầu hết những thứ này chỉ là một file cờ dưới `~/.local/state/omarchy/toggles/`. Nếu bạn muốn rẽ nhánh dựa trên một trong số chúng trong một script, `omarchy-toggle-enabled` sẽ cho bạn một mã thoát thay vì bắt bạn tự đi tìm:

```bash
omarchy-toggle-enabled screensaver-off && echo "screensaver is off"
```

Các cờ được đặt tên theo trạng thái tắt — `screensaver-off`, `suspend-off`, `bar-off` — nên sự hiện diện của chúng có nghĩa là tính năng đã bị tắt.

### Các chỉ báo trên thanh

Khi một chế độ đang bật, bạn sẽ thấy một biểu tượng nhỏ ở giữa thanh trên cùng, bên cạnh đồng hồ. Đó là widget chỉ báo, và nó chứa tính năng đọc chính tả, ghi màn hình, lời nhắc đang chờ, ánh sáng đêm, không làm phiền, và giữ máy thức.

Các chỉ báo không hoạt động sẽ bị ẩn. Di chuột lên bất cứ đâu trên thanh và chúng sẽ mờ hiện ra, để bạn có thể nhấp vào một cái để bật nó lên mà không cần biết phím tắt của nó. Nhấp vào một chỉ báo đang hoạt động sẽ tắt nó trở lại. Nếu bạn muốn luôn thấy tất cả chúng mọi lúc, hãy đặt `alwaysShow` thành `true` trên mục `omarchy.indicators` trong `~/.config/omarchy/shell.json` — xem [thanh trên cùng](05-the-top-bar.md) để biết cách cấu hình các widget trên thanh.

### Ánh sáng đêm

Ánh sáng đêm làm màn hình ấm lên ở 4000K, và bật/tắt nó lần nữa sẽ đưa màn hình trở lại 6500K. Gạt nó từ menu bật/tắt (`Super + Ctrl + O`) hoặc bằng `omarchy toggle nightlight`. Nó được điều khiển bởi hyprsunset, và chế độ bật/tắt sẽ khởi động hyprsunset cho bạn nếu nó chưa chạy.

Theo mặc định, hyprsunset hoàn toàn không làm gì với màn hình của bạn. `~/.config/hypr/hyprsunset.conf` đi kèm sẵn với một profile identity, chính xác là để màn hình không bị thay đổi gì cho đến khi bạn muốn nó ấm hơn. Nếu bạn muốn nó tự chuyển theo đồng hồ hơn, hãy thay thế nó bằng một profile theo thời gian:

```
profile {
    time = 20:00
    temperature = 4000
}
```

Sau đó khởi động hyprsunset khi đăng nhập bằng cách thêm `o.launch_on_start("hyprsunset")` vào `~/.config/hypr/autostart.lua`. Cặp 4000K/6500K mà chế độ bật/tắt sử dụng là cố định, nên file cấu hình là nơi bạn tìm đến nếu muốn một nhiệt độ khác.

### Không làm phiền

`Super + Ctrl + Alt + ,` tắt tiếng thông báo. Không có thông báo nổi nào bật lên khi nó đang bật, và chỉ báo chiếc chuông bị gạch chéo nằm trên thanh để nhắc bạn vì sao desktop đã trở nên im lặng.

Không có gì bị mất cả. Các thông báo bị tắt tiếng sẽ được giữ lại: đưa vài thông báo gần nhất trở lại màn hình bằng `Super + Shift + Alt + ,`. Xem [thông báo](10-notices.md) để biết phần còn lại.

Hai loại tin nhắn vẫn được phép lọt qua: các thông báo xác nhận của chính Omarchy cho việc bạn vừa làm ("Theme changed", "Screenshot saved"), và các cảnh báo khẩn cấp được gửi từ dòng lệnh. Các ứng dụng trò chuyện đánh dấu mọi thứ là khẩn cấp để ép chúng hiện ra trước mặt bạn thì không đạt tiêu chuẩn đó.

### Thời gian rảnh

Shell của Omarchy chịu trách nhiệm về hành vi khi rảnh, và các mốc thời gian là một khối `idle` ở cấp cao nhất trong `~/.config/omarchy/shell.json`:

```json
{
  "version": 1,
  "idle": {
    "screensaver": 150,
    "lock": 300
  }
}
```

Cả hai con số đều là giây được tính từ thời điểm bạn bắt đầu rảnh — không phải tính từ nhau. Vì vậy với các giá trị mặc định, trình bảo vệ màn hình xuất hiện sau hai phút rưỡi và màn hình khóa sẽ chiếm lấy sau năm phút, bất kể trình bảo vệ màn hình có chạy hay không. Lưu file lại và shell sẽ áp dụng các mốc thời gian mới ngay lập tức.

Nếu bạn tắt trình bảo vệ màn hình trước hạn chót khóa, điều đó được tính là hoạt động và lần khóa đang chờ sẽ bị hủy. Bạn sẽ không bị khóa ngoài chỉ vì liếc nhìn máy của mình.

Để ngừng hoàn toàn việc khóa khi rảnh, `Super + Ctrl + I` — hoặc `omarchy toggle idle` — bật chế độ giữ máy thức, và chỉ báo tách cà phê xuất hiện trên thanh. Đó là cái cần bấm trước một buổi thuyết trình dài hoặc một bản build bạn muốn theo dõi. Bấm lại lần nữa để trở lại bình thường. `omarchy toggle idle status` in ra trạng thái hiện tại dưới dạng JSON nếu bạn cần nó từ một script.

Đây là chuyện về khóa và trình bảo vệ màn hình, không phải về điện năng. Tạm dừng và ngủ đông có thiết lập riêng trong [chế độ ngủ của hệ thống](36-system-sleep.md).

### Trình bảo vệ màn hình

Trình bảo vệ màn hình của Omarchy là nghệ thuật ASCII chạy qua các hiệu ứng văn bản ngẫu nhiên, một phiên bản cho mỗi màn hình. Bất kỳ phím nào hoặc chuyển động chuột nào cũng thoát khỏi nó.

Bạn có thể khởi động nó theo yêu cầu từ _System > Screensaver_ (`Super + Esc`), việc này ép nó hiện lên ngay cả khi bạn đã tắt trình bảo vệ màn hình khi rảnh. Theo mặc định không có phím tắt nào được gán cho nó.

`omarchy toggle screensaver` là thứ tắt cái khi rảnh đi, nếu bạn muốn đi thẳng từ đang làm việc sang bị khóa hơn. Bất kỳ phím, cú nhấp, cuộn hoặc chuyển động chuột nào cũng đóng nó lại.

Logo mà nó vẽ là của bạn để thay đổi, dưới _Appearance > Branding > Screensaver_. Tải lên một file png hoặc svg và Omarchy sẽ chuyển đổi nó thành ASCII. Xem [nhận diện thương hiệu](41-branding.md).

### Màn hình khóa

`Super + Ctrl + L` khóa máy. Việc đó chạy màn hình khóa từ shell của Omarchy, làm trống màn hình, đặt lại bố cục bàn phím của bạn về bố cục đầu tiên để bạn không gõ mật khẩu của mình bằng bảng chữ cái sai, và — nếu bạn đang chạy nó — khóa 1Password trên đường ra.

Màn hình khóa chấp nhận mật khẩu, và nó cũng sẽ chấp nhận dấu vân tay sau khi bạn đã thiết lập một cái. Điều đó, và các cách xác thực khác, được trình bày trong [xác thực phần cứng](37-hardware-authentication.md).
