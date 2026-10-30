# Thanh trên cùng

Dải dọc theo cạnh trên của màn hình là thanh Omarchy. Nó không phải một thanh trạng thái gắn thêm vào, mà là một phần của shell Omarchy, tiến trình Quickshell duy nhất chạy lâu dài, cũng là tiến trình vẽ menu, các thông báo, các popup OSD và màn hình khóa. Đó là lý do nó ăn khớp hoàn hảo về giao diện với mọi thứ khác, và lý do một bảng mở ra ngay lập tức thay vì khởi chạy một ứng dụng mới.

Nó cũng là phần duy nhất của desktop luôn hiện trên màn hình, vì vậy đáng để biết tất cả những glyph nhỏ đó làm gì.

## Mặc định có những gì trên đó

Thanh có ba phần. Ở bên trái là logo Omarchy (trình khởi chạy menu) và các chỉ báo không gian làm việc. Ở giữa, bạn có các chỉ báo trạng thái, đồng hồ, Elsewhen (một đồng hồ thế giới), thời tiết và huy hiệu cập nhật Omarchy. Ở bên phải: khay hệ thống, bố cục bàn phím (khi có nhiều hơn một bố cục được cấu hình), agents, bluetooth, mạng, âm thanh, màn hình và nguồn.

Một vài thứ trong số đó chỉ xuất hiện khi chúng có điều gì để nói. Bố cục bàn phím chỉ xuất hiện nếu bạn đã cấu hình nhiều hơn một bố cục. Huy hiệu cập nhật chỉ xuất hiện khi có một bản cập nhật Omarchy đang chờ. Và biểu tượng agents xuất hiện lần đầu tiên Omarchy tìm thấy mức sử dụng AI coding trên máy (xem [AI](17-ai.md)).

## Nhấn chuột khắp nơi

Gần như mọi widget đều làm gì đó khi nhấn chuột trái, phải và giữa, và một vài widget phản hồi với thao tác cuộn. Đây là phần mọi người bỏ lỡ — các nút phải và giữa là nơi ẩn chứa rất nhiều thứ hay ho.

| Widget | Trái | Phải | Giữa / cuộn |
| --- | --- | --- | --- |
| Menu | Menu Omarchy | Terminal mới | — |
| Không gian làm việc | Tập trung vào không gian làm việc đó trên màn hình này | — | Cuộn: không gian làm việc tiếp theo/trước đó |
| Đồng hồ | Popup lịch | Chuyển vòng định dạng nhãn | Giữa: bộ chọn múi giờ |
| Thời tiết | Popup dự báo | Thời tiết đầy đủ dưới dạng thông báo | Giữa: làm mới |
| Âm thanh | Bảng âm thanh | Tắt tiếng | Giữa: bảng · cuộn: âm lượng |
| Microphone | Tắt tiếng mic | — | Giữa: bảng âm thanh · cuộn: âm lượng đầu vào |
| Mạng | Bảng mạng | — | — |
| Bluetooth | Bảng Bluetooth | Bật/tắt radio | — |
| Màn hình | Bảng màn hình | — | Cuộn: độ sáng |
| Nguồn | Bảng nguồn | Bật/tắt phần trăm pin | — |
| Media | Phát/tạm dừng | Popup ảnh bìa | Giữa: tiếp theo · cuộn: trước/tiếp theo |
| Agents | Bảng Agents | Khởi chạy agent của bạn | Giữa: gói đăng ký tiếp theo |
| Khay | Di chuột để lộ ngăn kéo | Nhấn phải vào chevron để quản lý | — |
| Cập nhật Omarchy | Chạy cập nhật | — | — |

Không phải mọi thứ trong bảng đó đều có trên thanh của bạn ngay từ đầu. Widget media (MPRIS đang phát, với track và nghệ sĩ cuộn) và widget microphone đều được tích hợp sẵn nhưng tắt theo mặc định — hãy thêm chúng nếu bạn muốn, như mô tả bên dưới.

## Các bảng

Nhấn vào một biểu tượng trên thanh sẽ mở một bảng, tức là một popup đúng nghĩa với các thanh trượt, danh sách và điều hướng bằng bàn phím chứ không phải một tooltip. Mỗi bảng cũng có một phím tắt, vì vậy bạn không bao giờ phải nhắm vào một glyph 16-pixel:

| Phím tắt | Bảng |
| --- | --- |
| `Super + Ctrl + A` | Âm thanh |
| `Super + Ctrl + N` | Mạng |
| `Super + Ctrl + B` | Bluetooth |
| `Super + Ctrl + D` | Màn hình |
| `Super + Ctrl + P` | Nguồn |
| `Super + Ctrl + Alt + D` | Lịch |
| `Super + Ctrl + Alt + E` | Đồng hồ thế giới |
| `Super + Ctrl + 1-9` | Bật/tắt bảng thứ n trong phần bên phải |

Các bảng không phải là bảng chỉ đọc thông tin. Chúng là nơi bạn thực sự làm việc đó:

