# Trích xuất văn bản & Đọc chính tả

### Trích xuất văn bản

Nhấn `Super + Ctrl + PrtScr` để chọn một vùng trên màn hình nhằm trích xuất văn bản. Mô hình OCR mã nguồn mở tesseract sau đó sẽ nhanh chóng chuyển đổi vùng chọn đó thành văn bản và đặt nó trên bảng nhớ tạm. Sau đó bạn chỉ cần nhấn `Super + V` để dán.

Điều này rất hữu ích để lấy địa chỉ ra khỏi chân trang hình ảnh hoặc số điện thoại nhúng trong tiêu đề trang web.

 ![text-extraction](images/text-extraction.webp)

### Đọc chính tả

Trên các cài đặt mới, [Superwhisper](https://superwhisper.com/) là chương trình phụ trợ đọc chính tả mặc định, sử dụng xử lý đám mây mà không cần tải xuống mô hình ngoại tuyến. Chọn Superwhisper hoặc [Voxtype](https://voxtype.io/) qua _Thiết lập > Mặc định > Đọc chính tả_ trong menu Omarchy. Chọn một chương trình phụ trợ sẽ cài đặt nó nếu cần và biến nó thành mặc định cho việc đọc chính tả. Voxtype tải một mô hình tiếng Anh cơ sở chiếm 150MB; thay đổi mô hình bằng `voxtype setup model` và các cài đặt khác qua `~/.config/voxtype/config.toml`. Superwhisper mở cài đặt của nó để chọn xử lý đám mây hoặc cục bộ, và OPR giữ ứng dụng được cập nhật.

Bạn đọc chính tả bằng cách giữ `Right Alt` hoặc `F9`, hoặc bằng cách bật/tắt với `Super + Ctrl + X`, và văn bản đã đọc sẽ xuất hiện trong vùng nhập đang được tập trung. Các phím tắt này dùng chương trình phụ trợ đã chọn. Right Alt cũng bắt đầu đọc chính tả khi được dùng trong một tổ hợp phím bổ trợ; dùng Left Alt cho các tổ hợp đó. Trên các bố cục bàn phím nơi Right Alt là AltGr, dùng `F9` để giữ AltGr khả dụng cho việc gõ phím.

Các phím tắt tương tự hoạt động với cả hai chương trình phụ trợ. Chọn chương trình phụ trợ của bạn qua Thiết lập > Mặc định > Đọc chính tả. Trình cài đặt chương trình phụ trợ cấu hình nó và lưu lựa chọn. Chạy `omarchy default dictation` để xem cái nào được chọn. Lựa chọn được lưu trong `~/.config/omarchy/defaults/dictation`. Các cài đặt mới tự động chọn Superwhisper.

Omarchy tự động tải tích hợp desktop của chương trình phụ trợ đã chọn. Không cần cấu hình Superwhisper trong `~/.config/hypr/`.

Các phím gán và tập lệnh tùy chỉnh có thể dùng `omarchy dictation start`, `omarchy dictation stop` và `omarchy dictation toggle`. Chương trình phụ trợ đã chọn xử lý việc ghi âm và phiên âm. Chọn Superwhisper vô hiệu hóa phím tắt giữ gốc của nó và đặt chuyển đổi gốc của nó thành `Alt + Space`, giữ nó tách biệt khỏi các phím ghi âm của Omarchy. Superwhisper yêu cầu ít nhất một phím tắt ghi âm gốc, và phím tắt hủy của nó vẫn khả dụng.

Các chương trình phụ trợ bổ sung có thể tích hợp mà không thay đổi Omarchy. Cung cấp một tệp thực thi có tên `omarchy-dictation-<backend>` trên PATH chấp nhận `start`, `stop` và `toggle` và trả về kịp thời, với trạng thái khác không khi thất bại. Trình cài đặt của nó cấu hình nhà cung cấp và gọi `omarchy-dictation-use <backend>` sau khi thiết lập thành công. Điều này dừng chương trình phụ trợ trước đó và lưu lựa chọn một cách nguyên tử; `stop` phải thành công khi nhà cung cấp nhàn rỗi hoặc không khả dụng. Tên chương trình phụ trợ dùng chữ thường, chữ số và dấu gạch ngang. Cung cấp `omarchy-install-dictation-<backend>` cho việc thiết lập; `omarchy default dictation <backend>` khởi chạy nó. Thêm một mục menu Mặc định qua một phần mở rộng menu Omarchy để gọi bộ chọn đó. Tích hợp desktop tùy chọn có thể nằm trong `${XDG_CONFIG_HOME:-$HOME/.config}/<backend>/shortcuts.lua`.
