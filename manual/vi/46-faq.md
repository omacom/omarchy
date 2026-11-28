# FAQ

### Làm thế nào để chuyển đổi giữa các bố cục bàn phím?

Chỉnh sửa tệp `~/.config/hypr/input.lua` của bạn và thêm đoạn này để chuyển đổi giữa các bố cục bằng `Left Alt + Right Alt`:

```
hl.config({
  input = {
    -- Use multiple keyboard layouts and switch between them with Left Alt + Right Alt
    kb_layout = "us,fr",
    kb_options = "omarchy:shift_caps_compose,grp:alts_toggle",
  },
})
```

Thanh bar sẽ tự động hiển thị bố cục bàn phím hiện tại của bạn khi bạn đã cấu hình nhiều bố cục (và bạn cũng có thể nhấp vào đó để chuyển đổi).

### Làm thế nào để đổi định dạng đồng hồ sang 12 giờ?

Nhấp chuột phải vào đồng hồ trên thanh bar để lần lượt chuyển qua các định dạng phổ biến, bao gồm cả các định dạng 12 giờ. Bạn cũng có thể đặt định dạng trực tiếp:

```
omarchy bar set omarchy.clock format "dddd h:mm AP"
```

Thao tác này sẽ hiển thị Chủ Nhật 10:55 AM.

### Làm thế nào để đổi múi giờ của tôi?

Chạy _Setup > Region > Timezone_ trong menu Omarchy và chọn từ danh sách. Nếu múi giờ đã đúng nhưng chính đồng hồ bị lệch, _Update > Time_ sẽ khởi động lại việc đồng bộ hóa thời gian cho bạn.

### Làm thế nào để thay đổi DNS, chia sẻ Wi-Fi, hoặc kiểm tra tốc độ kết nối của tôi?

Tất cả những thứ đó đều nằm trong [kết nối mạng](35-networking.md).

### Làm thế nào để kiểm tra tốc độ ổ đĩa của tôi?

_Trigger > Speed Test > Disk Speed Test_ đo tốc độ đọc và ghi trực tiếp trên ổ đĩa của bạn, hoặc `omarchy disk speedtest` từ terminal.

### Làm thế nào để thêm một máy in?

Việc in ấn đã được thiết lập và sẵn sàng hoạt động ngay từ đầu, và bạn tự thêm từng máy in từ _Print Settings_ trong trình khởi chạy ứng dụng (`Super + Alt + Space`).

Chọn _Add_, và chờ một lát để nó tìm kiếm: một máy in được cắm qua USB, và hầu hết các máy in mạng, đều được tìm thấy cho bạn. Nếu máy in của bạn không có trong danh sách, hãy chọn _Network Printer > Internet Printing Protocol (ipp)_ và nhập địa chỉ của nó — màn hình của chính máy in hoặc trang web của nó sẽ cho bạn biết đó là gì, thường là dạng như `192.168.1.50` với một hàng đợi là `ipp/print`. _Forward_ sau đó sẽ đề xuất một driver, trong đó một máy in hiện đại hoạt động tốt nhất với hồ sơ không cần driver _IPP Everywhere_ và một máy in cũ hơn thì muốn driver riêng của model đó.

Nhấp chuột phải vào một máy in và chọn _Set as Default_ để chọn máy in mà các ứng dụng của bạn sẽ tìm đến đầu tiên, và _Properties_ để đặt kích thước giấy, in hai mặt và chất lượng.

Tính năng tự động phát hiện, nơi các máy in trên mạng xuất hiện mà không cần được thêm vào, tạm thời bị tắt trong khi đang được làm lại, đó là lý do vì sao bước đầu tiên ở trên là việc của bạn thay vì tự động. In ra một tệp PDF hoạt động mà không cần bất kỳ máy in nào cả.

### Làm thế nào để thay đổi nơi lưu ảnh chụp màn hình hoặc bản ghi màn hình?

Ảnh chụp màn hình đã lưu mặc định đi tới `~/Pictures/Screenshots`. Để dùng một thư mục khác, hãy thêm đoạn này vào một tệp dưới `~/.config/uwsm/env.d/` (như `~/.config/uwsm/env.d/capture`):

```
export OMASNAP_SCREENSHOT_DIR="$HOME/Pictures/Captures"
```

Bạn có thể làm tương tự cho các bản ghi màn hình bằng cách dùng `OMARCHY_SCREENRECORD_DIR`.

Omasnap tự động tạo thư mục ảnh chụp màn hình của nó. Hãy tự tạo thư mục ghi màn hình, sau đó khởi động lại Omarchy để một trong hai thay đổi môi trường có hiệu lực.

### Làm thế nào để loa + webcam hoạt động trên Apple Studio Display của tôi?

Bạn sẽ nghĩ rằng tất cả chỉ cần cắm USB C vào là hoạt động, nhưng tiếc là không phải vậy. Giải pháp tôi đã tìm ra để khiến nó hoạt động một cách đáng tin cậy là dùng [cáp WJESOG DisplayPort + USB-A => USB-C](https://www.amazon.com/WJESOG-DisplayPort-Adapter-Converter-Thunderbolt/dp/B0BNX7MS6N/). Sau đó loa và webcam hoạt động ngon lành.

Hãy nhớ rằng bạn có tính năng điều khiển độ sáng tích hợp sẵn trong Omarchy cho các màn hình Apple (cả Studio và XDR) bằng các nút độ sáng bàn phím thông thường.

### Làm thế nào để loại bỏ tất cả phần mềm thừa?

Nếu bạn không muốn các chương trình như Obsidian hay LibreOffice hay bất kỳ thứ gì khác được cài sẵn, bạn có thể loại bỏ chúng rất dễ dàng.

Chạy _Remove > Package_ để xem mọi gói đã được cài đặt. Sau đó bạn có thể chọn bất kỳ gói nào bạn muốn loại bỏ bằng tab, và bắt đầu loại bỏ mọi thứ bạn đã chọn bằng return.

Và bạn có thể dùng _Remove > Web App_ từ menu Omarchy để loại bỏ bất kỳ ứng dụng web được cài sẵn nào bạn không muốn.

Hoặc chạy _Remove > Preinstalls_ để quét sạch tất cả các phần bổ sung được cài sẵn — các ứng dụng web, các TUI, và các ứng dụng tùy chọn — trong một lần. Các phím tắt đã khởi chạy chúng sẽ biến mất cùng với chúng, vì vậy bạn sẽ còn lại một bảng phím tắt sạch sẽ để điền các phím tắt của riêng bạn vào trong `~/.config/hypr/bindings.lua`.

---

Đối với các lỗi và những phần bị hỏng, hãy xem [phần Khắc phục sự cố](45-troubleshooting.md).
