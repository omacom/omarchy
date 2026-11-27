# Các snapshot hệ thống

Chúng tôi tự động tạo snapshot mỗi khi Omarchy cập nhật, nhưng nếu bạn muốn tự tạo snapshot của riêng mình, bạn có thể dùng `omarchy-snapshot create`.

Cách bạn khởi động và khôi phục một snapshot phụ thuộc vào trình khởi động mà máy của bạn bắt đầu bằng. Các bản cài đặt UEFI mới dùng systemd-boot; các bản cài đặt cũ hơn và các máy BIOS dùng Limine. `omarchy-boot-backend` cho bạn biết bạn đang dùng loại nào.

## Với systemd-boot

Chọn _System > Snapshots_ trong menu Omarchy và chọn snapshot bạn muốn khởi động vào. Máy sẽ khởi động lại vào snapshot đó một lần. Hoặc giữ phím Space trong khi máy khởi động để xem menu khởi động, nơi mọi snapshot được liệt kê với snapshot mới nhất ở đầu, kèm theo phiên bản Omarchy và ngày của nó.

Một snapshot khởi động với một lớp tạm thời ở phía trên, vì vậy bạn có thể dùng nó như bình thường, nhưng bất kỳ thứ gì bạn thay đổi đều sẽ biến mất ở lần khởi động lại tiếp theo. Để giữ lại, hãy biến nó thành hệ thống của bạn: nhấp vào thông báo xuất hiện khi bạn đăng nhập, chọn _System > Snapshots > Restore This Snapshot_, hoặc chạy `omarchy-snapshot restore`. Quá trình khôi phục diễn ra trong khi máy khởi động lại. Hệ thống như trước đó vẫn ở trong menu khởi động với tên _Before restore_, và `omarchy-snapshot restore backup` sẽ đưa nó trở lại.

Từ terminal:

- `omarchy-snapshot list` liệt kê các snapshot bạn có thể khởi động;
- `omarchy-snapshot boot 12` khởi động lại vào snapshot 12 một lần;
- `omarchy-snapshot restore 12` biến snapshot 12 thành hệ thống ở lần khởi động lại tiếp theo, và `omarchy-snapshot restore --cancel` sẽ thay đổi quyết định đó của bạn trước lần khởi động lại.

## Với Limine

Để khởi động và khôi phục một snapshot, bạn chọn nó từ trình khởi động Limine. Menu khởi động mặc định vẫn ẩn, vì vậy hãy nhấn phím bất kỳ ngay khi Limine khởi động để hiển thị nó.

Từ màn hình đó, hãy chọn snapshot bạn muốn khởi động vào dựa trên ngày và phiên bản. Phiên bản Omarchy tại thời điểm snapshot được tạo có thể được nhìn thấy ở góc dưới bên trái.

 ![snapshots-bootloader](images/snapshots-bootloader.webp)

Khi bạn vào bên trong, một thông báo sẽ bật lên cho bạn biết bạn đang ở trong một snapshot có thể khởi động được và nếu bạn nhấp vào nó, quá trình khôi phục sẽ bắt đầu. Ngoài ra, bạn có thể dùng `omarchy-snapshot restore`.

 ![snapshots-restore](images/snapshots-restore.webp)

## Một lần khôi phục bao gồm những gì

Một lần khôi phục sẽ đưa hệ thống tập tin root của bạn trở lại, nhưng không đưa `/home` của bạn trở lại. Vì vậy, nó hiệu quả để hoàn nguyên một bản cập nhật hệ thống bị hỏng, nhưng không hiệu quả để khôi phục các tập tin cá nhân đã mất.

Điều này cũng có nghĩa là thư mục `~/.config` của bạn được giữ nguyên như cũ. Vì vậy, nếu bạn đang quay lui về một phiên bản trước đó của một thư viện hoặc ứng dụng lưu các tập tin cấu hình ở một định dạng mới, bạn sẽ phải tự xử lý việc đó.

Điều tương tự cũng áp dụng cho bản ghi của chính Omarchy về những migration nào đã chạy: nó nằm trong thư mục home của bạn, vì vậy nó vẫn tồn tại sau lần khôi phục. Các migration đã chạy sau khi snapshot được tạo vẫn được đánh dấu là đã xong, ngay cả khi những thay đổi chúng đã thực hiện đối với hệ thống tập tin root đã bị quay lui, và lần `omarchy update` tiếp theo sẽ không chạy lại chúng. Vì vậy, nếu bạn cập nhật lại sau một lần khôi phục và thứ gì đó mà một bản cập nhật trước đó đã thiết lập vẫn còn thiếu, đó có thể là lý do.
