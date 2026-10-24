# Ảnh chụp nhanh hệ thống

Chúng tôi tự động tạo ảnh chụp nhanh mỗi lần cập nhật Omarchy, nhưng nếu bạn muốn tự tạo ảnh chụp nhanh của riêng mình, bạn có thể dùng `omarchy-snapshot create`.

Để khởi động và khôi phục một ảnh chụp nhanh, bạn chọn nó từ bộ tải khởi động Limine. (Nếu bạn hiện đang khởi động thẳng vào màn hình giải mã Omarchy, bạn sẽ cần chọn Limine làm tùy chọn khởi động qua BIOS trước).

Từ màn hình đó, hãy chọn ảnh chụp nhanh bạn muốn khởi động vào dựa trên ngày và phiên bản. Phiên bản của Omarchy tại thời điểm chụp nhanh có thể được nhìn thấy ở góc dưới bên trái.

 ![snapshots-bootloader](images/snapshots-bootloader.webp)

Khi bạn vào trong, một thông báo sẽ bật lên thông báo cho bạn rằng bạn đang ở trong một ảnh chụp nhanh có thể khởi động và nếu bạn nhấp vào nó, sẽ bắt đầu quá trình khôi phục. Ngoài ra, bạn có thể dùng `omarchy-snapshot restore`.

 ![snapshots-restore](images/snapshots-restore.webp)

Việc này sẽ khôi phục hệ thống tệp gốc của bạn, nhưng không khôi phục `/home` của bạn. Vậy nên nó hoạt động để hoàn nguyên một bản cập nhật hệ thống bị hỏng, nhưng không phải để khôi phục các tệp cá nhân đã mất.

Điều này cũng có nghĩa là thư mục `~/.config` của bạn được giữ nguyên như vậy. Vậy nên nếu bạn đang quay lại một phiên bản cũ hơn của một thư viện hoặc ứng dụng lưu trữ các tệp cấu hình ở định dạng mới, bạn sẽ phải tự giải quyết việc đó.

_Lưu ý: Tính năng này chỉ khả dụng trên các bản cài đặt dùng bộ tải khởi động Limine, vốn là mặc định kể từ Omarchy 2.0. Nó không khả dụng nếu bạn đang dùng GRUB hoặc systemd-boot._

### Bỏ qua menu khởi động

Nếu bạn không bao giờ chạm vào menu khởi động và chỉ muốn máy đi thẳng tới màn hình giải mã, hãy chạy _Thiết lập > Khởi động trực tiếp_ trong menu Omarchy. Việc đó bổ sung một mục EFI trỏ trực tiếp tới Omarchy, nên firmware khởi động nó mà không dừng ở Limine.

Sự đánh đổi là điều đã được nhắc ở trên cùng: khi khởi động trực tiếp bật, việc đến được một ảnh chụp nhanh có nghĩa là trước tiên phải chọn Limine từ menu khởi động BIOS của bạn. Chạy _Thiết lập > Khởi động trực tiếp_ lần nữa để loại bỏ mục đó và quay lại khởi động qua Limine. Một số firmware không thích các mục EFI tùy chỉnh, nên thiết lập sẽ từ chối chạy trên firmware American Megatrends và Apple.
