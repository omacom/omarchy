# Các nút bật/tắt, Thời gian rảnh & Trình bảo vệ màn hình

Rất nhiều thứ bạn thay đổi hằng ngày thực ra không phải là một cài đặt. Đó là một chế độ bạn bật lên trong một giờ rồi lại tắt đi: ánh sáng đêm khi bạn làm việc khuya, không làm phiền khi bạn đang thuyết trình, giữ máy luôn thức khi bạn đang xem gì đó. Omarchy gọi chúng là các công tắc bật/tắt, và tất cả đều hoạt động theo cùng một cách — một phím tắt, một mục trong menu, và một lệnh, tất cả đều tác động lên cùng một công tắc.

### Menu bật/tắt

`Super + Ctrl + O` mở trực tiếp _Trigger > Toggle_, hoặc bạn có thể đi đến đó từ menu Omarchy (`Super + Space`). Mọi thứ trong danh sách đó đều là một công tắc bạn có thể bật/tắt mà không cần nghĩ về nơi trạng thái được lưu. Các công tắc cho cách desktop trông như thế nào nằm ngay bên cạnh nó, trong _Appearance_.

Từ terminal, các công tắc tương tự là `omarchy toggle <thing>`. Chạy `omarchy toggle` riêng để xem toàn bộ nhóm.

