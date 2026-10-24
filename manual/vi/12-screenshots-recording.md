# Ảnh chụp màn hình & Ghi hình

Mọi thứ bạn có thể lấy ra khỏi màn hình đều treo trên phím Print Screen. Một phím riêng lẻ chụp một bức ảnh, và các phím bổ trợ thực hiện ghi hình, lấy một màu, hoặc lấy văn bản bên trong một vùng. Nếu bàn phím của bạn hoàn toàn không có phím Print Screen, `Super + Ctrl + C` mở cùng bộ đó dưới dạng một menu.

| Phím tắt | Chức năng |
| ------ | -------- |
| `Print Screen` | Ảnh chụp màn hình |
| `Alt + Print Screen` | Ghi màn hình (hoặc dừng bản ghi đang chạy) |
| `Super + Print Screen` | Bộ chọn màu |
| `Super + Ctrl + Print Screen` | Trích xuất văn bản từ một vùng |
| `Super + Ctrl + C` | Menu chụp/ghi |
| `Super + Ctrl + .` | Chuyển mã một bức ảnh hoặc video |

## Ảnh chụp màn hình

Nhấn `Print Screen` và Omasnap chụp màn hình đang được tập trung trước khi lớp phủ của nó xuất hiện, vì vậy không có gì dịch chuyển dưới bạn trong khi bạn nhắm. Kéo một vùng tự do, nhấp vào một cửa sổ để chụp nó, hoặc nhấp vào khoảng trống để chụp toàn bộ màn hình. Nhấn `S` trước khi vẽ để chụp một vùng cuộn. Đã đổi ý? Nhấn `Print Screen` lần nữa để loại bỏ Omasnap.

Sau khi bạn chọn một vùng, Omasnap lưu bản chụp, sao chép nó vào bảng nhớ tạm, và hiển thị một bản xem trước trong 10 giây. Dùng nút ghim của bản xem trước hoặc `Ctrl + P` để giữ nó trên màn hình, hoặc chọn Edit để chú thích nó.

Trình soạn thảo chú thích có thể vẽ mũi tên, đường thẳng, hình dạng, phần tô sáng, dấu đánh số, văn bản và các phần che giấu an toàn; cắt hoặc khoét một phần của hình ảnh; OCR văn bản của nó; và thêm một phông nền. Trong trình soạn thảo, nhấn `Enter` để sao chép và lưu PNG đã hoàn thành, `Ctrl + C` để sao chép nó mà không lưu, hoặc `Ctrl + S` để lưu nó mà không sao chép.

Ảnh chụp màn hình đã lưu nằm trong `~/Pictures/Screenshots` theo mặc định, với một cái tên như `screenshot-2026-08-13_14-22-05-firefox.png`. Đặt `OMASNAP_SCREENSHOT_DIR` để dùng một thư mục khác — xem [FAQ](46-faq.md) để biết nơi đặt các biến môi trường phiên. Omasnap tạo thư mục khi nó lưu ảnh đầu tiên. Đặt `[output] autosave = false` trong `~/.config/omasnap/omasnap.conf` để tắt lưu tự động.

Từ terminal, `omarchy screenshot` mở cùng lớp phủ đó, và bạn có thể chọn chế độ bắt đầu của nó: `omarchy capture screenshot region`, `windows`, `fullscreen` hoặc `scroll`. Một đối số thứ hai là `copy` hoặc `save` bỏ qua bản xem trước và gửi ảnh thẳng tới đích đó. Để chỉnh sửa trước khi xuất, dùng `omarchy screenshot --editor=overlay` cho một trình soạn thảo toàn màn hình hoặc `omarchy screenshot --editor=window` cho một cửa sổ riêng.

### Điều khiển bộ chọn từ bàn phím

Trong khi vùng chọn đang hiển thị, bạn hoàn toàn không cần dùng chuột:

| Phím | Chức năng |
| --- | -------- |
| `S` | Bật/tắt chế độ vùng cuộn |
| `Super + Arrow keys` | Di chuyển giữa các cửa sổ trong chế độ Cửa sổ |
| `Return` | Chụp cửa sổ được tô sáng |
| `Ctrl + A` | Chụp toàn bộ màn hình đang được tập trung |
| `R` | Khôi phục vùng cuối cùng đã vẽ trong phiên này |
| `Esc` | Loại bỏ Omasnap |

Các phím gán này chỉ tồn tại trong khi Omasnap đang mở, vì vậy chúng không thể xung đột với bất cứ thứ gì trong cấu hình của riêng bạn.

## Ghi màn hình

`Alt + Print Screen` mở _Kích hoạt > Chụp/ghi > Ghi màn hình_, nơi hỏi bạn muốn gì trên bản nhạc nền: không có âm thanh, âm thanh desktop, desktop cộng micro, hoặc desktop cộng micro cộng webcam. Tùy chọn cuối cùng đó chỉ xuất hiện nếu bạn thực sự có một camera được cắm vào. Chọn một tùy chọn và bộ chọn ghi của Omarchy cho phép bạn kéo một vùng hoặc nhấp vào một cửa sổ hoặc màn hình.

Việc ghi chạy trên gpu-screen-recorder, mã hóa trên GPU ở 60fps và quay lại CPU nếu phải làm vậy. Kết quả là một tệp MP4 trong `~/Videos`, có tên `screenrecording-2026-08-13_14-22-05.mp4`. Đặt `OMARCHY_SCREENRECORD_DIR` để thay đổi điều đó — nhưng lưu ý rằng không giống thư mục ảnh chụp màn hình, thư mục này phải tồn tại sẵn, nếu không bản ghi từ chối bắt đầu.

