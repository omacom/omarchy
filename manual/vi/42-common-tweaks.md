# Các tinh chỉnh phổ biến

Đây là một bộ sưu tập các tùy chỉnh phổ biến cho thiết lập Omarchy. Hãy biết rằng đôi khi các bản cập nhật hệ thống có thể cần khôi phục một số cấu hình nhất định về trạng thái gốc của chúng. Nếu điều này xảy ra, các thay đổi của bạn sẽ không bị mất, mà được đặt vào một tệp `.bak` trong cùng thư mục.

Nếu bạn làm hỏng thứ gì đó, bạn có thể khôi phục từng cấu hình riêng lẻ về thiết lập gốc của chúng qua _Cập nhật > Cấu hình_ trong menu Omarchy. Nếu bạn _thực sự_ làm hỏng mọi thứ, bạn có thể đặt lại mọi cấu hình qua `omarchy-reinstall`.

### Luôn hiện mọi biểu tượng khay hệ thống

Theo mặc định, các biểu tượng khay hệ thống, như Dropbox, 1password hoặc Steam, bị ẩn sau mũi tên mở rộng khay, mũi tên này sẽ hiện chúng khi bạn di chuột lên. Nếu bạn muốn chúng luôn lộ ra, hãy nhấp chuột phải vào mũi tên mở rộng để mở trình quản lý biểu tượng khay, rồi ghim các biểu tượng bạn muốn giữ luôn hiển thị (bạn cũng có thể ẩn những biểu tượng bạn không bao giờ muốn thấy).

### Góc cửa sổ bo tròn

Thiết kế mặc định của Omarchy là các góc vuông, nhưng nếu bạn thích làm mềm điều đó một chút, bạn có thể thay đổi `~/.config/hypr/looknfeel.lua` để rounding không còn bị chú thích tắt nữa:

```
hl.config({
  decoration = {
    -- Use round window corners.
    rounding = 8,
  },
})
```

### Loại bỏ khoảng cách cửa sổ

Trên màn hình laptop, một số người thích không lãng phí bất kỳ pixel nào cho khoảng cách cửa sổ (hoặc thậm chí một thanh trên cùng, thứ bạn có thể tắt bằng `Super + Shift + Space`). Bạn có thể tắt mọi khoảng cách và viền bằng `Super + Shift + Backspace`, hoặc loại bỏ chúng vĩnh viễn bằng cách xóa các chú thích trong phần này của `~/.config/hypr/looknfeel.lua`:

```
hl.config({
  general = {
    -- No gaps between windows or borders.
    gaps_in = 0,
    gaps_out = 0,
    border_size = 0,
  },
})
```
