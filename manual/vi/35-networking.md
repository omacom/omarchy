# Mạng

Kết nối mạng trong Omarchy được NetworkManager đảm nhiệm, và bạn điều khiển nó từ biểu tượng mạng trên [thanh menu](05-the-top-bar.md) hoặc bằng `Super + Ctrl + W`.

Bảng đó sẽ quét các mạng Wi-Fi, hiển thị cường độ tín hiệu và kết nối. Ethernet không cần làm gì cả — cắm dây vào là dùng được. Nếu bạn thích ở lại trong terminal, `nmtui` cho bạn các điều khiển tương tự, và cũng có nhóm lệnh `omarchy network`.

## Chia sẻ Wi-Fi của bạn

Thay vì đọc to một mật khẩu dài, hãy chạy _Thiết lập > Mạng > Mã QR_ khi đang dùng Wi-Fi. Việc đó sẽ đưa một mã QR lên màn hình mà bất kỳ camera điện thoại nào cũng có thể quét để tham gia. Đây là một trong những thứ bạn sẽ dùng nhiều hơn bạn tưởng một khi đã biết nó ở đó.

Nếu bạn thực sự cần chính mật khẩu, `omarchy network password <interface>` sẽ in nó ra.

## DNS

Omarchy dùng bất kỳ DNS nào mà mạng của bạn cấp qua DHCP. Bạn có thể ghi đè điều đó cho toàn bộ máy trong _Thiết lập > Mạng > DNS_, nơi Cloudflare và Google chỉ cách một lần nhấp. Chọn _Tùy chỉnh_ để nhập máy chủ của riêng bạn.

Từ terminal, `omarchy dns` in ra nhà cung cấp hiện tại và `omarchy dns Cloudflare` sẽ đặt một nhà cung cấp.

## Ghim băng tần Wi-Fi

Nếu router của bạn đặt 2.4GHz, 5GHz và 6GHz trên cùng một tên mạng, laptop của bạn đôi khi sẽ bám lấy băng tần chậm. `omarchy network band` cho biết bạn đang ở băng tần nào, và `omarchy network band 5` sẽ ghim nó. Dùng `auto` để để nó tự chọn lại.

Việc này ghim băng tần chứ không phải một điểm truy cập cụ thể, nên bạn vẫn chuyển vùng giữa các điểm truy cập như bình thường.

## Nó nhanh đến mức nào?

_Kích hoạt > Kiểm tra tốc độ > Kiểm tra tốc độ mạng_ đo tốc độ tải lên và tải xuống thực tế của bạn bằng một cặp đồng hồ đo. Từ terminal, lệnh là `omarchy network speedtest down` hoặc `up`. (Có một bài kiểm tra tốc độ đĩa nằm cạnh nó trong menu đó, nếu bạn đang đo hiệu năng ở nút thắt cổ chai còn lại.)

## Tường lửa

Tường lửa được bật theo mặc định và chặn mọi lưu lượng đến, với một ngoại lệ duy nhất: cổng 53317, để [LocalSend](22-guis.md) hoạt động ngay khi cài đặt.

SSH tắt cho đến khi bạn bật nó bằng _Thiết lập > Bảo mật > SSHD_, việc này sẽ khởi động daemon, mở cổng 22 với giới hạn tốc độ chống tấn công brute force và cấp quyền cho một khóa. Docker cũng bị khóa chặt, nên các container không thể vô tình phơi mình ra thế giới. Xem [bảo mật](48-security.md) để biết toàn bộ câu chuyện.

## Tailscale

[Tailscale](https://tailscale.com/) là một VPN dạng lưới giúp việc truy cập mọi máy tính và máy chủ của bạn qua internet trở nên đơn giản và an toàn. Cài đặt nó bằng _Cài đặt > Dịch vụ > Tailscale_.

Việc đó cho bạn một bảng Tailscale trên thanh, dùng để kết nối và ngắt kết nối tailnet, chuyển tài khoản và chọn nút thoát — cả máy của chính bạn và các khu vực Mullvad đều xuất hiện trong danh sách. Nó cũng duyệt qua các máy của bạn, và đó là nơi Taildrop sinh sống: chọn một máy và nhấn `s` để gửi tệp cho nó, hoặc `c`, `n` và `d` để sao chép IP, tên hoặc tên DNS đầy đủ của nó. Lệnh terminal tương đương là `omarchy tailscale send <machine> [file...]`, và các tệp được gửi cho bạn sẽ tự động đến `~/Downloads`. Thông báo báo tin tệp đến sẽ chờ cho đến khi bạn nhấp để mở nó hoặc loại bỏ nó, nên một tệp xuất hiện trong lúc bạn rời máy vẫn ở đó để bạn trả lời khi quay lại.

Cài đặt nó cũng bổ sung thêm một ứng dụng web cho bảng điều khiển quản trị Tailscale.

## Khi nó ngừng hoạt động

Trước khi khởi động lại máy, hãy thử khởi động lại riêng phần đang gây lỗi. _Cập nhật > Phần cứng_ có Wi-Fi, Bluetooth, Âm thanh và Bàn di chuột, và việc tải lại một trong số chúng sẽ giải quyết hầu hết các tình huống "năm phút trước nó còn hoạt động". Xem [khắc phục sự cố](45-troubleshooting.md).
