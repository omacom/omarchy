# Trích xuất văn bản & Đọc chính tả

### Trích xuất văn bản

Nhấn `Super + Ctrl + PrtScr` để chọn một vùng trên màn hình nhằm trích xuất văn bản. Mô hình OCR mã nguồn mở tesseract sau đó sẽ nhanh chóng chuyển vùng đã chọn đó thành văn bản và đặt vào clipboard. Sau đó bạn chỉ cần nhấn `Super + V` để dán.

Điều này rất hữu ích để lấy địa chỉ từ chân trang hình ảnh hoặc số điện thoại được nhúng trong tiêu đề trang web.

 ![text-extraction](images/text-extraction.webp)

### Đọc chính tả

Trên các bản cài đặt mới, [Superwhisper](https://superwhisper.com/) là backend đọc chính tả mặc định, sử dụng xử lý trên đám mây mà không cần tải xuống mô hình ngoại tuyến. Chọn Superwhisper hoặc [Voxtype](https://voxtype.io/) thông qua _Setup > Defaults > Dictation_ trong menu Omarchy. Việc chọn một backend sẽ cài đặt nó nếu cần và đặt nó làm mặc định cho đọc chính tả. Voxtype tải một mô hình tiếng Anh cơ bản chiếm 150MB; thay đổi mô hình bằng `voxtype setup model` và các cài đặt khác thông qua `~/.config/voxtype/config.toml`. Superwhisper mở phần cài đặt của nó để chọn xử lý trên đám mây hoặc cục bộ, và OPR giữ cho ứng dụng luôn được cập nhật.

Bạn đọc chính tả bằng cách giữ `Right Alt`, hoặc bằng cách bật/tắt với `Alt + Space`, và văn bản đã đọc sẽ xuất hiện trong vùng nhập đang được chọn. Các phím tắt này sử dụng backend đã chọn. Right Alt cũng bắt đầu đọc chính tả khi được dùng trong một tổ hợp phím bổ trợ; hãy dùng Left Alt cho các tổ hợp đó. Trên các bố cục bàn phím mà Right Alt là AltGr, hãy dùng `Alt + Space` để giữ AltGr sẵn sàng cho việc gõ phím. Các bản cài đặt từ trước khi Alt + Space trở thành mặc định vẫn giữ `F9` cho nhấn để nói và `Super + Ctrl + X` để bật/tắt, được thêm vào `~/.config/hypr/bindings.lua`; hãy xóa chúng tại đó để trả các phím đó lại cho các ứng dụng.

Các phím tắt tương tự hoạt động với cả hai backend. Chọn backend của bạn thông qua Setup > Defaults > Dictation. Trình cài đặt backend sẽ cấu hình nó và lưu lựa chọn. Chạy `omarchy default dictation` để xem backend nào đang được chọn. Lựa chọn được lưu trong `~/.config/omarchy/defaults/dictation`. Các bản cài đặt mới tự động chọn Superwhisper.

Omarchy tự động tải tích hợp desktop của backend đã chọn. Không cần cấu hình Superwhisper nào trong `~/.config/hypr/`.

Các binding tùy chỉnh và script có thể dùng `omarchy dictation start`, `omarchy dictation stop`, và `omarchy dictation toggle`. Backend đã chọn sẽ xử lý việc ghi âm và chuyển thành văn bản. Việc chọn Superwhisper sẽ tắt phím tắt giữ nguyên bản của nó và đặt phím bật/tắt nguyên bản của nó thành `Ctrl + Alt + Space`, giữ nó tách biệt khỏi các phím ghi âm của Omarchy. Superwhisper yêu cầu ít nhất một phím tắt ghi âm nguyên bản, và phím tắt hủy của nó vẫn luôn sẵn sàng.

Các backend bổ sung có thể tích hợp mà không cần thay đổi Omarchy. Cung cấp một tệp thực thi có tên `omarchy-dictation-<backend>` trên PATH, chấp nhận `start`, `stop`, và `toggle` và trả về ngay lập tức, với trạng thái khác không khi thất bại. Trình cài đặt của nó cấu hình nhà cung cấp và gọi `omarchy-dictation-use <backend>` sau khi thiết lập thành công. Điều này dừng backend trước đó và lưu lựa chọn một cách nguyên tử; `stop` phải thành công khi nhà cung cấp đang rảnh hoặc không khả dụng. Tên backend sử dụng chữ cái thường, chữ số, và dấu gạch nối. Cung cấp `omarchy-install-dictation-<backend>` cho việc thiết lập; `omarchy default dictation <backend>` sẽ khởi chạy nó. Thêm một mục menu Defaults thông qua một phần mở rộng menu Omarchy để gọi trình chọn đó. Tích hợp desktop tùy chọn có thể nằm trong `${XDG_CONFIG_HOME:-$HOME/.config}/<backend>/shortcuts.lua`.
