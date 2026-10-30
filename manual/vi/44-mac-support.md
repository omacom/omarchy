# Hỗ trợ Mac

Omarchy có hỗ trợ tích hợp sẵn cho **Mac Intel**. Hiện tại có một vài hạn chế đã biết, nhưng miễn là bạn nhận thức được và chấp nhận chúng; bạn có thể thổi luồng sinh khí mới vào những chiếc Mac cũ của mình bằng cách nạp Omarchy.

Xin lưu ý rằng việc cài đặt trên Mac dòng M hiện không được hỗ trợ trực tiếp. Bạn có thể tìm hiểu thêm về tình trạng của việc này trong #omarchy-on-other trên [Discord](https://discord.gg/tXFUdasqhY) của chúng tôi.

Trong một thử nghiệm đơn giản, chúng tôi đã đạt được mức tăng hiệu năng 36% trên một chiếc MacBook Pro 2019 chỉ bằng cách cài đặt Omarchy.

 ![macbook-omarchy](images/macbook-omarchy.webp)

### Cài đặt Omarchy trên Mac

Omarchy hiện chỉ hỗ trợ là hệ điều hành **duy nhất** được cài đặt. Trong quá trình cài đặt, ổ đĩa sẽ bị xóa sạch và MacOS sẽ không còn khởi động được nữa.

Bạn vẫn có thể khôi phục nó sau này qua Internet Recovery nếu muốn.

Vì mục đích của phần này, chúng ta sẽ giả định bạn đã xem qua [Bắt đầu](02-getting-started.md) và đã chuẩn bị sẵn ổ USB của mình. Nếu chưa, hãy làm điều đó ngay bây giờ.

#### Tắt Secure Boot

Cần phải tắt Secure Boot của Apple để khởi động USB có thể khởi động, cũng như hệ điều hành. Để tắt nó, hãy thực hiện các bước sau:

1. Tắt máy Mac của bạn
2. Bật nó lên và _ngay lập tức_ nhấn giữ Command-R cho đến khi bạn thấy màn hình tải xuất hiện
3. Chọn người dùng của bạn và nhập mật khẩu nếu được nhắc
4. Khi đã vào màn hình khôi phục, chọn **Utilities > Startup Security Utility** từ thanh menu
5. Nhập mật khẩu của bạn khi được nhắc xác thực
6. Chọn "No Security" từ các tùy chọn Secure Boot
7. Chọn "Allow booting from external or removable media" từ các tùy chọn External Boot

#### Bắt đầu cài đặt

1. Cắm ổ USB vào
2. Khởi động lại máy Mac của bạn và _ngay lập tức_ nhấn giữ Option cho đến khi bạn thấy màn hình các thiết bị khởi động
3. Chọn thiết bị EFI Boot màu cam
4. Tiến hành [cài đặt như bình thường](02-getting-started.md)

Trình cài đặt phát hiện phần cứng Mac và tự động áp dụng các sửa chữa cần thiết: trình điều khiển và firmware Wi-Fi Broadcom, trình điều khiển bàn phím SPI trên các mẫu MacBook cần nó, và một bản sửa lỗi tạm dừng NVMe cho chính những mẫu đó.

### Các hạn chế đã biết

Các thành viên của cộng đồng liên tục làm việc để tìm giải pháp cho những thách thức này, nên nếu những điều này gây vấn đề cho bạn, hãy tham gia #omarchy-on-other trên [Discord](https://discord.gg/tXFUdasqhY) của chúng tôi và xem có phương pháp cập nhật nào để giải quyết chúng không.

#### Các thiết bị có chip T1

Chip Apple T1 được giới thiệu vào cuối năm 2016 và được dùng độc quyền trong các mẫu MacBook Pro thế hệ đầu tiên có Touch Bar.
- MacBook Pro 13-inch (2016, two Thunderbolt 3 ports) – Model: A1706
- MacBook Pro 13-inch (2016, four Thunderbolt 3 ports) – Model: A1708
- MacBook Pro 15-inch (2016) – Model: A1707

#### Các vấn đề đã biết

- Touch Bar không hoạt động
- Âm thanh không hoạt động

#### Các thiết bị có chip T2

Chip bảo mật Apple T2 được giới thiệu vào năm 2017. Chip T2 đã bị ngừng sản xuất khi chuyển sang Apple silicon (các chip dòng M) bắt đầu từ năm 2020.

- iMac Pro (2017) – Model: A1862
- MacBook Pro 13-inch (2018, four Thunderbolt 3 ports) – Model: A1989
- MacBook Pro 15-inch (2018) – Model: A1990
- MacBook Air (Retina, 13-inch, 2018) – Model: A1932
- Mac mini (2018) – Model: A1998
- MacBook Pro 13-inch (2019, two Thunderbolt 3 ports) – Model: A2159
- MacBook Pro 13-inch (2019, four Thunderbolt 3 ports) – Model: A2178
- MacBook Pro 15-inch (2019) – Model: A1990
- iMac (Retina 5K, 27-inch, 2020) – Model: A2115 (iMac20,1 and iMac20,2)
- MacBook Pro 13-inch (2020, two Thunderbolt 3 ports) – Model: A2265
- MacBook Pro 15-inch (2020) – Model: A1990

Trên các mẫu này, trình cài đặt tự động thiết lập kernel `linux-t2` đã được vá, cấu hình âm thanh T2, firmware Wi-Fi/Bluetooth Broadcom của Apple và điều khiển quạt qua `t2fanrd`. Touch Bar chạy trên hỗ trợ kiểu Boot Camp tích hợp sẵn của kernel.
