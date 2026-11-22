# Hình nền

Mỗi theme đều đi kèm với bộ hình nền riêng của nó, và bạn có thể thêm hình nền của riêng mình trong `~/.config/omarchy/backgrounds/[theme]`. Nếu bạn muốn thêm một hình nền phụ vào, chẳng hạn, theme nord, bạn chỉ cần đặt file vào `~/.config/omarchy/backgrounds/nord`.

Bạn có thể làm việc này dễ dàng nhất bằng cách vào _Install > Style > Background_ trong Omarchy Menu. Thao tác đó sẽ mở thư mục nơi hình nền cho theme đó được lưu trữ. Nhấn `Super + Shift + F` để mở một trình quản lý file khác, tìm hình nền của bạn, sao chép nó qua. Giờ nó sẽ có mặt trong các lựa chọn hình nền mà bạn có thể chọn bằng `Super + Ctrl + W`.

Hình nền cũng có thể là video chứ không chỉ là ảnh tĩnh. Thả một file `mp4`, `m4v`, `mov`, `webm`, `mkv`, hoặc `avi` vào cùng thư mục và nó sẽ xuất hiện cùng với các ảnh. Video được phát bởi OWE wallpaper engine. Nó giải mã video một lần cho mọi màn hình và phát âm thanh của nó qua đầu ra âm thanh mặc định, và nó dừng phát bất cứ khi nào không có gì có thể nhìn thấy nó. Hình nền video vẫn tốn nhiều điện hơn hẳn so với hình nền tĩnh.

Các theme có thể bao gồm một đoạn intro ngắn cho một hình nền tĩnh. Đối với `backgrounds/road.webp`, video tương ứng nằm tại `backgrounds/intros/road.mp4`. Nó tự động phát khi khởi động, khi chuyển sang một theme có hình nền đó được chọn, và khi chọn hình nền đó, rồi quay lại ảnh tĩnh. Các video intro không xuất hiện trong trình chọn hình nền và không bao giờ lặp lại.

Chọn _Appearance > Animations Off_ cũng tắt các intro hình nền. Omarchy làm việc này theo mặc định trong một máy ảo. Lệnh `omarchy theme bg intro toggle` có thể bật/tắt các intro một cách riêng biệt. Làm mới một theme không phát intro.

Một ảnh tĩnh cũng có thể có một loop, một phiên bản yên tĩnh của cùng bức ảnh vẫn tiếp tục chuyển động, tại `backgrounds/loops/road.mp4`. Nó phát thay cho ảnh tĩnh, sau intro của nó nếu có, và dừng khi hoạt ảnh bị tắt. Khi dùng pin, ảnh tĩnh sẽ hiển thị thay vào đó, và loop quay lại khi bạn cắm nguồn. Các loop không xuất hiện trong trình chọn hình nền.

Bạn có thể tìm thấy một bộ sưu tập khổng lồ các hình nền tuyển chọn rất đẹp trong [dharmx/walls](https://github.com/dharmx/walls).

Màn hình khóa hiển thị một khung hình tĩnh của hình nền video, giống như cách nó hiển thị một khung hình tĩnh của một GIF động.
