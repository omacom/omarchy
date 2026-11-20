# Hình nền

Mỗi chủ đề đều đi kèm bộ hình nền riêng của nó, và bạn có thể thêm hình nền của riêng mình vào `~/.config/omarchy/backgrounds/[theme]`. Nếu bạn muốn thêm một hình nền bổ sung vào, chẳng hạn, chủ đề nord, bạn chỉ cần đặt tệp vào `~/.config/omarchy/backgrounds/nord`.

Cách dễ nhất để làm việc này là vào _Install > Style > Background_ trong Omarchy Menu. Thao tác đó sẽ mở thư mục nơi lưu trữ hình nền cho chủ đề đó. Nhấn `Super + Shift + F` để khởi động một trình quản lý tệp khác, tìm hình nền của bạn, sao chép nó qua.  Giờ nó sẽ nằm trong các lựa chọn hình nền mà bạn có thể chọn bằng `Super + Ctrl + W`.

Hình nền có thể là video cũng như ảnh tĩnh. Thả một tệp `mp4`, `m4v`, `mov`, `webm`, `mkv`, hoặc `avi` vào cùng một thư mục và nó sẽ xuất hiện bên cạnh các hình ảnh. Video được phát bởi engine hình nền OWE. Nó giải mã video một lần cho tất cả các màn hình và phát âm thanh của nó qua đầu ra âm thanh mặc định, đồng thời nó dừng phát mỗi khi không có gì có thể nhìn thấy nó. Hình nền video vẫn tốn nhiều điện hơn hình nền tĩnh rất nhiều.

Các chủ đề có thể bao gồm một đoạn intro ngắn cho một hình nền tĩnh. Với `backgrounds/road.webp`, video tương ứng nằm ở `backgrounds/intros/road.mp4`. Nó tự động phát khi khởi động, khi chuyển sang một chủ đề có hình nền đó được chọn, và khi chọn hình nền đó, rồi quay trở lại ảnh tĩnh. Các video intro không xuất hiện trong trình chọn hình nền và không bao giờ lặp lại.

Tắt _Appearance > Animations_ cũng tắt các đoạn intro hình nền. Omarchy thực hiện việc này theo mặc định trong một máy ảo. Lệnh `omarchy theme bg intro toggle` có thể bật/tắt các đoạn intro một cách riêng biệt. Việc làm mới một chủ đề không phát đoạn intro.

Một ảnh tĩnh cũng có thể có một đoạn lặp, một phiên bản trầm lặng của cùng một hình mà vẫn tiếp tục chuyển động, ở `backgrounds/loops/road.mp4`. Nó phát thay cho ảnh tĩnh, sau đoạn intro của nó nếu có, và dừng khi hiệu ứng động bị tắt. Khi dùng pin, ảnh tĩnh sẽ hiển thị thay vào đó, và đoạn lặp sẽ quay lại khi bạn cắm điện. Các đoạn lặp không xuất hiện trong trình chọn hình nền.

Bạn có thể tìm thấy một bộ sưu tập lớn các hình nền hay ho được tuyển chọn trong [dharmx/walls](https://github.com/dharmx/walls).

Màn hình khóa hiển thị một khung hình tĩnh của hình nền video, giống như cách nó hiển thị một khung hình tĩnh của ảnh GIF động.
