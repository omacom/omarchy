# Hình nền

Mỗi chủ đề đều đi kèm bộ hình nền riêng của nó, và bạn có thể thêm các hình nền của riêng mình vào `~/.config/omarchy/backgrounds/[theme]`. Nếu bạn muốn thêm một hình nền phụ vào, chẳng hạn, chủ đề nord, bạn chỉ cần đặt tệp đó vào `~/.config/omarchy/backgrounds/nord`.

Cách dễ nhất để làm việc này là đi tới _Install > Style > Background_ trong Menu Omarchy. Thao tác đó sẽ mở thư mục nơi lưu trữ các hình nền cho chủ đề đó. Nhấn `Super + Shift + F` để mở một trình quản lý tệp khác, tìm hình nền của bạn, rồi sao chép nó sang. Giờ nó sẽ xuất hiện trong các lựa chọn hình nền mà bạn có thể chọn bằng `Super + Ctrl + W`.

Hình nền cũng có thể là video chứ không chỉ là hình tĩnh. Thả một tệp `mp4`, `m4v`, `mov`, `webm`, `mkv`, hoặc `avi` vào cùng thư mục và nó sẽ xuất hiện bên cạnh các hình ảnh. Video được phát bởi công cụ hình nền OWE. Nó giải mã video một lần cho tất cả các màn hình và phát âm thanh của video qua đầu ra âm thanh mặc định, đồng thời dừng phát mỗi khi không có gì có thể nhìn thấy nó. Hình nền video vẫn tốn điện hơn rất nhiều so với hình nền tĩnh.

Các chủ đề có thể bao gồm một đoạn giới thiệu ngắn cho một hình nền tĩnh. Đối với `backgrounds/road.webp`, video tương ứng nằm tại `backgrounds/intros/road.mp4`. Nó tự động phát khi khởi động và khi chuyển sang một chủ đề có hình nền đó được chọn, sau đó quay trở lại hình tĩnh. Các video giới thiệu không xuất hiện trong trình chọn hình nền và không bao giờ lặp lại.

Tắt _Appearance > Animations_ cũng sẽ tắt các đoạn giới thiệu hình nền. Omarchy làm điều này theo mặc định trong một máy ảo. Lệnh `omarchy theme bg intro toggle` có thể bật/tắt các đoạn giới thiệu một cách riêng biệt. Làm mới một chủ đề hoặc chọn một hình nền khác trong cùng một chủ đề sẽ không phát đoạn giới thiệu.

Bạn có thể tìm thấy một bộ sưu tập khổng lồ các hình nền tuyệt vời được tuyển chọn tại [dharmx/walls](https://github.com/dharmx/walls).

Màn hình khóa hiển thị một khung hình tĩnh của hình nền video, giống như cách nó hiển thị một khung hình tĩnh của một GIF động.
