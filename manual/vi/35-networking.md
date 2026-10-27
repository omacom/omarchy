# Mạng

Mạng trong Omarchy do NetworkManager xử lý, và bạn điều khiển nó từ biểu tượng mạng trong [thanh trên cùng](05-the-top-bar.md) hoặc bằng `Super + Ctrl + N`.

Bảng đó quét các mạng Wi-Fi, hiển thị cường độ tín hiệu và kết nối. Ethernet thì chẳng cần làm gì cả — cứ cắm vào là dùng được. Nếu bạn thích ở trong terminal hơn, `nmtui` cho bạn các điều khiển tương tự, và cũng có nhóm lệnh `omarchy network` nữa.

## Chia sẻ Wi-Fi của bạn

Thay vì đọc to một mật khẩu dài, hãy chạy _Thiết lập > Mạng > Mã QR_ trong khi bạn đang kết nối Wi-Fi. Thao tác đó hiển thị một mã QR trên màn hình mà bất kỳ camera điện thoại nào cũng có thể quét để tham gia. Đây là một trong những thứ bạn sẽ dùng nhiều hơn bạn nghĩ một khi đã biết nó ở đó.

Nếu bạn thực sự cần chính mật khẩu, `omarchy network password <interface>` sẽ in nó ra.

## DNS

Omarchy dùng bất kỳ DNS nào mà mạng của bạn cấp phát qua DHCP. Bạn có thể ghi đè điều đó cho toàn bộ máy trong _Thiết lập > Mạng > DNS_, nơi Cloudflare và Google chỉ cách một cú nhấp chuột. Chọn _Tùy chỉnh_ để nhập các máy chủ của riêng bạn.

Từ terminal, `omarchy dns` in ra nhà cung cấp hiện tại và `omarchy dns Cloudflare` đặt một nhà cung cấp.

## Ghim băng tần Wi-Fi

Nếu router của bạn đặt 2.4GHz, 5GHz và 6GHz trên cùng một tên mạng, laptop của bạn đôi khi sẽ bám lấy băng tần chậm. `omarchy network band` hiển thị bạn đang ở băng tần nào, và `omarchy network band 5` ghim nó lại. Dùng `auto` để nó tự chọn lại.

Thao tác này ghim băng tần chứ không phải một điểm truy cập cụ thể, vì vậy bạn vẫn chuyển vùng giữa các AP như bình thường.

## Nó nhanh đến mức nào?

_Kích hoạt > Kiểm tra tốc độ > Kiểm tra tốc độ mạng_ đo tốc độ tải lên và tải xuống thực tế của bạn bằng một cặp đồng hồ đo. Từ terminal, đó là `omarchy network speedtest down` hoặc `up`. Nó đo với dịch vụ riêng của Omarchy và chỉ tính các lần truyền kiểm tra của nó. Các lần tải xuống khác có thể cạnh tranh băng thông, nhưng chúng không được cộng vào kết quả kiểm tra tốc độ. (Có một bài kiểm tra tốc độ đĩa nằm ngay cạnh nó trong menu đó, nếu bạn đang đo điểm nghẽn còn lại.)

## Tường lửa

Tường lửa được bật theo mặc định và chặn mọi lưu lượng đến, với một ngoại lệ: cổng 53317, để [LocalSend](22-guis.md) hoạt động ngay từ đầu.

SSH tắt cho đến khi bạn bật nó bằng _Thiết lập > Bảo mật > SSHD_, thao tác này khởi động daemon, mở cổng 22 với giới hạn tốc độ để chống brute force, và cấp quyền cho một khóa. Docker cũng bị khóa chặt, vì vậy các container không thể vô tình phơi mình ra với thế giới. Xem [bảo mật](48-security.md) để biết toàn bộ câu chuyện.

## Tailscale

[Tailscale](https://tailscale.com/) là một mesh VPN giúp việc tiếp cận mọi máy tính và máy chủ của bạn qua internet trở nên đơn giản và an toàn. Cài đặt nó bằng _Cài đặt > Dịch vụ > Tailscale_.

Điều đó cho bạn một bảng Tailscale trong thanh, bảng này kết nối và ngắt kết nối tailnet, chuyển đổi tài khoản, và chọn một exit node — cả các máy của chính bạn và các khu vực Mullvad đều xuất hiện trong danh sách. Nó cũng duyệt các máy của bạn, và đó là nơi Taildrop sống: chọn một máy và nhấn `s` để gửi tệp cho nó, hoặc `c`, `n` và `d` để sao chép IP, tên hoặc tên DNS đầy đủ của nó. Tương đương trong terminal là `omarchy tailscale send <machine> [file...]`, và các tệp được gửi cho bạn sẽ tự động đến `~/Downloads`. Thông báo về một tệp đến sẽ chờ cho đến khi bạn nhấp để mở nó hoặc bỏ qua nó, vì vậy một tệp xuất hiện trong khi bạn rời khỏi máy vẫn còn đó để bạn xử lý khi quay lại.

Cài đặt nó cũng thêm một ứng dụng web cho bảng điều khiển quản trị Tailscale.

## Khi nó ngừng hoạt động

Trước khi khởi động lại, hãy thử khởi động lại riêng phần đang gây sự cố. _Cập nhật > Phần cứng_ có Wi-Fi, Bluetooth, Âm thanh và Trackpad, và việc tải lại một trong số đó sẽ giải quyết hầu hết các tình huống "nó vừa mới hoạt động cách đây năm phút". Xem [khắc phục sự cố](45-troubleshooting.md).
