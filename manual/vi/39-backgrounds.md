# Hình nền

Mỗi chủ đề đều đi kèm bộ hình nền riêng của nó, và bạn có thể thêm hình nền của riêng mình trong `~/.config/omarchy/backgrounds/[theme]`. Nếu bạn muốn thêm một hình nền bổ sung vào, chẳng hạn, chủ đề nord, bạn chỉ cần đặt tệp vào `~/.config/omarchy/backgrounds/nord`.

Bạn có thể làm việc này dễ dàng nhất bằng cách vào _Cài đặt > Phong cách > Hình nền_ trong Menu Omarchy. Việc đó sẽ mở thư mục nơi các hình nền cho chủ đề đó được lưu trữ. Nhấn `Super + Shift + F` để mở một trình quản lý tệp khác, tìm hình nền của bạn, sao chép nó qua. Giờ nó sẽ được đưa vào các lựa chọn hình nền mà bạn có thể chọn bằng `Super + Ctrl + Space`.

Hình nền có thể là video cũng như ảnh tĩnh. Thả một tệp `mp4`, `m4v`, `mov`, `webm`, `mkv` hoặc `avi` vào cùng thư mục đó và nó sẽ xuất hiện bên cạnh các hình ảnh. Video được phát bởi engine hình nền OWE. Nó giải mã video một lần cho mọi màn hình và phát âm thanh của nó qua đầu ra âm thanh mặc định, và nó dừng phát bất cứ khi nào không có gì có thể nhìn thấy nó. Màn hình khóa vẽ cùng một bản giải mã đó, ở chế độ tắt tiếng, thông qua OWE. Một hình nền video vẫn tốn nhiều điện hơn nhiều so với một hình tĩnh.

Các chủ đề có thể bao gồm một đoạn giới thiệu ngắn cho một hình nền tĩnh. Đối với `backgrounds/road.webp`, video tương ứng nằm ở `backgrounds/intros/road.mp4`. Nó tự động phát khi khởi động và khi chuyển sang một chủ đề có hình nền đó được chọn, rồi quay lại hình tĩnh. Video giới thiệu không xuất hiện trong bộ chọn hình nền và không bao giờ lặp lại.

Tắt _Kích hoạt > Giao diện > Hiệu ứng_ cũng tắt các đoạn giới thiệu hình nền. Omarchy làm việc này theo mặc định trong một máy ảo. Lệnh `omarchy theme bg intro toggle` có thể bật/tắt các đoạn giới thiệu một cách riêng biệt. Làm mới một chủ đề hoặc chọn một hình nền khác trong cùng một chủ đề sẽ không phát đoạn giới thiệu.

Bạn có thể tìm thấy một bộ sưu tập lớn các hình nền hay ho được tuyển chọn trên https://github.com/dharmx/walls.

Hình nền video giữ một ảnh tĩnh đã lưu trong bộ nhớ đệm trên màn hình khóa trong khi quá trình phát bị tạm dừng hoặc không khả dụng. GIF động phát trên màn hình nền và hiển thị một khung hình tĩnh trên màn hình khóa.
