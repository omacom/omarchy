# Ảnh chụp màn hình & Quay màn hình

Mọi thứ bạn có thể lấy từ màn hình đều gắn với phím Print Screen. Chỉ riêng phím đó là chụp một bức ảnh, còn các phím bổ trợ sẽ quay màn hình, lấy một màu, hoặc lấy văn bản bên trong một vùng. Nếu bàn phím của bạn hoàn toàn không có phím Print Screen, `Super + Ctrl + Alt + C` sẽ chụp ảnh màn hình tương tự, và `Super + Ctrl + C` sẽ mở toàn bộ bộ công cụ này dưới dạng một menu.

| Phím tắt | Chức năng |
| ------ | -------- |
| `Print Screen` | Ảnh chụp màn hình |
| `Super + Ctrl + Alt + C` | Ảnh chụp màn hình |
| `Alt + Print Screen` | Quay màn hình (hoặc dừng bản quay đang chạy) |
| `Super + Print Screen` | Bộ chọn màu |
| `Super + Ctrl + Print Screen` | Trích xuất văn bản từ một vùng |
| `Super + Ctrl + C` | Menu Capture |
| `Super + Ctrl + .` | Chuyển mã một ảnh hoặc video |

## Ảnh chụp màn hình

Nhấn `Print Screen` (hoặc `Super + Ctrl + Alt + C`) và Omasnap sẽ chụp màn hình đang được focus trước khi lớp phủ của nó xuất hiện, nên không có gì dịch chuyển dưới con trỏ trong lúc bạn ngắm. Kéo một vùng tự do, nhấp vào một cửa sổ để chụp cửa sổ đó, hoặc nhấp vào khoảng trống để chụp toàn bộ màn hình. Nhấn `S` trước khi vẽ để chụp một vùng cuộn. Đổi ý à? Nhấn lại cùng phím đó để đóng Omasnap.

Sau khi bạn chọn một khu vực, Omasnap sẽ lưu ảnh chụp, sao chép nó vào clipboard, và hiển thị một thông báo kèm hình thu nhỏ của nó, giống như một bản quay màn hình đã lưu. Chọn Open để xem ảnh đã chụp trong trình xem ảnh của bạn, hoặc Edit để chú thích nó.

Trình chỉnh sửa chú thích có thể vẽ mũi tên, đường thẳng, hình dạng, vùng làm nổi bật, dấu đánh số, văn bản, và vùng che an toàn; cắt hoặc khoét bỏ một phần của ảnh; OCR văn bản trong ảnh; và thêm một lớp nền. Trong trình chỉnh sửa, nhấn `Enter` để sao chép và lưu PNG hoàn chỉnh, `Ctrl + C` để sao chép mà không lưu, hoặc `Ctrl + S` để lưu mà không sao chép.

Theo mặc định, ảnh chụp màn hình đã lưu sẽ nằm trong `~/Pictures/Screenshots`, với một tên như `screenshot-2026-08-13_14-22-05-firefox.png`. Đặt `OMASNAP_SCREENSHOT_DIR` để dùng một thư mục khác — xem [FAQ](46-faq.md) để biết nên đặt các biến môi trường của phiên ở đâu. Omasnap sẽ tạo thư mục khi lưu ảnh đầu tiên. Đặt `[output] autosave = false` trong `~/.config/omasnap/omasnap.conf` để tắt tính năng lưu tự động; khi đó ảnh chụp sẽ chỉ được sao chép, và được hiển thị trong một bản xem trước trong 10 giây mà bạn có thể giữ trên màn hình bằng nút ghim của nó hoặc `Ctrl + P`.

Từ terminal, `omarchy screenshot` mở cùng một lớp phủ, và bạn có thể chọn chế độ bắt đầu của nó: `omarchy capture screenshot region`, `windows`, `fullscreen`, hoặc `scroll`. Một đối số thứ hai là `copy` hoặc `save` sẽ gửi ảnh chụp thẳng tới đích đó. Để chỉnh sửa trước khi xuất, dùng `omarchy screenshot --editor=overlay` cho trình chỉnh sửa toàn màn hình hoặc `omarchy screenshot --editor=window` cho một cửa sổ riêng.

### Điều khiển bộ chọn bằng bàn phím

Khi vùng chọn đang mở, bạn không cần dùng chuột chút nào:

| Phím | Chức năng |
| --- | -------- |
| `S` | Bật/tắt chế độ vùng cuộn |
| `Super + Arrow keys` | Di chuyển giữa các cửa sổ trong chế độ Window |
| `Return` | Chụp cửa sổ đang được làm nổi bật |
| `Ctrl + A` | Chụp toàn bộ màn hình đang được focus |
| `R` | Khôi phục vùng cuối cùng đã vẽ trong phiên này |
| `Esc` | Đóng Omasnap |

Các phím này chỉ tồn tại khi Omasnap đang mở, nên chúng không thể xung đột với bất cứ thứ gì trong cấu hình của riêng bạn.

## Quay màn hình

`Alt + Print Screen` mở _Trigger > Capture > Screenrecord_, nơi sẽ hỏi bạn muốn gì trong phần âm thanh: không có âm thanh, âm thanh desktop, desktop kèm microphone, hoặc desktop kèm microphone kèm webcam. Lựa chọn cuối cùng đó chỉ xuất hiện nếu bạn thực sự đang cắm một camera. Chọn một lựa chọn và bộ chọn quay của Omarchy sẽ cho bạn kéo một vùng hoặc nhấp vào một cửa sổ hay màn hình.

