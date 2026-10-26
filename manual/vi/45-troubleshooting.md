# Khắc phục sự cố

### Tôi đã làm hỏng hệ thống của mình bằng một bản cập nhật!

Trước hết hãy thử [khôi phục hệ thống của bạn](47-system-snapshots.md) về phiên bản trước bản cập nhật gần đây của bạn. Nếu cách đó không hiệu quả, hãy dùng `omarchy-debug` để chia sẻ vấn đề của bạn trên #omarchy-help trong Discord. Và nếu tất cả đều thất bại, bạn có thể cài đặt lại các cấu hình và gói mặc định bằng `omarchy-reinstall`.

### Tại sao một số ứng dụng lại lớn như vậy trên màn hình của tôi?

Omarchy giả định một màn hình độ phân giải cao 2x, điều này yêu cầu đặt `GDK_SCALE` thành 2 trong `~/.config/hypr/monitors.lua`. Nhưng nếu bạn đang dùng màn hình 1x, bạn có thể đổi `local omarchy_gdk_scale = 2` thành 1 (rồi khởi động lại bất kỳ ứng dụng nào đang quá khổ). Xem [tài liệu hướng dẫn về màn hình](33-monitors.md).

Đối với Spotify, bạn có thể dùng `Ctrl + Minus` để thu nhỏ giao diện (và `Ctrl + Plus` để làm nó lớn hơn).

### Wi-Fi, Bluetooth, âm thanh hoặc bàn di chuột của tôi vừa ngừng hoạt động

Trước khi khởi động lại máy, hãy thử khởi động lại riêng hệ thống con đang gây lỗi. _Cập nhật > Phần cứng_ trong menu Omarchy có Wi-Fi, Bluetooth, Âm thanh và Bàn di chuột, và việc tải lại một trong số chúng sẽ giải quyết phần lớn các tình huống "năm phút trước nó còn hoạt động" — một tai nghe Bluetooth không chịu kết nối lại, một bàn di chuột chết sau khi tạm dừng, âm thanh biến mất khi bạn rút một màn hình.

### Tại sao loa ngoài của tôi không phát?

Có lẽ vì chúng không được đặt làm đầu ra chính. Nhấp vào biểu tượng loa ở phía bên phải của thanh, và nó sẽ mở cửa sổ bật lên âm lượng nơi bạn có thể chọn thiết bị đầu ra (và trộn âm lượng theo từng ứng dụng nữa).

### Loa laptop của tôi nghe lạ

Trên một số laptop, Omarchy tự động áp dụng một tinh chỉnh loa để hiệu chỉnh đáp ứng tần số của loa tích hợp. `omarchy audio tuning status` cho bạn biết liệu một tinh chỉnh có đang hoạt động trên máy của bạn không, và `omarchy audio tuning off` sẽ tắt nó nếu bạn muốn nghe loa ở dạng thô hơn.

### Tại sao tôi không thể đăng nhập hoặc sudo bằng mật khẩu của mình?

Có lẽ bạn đã gõ sai nó quá nhiều lần và bị khóa. Nếu điều này đang xảy ra trên màn hình khóa, bạn có thể nhấn `CTRL + ALT + F2` để mở một TTY mới nơi bạn có thể đăng nhập với quyền root, rồi chạy `faillock --reset --user [your-username]`. Việc đó sẽ đặt lại khóa, và bạn sẽ sẵn sàng tiếp tục.

### Tại sao lời nhắc cấp quyền 1Password cho 1Password SSH Agent / CLI của tôi không xuất hiện?

Điều này có thể xảy ra vì 2 lý do:

Để lời nhắc phê duyệt đầy đủ xuất hiện, Settings > Advanced > Use Hardware Acceleration phải được bật. _Lưu ý: Việc này yêu cầu khởi động lại máy để bắt đầu hoạt động._

 ![troubleshooting-1password](images/troubleshooting-1password.webp)

Hoặc nếu bạn chưa mở 1Password kể từ khi khởi động máy, lời nhắc sẽ không xuất hiện.
