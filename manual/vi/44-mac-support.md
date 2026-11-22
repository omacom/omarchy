# Hỗ trợ Mac

## Omarchy cho Apple Silicon

Omarchy cho Apple Silicon là giải pháp chính thức của Omacom, được phát hành lần đầu cùng Omarchy 4.5. Nó cài đặt song song với macOS, và bạn chọn giữa hai hệ điều hành khi máy Mac khởi động.

Nhận được thông báo về Omarchy Mac? Hãy đến [Chuyển từ Omarchy Mac](#coming-from-omarchy-mac).

Nó chạy trên các máy Mac sau:

| Mac | Chip |
| --- | --- |
| MacBook Air | M1, M2, M3 |
| MacBook Pro | M1, M1 Pro, M1 Max, M2, M2 Pro, M2 Max, M3, M3 Pro, M3 Max |
| MacBook Neo | A18 Pro |
| Mac mini | M1, M2, M2 Pro |
| Mac Studio | M1 Max, M1 Ultra, M2 Max, M2 Ultra |
| iMac | M1, M3 |
| Mac Pro | M2 Ultra |

Các máy Mac M4 và mới hơn chưa được hỗ trợ. Hỗ trợ M4 đang được thử nghiệm trên kênh edge và sẽ đến tiếp theo. Trình cài đặt kiểm tra máy Mac của bạn trước khi thay đổi bất cứ điều gì.

Trên bất kỳ máy Mac Apple Silicon nào, bao gồm M4 và mới hơn, bạn có thể chạy Omarchy trong máy ảo VM bằng [Try Omarchy](https://github.com/omacom/try-omarchy).

### Những gì bạn cần

- macOS 15 Sequoia hoặc mới hơn, và một tài khoản quản trị viên
- Dung lượng đĩa trống cho Omarchy. Trình cài đặt đề xuất một kích thước và cho phép bạn thay đổi.
- Một bản sao lưu của máy Mac, nguồn điện và kết nối internet. Quá trình cài đặt tải xuống vài gigabyte.

### Cài đặt

Bạn cài đặt từ macOS. Cài đặt Omarchy Installer bằng [Homebrew](https://brew.sh):

```sh
brew install omacom/mac/omarchy
```

Hoặc tải xuống Omarchy Installer mới nhất từ [trang phát hành](https://github.com/omacom/omarchy-mac-installer/releases) của nó và mở nó.

Trình cài đặt kiểm tra máy Mac của bạn, cho bạn xem kế hoạch, và tạo chỗ cho Omarchy bằng cách thu nhỏ phân vùng macOS. macOS vẫn ở trên đĩa và không cần ổ USB. Khi giai đoạn đầu tiên hoàn tất, nó hướng dẫn bạn hoàn thành thiết lập trong macOS Recovery: tắt máy, giữ nút nguồn cho đến khi "Loading startup options" xuất hiện, chọn Omarchy, và làm theo các bước.

Ở lần khởi động đầu tiên, Omarchy yêu cầu một mật khẩu để mã hóa đĩa của nó. Không có khóa khôi phục: nếu bạn quên mật khẩu, các tệp Omarchy của bạn không thể khôi phục được.

Để chuyển đổi giữa Omarchy và macOS sau này, hãy tắt máy, sau đó giữ nút nguồn cho đến khi các tùy chọn khởi động xuất hiện và chọn một tùy chọn.

### Chuyển từ Omarchy Mac

Omarchy Mac hiện là một phần của Omarchy cho Apple Silicon, và mọi máy Mac đã chạy nó đều được hỗ trợ. Bản cài đặt hiện tại của bạn vẫn tiếp tục chạy, và các gói hệ thống của nó vẫn cập nhật, nhưng nó sẽ không nhận thêm cập nhật Omarchy nữa. Không có thời hạn và không có nâng cấp tại chỗ: bạn sao lưu, gỡ bỏ bản cài đặt cũ, cài đặt mới, và khôi phục. Các bước 2 đến 5 diễn ra trong macOS, vì vậy hãy mở trang này trên điện thoại trước khi khởi động lại.

1. **Sao lưu từ Omarchy, ra khỏi máy Mac.** Việc gỡ bỏ bản cài đặt cũ sẽ xóa nó, và macOS không thể đọc đĩa Omarchy. Hãy sao chép thư mục home của bạn sang ổ ngoài hoặc máy tính khác, bao gồm các khóa SSH và GPG, hồ sơ trình duyệt và công việc chưa đẩy lên. Lưu danh sách gói của bạn bằng `pacman -Qqe > ~/packages.txt`. Hãy sao lưu cả macOS, vì cả việc gỡ bỏ và cài đặt đều thay đổi kích thước đĩa của nó.
2. **Khởi động máy Mac của bạn trong macOS.** Tắt máy, giữ nút nguồn cho đến khi các tùy chọn khởi động xuất hiện, và chọn macOS.
3. **Cài đặt Omarchy Installer** như hướng dẫn trong [Cài đặt](#installing).
4. **Gỡ bỏ bản cài đặt cũ.** Mở Omarchy Installer và chọn Installation > Remove Omarchy. Nó cho bạn xem những gì nó sẽ xóa và trả lại dung lượng cho macOS. Nếu nó không nhận ra bản cài đặt của bạn, nó sẽ dừng mà không thay đổi đĩa. Hãy nhờ trợ giúp trong [Discord](https://discord.gg/tXFUdasqhY) thay vì tự tay xóa các phân vùng, điều này có thể xóa macOS.
5. **Cài đặt Omarchy cho Apple Silicon** bằng trình cài đặt.
6. **Khôi phục các tệp của bạn.** Đưa các thiết lập của bạn trở lại từng phần một thay vì sao chép toàn bộ `~/.config` đè lên các mặc định mới, vì các thiết lập cũ có thể ghi đè chúng.

### Điều cần biết

- Trên MacBook M1 và M2, hãy đánh thức khỏi chế độ ngủ bằng cách mở nắp hoặc nhấn nút nguồn.
- Câu hỏi hoặc vấn đề: hãy hỏi trong [Discord](https://discord.gg/tXFUdasqhY) của chúng tôi.

[README của trình cài đặt](https://github.com/omacom/omarchy-mac-installer#readme) bao gồm các kênh phát hành, cập nhật trình cài đặt và gỡ bỏ Omarchy.

## Các máy Mac Intel

Trong một bài kiểm tra đơn giản, chúng tôi đã đạt được mức tăng hiệu năng 36% trên MacBook Pro 2019 chỉ bằng cách cài đặt Omarchy.

 ![macbook-omarchy](images/macbook-omarchy.webp)

### Cài đặt Omarchy trên Mac

Omarchy hiện chỉ hỗ trợ là hệ điều hành **duy nhất** được cài đặt. Trong quá trình cài đặt, ổ đĩa sẽ bị xóa sạch và MacOS sẽ không còn khởi động được nữa.

Bạn vẫn có thể khôi phục lại sau qua Internet Recovery nếu muốn.

Đối với phần này, chúng ta sẽ giả định bạn đã xem [Bắt đầu](02-getting-started.md) và đã chuẩn bị sẵn ổ USB. Nếu chưa, hãy làm ngay bây giờ.

#### Tắt Secure Boot

Cần tắt Secure Boot của Apple để khởi động USB có khả năng khởi động, cũng như hệ điều hành. Để tắt nó, hãy thực hiện như sau:

1. Tắt máy Mac của bạn
2. Bật máy và _ngay lập tức_ nhấn giữ Command-R cho đến khi bạn thấy màn hình tải xuất hiện
3. Chọn người dùng của bạn và nhập mật khẩu nếu được yêu cầu
4. Khi vào màn hình khôi phục, hãy chọn **Utilities > Startup Security Utility** từ thanh menu
5. Nhập mật khẩu của bạn khi được yêu cầu xác thực
6. Chọn "No Security" trong các tùy chọn Secure Boot
7. Chọn "Allow booting from external or removable media" trong các tùy chọn External Boot

#### Bắt đầu cài đặt

1. Cắm ổ USB
2. Khởi động lại máy Mac và _ngay lập tức_ nhấn giữ Option cho đến khi bạn thấy màn hình các thiết bị khởi động
3. Chọn thiết bị EFI Boot màu cam
4. Tiếp tục với [cài đặt như bình thường](02-getting-started.md)

Trình cài đặt tự động phát hiện phần cứng Mac và áp dụng các bản sửa cần thiết: driver và firmware Wi-Fi Broadcom, driver bàn phím SPI trên các mẫu MacBook cần đến nó, và bản sửa tạm dừng NVMe cho cùng các mẫu đó.

### Các hạn chế đã biết

Các thành viên của cộng đồng liên tục làm việc để tìm giải pháp cho các thách thức này, vì vậy nếu chúng gây vấn đề cho bạn, hãy tham gia #omarchy-on-other trong [Discord](https://discord.gg/tXFUdasqhY) của chúng tôi và xem có phương pháp cập nhật nào để giải quyết chúng không.

#### Các thiết bị có chip T1

Chip Apple T1 được giới thiệu vào cuối năm 2016 và chỉ được sử dụng trong các mẫu MacBook Pro thế hệ đầu tiên có Touch Bar.
- MacBook Pro 13-inch (2016, two Thunderbolt 3 ports) – Model: A1706
- MacBook Pro 13-inch (2016, four Thunderbolt 3 ports) – Model: A1708
- MacBook Pro 15-inch (2016) – Model: A1707

#### Các vấn đề đã biết

- Touch Bar không hoạt động
- Âm thanh không hoạt động

#### Các thiết bị có chip T2

Chip bảo mật Apple T2 được giới thiệu vào năm 2017. Chip T2 bị ngừng sản xuất khi chuyển sang Apple silicon (các chip dòng M) bắt đầu từ năm 2020.

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

Trên các mẫu này, trình cài đặt tự động thiết lập kernel `linux-t2` đã vá, cấu hình âm thanh T2, firmware Wi-Fi/Bluetooth Broadcom của Apple, và điều khiển quạt qua `t2fanrd`. Touch Bar chạy trên hỗ trợ kiểu Boot Camp tích hợp sẵn của kernel.

#### iMac Retina 5K (2017)

Chiếc iMac 27-inch 2017 không có chip T2, vì vậy trình cài đặt thiết lập nó như các máy Mac Intel khác.

- iMac (Retina 5K, 27-inch, 2017) – Model: A1419

#### Các vấn đề đã biết

- Màn hình không chạy ở độ phân giải gốc 5120×2880: tấm nền gồm hai ô, và driver mặc định chỉ hiển thị một ô
- Âm thanh không hoạt động
- Điều khiển độ sáng không có tác dụng
- Chế độ ngủ làm treo máy; chỉ tắt và bật lại nguồn mới khôi phục được

Một bản vá cộng đồng cho mẫu này sửa màn hình, âm thanh và độ sáng: [omarchy-imac18-3](https://github.com/ahmadtv/omarchy-imac18-3).
