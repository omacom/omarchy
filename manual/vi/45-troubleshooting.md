# Xử lý sự cố

### Tôi đã làm hỏng hệ thống của mình sau khi cập nhật!

Đầu tiên, hãy thử [khôi phục hệ thống của bạn](47-system-snapshots.md) về phiên bản trước bản cập nhật gần đây của bạn. Nếu cách đó không hiệu quả, hãy sử dụng `omarchy-debug` để chia sẻ vấn đề của bạn trên #omarchy-help trong Discord. Và nếu tất cả đều thất bại, bạn có thể cài đặt lại các cấu hình và gói mặc định bằng cách sử dụng `omarchy-reinstall`.

### Tại sao một số ứng dụng lại quá lớn trên màn hình của tôi?

Omarchy giả định một màn hình có độ phân giải cao 2x, vì vậy nó đặt `GDK_SCALE` thành 2 cho đến khi bạn chọn một tỷ lệ trong bảng điều khiển màn hình. Nếu bạn đang dùng màn hình 1x và các ứng dụng GTK hoặc X11 hiển thị quá khổ, hãy chọn 1x cho màn hình đó trong bảng điều khiển màn hình, hoặc thêm `hl.env("GDK_SCALE", "1")` vào `~/.config/hypr/monitors.lua` (và sau đó khởi động lại bất kỳ ứng dụng nào đang bị quá khổ). Xem [hướng dẫn về màn hình](33-monitors.md).

Đối với Spotify, bạn có thể sử dụng `Ctrl + Minus` để thu nhỏ giao diện người dùng (và `Ctrl + Plus` để phóng to hơn).

### Tại sao tất cả phím tắt Super của tôi ngừng hoạt động?

Trên một số laptop ASUS ROG và TUF, `Fn + Super` là một tổ hợp phím dễ bị bỏ qua, nó bật/tắt khóa phím Windows ở cấp firmware (dành cho chơi game để bạn không vô tình rời khỏi trò chơi). Không có gì trên màn hình cho bạn biết điều đó đã xảy ra. Khi khóa đang bật, Super hoàn toàn không phát ra tín hiệu nào — vì vậy mọi phím tắt của Omarchy sử dụng Super đều ngừng hoạt động, và trông như thể Hyprland đã bị hỏng.

Hãy nhấn `Fn + Super` một lần trước khi bạn đào sâu vào `~/.config/hypr/`, và nếu điều đó không đưa Super trở lại, hãy nhấn lại để bạn không để khóa vẫn bật. Đây không phải là Fn-lock, vốn chỉ thay đổi chức năng của hàng phím F.

### Wi-Fi, Bluetooth, âm thanh hoặc bàn di chuột của tôi vừa ngừng hoạt động

Trước khi khởi động lại máy, hãy thử khởi động lại riêng hệ thống con đang gặp sự cố. _Update > Hardware_ trong menu Omarchy có Wi-Fi, Bluetooth, Audio, và Trackpad, và việc tải lại một trong số đó sẽ xử lý phần lớn các tình huống "nó mới hoạt động cách đây năm phút" — một tai nghe Bluetooth không chịu kết nối lại, một bàn di chuột bị chết sau khi tạm dừng, âm thanh biến mất khi bạn rút phích cắm màn hình.

### Tại sao loa ngoài của tôi không phát âm thanh?

Có lẽ vì chúng chưa được đặt làm đầu ra chính. Nhấp vào biểu tượng loa ở phía bên phải của thanh bar, và nó sẽ mở popup âm lượng nơi bạn có thể chọn thiết bị đầu ra (và trộn âm lượng theo từng ứng dụng nữa).

### Loa laptop của tôi nghe không ổn

Trên một số laptop, Omarchy tự động áp dụng một tinh chỉnh loa để hiệu chỉnh đáp ứng tần số của loa tích hợp. `omarchy audio tuning status` cho bạn biết liệu một tinh chỉnh có đang hoạt động trên máy của bạn hay không, và `omarchy audio tuning off` sẽ tắt nó nếu bạn muốn nghe loa ở trạng thái thô hơn.

### Tại sao tôi không thể đăng nhập hoặc sudo bằng mật khẩu của mình?

Có lẽ bạn đã nhập sai quá nhiều lần và bị khóa. Nếu điều này đang xảy ra trên màn hình khóa, bạn có thể nhấn `CTRL + ALT + F2` để bắt đầu một TTY mới nơi bạn có thể đăng nhập dưới quyền root, sau đó chạy `faillock --reset --user [your-username]`. Điều đó sẽ đặt lại trạng thái khóa, và bạn có thể tiếp tục.

### Tại sao lời nhắc ủy quyền 1Password của tôi cho 1Password SSH Agent / CLI không xuất hiện?

Điều này có thể xảy ra vì 2 lý do:

Để lời nhắc phê duyệt phong phú xuất hiện, Settings > Advanced > Use Hardware Acceleration phải được bật. _Lưu ý: Điều này yêu cầu khởi động lại để bắt đầu hoạt động._

 ![troubleshooting-1password](images/troubleshooting-1password.webp)

Hoặc nếu bạn chưa khởi chạy 1Password kể từ khi khởi động máy, lời nhắc sẽ không xuất hiện.
