# Dotfiles

Omarchy chủ yếu được cấu hình thông qua các dotfiles nằm trong `~/.config`. Chúng được coi là tệp của bạn để bạn thay đổi. Các tệp nằm trong `/usr/share/omarchy` thuộc về chính Omarchy, và bạn không nên đụng vào chúng. Nếu bạn cần thay đổi bất cứ thứ gì trong `/usr/share/omarchy`, thay vào đó bạn nên ghi đè giá trị trong `~/.config`.

Các cấu hình quan trọng có thể được sửa thẳng từ menu Omarchy (`Super + Space`), như _Setup > Keybindings_, _Setup > Input_, và _Setup > Config > [file]_. Khi bạn làm theo cách này, mọi tiến trình cần khởi động lại sau khi sửa cấu hình sẽ tự động khởi động lại sau khi bạn thoát trình soạn thảo (Neovim theo mặc định — `:wq`, nhớ đấy! — nhưng bạn có thể thay đổi qua _Setup > Defaults > Editor_).

Đây là danh sách các tệp quan trọng trong `~/.config` và những gì chúng điều khiển:

| File                  | Purpose              |
| ----------------------- | --------------------- |
| `~/.config/hypr/hyprland.lua` | Cấu hình Hyprland chính. Nạp các giá trị mặc định của Omarchy cùng với các tệp ghi đè của bạn bên dưới. [Tìm hiểu thêm về cấu hình Hyprland](https://wiki.hypr.land/Configuring/).  |
| `~/.config/hypr/bindings.lua` | Các phím tắt của riêng bạn và các ghi đè lên giá trị mặc định. |
| `~/.config/hypr/monitors.lua` | Các cài đặt màn hình mà bảng điều khiển màn hình không hỗ trợ, như xoay, các chế độ bổ sung, hoặc tắt một màn hình. |
| `~/.config/hypr/input.lua` | Điều khiển bố cục bàn phím, chuột và cài đặt trackpad của bạn. |
| `~/.config/hypr/looknfeel.lua` | Điều khiển khoảng hở, viền, hiệu ứng chuyển động và phần còn lại của giao diện. |
| `~/.config/hypr/autostart.lua` | Điều khiển các tiến trình bổ sung được khởi động cùng với phiên. |
| `~/.config/omarchy/shell.json` | Điều khiển Omarchy shell: vị trí thanh bar, bố cục và các widget, cùng với thời gian chờ của screensaver, khóa màn hình và idle. |
| `~/.config/foot/foot.ini` | Điều khiển terminal của bạn (foot là mặc định). |
| `~/.XCompose` | Định nghĩa emoji truy cập nhanh và tính năng tự động hoàn thành tên/email của bạn. Nhớ chạy `omarchy-restart-xcompose` sau khi thay đổi. |

Nếu bạn thay đổi nhiều để tinh chỉnh thiết lập của riêng mình, bạn nên sao lưu tất cả các dotfiles này. [Stow là một cách tuyệt vời để làm điều đó](https://www.youtube.com/watch?v=NoFiYOqnC4o).

### Khởi động ứng dụng của riêng bạn cùng với phiên

Nếu bạn muốn thứ gì đó chạy mỗi lần bạn đăng nhập — một daemon đồng bộ, một ứng dụng chat, script của riêng bạn — hãy đặt nó vào `~/.config/hypr/autostart.lua`:

```lua
o.launch_on_start("my-service")
```

Lệnh đó sẽ khởi động như một phần của phiên, vì vậy nó sẽ được dọn dẹp đúng cách khi bạn đăng xuất trở lại.

### Chạy script theo các sự kiện hệ thống

Omarchy kích hoạt các hook tại một số thời điểm, và bạn có thể gắn script của riêng mình vào chúng. Chúng nằm trong `~/.config/omarchy/hooks/<event>.d/`, mỗi sự kiện một thư mục, và mọi tệp có thể thực thi trong đó sẽ chạy khi sự kiện xảy ra:

| Event | When it runs |
| ----- | ------------ |
| `post-boot` | Ngay sau khi desktop đã khởi động |
| `post-update` | Gần cuối `omarchy update`, sau các gói, migration và khởi động lại dịch vụ, trước khi các công cụ mise được cập nhật |
| `pre-refresh-pacman` | Sau khi `omarchy refresh pacman` đồng bộ lại cấu hình gói, trước khi nó cập nhật các gói; việc chuyển channel sẽ chạy nó trong cùng bước refresh đó |
| `theme-set` | Sau khi thay đổi theme (tên theme trong `$1`) |
| `font-set` | Sau khi thay đổi font (tên font trong `$1`) |
| `battery-low` | Khi pin yếu (phần trăm trong `$1`) |

Hook `pre-refresh-pacman` là nơi nên đặt các repository tùy chỉnh hoặc các dòng `IgnorePkg`, vì nó chạy trước giao dịch gói. Cả hai hook liên quan đến cập nhật đều chạy dưới người dùng của bạn sau khi Omarchy xóa ủy quyền sudo đã lưu trong bộ nhớ đệm, vì vậy một hook sử dụng `sudo` sẽ cần ủy quyền riêng và có thể yêu cầu mật khẩu của bạn.

Mỗi thư mục đó đã có sẵn một tệp `.sample` cho thấy hình thức của một hook — hãy bỏ phần `.sample` khỏi tên để đưa nó vào hoạt động. Để cài đặt một script bạn đã viết ở nơi khác, hãy dùng `omarchy hook install post-boot ~/my-hook`, lệnh này sẽ sao chép nó vào và đặt quyền thực thi cho nó.

### Thêm mục menu của riêng bạn

Menu Omarchy (`Super + Space`) có thể được mở rộng bằng các hàng của riêng bạn bằng cách sửa `~/.config/omarchy/extensions/omarchy-menu.jsonc`. Các mục được khóa bằng một id có dấu chấm, và chính id đó xác định vị trí của chúng trong cây, vì vậy `personal` xuất hiện trên menu gốc và `personal.notes` xuất hiện bên trong nó:

```jsonc
"personal": {"icon":"","label":"Personal"},
"personal.notes": {"icon":"󰎞","label":"Notes","action":"omarchy-launch-editor ~/notes"},
```

Dùng lại một id đã có và bạn sẽ ghi đè hàng đó thay vì thêm một hàng mới. Tệp này đi kèm với tất cả các trường có sẵn được ghi lại dưới dạng comment.

### Thêm shell export, hàm và alias của riêng bạn

Omarchy đi kèm với một loạt alias tiện dụng và các hàm hữu ích, nhưng việc muốn thêm của riêng bạn là rất phổ biến. Bạn nên thêm cả alias, hàm và export vào `~/.bashrc`. Tệp này sẽ không bị ghi đè khi cập nhật. Nếu bạn muốn thay đổi bất kỳ giá trị mặc định nào của Omarchy, bạn cũng có thể thêm chúng vào đây một cách an toàn.

### Thay đổi các tệp nội bộ của Omarchy

Nghe này, đây là máy tính của bạn. Bạn có thể làm bất cứ điều gì bạn muốn với nó, nhưng tôi khuyên bạn không nên thay đổi trực tiếp các tệp trong `/usr/share/omarchy`. Chúng thuộc về gói pacman của Omarchy, vì vậy các thay đổi của bạn sẽ bị ghi đè trong lần cập nhật tiếp theo. Thay vào đó, bạn nên ghi đè bất kỳ giá trị mặc định nào bạn không thích trong thư mục `~/.config/*`.

Bạn có thể thay đổi gần như mọi thứ theo cách đó, như các phím tắt mặc định. Chỉ cần sửa `~/.config/hypr/bindings.lua` để, chẳng hạn, thay thế [Obsidian](https://obsidian.md/) bằng [Joplin](https://joplinapp.org/) (cài đặt bằng `omarchy-pkg-add joplin-bin`):

```lua
o.rebind("SUPER + SHIFT + O", "Joplin", "joplin-desktop")
```

`o.rebind` xóa phím tắt hiện có trước khi thêm phím tắt thay thế. Nó nhận các đối số giống như `o.bind`, bao gồm các hàm hỗ trợ khởi chạy và các tùy chọn phím tắt. Dùng `o.bind` để thêm một phím tắt, hoặc `hl.unbind` để xóa một phím tắt mà không thay thế nó.

Nếu bạn vẫn khăng khăng muốn hack các tệp nội bộ của Omarchy, hãy chuyển sang kênh dev qua _Update > Channel > Dev_. Điều đó liên kết Omarchy với một bản checkout git của mã nguồn trong `~/omarchy`, nơi bạn có thể thoải mái thay đổi thỏa thích. Chẳng ai ở đây bảo bạn phải làm thế nào cả!

### Đặt lại mọi thay đổi

Nếu cuối cùng bạn làm rối tung các cấu hình, bạn luôn có thể khôi phục chúng về mặc định qua _Update > Config_ trong menu Omarchy. Hoặc bằng cách chạy `omarchy reinstall configs` để đặt lại mọi thứ.
