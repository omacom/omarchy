# Hình nền

Mỗi theme đều đi kèm bộ hình nền riêng của nó, và bạn có thể thêm hình nền của riêng mình trong `~/.config/omarchy/backgrounds/[theme]`. Nếu bạn muốn thêm một hình nền phụ vào, chẳng hạn, theme nord, bạn chỉ cần đặt tệp vào `~/.config/omarchy/backgrounds/nord`.

Bạn có thể làm việc này dễ nhất bằng cách vào _Cài đặt > Phong cách > Hình nền_ trong Menu Omarchy. Thao tác đó sẽ mở thư mục nơi hình nền của theme đó được lưu trữ. Nhấn `Super + Shift + F` để mở một trình quản lý tệp khác, tìm hình nền của bạn, sao chép nó qua. Giờ nó sẽ nằm trong các lựa chọn hình nền mà bạn có thể chọn bằng `Super + Ctrl + W`.

Hình nền có thể là video cũng như ảnh tĩnh. Thả một tệp `mp4`, `m4v`, `mov`, `webm`, `mkv`, hoặc `avi` vào cùng thư mục và nó sẽ xuất hiện bên cạnh các ảnh. Video được phát bởi công cụ hình nền OWE. Nó giải mã video một lần cho mọi màn hình và phát âm thanh của nó qua đầu ra âm thanh mặc định, và nó dừng phát bất cứ khi nào không có gì có thể nhìn thấy nó. Hình nền video vẫn tốn điện hơn rất nhiều so với hình nền tĩnh.

Các theme có thể bao gồm một đoạn intro ngắn cho một hình nền tĩnh. Đối với `backgrounds/road.webp`, video tương ứng nằm ở `backgrounds/intros/road.mp4`. Nó tự động phát lúc khởi động, khi chuyển sang một theme có hình nền đó được chọn, và khi chọn hình nền đó, rồi quay lại ảnh tĩnh. Video intro không xuất hiện trong trình chọn hình nền và không bao giờ lặp lại.

Tắt _Giao diện > Hiệu ứng chuyển động_ cũng tắt intro hình nền. Omarchy làm điều này theo mặc định trong một máy ảo. Lệnh `omarchy theme bg intro toggle` có thể bật/tắt intro riêng. Làm mới một theme không phát intro.

Bạn có thể tìm thấy một bộ sưu tập khổng lồ gồm các hình nền tuyển chọn rất ngầu trong [dharmx/walls](https://github.com/dharmx/walls).

Màn hình khóa hiển thị một khung hình tĩnh của hình nền video, giống như cách nó hiển thị một khung hình tĩnh của một GIF động.