Trong khi bạn đang ghi, một chỉ báo nhỏ xuất hiện trên thanh. Nhấp vào nó để dừng. Bạn cũng có thể dừng bằng `Alt + Print Screen` lần nữa, hoặc bằng mục _Dừng ghi màn hình_ trong _Kích hoạt > Chụp/ghi > Ghi màn hình_, mục này chỉ xuất hiện trong khi có thứ gì đó thực sự đang ghi.

Việc dừng thực hiện một chút dọn dẹp trước khi trao tệp cho bạn: khung hình đầu tiên được cắt bỏ, và nếu có âm thanh, nó được chuẩn hóa về -14 LUFS với tiếng bật khi chụp PipeWire ở ngay đầu được tắt tiếng. Sau đó một thông báo xuất hiện với một hình thu nhỏ từ bản ghi. Nhấp vào nó để phát tệp trong mpv.

### Lớp phủ webcam

Khi bạn ghi với một webcam, camera xuất hiện dưới dạng một cửa sổ chân dung đã ghim, đã cắt ở góc dưới bên phải của bất cứ thứ gì bạn đang ghi. Nếu nó đang nằm trên thứ gì đó bạn cần, hãy thay đổi kích thước nó ngay lập tức:

| Phím tắt | Chức năng |
| ------ | -------- |
| `Super + Alt + [` | Thu nhỏ lớp phủ webcam |
| `Super + Alt + ]` | Phóng to lớp phủ webcam |

Có ba kích thước — nhỏ, vừa và lớn — và các phím tắt bước qua chúng. Vừa là mặc định. Chúng tỷ lệ với bản ghi, vì vậy camera chiếm cùng một phần của khung hình dù bạn đang ghi một màn hình 1080p hay một màn hình 6K. Và nếu bạn ghi một vùng thay vì toàn bộ màn hình, lớp phủ neo vào góc của vùng đó thay vì góc của màn hình, vì vậy nó ở bên trong khung hình.

Bạn cũng có thể gọi nó trực tiếp bằng `omarchy-capture-webcam-resize small`, hoặc `reset` để quay lại vừa.

## Văn bản, mã QR và màu sắc

`Super + Ctrl + Print Screen` chọn một vùng và OCR nó vào bảng nhớ tạm. Điều đó được trình bày đúng cách trong [Trích xuất văn bản & Đọc chính tả](11-text-extraction-dictation.md).

_Kích hoạt > Chụp/ghi > Mã QR_ làm điều tương tự cho mã QR. Chọn vùng có mã trong đó, và giá trị đã giải mã đi vào bảng nhớ tạm. Nó chỉ tìm mã QR — nội dung màn hình dày đặc có thói quen dương tính giả thành mã vạch nếu không làm vậy. Đáng biết: giá trị đã giải mã đi vào bảng nhớ tạm và không đi đâu khác. Nó không được in ra, nó không nằm trong thông báo, và nó được đánh dấu là nhạy cảm vì vậy nó không tồn tại lâu trong [lịch sử bảng nhớ tạm](08-unified-clipboard-history.md). Mã QR thường mang theo bí mật — ví dụ như URI `otpauth://` đằng sau một mã thiết lập 2FA — và bạn không muốn thứ đó nằm trong một nhật ký. Việc dán vẫn hoạt động tốt.

`Super + Print Screen` (hoặc _Kích hoạt > Chụp/ghi > Màu_) biến con trỏ thành một ống nhỏ giọt. Nhấp vào bất cứ thứ gì trên màn hình và màu sắc nằm trên bảng nhớ tạm. Nhấn phím tắt lần nữa để thoát ra mà không chọn.

## Chuyển mã trước khi bạn chia sẻ

Một bản ghi màn hình 4K hoặc một tệp HEIC thô từ điện thoại của bạn thường quá lớn để chỉ gửi đi. `Super + Ctrl + .` (hoặc _Kích hoạt > Chuyển mã_) khắc phục điều đó. Nó cung cấp cho bạn một bộ chọn tệp mờ trên `~/Pictures` và `~/Videos`, sau đó hỏi về định dạng và kích thước.

Hình ảnh đi tới jpg hoặc png ở mức cao, vừa hoặc thấp, giới hạn chiều rộng ở 3160, 2160 và 1080 pixel. Video đi tới mp4 hoặc một tệp gif động ở 4k, 1080p hoặc 720p. Tệp đã chuyển đổi được ghi bên cạnh tệp gốc với độ phân giải trong tên — `demo-1080p.mp4` — và đường dẫn được sao chép vào bảng nhớ tạm dưới dạng một URI tệp, vì vậy bạn có thể dán nó trực tiếp vào một ứng dụng nhận tệp thả vào.

Nó cũng hoạt động từ terminal, nếu bạn đã biết mình muốn gì: `omarchy transcode ~/Videos/demo.mov mp4 1080p`. Ngoài ra còn có `omarchy transcode ascii`, biến một hình ảnh thành nghệ thuật ASCII — cái đó chủ yếu dành cho [thương hiệu](41-branding.md).

## Gửi nó đi đâu đó

Khi bạn đã có tệp, `Super + Ctrl + S` mở menu Chia sẻ và gửi nó tới một thiết bị khác trên mạng của bạn qua LocalSend. Xem [GUI](22-guis.md) cho điều đó.
