# Thanh trên cùng

Dải dọc trên cùng màn hình của bạn là thanh Omarchy. Nó không phải một thanh trạng thái gắn thêm vào mà là một phần của Omarchy shell, tiến trình Quickshell duy nhất chạy dài hạn cũng vẽ menu, các thông báo, các cửa sổ bật lên OSD và màn hình khóa. Đó là lý do nó ăn khớp hoàn hảo với mọi thứ còn lại và là lý do một panel mở ra ngay lập tức thay vì khởi chạy một ứng dụng mới.

Nó cũng là phần duy nhất của desktop luôn hiện trên màn hình, nên rất đáng để biết tất cả những glyph nhỏ xíu đó làm gì.

## Mặc định có gì trên đó

Thanh có ba phần. Ở bên trái là logo Omarchy (trình khởi chạy menu) và các chỉ báo không gian làm việc. Ở giữa bạn có các chỉ báo trạng thái, đồng hồ, Elsewhen (một đồng hồ thế giới), thời tiết và một huy hiệu cập nhật Omarchy. Ở bên phải: khay hệ thống, bố cục bàn phím (khi có nhiều hơn một bố cục hoặc phương thức nhập được cấu hình), agents, bluetooth, mạng, âm thanh, màn hình hiển thị và nguồn điện.

Một vài trong số đó chỉ xuất hiện khi chúng có điều gì đó để nói. Bố cục bàn phím chỉ xuất hiện nếu bạn đã cấu hình nhiều hơn một bố cục hoặc phương thức nhập. Huy hiệu cập nhật chỉ xuất hiện khi có một bản cập nhật Omarchy đang chờ.

## Nhấp chuột xung quanh

Gần như mọi widget đều làm gì đó khi nhấp trái, phải và giữa, và một số còn phản hồi với thao tác cuộn. Đây là phần mọi người hay bỏ lỡ — nút phải và nút giữa là nơi ẩn giấu rất nhiều thứ hay ho.

| Widget | Trái | Phải | Giữa / cuộn |
| --- | --- | --- | --- |
| Menu | Menu Omarchy | Terminal mới | — |
| Không gian làm việc | Chuyển tiêu điểm tới không gian làm việc đó trên màn hình này | — | Cuộn: không gian làm việc tiếp theo/trước |
| Đồng hồ | Cửa sổ bật lên lịch | Chuyển luân phiên định dạng nhãn | Giữa: bộ chọn múi giờ |
| Đồng hồ thế giới | Panel đồng hồ thế giới | Làm mới | Giữa: làm mới |
| Thời tiết | Cửa sổ bật lên dự báo | Thời tiết đầy đủ dưới dạng thông báo | Giữa: làm mới |
| Âm thanh | Panel âm thanh | Tắt tiếng | Giữa: panel · cuộn: âm lượng |
| Micrô | Tắt tiếng micrô | — | Giữa: panel âm thanh · cuộn: âm lượng đầu vào |
| Mạng | Panel mạng | — | — |
| Bluetooth | Panel Bluetooth | Bật/tắt radio | — |
| Màn hình hiển thị | Panel màn hình hiển thị | — | Cuộn: độ sáng |
| Nguồn điện | Panel nguồn điện | Bật/tắt phần trăm pin | — |
| Media | Phát/tạm dừng | Cửa sổ bật lên ảnh bìa | Giữa: tiếp theo · cuộn: trước/tiếp theo |
| Agents | Panel Agents | Khởi chạy agent của bạn | Giữa: làm mới mức sử dụng |
| Khay hệ thống | Di chuột để hiện ngăn kéo | Nhấp phải vào chevron để quản lý | — |
| Cập nhật Omarchy | Chạy cập nhật | — | — |

Không phải mọi thứ trong bảng đó đều có trên thanh của bạn ngay từ đầu. Widget media (MPRIS đang phát, với một bản nhạc và nghệ sĩ cuộn qua) và widget micrô đều được tích hợp sẵn nhưng tắt theo mặc định — hãy thêm chúng nếu bạn muốn, như mô tả bên dưới.

## Các panel

