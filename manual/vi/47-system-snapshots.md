# Snapshot hệ thống

Chúng tôi tự động tạo snapshot mỗi khi cập nhật Omarchy, nhưng nếu bạn muốn tự tạo snapshot của riêng mình, bạn có thể dùng `omarchy-snapshot create`.

Để khởi động và khôi phục một snapshot, bạn chọn nó từ trình nạp khởi động Limine. Menu khởi động mặc định bị ẩn, vì vậy hãy nhấn phím bất kỳ ngay khi Limine khởi động để hiển thị nó.

Từ màn hình đó, hãy chọn snapshot bạn muốn khởi động vào dựa trên ngày và phiên bản. Phiên bản của Omarchy tại thời điểm tạo snapshot có thể được xem ở góc dưới bên trái.

 ![snapshots-bootloader](images/snapshots-bootloader.webp)

Khi bạn vào trong, một thông báo sẽ bật lên cho bạn biết rằng bạn đang ở trong một snapshot có thể khởi động được và nếu bạn nhấp vào nó, quá trình khôi phục sẽ bắt đầu. Ngoài ra, bạn có thể dùng `omarchy-snapshot restore`.

 ![snapshots-restore](images/snapshots-restore.webp)

Thao tác này sẽ khôi phục hệ thống tệp gốc của bạn, nhưng không khôi phục `/home` của bạn. Vì vậy nó có tác dụng để quay lui một bản cập nhật hệ thống bị hỏng, nhưng không dùng để khôi phục các tệp cá nhân đã mất.

Điều này cũng có nghĩa là thư mục `~/.config` của bạn được giữ nguyên như cũ. Vì vậy nếu bạn quay lui về một phiên bản cũ hơn của một thư viện hoặc ứng dụng lưu trữ các tệp cấu hình ở định dạng mới, bạn sẽ phải tự xử lý việc đó thủ công.

Điều tương tự cũng áp dụng cho bản ghi của chính Omarchy về những migration nào đã chạy: nó nằm trong thư mục nhà của bạn, vì vậy nó vẫn còn sau khi khôi phục. Các migration đã chạy sau khi snapshot được tạo vẫn được đánh dấu là đã hoàn thành, mặc dù những thay đổi chúng đã thực hiện đối với hệ thống tệp gốc đã bị quay lui, và lần `omarchy update` tiếp theo sẽ không chạy lại chúng. Vì vậy nếu bạn cập nhật lại sau khi khôi phục và thứ gì đó mà một bản cập nhật trước đó đã thiết lập vẫn còn thiếu, đó có thể là lý do.

_Lưu ý: Tính năng này chỉ khả dụng trên các bản cài đặt sử dụng trình nạp khởi động Limine, vốn đã là mặc định kể từ Omarchy 2.0. Nó không khả dụng nếu bạn đang dùng GRUB hoặc systemd-boot._