- **Audio** có một thanh trượt âm lượng tổng, một bộ chọn thiết bị đầu ra và một bộ trộn theo từng ứng dụng, vì vậy bạn có thể giảm âm lượng của đúng tab trình duyệt đó mà không động vào mọi thứ khác.
- **Network** quét Wi-Fi, hiển thị cường độ tín hiệu, kết nối và cho phép bạn chọn một nhà cung cấp DNS.
- **Bluetooth** liệt kê các thiết bị của bạn với trạng thái kết nối/ngắt kết nối và mức pin.
- **Power** hiển thị số liệu pin, chuyển đổi các hồ sơ nguồn (nó ghi nhớ lựa chọn riêng cho pin và AC), và in ra một số thông tin hệ thống.
- **Display** mang theo một thanh trượt độ sáng, kích thước văn bản, các cài đặt sẵn về tỉ lệ màn hình, và — khi bạn có nhiều hơn một màn hình — các điều khiển cho từng màn hình. Xem [monitors](33-monitors.md) để biết câu chuyện sâu hơn.
- **Clock** mở một lưới tháng với số tuần ISO và thao tác chuyển tháng.
- **World clock** giữ một hàng cho mỗi thành phố, với thời tiết của nó và ngày của nó đang diễn ra thế nào. Tìm kiếm tìm thấy các thị trấn cũng như các múi giờ, vì vậy Fort Lauderdale là Fort Lauderdale chứ không phải New York. Nếu dòng ở trên cùng nêu sai thành phố, hãy nhấn vào nó và cho biết bạn đang ở đâu; chọn một nơi ở múi giờ khác và đồng hồ hệ thống cũng di chuyển tới đó, điều này rất tiện khi bạn đi du lịch. Di chuột lên một thành phố và nhấn nút hình người để cho biết ai sống ở đó — tên thường, hoặc handle GitHub `@` để mang theo khuôn mặt của họ.

Mọi bảng đều nhận cả bàn phím lẫn chuột: các phím mũi tên di chuyển, Return kích hoạt, Tab bước sang bảng kề bên, và Escape đóng lại.

`Super + Ctrl + 1-9` đếm các bảng từ trái sang phải trong phần bên phải, bỏ qua khay vì nó không có bảng riêng. Vì vậy con số khớp với biểu tượng mà bạn sẽ chỉ vào.

### Tailscale và Dropbox

Hai widget nữa chỉ xuất hiện trên thanh một khi bạn cài đặt dịch vụ tương ứng từ **Install → Service**, và cả hai đều đáng biết vì chúng làm được nhiều hơn là báo cáo trạng thái.

Bảng **Tailscale** kết nối và ngắt kết nối tailnet, chuyển đổi giữa các tài khoản, và chọn một exit node (cả máy của chính bạn và các vùng Mullvad đều xuất hiện trong danh sách đó). Nó cũng duyệt các máy của bạn — và với một máy được chọn, `s` gửi file tới nó qua Taildrop, đó là cách nhanh nhất để chuyển một file tới điện thoại hoặc một laptop khác của bạn. `c` sao chép IP của máy, `n` sao chép tên của nó, và `d` sao chép tên DNS đầy đủ của nó. Cũng có một nút gửi trên mỗi hàng máy, nếu bạn thích nhấn chuột hơn. Điều tương tự từ terminal là `omarchy tailscale send <machine> [file...]`.

Bảng **Dropbox** xử lý đăng nhập, hiển thị bạn đã dùng bao nhiêu dung lượng lưu trữ, và liệt kê các file được đồng bộ gần đây.

Gỡ bỏ bất kỳ dịch vụ nào trong hai dịch vụ này cũng sẽ đưa widget của nó ra khỏi thanh.

## Các chỉ báo

Cụm nhỏ ở giữa là widget chỉ báo. Đây là các glyph trạng thái cho các chế độ bạn đã bật: không làm phiền, ánh sáng ban đêm, một [lời nhắc](09-reminders.md) đang xếp hàng, một bản ghi màn hình đang hoạt động, giữ tỉnh táo, và [dictation](11-text-extraction-dictation.md). Chúng sáng lên khi chế độ đang hoạt động và nếu không thì tránh sang một bên — di chuột vào bất cứ đâu trên thanh để nhìn lén những cái không hoạt động. Nhấn vào một chỉ báo sẽ bật/tắt chế độ đó. Còn một cái nữa chỉ để hiển thị trạng thái: một phiên từ xa sáng đỏ trong khi ai đó kết nối tới máy này qua gliff.

Nếu bạn muốn chúng luôn hiển thị, hãy đặt `alwaysShow` thành `true` trên widget. Và nếu bạn chỉ quan tâm tới một số trong chúng, hãy liệt kê những cái bạn muốn trong `items`: `["Dnd", "Reminder", "NightLight"]`. Bạn có thể có nhiều hơn một widget chỉ báo, vì vậy các phần khác nhau có thể hiển thị các tập con khác nhau.

