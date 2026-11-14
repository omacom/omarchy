# Tự tạo theme của riêng bạn

Bạn có thể thêm theme của riêng mình vào `~/.config/omarchy/themes`. Chỉ cần sao chép một theme có sẵn làm nền (xem trong `/usr/share/omarchy/themes`), rồi chỉnh sửa tuỳ thích. Miễn là theme của bạn nằm trong thư mục đó, nó sẽ xuất hiện trong menu chọn theme.

File chính bạn cần chỉnh sửa là `colors.toml`. File đó định nghĩa bộ màu, sau đó được dùng để tạo cấu hình cho terminal (Foot/Alacritty/Ghostty/Kitty), btop, Chromium, Hyprland, Neovim, Helix, VSCode, Obsidian, và toàn bộ Omarchy shell (thanh trên cùng, menu, thông báo, OSD và màn hình khoá).

Bạn cũng có thể dùng ứng dụng Aether đi kèm để tạo theme mới bằng một giao diện GUI dễ thương để nghịch màu sắc và tìm hình nền. Chỉ cần khởi động nó từ lưới ứng dụng bằng `Super + Alt + Space`.

### Theme đã cài có thể chứa những gì

Theme bạn tự viết trong `~/.config/omarchy/themes` có thể chứa bất cứ thứ gì bạn muốn — đó là máy của bạn và file của bạn, và Omarchy áp dụng tất cả.

Theme bạn cài từ repo của người khác bằng `omarchy theme install` giữ lại mọi thứ thuộc về màu sắc, và loại bỏ số ít file sẽ chạy code trên máy của bạn: mọi file `.lua`, các config terminal (`alacritty.toml`, `foot.ini`, `ghostty.conf`, `kitty.conf`), và `vscode.json`. File `hyprland.lua` của một theme là Lua mà compositor của bạn chạy khi đăng nhập, một config terminal nêu tên chương trình mà terminal của bạn khởi động, và `vscode.json` nêu tên một extension VSCode cần cài. Cài theme của ai đó chỉ nên thay đổi diện mạo desktop của bạn, không bao giờ thay đổi những gì nó chạy.

Mọi thứ còn lại vẫn hoạt động đúng như tác giả theme đã viết — `btop.theme`, `chromium.theme`, `helix.toml`, `shell.toml`, các hình nền và các bản xem trước đều được giữ lại. Chỉ những gì đã bị loại bỏ mới được tạo lại từ `colors.toml` trên máy của bạn.

Omarchy phân biệt hai loại này bằng việc theme có repo git riêng bên trong nó hay không, đó là thứ `omarchy theme install` để lại khi nó clone. Vì vậy theme bạn viết vẫn là của bạn, còn theme bạn tải từ internet thì chỉ còn là màu sắc.

### Chế độ sáng

Nếu bạn đang làm một theme chế độ sáng, hãy đặt `mode = "light"` ở đầu file `colors.toml` của bạn. Sau đó nó sẽ tự động được ghép với chế độ sáng cho tất cả các ứng dụng. (Cách cũ là thả một file trống tên `light.mode` vào thư mục gốc của theme vẫn dùng được.)

### Hình ảnh mở khoá

Các theme được cung cấp kèm hình ảnh `unlock.png` và `preview-unlock.png` sẽ được liệt kê dưới _Giao diện > Mở khoá_. File `unlock.png` của bạn tốt nhất nên là một png trong suốt. Và bạn có thể tạo hình ảnh xem trước bằng `omarchy plymouth preview`.

### Áp theme cho các ứng dụng Omarchy không bao phủ

Nếu bạn dùng một ứng dụng không nằm trong danh sách đó, bạn có thể tự dạy Omarchy áp theme cho nó bằng một template. Thả một file vào `~/.config/omarchy/themed/` được đặt tên theo config mà nó tạo ra cộng thêm phần mở rộng `.tpl`, và viết config với `{{ background }}`, `{{ foreground }}`, `{{ accent }}`, `{{ red }}`, `{{ color0 }}` cho đến `{{ color15 }}`, và phần còn lại của bảng màu dưới dạng các placeholder. Mỗi lần bạn chuyển theme, file sẽ được tạo lại với màu sắc của theme đó.

Trong thư mục đó có một file `alacritty.toml.tpl.sample` được chú thích đầy đủ để bạn sao chép — nó liệt kê mọi biến bạn có thể dùng, cùng với các modifier `_strip` và `_rgb` dành cho các ứng dụng muốn màu của chúng không có `#` hoặc ở dạng RGB thập phân. Template của bạn được ưu tiên hơn template của chính Omarchy, vì vậy bạn cũng có thể dùng cách này để ghi đè cách một ứng dụng tích hợp sẵn được áp theme.

### Phân phối theme của bạn

Nếu bạn muốn phân phối theme của mình để người khác có thể dùng, bạn cần đưa nó lên một máy chủ git công khai, như GitHub. Sau đó mọi người có thể cài nó bằng _Cài đặt > Kiểu > Theme_ trong menu Omarchy bằng URL đó. Bạn nên tuân theo quy ước đặt tên `omarchy-[themename]-theme`, vì theme sẽ hiển thị đúng chỉ là `[themename]` trong menu chọn theme sau khi cài đặt.

Phần `[themename]` còn lại đó trở thành tên thư mục của theme, vì vậy nó phải là một tên mà Omarchy có thể truyền đi một cách an toàn: nó phải bắt đầu bằng một chữ cái, một chữ số, hoặc một dấu gạch dưới, và phần còn lại có thể chứa chữ cái, chữ số, `.`, `_`, `+`, và `-`. Chữ hoa sẽ được chuyển thành chữ thường cho bạn, nhưng bất cứ thứ gì khác — một khoảng trắng, một dấu trích dẫn, một ký tự không phải tiếng Anh — đều bị từ chối ngay lúc cài đặt thay vì bị biến thành tên thư mục. Vì vậy `omarchy-tokyo-night-theme`, `omarchy-flexoki_light-theme`, và `omarchy-c++-theme` đều cài đặt ngon lành.

Hãy nhớ rằng một khi nó được cài từ một repo, mọi `.lua`, config terminal hoặc `vscode.json` mà nó đi kèm đều bị loại bỏ, vì vậy đừng xây dựng theme xoay quanh những thứ đó.

Bạn có thể đưa theme của mình vào [trang theme bổ sung](https://omarchy.org/themes/) bằng cách gửi một pull request tới [repo omarchy-site](https://github.com/omacom-io/omarchy-site).
