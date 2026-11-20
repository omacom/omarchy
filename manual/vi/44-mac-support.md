# Hỗ trợ Mac

Omarchy có hỗ trợ tích hợp sẵn cho **Intel Macs**. Hiện tại vẫn còn một vài hạn chế đã biết, nhưng miễn là bạn nắm rõ và chấp nhận được những hạn chế đó; bạn có thể thổi luồng sinh khí mới vào những chiếc Mac cũ của mình bằng cách cài Omarchy.

Xin lưu ý rằng việc cài đặt trên Mac dòng M hiện chưa được hỗ trợ trực tiếp. Bạn có thể tìm hiểu thêm về tình trạng này tại #omarchy-on-other trong [Discord](https://discord.gg/tXFUdasqhY) của chúng tôi.

Trong một bài kiểm tra đơn giản, chúng tôi đã đạt được mức tăng hiệu năng 36% trên một chiếc MacBook Pro 2019 chỉ bằng cách cài đặt Omarchy.

 ![macbook-omarchy](images/macbook-omarchy.webp)

### Cài đặt Omarchy trên Mac

Omarchy hiện chỉ hỗ trợ là hệ điều hành **duy nhất** được cài đặt. Trong quá trình cài đặt, ổ đĩa sẽ bị xóa sạch và MacOS sẽ không còn khởi động được nữa.

Bạn vẫn có thể khôi phục lại sau này qua Internet Recovery nếu muốn.

Trong phần này, chúng tôi sẽ giả định rằng bạn đã xem qua [Getting Started](02-getting-started.md) và đã chuẩn bị sẵn ổ USB. Nếu chưa, hãy làm ngay bây giờ.

#### Tắt Secure Boot

Cần phải tắt Secure Boot của Apple để khởi động USB có khả năng khởi động, cũng như hệ điều hành. Để tắt, hãy thực hiện như sau:

1. Tắt Mac của bạn
2. Bật máy lên và _ngay lập tức_ nhấn giữ Command-R cho đến khi bạn thấy màn hình tải xuất hiện
3. Chọn người dùng của bạn và nhập mật khẩu nếu được nhắc
4. Khi đã vào màn hình khôi phục, chọn **Utilities > Startup Security Utility** từ thanh menu
5. Nhập mật khẩu khi được nhắc để xác thực
6. Chọn "No Security" từ các tùy chọn Secure Boot
7. Chọn "Allow booting from external or removable media" từ các tùy chọn External Boot

#### Bắt đầu cài đặt

1. Cắm ổ USB vào
2. Khởi động lại Mac và _ngay lập tức_ nhấn giữ Option cho đến khi bạn thấy màn hình các thiết bị khởi động
3. Chọn thiết bị EFI Boot màu cam
4. Tiếp tục [cài đặt như bình thường](02-getting-started.md)

Trình cài đặt sẽ phát hiện phần cứng Mac và tự động áp dụng các bản sửa cần thiết: driver và firmware Wi-Fi Broadcom, driver bàn phím SPI trên các mẫu MacBook cần đến nó, và bản sửa lỗi tạm dừng NVMe cho chính các mẫu đó.

### Các hạn chế đã biết

Các thành viên trong cộng đồng liên tục làm việc để tìm giải pháp cho những thách thức này, vì vậy nếu chúng gây khó khăn cho bạn, hãy tham gia #omarchy-on-other trong [Discord](https://discord.gg/tXFUdasqhY) của chúng tôi và xem liệu có phương pháp cập nhật nào để giải quyết chúng hay không.

#### Thiết bị có chip T1

Chip Apple T1 được giới thiệu vào cuối năm 2016 và chỉ được dùng riêng trong các mẫu MacBook Pro thế hệ đầu tiên có Touch Bar.
- MacBook Pro 13-inch (2016, hai cổng Thunderbolt 3) – Model: A1706
- MacBook Pro 13-inch (2016, bốn cổng Thunderbolt 3) – Model: A1708
- MacBook Pro 15-inch (2016) – Model: A1707

#### Các vấn đề đã biết

- Touch Bar không hoạt động
- Âm thanh không hoạt động

#### Thiết bị có chip T2

Chip bảo mật Apple T2 được giới thiệu vào năm 2017. Chip T2 đã bị ngừng sản xuất khi chuyển sang Apple silicon (các chip dòng M) bắt đầu từ năm 2020.

- iMac Pro (2017) – Model: A1862
- MacBook Pro 13-inch (2018, bốn cổng Thunderbolt 3) – Model: A1989
- MacBook Pro 15-inch (2018) – Model: A1990
- MacBook Air (Retina, 13-inch, 2018) – Model: A1932
- Mac mini (2018) – Model: A1998
- MacBook Pro 13-inch (2019, hai cổng Thunderbolt 3) – Model: A2159
- MacBook Pro 13-inch (2019, bốn cổng Thunderbolt 3) – Model: A2178
- MacBook Pro 15-inch (2019) – Model: A1990
- iMac (Retina 5K, 27-inch, 2020) – Model: A2115 (iMac20,1 và iMac20,2)
- MacBook Pro 13-inch (2020, hai cổng Thunderbolt 3) – Model: A2265
- MacBook Pro 15-inch (2020) – Model: A1990

Trên các mẫu này, trình cài đặt sẽ tự động thiết lập kernel `linux-t2` đã vá, cấu hình âm thanh T2, firmware Wi-Fi/Bluetooth Broadcom của Apple, và điều khiển quạt qua `t2fanrd`. Touch Bar chạy trên hỗ trợ kiểu Boot Camp tích hợp sẵn trong kernel.

#### iMac Retina 5K (2017)

Chiếc iMac 27-inch 2017 không có chip T2, vì vậy trình cài đặt sẽ thiết lập nó giống như các Mac Intel khác.

- iMac (Retina 5K, 27-inch, 2017) – Model: A1419

#### Các vấn đề đã biết

- Màn hình không chạy ở độ phân giải gốc 5120×2880: tấm nền gồm hai tile, và driver mặc định chỉ bật một tile
- Âm thanh không hoạt động
- Điều khiển độ sáng không có tác dụng
- Chế độ ngủ làm treo máy; chỉ có thể khôi phục bằng cách tắt và bật lại nguồn

Một bản vá do cộng đồng phát triển cho mẫu này sửa lỗi màn hình, âm thanh và độ sáng: [omarchy-imac18-3](https://github.com/ahmadtv/omarchy-imac18-3).
