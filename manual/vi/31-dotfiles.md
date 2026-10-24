# Dotfiles

Omarchy chủ yếu được cấu hình thông qua các dotfiles nằm trong `~/.config`. Đó là các tệp của bạn dành cho những thay đổi của bạn. Các tệp nằm trong `/usr/share/omarchy` thuộc về chính Omarchy, và bạn không nên động vào chúng. Nếu bạn cần thay đổi bất cứ thứ gì trong `/usr/share/omarchy`, bạn nên ghi đè giá trị trong `~/.config` thay thế.

Các cấu hình chính có thể được chỉnh sửa thẳng từ menu Omarchy (`Super + Space`), như _Thiết lập > Màn hình_, _Thiết lập > Phím tắt_, _Thiết lập > Đầu vào_ và _Thiết lập > Cấu hình > [file]_. Khi bạn làm theo cách này, bất kỳ tiến trình nào cần khởi động lại sau khi sửa cấu hình sẽ tự động được khởi động lại sau khi bạn thoát trình soạn thảo (Neovim theo mặc định — `:wq`, nhớ nhé! — nhưng bạn có thể thay đổi điều đó qua _Thiết lập > Mặc định > Trình soạn thảo_).

Dưới đây là danh sách các tệp chính trong `~/.config` và chúng kiểm soát điều gì:

| Tệp                  | Mục đích              |
| ----------------------- | --------------------- |
| `~/.config/hypr/hyprland.lua` | Cấu hình Hyprland chính. Tải các mặc định của Omarchy cộng với các tệp ghi đè của bạn ở bên dưới. [Tìm hiểu thêm về cấu hình Hyprland](https://wiki.hypr.land/Configuring/).  |
| `~/.config/hypr/bindings.lua` | Các phím tắt của riêng bạn và các ghi đè lên mặc định. |
| `~/.config/hypr/monitors.lua` | Kiểm soát màn hình, độ phân giải và vị trí của bạn. |
| `~/.config/hypr/input.lua` | Kiểm soát bố cục bàn phím, chuột và cài đặt bàn di chuột của bạn. |
| `~/.config/hypr/looknfeel.lua` | Kiểm soát khoảng cách, viền, hiệu ứng và phần còn lại của diện mạo. |
| `~/.config/hypr/autostart.lua` | Kiểm soát các tiến trình phụ khởi động cùng phiên. |
| `~/.config/omarchy/shell.json` | Kiểm soát shell của Omarchy: vị trí thanh, bố cục và các widget, cộng thêm thời gian bảo vệ màn hình, khóa và nhàn rỗi. |
| `~/.config/foot/foot.ini` | Kiểm soát terminal của bạn (foot là mặc định). |
| `~/.XCompose` | Định nghĩa emoji truy cập nhanh và tính năng tự động hoàn thành tên/email của bạn. Hãy chắc chắn chạy `omarchy-restart-xcompose` sau khi thực hiện thay đổi. |

Nếu bạn thực hiện nhiều thay đổi để tinh chỉnh thiết lập của riêng mình, bạn nên sao lưu tất cả các dotfiles này. [Stow là một cách tuyệt vời để làm điều đó](https://www.youtube.com/watch?v=NoFiYOqnC4o).

### Khởi động ứng dụng của riêng bạn cùng phiên

Nếu bạn muốn thứ gì đó chạy mỗi lần đăng nhập — một tiến trình nền đồng bộ, một ứng dụng trò chuyện, script của riêng bạn — hãy đặt nó vào `~/.config/hypr/autostart.lua`:

```lua
o.launch_on_start("my-service")
```

Thao tác đó khởi động lệnh như một phần của phiên, vì vậy nó được dọn dẹp đúng cách khi bạn đăng xuất lần nữa.

### Chạy script theo các sự kiện hệ thống

Omarchy kích hoạt các hook tại một vài thời điểm, và bạn có thể gắn các script của riêng mình vào chúng. Chúng nằm trong `~/.config/omarchy/hooks/<event>.d/`, một thư mục cho mỗi sự kiện, và mọi tệp có thể thực thi trong đó đều chạy khi sự kiện xảy ra:

| Sự kiện | Khi nó chạy |
| ----- | ------------ |
| `post-boot` | Ngay sau khi màn hình nền đã khởi động |
| `post-update` | Gần cuối quá trình `omarchy update`, sau các gói, di chuyển và khởi động lại dịch vụ, trước khi các công cụ mise được cập nhật |
| `pre-refresh-pacman` | Sau khi `omarchy refresh pacman` đồng bộ lại cấu hình gói, trước khi nó cập nhật các gói; một lần chuyển kênh chạy nó trong cùng bước làm mới đó |
| `theme-set` | Sau khi thay đổi giao diện (tên giao diện trong `$1`) |
| `font-set` | Sau khi thay đổi phông chữ (tên phông chữ trong `$1`) |
| `battery-low` | Khi pin yếu (phần trăm trong `$1`) |

Hook `pre-refresh-pacman` là nơi các kho tùy chỉnh hoặc các dòng `IgnorePkg` thuộc về, vì nó chạy trước giao dịch gói. Cả hai hook liên quan đến cập nhật đều chạy dưới quyền người dùng của bạn sau khi Omarchy xóa ủy quyền sudo đã lưu trong bộ nhớ đệm của nó, vì vậy một hook dùng `sudo` cần ủy quyền riêng của nó và có thể hỏi mật khẩu của bạn.

Mỗi thư mục trong số đó đã chứa một tệp `.sample` cho thấy hình dạng của một hook — bỏ phần `.sample` khỏi tên để đưa nó vào hoạt động. Để cài đặt một script bạn đã viết ở nơi khác, dùng `omarchy hook install post-boot ~/my-hook`, lệnh này sao chép nó vào và biến nó thành tệp có thể thực thi.

### Thêm các mục menu của riêng bạn

Menu Omarchy (`Super + Space`) có thể được mở rộng bằng các hàng của riêng bạn bằng cách chỉnh sửa `~/.config/omarchy/extensions/omarchy-menu.jsonc`. Các mục được khóa bằng một id có chấm, và id là thứ đặt chúng vào cây, vì vậy `personal` xuất hiện trên menu gốc và `personal.notes` xuất hiện bên trong nó:

```jsonc
"personal": {"icon":"","label":"Personal"},
"personal.notes": {"icon":"󰎞","label":"Notes","action":"omarchy-launch-editor ~/notes"},
```

Tái sử dụng một id hiện có và bạn sẽ ghi đè hàng đó thay vì thêm một hàng mới. Tệp được giao kèm với mọi trường khả dụng được ghi lại dưới dạng nhận xét.

### Thêm các export, hàm và bí danh shell của riêng bạn

Omarchy đi kèm một loạt bí danh tiện ích và hàm hữu ích theo công thái học, nhưng việc muốn thêm của riêng bạn là rất phổ biến. Bạn nên thêm cả bí danh, hàm và export vào `~/.bashrc`. Tệp này sẽ không bị ghi đè khi cập nhật. Nếu bạn muốn thay đổi bất kỳ mặc định nào của Omarchy, bạn cũng có thể thêm chúng vào đây một cách an toàn.

### Thay đổi các tệp nội bộ của Omarchy

Nghe này, đây là máy tính của bạn. Bạn có thể làm bất cứ điều gì bạn muốn với nó, nhưng tôi khuyên bạn không nên thực hiện thay đổi trực tiếp đối với các tệp trong `/usr/share/omarchy`. Chúng thuộc về gói pacman của Omarchy, vì vậy các thay đổi của bạn sẽ bị ghi đè trong lần cập nhật tiếp theo. Bạn tốt hơn nên ghi đè bất kỳ giá trị mặc định nào bạn không thích trong thư mục `~/.config/*` thay thế.

Bạn có thể thay đổi gần như mọi thứ theo cách đó, như các phím tắt mặc định. Chỉ cần chỉnh sửa `~/.config/hypr/bindings.lua` để, chẳng hạn, thay thế [Obsidian](https://obsidian.md/) bằng [Joplin](https://joplinapp.org/) (cài đặt bằng `omarchy-pkg-add joplin-bin`):

```lua
o.rebind("SUPER + SHIFT + O", "Joplin", "joplin-desktop")
```

`o.rebind` xóa ràng buộc hiện có trước khi thêm ràng buộc thay thế của nó. Nó nhận các đối số giống như `o.bind`, bao gồm các trình trợ giúp khởi chạy và các tùy chọn ràng buộc. Dùng `o.bind` để thêm một ràng buộc, hoặc `hl.unbind` để xóa một ràng buộc mà không thay thế nó.

Nếu bạn nhất quyết mày mò các tệp nội bộ của Omarchy, hãy chuyển sang kênh dev qua _Cập nhật > Kênh > Dev_. Điều đó liên kết Omarchy đến một bản sao git của mã nguồn trong `~/omarchy`, mà bạn được tự do thay đổi thỏa thích. Không ai ở đây để bảo bạn phải làm gì cả!

### Đặt lại mọi thay đổi

Nếu bạn làm rối tung các cấu hình, bạn luôn có thể hoàn nguyên chúng về mặc định qua _Cập nhật > Cấu hình_ trong menu Omarchy. Hoặc bằng cách chạy `omarchy reinstall configs` để đặt lại mọi thứ.
