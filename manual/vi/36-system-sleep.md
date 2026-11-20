# Chế độ ngủ của hệ thống

Omarchy bật chế độ tạm dừng và ngủ đông theo mặc định, nhưng nếu bạn gặp sự cố với một trong hai chế độ trên máy của mình, bạn có thể tắt chúng.

Trên các máy NVIDIA GB10, chẳng hạn như DGX Spark và ASUS Ascent GX10, chế độ tạm dừng và ngủ đông bị tắt, giống như trong DGX OS của NVIDIA, vì chế độ ngủ vẫn chưa được chứng minh là hoạt động trên phần cứng đó. Điều tương tự cũng áp dụng cho ASUS Zenbook A16 (UX3607OA), nơi chế độ tạm dừng vẫn chưa đưa chip vào trạng thái ngủ hoàn toàn và có thể bị treo qua đêm. Công tắc bật/tắt chế độ tạm dừng và thiết lập ngủ đông không áp dụng ở đó. Để bật lại chế độ ngủ, hãy xóa `/etc/systemd/sleep.conf.d/omarchy-sleep-disabled.conf` bằng `sudo rm`; sau đó Suspend sẽ quay lại menu, và chế độ ngủ đông có thể được thiết lập như trên các máy khác. Chạy `sudo omarchy apply hardware --install-user "$USER"` sẽ khôi phục lại tệp.

### Cấu hình điện năng

Trên laptop, Omarchy ghi nhớ cấu hình điện năng của bạn riêng biệt cho trạng thái cắm điện và chạy bằng pin, và chuyển đổi giữa hai trạng thái khi bạn cắm và rút sạc. Theo mặc định, điều đó có nghĩa là hiệu năng cao khi dùng nguồn AC và cân bằng khi dùng pin.

Bạn có thể xem máy của mình cung cấp những gì bằng `omarchy powerprofiles list`, và đặt cấu hình bạn muốn cho trạng thái hiện tại của mình bằng `omarchy powerprofiles set autodetect power-saver`. Để đặt trạng thái còn lại mà không cần rút bất cứ thứ gì, hãy nêu tên trực tiếp: `omarchy powerprofiles set battery power-saver`. Bất cứ thứ gì bạn chọn sẽ là thứ bạn nhận lại vào lần tới khi ở trạng thái đó.

### Bật/tắt chế độ tạm dừng

Bạn bật/tắt chế độ tạm dừng bằng cách chạy `omarchy toggle suspend` từ terminal. Lệnh đó chỉ hiện/ẩn tùy chọn trong _System_ (hoặc `Super + Esc`), và sau đó bạn có thể xem liệu nó có hoạt động ổn định trên hệ thống của mình hay không. Nếu không, bạn có thể ẩn nó lại bằng cùng lệnh đó.

### Bật/tắt chế độ ngủ đông

Bạn thiết lập chế độ ngủ đông bằng cách chạy `omarchy hibernation setup` từ terminal. Chế độ ngủ đông tạo một subvolume /swap trên ổ khởi động của bạn có kích thước bằng dung lượng RAM vật lý được cấp phát, vì vậy hãy đảm bảo bạn có nhiều dung lượng trống dự phòng. Trên máy 32GB, bạn sẽ luôn cần trống 32GB+ cho volume này. Chế độ ngủ đông cũng yêu cầu bootloader Limine mặc định.

Khi đã thiết lập, bạn sẽ thấy tùy chọn ngủ đông trong _System_ (hoặc `Super + Esc`), và sau đó bạn có thể xem liệu nó có hoạt động ổn định trên hệ thống của mình hay không. Nếu không, bạn có thể xóa nó lại bằng cách chạy `omarchy hibernation remove`.
