# Trích xuất văn bản & Nhập liệu bằng giọng nói

### Trích xuất văn bản

Nhấn `Super + Ctrl + PrtScr` để chọn một vùng trên màn hình nhằm trích xuất văn bản. Mô hình OCR mã nguồn mở tesseract sau đó sẽ nhanh chóng chuyển vùng đã chọn thành văn bản và đưa vào clipboard. Sau đó bạn chỉ cần nhấn `Super + V` để dán.

Cách này rất hữu ích để lấy địa chỉ từ phần chân trang của hình ảnh hoặc số điện thoại được nhúng trong các tiêu đề của trang web.

 ![text-extraction](images/text-extraction.webp)

### Nhập liệu bằng giọng nói

Trên các bản cài đặt mới, [Superwhisper](https://superwhisper.com/) là backend nhập liệu bằng giọng nói mặc định, sử dụng xử lý trên đám mây mà không cần tải về các mô hình ngoại tuyến. Chọn Superwhisper, [Voxtype](https://voxtype.io/) hoặc [Hex](https://anoma.ly/hex/) thông qua _Setup > Defaults > Dictation_ trong menu Omarchy. Việc chọn một backend sẽ cài đặt nó nếu cần và đặt nó làm mặc định cho nhập liệu bằng giọng nói. Voxtype tải một mô hình tiếng Anh cơ bản chiếm 150MB; thay đổi mô hình bằng `voxtype setup model` và các cài đặt khác thông qua `~/.config/voxtype/config.toml`. Superwhisper mở phần cài đặt của nó để chọn xử lý trên đám mây hoặc cục bộ, và OPR giữ cho ứng dụng luôn được cập nhật. Hex tải mô hình giọng nói trên thiết bị của nó trong quá trình thiết lập và chạy dưới dạng dịch vụ người dùng `hex.service`; mở cửa sổ của nó từ biểu tượng khay trên thanh bar hoặc bằng cách chạy `hex` để thay đổi mô hình và các cài đặt khác.

Bạn đọc để nhập liệu bằng cách giữ `Right Alt`, hoặc bằng cách bật/tắt bằng `Alt + Space`, và văn bản được đọc sẽ xuất hiện trong vùng nhập đang được focus. Các phím tắt này sử dụng backend đã chọn. `Right Alt` cũng bắt đầu nhập liệu bằng giọng nói khi được dùng trong một tổ hợp phím bổ trợ; hãy dùng `Left Alt` cho các tổ hợp đó. Trên các bố cục bàn phím mà `Right Alt` là AltGr, hãy dùng `Alt + Space` để giữ AltGr luôn khả dụng cho việc gõ phím. Các bản cài đặt từ trước khi `Alt + Space` trở thành mặc định vẫn giữ `F9` cho nhấn-giữ để nói và `Super + Ctrl + X` để bật/tắt, được thêm vào `~/.config/hypr/bindings.lua`, tại đó `Super + Ctrl + X` đó chiếm vị trí của agents panel; hãy xóa chúng tại đó để trả lại các phím đó cho các ứng dụng và panel.

Các phím tắt tương tự hoạt động với mọi backend. Chọn backend của bạn thông qua Setup > Defaults > Dictation. Trình cài đặt của backend cấu hình nó và lưu lựa chọn. Chạy `omarchy default dictation` để xem backend nào đang được chọn. Lựa chọn được lưu trong `~/.config/omarchy/defaults/dictation`. Các bản cài đặt mới tự động chọn Superwhisper.

Omarchy tự động tải tích hợp desktop của backend đã chọn. Không cần cấu hình Superwhisper nào trong `~/.config/hypr/`.

Các bindings và script tùy chỉnh có thể sử dụng `omarchy dictation start`, `omarchy dictation stop` và `omarchy dictation toggle`. Backend đã chọn xử lý việc ghi âm và chuyển thành văn bản. Việc chọn Superwhisper sẽ tắt phím tắt giữ gốc của nó và đặt phím bật/tắt gốc của nó thành `Ctrl + Alt + Space`, giữ nó tách biệt khỏi các phím ghi âm của Omarchy. Superwhisper yêu cầu ít nhất một phím tắt ghi âm gốc, và phím tắt hủy của nó vẫn luôn khả dụng.

Các backend bổ sung có thể tích hợp mà không cần thay đổi Omarchy. Cung cấp một tệp thực thi có tên `omarchy-dictation-<backend>` trên PATH chấp nhận `start`, `stop` và `toggle` và trả về ngay lập tức, với trạng thái khác không khi thất bại. Trình cài đặt của nó cấu hình provider và gọi `omarchy-dictation-use <backend>` sau khi thiết lập thành công. Thao tác này dừng backend trước đó và lưu lựa chọn một cách nguyên tử; `stop` phải thành công khi provider đang idle hoặc không khả dụng. Tên backend sử dụng chữ cái thường, chữ số và dấu gạch ngang. Cung cấp `omarchy-install-dictation-<backend>` cho việc thiết lập; `omarchy default dictation <backend>` sẽ khởi chạy nó. Thêm một mục menu Defaults thông qua một extension của menu Omarchy để gọi bộ chọn đó. Tích hợp desktop tùy chọn có thể nằm trong `${XDG_CONFIG_HOME:-$HOME/.config}/<backend>/shortcuts.lua`.