## Sắp xếp lại thanh

Thanh tự cấu hình chính nó. Bạn không cần mở một file cấu hình để di chuyển mọi thứ.

Nắm lấy một khoảng trống của thanh quanh phần giữa và kéo nó về phía một cạnh màn hình khác, và thanh sẽ di chuyển tới đó — trái, phải, trên hoặc dưới đều hoạt động, và mọi widget đều thích ứng (các thanh dọc quay về dạng compact chỉ có biểu tượng). Một thao tác nhấn và giữ cũng bắt đầu cùng một thao tác kéo. Nhấn đúp chuột trái vào cùng khoảng trống đó để chuyển vòng nền thanh từ trong suốt sang mờ kính sang đục. Và kéo bất kỳ widget nào để sắp xếp lại nó hoặc ném nó vào một phần khác; các widget khác trượt tách ra để nhường chỗ tại nơi nó sẽ đáp xuống.

Phần giữa của thanh là một hộp: bất cứ thứ gì trong đó đều giữ ở vị trí trung tâm như một nhóm, và các widget ở hai phía của nó treo lơ lửng ở các cạnh của nó. Trong khi bạn kéo một widget, hộp hiển thị dưới dạng đường viền, hoặc một đường thẳng ngang qua thanh khi nó trống, và bạn có thể thả vào trong nó hoặc bên cạnh nó. Khi một lần thả sẽ đáp vào hộp, hộp sẽ lớn lên để nhận widget vào.

Một widget bạn muốn có quanh đây nhưng không phải lúc nào cũng trong tầm nhìn có thể đi vào ngăn kéo của khay: kéo nó lên khay, và ngăn kéo mở ra để nhận nó. Nó ngồi ở đó sau các biểu tượng ứng dụng, xuất hiện bất cứ khi nào ngăn kéo xuất hiện, và giữ ngăn kéo của nó mở trong khi bảng của nó đang bật. Kéo nó trở lại thanh để đặt nó về chỗ cũ.

Nếu bạn thích chọn từ một menu hơn, **Appearance → Menu Bar** có vị trí, và **Bar Background** chọn cách thanh được vẽ: **Opaque Bar**, **Glassy Bar** (trong suốt, với phần phía sau nó bị làm mờ), hoặc **Clear Bar**.

Những điều tương tự cũng có các lệnh, đó là điều bạn muốn cho một thiết lập [dotfiles](31-dotfiles.md):

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

`Super + Shift + Space` bật/tắt thanh mà không giết shell — các bảng và phím tắt vẫn tiếp tục hoạt động, bạn chỉ lấy lại được các pixel. Nó cũng có trong menu dưới **Appearance → Menu Bar → Hide Bar**.

## File cấu hình

Tất cả đều được lưu trong `~/.config/omarchy/shell.json`, dưới khóa `bar`. Đây là một phiên bản đã rút gọn:

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

Mỗi widget là một mục trong một trong năm mảng bố cục, và các cài đặt của nó nằm ngay trên mục đó — không có file cài đặt riêng và không có đối tượng con `config`. `format`, `formatAlt` (thứ mà nhấn chuột phải chuyển vòng tới) và `verticalFormat` của đồng hồ đều sống ngay tại đó trên `{ "id": "omarchy.clock" }`.

`center` là hộp ở giữa thanh: mọi thứ trong đó đều được căn giữa trên màn hình như một nhóm. `centerBegin` và `centerEnd` treo ở hai phía của hộp, đó là cách đồng hồ giữ đúng ở chính giữa ngay cả khi thời tiết và huy hiệu cập nhật đến và đi. Đặt nhiều hơn một widget vào `center` và chúng được căn giữa cùng nhau; để nó trống và `centerBegin` cùng `centerEnd` gặp nhau ở giữa thanh.

Một quy tắc đáng ghi nhớ: **một khi bạn có `shell.json` của riêng mình, nó là chuẩn duy nhất**. Cho đến khi bạn tùy chỉnh bất cứ thứ gì, shell đọc file mặc định của Omarchy. Ngay khoảnh khắc bạn kéo một widget, chạy `omarchy bar`, hoặc tự sửa file, bạn sở hữu nó — không có hợp nhất sâu, vì vậy các widget mặc định mới trong các bản phát hành Omarchy tương lai sẽ không tự động xuất hiện trên thanh của bạn. `omarchy bar defaults` đặt bố cục được phát hành kèm theo trở lại bất cứ khi nào bạn muốn một khởi đầu sạch sẽ.

Cùng file đó cũng giữ các thời gian nhàn rỗi của bạn ở cấp trên cùng, bên ngoài khóa `bar`: `idle.screensaver` và `idle.lock`, cả hai đều tính bằng giây kể từ khi bạn đi vào trạng thái nhàn rỗi. Vì vậy trình bảo vệ màn hình mặc định khởi động ở 150 giây và khóa ở 300 giây.
