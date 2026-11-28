# Các tinh chỉnh phổ biến

Đây là một tuyển tập các tùy biến thường gặp cho thiết lập Omarchy. Nên biết rằng đôi khi các bản cập nhật hệ thống có thể cần khôi phục một số cấu hình về trạng thái ban đầu. Nếu điều đó xảy ra, các thay đổi của bạn sẽ không bị mất, mà được đặt vào một tệp `.bak.<timestamp>` bên cạnh tệp gốc.

Nếu bạn làm hỏng thứ gì đó, bạn có thể khôi phục từng cấu hình riêng lẻ về thiết lập ban đầu của chúng thông qua _Update > Config_ trong menu Omarchy. Nếu bạn _thực sự_ làm hỏng mọi thứ, bạn có thể đặt lại tất cả các cấu hình bằng `omarchy reinstall configs`, hoặc cài đặt lại mọi gói và cấu hình mặc định bằng `omarchy reinstall`.

### Luôn hiển thị tất cả các biểu tượng trên khay

Theo mặc định, các biểu tượng trên khay, như Dropbox, 1password hoặc Steam, được ẩn sau mũi tên mở rộng khay, mũi tên này sẽ hiển thị chúng khi bạn di chuột lên nó. Nếu bạn muốn chúng luôn hiển thị, hãy nhấp chuột phải vào mũi tên mở rộng để mở trình quản lý biểu tượng khay, sau đó ghim các biểu tượng mà bạn muốn giữ hiển thị (bạn cũng có thể ẩn những biểu tượng mà bạn không bao giờ muốn thấy).

### Các góc cửa sổ bo tròn

Thiết kế mặc định của Omarchy là các góc vuông, nhưng nếu bạn muốn làm mềm điều đó đi một chút, hãy chọn _Appearance > Windows > Window Corners > Rounded Corners_ trong menu Omarchy, hoặc chạy `omarchy hyprland corners rounded`. _Theme Corners_ quay trở lại bất kỳ kiểu nào mà chủ đề sử dụng. Để chọn bán kính của riêng bạn, hãy giữ nguyên _Theme Corners_ (`omarchy hyprland corners theme`), vì Rounded và Sharp tải sau cấu hình của bạn và ghi đè lên nó, đồng thời bỏ chú thích cho phần rounding trong `~/.config/hypr/looknfeel.lua`:

```
hl.config({
  decoration = {
    -- Use round window corners.
    rounding = 8,
  },
})
```

### Loại bỏ khoảng trống giữa các cửa sổ

Trên các màn hình laptop, một số người thích không lãng phí bất kỳ pixel nào cho các khoảng trống giữa các cửa sổ (hoặc thậm chí cho thanh trên cùng, thanh mà bạn có thể bật/tắt bằng `Super + Shift + Space`). Bạn có thể bật/tắt tất cả các khoảng trống và đường viền bằng `Super + Shift + Backspace`, hoặc loại bỏ chúng vĩnh viễn bằng cách loại bỏ các chú thích trong phần này của `~/.config/hypr/looknfeel.lua`:

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
