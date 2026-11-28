# Tự tạo theme của riêng bạn

Bạn có thể thêm theme của riêng mình vào `~/.config/omarchy/themes`. Chỉ cần sao chép một theme hiện có làm nền (hãy xem trong `/usr/share/omarchy/themes`), rồi chỉnh sửa thỏa thích. Miễn là theme của bạn nằm trong thư mục đó, nó sẽ được đưa vào menu chọn theme.

Tệp chính bạn phải chỉnh sửa là `colors.toml`. Tệp đó định nghĩa bộ màu sau đó được dùng để tạo cấu hình cho terminal (Foot/Alacritty/Ghostty/Kitty), btop, Chromium, Hyprland, Neovim, Helix, VSCode, Obsidian, các ứng dụng Qt, đèn nền bàn phím, phương thức nhập, trình chọn chia sẻ màn hình, các biểu tượng ứng dụng, một số công cụ AI (Claude, Pi, Hermes, T3 Code, Herdr), và toàn bộ shell của Omarchy (thanh trên cùng, menu, thông báo, OSD, và màn hình khóa).

Bạn cũng có thể dùng ứng dụng Aether đi kèm để tạo một theme mới bằng giao diện GUI xinh xắn để tha hồ chơi với màu sắc và tìm hình nền. Chỉ cần khởi chạy nó từ lưới ứng dụng bằng `Super + Alt + Space`.

### Một theme đã cài đặt có thể chứa những gì

Một theme do chính bạn viết trong `~/.config/omarchy/themes` có thể chứa bất cứ thứ gì bạn muốn — đó là máy của bạn và tệp của bạn, và Omarchy áp dụng tất cả.

Một theme bạn cài đặt từ repo của người khác bằng `omarchy theme install` sẽ giữ lại mọi thứ thuộc về màu sắc, và mất đi một vài tệp sẽ chạy code trên máy của bạn: bất kỳ tệp `.lua` nào, các cấu hình terminal (`alacritty.toml`, `foot.ini`, `ghostty.conf`, `kitty.conf`), và `vscode.json`. `hyprland.lua` của một theme là Lua mà compositor của bạn chạy khi đăng nhập, một cấu hình terminal đặt tên chương trình mà terminal của bạn khởi chạy, và `vscode.json` đặt tên một extension của VSCode cần cài đặt. Việc cài đặt theme của ai đó nên thay đổi diện mạo desktop của bạn, chứ không bao giờ thay đổi những gì nó chạy.

Mọi thứ còn lại vẫn hoạt động đúng y như tác giả theme đã viết — `btop.theme`, `chromium.theme`, `helix.toml`, `shell.toml`, các hình nền và các bản xem trước đều được giữ lại. Chỉ những gì đã bị loại bỏ mới được tạo lại từ `colors.toml` trên máy của bạn.

Omarchy phân biệt hai loại này dựa vào việc theme có repo git riêng bên trong nó hay không, đó là thứ mà `omarchy theme install` để lại khi nó clone. Vậy nên một theme do bạn viết vẫn là của bạn, và một theme bạn tải về từ internet vẫn chỉ là màu sắc.

### Chế độ sáng

Nếu bạn đang tạo một theme chế độ sáng, hãy đặt `mode = "light"` ở đầu `colors.toml` của bạn. Sau đó nó sẽ tự động được ghép nối với chế độ sáng cho tất cả các ứng dụng. (Cách cũ là thả một tệp trống có tên `light.mode` vào thư mục gốc của theme vẫn hoạt động tốt.)

### Hình ảnh mở khóa

Các theme được cung cấp kèm các hình ảnh `unlock.png` và `preview-unlock.png` sẽ được liệt kê dưới _Appearance > Unlock_. `unlock.png` của bạn tốt nhất nên là một png trong suốt. Và bạn có thể tạo hình ảnh xem trước bằng `omarchy plymouth preview`.

### Tạo theme cho các ứng dụng mà Omarchy không hỗ trợ

Nếu bạn dùng một ứng dụng không có trong danh sách đó, bạn có thể dạy Omarchy tự tạo theme cho nó bằng một template. Hãy thả một tệp vào `~/.config/omarchy/themed/` được đặt tên theo cấu hình mà nó tạo ra cộng thêm phần mở rộng `.tpl`, và viết cấu hình với `{{ background }}`, `{{ foreground }}`, `{{ accent }}`, `{{ red }}`, `{{ color0 }}` đến `{{ color15 }}`, và phần còn lại của bảng màu dưới dạng các placeholder. Mỗi lần bạn chuyển theme, tệp sẽ được tạo lại với màu sắc của theme đó.

Có một `alacritty.toml.tpl.sample` được chú thích đầy đủ trong thư mục đó để bạn sao chép — nó liệt kê mọi biến bạn có thể dùng, cùng với các modifier `_strip` và `_rgb` dành cho các ứng dụng muốn màu sắc của chúng không có `#` hoặc ở dạng RGB thập phân. Các template của bạn được ưu tiên hơn template của chính Omarchy, vì vậy bạn cũng có thể dùng cách này để ghi đè cách một ứng dụng tích hợp được tạo theme.

### Phân phối theme của bạn

Nếu bạn muốn phân phối theme của mình để người khác có thể dùng, bạn cần đặt nó lên một máy chủ git công khai, như GitHub. Sau đó mọi người có thể cài đặt nó bằng _Install > Style > Theme_ trong menu Omarchy bằng URL đó. Bạn nên tuân theo quy ước đặt tên `omarchy-[themename]-theme`, vì theme sẽ hiển thị chính xác chỉ dưới dạng `[themename]` trong menu chọn theme sau khi cài đặt.

Phần `[themename]` còn lại đó trở thành tên thư mục của theme, vì vậy nó phải là một cái tên mà Omarchy có thể truyền qua lại một cách an toàn: nó phải bắt đầu bằng một chữ cái, một chữ số, hoặc một dấu gạch dưới, và phần còn lại có thể chứa các chữ cái, chữ số, `.`, `_`, `+`, và `-`. Các chữ hoa sẽ được chuyển thành chữ thường cho bạn, nhưng bất kỳ thứ gì khác — một khoảng trắng, một dấu trích dẫn, một ký tự không phải tiếng Anh — sẽ bị từ chối ngay lúc cài đặt thay vì bị biến thành tên thư mục. Vậy nên `omarchy-tokyo-night-theme`, `omarchy-flexoki_light-theme`, và `omarchy-c++-theme` đều cài đặt tốt.

Hãy nhớ rằng một khi nó được cài đặt từ một repo, bất kỳ `.lua`, cấu hình terminal hoặc `vscode.json` nào mà nó đi kèm đều bị loại bỏ, vì vậy đừng xây dựng theme xoay quanh những thứ đó.

Bạn có thể đưa theme của mình vào [trang các theme bổ sung](https://omarchy.org/themes/) bằng cách gửi một pull request tới [repo omarchy-site](https://github.com/omacom-io/omarchy-site).