Nhấp vào một biểu tượng trên thanh sẽ mở một panel, đó là một cửa sổ bật lên đàng hoàng với các thanh trượt, danh sách và điều hướng bằng bàn phím chứ không phải một tooltip. Mỗi panel cũng có một phím tắt, nên bạn không bao giờ phải ngắm vào một glyph 16 pixel:

| Phím tắt | Panel |
| --- | --- |
| `Super + Ctrl + A` | Âm thanh |
| `Super + Ctrl + N` | Mạng |
| `Super + Ctrl + B` | Bluetooth |
| `Super + Ctrl + D` | Màn hình hiển thị |
| `Super + Ctrl + P` | Nguồn điện |
| `Super + Ctrl + Alt + D` | Lịch |
| `Super + Ctrl + Alt + E` | Đồng hồ thế giới |
| `Super + Ctrl + X` | Agents |
| `Super + Ctrl + 1-9` | Bật/tắt panel thứ n trong phần bên phải |

Các panel không phải là chỗ chỉ để xem thông số. Chúng là nơi bạn thực sự làm việc cần làm:

- **Âm thanh** có một thanh trượt âm lượng tổng, một bộ chọn thiết bị đầu ra và một bộ trộn theo từng ứng dụng, nên bạn có thể giảm âm lượng của đúng cái tab trình duyệt đó mà không động vào mọi thứ khác.
- **Mạng** quét Wi-Fi, hiển thị cường độ tín hiệu, kết nối và cho phép bạn chọn một nhà cung cấp DNS.
- **Bluetooth** liệt kê các thiết bị của bạn với kết nối/ngắt kết nối và mức pin.
- **Nguồn điện** hiển thị thống kê pin, chuyển đổi các hồ sơ nguồn điện (nó nhớ một lựa chọn riêng cho pin và AC), và hiển thị một số thông tin hệ thống.
- **Màn hình hiển thị** có một thanh trượt độ sáng, kích thước văn bản, các preset tỉ lệ màn hình, và — khi bạn có nhiều hơn một màn hình — các điều khiển cho từng màn hình. Xem [màn hình](33-monitors.md) để biết câu chuyện sâu hơn.
- **Đồng hồ** mở một lưới tháng với số tuần ISO và chuyển bước theo tháng.
- **Đồng hồ thế giới** giữ một hàng cho mỗi thành phố, với thời tiết của nó và ngày của nó đang diễn ra thế nào. Tìm kiếm tìm thấy các thị trấn cũng như các múi giờ, nên Fort Lauderdale là Fort Lauderdale chứ không phải New York. Nếu dòng ở trên cùng ghi sai thành phố, hãy nhấp vào nó và cho biết bạn đang ở đâu; chọn một nơi ở một múi giờ khác và đồng hồ hệ thống cũng chuyển tới đó, điều này rất tiện khi bạn đi du lịch. Di chuột qua một thành phố và nhấp vào nút hình người để cho biết ai sống ở đó — tên thường, hoặc tên người dùng GitHub dạng `@` để mang theo cả khuôn mặt của họ.

Mọi panel đều dùng được bàn phím cũng như chuột: các phím mũi tên để di chuyển, Return để kích hoạt, Tab để bước sang panel bên cạnh, và Escape để đóng.

`Super + Ctrl + 1-9` đếm các panel từ trái sang phải trong phần bên phải, bỏ qua khay hệ thống vì nó không có panel riêng. Vì vậy con số khớp với biểu tượng bạn sẽ chỉ vào.

### Tailscale and Dropbox

Hai widget nữa chỉ xuất hiện trên thanh một khi bạn cài đặt dịch vụ tương ứng từ **Install → Service**, và cả hai đều đáng để biết vì chúng làm được nhiều hơn là chỉ báo cáo trạng thái.

Panel **Tailscale** kết nối và ngắt kết nối tailnet, chuyển đổi giữa các tài khoản, và chọn một exit node (cả máy của bạn và các vùng Mullvad đều xuất hiện trong danh sách đó). Nó cũng duyệt các máy của bạn — và khi một máy được chọn, `s` sẽ gửi các tệp tới nó qua Taildrop, đó là cách nhanh nhất để chuyển một tệp tới điện thoại hoặc một laptop khác của bạn. `c` sao chép IP của máy, `n` sao chép tên của nó, và `d` sao chép tên DNS đầy đủ của nó. Cũng có một nút gửi trên mỗi hàng máy, nếu bạn thích nhấp chuột hơn. Điều tương tự từ terminal là `omarchy tailscale send <machine> [file...]`.

