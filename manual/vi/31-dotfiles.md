# Dotfiles

Omarchy chủ yếu được cấu hình thông qua các dotfiles nằm trong `~/.config`. Chúng được coi là tệp của bạn để bạn thay đổi. Các tệp nằm trong `/usr/share/omarchy` thuộc về chính Omarchy, và bạn không nên động vào chúng. Nếu bạn cần thay đổi bất cứ thứ gì trong `/usr/share/omarchy`, thay vào đó bạn nên ghi đè giá trị đó trong `~/.config`.

Các cấu hình chính có thể được chỉnh sửa ngay từ menu Omarchy (`Super + Space`), như _Setup > Keybindings_, _Setup > Input_, và _Setup > Config > [file]_. Khi bạn làm theo cách này, mọi tiến trình cần khởi động lại sau khi chỉnh sửa cấu hình sẽ tự động được khởi động lại sau khi bạn thoát khỏi trình soạn thảo (mặc định là Neovim — nhớ `:wq` nhé! — nhưng bạn có thể thay đổi qua _Setup > Defaults > Editor_).

Dưới đây là danh sách các tệp chính trong `~/.config` và những gì chúng điều khiển:

| File                  | Purpose              |
| ----------------------- | --------------------- |
| `~/.config/hypr/hyprland.lua` | Tệp cấu hình Hyprland chính. Nạp các mặc định của Omarchy cùng với các tệp ghi đè của bạn bên dưới. [Tìm hiểu thêm về cấu hình Hyprland](https://wiki.hypr.land/Configuring/).  |
| `~/.config/hypr/bindings.lua` | Các phím tắt của riêng bạn và các ghi đè lên mặc định. |
| `~/.config/hypr/monitors.lua` | Các cài đặt màn hình mà bảng điều khiển màn hình không bao quát, như xoay, các chế độ bổ sung, hoặc tắt một màn hình. |
| `~/.config/hypr/input.lua` | Điều khiển bố cục bàn phím, chuột và trackpad của bạn. |
| `~/.config/hypr/looknfeel.lua` | Điều khiển khoảng cách, viền, hiệu ứng chuyển động và phần còn lại của giao diện. |
| `~/.config/hypr/autostart.lua` | Điều khiển các tiến trình bổ sung được khởi chạy cùng với phiên làm việc. |
| `~/.config/omarchy/shell.json` | Điều khiển shell của Omarchy: vị trí thanh, bố cục và các widget, cùng với thời gian chờ của screensaver, khóa màn hình và idle. |
| `~/.config/foot/foot.ini` | Điều khiển terminal của bạn (foot là mặc định). |
| `~/.XCompose` | Định nghĩa emoji truy cập nhanh và tính năng tự động hoàn thành tên/email của bạn. Đảm bảo chạy `omarchy-restart-xcompose` sau khi thay đổi. |

Nếu cuối cùng bạn thay đổi nhiều thứ để tinh chỉnh thiết lập của riêng mình, bạn nên sao lưu tất cả các dotfiles này. [Stow là một cách tuyệt vời để làm việc đó](https://www.youtube.com/watch?v=NoFiYOqnC4o).

### Khởi chạy ứng dụng của riêng bạn cùng với phiên làm việc

Nếu bạn muốn một thứ gì đó chạy mỗi khi đăng nhập — một daemon đồng bộ, một ứng dụng chat, script của riêng bạn — hãy đặt nó vào `~/.config/hypr/autostart.lua`:

```lua
o.launch_on_start("my-service")
```

Lệnh đó khởi chạy lệnh như một phần của phiên làm việc, vì vậy nó sẽ được dọn dẹp đúng cách khi bạn đăng xuất.

### Chạy script theo các sự kiện hệ thống

Omarchy kích hoạt các hook tại một vài thời điểm, và bạn có thể gắn script của riêng mình vào chúng. Chúng nằm trong `~/.config/omarchy/hooks/<event>.d/`, mỗi sự kiện một thư mục, và mọi tệp có thể thực thi trong đó sẽ chạy khi sự kiện xảy ra:

| Event | When it runs |
| ----- | ------------ |
| `post-boot` | Ngay sau khi desktop đã khởi động |
| `post-update` | Gần cuối quá trình `omarchy update`, sau các gói, migration và khởi động lại dịch vụ, trước khi các công cụ mise được cập nhật |
| `pre-refresh-pacman` | Sau khi `omarchy refresh pacman` đồng bộ lại cấu hình gói, trước khi nó cập nhật các gói; việc chuyển kênh sẽ chạy nó trong cùng bước refresh đó |
| `theme-set` | Sau khi thay đổi theme (tên theme trong `$1`) |
| `font-set` | Sau khi thay đổi font (tên font trong `$1`) |
| `battery-low` | Khi pin yếu (phần trăm trong `$1`) |

Hook `pre-refresh-pacman` là nơi nên đặt các repository tùy chỉnh hoặc các dòng `IgnorePkg`, vì nó chạy trước giao dịch gói. Cả hai hook liên quan đến cập nhật đều chạy dưới người dùng của bạn sau khi Omarchy xóa ủy quyền sudo đã lưu trong bộ nhớ đệm, vì vậy một hook dùng `sudo` sẽ cần ủy quyền riêng và có thể yêu cầu mật khẩu của bạn.

Mỗi thư mục trong số đó đều đã chứa một tệp `.sample` cho thấy hình dạng của một hook — hãy bỏ phần `.sample` khỏi tên để đưa nó vào hoạt động. Để cài đặt một script bạn đã viết ở nơi khác, hãy dùng `omarchy hook install post-boot ~/my-hook`, lệnh này sẽ sao chép nó vào và đặt nó thành có thể thực thi.

### Thêm mục menu của riêng bạn

Menu Omarchy (`Super + Space`) có thể được mở rộng với các hàng của riêng bạn bằng cách chỉnh sửa `~/.config/omarchy/extensions/omarchy-menu.jsonc`. Các mục được khóa bằng một id có dấu chấm, và id là thứ đặt chúng vào cây, vì vậy `personal` xuất hiện trên menu gốc và `personal.notes` xuất hiện bên trong nó:

```jsonc
"personal": {"icon":"","label":"Personal"},
"personal.notes": {"icon":"󰎞","label":"Notes","action":"omarchy-launch-editor ~/notes"},
```

Dùng lại một id hiện có và bạn sẽ ghi đè hàng đó thay vì thêm một hàng mới. Tệp đi kèm với tất cả các trường khả dụng được ghi chú dưới dạng comment.

### Thêm export, hàm và alias shell của riêng bạn

Omarchy đi kèm với một loạt alias tiện dụng và các hàm hữu ích, nhưng việc muốn thêm của riêng bạn là rất phổ biến. Bạn nên thêm cả alias, hàm và export trong `~/.bashrc`. Tệp này sẽ không bị ghi đè khi cập nhật. Nếu bạn muốn thay đổi bất kỳ mặc định nào của Omarchy, bạn cũng có thể thêm chúng một cách an toàn tại đây.

### Đặt biến môi trường cho desktop

Các export của phiên desktop thuộc về `~/.config/uwsm/env.d/`. Các tệp này chạy trước khi desktop của bạn khởi động, vì vậy một lỗi shell có thể khiến bạn quay lại màn hình đăng nhập. Hãy giữ một terminal đang hoạt động mở trong khi chỉnh sửa chúng. Để vô hiệu hóa một ghi đè, hãy di chuyển nó ra khỏi `env.d`. Xem [khôi phục đăng nhập](45-troubleshooting.md#my-password-is-accepted-but-i-return-to-the-login-screen) nếu một thay đổi khiến bạn không thể đăng nhập.

### Thay đổi các tệp nội bộ của Omarchy

Nghe này, đây là máy tính của bạn. Bạn muốn làm gì với nó cũng được, nhưng tôi khuyên bạn không nên thay đổi trực tiếp các tệp trong `/usr/share/omarchy`. Chúng thuộc về gói pacman của Omarchy, vì vậy các thay đổi của bạn sẽ đơn giản là bị ghi đè trong lần cập nhật tiếp theo. Thay vào đó, tốt hơn hết bạn chỉ nên ghi đè bất kỳ giá trị mặc định nào bạn không thích trong thư mục `~/.config/*`.

Bạn có thể thay đổi gần như mọi thứ theo cách đó, như các phím tắt mặc định. Chỉ cần chỉnh sửa `~/.config/hypr/bindings.lua` để, chẳng hạn, thay thế [Obsidian](https://obsidian.md/) bằng [Joplin](https://joplinapp.org/) (cài đặt bằng `omarchy-pkg-add joplin-bin`):

```lua
o.rebind("SUPER + SHIFT + O", "Joplin", "joplin-desktop")
```

`o.rebind` loại bỏ ràng buộc hiện có trước khi thêm ràng buộc thay thế của nó. Nó nhận các đối số giống như `o.bind`, bao gồm các helper khởi chạy và các tùy chọn ràng buộc. Dùng `o.bind` để thêm một ràng buộc, hoặc `hl.unbind` để loại bỏ một ràng buộc mà không thay thế nó.

Nếu bạn khăng khăng muốn hack các tệp nội bộ của Omarchy, hãy chuyển sang kênh dev qua _Update > Channel > Dev_. Điều đó liên kết Omarchy với một bản checkout git của mã nguồn trong `~/omarchy`, nơi bạn được tự do thay đổi thỏa thích. Chẳng ai ở đây có quyền bảo bạn phải làm gì đâu!

### Đặt lại mọi thay đổi

Nếu cuối cùng bạn làm rối tung các cấu hình, bạn luôn có thể hoàn nguyên chúng về mặc định qua _Update > Config_ trong menu Omarchy. Hoặc bằng cách chạy `omarchy reinstall configs` để đặt lại mọi thứ.
