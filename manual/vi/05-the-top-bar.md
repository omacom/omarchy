# Thanh trên cùng

Dải nằm dọc theo cạnh trên của màn hình là thanh Omarchy. Nó không phải một thanh trạng thái gắn thêm vào, mà là một phần của shell Omarchy, tiến trình Quickshell duy nhất chạy lâu dài, cũng là tiến trình vẽ menu, thông báo, các cửa sổ bật lên OSD và màn hình khóa. Đó là lý do nó ăn khớp hoàn hảo về giao diện với mọi thứ khác, và là lý do một bảng mở ra ngay lập tức thay vì phải khởi chạy một ứng dụng mới.

Đây cũng là phần duy nhất của desktop luôn hiện trên màn hình, vì vậy đáng để biết tất cả những ký hiệu nhỏ xíu đó làm gì.

## Có gì trên đó theo mặc định

Thanh này có ba phần. Ở bên trái là logo Omarchy (trình khởi chạy menu) và các chỉ báo không gian làm việc. Ở giữa, bạn có các chỉ báo trạng thái, đồng hồ, Elsewhen (một đồng hồ thế giới), thời tiết và huy hiệu cập nhật Omarchy. Ở bên phải: khay hệ thống, bố cục bàn phím (khi có nhiều hơn một bố cục được cấu hình), agents, Bluetooth, mạng, âm thanh, màn hình và nguồn điện.

Một vài thứ trong số đó chỉ xuất hiện khi chúng có điều gì đó để nói. Bố cục bàn phím chỉ xuất hiện nếu bạn đã cấu hình nhiều hơn một bố cục. Huy hiệu cập nhật chỉ xuất hiện khi có một bản cập nhật Omarchy đang chờ. Và biểu tượng agents xuất hiện ngay lần đầu tiên Omarchy tìm thấy việc sử dụng AI coding trên máy (xem [AI](17-ai.md)).

## Nhấp chuột khắp nơi

Gần như mọi widget đều làm một việc gì đó khi nhấp chuột trái, chuột phải và chuột giữa, và nhiều widget còn phản hồi khi cuộn. Đây là phần người ta hay bỏ lỡ — nút phải và nút giữa là nơi ẩn giấu rất nhiều thứ hay ho.

| Widget | Trái | Phải | Giữa / cuộn |
| --- | --- | --- | --- |
| Menu | Menu Omarchy | Terminal mới | — |
| Các không gian làm việc | Chuyển đến không gian làm việc đó trên màn hình này | — | Cuộn: không gian làm việc tiếp theo/trước đó |
| Đồng hồ | Cửa sổ bật lên lịch | Chuyển vòng qua các định dạng nhãn | Giữa: bộ chọn múi giờ |
| Thời tiết | Cửa sổ bật lên dự báo | Toàn bộ thời tiết dưới dạng thông báo | Giữa: làm mới |
| Âm thanh | Bảng âm thanh | Tắt tiếng | Giữa: bảng · cuộn: âm lượng |
| Micrô | Tắt tiếng mic | — | Giữa: bảng âm thanh · cuộn: âm lượng đầu vào |
| Mạng | Bảng mạng | — | — |
| Bluetooth | Bảng Bluetooth | Bật/tắt radio | — |
| Màn hình | Bảng màn hình | — | Cuộn: độ sáng |
| Nguồn điện | Bảng nguồn điện | Bật/tắt phần trăm pin | — |
| Media | Phát/tạm dừng | Cửa sổ bật lên ảnh bìa | Giữa: bài tiếp theo · cuộn: bài trước/tiếp theo |
| Agents | Bảng agents | Khởi chạy agent của bạn | Giữa: gói đăng ký tiếp theo |
| Khay | Di chuột lên để hiện ngăn kéo | Nhấp chuột phải vào dấu chevron để quản lý | — |
| Cập nhật Omarchy | Chạy cập nhật | — | — |