Panel **Dropbox** xử lý đăng nhập, hiển thị dung lượng lưu trữ bạn đã dùng, và liệt kê các tệp đã đồng bộ gần đây.

Việc gỡ bỏ bất kỳ dịch vụ nào trong hai dịch vụ này cũng sẽ gỡ widget của nó khỏi thanh.

## Các chỉ báo

Cụm nhỏ ở giữa là widget chỉ báo. Đây là các glyph trạng thái cho các chế độ bạn đã bật: không làm phiền, ánh sáng ban đêm, một [lời nhắc](09-reminders.md) đã xếp hàng, một phiên ghi màn hình đang hoạt động, và giữ máy luôn thức, cộng với các cảnh báo trong khi sudo không cần mật khẩu đang bật hoặc ai đó đang kết nối tới một phiên từ xa. Chúng sáng lên khi chế độ đang hoạt động và nếu không thì tránh sang một bên — hãy di chuột ngay bên cạnh chúng, nơi các chỉ báo không hoạt động sẽ nằm, để hé nhìn những chỉ báo đó. Nhấp vào một chỉ báo sẽ bật/tắt chế độ đó. Còn một chỉ báo nữa chỉ để hiển thị trạng thái: một phiên từ xa sáng lên màu đỏ trong khi ai đó đang kết nối tới máy này qua gliff.

Nếu bạn muốn chúng luôn hiển thị, hãy đặt `alwaysShow` thành `true` trên widget. Và nếu bạn chỉ quan tâm tới một vài trong số chúng, hãy liệt kê những cái bạn muốn trong `items`: `["Dnd", "Reminder", "NightLight"]`. Bạn có thể có nhiều hơn một widget chỉ báo, nên các phần khác nhau có thể hiển thị các tập con khác nhau.

## Sắp xếp lại thanh

Thanh tự cấu hình chính nó. Bạn không phải mở một tệp cấu hình để di chuyển mọi thứ.

Nắm lấy một khoảng trống của thanh quanh phần giữa và kéo nó về một cạnh màn hình khác, và thanh sẽ di chuyển tới đó — trái, phải, trên hoặc dưới đều được, và mọi widget đều thích ứng (các thanh dọc sẽ quay về dạng gọn chỉ có biểu tượng). Nhấp và giữ cũng bắt đầu cùng một thao tác kéo. Nhấp đúp chuột trái vào cùng khoảng trống đó để chuyển luân phiên nền của thanh từ trong suốt sang dạng kính sang đục. Và kéo bất kỳ widget nào để sắp xếp lại nó hoặc ném nó vào một phần khác; các widget khác sẽ trượt ra để nhường chỗ nơi nó sẽ đáp xuống.

Phần giữa của thanh là một hộp: bất cứ thứ gì trong đó đều ở giữa như một nhóm, và các widget ở hai bên của nó bám vào các cạnh của nó. Trong khi bạn kéo một widget, hộp hiện ra dưới dạng một đường viền, hoặc một đường kẻ ngang qua thanh khi nó trống, và bạn có thể thả vào trong nó hoặc bên cạnh nó. Khi một thao tác thả sẽ đáp vào hộp, hộp sẽ lớn ra để đón widget vào.

Một widget bạn muốn ở quanh đó nhưng không phải lúc nào cũng thấy có thể cho vào ngăn kéo của khay hệ thống: kéo nó lên khay hệ thống, và ngăn kéo sẽ mở ra để đón nó. Nó nằm ở đó sau các biểu tượng ứng dụng, xuất hiện bất cứ khi nào ngăn kéo xuất hiện, và giữ ngăn kéo của nó mở trong khi panel của nó đang hiện. Kéo nó trở lại ra thanh để đặt nó về chỗ cũ.

