# Ảnh chụp màn hình & Quay màn hình

Mọi thứ bạn có thể lấy ra khỏi màn hình đều gắn với phím Print Screen. Chỉ phím đó thôi là chụp ảnh, còn các phím bổ trợ thì quay màn hình, lấy một màu, hoặc lấy văn bản bên trong một vùng. Nếu bàn phím của bạn không hề có phím Print Screen, `Super + Ctrl + Alt + C` chụp cùng một ảnh chụp màn hình đó, và `Super + Ctrl + C` mở toàn bộ bộ tính năng dưới dạng một menu.

| Phím tắt | Chức năng |
| ------ | -------- |
| `Print Screen` | Ảnh chụp màn hình |
| `Super + Ctrl + Alt + C` | Ảnh chụp màn hình |
| `Alt + Print Screen` | Quay màn hình (hoặc dừng bản đang quay) |
| `Super + Print Screen` | Bộ chọn màu |
| `Super + Ctrl + Print Screen` | Trích xuất văn bản từ một vùng |
| `Super + Ctrl + C` | Menu chụp |
| `Super + Ctrl + .` | Chuyển mã một ảnh hoặc video |

## Ảnh chụp màn hình

Nhấn `Print Screen` (hoặc `Super + Ctrl + Alt + C`) và Omasnap chụp màn hình đang được focus trước khi lớp phủ của nó xuất hiện, để không có gì xê dịch bên dưới bạn trong lúc bạn ngắm. Kéo một vùng tự do, nhấp vào một cửa sổ để chụp nó, hoặc nhấp vào khoảng trống để chụp toàn bộ màn hình. Nhấn `S` trước khi vẽ để chụp một vùng cuộn. Đổi ý à? Nhấn lại phím đó để đóng Omasnap.

Sau khi bạn chọn một khu vực, Omasnap lưu ảnh chụp, sao chép nó vào clipboard, và hiển thị một thông báo kèm ảnh thu nhỏ của nó, giống như một bản quay màn hình đã lưu vẫn làm. Chọn Open để xem ảnh đã lưu trong trình xem ảnh của bạn, hoặc Edit để chú thích lên nó.

Trình soạn thảo chú thích có thể vẽ mũi tên, đường thẳng, hình dạng, vùng tô sáng, điểm đánh dấu có số, văn bản, và vùng che kín an toàn; cắt xén hoặc cắt bỏ một phần của ảnh; OCR văn bản trong đó; và thêm một nền phía sau. Trong trình soạn thảo, nhấn `Enter` để sao chép và lưu PNG đã hoàn thiện, `Ctrl + C` để sao chép nó mà không lưu, hoặc `Ctrl + S` để lưu nó mà không sao chép.

Ảnh chụp màn hình đã lưu mặc định nằm trong `~/Pictures/Screenshots`, với một tên như `screenshot-2026-08-13_14-22-05-firefox.png`. Đặt `OMASNAP_SCREENSHOT_DIR` để dùng một thư mục khác — xem [Câu hỏi thường gặp](46-faq.md) để biết nên đặt các biến môi trường của session ở đâu. Omasnap tạo thư mục khi nó lưu ảnh đầu tiên. Đặt `[output] autosave = false` trong `~/.config/omasnap/omasnap.conf` để tắt lưu tự động; các ảnh chụp khi đó chỉ được sao chép, và được hiển thị trong một bản xem trước trong 7 giây mà bạn có thể giữ trên màn hình bằng nút ghim của nó hoặc `Ctrl + P`.

Từ terminal, `omarchy screenshot` mở cùng một lớp phủ đó, và bạn có thể chọn chế độ khởi đầu của nó: `omarchy capture screenshot region`, `windows`, `fullscreen`, hoặc `scroll`. Đối số thứ hai là `copy` hoặc `save` sẽ gửi ảnh thẳng đến đích đó. Để chỉnh sửa trước khi xuất ra, dùng `omarchy screenshot --editor=overlay` cho một trình soạn thảo toàn màn hình hoặc `omarchy screenshot --editor=window` cho một cửa sổ riêng.

### Điều khiển trình chọn bằng bàn phím

Trong khi vùng chọn đang mở, bạn hoàn toàn không cần dùng đến chuột:

| Phím | Chức năng |
| --- | -------- |
| `S` | Bật/tắt chế độ vùng cuộn |
| `Super + Arrow keys` | Di chuyển giữa các cửa sổ ở chế độ Window |
| `Return` | Chụp cửa sổ đang được tô sáng |
| `Ctrl + A` | Chụp toàn bộ màn hình đang được focus |
| `R` | Khôi phục vùng cuối cùng đã vẽ trong session này |
| `Esc` | Đóng Omasnap |

Các phím gán này chỉ tồn tại trong khi Omasnap đang mở, nên chúng không thể xung đột với bất cứ thứ gì trong config của bạn.

## Quay màn hình

`Alt + Print Screen` mở _Trigger > Capture > Screenrecord_, mục này hỏi bạn muốn gì trên soundtrack: không có âm thanh, âm thanh desktop, desktop cộng với microphone, hoặc desktop cộng với microphone cộng với webcam. Tùy chọn cuối cùng đó chỉ hiện ra nếu bạn thực sự có cắm một camera. Chọn một tùy chọn và trình chọn quay của Omarchy cho phép bạn kéo một vùng hoặc nhấp vào một cửa sổ hoặc màn hình.

