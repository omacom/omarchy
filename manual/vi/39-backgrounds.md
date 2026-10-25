# Hình nền

Mỗi theme đều đi kèm bộ hình nền riêng, và bạn có thể thêm hình nền của mình vào `~/.config/omarchy/backgrounds/[theme]`. Nếu muốn thêm một hình nền phụ vào, ví dụ, theme nord, bạn chỉ cần đặt file vào `~/.config/omarchy/backgrounds/nord`.

Cách dễ nhất để làm việc này là vào _Install > Style > Background_ trong Omarchy Menu. Thao tác đó sẽ mở thư mục lưu hình nền cho theme đó. Nhấn `Super + Shift + F` để mở một trình quản lý file khác, tìm hình nền của bạn, sao chép nó sang. Giờ nó sẽ nằm trong các lựa chọn hình nền mà bạn có thể chuyển đổi bằng `Super + Ctrl + W`.

Hình nền có thể là video cũng như ảnh tĩnh. Thả một file `mp4`, `m4v`, `mov`, `webm`, `mkv`, hoặc `avi` vào cùng thư mục và nó sẽ xuất hiện bên cạnh các hình ảnh. Video được phát bởi công cụ hình nền OWE. Nó giải mã video một lần cho tất cả màn hình, phát âm thanh qua đầu ra âm thanh mặc định, và dừng phát bất cứ khi nào không có gì nhìn thấy nó. Hình nền video vẫn tốn nhiều điện năng hơn hẳn so với hình nền tĩnh.

Các theme có thể bao gồm một đoạn intro ngắn cho hình nền tĩnh. Với `backgrounds/road.webp`, video tương ứng nằm tại `backgrounds/intros/road.mp4`. Nó tự động phát khi khởi động và khi chuyển sang một theme có hình nền đó được chọn, sau đó quay lại ảnh tĩnh. Video intro không xuất hiện trong trình chọn hình nền và không bao giờ lặp lại.

Tắt _Appearance > Animations_ cũng tắt intro hình nền. Omarchy làm điều này theo mặc định trong máy ảo. Lệnh `omarchy theme bg intro toggle` có thể bật/tắt intro riêng biệt. Làm mới một theme hoặc chọn hình nền khác trong cùng theme sẽ không phát intro.

Bạn có thể tìm thấy một bộ sưu tập lớn các hình nền tuyển chọn rất ngầu tại https://github.com/dharmx/walls.

Màn hình khóa hiển thị một khung hình tĩnh của hình nền video, giống như cách nó hiển thị một khung hình tĩnh của GIF động.
