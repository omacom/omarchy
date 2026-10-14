# FAQ

### Làm thế nào để chuyển đổi giữa các bố cục bàn phím?

Sửa tệp `~/.config/hypr/input.lua` của bạn và thêm đoạn này để chuyển đổi giữa các bố cục bằng `Left Alt + Right Alt`:

```
hl.config({
  input = {
    -- Use multiple keyboard layouts and switch between them with Left Alt + Right Alt
    kb_layout = "us,fr",
    kb_options = "omarchy:shift_caps_compose,grp:alts_toggle",
  },
})
```

Thanh sẽ tự động hiển thị bố cục bàn phím hiện tại của bạn một khi bạn đã cấu hình nhiều bố cục (và bạn cũng có thể nhấp vào nó để chuyển đổi).

### Làm thế nào để đổi định dạng đồng hồ thành 12 giờ?

Nhấp chuột phải vào đồng hồ trên thanh để duyệt qua các định dạng phổ biến, bao gồm cả các định dạng 12 giờ. Bạn cũng có thể đặt định dạng trực tiếp:

```
omarchy bar set omarchy.clock format "dddd h:mm AP"
```

Việc này sẽ hiển thị Sunday 10:55 AM.

### Làm thế nào để đổi múi giờ của tôi?

Chạy _Cập nhật > Múi giờ_ trong menu Omarchy và chọn từ danh sách. Nếu múi giờ đúng nhưng chính đồng hồ đã bị lệch, _Cập nhật > Thời gian_ sẽ khởi động lại việc đồng bộ thời gian cho bạn.

### Làm thế nào để đổi DNS, chia sẻ Wi-Fi hoặc kiểm tra tốc độ kết nối của tôi?

Tất cả những thứ đó đều nằm trong [mạng](35-networking.md).

### Làm thế nào để kiểm tra đĩa của tôi nhanh đến mức nào?

_Kích hoạt > Kiểm tra tốc độ > Kiểm tra tốc độ đĩa_ đo tốc độ đọc và ghi trực tiếp trên ổ đĩa của bạn, hoặc `omarchy disk speedtest` từ terminal.

### Tại sao tôi không thể đăng nhập vào tài khoản Google của mình trong Chromium?

Bản dựng Chromium mã nguồn mở thuần túy không đi kèm thông tin xác thực OAuth mà Google yêu cầu để đăng nhập tài khoản. Chạy _Cài đặt > Dịch vụ > Tài khoản Chromium_ trong menu Omarchy để thêm chúng, khởi động lại trình duyệt, và việc đăng nhập sẽ thành công.

### Làm thế nào để thêm một máy in?

In ấn đã được thiết lập và chạy ngay khi cài đặt, và bạn tự thêm từng máy in từ _Print Settings_ trong trình mở ứng dụng (`Super + Space`).

Chọn _Add_, và cho nó một chút thời gian để tìm kiếm: một máy in cắm qua USB, và hầu hết các máy in mạng, đều được tìm thấy cho bạn. Nếu máy in của bạn không có trong danh sách, hãy chọn _Network Printer > Internet Printing Protocol (ipp)_ và nhập địa chỉ của nó — màn hình của chính máy in hoặc trang web của nó sẽ cho bạn biết địa chỉ đó là gì, thường là thứ gì đó như `192.168.1.50` với hàng đợi `ipp/print`. _Forward_ sau đó sẽ đề xuất một trình điều khiển, nơi một máy in hiện đại hoạt động tốt nhất trên cấu hình không cần trình điều khiển _IPP Everywhere_ và một máy in cũ hơn muốn trình điều khiển của chính mẫu máy.

Nhấp chuột phải vào một máy in và chọn _Set as Default_ để chọn máy in mà các ứng dụng của bạn tìm đến đầu tiên, và _Properties_ để đặt kích thước giấy, in hai mặt và chất lượng.

Việc tự động phát hiện, nơi các máy in trên mạng xuất hiện mà không cần được thêm vào, tạm thời bị tắt trong khi nó đang được làm lại, đó là lý do bước đầu tiên ở trên là của bạn chứ không phải tự động. In ra một tệp PDF hoạt động mà không cần bất kỳ máy in nào cả.

### Làm thế nào để đổi nơi lưu ảnh chụp màn hình hoặc bản ghi màn hình?

Ảnh chụp màn hình đã lưu đi tới `~/Pictures/Screenshots` theo mặc định. Để dùng một thư mục khác, hãy thêm đoạn này vào một tệp dưới `~/.config/uwsm/env.d/` (như `~/.config/uwsm/env.d/capture`):

```
export OMASNAP_SCREENSHOT_DIR="$HOME/Pictures/Captures"
```

Bạn có thể làm tương tự cho các bản ghi màn hình bằng `OMARCHY_SCREENRECORD_DIR`.

Omasnap tự động tạo thư mục ảnh chụp màn hình của nó. Hãy tự tạo thư mục ghi màn hình, rồi khởi động lại Omarchy để bất kỳ thay đổi môi trường nào cũng có hiệu lực.

### Làm thế nào để loa + webcam hoạt động trên Apple Studio Display của tôi?

Bạn sẽ nghĩ rằng mọi thứ chỉ cần cắm USB C vào là hoạt động, nhưng tiếc là không phải vậy. Giải pháp tôi tìm thấy để làm nó hoạt động ổn định là dùng [cáp WJESOG DisplayPort + USB-A => USB-C](https://www.amazon.com/WJESOG-DisplayPort-Adapter-Converter-Thunderbolt/dp/B0BNX7MS6N/). Sau đó loa và webcam hoạt động hoàn hảo.

Hãy nhớ rằng bạn có điều khiển độ sáng tích hợp sẵn trong Omarchy cho các Màn hình Apple (cả Studio và XDR) bằng các nút độ sáng bàn phím thông thường.

### Làm thế nào để loại bỏ mọi phần mềm bổ sung?

Nếu bạn không muốn các chương trình như Obsidian hoặc LibreOffice hoặc bất kỳ thứ gì cài sẵn khác, bạn có thể loại bỏ chúng rất dễ dàng.

Chạy _Gỡ bỏ > Gói_ để xem mọi gói đã được cài đặt. Sau đó bạn có thể chọn bất kỳ gói nào bạn muốn gỡ bỏ bằng tab, và bắt đầu gỡ bỏ mọi thứ bạn đã chọn bằng return.

Và bạn có thể dùng _Gỡ bỏ > Ứng dụng web_ từ menu Omarchy để gỡ bỏ bất kỳ ứng dụng web cài sẵn nào bạn không muốn.

Hoặc chạy _Gỡ bỏ > Cài sẵn_ để quét sạch mọi thứ bổ sung đã cài sẵn — ứng dụng web, TUI và các ứng dụng tùy chọn — trong một lần. Các phím tắt đã mở chúng sẽ biến mất cùng với chúng, vậy là bạn còn lại một bảng gán phím sạch để lấp đầy bằng phím của riêng mình trong `~/.config/hypr/bindings.lua`.

---

Đối với lỗi và các phần bị hỏng, hãy xem [phần Khắc phục sự cố](45-troubleshooting.md).