Việc quay chạy trên gpu-screen-recorder, phần mềm mã hóa trên GPU ở 60fps và chuyển về CPU nếu buộc phải làm vậy. Kết quả là một MP4 trong `~/Videos`, có tên là `screenrecording-2026-08-13_14-22-05.mp4`. Đặt `OMARCHY_SCREENRECORD_DIR` để thay đổi điều đó — nhưng lưu ý rằng không giống thư mục ảnh chụp màn hình, thư mục này phải tồn tại sẵn, nếu không bản quay sẽ từ chối bắt đầu.

Trong lúc bạn đang quay, một chỉ báo nhỏ sẽ xuất hiện trên thanh. Nhấp vào nó để dừng. Bạn cũng có thể dừng bằng cách nhấn lại `Alt + Print Screen`, hoặc bằng mục _Stop Screenrecording_ dưới _Trigger > Capture > Screenrecord_, mục này chỉ xuất hiện khi thực sự đang có thứ gì đó được quay.

Việc dừng sẽ dọn dẹp một chút trước khi giao file cho bạn: khung hình đầu tiên được cắt bỏ, và nếu có âm thanh, nó sẽ được chuẩn hóa về -14 LUFS với tiếng bụp khi bắt đầu capture của PipeWire ở ngay đầu bị tắt tiếng. Sau đó một thông báo sẽ xuất hiện kèm một hình thu nhỏ từ bản quay. Nhấp vào nó để phát file trong Omaview.

### Lớp phủ webcam

Khi bạn quay bằng webcam, camera sẽ xuất hiện dưới dạng một cửa sổ dọc được ghim, đã cắt, ở góc dưới-phải của bất cứ thứ gì bạn đang quay. Nếu nó đang nằm trên thứ bạn cần, hãy thay đổi kích thước ngay trong lúc quay:

| Phím tắt | Chức năng |
| ------ | -------- |
| `Super + Alt + [` | Thu nhỏ lớp phủ webcam |
| `Super + Alt + ]` | Phóng to lớp phủ webcam |

Có ba kích thước — nhỏ, vừa, và lớn — và các phím tắt sẽ chuyển từng bước giữa chúng. Vừa là mặc định. Chúng tỷ lệ theo bản quay, nên camera chiếm cùng một phần khung hình dù bạn đang quay một màn hình 1080p hay một màn hình 6K. Và nếu bạn đã quay một vùng thay vì toàn bộ màn hình, lớp phủ sẽ neo vào góc của vùng đó thay vì góc của màn hình, nên nó luôn nằm trong khung hình.

Bạn cũng có thể gọi nó trực tiếp bằng `omarchy-capture-webcam-resize small`, hoặc `reset` để quay về kích thước vừa.

## Văn bản, mã QR, và màu sắc

`Super + Ctrl + Print Screen` chọn một vùng và OCR nó vào clipboard. Việc đó được trình bày đầy đủ trong [Trích xuất văn bản & Đọc chính tả](11-text-extraction-dictation.md).

_Trigger > Capture > QR Code_ cũng làm chiêu tương tự với mã QR. Chọn vùng có mã trong đó, và giá trị đã giải mã sẽ đi vào clipboard. Nó chỉ tìm mã QR — nếu không, nội dung màn hình dày đặc rất hay bị nhận nhầm là barcode. Điều đáng biết: giá trị đã giải mã đi vào clipboard và không đi đâu khác. Nó không được in ra, nó không nằm trong thông báo, và nó được đánh dấu là nhạy cảm để không lưu lại trong [lịch sử clipboard](08-unified-clipboard-history.md). Mã QR thường xuyên mang theo bí mật — URI `otpauth://` đằng sau một mã thiết lập 2FA, chẳng hạn — và bạn không muốn thứ đó nằm trong log. Việc dán vẫn hoạt động bình thường.

`Super + Print Screen` (hoặc _Trigger > Capture > Color_) biến con trỏ thành một ống hút màu. Nhấp vào bất cứ thứ gì trên màn hình và màu sẽ nằm trong clipboard. Nhấn lại phím tắt để thoát ra mà không chọn.

## Chuyển mã trước khi chia sẻ

Một bản quay màn hình 4K hoặc một ảnh HEIC thô từ điện thoại của bạn thường quá lớn để cứ thế gửi đi. `Super + Ctrl + .` (hoặc _Trigger > Transcode_) sẽ xử lý việc đó. Nó cho bạn một bộ chọn file dạng fuzzy trên `~/Pictures` và `~/Videos`, rồi hỏi về định dạng và kích thước.

Ảnh sẽ thành jpg hoặc png ở mức cao, vừa, hoặc thấp, giới hạn chiều rộng lần lượt ở 3160, 2160, và 1080 pixel. Video sẽ thành mp4 hoặc gif động ở 4k, 1080p, hoặc 720p. File đã chuyển đổi được ghi bên cạnh file gốc với độ phân giải trong tên — `demo-1080p.mp4` — và đường dẫn được sao chép vào clipboard dưới dạng file URI, nên bạn có thể dán nó trực tiếp vào một ứng dụng nhận thả file.

Nó cũng hoạt động từ terminal, nếu bạn đã biết mình muốn gì: `omarchy transcode ~/Videos/demo.mov mp4 1080p`. Còn có `omarchy transcode ascii`, chuyển một ảnh thành ASCII art — cái đó chủ yếu dành cho [thương hiệu](41-branding.md).

## Gửi nó đi đâu đó

Khi đã có file, `Super + Ctrl + S` mở menu Share và gửi nó tới một thiết bị khác trong mạng của bạn qua LocalSend. Xem [GUIs](22-guis.md) về việc đó.
