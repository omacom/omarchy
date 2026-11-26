# Dotfiles

Omarchy chủ yếu được cấu hình thông qua các dotfile sống trong `~/.config`. Đó được xem là các file của bạn để bạn thay đổi. Các file sống trong `/usr/share/omarchy` thuộc về chính Omarchy, và bạn không nên động vào chúng. Nếu bạn cần thay đổi bất cứ thứ gì trong `/usr/share/omarchy`, thay vào đó bạn nên ghi đè giá trị trong `~/.config`.

Các file cấu hình chính có thể được chỉnh sửa trực tiếp từ menu Omarchy (`Super + Space`), như _Setup > Keyboard > Keybindings_, _Setup > Input_, và _Setup > Config > [file]_. Khi bạn làm theo cách này, mọi tiến trình cần khởi động lại sau khi chỉnh sửa cấu hình sẽ tự động được khởi động lại sau khi bạn thoát khỏi trình soạn thảo (Neovim theo mặc định — `:wq`, nhớ đấy! — nhưng bạn có thể thay đổi điều đó qua _Setup > Defaults > Editor_).

Dưới đây là danh sách các file chính trong `~/.config` và những gì chúng điều khiển:

| File                  | Mục đích              |
| ----------------------- | --------------------- |
| `~/.config/hypr/hyprland.lua` | File cấu hình Hyprland chính. Nạp các giá trị mặc định của Omarchy cùng với các file ghi đè của bạn ở bên dưới. [Tìm hiểu thêm về cấu hình Hyprland](https://wiki.hypr.land/Configuring/).  |
| `~/.config/hypr/bindings.lua` | Các keybinding của riêng bạn và các ghi đè lên giá trị mặc định. |
| `~/.config/hypr/monitors.lua` | Các cài đặt màn hình mà bảng điều khiển màn hình không hỗ trợ, như xoay màn hình, các chế độ bổ sung, hoặc tắt một màn hình. |
| `~/.config/hypr/input.lua` | Điều khiển bố cục bàn phím, chuột và cài đặt trackpad của bạn. |
| `~/.config/hypr/looknfeel.lua` | Điều khiển khoảng hở, viền, hiệu ứng chuyển động, và phần còn lại của diện mạo. |
| `~/.config/hypr/autostart.lua` | Điều khiển các tiến trình bổ sung được khởi chạy cùng với phiên. |
| `~/.config/omarchy/shell.json` | Điều khiển shell của Omarchy: vị trí thanh, bố cục và widget, cộng với thời gian chờ của screensaver, khóa màn hình và trạng thái idle. |
| `~/.config/foot/foot.ini` | Điều khiển terminal của bạn (foot là mặc định). |
| `~/.XCompose` | Định nghĩa emoji truy cập nhanh và tính năng tự động hoàn thành tên/email của bạn. Hãy nhớ chạy `omarchy-restart-xcompose` sau khi thay đổi. |

Nếu cuối cùng bạn thực hiện nhiều thay đổi để tinh chỉnh thiết lập của riêng mình, bạn nên sao lưu tất cả các dotfile này. [Stow là một cách tuyệt vời để làm việc đó](https://www.youtube.com/watch?v=NoFiYOqnC4o).

### Khởi chạy ứng dụng của riêng bạn cùng với phiên

Nếu bạn muốn một thứ gì đó chạy mỗi lần bạn đăng nhập — một daemon đồng bộ, một ứng dụng chat, script của riêng bạn — hãy đặt nó vào `~/.config/hypr/autostart.lua`:

```lua
o.launch_on_start("my-service")
```

Điều đó khởi chạy lệnh như một phần của phiên, vì vậy nó được dọn dẹp đúng cách khi bạn đăng xuất trở lại.

### Chạy script theo các sự kiện của hệ thống

Omarchy kích hoạt các hook tại một số thời điểm, và bạn có thể gắn script của riêng mình vào chúng. Chúng sống trong `~/.config/omarchy/hooks/<event>.d/`, mỗi sự kiện một thư mục, và mọi file trong đó không kết thúc bằng `.sample` đều chạy bằng bash khi sự kiện xảy ra:

| Sự kiện | Khi nào nó chạy |
| ----- | ------------ |
| `post-boot` | Ngay sau khi desktop đã khởi động |
| `post-update` | Gần cuối của `omarchy update`, sau các gói, quá trình migration và khởi động lại dịch vụ, trước khi các công cụ mise được cập nhật |
| `pre-refresh-pacman` | Sau khi `omarchy refresh pacman` đồng bộ lại cấu hình gói, trước khi nó cập nhật các gói; việc chuyển kênh sẽ chạy nó trong cùng bước refresh đó |
| `theme-set` | Sau khi thay đổi theme (tên theme trong `$1`) |
| `font-set` | Sau khi thay đổi font (tên font trong `$1`) |
| `battery-low` | Khi pin yếu (phần trăm trong `$1`) |

Hook `pre-refresh-pacman` là nơi các kho tùy chỉnh hoặc các dòng `IgnorePkg` thuộc về, vì nó chạy trước giao dịch gói. Cả hai đều chạy với quyền người dùng của bạn. `post-update` chạy trong khi ủy quyền sudo của `omarchy update` vẫn còn hiệu lực, vì vậy một hook sử dụng `sudo` sẽ không hỏi lại mật khẩu của bạn; `pre-refresh-pacman` chạy ngay sau khi `omarchy refresh pacman` đã tự sử dụng sudo.

Mỗi thư mục trong số đó đã chứa một file `.sample` cho thấy hình dạng của một hook — hãy bỏ `.sample` khỏi tên để đưa nó vào hoạt động. Để cài đặt một script bạn đã viết ở nơi khác, hãy dùng `omarchy hook install post-boot ~/my-hook`, lệnh này sao chép nó vào và biến nó thành file có thể thực thi.

### Thêm mục menu của riêng bạn

Menu Omarchy (`Super + Space`) có thể được mở rộng bằng các hàng của riêng bạn bằng cách chỉnh sửa `~/.config/omarchy/extensions/omarchy-menu.jsonc`. Các mục được khóa bằng một id có dấu chấm, và id là thứ đặt chúng vào cây, vì vậy `personal` xuất hiện trên menu gốc và `personal.notes` xuất hiện bên trong nó:

```jsonc
"personal": {"icon":"","label":"Personal"},
"personal.notes": {"icon":"󰎞","label":"Notes","action":"omarchy-launch-editor ~/notes"},
```

Tái sử dụng một id hiện có và bạn sẽ ghi đè hàng đó thay vì thêm một hàng mới. File được đóng gói kèm với tất cả các trường có sẵn được ghi lại dưới dạng chú thích.

### Thêm shell export, hàm và alias của riêng bạn

Omarchy được đóng gói kèm với một loạt alias tiện dụng và các hàm hữu ích, nhưng việc bạn muốn thêm alias của riêng mình là rất phổ biến. Bạn nên thêm cả alias, hàm và export vào `~/.bashrc`. File này sẽ không bị ghi đè khi cập nhật. Nếu bạn muốn thay đổi bất kỳ giá trị mặc định nào của Omarchy, bạn cũng có thể thêm chúng một cách an toàn tại đây.

### Đặt biến môi trường cho desktop

Các export của phiên desktop thuộc về `~/.config/uwsm/env.d/`. Các file này chạy trước khi desktop của bạn khởi động, vì vậy một lỗi shell có thể đưa bạn trở lại màn hình đăng nhập. Hãy giữ một terminal đang hoạt động mở trong khi chỉnh sửa chúng. Để vô hiệu hóa một ghi đè, hãy di chuyển nó ra khỏi `env.d`. Xem [khôi phục đăng nhập](45-troubleshooting.md#my-password-is-accepted-but-i-return-to-the-login-screen) nếu một thay đổi ngăn cản việc đăng nhập.

### Thay đổi các file nội bộ của Omarchy

Nghe này, đây là máy tính của bạn. Bạn có thể làm bất cứ điều gì bạn muốn với nó, nhưng tôi khuyên bạn không nên thay đổi trực tiếp các file trong `/usr/share/omarchy`. Chúng thuộc về gói pacman của Omarchy, vì vậy các thay đổi của bạn sẽ đơn giản là bị ghi đè trong lần cập nhật tiếp theo. Thay vào đó, bạn tốt hơn nên ghi đè bất kỳ giá trị mặc định nào bạn không thích trong thư mục `~/.config/*`.

Bạn có thể thay đổi gần như mọi thứ theo cách đó, như các keybinding mặc định. Chỉ cần chỉnh sửa `~/.config/hypr/bindings.lua` để, chẳng hạn, thay thế [Obsidian](https://obsidian.md/) bằng [Joplin](https://joplinapp.org/) (cài đặt bằng `omarchy-pkg-add joplin-bin`):

```lua
o.rebind("SUPER + SHIFT + O", "Joplin", "joplin-desktop")
```

`o.rebind` loại bỏ ràng buộc hiện có trước khi thêm ràng buộc thay thế của nó. Nó nhận các đối số giống như `o.bind`, bao gồm các hàm hỗ trợ khởi chạy và các tùy chọn ràng buộc. Sử dụng `o.bind` để thêm một ràng buộc, hoặc `hl.unbind` để loại bỏ một ràng buộc mà không thay thế nó.

Nếu bạn khăng khăng muốn hack các file nội bộ của Omarchy, hãy chuyển sang kênh dev qua _Update > Channel > Dev_. Điều đó liên kết Omarchy tới một bản checkout git của mã nguồn trong `~/omarchy`, nơi bạn tự do thay đổi thỏa thích. Chẳng ai ở đây có quyền bảo bạn phải làm gì đâu!

### Đặt lại mọi thay đổi

Nếu cuối cùng bạn làm rối tung các cấu hình, bạn luôn có thể hoàn chúng về giá trị mặc định qua _Update > Config_ trong menu Omarchy. Hoặc bằng cách chạy `omarchy reinstall configs` để đặt lại mọi thứ.
