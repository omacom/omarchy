# Thanh trên cùng

Dải dọc theo cạnh trên màn hình của bạn là thanh Omarchy. Nó không phải là một thanh trạng thái gắn thêm mà là một phần của shell Omarchy, tiến trình Quickshell chạy dài hạn duy nhất cũng vẽ menu, thông báo, các cửa sổ bật lên OSD và màn hình khóa. Đó là lý do nó hòa hợp hoàn hảo với mọi thứ khác và lý do một bảng mở ra tức thì thay vì tạo ra một ứng dụng mới.

Nó cũng là phần duy nhất của desktop luôn hiện trên màn hình, vì vậy đáng để biết tất cả những ký tự nhỏ đó làm gì.

## Những gì có trên đó theo mặc định

Thanh có ba phần. Ở phía trái là logo Omarchy (trình khởi chạy menu) và các chỉ báo không gian làm việc. Ở giữa bạn có các chỉ báo trạng thái, đồng hồ, Elsewhen (một đồng hồ thế giới), thời tiết và huy hiệu cập nhật Omarchy. Ở phía phải: bố cục bàn phím (khi có nhiều hơn một bố cục được cấu hình), khay hệ thống, agent, bluetooth, mạng, âm thanh, màn hình và nguồn điện.

Một vài trong số đó chỉ xuất hiện khi chúng có điều gì đó để nói. Bố cục bàn phím chỉ xuất hiện nếu bạn đã cấu hình nhiều hơn một bố cục. Huy hiệu cập nhật chỉ xuất hiện khi có một bản cập nhật Omarchy đang chờ. Và biểu tượng agent xuất hiện lần đầu tiên Omarchy tìm thấy việc sử dụng AI coding trên máy (xem [AI](17-ai.md)).

## Nhấp chuột xung quanh

Gần như mọi tiện ích đều làm điều gì đó khi nhấp chuột trái, phải và giữa, và một vài tiện ích phản hồi với thao tác cuộn. Đây là phần mọi người bỏ lỡ — các nút phải và giữa là nơi rất nhiều thứ hay ho ẩn náu.

| Tiện ích | Trái | Phải | Giữa / cuộn |
| --- | --- | --- | --- |
| Menu | Menu Omarchy | Terminal mới | — |
| Không gian làm việc | Tập trung vào không gian làm việc đó | — | Cuộn: không gian làm việc tiếp theo/trước đó |
| Đồng hồ | Cửa sổ bật lên lịch | Chuyển đổi định dạng nhãn | Giữa: bộ chọn múi giờ |
| Thời tiết | Cửa sổ bật lên dự báo | Thời tiết đầy đủ dưới dạng thông báo | Giữa: làm mới |
| Âm thanh | Bảng âm thanh | Tắt tiếng | Giữa: bảng · cuộn: âm lượng |
| Micro | Tắt tiếng micro | — | Giữa: bảng âm thanh · cuộn: âm lượng đầu vào |
| Mạng | Bảng mạng | — | — |
| Bluetooth | Bảng Bluetooth | Bật/tắt sóng vô tuyến | — |
| Màn hình | Bảng màn hình | — | Cuộn: độ sáng |
| Nguồn điện | Bảng nguồn điện | Bật/tắt phần trăm pin | — |
| Phương tiện | Phát/tạm dừng | Cửa sổ bật lên ảnh bìa | Giữa: tiếp theo · cuộn: trước/tiếp theo |
| Agent | Bảng agent | Khởi chạy agent của bạn | Giữa: gói đăng ký tiếp theo |
| Khay | Di chuột để hiện ngăn kéo | Nhấp phải vào dấu chevron để quản lý | — |
| Cập nhật Omarchy | Chạy bản cập nhật | — | — |

Không phải mọi thứ trong bảng đó đều có trên thanh của bạn ngay khi mở hộp. Tiện ích phương tiện (MPRIS đang phát, với bản nhạc và nghệ sĩ cuộn) và tiện ích micro đều được tích hợp sẵn nhưng tắt theo mặc định — thêm chúng nếu bạn muốn, như mô tả bên dưới.

## Các bảng

Nhấp vào một biểu tượng trên thanh mở ra một bảng, đó là một cửa sổ bật lên đúng nghĩa với thanh trượt, danh sách và điều hướng bằng bàn phím thay vì một chú thích công cụ. Mỗi bảng cũng có một phím tắt, vì vậy bạn không bao giờ phải nhắm vào một ký tự 16 pixel:

| Phím tắt | Bảng |
| --- | --- |
| `Super + Ctrl + A` | Âm thanh |
| `Super + Ctrl + W` | Mạng |
| `Super + Ctrl + B` | Bluetooth |
| `Super + Ctrl + D` | Màn hình |
| `Super + Ctrl + P` | Nguồn điện |
| `Super + Ctrl + Alt + D` | Lịch |
| `Super + Ctrl + Alt + E` | Đồng hồ thế giới |
| `Super + Ctrl + 1-9` | Bật/tắt bảng thứ n trong phần bên phải |