| Công tắc | Phím tắt | Lệnh |
| ------ | ------ | ------- |
| Ánh sáng đêm | — | `omarchy toggle nightlight` |
| Tắt tiếng thông báo | `Super + Ctrl + Alt + ,` | `omarchy toggle notification silencing` |
| Giữ máy luôn thức (không khóa khi rảnh) | `Super + Ctrl + I` | `omarchy toggle idle` |
| Ghi lại sự cố | — | `omarchy toggle crash-capture` |
| Trình bảo vệ màn hình | — | `omarchy toggle screensaver` |
| Đồng bộ theme của [Herdr](https://herdr.dev) | — | `omarchy toggle theme sync` |
| Thanh menu | `Super + Shift + Space` | `omarchy toggle bar` |
| Bàn di chuột | `XF86TouchpadToggle` | `omarchy toggle touchpad` |
| Màn hình cảm ứng | — | `omarchy toggle touchscreen` |
| Tạm dừng | — | `omarchy toggle suspend` |
| GPU lai | — | `omarchy toggle hybrid gpu` |

Các công tắc bàn di chuột, màn hình cảm ứng và GPU lai nằm trong _Trigger > Hardware_ (`Super + Ctrl + H`) thay vì trong Toggle, vì chúng chỉ xuất hiện khi bạn thực sự có phần cứng đó. Các công tắc bàn di chuột và màn hình cảm ứng vẫn giữ nguyên sau khi Hyprland tải lại — tên của thiết bị đã tắt được lưu vào một tệp trạng thái nhỏ mà Hyprland đọc khi khởi động để tắt lại thiết bị đó.

_Appearance_ chứa thanh menu và các hiệu ứng chuyển động, cùng với một vài thứ không phải là lệnh `omarchy toggle` nhưng hoạt động giống như vậy: phần trăm pin trên thanh, bố cục workspace mặc định, và trong _Windows_, khoảng cách giữa các cửa sổ (`Super + Shift + Backspace`) và tỷ lệ vuông cho 1 cửa sổ (`Super + Ctrl + Backspace`).

Khi Hyprland không có GPU để vẽ và thay vào đó kết xuất bằng CPU (llvmpipe), như trên các máy Mac mà GPU chưa được hỗ trợ, trong hầu hết các máy ảo, hoặc khi trình điều khiển đồ họa không tải được, Omarchy sẽ tắt hiệu ứng chuyển động, hiệu ứng làm mờ và bóng đổ cho phiên đó và thông báo cho bạn một lần bằng một thông báo. _Appearance > Animations On_ sẽ bật lại chúng, và Omarchy cũng ghi nhớ điều đó cho các phiên sau.

Hầu hết các công tắc này chỉ là một tệp cờ nằm trong `~/.local/state/omarchy/toggles/`. Nếu bạn muốn rẽ nhánh dựa trên một công tắc trong một script, `omarchy-toggle-enabled` sẽ cho bạn một mã thoát thay vì bắt bạn phải tự đi tìm:

```bash
omarchy-toggle-enabled screensaver-off && echo "screensaver is off"
```

Các cờ được đặt tên theo trạng thái tắt — `screensaver-off`, `suspend-off`, `bar-off` — vì vậy sự hiện diện của chúng có nghĩa là tính năng đã bị tắt.

### Các chỉ báo trên thanh

Khi một chế độ đang bật, bạn sẽ thấy một biểu tượng nhỏ ở giữa thanh trên cùng, bên cạnh đồng hồ. Đó là widget chỉ báo, và nó chứa tính năng đọc chính tả, quay màn hình, lời nhắc đang chờ, ánh sáng đêm, không làm phiền và giữ máy luôn thức.

Các chỉ báo không hoạt động sẽ bị ẩn. Di chuột đến bất kỳ đâu trên thanh và chúng sẽ hiện mờ dần, để bạn có thể nhấp vào một chỉ báo để bật nó mà không cần biết phím tắt của nó. Nhấp vào một chỉ báo đang hoạt động sẽ tắt nó trở lại. Nếu bạn muốn luôn nhìn thấy tất cả chúng, hãy đặt `alwaysShow` thành `true` trên mục `omarchy.indicators` trong `~/.config/omarchy/shell.json` — xem [thanh trên cùng](05-the-top-bar.md) để biết cách cấu hình các widget trên thanh.

### Ánh sáng đêm

Ánh sáng đêm làm ấm màn hình lên 4000K, và bật/tắt lại sẽ đưa nó trở về 6500K. Bật/tắt nó từ menu bật/tắt (`Super + Ctrl + O`) hoặc bằng `omarchy toggle nightlight`. Nó được điều khiển bởi hyprsunset, chương trình mà công tắc sẽ khởi động cho bạn nếu nó chưa chạy.

Theo mặc định, hyprsunset hoàn toàn không làm gì với màn hình của bạn. `~/.config/hypr/hyprsunset.conf` đi kèm với một hồ sơ identity chính xác để màn hình không bị động vào cho đến khi bạn yêu cầu làm ấm. Nếu bạn muốn nó chuyển đổi theo giờ, hãy thay thế hồ sơ đó bằng một hồ sơ theo thời gian:

```
profile {
    time = 20:00
    temperature = 4000
}
```

Sau đó khởi động hyprsunset khi đăng nhập bằng cách thêm `o.launch_on_start("hyprsunset")` vào `~/.config/hypr/autostart.lua`. Cặp 4000K/6500K mà công tắc sử dụng là cố định, vì vậy tệp cấu hình là nơi bạn cần đến nếu muốn một nhiệt độ khác.

### Không làm phiền

`Super + Ctrl + Alt + ,` sẽ tắt tiếng thông báo. Không có thông báo nổi nào bật lên khi nó đang bật, và chỉ báo chuông bị gạch chéo nằm trên thanh để nhắc bạn lý do desktop trở nên yên lặng.

Tuy nhiên, không có gì bị mất. Các thông báo đã tắt tiếng sẽ bị giữ lại: đưa vài thông báo gần nhất trở lại màn hình bằng `Super + Shift + Alt + ,`. Xem [thông báo](10-notices.md) để biết phần còn lại.

Hai loại tin nhắn vẫn lọt qua được: các thông báo xác nhận của chính Omarchy cho việc bạn vừa làm ("Theme changed", "Screenshot saved"), và các cảnh báo nghiêm trọng được gửi từ dòng lệnh. Các ứng dụng trò chuyện đánh dấu mọi thứ là nghiêm trọng để ép mình xuất hiện trước mặt bạn thì không được tính.

### Thời gian rảnh

Shell của Omarchy sở hữu hành vi khi rảnh, và các mốc thời gian là một khối `idle` ở cấp cao nhất trong `~/.config/omarchy/shell.json`:

```json
{
  "version": 1,
  "idle": {
    "screensaver": 150,
    "lock": 300
  }
}
```

Cả hai con số đều là số giây được tính từ thời điểm bạn bắt đầu rảnh — chứ không phải tính từ nhau. Vì vậy với các giá trị mặc định, trình bảo vệ màn hình sẽ hiện lên sau hai phút rưỡi và màn hình khóa sẽ tiếp quản ở phút thứ năm, bất kể trình bảo vệ màn hình có chạy hay không. Lưu tệp và shell sẽ áp dụng các mốc thời gian mới ngay lập tức.

Nếu bạn tắt trình bảo vệ màn hình trước thời hạn khóa, điều đó được tính là hoạt động và việc khóa đang chờ sẽ bị hủy. Bạn sẽ không bị khóa ngoài chỉ vì liếc nhìn máy của mình.

Để ngừng hoàn toàn việc khóa khi rảnh, `Super + Ctrl + I` — hoặc `omarchy toggle idle` — sẽ bật chế độ giữ máy luôn thức, và chỉ báo tách cà phê sẽ xuất hiện trên thanh. Đó là công tắc bạn nên bấm trước một buổi thuyết trình dài hoặc một bản build mà bạn muốn theo dõi. Bấm lại lần nữa để trở lại bình thường. `omarchy toggle idle status` in trạng thái hiện tại dưới dạng JSON nếu bạn cần nó từ một script.

Phần này nói về việc khóa và trình bảo vệ màn hình, không phải về năng lượng. Tạm dừng và ngủ đông có cách thiết lập riêng trong [chế độ ngủ của hệ thống](36-system-sleep.md).

### Trình bảo vệ màn hình

Trình bảo vệ màn hình của Omarchy là nghệ thuật ASCII chạy qua các hiệu ứng văn bản ngẫu nhiên, mỗi màn hình một phiên bản. Bất kỳ phím nào hoặc chuyển động chuột nào cũng sẽ thoát khỏi nó.

Bạn có thể khởi động nó theo yêu cầu từ _System > Screensaver_ (`Super + Esc`), thao tác này buộc nó hiện lên ngay cả khi bạn đã tắt trình bảo vệ màn hình khi rảnh. Theo mặc định, không có phím tắt nào được gán cho nó.

`omarchy toggle screensaver` là lệnh tắt trình bảo vệ màn hình khi rảnh, nếu bạn muốn đi thẳng từ đang làm việc sang bị khóa. Bất kỳ phím nào, cú nhấp, cuộn hoặc chuyển động chuột nào cũng sẽ đóng nó.

Logo mà nó vẽ là do bạn thay đổi, trong _Appearance > Branding > Screensaver_. Tải lên một png hoặc svg và Omarchy sẽ chuyển nó thành ASCII. Xem [nhận diện thương hiệu](41-branding.md).

### Màn hình khóa

`Super + Ctrl + L` khóa máy. Thao tác đó chạy màn hình khóa từ shell của Omarchy, làm trống màn hình, đặt lại bố cục bàn phím của bạn về bố cục đầu tiên để bạn không gõ mật khẩu bằng bảng chữ cái sai, và — nếu bạn đang chạy nó — khóa 1Password trên đường ra.

Màn hình khóa nhận mật khẩu, và nó cũng sẽ nhận dấu vân tay sau khi bạn đã thiết lập một dấu vân tay. Điều đó, cùng các cách xác thực khác, được trình bày trong [xác thực phần cứng](37-hardware-authentication.md).