Việc quay chạy trên gpu-screen-recorder, mã hóa trên GPU ở 60fps và lùi về CPU nếu buộc phải vậy; trên các GPU mà nó không hỗ trợ, chẳng hạn như của Apple Silicon, Omarchy thay vào đó quay bằng wf-recorder. Kết quả là một MP4 trong `~/Videos`, có tên `screenrecording-2026-08-13_14-22-05.mp4`. Đặt `OMARCHY_SCREENRECORD_DIR` để thay đổi điều đó — nhưng lưu ý rằng không như thư mục ảnh chụp màn hình, thư mục này phải tồn tại sẵn, nếu không việc quay sẽ từ chối bắt đầu.

Trong khi bạn đang quay, một chỉ báo nhỏ xuất hiện trên thanh. Nhấp vào nó để dừng. Bạn cũng có thể dừng bằng `Alt + Print Screen` lần nữa, hoặc bằng mục _Stop Screenrecording_ dưới _Trigger > Capture > Screenrecord_, mục này chỉ xuất hiện trong khi thực sự có thứ gì đó đang được quay.

Việc dừng sẽ dọn dẹp một chút trước khi trao file cho bạn: khung hình đầu tiên được cắt bỏ, và nếu có âm thanh thì nó được chuẩn hóa về -14 LUFS với tiếng bụp khi bắt đầu capture của PipeWire ở ngay đầu được làm im đi. Sau đó một thông báo xuất hiện kèm một ảnh thu nhỏ từ bản quay. Chọn _Open_ để phát file trong Omaview, hoặc _Cut_ để cắt nó trong Omacut.

### Lớp phủ webcam

Khi bạn quay kèm webcam, camera xuất hiện dưới dạng một cửa sổ chân dung đã được ghim, đã được cắt xén ở góc dưới-phải của bất cứ thứ gì bạn đang quay. Nếu nó đang nằm đè lên thứ bạn cần, hãy thay đổi kích thước của nó ngay tức thì:

| Phím tắt | Chức năng |
| ------ | -------- |
| `Super + Alt + [` | Làm lớp phủ webcam nhỏ hơn |
| `Super + Alt + ]` | Làm lớp phủ webcam lớn hơn |

Có ba kích thước — nhỏ, vừa, và lớn — và các phím tắt bước qua lại giữa chúng. Vừa là mặc định. Chúng tỷ lệ với bản quay, nên camera chiếm cùng một phần của khung hình cho dù bạn đang quay một màn hình 1080p hay một màn hình 6K. Và nếu bạn đã quay một vùng thay vì toàn bộ màn hình, lớp phủ neo vào góc của vùng đó thay vì của màn hình, nên nó nằm gọn bên trong ảnh chụp.

Bạn cũng có thể gọi nó trực tiếp bằng `omarchy-capture-webcam-resize small`, hoặc `reset` để quay về mức vừa.

## Văn bản, mã QR và màu sắc

`Super + Ctrl + Print Screen` chọn một vùng và OCR nó vào clipboard. Điều đó được trình bày đầy đủ trong [Trích xuất văn bản & Đọc chính tả](11-text-extraction-dictation.md).

_Trigger > Capture > QR Code_ làm cùng một trò đó cho các mã QR. Chọn vùng có mã trong đó, và giá trị đã giải mã sẽ đi vào clipboard. Nó chỉ tìm các mã QR — nội dung màn hình dày đặc có thói quen bị dương tính giả thành barcode nếu không vậy. Điều đáng biết: giá trị đã giải mã đi vào clipboard và không đi đến nơi nào khác. Nó không được in ra, nó không nằm trong thông báo, và nó được đánh dấu là nhạy cảm để nó không lưu lại trong [lịch sử clipboard](08-unified-clipboard-history.md). Mã QR thường xuyên mang theo các bí mật — URI `otpauth://` đằng sau một mã thiết lập 2FA, chẳng hạn — và bạn không muốn thứ đó nằm trong một log. Việc dán vẫn hoạt động tốt.

`Super + Print Screen` (hoặc _Trigger > Capture > Color_) biến con trỏ thành một ống nhỏ giọt. Nhấp vào bất cứ thứ gì trên màn hình và màu sắc sẽ nằm trong clipboard. Nhấn lại phím tắt để thoát ra mà không chọn.

## Chuyển mã trước khi bạn chia sẻ

Một bản quay màn hình 4K hoặc một HEIC thô lấy từ điện thoại của bạn thường quá lớn để cứ thế mà gửi đi. `Super + Ctrl + .` (hoặc _Trigger > Transcode_) sửa điều đó. Nó cho bạn một bộ chọn file mờ trên `~/Pictures` và `~/Videos`, rồi hỏi về định dạng và kích thước.

Ảnh đi đến jpg hoặc png ở mức cao, trung bình, hoặc thấp, giới hạn chiều rộng ở 3160, 2160, và 1080 pixels. Video đi đến mp4 hoặc một gif động ở 4k, 1080p, hoặc 720p. File đã chuyển đổi được ghi ngay cạnh bản gốc với độ phân giải trong tên — `demo-1080p.mp4` — và đường dẫn được sao chép vào clipboard dưới dạng một file URI, để bạn có thể dán nó trực tiếp vào một app nhận các lần thả file.

Nó cũng hoạt động từ terminal, nếu bạn đã biết mình muốn gì: `omarchy transcode ~/Videos/demo.mov mp4 1080p`. Còn có `omarchy transcode ascii`, biến một ảnh thành ASCII art — cái đó chủ yếu dành cho [thương hiệu](41-branding.md).

## Gửi nó đi nơi khác

Một khi bạn đã có file, `Super + Ctrl + S` mở menu Share và gửi nó đến một thiết bị khác trên mạng của bạn qua LocalSend. Xem [GUIs](22-guis.md) về điều đó.