Các bảng không phải là các bảng chỉ đọc. Chúng là nơi bạn thực sự làm việc đó:

- **Âm thanh** có thanh trượt âm lượng chính, bộ chọn thiết bị đầu ra và bộ trộn theo từng ứng dụng, vì vậy bạn có thể giảm âm lượng của tab trình duyệt đó mà không chạm vào mọi thứ khác.
- **Mạng** quét tìm Wi-Fi, hiển thị cường độ tín hiệu, kết nối và cho phép bạn chọn nhà cung cấp DNS.
- **Bluetooth** liệt kê các thiết bị của bạn với kết nối/ngắt kết nối và mức pin.
- **Nguồn điện** hiển thị thống kê pin, chuyển đổi cấu hình nguồn điện (nó ghi nhớ lựa chọn riêng cho pin và AC), và in một số thông tin hệ thống.
- **Màn hình** mang theo thanh trượt độ sáng, kích thước văn bản, các cài đặt sẵn tỷ lệ màn hình, và — khi bạn có nhiều hơn một màn hình — các điều khiển theo từng màn hình. Xem [màn hình](33-monitors.md) để biết câu chuyện sâu hơn.
- **Đồng hồ** mở một lưới tháng với số tuần ISO và chuyển đổi tháng.

Mọi bảng đều nhận bàn phím cũng như chuột: các phím mũi tên di chuyển, Return kích hoạt, Tab bước sang bảng bên cạnh, và Escape đóng lại.

`Super + Ctrl + 1-9` đếm các bảng từ trái sang phải trong phần bên phải, bỏ qua khay vì nó không có bảng riêng. Vì vậy con số khớp với biểu tượng mà bạn sẽ chỉ vào.

### Tailscale và Dropbox

Hai tiện ích nữa chỉ xuất hiện trên thanh khi bạn cài đặt dịch vụ tương ứng từ **Cài đặt → Dịch vụ**, và cả hai đều đáng biết vì chúng làm nhiều hơn việc báo cáo trạng thái.

Bảng **Tailscale** kết nối và ngắt kết nối tailnet, chuyển đổi giữa các tài khoản, và chọn một nút thoát (các máy của chính bạn và các khu vực Mullvad đều xuất hiện trong danh sách đó). Nó cũng duyệt các máy của bạn — và khi một máy được chọn, `s` gửi tệp tới nó qua Taildrop, đó là cách nhanh nhất để di chuyển một tệp tới điện thoại hoặc một laptop khác của bạn. `c` sao chép IP của máy, `n` sao chép tên của nó, và `d` sao chép tên DNS đầy đủ của nó. Cũng có một nút gửi trên mỗi hàng máy, nếu bạn thích nhấp chuột hơn. Điều tương tự từ terminal là `omarchy tailscale send <machine> [file...]`.

Bảng **Dropbox** xử lý đăng nhập, hiển thị lượng lưu trữ bạn đã dùng, và liệt kê các tệp đã đồng bộ gần đây.

Việc gỡ bỏ một trong hai dịch vụ sẽ lấy tiện ích của nó ra khỏi thanh.

## Chỉ báo

Cụm nhỏ ở giữa là tiện ích chỉ báo. Đây là các ký tự trạng thái cho các chế độ bạn đã bật: không làm phiền, đèn đêm, một [lời nhắc](09-reminders.md) đã xếp hàng, một bản ghi màn hình đang hoạt động, giữ thức, và [đọc chính tả](11-text-extraction-dictation.md). Chúng sáng lên khi chế độ đang hoạt động và nếu không sẽ tránh đường — di chuột sang trái đồng hồ (phía trên nó trên một thanh dọc) để nhìn lén những chỉ báo không hoạt động. Nhấp vào một chỉ báo sẽ bật/tắt chế độ đó. Một chỉ báo nữa chỉ là trạng thái: một phiên từ xa sáng đỏ trong khi ai đó được kết nối tới máy này qua gliff.

Nếu bạn muốn chúng luôn hiển thị, đặt `alwaysShow` thành `true` trên tiện ích. Và nếu bạn chỉ quan tâm đến một số trong chúng, liệt kê những cái bạn muốn trong `items`: `["Dnd", "Reminder", "NightLight"]`. Bạn có thể có nhiều hơn một tiện ích chỉ báo, vì vậy các phần khác nhau có thể hiển thị các tập hợp con khác nhau.

## Sắp xếp lại thanh

Thanh tự cấu hình chính nó. Bạn không cần mở một tệp cấu hình để di chuyển mọi thứ.

