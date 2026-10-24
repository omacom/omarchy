# Ngủ hệ thống

Omarchy bật tạm dừng và ngủ đông theo mặc định, nhưng nếu bạn gặp vấn đề với một trong hai tính năng trên máy của mình, bạn có thể tắt chúng.

### Cấu hình năng lượng

Trên laptop, Omarchy ghi nhớ cấu hình năng lượng của bạn riêng cho lúc cắm điện và lúc dùng pin, và chuyển đổi giữa hai trạng thái khi bạn cắm và rút điện. Ngay khi cài đặt, điều đó có nghĩa là hiệu năng khi dùng điện AC và cân bằng khi dùng pin.

Bạn có thể xem máy của mình cung cấp những gì bằng `omarchy powerprofiles list`, và đặt cấu hình bạn muốn cho trạng thái bạn đang ở bằng `omarchy powerprofiles set autodetect power-saver`. Để đặt trạng thái còn lại mà không cần rút bất kỳ thứ gì, hãy nêu tên nó trực tiếp: `omarchy powerprofiles set battery power-saver`. Bất cứ thứ gì bạn chọn cũng sẽ là thứ bạn nhận lại vào lần tiếp theo bạn ở trong trạng thái đó.

### Bật/tắt tạm dừng

Bạn bật/tắt tạm dừng bằng cách chạy `omarchy toggle suspend` từ terminal. Việc đó chỉ hiện/ẩn tùy chọn dưới _Hệ thống_ (hoặc `Super + Esc`), và sau đó bạn có thể xem nó có hoạt động ổn định trên hệ thống của mình không. Nếu không, bạn có thể ẩn nó lại bằng cùng một lệnh.

### Bật/tắt ngủ đông

Bạn thiết lập ngủ đông bằng cách chạy `omarchy hibernation setup` từ terminal. Ngủ đông tạo một subvolume /swap trên ổ đĩa khởi động của bạn có kích thước bằng dung lượng RAM vật lý của bạn, nên hãy đảm bảo bạn còn nhiều chỗ trống. Trên một máy 32GB, bạn sẽ luôn cần hơn 32GB trống cho volume này. Ngủ đông cũng yêu cầu bootloader Limine mặc định.

Khi đã thiết lập, bạn sẽ thấy tùy chọn ngủ đông dưới _Hệ thống_ (hoặc `Super + Esc`), và sau đó bạn có thể xem nó có hoạt động ổn định trên hệ thống của mình không. Nếu không, bạn có thể gỡ bỏ nó lại bằng cách chạy `omarchy hibernation remove`.