Không phải mọi thứ trong bảng đó đều có trên thanh của bạn ngay từ đầu. Widget media (MPRIS đang phát, với bản nhạc và nghệ sĩ cuộn qua) và widget micrô đều được tích hợp sẵn nhưng tắt theo mặc định — hãy thêm chúng nếu bạn muốn, như mô tả bên dưới.

## Các bảng

Nhấp vào một biểu tượng trên thanh sẽ mở một bảng, đó là một cửa sổ bật lên tử tế với các thanh trượt, danh sách và điều hướng bằng bàn phím, chứ không phải một tooltip. Mỗi bảng cũng có một phím tắt riêng, vì vậy bạn không bao giờ phải ngắm bắn vào một ký hiệu 16 pixel:

| Phím tắt | Bảng |
| --- | --- |
| `Super + Ctrl + A` | Âm thanh |
| `Super + Ctrl + N` | Mạng |
| `Super + Ctrl + B` | Bluetooth |
| `Super + Ctrl + D` | Màn hình |
| `Super + Ctrl + P` | Nguồn điện |
| `Super + Ctrl + Alt + D` | Lịch |
| `Super + Ctrl + Alt + E` | Đồng hồ thế giới |
| `Super + Ctrl + 1-9` | Bật/tắt bảng thứ n trong phần bên phải |

Các bảng không phải là màn hình chỉ để đọc số liệu. Chúng là nơi bạn thực sự làm việc đó:

- **Âm thanh** có thanh trượt âm lượng tổng, bộ chọn thiết bị đầu ra và bộ trộn theo từng ứng dụng, vì vậy bạn có thể giảm âm lượng của đúng một tab trình duyệt đó mà không động đến mọi thứ còn lại.
- **Mạng** quét tìm Wi-Fi, hiển thị cường độ tín hiệu, kết nối và cho phép bạn chọn một nhà cung cấp DNS.
- **Bluetooth** liệt kê các thiết bị của bạn với kết nối/ngắt kết nối và mức pin.
- **Nguồn điện** hiển thị số liệu pin, chuyển đổi cấu hình nguồn điện (nó ghi nhớ lựa chọn riêng cho pin và AC), và in ra một số thông tin hệ thống.
- **Màn hình** mang theo thanh trượt độ sáng, kích thước văn bản, các thiết lập sẵn cho tỉ lệ màn hình, và — khi bạn có nhiều hơn một màn hình — các điều khiển cho từng màn hình. Xem [màn hình](33-monitors.md) để biết câu chuyện sâu hơn.
- **Đồng hồ** mở một lưới tháng với số tuần ISO và việc chuyển bước theo tháng.
- **Đồng hồ thế giới** giữ một hàng cho mỗi thành phố, với thời tiết của nó và ngày của nó đang diễn ra thế nào. Tìm kiếm tìm thấy các thị trấn cũng như các múi giờ, vì vậy Fort Lauderdale là Fort Lauderdale chứ không phải New York. Nếu dòng ở trên cùng nêu sai thành phố, hãy nhấp vào nó và nói bạn đang ở đâu; chọn một nơi ở múi giờ khác và đồng hồ hệ thống cũng di chuyển đến đó, điều này rất tiện khi bạn đi du lịch. Di chuột lên một thành phố và nhấp vào nút hình người để nói ai sống ở đó — tên đơn giản, hoặc các tên định danh GitHub bắt đầu bằng `@` để mang theo khuôn mặt của họ.

Mỗi bảng đều tiếp nhận bàn phím cũng như chuột: các phím mũi tên để di chuyển, Return để kích hoạt, Tab để bước sang bảng bên cạnh, và Escape để đóng.

`Super + Ctrl + 1-9` đếm các bảng từ trái sang phải trong phần bên phải, bỏ qua khay vì nó không có bảng riêng. Vì vậy con số khớp với biểu tượng bạn sẽ chỉ vào.

### Tailscale và Dropbox

Hai widget nữa chỉ xuất hiện trên thanh một khi bạn cài đặt dịch vụ tương ứng từ **Cài đặt → Dịch vụ**, và cả hai đều đáng biết vì chúng làm nhiều hơn là báo cáo trạng thái.

