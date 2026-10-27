# Máy ảo Windows

Omarchy cung cấp một cách dễ dàng để chạy Windows thông qua một máy ảo Docker. Bạn có thể cài đặt nó bằng _Cài đặt > Windows_ từ menu Omarchy (`Super + Space`).

Máy của bạn cần ảo hóa KVM cho việc này, hầu hết các máy đều có — nhưng đôi khi nó bị tắt trong BIOS, và trình cài đặt sẽ cho bạn biết nếu đó là trường hợp đó. Bạn cũng sẽ cần dung lượng đĩa: bất cứ thứ gì bạn cấp cho Windows, cộng thêm khoảng 10GB cho chính image.

Trình cài đặt hỏi bạn muốn cấp bao nhiêu RAM, bao nhiêu lõi CPU và bao nhiêu dung lượng đĩa (64GB trở lên là mức tối thiểu hợp lý), rồi hỏi tên người dùng và mật khẩu Windows. Để trống chúng và bạn sẽ nhận được `docker` / `admin`. Quá trình tải xuống mất một lúc — 10-15 phút là bình thường — và bạn có thể theo dõi tiến trình trong trình duyệt tại `http://127.0.0.1:8006`. Trình duyệt sẽ nhắc cùng tên người dùng và mật khẩu trước khi mở bảng điều khiển.

 ![windows-vm](images/windows-vm.webp)

## Sử dụng nó

Khi nó đã được cài đặt, khởi chạy _Windows_ từ trình khởi chạy ứng dụng. Thao tác đó khởi động máy ảo nếu nó chưa chạy và kết nối bạn qua RDP, toàn màn hình. Cho nó 15-30 giây vào lần khởi động lạnh.

Phiên RDP mang theo âm thanh, micro của bạn và một khay nhớ tạm dùng chung, vì vậy việc sao chép văn bản giữa Linux và Windows cứ thế hoạt động. Độ phân giải tuân theo cửa sổ của bạn, và Omarchy truyền tỷ lệ hiển thị của bạn qua, vì vậy nó không phải là một mớ mờ nhạt trên màn hình HiDPI.

Khi bạn đóng cửa sổ RDP, máy ảo sẽ tự động tắt. Nếu bạn muốn để nó tiếp tục chạy — giả sử bạn có thứ gì đó đang hoạt động trong đó — hãy khởi chạy nó bằng `omarchy windows vm launch --keep-alive` thay thế.

Phần còn lại của các điều khiển nằm trên cùng một lệnh:

```bash
omarchy windows vm status    # is it running?
omarchy windows vm stop      # shut it down
omarchy windows vm launch    # start and connect
```

## Chia sẻ tệp

Thư mục `~/Windows` trong thư mục nhà của bạn được tự động chia sẻ với máy ảo. Đặt các tệp ở đó nếu bạn muốn chúng có thể truy cập được từ Windows. Máy ảo không có quyền truy cập vào bất kỳ phần nào khác của hệ thống tệp của bạn, vì vậy bạn an toàn trước bất cứ thứ gì nguy hiểm ở phía Windows. Đĩa ảo của chính nó có sẵn tại `~/.windows`.

Các đường dẫn quen thuộc trong thư mục nhà đó vẫn nằm trên các hệ thống tệp của riêng chúng. Chúng cũng có thể là liên kết tượng trưng (symlink) đến các thư mục bạn sở hữu, điều này hữu ích khi đĩa ảo nằm trên một ổ đĩa lớn hơn. Trình cài đặt đo dung lượng trống trên hệ thống tệp thực sự chứa `~/.windows`, không nhất thiết là hệ thống tệp chứa thư mục nhà của bạn.

Giữ các đường dẫn đĩa và chia sẻ là các thư mục riêng biệt, không chồng chéo. Việc gỡ bỏ cố tình làm trống thư mục đĩa nhưng bảo toàn thư mục chia sẻ. Ngay trước khi xóa, Omarchy thực hiện một kiểm tra ngăn chặn có giới hạn và từ chối xóa bất cứ thứ gì nếu việc kiểm tra đó hết thời gian chờ hoặc không thể chứng minh hai cây thư mục là riêng biệt.

Trước khi máy ảo khởi động, Omarchy mở và ghim hai thư mục đó, rồi gắn kết (bind-mount) chính xác các inode của thư mục vào các điểm neo riêng tư cho từng người dùng bên dưới `/var/lib/omarchy/windows/mounts`. Docker chỉ thấy các điểm neo được bảo vệ bởi root đó. Điều này bảo toàn các vị trí đĩa tùy chỉnh đồng thời ngăn một tiến trình khác chạy dưới quyền của bạn hoán đổi một đường dẫn đã kiểm tra trước khi container có đặc quyền sử dụng nó. Các thư mục đĩa và chia sẻ hiện có được thắt chặt ở chế độ `0700` trong quá trình di chuyển để các tài khoản cục bộ khác không thể duyệt nội dung của chúng.

Các cổng của máy ảo chỉ được liên kết với localhost, vì vậy không thứ gì trên mạng của bạn có thể tiếp cận máy Windows. Bảng điều khiển web cũng yêu cầu tên người dùng và mật khẩu Windows đã cấu hình, ngăn một tài khoản cục bộ khác điều khiển máy ảo qua cổng 8006.

## Giới hạn và cấp phép

Thiết lập này không có truyền GPU qua (GPU passthrough), vì vậy nó không phù hợp cho chơi game hoặc biên tập video. Đây là một cách tuyệt vời để chạy Microsoft Office hoặc bất cứ thứ gì khác mà bạn tuyệt đối phải có.

Phiên bản được cài đặt là Windows 11 Pro, chưa được kích hoạt. Bạn sẽ cần khóa cấp phép của riêng mình để sử dụng các tính năng bị giới hạn.

Nếu máy tính này được giao kèm Windows, khóa OEM vẫn còn trong firmware ngay cả sau khi cài đặt Omarchy. In nó ra bằng `omarchy windows key`. Khóa đó bị ràng buộc với máy này — nó sẽ kích hoạt Windows được cài đặt lại trên phần cứng này, nhưng thường sẽ không kích hoạt được máy ảo.

Bạn có thể thay đổi việc phân bổ tài nguyên sau này bằng cách chạy lại `omarchy-windows-vm install`, lệnh này viết lại cấu hình của máy ảo từ câu trả lời của bạn. Tệp compose hiện nằm tại `/var/lib/omarchy/windows/docker-compose.yml` và thuộc sở hữu của root — đó là cố tình, để một tiến trình chạy dưới quyền của bạn không thể viết lại nó và khiến quá trình khởi động có đặc quyền gắn toàn bộ đĩa của bạn vào container. Nếu bạn cần tự tay sửa nó (ví dụ để gắn một thiết bị USB), hãy sửa nó bằng `sudo` và xem mọi tùy chọn trên [dự án Dockur Windows](https://github.com/dockur/windows).

Để loại bỏ toàn bộ, dùng _Gỡ bỏ > Windows_ từ menu Omarchy. Thao tác đó xóa đĩa của máy ảo và mọi dữ liệu của nó, vì vậy hãy chắc chắn rằng bất cứ thứ gì bạn quan tâm đã ra khỏi `~/Windows` trước.
