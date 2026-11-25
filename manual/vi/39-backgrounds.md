# Hình nền

Mỗi theme đều đi kèm bộ hình nền riêng của nó, và bạn có thể thêm những hình nền của riêng mình vào `~/.config/omarchy/backgrounds/[theme]`. Nếu bạn muốn thêm một hình nền phụ vào, chẳng hạn, theme nord, bạn chỉ cần đặt tệp vào `~/.config/omarchy/backgrounds/nord`.

Bạn có thể làm việc này dễ nhất bằng cách vào _Install > Style > Background_ trong Omarchy Menu. Thao tác đó sẽ mở thư mục nơi lưu trữ hình nền cho theme đó. Nhấn `Super + Shift + F` để mở một trình quản lý tệp khác, tìm hình nền của bạn, sao chép nó sang. Giờ nó sẽ có mặt trong các lựa chọn hình nền mà bạn có thể chọn bằng `Super + Ctrl + W`.

Một theme không có hình nền nào của riêng mình sẽ nhận được một hình được vẽ từ màu sắc của nó: logo Omarchy bằng màu nhấn của theme trên màu nền của nó. Thêm hình của riêng bạn để thay thế nó.

Hình nền có thể là video cũng như ảnh tĩnh. Thả một tệp `mp4`, `m4v`, `mov`, `webm`, `mkv`, hoặc `avi` vào cùng thư mục và nó sẽ xuất hiện cùng với các hình ảnh. Video được phát bởi OWE wallpaper engine. Nó giải mã video một lần cho tất cả các màn hình và phát âm thanh của video qua đầu ra âm thanh mặc định, và nó dừng phát bất cứ khi nào không có gì có thể nhìn thấy nó. Hình nền video vẫn tốn điện hơn nhiều so với hình nền tĩnh.

Các theme có thể bao gồm một intro ngắn cho một hình nền tĩnh. Đối với `backgrounds/road.webp`, video tương ứng nằm tại `backgrounds/intros/road.mp4`. Nó tự động phát khi khởi động, khi chuyển sang một theme có hình nền đó được chọn, và khi chọn hình nền đó, rồi quay lại ảnh tĩnh. Video intro không xuất hiện trong trình chọn hình nền và không bao giờ lặp lại.

Chọn _Appearance > Animations Off_ cũng tắt intro hình nền. Omarchy làm điều này theo mặc định trong máy ảo. Lệnh `omarchy theme bg intro toggle` có thể bật/tắt intro riêng biệt. Làm mới một theme không phát intro.

Một ảnh tĩnh cũng có thể có một loop, một phiên bản yên tĩnh của cùng bức ảnh cứ tiếp tục chuyển động, tại `backgrounds/loops/road.mp4`. Nó phát thay cho ảnh tĩnh, sau intro của ảnh tĩnh nếu có, và dừng khi animation bị tắt. Khi dùng pin, ảnh tĩnh sẽ hiển thị thay vào đó, và loop quay lại ngay khi bạn cắm điện. Loop không xuất hiện trong trình chọn hình nền.

Bạn có thể tìm thấy một bộ sưu tập khổng lồ các hình nền tuyển chọn tuyệt vời trong [dharmx/walls](https://github.com/dharmx/walls).

Màn hình khóa hiển thị một khung hình tĩnh của hình nền video, cùng cách nó hiển thị một khung hình tĩnh của một GIF động.