Bảng **Tailscale** kết nối và ngắt kết nối tailnet, chuyển đổi giữa các tài khoản và chọn một exit node (cả máy của chính bạn và các khu vực Mullvad đều xuất hiện trong danh sách đó). Nó cũng duyệt các máy của bạn — và khi một máy được chọn, `s` sẽ gửi tệp đến nó qua Taildrop, đó là cách nhanh nhất để chuyển một tệp đến điện thoại hoặc một laptop khác của bạn. `c` sao chép IP của máy, `n` sao chép tên của nó, và `d` sao chép tên DNS đầy đủ của nó. Cũng có một nút gửi trên mỗi hàng máy, nếu bạn thích nhấp chuột hơn. Việc tương tự từ terminal là `omarchy tailscale send <machine> [file...]`.

Bảng **Dropbox** xử lý đăng nhập, hiển thị bạn đã dùng bao nhiêu dung lượng lưu trữ, và liệt kê các tệp đã đồng bộ gần đây.

Gỡ bỏ một trong hai dịch vụ sẽ loại bỏ widget của nó khỏi thanh.

## Các chỉ báo

Cụm nhỏ ở giữa là widget chỉ báo. Đây là các ký hiệu trạng thái cho các chế độ bạn đã bật: không làm phiền, ánh sáng đêm, một [lời nhắc](09-reminders.md) đang xếp hàng, một phiên ghi màn hình đang hoạt động, giữ máy thức, và [nhập liệu bằng giọng nói](11-text-extraction-dictation.md). Chúng sáng lên khi chế độ đang hoạt động và ngược lại thì tránh sang một bên — hãy di chuột ngay bên cạnh chúng, nơi các chỉ báo không hoạt động sẽ nằm, để hé nhìn những chỉ báo đó. Nhấp vào một chỉ báo sẽ bật/tắt chế độ đó. Còn một chỉ báo nữa chỉ để hiển thị trạng thái: một phiên từ xa sáng đỏ trong khi ai đó đang kết nối đến máy này qua gliff.

Nếu bạn muốn chúng luôn hiển thị, hãy đặt `alwaysShow` thành `true` trên widget. Và nếu bạn chỉ quan tâm đến một số trong chúng, hãy liệt kê những cái bạn muốn trong `items`: `["Dnd", "Reminder", "NightLight"]`. Bạn có thể có nhiều hơn một widget chỉ báo, vì vậy các phần khác nhau có thể hiển thị các tập con khác nhau.

## Sắp xếp lại thanh

Thanh tự cấu hình. Bạn không phải mở một tệp cấu hình để di chuyển mọi thứ.

Nắm lấy một khoảng trống của thanh quanh khu vực giữa và kéo nó về phía một cạnh màn hình khác, và thanh sẽ di chuyển đến đó — trái, phải, trên hoặc dưới đều hoạt động, và mọi widget đều thích ứng (các thanh dọc sẽ quay về dạng rút gọn chỉ có biểu tượng). Nhấp và giữ cũng bắt đầu cùng một thao tác kéo đó. Nhấp đúp chuột trái vào cùng khoảng trống đó để chuyển vòng nền của thanh từ trong suốt sang dạng kính sang đục. Và kéo bất kỳ widget nào để sắp xếp lại nó hoặc ném nó vào một phần khác; các widget còn lại sẽ trượt ra xa nhau để nhường chỗ tại nơi nó sẽ hạ xuống.

Phần giữa của thanh là một hộp: bất cứ thứ gì trong đó đều ở giữa như một nhóm duy nhất, và các widget ở hai phía của nó treo vào các cạnh của nó. Trong khi bạn kéo một widget, hộp hiện ra dưới dạng một đường viền, hoặc một đường thẳng ngang qua thanh khi nó trống, và bạn có thể thả vào trong nó hoặc bên cạnh nó. Khi một lần thả sẽ hạ xuống trong hộp, hộp sẽ lớn ra để đón widget vào.

