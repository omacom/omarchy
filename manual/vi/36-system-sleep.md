# Chế độ ngủ của hệ thống

Omarchy bật chế độ tạm dừng theo mặc định, và chế độ ngủ đông sau khi đã được thiết lập, nhưng nếu bạn gặp sự cố với một trong hai chế độ trên máy của mình, bạn có thể tắt chúng đi.

Trên các máy NVIDIA GB10, chẳng hạn như DGX Spark và ASUS Ascent GX10, chế độ tạm dừng và ngủ đông bị tắt, giống như trong DGX OS của NVIDIA, vì chế độ ngủ chưa được chứng minh là hoạt động trên phần cứng đó. Công tắc bật/tắt tạm dừng và việc thiết lập ngủ đông không áp dụng ở đó. Để bật lại chế độ ngủ, hãy xóa `/etc/systemd/sleep.conf.d/omarchy-sleep-disabled.conf` bằng `sudo rm`; Suspend sau đó sẽ trở lại menu, và có thể thiết lập ngủ đông như trên các máy khác. Chạy `sudo omarchy apply hardware --install-user "$USER"` sẽ đặt lại tệp đó.

### Hồ sơ năng lượng

Trên laptop, Omarchy ghi nhớ hồ sơ năng lượng của bạn riêng biệt cho trường hợp cắm nguồn và chạy bằng pin, và chuyển đổi giữa hai trạng thái khi bạn cắm và rút nguồn. Ngay từ đầu, điều đó có nghĩa là hiệu năng khi dùng nguồn AC và cân bằng khi dùng pin.

Bạn có thể xem máy của mình cung cấp những gì bằng `omarchy powerprofiles list`, và đặt hồ sơ bạn muốn cho trạng thái bạn hiện đang ở bằng `omarchy powerprofiles set autodetect power-saver`. Để đặt trạng thái còn lại mà không cần rút bất cứ thứ gì, hãy nêu trực tiếp tên của nó: `omarchy powerprofiles set battery power-saver`. Bất cứ thứ gì bạn chọn sẽ là thứ bạn nhận lại vào lần tiếp theo bạn ở trong trạng thái đó.

### Bật/tắt tạm dừng

Bạn bật/tắt tạm dừng bằng cách chạy `omarchy toggle suspend` từ terminal. Thao tác đó chỉ hiện/ẩn tùy chọn trong _System_ (hoặc `Super + Esc`), và sau đó bạn có thể xem nó có hoạt động ổn định trên hệ thống của mình hay không. Nếu không, bạn có thể ẩn nó lại bằng cùng một lệnh.

### Bật/tắt ngủ đông

Bạn thiết lập ngủ đông bằng cách chạy `omarchy hibernation setup` từ terminal (nó không khả dụng trên các máy Mac Apple Silicon). Ngủ đông tạo một subvolume /swap trên ổ khởi động của bạn có kích thước bằng dung lượng RAM vật lý của bạn, vì vậy hãy đảm bảo bạn có nhiều dung lượng trống. Trên máy 32GB, bạn sẽ luôn cần trống 32GB+ cho volume này. Ngủ đông cũng yêu cầu bootloader Limine mặc định.

Khi đã thiết lập, bạn sẽ thấy tùy chọn ngủ đông trong _System_ (hoặc `Super + Esc`), và sau đó bạn có thể xem nó có hoạt động ổn định trên hệ thống của mình hay không. Nếu không, bạn có thể xóa nó lại bằng cách chạy `omarchy hibernation remove`.
