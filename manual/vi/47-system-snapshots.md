# Snapshot hệ thống

Chúng tôi tự động tạo snapshot trong mỗi lần cập nhật Omarchy, nhưng nếu bạn muốn tự tạo snapshot của riêng mình, bạn có thể dùng `omarchy-snapshot create`.

Để khởi động và khôi phục một snapshot, bạn chọn nó từ bộ nạp khởi động Limine. (Nếu hiện tại bạn khởi động thẳng vào màn hình giải mã của Omarchy, trước tiên bạn sẽ cần chọn Limine làm tùy chọn khởi động qua BIOS).

Từ màn hình đó, hãy chọn snapshot bạn muốn khởi động dựa trên ngày và phiên bản. Phiên bản Omarchy tại thời điểm tạo snapshot có thể được xem ở góc dưới cùng bên trái.

 ![snapshots-bootloader](images/snapshots-bootloader.webp)

Khi bạn vào được bên trong, một thông báo sẽ bật lên cho bạn biết rằng bạn đang ở trong một snapshot có thể khởi động được và nếu bạn nhấp vào đó, quá trình khôi phục sẽ bắt đầu. Ngoài ra, bạn có thể sử dụng `omarchy-snapshot restore`.

 ![snapshots-restore](images/snapshots-restore.webp)

Thao tác này sẽ khôi phục hệ thống tệp root của bạn, nhưng không khôi phục `/home` của bạn. Vì vậy nó hiệu quả để hoàn tác một bản cập nhật hệ thống bị lỗi, nhưng không dùng để khôi phục các tệp cá nhân đã mất.

Điều này cũng có nghĩa là thư mục `~/.config` của bạn được giữ nguyên như cũ. Vì vậy nếu bạn quay lại phiên bản cũ hơn của một thư viện hoặc ứng dụng lưu trữ các tệp cấu hình theo định dạng mới, bạn sẽ phải tự xử lý việc đó.

Điều tương tự cũng áp dụng cho bản ghi của chính Omarchy về những migration nào đã chạy: nó nằm trong thư mục home của bạn, vì vậy nó vẫn còn sau khi khôi phục. Các migration đã chạy sau khi snapshot được tạo vẫn được đánh dấu là đã hoàn thành, mặc dù những thay đổi chúng đã thực hiện đối với hệ thống tệp root đã bị hoàn tác, và lần `omarchy update` tiếp theo sẽ không chạy lại chúng. Vì vậy nếu bạn cập nhật lại sau khi khôi phục và thứ gì đó mà một bản cập nhật trước đó đã thiết lập vẫn còn thiếu, đó có thể là lý do.

_Lưu ý: Tính năng này chỉ khả dụng trên các bản cài đặt sử dụng bộ nạp khởi động Limine, vốn đã là mặc định kể từ Omarchy 2.0. Nó không khả dụng nếu bạn đang dùng GRUB hoặc systemd-boot._

### Bỏ qua menu khởi động

Nếu bạn không bao giờ động vào menu khởi động và chỉ muốn máy đi thẳng tới màn hình giải mã, hãy chạy _Setup > Direct Boot_ trong menu Omarchy. Thao tác đó thêm một mục EFI trỏ trực tiếp tới Omarchy, để firmware khởi động nó mà không dừng lại ở Limine.

Sự đánh đổi là điều đã được đề cập ở đầu: khi bật khởi động trực tiếp, để tới được một snapshot nghĩa là trước tiên phải chọn Limine từ menu khởi động BIOS của bạn. Hãy chạy _Setup > Direct Boot_ một lần nữa để xóa mục đó và quay lại khởi động qua Limine. Một số firmware không ưa các mục EFI tùy chỉnh, vì vậy trình thiết lập từ chối chạy trên firmware American Megatrends và Apple.
