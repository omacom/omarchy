# Ảnh chụp màn hình & Quay màn hình

Mọi thứ bạn có thể lấy từ màn hình đều gắn với phím Print Screen. Chỉ một phím đó thôi là chụp một bức ảnh, còn các phím bổ trợ sẽ quay màn hình, lấy một màu, hoặc lấy văn bản bên trong một vùng. Nếu bàn phím của bạn hoàn toàn không có phím Print Screen, `Super + Ctrl + Alt + C` sẽ chụp cùng một ảnh chụp màn hình đó, còn `Super + Ctrl + C` sẽ mở toàn bộ bộ tính năng dưới dạng một menu.

| Phím tắt | Chức năng |
| ------ | -------- |
| `Print Screen` | Chụp màn hình |
| `Super + Ctrl + Alt + C` | Chụp màn hình |
| `Alt + Print Screen` | Quay màn hình (hoặc dừng bản quay đang chạy) |
| `Super + Print Screen` | Bộ chọn màu |
| `Super + Ctrl + Print Screen` | Trích xuất văn bản từ một vùng |
| `Super + Ctrl + C` | Menu chụp |
| `Super + Ctrl + .` | Chuyển mã một bức ảnh hoặc video |

## Ảnh chụp màn hình

Nhấn `Print Screen` (hoặc `Super + Ctrl + Alt + C`) và Omasnap chụp màn hình đang được focus trước khi lớp phủ của nó xuất hiện, vì vậy không có gì dịch chuyển dưới bạn trong lúc bạn ngắm. Kéo một vùng tự do, nhấp vào một cửa sổ để chụp nó, hoặc nhấp vào khoảng trống để chụp toàn bộ màn hình. Nhấn `S` trước khi vẽ để chụp một vùng cuộn. Đổi ý à? Nhấn lại cùng phím đó để đóng Omasnap.

Sau khi bạn chọn một vùng, Omasnap lưu ảnh chụp, sao chép nó vào clipboard và hiển thị bản xem trước trong 10 giây. Dùng nút ghim của bản xem trước hoặc `Ctrl + P` để giữ nó trên màn hình, hoặc chọn Edit để chú thích nó.

Trình chỉnh sửa chú thích có thể vẽ mũi tên, đường thẳng, hình dạng, vùng tô sáng, điểm đánh dấu có số, văn bản và vùng che an toàn; cắt hoặc khoét bỏ một phần của hình ảnh; OCR văn bản của nó; và thêm một phông nền. Trong trình chỉnh sửa, nhấn `Enter` để sao chép và lưu PNG đã hoàn thiện, `Ctrl + C` để sao chép mà không lưu, hoặc `Ctrl + S` để lưu mà không sao chép.

Ảnh chụp màn hình đã lưu mặc định nằm trong `~/Pictures/Screenshots`, với tên như `screenshot-2026-08-13_14-22-05-firefox.png`. Đặt `OMASNAP_SCREENSHOT_DIR` để dùng một thư mục khác — xem [FAQ](46-faq.md) để biết đặt biến môi trường của phiên ở đâu. Omasnap tạo thư mục khi nó lưu ảnh đầu tiên. Đặt `[output] autosave = false` trong `~/.config/omasnap/omasnap.conf` để tắt tính năng lưu tự động.

Từ terminal, `omarchy screenshot` mở cùng lớp phủ đó, và bạn có thể chọn chế độ bắt đầu của nó: `omarchy capture screenshot region`, `windows`, `fullscreen`, hoặc `scroll`. Một đối số thứ hai là `copy` hoặc `save` sẽ bỏ qua bản xem trước và gửi ảnh thẳng tới đích đó. Để chỉnh sửa trước khi xuất, dùng `omarchy screenshot --editor=overlay` cho trình chỉnh sửa toàn màn hình hoặc `omarchy screenshot --editor=window` cho một cửa sổ riêng.

### Điều khiển bộ chọn bằng bàn phím

Khi vùng chọn đang hiển thị, bạn hoàn toàn không cần dùng chuột:

| Phím | Chức năng |
| --- | -------- |
| `S` | Bật/tắt chế độ vùng cuộn |
| `Super + Arrow keys` | Di chuyển giữa các cửa sổ trong chế độ Window |
| `Return` | Chụp cửa sổ đang được tô sáng |
| `Ctrl + A` | Chụp toàn bộ màn hình đang được focus |
| `R` | Khôi phục vùng cuối cùng đã vẽ trong phiên này |
| `Esc` | Đóng Omasnap |

Các ràng buộc phím này chỉ tồn tại khi Omasnap đang mở, vì vậy chúng không thể xung đột với bất cứ thứ gì trong cấu hình của riêng bạn.

## Quay màn hình

`Alt + Print Screen` mở _Trigger > Capture > Screenrecord_, mục này hỏi bạn muốn gì trong bản âm thanh: không có âm thanh, âm thanh của desktop, desktop cộng với microphone, hoặc desktop cộng với microphone cộng với webcam. Lựa chọn cuối cùng đó chỉ xuất hiện nếu bạn thực sự có một camera được cắm vào. Chọn một lựa chọn và bộ chọn ghi hình của Omarchy cho phép bạn kéo một vùng hoặc nhấp vào một cửa sổ hoặc màn hình.

