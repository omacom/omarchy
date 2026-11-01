# Ảnh chụp màn hình & Quay màn hình

Mọi thứ bạn có thể lấy khỏi màn hình đều treo trên phím Print Screen. Một phím đơn độc chụp một bức ảnh, và các phím bổ trợ quay, lấy một màu, hoặc lấy văn bản bên trong một vùng. Nếu bàn phím của bạn hoàn toàn không có phím Print Screen, `Super + Ctrl + Alt + C` chụp cùng ảnh chụp màn hình đó, và `Super + Ctrl + C` mở toàn bộ bộ tính năng dưới dạng một menu.

| Phím tắt | Chức năng |
| ------ | -------- |
| `Print Screen` | Ảnh chụp màn hình |
| `Super + Ctrl + Alt + C` | Ảnh chụp màn hình |
| `Alt + Print Screen` | Quay màn hình (hoặc dừng lần quay đang chạy) |
| `Super + Print Screen` | Bộ chọn màu |
| `Super + Ctrl + Print Screen` | Trích xuất văn bản từ một vùng |
| `Super + Ctrl + C` | Menu chụp/quay |
| `Super + Ctrl + .` | Chuyển mã một bức ảnh hoặc video |

## Ảnh chụp màn hình

Nhấn `Print Screen` (hoặc `Super + Ctrl + Alt + C`) và Omasnap chụp màn hình đang được focus trước khi lớp phủ của nó xuất hiện, vì vậy không có gì dịch chuyển dưới bạn trong khi bạn ngắm. Kéo một vùng tự do, nhấp vào một cửa sổ để chụp nó, hoặc nhấp vào khoảng trống để chụp toàn bộ màn hình. Nhấn `S` trước khi vẽ để chụp một vùng cuộn. Đổi ý? Nhấn lại cùng phím đó để đóng Omasnap.

Sau khi bạn chọn một vùng, Omasnap lưu ảnh chụp, sao chép nó vào clipboard, và hiển thị một thông báo kèm hình thu nhỏ của nó, giống như một bản quay màn hình đã lưu vẫn làm. Chọn Open để xem ảnh đã lưu trong trình xem ảnh của bạn, hoặc Edit để chú thích nó.

Trình chỉnh sửa chú thích có thể vẽ mũi tên, đường thẳng, hình dạng, vùng làm nổi bật, điểm đánh dấu được đánh số, văn bản, và các vùng che giấu an toàn; cắt xén hoặc cắt bỏ một phần của hình ảnh; OCR văn bản của nó; và thêm một nền phía sau. Trong trình chỉnh sửa, nhấn `Enter` để sao chép và lưu PNG hoàn thiện, `Ctrl + C` để sao chép nó mà không lưu, hoặc `Ctrl + S` để lưu nó mà không sao chép.

Ảnh chụp màn hình đã lưu mặc định nằm trong `~/Pictures/Screenshots`, với một tên như `screenshot-2026-08-13_14-22-05-firefox.png`. Đặt `OMASNAP_SCREENSHOT_DIR` để dùng một thư mục khác — xem [FAQ](46-faq.md) để biết nơi đặt các biến môi trường của phiên. Omasnap tạo thư mục khi nó lưu ảnh đầu tiên. Đặt `[output] autosave = false` trong `~/.config/omasnap/omasnap.conf` để tắt lưu tự động; ảnh chụp khi đó chỉ được sao chép, và được hiển thị trong một bản xem trước trong 10 giây mà bạn có thể giữ trên màn hình bằng nút ghim của nó hoặc `Ctrl + P`.

Từ terminal, `omarchy screenshot` mở cùng lớp phủ đó, và bạn có thể chọn chế độ bắt đầu của nó: `omarchy capture screenshot region`, `windows`, `fullscreen`, hoặc `scroll`. Một đối số thứ hai là `copy` hoặc `save` gửi ảnh chụp thẳng tới đích đó. Để chỉnh sửa trước khi xuất, dùng `omarchy screenshot --editor=overlay` cho một trình chỉnh sửa toàn màn hình hoặc `omarchy screenshot --editor=window` cho một cửa sổ riêng.

### Điều khiển bộ chọn từ bàn phím

Trong khi vùng chọn đang hiển thị, bạn hoàn toàn không cần dùng chuột:

| Phím | Chức năng |
| --- | -------- |
| `S` | Bật/tắt chế độ vùng cuộn |
| `Super + Arrow keys` | Di chuyển giữa các cửa sổ trong chế độ Window |
| `Return` | Chụp cửa sổ được làm nổi bật |
| `Ctrl + A` | Chụp toàn bộ màn hình đang được focus |
| `R` | Khôi phục vùng cuối cùng đã vẽ trong phiên này |
| `Esc` | Đóng Omasnap |

Các phím gán này chỉ tồn tại trong khi Omasnap đang mở, vì vậy chúng không thể xung đột với bất cứ thứ gì trong cấu hình của riêng bạn.

## Quay màn hình

`Alt + Print Screen` mở _Trigger > Capture > Screenrecord_, mục này hỏi bạn muốn gì trên bản nhạc âm thanh: không có âm thanh, âm thanh desktop, desktop cộng microphone, hoặc desktop cộng microphone cộng webcam. Lựa chọn cuối đó chỉ xuất hiện nếu bạn thực sự có một camera đã cắm vào. Chọn một lựa chọn và bộ chọn quay của Omarchy cho phép bạn kéo một vùng hoặc nhấp vào một cửa sổ hoặc màn hình.

