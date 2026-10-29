# Khắc phục sự cố

### Tôi đã làm hỏng hệ thống của mình bằng một bản cập nhật!

Trước tiên hãy thử [khôi phục hệ thống của bạn](47-system-snapshots.md) về phiên bản trước bản cập nhật gần đây của bạn. Nếu không được, hãy dùng `omarchy-debug` để chia sẻ vấn đề của bạn trên #omarchy-help trong Discord. Và nếu tất cả đều thất bại, bạn có thể cài đặt lại các cấu hình và gói mặc định bằng `omarchy-reinstall`.

### Tại sao một số ứng dụng lại lớn như vậy trên màn hình của tôi?

Omarchy giả định màn hình có độ phân giải cao 2x, điều này yêu cầu đặt `GDK_SCALE` thành 2 trong `~/.config/hypr/monitors.lua`. Nhưng nếu bạn đang dùng màn hình 1x, bạn có thể đổi `local omarchy_gdk_scale = 2` thành 1 (rồi khởi động lại bất kỳ ứng dụng nào đang quá khổ). Xem [hướng dẫn về màn hình](33-monitors.md).

Đối với Spotify, bạn có thể dùng `Ctrl + Minus` để thu nhỏ giao diện (và `Ctrl + Plus` để phóng to hơn).

### Tại sao tất cả phím tắt Super của tôi ngừng hoạt động?

Trên một số laptop ASUS ROG và TUF, `Fn + Super` là một tổ hợp dễ bỏ qua, nó bật/tắt khóa phím Windows ở cấp firmware (dành cho chơi game để bạn không thoát khỏi game do vô tình). Không có gì trên màn hình cho bạn biết điều đó đã xảy ra. Khi khóa đang bật, Super hoàn toàn không phát ra gì cả — vì vậy mọi phím tắt Omarchy dùng Super đều dừng lại, và trông như thể Hyprland đã hỏng.

Hãy nhấn `Fn + Super` một lần trước khi bạn đào vào `~/.config/hypr/`, và nếu cách đó không mang Super trở lại, hãy nhấn lại một lần nữa để bạn không để khóa vẫn bật. Đây không phải là Fn-lock, cái đó chỉ thay đổi chức năng của hàng phím F.

### Wi-Fi, Bluetooth, âm thanh hoặc bàn di chuột của tôi vừa ngừng hoạt động

Trước khi khởi động lại, hãy thử tự khởi động lại hệ thống con đang gây lỗi. _Update > Hardware_ trong menu Omarchy có Wi-Fi, Bluetooth, Audio và Trackpad, và việc tải lại một trong số đó sẽ giải quyết phần lớn các tình huống "năm phút trước nó vẫn hoạt động" — một tai nghe Bluetooth không kết nối lại được, một bàn di chuột chết sau khi tạm dừng, âm thanh biến mất khi bạn rút màn hình.

### Tại sao loa ngoài của tôi không phát?

Có lẽ vì chúng chưa được đặt làm đầu ra chính. Nhấp vào biểu tượng loa ở phía bên phải của thanh, và nó sẽ mở cửa sổ bật lên âm lượng, nơi bạn có thể chọn thiết bị đầu ra (và trộn âm lượng theo từng ứng dụng nữa).

### Loa laptop của tôi nghe lạ

Trên một số laptop, Omarchy tự động áp dụng một tinh chỉnh loa để hiệu chỉnh đáp tuyến tần số của loa tích hợp. `omarchy audio tuning status` cho bạn biết liệu một tinh chỉnh có đang hoạt động trên máy của bạn hay không, và `omarchy audio tuning off` sẽ tắt nó nếu bạn muốn nghe loa ở trạng thái thô.

### Tại sao tôi không thể đăng nhập hoặc sudo bằng mật khẩu của mình?

Có lẽ bạn đã nhập sai quá nhiều lần và bị khóa. Nếu điều này xảy ra trên màn hình khóa, bạn có thể nhấn `CTRL + ALT + F2` để bắt đầu một TTY mới, nơi bạn có thể đăng nhập với tư cách root, rồi chạy `faillock --reset --user [your-username]`. Thao tác đó sẽ đặt lại khóa, và bạn có thể tiếp tục.

### Tại sao lời nhắc ủy quyền 1Password cho 1Password SSH Agent / CLI của tôi không xuất hiện?

Điều này có thể xảy ra vì 2 lý do:

Để lời nhắc phê duyệt đầy đủ xuất hiện, Settings > Advanced > Use Hardware Acceleration phải được bật. _Lưu ý: Cần khởi động lại để bắt đầu hoạt động._

 ![troubleshooting-1password](images/troubleshooting-1password.webp)

Hoặc nếu bạn chưa khởi chạy 1Password kể từ khi khởi động, lời nhắc sẽ không xuất hiện.
