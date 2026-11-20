# Khắc phục sự cố

### Tôi đã làm hỏng hệ thống bằng một bản cập nhật!

Trước tiên hãy thử [khôi phục hệ thống của bạn](47-system-snapshots.md) về phiên bản trước bản cập nhật gần đây của bạn. Nếu cách đó không hiệu quả, hãy dùng `omarchy-debug` để chia sẻ vấn đề của bạn trên #omarchy-help trong Discord. Và nếu tất cả đều thất bại, bạn có thể cài đặt lại các cấu hình và gói mặc định bằng `omarchy-reinstall`.

### Tại sao một số ứng dụng lại quá lớn trên màn hình của tôi?

Omarchy giả định bạn dùng màn hình độ phân giải cao 2x, nên nó đặt `GDK_SCALE` thành 2 cho đến khi bạn chọn một tỷ lệ trong bảng điều khiển màn hình. Nếu bạn đang dùng màn hình 1x và các ứng dụng GTK hoặc X11 hiển thị quá khổ, hãy chọn 1x cho nó trong bảng điều khiển màn hình, hoặc thêm `hl.env("GDK_SCALE", "1")` vào `~/.config/hypr/monitors.lua` (rồi khởi động lại bất kỳ ứng dụng nào đang quá khổ). Xem [hướng dẫn về màn hình](33-monitors.md).

Đối với Spotify, bạn có thể dùng `Ctrl + Minus` để thu nhỏ giao diện người dùng (và `Ctrl + Plus` để phóng to hơn).

### Tại sao tất cả các phím tắt dùng phím Super của tôi đều ngừng hoạt động?

Trên một số laptop ASUS ROG và TUF, `Fn + Super` là một tổ hợp phím dễ bị bỏ qua, có tác dụng bật/tắt khóa phím Windows ở cấp firmware (dành cho chơi game để bạn không vô tình thoát khỏi trò chơi). Không có gì trên màn hình cho bạn biết điều đó đã xảy ra. Khi khóa đang bật, Super không phát ra bất kỳ tín hiệu nào — vì vậy mọi phím tắt Omarchy dùng Super đều ngừng hoạt động, và trông cứ như Hyprland đã hỏng.

Hãy nhấn `Fn + Super` một lần trước khi bạn đào sâu vào `~/.config/hypr/`, và nếu cách đó không đưa Super trở lại, hãy nhấn lại một lần nữa để bạn không để khóa vẫn bật. Đây không phải là Fn-lock, thứ chỉ thay đổi chức năng của hàng phím F.

### Wi-Fi, Bluetooth, âm thanh hoặc bàn di chuột của tôi vừa ngừng hoạt động

Trước khi khởi động lại máy, hãy thử khởi động lại riêng hệ thống con đang gây sự cố. _Update > Hardware_ trong menu Omarchy có Wi-Fi, Bluetooth, Audio, và Trackpad, và việc tải lại một trong số đó sẽ giải quyết phần lớn các tình huống "mới năm phút trước còn hoạt động" — một tai nghe Bluetooth không chịu kết nối lại, một bàn di chuột bị tê liệt sau khi tạm dừng, âm thanh biến mất khi bạn rút màn hình ra.

### Tại sao loa ngoài của tôi không phát tiếng?

Có lẽ vì chúng chưa được đặt làm đầu ra chính. Nhấp vào biểu tượng loa ở phía bên phải của thanh, và nó sẽ mở cửa sổ bật lên âm lượng, nơi bạn có thể chọn thiết bị đầu ra (và cũng có thể trộn âm lượng cho từng ứng dụng).

### Loa laptop của tôi nghe lạ

Trên một số laptop, Omarchy tự động áp dụng một bản tinh chỉnh loa để hiệu chỉnh đáp tuyến tần số của loa tích hợp. `omarchy audio tuning status` cho bạn biết liệu một bản tinh chỉnh có đang hoạt động trên máy của bạn hay không, và `omarchy audio tuning off` sẽ tắt nó nếu bạn muốn nghe loa ở trạng thái thô nguyên bản.

### Tại sao tôi không thể đăng nhập hoặc dùng sudo bằng mật khẩu của mình?

Có lẽ bạn đã nhập sai mười lần và bị khóa. Việc khóa sẽ tự động được gỡ sau hai phút. Nếu bạn không thể chờ, và điều này đang xảy ra trên màn hình khóa, bạn có thể nhấn `CTRL + ALT + F2` để khởi động một TTY mới, nơi bạn có thể đăng nhập với tư cách root, rồi chạy `faillock --reset --user [your-username]`. Thao tác đó sẽ đặt lại việc khóa, và bạn có thể tiếp tục.

### Mật khẩu của tôi được chấp nhận, nhưng tôi lại quay về màn hình đăng nhập

Một tệp môi trường phiên bị hỏng có thể ngăn màn hình nền khởi động ngay cả khi mật khẩu của bạn đúng. Điều này đặc biệt đáng kiểm tra sau khi chỉnh sửa `~/.config/uwsm/env.d/`.

Nhấn `Ctrl + Alt + F2`, đăng nhập bằng tên người dùng và mật khẩu thông thường của bạn, và kiểm tra nhật ký người dùng của lần khởi động hiện tại:

```bash
journalctl --user -b -t uwsm_env-preloader --no-pager
```

Hãy tìm một lỗi nêu tên một trong các tệp môi trường của bạn, chẳng hạn như `bad substitution`, ngay trước một thông báo cho biết không tìm thấy dấu đầu ra env. Hãy di chuyển tệp đó ra khỏi `env.d` trước khi thử đăng nhập lại. Ví dụ, nếu lỗi nêu tên `99-custom`:

```bash
mkdir -p ~/.config/uwsm/disabled
mv -i ~/.config/uwsm/env.d/99-custom ~/.config/uwsm/disabled/
```

UWSM bỏ qua một tệp có lỗi cú pháp, nhưng một lỗi nghiêm trọng chỉ xuất hiện khi tệp chạy, như `bad substitution`, vẫn có thể ngăn màn hình nền khởi động. Việc khôi phục ảnh chụp hệ thống không sửa được các tệp này, vì `/home` không được khôi phục.

Khi bạn có thể đăng nhập, hãy sửa bản sao đã lưu trước khi di chuyển nó trở lại. `sh -n` bắt được các lỗi cú pháp mà không cần chạy tệp, nhưng không thể bắt được mọi lỗi xảy ra khi tệp được source. Hãy giữ một terminal đang hoạt động mở trong khi kiểm tra các thay đổi.

### Tại sao các lời nhắc ủy quyền 1Password cho 1Password SSH Agent / CLI của tôi không xuất hiện?

Điều này có thể xảy ra vì 2 lý do:

Để lời nhắc phê duyệt đầy đủ xuất hiện, Settings > Advanced > Use Hardware Acceleration phải được bật. _Lưu ý: Điều này đòi hỏi khởi động lại để bắt đầu hoạt động._

 ![troubleshooting-1password](images/troubleshooting-1password.webp)

Hoặc nếu bạn chưa khởi chạy 1Password kể từ khi khởi động máy, lời nhắc sẽ không xuất hiện.