Nếu bạn thích chọn từ một menu hơn, **Appearance → Menu Bar** có vị trí, và **Bar Background** chọn cách thanh được vẽ: **Opaque Bar**, **Glassy Bar** (trong suốt, với những gì phía sau nó bị làm mờ), hoặc **Clear Bar**.

Những điều tương tự cũng có các lệnh, đó là thứ bạn cần cho một thiết lập [dotfiles](31-dotfiles.md):

```bash
omarchy bar position bottom
omarchy bar background glassy  # opaque, glassy, none, or cycle
omarchy bar move omarchy.weather --section centerBegin --index 0
omarchy bar move omarchy.bluetooth --section tray  # into the tray's drawer
omarchy bar set omarchy.clock format "HH:mm"
omarchy bar defaults          # back to the shipped layout
```

Để thêm hoặc gỡ bỏ hoàn toàn một widget, hãy dùng các lệnh plugin. `omarchy plugin list` in ra mọi widget mà shell biết cùng với id của nó, và sau đó:

```bash
omarchy plugin enable omarchy.media --section centerEnd
omarchy plugin disable omarchy.weather
```

## Ẩn thanh

`Super + Shift + Space` bật/tắt thanh mà không giết shell — các panel và phím tắt vẫn hoạt động, bạn chỉ lấy lại các pixel. Nó cũng có trong menu dưới **Appearance → Menu Bar → Hide Bar**.

## Tệp cấu hình

Tất cả được lưu trong `~/.config/omarchy/shell.json`, dưới khóa `bar`. Đây là một phiên bản đã rút gọn:

```json
{
  "version": 1,
  "bar": {
    "position": "top",
    "background": "opaque",
    "layout": {
      "left": [{ "id": "omarchy.menu" }, { "id": "omarchy.workspaces" }],
      "centerBegin": [{ "id": "omarchy.indicators" }],
      "center": [{ "id": "omarchy.clock", "format": "HH:mm" }],
      "centerEnd": [{ "id": "omarchy.weather" }],
      "right": [{ "id": "omarchy.audio" }, { "id": "omarchy.power" }]
    }
  }
}
```

Mọi widget là một mục trong một trong năm mảng bố cục, và các cài đặt của nó nằm ngay trên mục đó — không có tệp cài đặt riêng và không có đối tượng con `config`. `format`, `formatAlt` (thứ mà nhấp phải chuyển luân phiên tới) và `verticalFormat` của đồng hồ đều nằm ngay ở đó trên `{ "id": "omarchy.clock" }`.

`center` là hộp ở giữa thanh: mọi thứ trong đó đều được căn giữa trên màn hình như một nhóm. `centerBegin` và `centerEnd` bám vào hai bên của hộp, đó là cách đồng hồ luôn ở chính giữa ngay cả khi thời tiết và huy hiệu cập nhật đến rồi đi. Đặt nhiều hơn một widget vào `center` và chúng sẽ được căn giữa cùng nhau; để nó trống và `centerBegin` cùng `centerEnd` sẽ gặp nhau ở giữa thanh.

Một quy tắc đáng để ghi nhớ: **một khi bạn đã có `shell.json` của riêng mình, nó là chuẩn chính thức**. Cho tới khi bạn tùy chỉnh bất cứ thứ gì, shell đọc tệp mặc định của Omarchy. Ngay khi bạn kéo một widget, chạy `omarchy bar`, hoặc tự sửa tệp, nó là của bạn — không có việc hợp nhất sâu nào cả, nên các widget mặc định mới trong các bản phát hành Omarchy tương lai sẽ không tự động xuất hiện trên thanh của bạn. `omarchy bar defaults` đưa bố cục được đóng gói sẵn trở lại bất cứ khi nào bạn muốn một khởi đầu sạch sẽ.

Cùng tệp đó cũng giữ các thời gian chờ không hoạt động của bạn ở cấp cao nhất, bên ngoài khóa `bar`: `idle.screensaver` và `idle.lock`, cả hai đều tính bằng giây kể từ khi bạn ngừng hoạt động. Vì vậy trình bảo vệ màn hình mặc định sẽ kích hoạt ở 150 giây và khóa ở 300 giây.
