# Mạng

Việc kết nối mạng trong Omarchy do NetworkManager đảm nhiệm, và bạn điều khiển nó từ biểu tượng mạng trên [thanh trên cùng](05-the-top-bar.md) hoặc bằng `Super + Ctrl + N`.

Bảng đó quét các mạng Wi-Fi, hiển thị cường độ tín hiệu và kết nối. Ethernet thì chẳng cần làm gì cả — cắm vào là dùng được. Nếu bạn thích ở lại trong terminal hơn, `nmtui` cung cấp cho bạn các điều khiển tương tự, và cũng có một nhóm lệnh `omarchy network` nữa.

## Chia sẻ Wi-Fi của bạn

Thay vì đọc to một mật khẩu dài, hãy chạy _Setup > Network > QR Code_ khi bạn đang dùng Wi-Fi. Thao tác đó hiển thị một mã QR trên màn hình mà bất kỳ camera điện thoại nào cũng có thể quét để tham gia. Đây là một trong những thứ bạn sẽ dùng nhiều hơn bạn tưởng một khi đã biết nó ở đó.

Nếu bạn thực sự cần chính mật khẩu, `omarchy network password <interface>` sẽ in nó ra.

## DNS

Omarchy dùng bất kỳ DNS nào mà mạng của bạn cấp phát qua DHCP. Bạn có thể ghi đè điều đó cho toàn bộ máy trong _Setup > Network > DNS_, nơi Cloudflare và Google chỉ cách một cú nhấp chuột. Chọn _Custom_ để nhập các máy chủ của riêng bạn.

Từ terminal, `omarchy dns` in ra nhà cung cấp hiện tại và `omarchy dns Cloudflare` đặt một nhà cung cấp.

## Ghim băng tần Wi-Fi

Nếu router của bạn đặt 2.4GHz, 5GHz và 6GHz trên cùng một tên mạng, laptop của bạn đôi khi sẽ bám vào băng tần chậm. `omarchy network band` cho biết bạn đang ở băng tần nào, và `omarchy network band 5` sẽ ghim nó. Dùng `auto` để nó tự chọn lại.

Thao tác này ghim băng tần chứ không phải một điểm truy cập cụ thể, vì vậy bạn vẫn chuyển vùng giữa các AP như bình thường.

## Nó nhanh đến mức nào?

_Trigger > Speed Test > Network Speed Test_ đo tốc độ tải lên và tải xuống thực tế của bạn bằng một cặp đồng hồ đo. Từ terminal, đó là `omarchy network speedtest down` hoặc `up`. (Có một bài kiểm tra tốc độ đĩa nằm ngay cạnh nó trong menu đó, nếu bạn đang đo điểm nghẽn còn lại.)

## Tường lửa

Tường lửa được bật theo mặc định và chặn mọi lưu lượng đến, với một ngoại lệ: cổng 53317, để [LocalSend](22-guis.md) hoạt động ngay khi cài đặt.

SSH tắt cho đến khi bạn bật nó bằng _Setup > Security > SSHD_, thao tác này khởi động daemon, mở cổng 22 với giới hạn tốc độ để chống brute force, và ủy quyền một khóa. Docker cũng bị khóa chặt, vì vậy các container không thể vô tình phơi mình ra thế giới. Xem [bảo mật](48-security.md) để biết toàn bộ câu chuyện.

## Tailscale

[Tailscale](https://tailscale.com/) là một VPN dạng lưới giúp việc tiếp cận mọi máy tính và máy chủ của bạn qua internet trở nên đơn giản và an toàn. Cài đặt nó bằng _Install > Service > Tailscale_.

Thao tác đó mang đến cho bạn một bảng Tailscale trên thanh, cho phép kết nối và ngắt kết nối tailnet, chuyển tài khoản và chọn một exit node — cả máy của chính bạn lẫn các khu vực Mullvad đều xuất hiện trong danh sách. Nó cũng duyệt các máy của bạn, và đó là nơi Taildrop hoạt động: chọn một máy và nhấn `s` để gửi tệp cho nó, hoặc `c`, `n` và `d` để sao chép IP, tên hoặc tên DNS đầy đủ của nó. Lệnh tương đương trong terminal là `omarchy tailscale send <machine> [file...]`, và các tệp được gửi cho bạn sẽ tự động nằm trong `~/Downloads`. Thông báo báo có tệp đến sẽ chờ cho đến khi bạn nhấp để mở nó hoặc loại bỏ nó, vì vậy một tệp xuất hiện trong khi bạn rời xa máy vẫn ở đó để bạn xử lý khi quay lại.

Việc cài đặt nó cũng thêm một ứng dụng web cho bảng điều khiển quản trị Tailscale.

## Khi nó ngừng hoạt động

Trước khi khởi động lại, hãy thử tự khởi động lại phần đang gây sự cố. _Update > Hardware_ có Wi-Fi, Bluetooth, Audio và Trackpad, và việc tải lại một trong số đó sẽ giải quyết hầu hết các tình huống "năm phút trước nó vẫn hoạt động mà". Xem [khắc phục sự cố](45-troubleshooting.md).
