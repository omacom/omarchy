# Chế độ ngủ của hệ thống

Omarchy bật chế độ tạm dừng và ngủ đông theo mặc định, nhưng nếu bạn gặp vấn đề với một trong hai chế độ trên máy của mình, bạn có thể tắt chúng.

Trên các máy NVIDIA GB10, chẳng hạn như DGX Spark và ASUS Ascent GX10, chế độ tạm dừng và ngủ đông bị tắt, giống như trong DGX OS của NVIDIA, vì chế độ ngủ vẫn chưa được chứng minh là hoạt động trên phần cứng đó. Nút bật/tắt tạm dừng và thiết lập ngủ đông không áp dụng ở đó. Để bật lại chế độ ngủ, hãy xóa `/etc/systemd/sleep.conf.d/omarchy-sleep-disabled.conf` bằng `sudo rm`; Suspend sau đó sẽ trở lại menu, và ngủ đông có thể được thiết lập như trên các máy khác. Chạy `sudo omarchy apply hardware --install-user "$USER"` sẽ đặt lại tệp.

### Hồ sơ điện năng

Trên laptop, Omarchy ghi nhớ hồ sơ điện năng của bạn riêng cho khi cắm điện và khi chạy bằng pin, và chuyển đổi giữa hai hồ sơ khi bạn cắm và rút điện. Mặc định, điều đó có nghĩa là performance khi dùng nguồn AC và balanced khi dùng pin.

Bạn có thể xem máy của mình có những gì với `omarchy powerprofiles list`, và đặt hồ sơ bạn muốn cho trạng thái bạn đang ở hiện tại với `omarchy powerprofiles set autodetect power-saver`. Để đặt trạng thái còn lại mà không cần rút bất cứ thứ gì, hãy nêu tên trực tiếp: `omarchy powerprofiles set battery power-saver`. Bất cứ hồ sơ nào bạn chọn sẽ là hồ sơ bạn nhận lại vào lần tới khi bạn ở trạng thái đó.

### Bật/tắt tạm dừng

Bạn bật/tắt tạm dừng bằng cách chạy `omarchy toggle suspend` từ terminal. Thao tác đó chỉ hiện/ẩn tùy chọn trong _System_ (hoặc `Super + Esc`), và sau đó bạn có thể xem nó có hoạt động ổn định trên hệ thống của mình không. Nếu không, bạn có thể ẩn lại bằng cùng lệnh đó.

### Bật/tắt ngủ đông

Bạn thiết lập ngủ đông bằng cách chạy `omarchy hibernation setup` từ terminal. Ngủ đông tạo một subvolume /swap trên ổ đĩa khởi động của bạn có kích thước bằng dung lượng RAM vật lý được cấp phát, vì vậy hãy đảm bảo bạn có nhiều dung lượng trống. Trên máy 32GB, bạn sẽ luôn cần trống 32GB+ cho volume này. Ngủ đông cũng yêu cầu bootloader Limine mặc định.

Khi đã thiết lập, bạn sẽ thấy tùy chọn ngủ đông trong _System_ (hoặc `Super + Esc`), và sau đó bạn có thể xem nó có hoạt động ổn định trên hệ thống của mình không. Nếu không, bạn có thể gỡ bỏ lại bằng cách chạy `omarchy hibernation remove`.
