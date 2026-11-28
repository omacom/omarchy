# Tự tạo theme của riêng bạn

Bạn có thể thêm theme của riêng mình vào `~/.config/omarchy/themes`. Chỉ cần sao chép một theme có sẵn làm nền (xem trong `/usr/share/omarchy/themes`), rồi tùy chỉnh thỏa thích. Miễn là theme của bạn nằm trong thư mục đó, nó sẽ có mặt trong menu chọn theme.

File chính bạn phải tùy chỉnh là `colors.toml`. File đó định nghĩa bộ màu, sau đó được dùng để tạo cấu hình cho terminal (Foot/Alacritty/Ghostty/Kitty), btop, Chromium, Hyprland, Neovim, Helix, VSCode, Obsidian, các ứng dụng Qt, đèn nền bàn phím, bộ gõ, trình chọn chia sẻ màn hình, các biểu tượng ứng dụng, một số công cụ AI (Claude, Pi, Hermes, T3 Code, Herdr), và toàn bộ Omarchy shell (thanh trên cùng, menu, thông báo, OSD, và màn hình khóa).

Bạn cũng có thể dùng ứng dụng Aether đi kèm để tạo theme mới bằng một giao diện GUI dễ chịu, giúp bạn chơi với màu sắc và tìm hình nền. Chỉ cần khởi động nó từ lưới ứng dụng bằng `Super + Alt + Space`.

### Một theme đã cài có thể chứa những gì

Một theme do chính bạn viết trong `~/.config/omarchy/themes` có thể chứa bất cứ thứ gì bạn muốn — đó là máy của bạn và file của bạn, và Omarchy sẽ áp dụng tất cả.

Một theme bạn cài từ repo của người khác bằng `omarchy theme install` sẽ giữ lại mọi thứ thuộc về màu sắc, và loại bỏ một số ít file sẽ chạy code trên máy của bạn: mọi file `.lua`, các file cấu hình terminal (`alacritty.toml`, `foot.ini`, `ghostty.conf`, `kitty.conf`), và `vscode.json`. File `hyprland.lua` của một theme là Lua mà compositor của bạn chạy khi đăng nhập, một file cấu hình terminal nêu tên chương trình mà terminal của bạn khởi động, và `vscode.json` nêu tên một extension VSCode cần cài đặt. Cài theme của người khác chỉ nên thay đổi diện mạo desktop của bạn, không bao giờ thay đổi những gì nó chạy.

Mọi thứ còn lại vẫn hoạt động đúng như cách tác giả theme đã viết — `btop.theme`, `chromium.theme`, `helix.toml`, `shell.toml`, các hình nền và các bản xem trước đều được giữ lại. Chỉ những gì đã bị loại bỏ mới được tạo lại từ `colors.toml` trên máy của bạn.

Omarchy phân biệt hai loại này bằng cách kiểm tra xem theme có repo git riêng bên trong nó hay không, đó là thứ `omarchy theme install` để lại khi nó clone. Vậy nên theme bạn tự viết vẫn là của bạn, và theme bạn tải từ internet chỉ là màu sắc mà thôi.

### Chế độ sáng

Nếu bạn đang làm một theme chế độ sáng, hãy đặt `mode = "light"` ở đầu file `colors.toml` của bạn. Sau đó nó sẽ tự động được ghép với chế độ sáng cho mọi ứng dụng. (Cách cũ là thả một file rỗng tên `light.mode` vào thư mục gốc của theme vẫn dùng được.)

### Màn hình khởi động và đăng nhập

Màn hình yêu cầu mật khẩu ổ đĩa khi khởi động, và màn hình đăng nhập, vẽ logo Omarchy bằng màu `accent` của theme của bạn trên nền `background` của nó, với trường mật khẩu dùng màu `foreground` và màu `red` khi mật khẩu sai. Bạn không cần cung cấp thêm gì cho chúng: Omarchy không còn dùng file `unlock.png` hay `preview-unlock.png` của theme nữa. Trên các máy Mac Apple Silicon, màn hình mật khẩu ổ đĩa vẫn giữ diện mạo mặc định của Omarchy bất kể theme nào.

### Áp theme cho các ứng dụng Omarchy không hỗ trợ sẵn

Nếu bạn dùng một ứng dụng không có trong danh sách đó, bạn có thể tự dạy Omarchy áp theme cho nó bằng một template. Thả một file vào `~/.config/omarchy/themed/` được đặt tên theo file cấu hình mà nó tạo ra cộng thêm phần mở rộng `.tpl`, và viết file cấu hình với `{{ background }}`, `{{ foreground }}`, `{{ accent }}`, `{{ red }}`, `{{ color0 }}` đến `{{ color15 }}`, cùng phần còn lại của bảng màu dưới dạng các placeholder. Mỗi lần bạn chuyển theme, file sẽ được tạo lại với màu sắc của theme đó.

Có một file `alacritty.toml.tpl.sample` được chú thích đầy đủ trong thư mục đó để bạn sao chép — nó liệt kê mọi biến bạn có thể dùng, cùng các modifier `_strip` và `_rgb` dành cho các ứng dụng muốn màu sắc của chúng không có dấu `#` hoặc dưới dạng RGB thập phân. Các template của bạn được ưu tiên hơn của chính Omarchy, vì vậy bạn cũng có thể dùng cách này để ghi đè cách một ứng dụng tích hợp sẵn được áp theme.

### Phân phối theme của bạn

Nếu bạn muốn phân phối theme của mình để người khác có thể dùng, bạn cần đặt nó trên một máy chủ git công khai, như GitHub. Sau đó mọi người có thể cài nó bằng _Install > Style > Theme_ trong menu Omarchy bằng URL đó. Bạn nên tuân theo quy ước đặt tên `omarchy-[themename]-theme`, vì như vậy theme sẽ hiển thị đúng chỉ là `[themename]` trong menu chọn theme sau khi cài đặt.

Phần `[themename]` còn lại đó trở thành tên thư mục của theme, vì vậy nó phải là một tên Omarchy có thể truyền qua lại một cách an toàn: nó phải bắt đầu bằng một chữ cái, một chữ số, hoặc một dấu gạch dưới, và phần còn lại có thể chứa các chữ cái, chữ số, `.`, `_`, `+`, và `-`. Các chữ hoa sẽ được chuyển thành chữ thường cho bạn, nhưng bất cứ thứ gì khác — một dấu cách, một dấu ngoặc kép, một ký tự không phải tiếng Anh — đều bị từ chối ngay khi cài đặt thay vì được biến thành tên thư mục. Vì vậy `omarchy-tokyo-night-theme`, `omarchy-flexoki_light-theme`, và `omarchy-c++-theme` đều cài đặt tốt.

Hãy nhớ rằng một khi nó được cài từ một repo, mọi file `.lua`, file cấu hình terminal hoặc `vscode.json` mà nó cung cấp đều bị loại bỏ, vì vậy đừng xây dựng theme xoay quanh những thứ đó.

Bạn có thể đưa theme của mình vào [trang theme bổ sung](https://omarchy.org/themes/) bằng cách gửi một pull request tới [repo omarchy-site](https://github.com/omacom-io/omarchy-site).