Một widget bạn muốn ở quanh mình nhưng không phải lúc nào cũng trong tầm mắt có thể đi vào ngăn kéo của khay: kéo nó lên khay, và ngăn kéo mở ra để đón nó. Nó ngồi ở đó sau các biểu tượng ứng dụng, xuất hiện bất cứ khi nào ngăn kéo xuất hiện, và giữ cho ngăn kéo của nó mở trong khi bảng của nó đang mở. Kéo nó trở lại ra thanh để đặt nó trở lại.

Nếu bạn thích chọn từ một menu hơn, **Giao diện → Thanh Menu** có vị trí, và **Nền Thanh** chọn cách thanh được vẽ: **Thanh Đục**, **Thanh Kính** (trong suốt, với những gì phía sau nó bị làm mờ), hoặc **Thanh Trong Suốt**.

Mọi thứ tương tự đều có lệnh, đó là điều bạn muốn cho một thiết lập [dotfiles](31-dotfiles.md):

```bash
omarchy bar position bottom
omarchy bar background glassy  # opaque, glassy, none, or cycle
omarchy bar move omarchy.weather --section centerBegin --index 0
omarchy bar move omarchy.bluetooth --section tray  # into the tray's drawer
omarchy bar set omarchy.clock format "HH:mm"
omarchy bar defaults          # back to the shipped layout
```

Để thêm hoặc loại bỏ một widget hoàn toàn, hãy dùng các lệnh plugin. `omarchy plugin list` in ra mọi widget mà shell biết cùng với id của nó, và sau đó:

```bash
omarchy plugin enable omarchy.media --section centerEnd
omarchy plugin disable omarchy.weather
```

## Ẩn thanh

`Super + Shift + Space` tắt thanh và bật lại mà không giết shell — các bảng và phím tắt vẫn hoạt động, bạn chỉ lấy lại các pixel. Nó cũng nằm trong menu dưới **Giao diện → Thanh Menu → Ẩn Thanh**.

## Tệp cấu hình

Tất cả được lưu trữ trong `~/.config/omarchy/shell.json`, dưới khóa `bar`. Đây là một phiên bản đã cắt gọn:

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

Mỗi widget là một mục trong một trong năm mảng bố cục, và các cài đặt của nó nằm ngay trên mục đó — không có tệp cài đặt riêng và không có đối tượng con `config`. `format`, `formatAlt` (định dạng mà nhấp chuột phải chuyển vòng đến) và `verticalFormat` của đồng hồ đều sống ngay tại đó trên `{ "id": "omarchy.clock" }`.

`center` là hộp ở giữa thanh: mọi thứ trong đó được căn giữa trên màn hình như một nhóm. `centerBegin` và `centerEnd` treo vào hai phía của hộp, đó là cách đồng hồ luôn ở chính giữa ngay cả khi thời tiết và huy hiệu cập nhật đến và đi. Đặt nhiều hơn một widget trong `center` và chúng được căn giữa cùng nhau; để nó trống và `centerBegin` cùng `centerEnd` gặp nhau ở giữa thanh.

Một quy tắc đáng khắc sâu: **một khi bạn có `shell.json` của riêng mình, nó là thứ có tính chuẩn tắc**. Cho đến khi bạn tùy chỉnh bất cứ thứ gì, shell đọc tệp mặc định của Omarchy. Ngay khoảnh khắc bạn kéo một widget, chạy `omarchy bar`, hoặc tự sửa tệp, bạn sở hữu nó — không có phép trộn sâu nào cả, vì vậy các widget mặc định mới trong các bản phát hành Omarchy tương lai sẽ không xuất hiện trên thanh của bạn một cách tự động. `omarchy bar defaults` đưa bố cục được phát hành kèm theo trở lại bất cứ khi nào bạn muốn một khởi đầu sạch sẽ.

Cùng tệp đó cũng chứa các thời gian chờ không hoạt động của bạn ở cấp cao nhất, ngoài khóa `bar`: `idle.screensaver` và `idle.lock`, cả hai đều tính bằng giây kể từ khi bạn không hoạt động. Vì vậy trình bảo vệ màn hình mặc định bắt đầu chạy ở 150 giây và khóa ở 300 giây.