Lấy một khoảng trống của thanh xung quanh phần giữa và kéo nó về phía một cạnh màn hình khác, và thanh di chuyển tới đó — trái, phải, trên hoặc dưới đều hoạt động, và mọi tiện ích đều thích ứng (các thanh dọc quay lại dạng chỉ có biểu tượng nhỏ gọn). Nhấp và giữ cũng bắt đầu thao tác kéo tương tự. Nhấp đúp chuột trái vào cùng khoảng trống đó để chuyển đổi nền thanh từ trong sang kính sang đặc. Và kéo bất kỳ tiện ích nào để sắp xếp lại nó hoặc ném nó vào một phần khác.

Một tiện ích bạn muốn có sẵn nhưng không cần lúc nào cũng hiện ra có thể đi vào ngăn kéo của khay: kéo nó lên khay, và ngăn kéo mở ra để nhận nó. Nó nằm ở đó sau các biểu tượng ứng dụng, xuất hiện mỗi khi ngăn kéo xuất hiện, và giữ cho ngăn kéo luôn mở trong khi bảng của nó đang hiện. Kéo nó trở ra lên thanh để đưa nó trở lại.

Nếu bạn thích chọn từ một menu hơn, **Kích hoạt → Giao diện → Thanh menu** có vị trí, và **Nền thanh** chọn cách thanh được vẽ: **Thanh đặc**, **Thanh kính** (trong suốt, với những gì phía sau nó bị làm mờ), hoặc **Thanh trong**.

Những điều tương tự cũng có lệnh, đó là điều bạn muốn cho một thiết lập [dotfiles](31-dotfiles.md):

```bash
omarchy bar position bottom
omarchy bar background glassy  # opaque, glassy, none, or cycle
omarchy bar move omarchy.clock --section center --index 0
omarchy bar move omarchy.bluetooth --section tray  # into the tray's drawer
omarchy bar set omarchy.clock format "HH:mm"
omarchy bar defaults          # back to the shipped layout
```

Để thêm hoặc gỡ bỏ hoàn toàn một tiện ích, dùng các lệnh plugin. `omarchy plugin list` in ra mọi tiện ích mà shell biết cùng với id của nó, và sau đó:

```bash
omarchy plugin enable omarchy.media --section center
omarchy plugin disable omarchy.weather
```

## Ẩn thanh

`Super + Shift + Space` bật/tắt thanh mà không giết shell — các bảng và phím tắt tiếp tục hoạt động, bạn chỉ lấy lại được các pixel. Nó cũng nằm trong menu trong **Kích hoạt → Giao diện → Thanh menu → Ẩn thanh**.

## Tệp cấu hình

Tất cả được lưu trữ trong `~/.config/omarchy/shell.json`, dưới khóa `bar`. Đây là một phiên bản đã rút gọn:

```json
{
  "version": 1,
  "bar": {
    "position": "top",
    "background": "opaque",
    "centerAnchor": "omarchy.clock",
    "layout": {
      "left": [{ "id": "omarchy.menu" }, { "id": "omarchy.workspaces" }],
      "center": [{ "id": "omarchy.clock", "format": "HH:mm" }],
      "right": [{ "id": "omarchy.audio" }, { "id": "omarchy.power" }]
    }
  }
}
```

Mỗi tiện ích là một mục trong một trong ba mảng bố cục, và các cài đặt của nó nằm trực tiếp trên mục đó — không có tệp cài đặt riêng và không có đối tượng con `config`. `format`, `formatAlt` (thứ mà nhấp chuột phải chuyển đổi tới) và `verticalFormat` của đồng hồ đều nằm ngay tại đó trên `{ "id": "omarchy.clock" }`.

`centerAnchor` đặt tên cho tiện ích ở giữa duy nhất được ghim vào chính giữa màn hình, với các tiện ích khác ở hai bên nó. Đó là cách đồng hồ ở chính giữa ngay cả khi thời tiết và huy hiệu cập nhật đến rồi đi. Đặt nó thành một chuỗi rỗng và danh sách ở giữa chỉ được căn giữa dưới dạng một nhóm thay vào đó.

Một quy tắc đáng ghi nhớ: **một khi bạn có `shell.json` của riêng mình, nó là chuẩn mực**. Cho đến khi bạn tùy chỉnh bất cứ thứ gì, shell đọc tệp mặc định của Omarchy. Ngay khi bạn kéo một tiện ích, chạy `omarchy bar`, hoặc tự chỉnh sửa tệp, bạn sở hữu nó — không có hợp nhất sâu, vì vậy các tiện ích mặc định mới trong các bản phát hành Omarchy trong tương lai sẽ không tự động xuất hiện trên thanh của bạn. `omarchy bar defaults` đưa bố cục đã xuất xưởng trở lại bất cứ khi nào bạn muốn một khởi đầu sạch sẽ.

Cùng tệp đó cũng chứa các thời gian nhàn rỗi của bạn ở cấp cao nhất, bên ngoài khóa `bar`: `idle.screensaver` và `idle.lock`, cả hai đều tính bằng giây kể từ khi bạn nhàn rỗi. Vì vậy trình bảo vệ màn hình mặc định kích hoạt ở 150 giây và khóa ở 300 giây.
