# Dotfiles

Omarchy chủ yếu được cấu hình thông qua những thứ gọi là dotfile nằm trong `~/.config`. Đó được coi là các tệp của bạn để bạn thay đổi. Các tệp nằm trong `/usr/share/omarchy` thuộc về chính Omarchy, và bạn không nên động vào chúng. Nếu bạn cần thay đổi bất cứ thứ gì trong `/usr/share/omarchy`, thay vào đó bạn nên ghi đè giá trị trong `~/.config`.

Các cấu hình chính có thể được chỉnh sửa thẳng từ menu Omarchy (`Super + Space`), như _Setup > Keyboard > Keybindings_, _Setup > Input_, và _Setup > Config > [file]_. Khi bạn làm theo cách này, mọi tiến trình cần khởi động lại sau khi chỉnh sửa cấu hình sẽ tự động được khởi động lại sau khi bạn thoát trình soạn thảo (Neovim theo mặc định — `:wq`, nhớ đấy! — nhưng bạn có thể thay đổi điều đó qua _Setup > Defaults > Editor_).

Đây là danh sách các tệp chính trong `~/.config` và những gì chúng điều khiển:

| File                  | Purpose              |
| ----------------------- | --------------------- |
| `~/.config/hypr/hyprland.lua` | Cấu hình Hyprland chính. Nạp các mặc định của Omarchy cùng các tệp ghi đè của bạn bên dưới. [Tìm hiểu thêm về cấu hình Hyprland](https://wiki.hypr.land/Configuring/).  |
| `~/.config/hypr/bindings.lua` | Các phím tắt của riêng bạn và các ghi đè lên mặc định. |
| `~/.config/hypr/monitors.lua` | Các cài đặt màn hình mà bảng điều khiển màn hình không bao quát, như xoay, các chế độ bổ sung, hoặc giữ một màn hình tắt. |
| `~/.config/hypr/input.lua` | Điều khiển bố cục bàn phím, chuột và bàn di chuột của bạn. |
| `~/.config/hypr/looknfeel.lua` | Điều khiển khoảng hở, viền, hiệu ứng chuyển động và phần còn lại của giao diện. |
| `~/.config/hypr/autostart.lua` | Điều khiển các tiến trình bổ sung được khởi động cùng phiên. |
| `~/.config/omarchy/shell.json` | Điều khiển shell của Omarchy: vị trí thanh, bố cục và các widget, cùng thời gian chờ của trình bảo vệ màn hình, khóa và trạng thái nhàn rỗi. |
| `~/.config/foot/foot.ini` | Điều khiển terminal của bạn (foot là mặc định). |
| `~/.XCompose` | Định nghĩa emoji truy cập nhanh và tính năng tự động hoàn thành tên/email của bạn. Đảm bảo chạy `omarchy-restart-xcompose` sau khi thay đổi. |

Nếu cuối cùng bạn thay đổi nhiều để tinh chỉnh thiết lập của riêng mình, bạn nên sao lưu tất cả các dotfile này. [Stow là một cách tuyệt vời để làm điều đó](https://www.youtube.com/watch?v=NoFiYOqnC4o).

### Khởi động các ứng dụng của riêng bạn cùng phiên

Nếu bạn muốn một thứ gì đó chạy mỗi khi bạn đăng nhập — một daemon đồng bộ, một ứng dụng trò chuyện, script của riêng bạn — hãy đặt nó trong `~/.config/hypr/autostart.lua`:

```lua
o.launch_on_start("my-service")
```

Điều đó khởi động lệnh như một phần của phiên, vì vậy nó sẽ được dọn dẹp đúng cách khi bạn đăng xuất.

### Chạy script theo các sự kiện hệ thống

Omarchy kích hoạt các hook tại một vài thời điểm, và bạn có thể gắn các script của riêng mình vào chúng. Chúng nằm trong `~/.config/omarchy/hooks/<event>.d/`, mỗi sự kiện một thư mục, và mọi tệp có thể thực thi trong đó sẽ chạy khi sự kiện xảy ra:

| Event | When it runs |
| ----- | ------------ |
| `post-boot` | Ngay sau khi desktop đã khởi động |
| `post-update` | Gần cuối của `omarchy update`, sau các gói, các bước di chuyển và khởi động lại dịch vụ, trước khi các công cụ mise được cập nhật |
| `pre-refresh-pacman` | Sau khi `omarchy refresh pacman` đồng bộ lại cấu hình gói, trước khi nó cập nhật các gói; việc chuyển kênh sẽ chạy nó trong cùng bước làm mới đó |
| `theme-set` | Sau khi thay đổi giao diện (tên giao diện trong `$1`) |
| `font-set` | Sau khi thay đổi phông chữ (tên phông chữ trong `$1`) |
| `battery-low` | Khi pin yếu (phần trăm trong `$1`) |

Hook `pre-refresh-pacman` là nơi các kho tùy chỉnh hoặc các dòng `IgnorePkg` nên thuộc về, vì nó chạy trước giao dịch gói. Cả hai hook liên quan đến cập nhật đều chạy dưới quyền người dùng của bạn sau khi Omarchy xóa ủy quyền sudo đã lưu trong bộ nhớ đệm của nó, vì vậy một hook sử dụng `sudo` cần ủy quyền riêng và có thể yêu cầu mật khẩu của bạn.

Mỗi thư mục trong số đó đã chứa một tệp `.sample` cho thấy hình dạng của một hook — bỏ `.sample` khỏi tên để đưa nó vào hoạt động. Để cài đặt một script bạn đã viết ở nơi khác, hãy dùng `omarchy hook install post-boot ~/my-hook`, lệnh này sẽ sao chép nó vào và làm cho nó có thể thực thi.

### Thêm các mục menu của riêng bạn

Menu Omarchy (`Super + Space`) có thể được mở rộng bằng các hàng của riêng bạn bằng cách chỉnh sửa `~/.config/omarchy/extensions/omarchy-menu.jsonc`. Các mục được khóa bằng một id có dấu chấm, và id là thứ đặt chúng vào cây, vì vậy `personal` xuất hiện trên menu gốc và `personal.notes` xuất hiện bên trong nó:

```jsonc
"personal": {"icon":"","label":"Personal"},
"personal.notes": {"icon":"󰎞","label":"Notes","action":"omarchy-launch-editor ~/notes"},
```

Tái sử dụng một id hiện có và bạn sẽ ghi đè hàng đó thay vì thêm một hàng mới. Tệp đi kèm với tất cả các trường có sẵn được ghi lại dưới dạng chú thích.

### Thêm các export, hàm và alias shell của riêng bạn

Omarchy đi kèm với một loạt alias tiện dụng và các hàm hữu ích, nhưng việc muốn thêm của riêng bạn là rất phổ biến. Bạn nên thêm cả alias, hàm và export trong `~/.bashrc`. Tệp này sẽ không bị ghi đè khi cập nhật. Nếu bạn muốn thay đổi bất kỳ mặc định nào của Omarchy, bạn cũng có thể thêm chúng một cách an toàn tại đây.

### Đặt biến môi trường cho desktop

Các export của phiên desktop thuộc về `~/.config/uwsm/env.d/`. Các tệp này chạy trước khi desktop của bạn khởi động, vì vậy một lỗi shell có thể đưa bạn trở lại màn hình đăng nhập. Hãy giữ một terminal đang hoạt động mở trong khi chỉnh sửa chúng. Để vô hiệu hóa một ghi đè, hãy di chuyển nó ra khỏi `env.d`. Xem [khôi phục đăng nhập](45-troubleshooting.md#my-password-is-accepted-but-i-return-to-the-login-screen) nếu một thay đổi ngăn bạn đăng nhập.

### Thay đổi các tệp nội bộ của Omarchy

Nghe này, đây là máy tính của bạn. Bạn có thể làm bất cứ điều gì bạn muốn với nó, nhưng tôi khuyên bạn không nên thay đổi trực tiếp các tệp trong `/usr/share/omarchy`. Chúng thuộc về gói pacman của Omarchy, vì vậy các thay đổi của bạn sẽ đơn giản bị ghi đè trong lần cập nhật tiếp theo. Tốt hơn là bạn chỉ cần ghi đè bất kỳ giá trị mặc định nào bạn không thích trong thư mục `~/.config/*` thay vào đó.

Bạn có thể thay đổi gần như mọi thứ theo cách đó, như các phím tắt mặc định. Chỉ cần chỉnh sửa `~/.config/hypr/bindings.lua` để, chẳng hạn, thay thế [Obsidian](https://obsidian.md/) bằng [Joplin](https://joplinapp.org/) (cài đặt bằng `omarchy-pkg-add joplin-bin`):

```lua
o.rebind("SUPER + SHIFT + O", "Joplin", "joplin-desktop")
```

`o.rebind` loại bỏ phím tắt hiện có trước khi thêm phím tắt thay thế. Nó nhận các đối số giống như `o.bind`, bao gồm các trình hỗ trợ khởi chạy và các tùy chọn phím tắt. Dùng `o.bind` để thêm một phím tắt, hoặc `hl.unbind` để loại bỏ một phím tắt mà không thay thế nó.

Nếu bạn khăng khăng muốn can thiệp vào các tệp nội bộ của Omarchy, hãy chuyển sang kênh dev qua _Update > Channel > Dev_. Điều đó liên kết Omarchy với một bản checkout git của mã nguồn trong `~/omarchy`, nơi bạn tự do thay đổi thỏa thích. Không ai ở đây cấm bạn cả!

### Đặt lại mọi thay đổi

Nếu cuối cùng bạn làm rối tung các cấu hình, bạn luôn có thể hoàn chúng về mặc định qua _Update > Config_ trong menu Omarchy. Hoặc bằng cách chạy `omarchy reinstall configs` để đặt lại mọi thứ.