Việc ghi hình chạy trên gpu-screen-recorder, công cụ này mã hóa trên GPU ở 60fps và quay lại dùng CPU nếu buộc phải làm vậy. Kết quả là một MP4 trong `~/Videos`, có tên `screenrecording-2026-08-13_14-22-05.mp4`. Đặt `OMARCHY_SCREENRECORD_DIR` để thay đổi điều đó — nhưng lưu ý rằng không giống thư mục ảnh chụp màn hình, thư mục này phải tồn tại sẵn, nếu không bản ghi sẽ từ chối bắt đầu.

Trong khi bạn đang ghi, một chỉ báo nhỏ xuất hiện trên thanh. Nhấp vào nó để dừng. Bạn cũng có thể dừng bằng `Alt + Print Screen` lần nữa, hoặc bằng mục _Stop Screenrecording_ trong _Trigger > Capture > Screenrecord_, mục này chỉ xuất hiện khi thực sự có thứ gì đó đang ghi.

Việc dừng sẽ làm một chút dọn dẹp trước khi trao file cho bạn: khung hình đầu tiên được cắt bỏ, và nếu có âm thanh, nó được chuẩn hóa tới -14 LUFS với tiếng bụp khi thu PipeWire ở ngay đầu được tắt tiếng. Sau đó một thông báo xuất hiện với một hình thu nhỏ từ bản ghi. Nhấp vào nó để phát file trong mpv.

### Lớp phủ webcam

Khi bạn ghi cùng webcam, camera xuất hiện dưới dạng một cửa sổ chân dung đã ghim, đã cắt ở góc dưới-phải của bất cứ thứ gì bạn đang ghi. Nếu nó đang nằm trên thứ bạn cần, hãy thay đổi kích thước nó ngay lập tức:

| Phím tắt | Chức năng |
| ------ | -------- |
| `Super + Alt + [` | Làm lớp phủ webcam nhỏ hơn |
| `Super + Alt + ]` | Làm lớp phủ webcam lớn hơn |

Có ba kích cỡ — nhỏ, vừa và lớn — và các phím tắt bước giữa chúng. Vừa là mặc định. Chúng tỉ lệ với bản ghi, vì vậy camera chiếm cùng một phần của khung hình dù bạn đang ghi một màn hình 1080p hay một màn hình 6K. Và nếu bạn đã ghi một vùng thay vì toàn bộ màn hình, lớp phủ neo vào góc của vùng đó thay vì góc của màn hình, vì vậy nó ở lại bên trong ảnh.

Bạn cũng có thể gọi nó trực tiếp bằng `omarchy-capture-webcam-resize small`, hoặc `reset` để quay lại kích cỡ vừa.

## Văn bản, mã QR và màu sắc

`Super + Ctrl + Print Screen` chọn một vùng và OCR nó vào clipboard. Điều đó được trình bày đầy đủ trong [Trích xuất văn bản & Đọc chính tả](11-text-extraction-dictation.md).

_Trigger > Capture > QR Code_ làm cùng thủ thuật đó cho mã QR. Chọn vùng có mã trong đó, và giá trị đã giải mã sẽ vào clipboard. Nó chỉ tìm mã QR — nội dung màn hình dày đặc có thói quen dương tính giả thành barcode trong các trường hợp khác. Điều đáng biết: giá trị đã giải mã đi vào clipboard và không đi đâu khác. Nó không được in ra, nó không có trong thông báo, và nó được đánh dấu là nhạy cảm để nó không ở lại trong [lịch sử clipboard](08-unified-clipboard-history.md). Mã QR thường xuyên mang theo bí mật — URI `otpauth://` đằng sau một mã thiết lập 2FA, chẳng hạn — và bạn không muốn thứ đó trong một log. Việc dán vẫn hoạt động tốt.

`Super + Print Screen` (hoặc _Trigger > Capture > Color_) biến con trỏ thành một ống nhỏ giọt. Nhấp vào bất cứ thứ gì trên màn hình và màu sẽ nằm trên clipboard. Nhấn lại phím tắt để thoát ra mà không chọn.

## Chuyển mã trước khi bạn chia sẻ

Một bản ghi màn hình 4K hoặc một HEIC thô từ điện thoại của bạn thường quá lớn để cứ thế gửi đi. `Super + Ctrl + .` (hoặc _Trigger > Transcode_) sửa điều đó. Nó cung cấp cho bạn một trình chọn file dạng tìm kiếm mờ trên `~/Pictures` và `~/Videos`, rồi hỏi về định dạng và kích cỡ.

Ảnh đi tới jpg hoặc png ở mức cao, trung bình, hoặc thấp, các mức này giới hạn chiều rộng ở 3160, 2160, và 1080 pixel. Video đi tới mp4 hoặc một gif động ở 4k, 1080p, hoặc 720p. File đã chuyển đổi được ghi bên cạnh file gốc với độ phân giải trong tên — `demo-1080p.mp4` — và đường dẫn được sao chép vào clipboard dưới dạng URI file, vì vậy bạn có thể dán nó trực tiếp vào một ứng dụng nhận thả file.

Nó cũng hoạt động từ terminal, nếu bạn đã biết bạn muốn gì: `omarchy transcode ~/Videos/demo.mov mp4 1080p`. Cũng có `omarchy transcode ascii`, lệnh này biến một hình ảnh thành ASCII art — lệnh đó chủ yếu dành cho [thương hiệu](41-branding.md).

## Gửi nó tới đâu đó

Khi bạn đã có file, `Super + Ctrl + S` mở menu Share và gửi nó tới một thiết bị khác trên mạng của bạn qua LocalSend. Xem [GUIs](22-guis.md) cho việc đó.
