# Hình nền

Mọi chủ đề đều đi kèm với bộ hình nền riêng, và bạn có thể thêm hình nền của riêng mình trong `~/.config/omarchy/backgrounds/[theme]`. Nếu bạn muốn thêm một hình nền phụ vào, chẳng hạn, chủ đề nord, bạn chỉ cần đặt file vào `~/.config/omarchy/backgrounds/nord`.

Bạn có thể làm việc này dễ dàng nhất bằng cách vào _Cài đặt > Phong cách > Hình nền_ trong Omarchy Menu. Thao tác đó sẽ mở thư mục nơi lưu trữ các hình nền cho chủ đề đó. Nhấn `Super + Shift + F` để mở một trình quản lý file khác, tìm hình nền của bạn, sao chép nó sang. Giờ nó sẽ nằm trong các lựa chọn hình nền mà bạn có thể chọn bằng `Super + Ctrl + W`.

Hình nền có thể là video cũng như hình tĩnh. Thả một file `mp4`, `m4v`, `mov`, `webm`, `mkv`, hoặc `avi` vào cùng thư mục và nó sẽ xuất hiện cùng với các hình ảnh. Video được phát bởi công cụ hình nền OWE. Nó giải mã video một lần cho mọi màn hình và phát âm thanh của video qua đầu ra âm thanh mặc định, đồng thời dừng phát bất cứ khi nào không có gì có thể nhìn thấy nó. Hình nền video vẫn tốn nhiều điện năng hơn hẳn so với hình nền tĩnh.

Các chủ đề có thể bao gồm một đoạn intro ngắn cho một hình nền tĩnh. Đối với `backgrounds/road.webp`, video tương ứng nằm tại `backgrounds/intros/road.mp4`. Nó tự động phát khi khởi động, khi chuyển sang một chủ đề có hình nền đó đang được chọn, và khi chọn hình nền đó, rồi quay lại hình tĩnh. Video intro không xuất hiện trong bộ chọn hình nền và không bao giờ lặp lại.

Tắt _Giao diện > Hoạt ảnh_ cũng tắt intro hình nền. Omarchy làm điều này theo mặc định trong máy ảo. Lệnh `omarchy theme bg intro toggle` có thể bật/tắt intro một cách riêng biệt. Làm mới một chủ đề không phát intro.

Một hình tĩnh cũng có thể có một vòng lặp, một phiên bản lặng lẽ của cùng một bức hình vẫn liên tục chuyển động, tại `backgrounds/loops/road.mp4`. Nó phát thay cho hình tĩnh, sau intro của nó nếu có, và dừng khi hoạt ảnh bị tắt. Các vòng lặp không xuất hiện trong bộ chọn hình nền và, giống như bất kỳ hình nền video nào, tốn nhiều điện năng hơn hình tĩnh.

Bạn có thể tìm thấy một bộ sưu tập khổng lồ gồm các hình nền hay được tuyển chọn tại [dharmx/walls](https://github.com/dharmx/walls).

Màn hình khóa hiển thị một khung hình tĩnh của hình nền video, giống như cách nó hiển thị một khung hình tĩnh của một GIF động.