Việc quay chạy trên gpu-screen-recorder, công cụ mã hóa trên GPU ở 60fps và quay về CPU nếu buộc phải làm vậy. Kết quả là một MP4 trong `~/Videos`, mang tên `screenrecording-2026-08-13_14-22-05.mp4`. Đặt `OMARCHY_SCREENRECORD_DIR` để thay đổi điều đó — nhưng lưu ý rằng không giống thư mục ảnh chụp màn hình, thư mục này phải tồn tại sẵn, nếu không việc quay sẽ từ chối bắt đầu.

Trong khi bạn đang quay, một chỉ báo nhỏ xuất hiện trên thanh. Nhấp vào nó để dừng. Bạn cũng có thể dừng bằng `Alt + Print Screen` lần nữa, hoặc bằng mục _Stop Screenrecording_ trong _Trigger > Capture > Screenrecord_, mục này chỉ xuất hiện trong khi thực sự có thứ gì đó đang quay.

Việc dừng sẽ làm một chút dọn dẹp trước khi trao cho bạn tệp: khung hình đầu tiên được cắt bỏ, và nếu có âm thanh, nó được chuẩn hóa về -14 LUFS với tiếng bật của PipeWire capture ở ngay đầu được tắt tiếng. Sau đó một thông báo xuất hiện với một hình thu nhỏ từ bản quay. Nhấp vào nó để phát tệp trong mpv.

### Lớp phủ webcam

Khi bạn quay với một webcam, camera xuất hiện dưới dạng một cửa sổ chân dung được ghim, đã cắt xén ở góc dưới-phải của bất cứ thứ gì bạn đang quay. Nếu nó nằm trên thứ gì đó bạn cần, hãy thay đổi kích thước nó ngay lúc đó:

| Phím tắt | Chức năng |
| ------ | -------- |
| `Super + Alt + [` | Làm lớp phủ webcam nhỏ hơn |
| `Super + Alt + ]` | Làm lớp phủ webcam lớn hơn |

Có ba kích thước — nhỏ, vừa và lớn — và các phím tắt bước giữa chúng. Vừa là mặc định. Chúng tỷ lệ với bản quay, vì vậy camera chiếm cùng một tỷ lệ khung hình dù bạn đang quay một màn hình 1080p hay một màn hình 6K. Và nếu bạn đã quay một vùng thay vì toàn bộ màn hình hiển thị, lớp phủ neo vào góc của vùng đó thay vì của màn hình, vì vậy nó ở lại bên trong ảnh chụp.

Bạn cũng có thể gọi nó trực tiếp bằng `omarchy-capture-webcam-resize small`, hoặc `reset` để quay lại kích thước vừa.

## Văn bản, mã QR và màu sắc

`Super + Ctrl + Print Screen` chọn một vùng và OCR nó vào clipboard. Điều đó được trình bày đúng mức trong [Trích xuất văn bản & Đọc chính tả](11-text-extraction-dictation.md).

_Trigger > Capture > QR Code_ làm cùng trò đó với mã QR. Chọn vùng có mã trong đó, và giá trị đã giải mã đi vào clipboard. Nó chỉ tìm mã QR — nội dung màn hình dày đặc có thói quen bị dương tính giả thành một barcode trong các trường hợp khác. Đáng biết: giá trị đã giải mã đi vào clipboard và không đi nơi nào khác. Nó không được in ra, nó không nằm trong thông báo, và nó được đánh dấu là nhạy cảm vì vậy nó không ở lại trong [lịch sử clipboard](08-unified-clipboard-history.md). Mã QR thường xuyên mang theo bí mật — URI `otpauth://` phía sau một mã thiết lập 2FA, chẳng hạn — và bạn không muốn thứ đó nằm trong một log. Dán vẫn hoạt động tốt.

`Super + Print Screen` (hoặc _Trigger > Capture > Color_) biến con trỏ thành một ống nhỏ giọt. Nhấp vào bất cứ thứ gì trên màn hình và màu sắc nằm trên clipboard. Nhấn phím tắt lần nữa để thoát ra mà không chọn.

## Chuyển mã trước khi bạn chia sẻ

Một bản quay màn hình 4K hoặc một HEIC thô từ điện thoại của bạn thường quá lớn để cứ thế gửi đi. `Super + Ctrl + .` (hoặc _Trigger > Transcode_) sửa điều đó. Nó cung cấp cho bạn một bộ chọn tệp fuzzy trên `~/Pictures` và `~/Videos`, sau đó hỏi về một định dạng và một kích thước.

Ảnh đi tới jpg hoặc png ở mức cao, vừa, hoặc thấp, các mức này giới hạn chiều rộng ở 3160, 2160, và 1080 pixels. Video đi tới mp4 hoặc một gif động ở 4k, 1080p, hoặc 720p. Tệp đã chuyển đổi được viết bên cạnh tệp gốc với độ phân giải trong tên — `demo-1080p.mp4` — và đường dẫn được sao chép vào clipboard dưới dạng một file URI, vì vậy bạn có thể dán nó trực tiếp vào một ứng dụng nhận thả tệp.

Nó cũng hoạt động từ terminal, nếu bạn đã biết mình muốn gì: `omarchy transcode ~/Videos/demo.mov mp4 1080p`. Còn có `omarchy transcode ascii`, lệnh này biến một hình ảnh thành ASCII art — cái đó chủ yếu dành cho [thương hiệu](41-branding.md).

## Gửi nó đi đâu đó

Khi bạn đã có tệp, `Super + Ctrl + S` mở menu Share và gửi nó tới một thiết bị khác trên mạng của bạn qua LocalSend. Xem [GUIs](22-guis.md) về việc đó.
