# Hỗ trợ Mac

## Omarchy cho Apple Silicon

Omarchy cho Apple Silicon là một giải pháp chính thức của Omacom, được phát hành lần đầu cùng Omarchy 4.5. Nó được cài đặt bên cạnh macOS, và bạn chọn giữa hai hệ điều hành khi máy Mac khởi động.

Nhận được thông báo về Omarchy Mac? Hãy đến [Chuyển từ Omarchy Mac](#coming-from-omarchy-mac).

Nó chạy trên các máy Mac này:

| Mac | Chips |
| --- | --- |
| MacBook Air | M1, M2, M3 |
| MacBook Pro | M1, M1 Pro, M1 Max, M2, M2 Pro, M2 Max, M3, M3 Pro, M3 Max |
| MacBook Neo | A18 Pro |
| Mac mini | M1, M2, M2 Pro |
| Mac Studio | M1 Max, M1 Ultra, M2 Max, M2 Ultra |
| iMac | M1, M3 |
| Mac Pro | M2 Ultra |

Các máy Mac M4 và mới hơn chưa được hỗ trợ. Hỗ trợ M4 đang được kiểm thử trên kênh edge và sẽ đến tiếp theo. Trình cài đặt kiểm tra máy Mac của bạn trước khi nó thay đổi bất cứ thứ gì.

Trên bất kỳ máy Mac Apple Silicon nào, bao gồm M4 và mới hơn, bạn có thể chạy Omarchy trong một máy ảo với [Try Omarchy](https://github.com/omacom/try-omarchy).

### Những thứ bạn cần

- macOS 15 Sequoia trở lên, và một tài khoản quản trị viên
- Dung lượng đĩa trống cho Omarchy. Trình cài đặt đề xuất một kích thước và cho phép bạn thay đổi nó.
- Một bản sao lưu của máy Mac, nguồn điện, và một kết nối internet. Quá trình cài đặt tải xuống vài gigabyte.

### Cài đặt

Bạn cài đặt từ macOS. Cài đặt Omarchy Installer bằng [Homebrew](https://brew.sh):

```sh
brew install omacom/mac/omarchy
```

Hoặc tải xuống Omarchy Installer mới nhất từ [trang releases](https://github.com/omacom/omarchy-mac-installer/releases) của nó và mở nó.

Trình cài đặt kiểm tra máy Mac của bạn, cho bạn xem kế hoạch, và tạo chỗ cho Omarchy bằng cách thu nhỏ phân vùng macOS. macOS vẫn ở trên đĩa và không cần ổ USB. Khi giai đoạn đầu tiên hoàn tất, nó hướng dẫn bạn hoàn thành việc thiết lập trong macOS Recovery: tắt máy, giữ nút nguồn cho đến khi "Loading startup options" xuất hiện, chọn Omarchy, và làm theo các bước.

Ở lần khởi động đầu tiên, Omarchy yêu cầu một mật khẩu để mã hóa đĩa của nó. Không có khóa khôi phục: nếu bạn quên mật khẩu, các tệp Omarchy của bạn không thể được khôi phục.

Để chuyển đổi giữa Omarchy và macOS sau này, hãy tắt máy, sau đó giữ nút nguồn cho đến khi các tùy chọn khởi động xuất hiện và chọn một tùy chọn.

### Chuyển từ Omarchy Mac

Omarchy Mac hiện là một phần của Omarchy cho Apple Silicon, và mọi máy Mac đã chạy nó đều được hỗ trợ. Bản cài đặt hiện tại của bạn vẫn tiếp tục chạy, và các gói hệ thống của nó vẫn được cập nhật, nhưng nó không còn nhận được các bản cập nhật Omarchy nữa. Không có thời hạn và không có nâng cấp tại chỗ: bạn sao lưu, gỡ bỏ bản cài đặt cũ, cài đặt mới, và khôi phục. Các bước 2 đến 5 diễn ra trong macOS, vì vậy hãy mở trang này trên điện thoại của bạn trước khi khởi động lại.

1. **Sao lưu từ Omarchy, ra ngoài máy Mac.** Việc gỡ bỏ bản cài đặt cũ sẽ xóa nó, và macOS không thể đọc đĩa Omarchy. Hãy sao chép thư mục home của bạn vào một ổ đĩa ngoài hoặc một máy tính khác, bao gồm các khóa SSH và GPG, các hồ sơ trình duyệt và công việc chưa được đẩy lên. Lưu danh sách gói của bạn bằng `pacman -Qqe > ~/packages.txt`. Hãy sao lưu cả macOS nữa, vì việc gỡ bỏ và cài đặt đều thay đổi kích thước đĩa của nó.
2. **Khởi động máy Mac của bạn trong macOS.** Tắt máy, giữ nút nguồn cho đến khi các tùy chọn khởi động xuất hiện, và chọn macOS.
3. **Cài đặt Omarchy Installer** như được trình bày trong [Cài đặt](#installing).
4. **Gỡ bỏ bản cài đặt cũ.** Mở Omarchy Installer và chọn Installation > Remove Omarchy. Nó cho bạn xem những gì nó sẽ xóa và trả lại dung lượng cho macOS. Nếu nó không nhận ra bản cài đặt của bạn, nó sẽ dừng lại mà không thay đổi đĩa. Hãy yêu cầu trợ giúp trong [Discord](https://discord.gg/tXFUdasqhY) thay vì tự tay xóa các phân vùng, việc này có thể xóa macOS.
5. **Cài đặt Omarchy cho Apple Silicon** bằng trình cài đặt.
6. **Khôi phục các tệp của bạn.** Đưa các cài đặt của bạn trở lại từng phần một thay vì sao chép toàn bộ `~/.config` đè lên các giá trị mặc định mới, vì các cài đặt cũ có thể ghi đè chúng.

### Cần biết

- Trên các máy MacBook M1 và M2, hãy đánh thức máy khỏi trạng thái ngủ bằng cách mở nắp hoặc nhấn nút nguồn.
- Câu hỏi hoặc vấn đề: hãy hỏi trong [Discord](https://discord.gg/tXFUdasqhY) của chúng tôi.

[README của trình cài đặt](https://github.com/omacom/omarchy-mac-installer#readme) bao quát các kênh phát hành, việc cập nhật trình cài đặt và gỡ bỏ Omarchy.

## Các máy Mac Intel

Trong một bài kiểm tra đơn giản, chúng tôi đã có thể đạt được mức tăng hiệu năng 36% trên một chiếc MacBook Pro 2019 chỉ bằng cách cài đặt Omarchy.

 ![macbook-omarchy](images/macbook-omarchy.webp)

### Cài đặt Omarchy trên Mac

Omarchy hiện chỉ hỗ trợ là hệ điều hành **duy nhất** được cài đặt. Trong quá trình cài đặt, ổ đĩa sẽ bị xóa sạch và MacOS sẽ không còn khởi động được nữa.

Bạn vẫn có thể khôi phục nó sau này qua Internet Recovery nếu bạn muốn.

Đối với phần này, chúng ta sẽ giả định bạn đã xem lại [Getting Started](02-getting-started.md) và đã sẵn sàng ổ USB của mình. Nếu bạn chưa làm, hãy làm ngay bây giờ.

#### Tắt Secure Boot

Cần phải tắt Secure Boot của Apple để khởi động USB có thể khởi động, cũng như hệ điều hành. Để tắt nó, hãy thực hiện như sau:

1. Tắt máy Mac của bạn
2. Bật nó lên và _ngay lập tức_ nhấn và giữ Command-R cho đến khi bạn thấy màn hình đang tải xuất hiện
3. Chọn người dùng của bạn và nhập mật khẩu nếu được nhắc
4. Khi đã ở màn hình khôi phục, chọn **Utilities > Startup Security Utility** từ thanh menu
5. Nhập mật khẩu của bạn khi được nhắc để xác thực
6. Chọn "No Security" từ các tùy chọn Secure Boot
7. Chọn "Allow booting from external or removable media" từ các tùy chọn External Boot

#### Bắt đầu cài đặt

1. Cắm ổ USB vào
2. Khởi động lại máy Mac của bạn và _ngay lập tức_ nhấn và giữ Option cho đến khi bạn thấy một màn hình các thiết bị khởi động
3. Chọn thiết bị EFI Boot màu cam
4. Tiến hành [cài đặt như bình thường](02-getting-started.md)

Trình cài đặt phát hiện phần cứng Mac và tự động áp dụng các bản sửa cần thiết: các trình điều khiển và firmware Wi-Fi Broadcom, trình điều khiển camera FaceTime HD trên các máy có Broadcom 1570 (firmware của nó được tải xuống từ Apple khi máy Mac trực tuyến, vì trình cài đặt hoạt động ngoại tuyến), trình điều khiển bàn phím SPI trên các mẫu MacBook cần nó, và một bản sửa lỗi tạm dừng NVMe cho chính các mẫu đó.

### Giới hạn đã biết

Các thành viên của cộng đồng liên tục làm việc để tìm giải pháp cho những thách thức này, vì vậy nếu những điều này gây vấn đề cho bạn, hãy tham gia #omarchy-on-other trong [Discord](https://discord.gg/tXFUdasqhY) của chúng tôi và xem liệu có bất kỳ phương pháp cập nhật nào để giải quyết chúng hay không.

#### Camera FaceTime HD

Trình điều khiển camera làm treo máy nếu nó được tải khi máy Mac ngủ đông, vì vậy nó được gỡ tải trước. Nó không thể được gỡ tải trong khi một ứng dụng đang mở camera, vì vậy việc ngủ đông bị hủy bỏ kèm một thông báo nêu tên ứng dụng: hãy đóng nó và ngủ đông lại. Điều đó bao gồm việc ngủ đông tự động khi pin yếu nghiêm trọng, và suspend-then-hibernate, việc này bị từ chối trước khi nó tạm dừng. Việc tạm dừng thông thường bị chính trình điều khiển từ chối trong khi camera đang mở, mà không có thông báo.

Firmware của camera được tải xuống từ Apple, vì vậy camera chỉ hoạt động khi máy Mac đã trực tuyến. Quá trình tải xuống bắt đầu khi khởi động và được thử lại cứ mỗi 15 phút trong khi mạng là vấn đề; nếu tệp của Apple đã thay đổi, nó sẽ dừng lại và chờ một bản cập nhật Omarchy. Nếu camera không xuất hiện, `journalctl -u facetimehd-firmware-fetcher` sẽ cho biết lý do, `sudo systemctl restart facetimehd-firmware-fetcher` sẽ thử lại, và một lần khởi động lại sẽ tải trình điều khiển nếu quá trình tải xuống đã hoàn tất nhưng camera vẫn chưa ở đó.

#### Các thiết bị có chip T1

Chip Apple T1 được giới thiệu vào cuối năm 2016 và được sử dụng độc quyền trong các mẫu MacBook Pro thế hệ đầu tiên có Touch Bar.
- MacBook Pro 13-inch (2016, two Thunderbolt 3 ports) – Model: A1706
- MacBook Pro 13-inch (2016, four Thunderbolt 3 ports) – Model: A1708
- MacBook Pro 15-inch (2016) – Model: A1707

#### Các vấn đề đã biết

- Touch Bar không hoạt động
- Âm thanh không hoạt động

#### Các thiết bị có chip T2

Chip bảo mật Apple T2 được giới thiệu vào năm 2017. Chip T2 đã bị ngừng sản xuất cùng với quá trình chuyển đổi sang Apple silicon (các chip dòng M) bắt đầu từ năm 2020.

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

Trên các mẫu này, trình cài đặt tự động thiết lập kernel `linux-t2` đã được vá, cấu hình âm thanh T2, firmware Wi-Fi/Bluetooth Broadcom của Apple, và điều khiển quạt qua `t2fanrd`. Touch Bar chạy trên hỗ trợ kiểu Boot Camp tích hợp sẵn của kernel.

#### iMac Retina 5K (2017)

Chiếc iMac 27-inch 2017 không có chip T2, vì vậy trình cài đặt thiết lập nó giống như các máy Mac Intel khác.

- iMac (Retina 5K, 27-inch, 2017) – Model: A1419

#### Các vấn đề đã biết

- Màn hình không chạy ở độ phân giải gốc 5120×2880 của nó: tấm nền gồm hai ô, và trình điều khiển mặc định chỉ thắp sáng một ô
- Âm thanh không hoạt động
- Điều khiển độ sáng không có tác dụng
- Chế độ ngủ làm treo máy; chỉ một lần tắt và bật lại nguồn mới khôi phục được nó

Một công cụ vá của cộng đồng cho mẫu này sửa màn hình, âm thanh và độ sáng: [omarchy-imac18-3](https://github.com/ahmadtv/omarchy-imac18-3).
