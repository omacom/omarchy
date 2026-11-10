# Tạo theme của riêng bạn

Bạn có thể thêm theme của riêng mình vào `~/.config/omarchy/themes`. Chỉ cần sao chép một theme hiện có làm nền (xem trong `/usr/share/omarchy/themes`), rồi tùy chỉnh thỏa thích. Miễn là theme của bạn nằm trong thư mục đó, nó sẽ xuất hiện trong menu chọn theme.

File chính bạn cần tùy chỉnh là `colors.toml`. File này định nghĩa bộ màu, rồi bộ màu đó được dùng để tạo cấu hình cho terminal (Foot/Alacritty/Ghostty/Kitty), btop, Chromium, Hyprland, Neovim, Helix, VSCode, Obsidian, và toàn bộ shell của Omarchy (thanh trên cùng, menu, thông báo, OSD, và màn hình khóa).

Bạn cũng có thể dùng ứng dụng Aether đi kèm để tạo theme mới bằng giao diện GUI đẹp mắt, tha hồ thử nghiệm màu sắc và tìm hình nền. Chỉ cần khởi động nó từ lưới ứng dụng bằng `Super + Alt + Space`.

### Một theme đã cài có thể chứa những gì

Theme bạn tự viết trong `~/.config/omarchy/themes` có thể chứa bất cứ thứ gì bạn muốn — đó là máy của bạn, file của bạn, và Omarchy sẽ áp dụng tất cả.

Theme bạn cài từ repo của người khác bằng `omarchy theme install` sẽ giữ lại mọi thứ thuộc về màu sắc, và loại bỏ số ít file có thể chạy code trên máy của bạn: mọi file `.lua`, các cấu hình terminal (`alacritty.toml`, `foot.ini`, `ghostty.conf`, `kitty.conf`), và `vscode.json`. `hyprland.lua` của một theme là mã Lua mà compositor của bạn chạy khi đăng nhập, một cấu hình terminal chỉ định chương trình mà terminal của bạn khởi động, và `vscode.json` chỉ định một extension của VSCode cần cài. Cài theme của người khác phải thay đổi diện mạo desktop của bạn, chứ không bao giờ thay đổi những gì nó chạy.

Mọi thứ còn lại vẫn hoạt động đúng như tác giả theme đã viết — `btop.theme`, `chromium.theme`, `helix.toml`, `icons.theme`, `shell.toml`, các hình nền và các bản xem trước đều được giữ lại. Chỉ những gì đã bị loại bỏ mới được tạo lại từ `colors.toml` trên máy của bạn.

Omarchy phân biệt hai trường hợp này bằng cách kiểm tra xem theme có repo git riêng bên trong hay không, và đó chính là thứ `omarchy theme install` để lại khi nó clone. Vì vậy, theme bạn tự viết vẫn là của bạn, còn theme bạn kéo về từ internet vẫn chỉ là màu sắc.

### Chế độ sáng

Nếu bạn đang làm một theme chế độ sáng, hãy đặt `mode = "light"` ở đầu `colors.toml` của bạn. Sau đó nó sẽ tự động được ghép với chế độ sáng cho tất cả các ứng dụng. (Cách cũ là thả một file trống tên `light.mode` vào thư mục gốc của theme vẫn hoạt động.)

### Màu icon

Nếu bạn muốn khớp màu icon của trình quản lý file với theme của mình, hãy thêm một file tên `icons.theme` chứa tên bộ icon bạn muốn dùng. Theo mặc định, các tùy chọn là: `Yaru Yaru-blue Yaru-dark Yaru-magenta Yaru-olive Yaru-prussiangreen Yaru-purple Yaru-red Yaru-sage Yaru-wartybrown Yaru-yellow`.

### Hình ảnh mở khóa

Các theme được cung cấp kèm hình ảnh `unlock.png` và `preview-unlock.png` sẽ được liệt kê dưới mục _Appearance > Unlock_. `unlock.png` của bạn tốt nhất nên là một png trong suốt. Và bạn có thể tạo hình ảnh xem trước bằng `omarchy plymouth preview`.

### Áp theme cho các ứng dụng Omarchy không hỗ trợ

Nếu bạn dùng một ứng dụng không có trong danh sách đó, bạn có thể tự dạy Omarchy áp theme cho nó bằng một template. Thả một file vào `~/.config/omarchy/themed/` được đặt tên theo cấu hình mà nó tạo ra cộng thêm phần mở rộng `.tpl`, và viết cấu hình với `{{ background }}`, `{{ foreground }}`, `{{ accent }}`, `{{ red }}`, `{{ color0 }}` đến `{{ color15 }}`, cùng phần còn lại của bảng màu làm các placeholder. Mỗi khi bạn chuyển theme, file sẽ được tạo lại với màu sắc của theme đó.

Có một file `alacritty.toml.tpl.sample` được chú thích đầy đủ trong thư mục đó để bạn sao chép — nó liệt kê mọi biến bạn có thể dùng, cộng thêm các modifier `_strip` và `_rgb` cho các ứng dụng muốn màu sắc của chúng không có dấu `#` hoặc ở dạng RGB thập phân. Template của bạn được ưu tiên hơn template của chính Omarchy, nên bạn cũng có thể dùng cách này để ghi đè cách một ứng dụng tích hợp sẵn được áp theme.

### Phân phối theme của bạn

Nếu bạn muốn phân phối theme của mình để người khác có thể dùng, bạn cần đưa nó lên một máy chủ git công khai, như GitHub. Sau đó mọi người có thể cài nó bằng _Install > Style > Theme_ trong menu Omarchy, sử dụng URL đó. Bạn nên tuân theo quy ước đặt tên `omarchy-[themename]-theme`, vì như vậy theme sẽ hiển thị đúng chỉ dưới dạng `[themename]` trong menu chọn theme sau khi cài đặt.

Phần `[themename]` còn lại đó trở thành tên thư mục của theme, nên nó phải là một cái tên Omarchy có thể truyền qua lại một cách an toàn: nó phải bắt đầu bằng một chữ cái, một chữ số, hoặc một dấu gạch dưới, và phần còn lại có thể chứa chữ cái, chữ số, `.`, `_`, `+`, và `-`. Chữ viết hoa sẽ được hạ xuống chữ thường cho bạn, nhưng bất cứ thứ gì khác — một khoảng trắng, một dấu trích dẫn, một ký tự không phải tiếng Anh — sẽ bị từ chối ngay lúc cài đặt thay vì được biến thành tên thư mục. Vì vậy `omarchy-tokyo-night-theme`, `omarchy-flexoki_light-theme`, và `omarchy-c++-theme` đều cài đặt tốt.

Hãy nhớ rằng một khi nó được cài từ một repo, bất kỳ `.lua`, cấu hình terminal hoặc `vscode.json` nào nó mang theo đều bị loại bỏ, nên đừng xây dựng theme xoay quanh những thứ đó.

Bạn có thể đưa theme của mình vào [trang theme bổ sung](https://omarchy.org/themes/) bằng cách gửi một pull request đến [repo omarchy-site](https://github.com/omacom-io/omarchy-site).
