# Màn hình

Omarchy mặc định giả định bạn đang dùng một màn hình retina-class có khả năng 2x. Đó là thứ bạn cần để có những font chữ lập trình đẹp, sắc nét. Đó là thứ mà gần như mọi laptop cao cấp mới với màn hình độ phân giải cao đều được tối ưu cho. Đó là thứ bạn sẽ muốn chạy trên một màn hình 27" 5K [Apple Studio Display](https://www.apple.com/studio-display/)/[ProArt PA27JCV](https://www.asus.com/us/displays-desktops/monitors/proart/proart-display-5k-pa27jcv/)/[Samsung S9](https://www.samsung.com/us/computing/monitors/5k/27-viewfinity-s9-5k-monitor-with-thunderbolt-4-matte-display-and-smart-features-ls27c900panxza/)/[Kuycon G27P](https://kuycon.us/monitors/G27P/) hoặc 32" 6K [Apple XDR](https://www.apple.com/pro-display-xdr/)/[ProArt PA32QCV](https://www.asus.com/displays-desktops/monitors/proart/proart-display-6k-pa32qcv/)/[Kuycon G32P](https://kuycon.us/monitors/G32P/).

Nhưng nếu bạn không dùng một màn hình có PPI từ 218 trở lên, bạn sẽ muốn thay đổi cài đặt màn hình. Ví dụ, nếu bạn có một màn hình 4K 27" hoặc 32", bạn có thể chọn một tỷ lệ scale phân đoạn cho nó từ bảng màn hình trên thanh trên cùng, hoặc đặt mặc định cho mọi màn hình bằng cách mở `~/.config/hypr/monitors.lua` và chuyển sang khuyến nghị cho combo đó:

```lua
hl.monitor({ output = "", mode = "preferred", position = "auto", scale = 1.6 })
```

Nếu bạn đang dùng một màn hình 1080p hoặc 1440p, có lẽ bạn sẽ chỉ muốn dùng scaling 1x, và tương tự cho các ứng dụng GTK và X11, vì vậy bạn có thể dùng:

```lua
hl.monitor({ output = "", mode = "preferred", position = "auto", scale = 1 })
hl.env("GDK_SCALE", "1")
```

Các thay đổi đối với `GDK_SCALE` áp dụng cho các ứng dụng được khởi động sau thay đổi (và GTK chỉ chấp nhận số nguyên, vì vậy hãy giữ nó ở số nguyên gần nhất với tỷ lệ scale màn hình của bạn). Vì vậy hãy đảm bảo bạn thoát các cửa sổ đang quá khổ mà bạn có sau thay đổi (hoặc đóng mọi cửa sổ bằng `Ctrl + Alt + Del`!).

Bạn cũng có thể nhanh chóng bước qua các tỷ lệ scale màn hình chính (1x, 1.25x, 1.6x, 2x, 3x, 4x) bằng `Super + /` để lên cao hơn và `Super + Alt + /` để xuống thấp hơn, hoặc chọn một tỷ lệ từ bảng màn hình trên thanh trên cùng. Những thay đổi này chỉ thay đổi màn hình bạn đang focus, vì vậy màn hình laptop và màn hình ngoài mỗi cái có thể có tỷ lệ scale riêng. Bảng này cũng đặt độ phân giải, tần số quét và hướng xoay của mỗi màn hình. Các lựa chọn của bạn được lưu cho màn hình vật lý đó trong `~/.local/state/omarchy/monitors/settings`, vì vậy chúng tồn tại qua lần khởi động lại và đi theo màn hình tới bất kỳ cổng hoặc dock nào nó được cắm vào tiếp theo. Chúng được ưu tiên hơn bất kỳ quy tắc nào cho cùng màn hình trong `~/.config/hypr/monitors.lua`, file mà Omarchy không bao giờ chỉnh sửa. Nếu bạn muốn đặt màn hình của mình hoàn toàn trong file đó, hãy thêm `omarchy_monitor_panel_settings = false` vào đó, và các thay đổi của bảng sẽ chỉ kéo dài cho đến khi Hyprland tải lại. Vì `GDK_SCALE` là một giá trị duy nhất cho mọi màn hình, một tỷ lệ scale đã chọn sẽ đặt nó từ màn hình có tỷ lệ scale thấp nhất, vì vậy các ứng dụng X11 sẽ hơi nhỏ trên màn hình dày đặc hơn thay vì quá khổ trên màn hình còn lại.

### Làm chữ lớn hơn hoặc nhỏ hơn

Việc scale màn hình thay đổi kích thước của mọi thứ. Nếu tất cả những gì bạn muốn là _chữ_ lớn hơn hoặc nhỏ hơn, chỉ có một núm chỉnh duy nhất cho việc đó:

```
omarchy display text size 14
```

Lệnh đó nhận một kích thước pixel từ 9 đến 20, và di chuyển Omarchy shell, các ứng dụng GTK, và terminal của bạn cùng nhau, vì vậy toàn bộ desktop giữ đúng tỷ lệ. Chạy nó mà không có đối số để xem bạn đang ở mức nào, và `omarchy display text size reset` để quay về mặc định. Foot là kẻ chậm chân duy nhất: nó không có cách nào để tải lại cấu hình của nó, vì vậy các terminal đang chạy giữ nguyên kích thước cũ cho đến khi bạn mở một terminal mới.

### Mở rộng và phản chiếu màn hình laptop

Khi bạn kết nối một màn hình ngoài với laptop của mình, màn hình sẽ tự động được mở rộng. Nhưng bạn có thể thay đổi điều đó thành phản chiếu thay vào đó bằng _Trigger > Hardware_ trong menu Omarchy hoặc `Super + Ctrl + Alt + Delete`. Điều này đặc biệt hữu ích nếu màn hình ngoài đó là một máy chiếu, và bạn muốn trình chiếu thứ gì đó trong lúc làm việc.

Khi bạn đang mở rộng, việc gập nắp laptop sẽ tự động tắt màn hình trong. Việc mở nắp sẽ bật nó trở lại. Bạn cũng có thể điều khiển việc này thủ công bằng _Trigger > Hardware_ trong menu Omarchy hoặc `Super + Ctrl + Delete`.

### Sắp xếp nhiều màn hình

Hyprland hoạt động tuyệt vời với nhiều màn hình. Bảng màn hình trên thanh trên cùng vẽ chúng ở đúng vị trí chúng đang ngồi: kéo một màn hình vào cạnh của một màn hình khác để di chuyển nó tới đó, và cách sắp xếp được lưu cùng với các cài đặt khác của mỗi màn hình. Đối với bất cứ thứ gì bảng này không bao quát, hãy đọc thêm về cách bố trí chúng trong [tài liệu màn hình của Hyprland](https://wiki.hypr.land/Configuring/Basics/Monitors/). Trong Omarchy, những thứ này nằm trong `~/.config/hypr/monitors.lua` dưới dạng các mục `hl.monitor` — file đi kèm với các ví dụ đã được comment cho việc giữ một màn hình tắt, các chế độ mà bảng này không cung cấp, màu 10-bit, và tần số quét biến thiên.

Mỗi màn hình có các workspace 1 đến 10 của riêng nó, vì vậy `Super + 1` luôn có nghĩa là workspace đầu tiên của màn hình bạn đang ở. Đằng sau hậu trường, Hyprland vẫn đánh số các workspace trên tất cả các màn hình: màn hình laptop của bạn (hoặc màn hình đầu tiên) nhận 1–10, màn hình tiếp theo 11–20, và cứ thế, và mỗi màn hình giữ khối của nó mỗi lần bạn cắm nó vào. Hãy dùng những con số đó nếu bạn viết [quy tắc workspace](https://wiki.hypr.land/Configuring/Basics/Workspace-Rules/) hoặc quy tắc cửa sổ cho một màn hình cụ thể, vì vậy workspace 12 là workspace thứ hai của màn hình thứ hai của bạn. `~/.local/state/omarchy/monitors/workspaces` liệt kê khối nào mỗi màn hình có.

Các phím mũi tên hoạt động qua các màn hình có chung một cạnh trong bố cục của bạn. Các màn hình chỉ chạm nhau ở một góc, hoặc có một khoảng trống giữa chúng, không phải là hàng xóm, vì vậy hãy dùng `Ctrl + Alt + Tab` để di chuyển giữa chúng.

| Phím tắt | Qua các màn hình |
| --- | --- |
| `Super + Arrow` | Di chuyển focus tới màn hình ở phía đó khi không còn cửa sổ nào theo hướng đó |
| `Super + Shift + Arrow` | Hoán đổi với một cửa sổ trên màn hình ở phía đó |
| `Super + Alt + Arrow` | Di chuyển cửa sổ vào một nhóm trên màn hình ở phía đó |
| `Super + Shift + Ctrl + Arrow` | Di chuyển cửa sổ tới màn hình ở phía đó, lên workspace mà nó đang hiển thị |
| `Super + Shift + Alt + Arrow` | Di chuyển workspace tới màn hình ở phía đó, giữ nguyên số của nó nếu nó đang trống |
| `Ctrl + Alt + Tab` / `Ctrl + Alt + Shift + Tab` | Di chuyển focus tới màn hình tiếp theo hoặc trước đó, bất kể bố cục |
| `Super + 1-0`, `Super + Tab`, `Super + Scroll Wheel` | Ở lại trên màn hình bạn đang ở |

Bạn cũng có thể xem qua [Hyprmon](https://github.com/erans/hyprmon/), nếu bạn muốn một TUI giúp bạn định vị nhiều màn hình.

### Điều khiển độ sáng

Độ sáng màn hình được điều khiển bằng các phím chức năng chuyên dụng cho tăng/giảm độ sáng. Nếu bạn giữ shift trong khi nhấn các phím này, bạn sẽ đi tới độ sáng tối đa hoặc tối thiểu. Các phím điều khiển màn hình bạn đang focus, vì vậy các màn hình ngoài nói DDC/CI được điều chỉnh giống như màn hình laptop.

### Màn hình Apple

Nếu bạn đang dùng một màn hình Apple, các phím độ sáng bàn phím thông thường cũng sẽ tự động hoạt động, nếu bạn đang focus trên màn hình Apple. Việc này được thực hiện thông qua lệnh `asdcontrol`.

Lưu ý rằng nếu bạn đang dùng một màn hình Apple 6K XDR, bạn có thể thấy một màn hình ma trong danh sách `hyprctl monitors` của mình. Bạn có thể tắt nó bằng thứ gì đó như `hl.monitor({ output = "DP-2", disabled = true })` trong `~/.config/hypr/monitors.lua`.

Trên các máy Intel, bạn nên kết nối với các màn hình Apple bằng một cáp Thunderbolt thông thường. Trên các máy khác không có Thunderbolt, bạn thường sẽ phải dùng một [cáp DP + USB-A -> USB-C](https://www.amazon.com/dp/B0BNX7MS6N) để nó hoạt động.
