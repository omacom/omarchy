# Màn hình

Omarchy mặc định giả định bạn đang chạy trên một màn hình đẳng cấp retina có khả năng 2x. Đây là điều bạn cần để có được những font chữ lập trình đẹp, sắc nét. Hầu như tất cả laptop cao cấp mới với màn hình độ phân giải cao đều được tối ưu cho điều này. Đây là điều bạn sẽ muốn chạy trên một màn hình 27" 5K [Apple Studio Display](https://www.apple.com/studio-display/)/[ProArt PA27JCV](https://www.asus.com/us/displays-desktops/monitors/proart/proart-display-5k-pa27jcv/)/[Samsung S9](https://www.samsung.com/us/computing/monitors/5k/27-viewfinity-s9-5k-monitor-with-thunderbolt-4-matte-display-and-smart-features-ls27c900panxza/)/[Kuycon G27P](https://kuycon.us/monitors/G27P/) hoặc 32" 6K [Apple XDR](https://www.apple.com/pro-display-xdr/)/[ProArt PA32QCV](https://www.asus.com/displays-desktops/monitors/proart/proart-display-6k-pa32qcv/)/[Kuycon G32P](https://kuycon.us/monitors/G32P/).

Nhưng nếu bạn không chạy một màn hình có PPI từ 218 trở lên, bạn sẽ muốn thay đổi cài đặt màn hình. Ví dụ, nếu bạn có một màn hình 4K 27" hoặc 32", bạn có thể dùng fractional scaling bằng cách mở `~/.config/hypr/monitors.lua` (qua _Setup > Monitors_ trong menu Omarchy) và chuyển sang khuyến nghị cho tổ hợp đó:

```lua
local omarchy_gdk_scale = 2
local omarchy_monitor_scale = 1.6
```

Nếu bạn đang dùng màn hình 1080p hoặc 1440p, có lẽ bạn chỉ muốn dùng scaling 1x, nên bạn có thể dùng:

```lua
local omarchy_gdk_scale = 1
local omarchy_monitor_scale = 1
```

Các thay đổi đối với `GDK_SCALE` áp dụng cho các ứng dụng được khởi động sau thay đổi (và GTK chỉ tôn trọng số nguyên, vì vậy hãy giữ nó ở số nguyên gần nhất với tỉ lệ màn hình của bạn). Vì vậy hãy đảm bảo bạn thoát các cửa sổ đang quá khổ sau thay đổi (hoặc đóng tất cả cửa sổ bằng `Ctrl + Alt + Del`!).

Bạn cũng có thể nhanh chóng bước qua các tỉ lệ scaling màn hình chính (1x, 1.25x, 1.6x, 2x, 3x, 4x) bằng `Super + /` để lên cao hơn và `Super + Alt + /` để xuống thấp hơn, hoặc chọn một tỉ lệ từ bảng màn hình trên thanh trên cùng. Những thay đổi này chỉ thay đổi màn hình bạn đang tập trung vào, vì vậy màn hình laptop và màn hình ngoài mỗi cái có thể có tỉ lệ riêng. Lựa chọn được lưu vào `~/.config/hypr/monitors.lua` dưới dạng một quy tắc `hl.monitor` cho màn hình đó, vì vậy nó tồn tại qua lần khởi động lại và được ưu tiên hơn `omarchy_monitor_scale`, vốn vẫn là tỉ lệ cho mọi màn hình không có quy tắc riêng. Vì `GDK_SCALE` là một giá trị duy nhất cho tất cả màn hình, những thay đổi này đặt nó từ màn hình có tỉ lệ thấp nhất, vì vậy các ứng dụng X11 hiện ra hơi nhỏ trên màn hình dày đặc điểm ảnh hơn thay vì quá khổ trên màn hình còn lại.

### Làm cho văn bản lớn hơn hoặc nhỏ hơn

Scaling màn hình thay đổi kích thước của mọi thứ. Nếu tất cả những gì bạn muốn là _văn bản_ lớn hơn hoặc nhỏ hơn, có một núm điều chỉnh duy nhất cho việc đó:

```
omarchy display text size 14
```

Lệnh đó nhận một kích thước pixel từ 9 đến 20, và di chuyển shell Omarchy, các ứng dụng GTK, và terminal của bạn cùng nhau, vì vậy toàn bộ desktop giữ đúng tỉ lệ. Chạy nó không kèm đối số để xem bạn đang ở mức nào, và `omarchy display text size reset` để quay lại mặc định. Foot là kẻ lạc lõng duy nhất: nó không có cách nào để tải lại cấu hình của mình, vì vậy các terminal đang chạy giữ kích thước cũ cho đến khi bạn mở một terminal mới.

### Mở rộng và phản chiếu màn hình laptop

Khi bạn kết nối một màn hình ngoài với laptop, màn hình được tự động mở rộng. Nhưng bạn có thể thay đổi điều đó thành phản chiếu thay thế bằng _Trigger > Hardware_ trong menu Omarchy hoặc `Super + Ctrl + Alt + Delete`. Điều này đặc biệt hữu ích nếu màn hình ngoài đó là một máy chiếu, và bạn muốn trình chiếu thứ gì đó trong khi làm việc.

Khi bạn đang mở rộng, đóng nắp laptop sẽ tự động tắt màn hình trong. Mở nắp sẽ bật nó lại. Bạn cũng có thể điều khiển việc này thủ công bằng _Trigger > Hardware_ trong menu Omarchy hoặc `Super + Ctrl + Delete`.

### Sắp xếp nhiều màn hình

Hyprland hoạt động tuyệt vời với nhiều màn hình. Đọc thêm về cách bố trí chúng trong [tài liệu về màn hình của Hyprland](https://wiki.hypr.land/Configuring/Basics/Monitors/). Trong Omarchy, những thứ này nằm trong `~/.config/hypr/monitors.lua` dưới dạng các mục `hl.monitor` — tệp đi kèm với các ví dụ đã được chú thích để ghim một màn hình cụ thể vào một độ phân giải, vị trí, và hướng xoay.

Mỗi màn hình có các workspace từ 1 đến 10 của riêng nó, vì vậy `Super + 1` luôn có nghĩa là workspace đầu tiên của màn hình bạn đang ở. Đằng sau hậu trường, Hyprland vẫn đánh số các workspace trên tất cả màn hình: màn hình laptop của bạn (hoặc màn hình đầu tiên) nhận 1–10, màn hình tiếp theo 11–20, và cứ thế, và mỗi màn hình giữ khối của nó mỗi lần bạn cắm vào. Hãy dùng những con số đó nếu bạn viết [quy tắc workspace](https://wiki.hypr.land/Configuring/Basics/Workspace-Rules/) hoặc quy tắc cửa sổ cho một màn hình cụ thể, vì vậy workspace 12 là workspace thứ hai của màn hình thứ hai của bạn. `~/.local/state/omarchy/monitor-workspaces` liệt kê khối mà mỗi màn hình có.

Các phím mũi tên hoạt động qua các màn hình có chung một cạnh trong bố cục của bạn. Các màn hình chỉ chạm nhau ở một góc, hoặc có khoảng cách giữa chúng, không phải là hàng xóm, vì vậy hãy dùng `Ctrl + Alt + Tab` để di chuyển giữa chúng.

| Phím tắt | Qua các màn hình |
| --- | --- |
| `Super + Arrow` | Di chuyển tiêu điểm đến màn hình ở phía đó khi không còn cửa sổ nào theo hướng đó |
| `Super + Shift + Arrow` | Hoán đổi với một cửa sổ trên màn hình ở phía đó |
| `Super + Alt + Arrow` | Di chuyển cửa sổ vào một nhóm trên màn hình ở phía đó |
| `Super + Shift + Ctrl + Arrow` | Di chuyển cửa sổ đến màn hình ở phía đó, vào workspace mà nó đang hiển thị |
| `Super + Shift + Alt + Arrow` | Di chuyển workspace đến màn hình ở phía đó, giữ số của nó nếu nó còn trống |
| `Ctrl + Alt + Tab` / `Ctrl + Alt + Shift + Tab` | Di chuyển tiêu điểm đến màn hình tiếp theo hoặc trước đó, bất kể bố cục |
| `Super + 1-0`, `Super + Tab`, `Super + Scroll Wheel` | Ở lại trên màn hình bạn đang ở |

Bạn cũng có thể xem qua [Hyprmon](https://github.com/erans/hyprmon/), nếu bạn muốn một TUI giúp bạn định vị nhiều màn hình.

### Điều khiển độ sáng

Độ sáng màn hình được điều khiển bằng các phím chức năng chuyên dụng cho tăng/giảm độ sáng. Nếu bạn giữ shift trong khi nhấn các phím này, bạn sẽ đến độ sáng tối đa hoặc tối thiểu. Các phím điều khiển màn hình bạn đang tập trung vào, vì vậy các màn hình ngoài nói DDC/CI được điều chỉnh giống như màn hình laptop.

### Màn hình Apple

Nếu bạn đang dùng một màn hình Apple, các phím độ sáng bàn phím thông thường cũng sẽ tự động hoạt động, nếu bạn đang tập trung vào màn hình Apple. Điều này được thực hiện thông qua lệnh `asdcontrol`.

Lưu ý rằng nếu bạn đang dùng màn hình Apple 6K XDR, bạn có thể thấy một màn hình ma trong danh sách `hyprctl monitors` của mình. Bạn có thể tắt điều này bằng thứ gì đó như `hl.monitor({ output = "DP-2", disabled = true })` qua _Setup > Monitors_.

Trên các máy Intel, bạn nên kết nối với màn hình Apple bằng cáp Thunderbolt thông thường. Trên các máy khác không có Thunderbolt, bạn thường sẽ phải dùng [DP + USB-A -> USB-C cable](https://www.amazon.com/dp/B0BNX7MS6N) để làm cho nó hoạt động.
