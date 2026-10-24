# Màn hình

Omarchy giả định theo mặc định bạn đang chạy trên một màn hình cấp retina có khả năng 2x. Đây là điều bạn cần để có những phông chữ lập trình viên đẹp, sắc nét. Đây là điều mà hầu hết các máy tính xách tay cao cấp mới với màn hình độ phân giải cao đều được tối ưu hóa cho. Đây là điều bạn muốn chạy trên một màn hình 27" 5K [Apple Studio Display](https://www.apple.com/studio-display/)/[ProArt PA27JCV](https://www.asus.com/us/displays-desktops/monitors/proart/proart-display-5k-pa27jcv/)/[Samsung S9](https://www.samsung.com/us/computing/monitors/5k/27-viewfinity-s9-5k-monitor-with-thunderbolt-4-matte-display-and-smart-features-ls27c900panxza/)/[Kuycon G27P](https://kuycon.us/monitors/G27P/) hoặc 32" 6K [Apple XDR](https://www.apple.com/pro-display-xdr/)/[ProArt PA32QCV](https://www.asus.com/displays-desktops/monitors/proart/proart-display-6k-pa32qcv/)/[Kuycon G32P](https://kuycon.us/monitors/G32P/).

Nhưng nếu bạn không chạy một màn hình với PPI từ 218 trở lên, bạn sẽ muốn thay đổi cài đặt màn hình. Ví dụ, nếu bạn có một màn hình 27" hoặc 32" 4K, bạn có thể dùng chia tỷ lệ phân đoạn bằng cách mở `~/.config/hypr/monitors.lua` (qua _Thiết lập > Màn hình_ trong menu Omarchy) và chuyển sang khuyến nghị cho sự kết hợp đó:

```lua
local omarchy_gdk_scale = 2
local omarchy_monitor_scale = 1.6
```

Nếu bạn đang dùng một màn hình 1080p hoặc 1440p, bạn có thể chỉ muốn dùng chia tỷ lệ 1x, vì vậy bạn có thể dùng:

```lua
local omarchy_gdk_scale = 1
local omarchy_monitor_scale = 1
```

Các thay đổi đối với `GDK_SCALE` áp dụng cho các ứng dụng được khởi động sau thay đổi (và GTK chỉ tôn trọng các số nguyên, vì vậy hãy giữ nó ở số nguyên gần nhất với tỷ lệ màn hình của bạn). Vì vậy hãy chắc chắn rằng bạn thoát các cửa sổ bị quá khổ sau thay đổi (hoặc đóng mọi cửa sổ bằng `Ctrl + Alt + Del`!).

Bạn cũng có thể nhanh chóng bước qua các tỷ lệ chia tỷ lệ màn hình chính (1x, 1.25x, 1.6x, 2x, 3x, 4x) bằng `Super + /` để tăng lên và `Super + Alt + /` để giảm xuống. Nếu bạn có cấu hình mặc định, những thay đổi này cũng sẽ duy trì qua lần khởi động lại.

### Làm cho văn bản lớn hơn hoặc nhỏ hơn

Chia tỷ lệ màn hình thay đổi kích thước của mọi thứ. Nếu tất cả những gì bạn muốn là _văn bản_ lớn hơn hoặc nhỏ hơn, có một núm duy nhất cho điều đó:

```
omarchy display text size 14
```

Lệnh đó nhận một kích thước pixel trong khoảng từ 9 đến 20, và di chuyển shell của Omarchy, các ứng dụng GTK và terminal của bạn cùng nhau, để toàn bộ màn hình nền giữ nguyên tỷ lệ. Chạy nó mà không có đối số để xem bạn đang ở đâu, và `omarchy display text size reset` để quay về mặc định. Foot là kẻ tụt hậu duy nhất: nó không có cách nào để tải lại cấu hình của nó, vì vậy các terminal đang chạy giữ nguyên kích thước cũ cho đến khi bạn mở một cái mới.

### Mở rộng và phản chiếu màn hình máy tính xách tay

Khi bạn kết nối một màn hình ngoài với máy tính xách tay của mình, màn hình sẽ tự động được mở rộng. Nhưng bạn có thể thay đổi điều đó thành phản chiếu thay thế bằng _Kích hoạt > Phần cứng_ trong menu Omarchy hoặc `Super + Ctrl + Alt + Delete`. Điều này đặc biệt hữu ích nếu màn hình ngoài đó là một máy chiếu, và bạn muốn hiển thị thứ gì đó trong khi làm việc.

Khi bạn đang mở rộng, việc đóng nắp máy tính xách tay sẽ tự động tắt màn hình trong. Mở nắp sẽ bật nó trở lại. Bạn cũng có thể kiểm soát điều này thủ công bằng _Kích hoạt > Phần cứng_ trong menu Omarchy hoặc `Super + Ctrl + Delete`.

### Sắp xếp nhiều màn hình

Hyprland hoạt động tuyệt vời với nhiều màn hình. Đọc thêm về cách sắp xếp chúng trong [tài liệu về màn hình của Hyprland](https://wiki.hypr.land/Configuring/Basics/Monitors/). Bạn cũng có thể [ràng buộc các workspace cụ thể với các màn hình cụ thể](https://wiki.hypr.land/Configuring/Basics/Workspace-Rules/). Trong Omarchy, các quy tắc này nằm trong `~/.config/hypr/monitors.lua` dưới dạng các mục `hl.monitor` — tệp được giao kèm với các ví dụ đã được chú thích để ghim một màn hình cụ thể vào một độ phân giải, vị trí và góc xoay.

Bạn cũng có thể tham khảo [Hyprmon](https://github.com/erans/hyprmon/), nếu bạn muốn một TUI giúp bạn định vị nhiều màn hình.

### Điều khiển độ sáng

Độ sáng màn hình được điều khiển bằng các phím chức năng chuyên dụng cho độ sáng tăng/giảm. Nếu bạn giữ shift trong khi nhấn các phím này, bạn sẽ đi đến độ sáng tối đa hoặc tối thiểu. Các phím điều khiển màn hình bạn đang tập trung vào, vì vậy các màn hình ngoài sử dụng DDC/CI được điều chỉnh theo cùng cách như màn hình máy tính xách tay.

### Màn hình Apple

Nếu bạn đang dùng một màn hình Apple, các phím độ sáng bàn phím thông thường cũng sẽ tự động hoạt động, nếu bạn đang tập trung vào màn hình Apple. Điều này được thực hiện thông qua lệnh `asdcontrol`.

Lưu ý rằng nếu bạn đang dùng một màn hình Apple 6K XDR, bạn có thể thấy một màn hình ảo trong danh sách `hyprctl monitors` của mình. Bạn có thể tắt nó bằng thứ gì đó như `hl.monitor({ output = "DP-2", disabled = true })` qua _Thiết lập > Màn hình_.

Trên các máy Intel, bạn nên kết nối với các màn hình Apple bằng một cáp Thunderbolt thông thường. Trên các máy khác không có Thunderbolt, bạn thường sẽ phải dùng một [cáp DP + USB-A -> USB-C](https://www.amazon.com/dp/B0BNX7MS6N) để làm cho nó hoạt động.
