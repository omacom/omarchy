# Tự làm chủ đề của riêng bạn

Bạn có thể thêm chủ đề của riêng mình vào `~/.config/omarchy/themes`. Chỉ cần sao chép một trong các chủ đề hiện có làm nền (xem trong `/usr/share/omarchy/themes`), rồi tinh chỉnh theo ý thích của bạn. Miễn là chủ đề của bạn nằm trong thư mục đó, nó sẽ được đưa vào menu chọn chủ đề.

Tệp chính bạn phải tinh chỉnh là `colors.toml`. Tệp đó định nghĩa bộ màu sau đó được dùng để tạo các cấu hình cho terminal (Foot/Alacritty/Ghostty/Kitty), btop, Chromium, Hyprland, Neovim, Helix, VSCode, Obsidian và toàn bộ shell Omarchy (thanh trên cùng, menu, thông báo, OSD và màn hình khóa).

Bạn cũng có thể dùng ứng dụng Aether đi kèm để tạo một chủ đề mới bằng một giao diện GUI dễ thương để chơi với màu sắc và tìm kiếm hình nền. Chỉ cần khởi động nó từ lưới ứng dụng trên `Super + Alt + Space`.

### Một chủ đề đã cài đặt có thể chứa những gì

Một chủ đề bạn tự viết trong `~/.config/omarchy/themes` có thể chứa bất cứ thứ gì bạn thích — đó là máy của bạn và tệp của bạn, và Omarchy áp dụng tất cả chúng.

Một chủ đề bạn cài đặt từ repo của người khác bằng `omarchy theme install` giữ lại mọi thứ là màu sắc, và mất đi một số ít tệp sẽ chạy mã trên máy của bạn: bất kỳ tệp `.lua` nào, các cấu hình terminal (`alacritty.toml`, `foot.ini`, `ghostty.conf`, `kitty.conf`) và `vscode.json`. Tệp `hyprland.lua` của một chủ đề là Lua mà compositor của bạn chạy khi đăng nhập, một cấu hình terminal nêu tên chương trình mà terminal của bạn khởi động, và `vscode.json` nêu tên một tiện ích mở rộng VSCode để cài đặt. Cài đặt chủ đề của ai đó nên thay đổi diện mạo màn hình nền của bạn, chứ không bao giờ thay đổi thứ nó chạy.

Mọi thứ khác vẫn hoạt động đúng như tác giả chủ đề đã viết — `btop.theme`, `chromium.theme`, `helix.toml`, `icons.theme`, `shell.toml`, các hình nền và các bản xem trước đều được giữ lại. Chỉ những gì đã bị loại bỏ mới được tạo lại từ `colors.toml` trên máy của bạn.

Omarchy phân biệt hai loại bằng việc chủ đề có repo git riêng bên trong nó hay không, đó là thứ `omarchy theme install` để lại khi nó clone. Vậy nên một chủ đề bạn đã viết vẫn là của bạn, và một chủ đề bạn kéo từ internet về vẫn là màu sắc.

### Chế độ sáng

Nếu bạn đang làm một chủ đề chế độ sáng, hãy đặt `mode = "light"` ở đầu tệp `colors.toml` của bạn. Sau đó nó sẽ tự động được ghép nối với chế độ sáng cho mọi ứng dụng. (Cách cũ là thả một tệp trống có tên `light.mode` vào thư mục gốc của chủ đề của bạn vẫn hoạt động.)

### Màu biểu tượng

Nếu bạn muốn khớp màu các biểu tượng của trình quản lý tệp với chủ đề của mình, hãy thêm một tệp có tên `icons.theme` với tên của bộ biểu tượng bạn muốn dùng. Theo mặc định, các tùy chọn là: `Yaru Yaru-blue Yaru-dark Yaru-magenta Yaru-olive Yaru-prussiangreen Yaru-purple Yaru-red Yaru-sage Yaru-wartybrown Yaru-yellow`.

### Hình ảnh mở khóa

Các chủ đề được cung cấp kèm hình ảnh `unlock.png` và `preview-unlock.png` sẽ được liệt kê dưới _Phong cách > Mở khóa_. Tệp `unlock.png` của bạn tốt nhất nên là một png trong suốt. Và bạn có thể tạo hình ảnh xem trước bằng `omarchy plymouth preview`.

### Áp dụng chủ đề cho các ứng dụng mà Omarchy không bao quát

Nếu bạn dùng một ứng dụng không nằm trong danh sách đó, bạn có thể tự dạy Omarchy áp dụng chủ đề cho nó bằng một mẫu. Thả một tệp vào `~/.config/omarchy/themed/` được đặt tên theo cấu hình mà nó tạo ra cộng với phần mở rộng `.tpl`, và viết cấu hình với `{{ background }}`, `{{ foreground }}`, `{{ accent }}`, `{{ red }}`, `{{ color0 }}` đến `{{ color15 }}` và phần còn lại của bảng màu làm các trình giữ chỗ. Mỗi lần bạn chuyển chủ đề, tệp sẽ được tạo lại với màu sắc của chủ đề đó.

Có một tệp `alacritty.toml.tpl.sample` được chú thích đầy đủ trong thư mục đó để sao chép — nó liệt kê mọi biến bạn có thể dùng, cộng với các bổ trợ `_strip` và `_rgb` cho các ứng dụng muốn màu sắc của chúng không có dấu `#` hoặc dưới dạng RGB thập phân. Các mẫu của bạn được ưu tiên hơn các mẫu của chính Omarchy, nên bạn cũng có thể dùng việc này để ghi đè cách một ứng dụng tích hợp sẵn được áp dụng chủ đề.

### Phân phối chủ đề của bạn

Nếu bạn muốn phân phối chủ đề của mình để người khác có thể dùng nó, bạn cần đưa nó lên một máy chủ git công khai, như GitHub. Sau đó mọi người có thể cài đặt nó bằng _Cài đặt > Phong cách > Chủ đề_ trong menu Omarchy bằng URL đó. Bạn nên tuân theo quy ước đặt tên `omarchy-[themename]-theme`, vì chủ đề sẽ hiển thị đúng dưới dạng chỉ `[themename]` trong menu chọn chủ đề sau khi cài đặt.

Phần `[themename]` còn lại đó trở thành tên thư mục của chủ đề, nên nó phải là một cái tên mà Omarchy có thể truyền đi một cách an toàn: nó phải bắt đầu bằng một chữ cái, một chữ số hoặc một dấu gạch dưới, và phần còn lại có thể chứa các chữ cái, chữ số, `.`, `_`, `+` và `-`. Chữ hoa sẽ được chuyển thành chữ thường cho bạn, nhưng bất cứ thứ gì khác — một dấu cách, một dấu ngoặc kép, một ký tự không phải tiếng Anh — đều bị từ chối vào lúc cài đặt thay vì được biến thành một tên thư mục. Vậy nên `omarchy-tokyo-night-theme`, `omarchy-flexoki_light-theme` và `omarchy-c++-theme` đều cài đặt tốt.

Hãy nhớ rằng một khi nó được cài đặt từ một repo, bất kỳ tệp `.lua`, cấu hình terminal hoặc `vscode.json` nào nó đi kèm đều bị loại bỏ, nên đừng xây dựng chủ đề xung quanh những thứ đó.

Bạn có thể đưa chủ đề của mình vào [trang chủ đề bổ sung](https://omarchy.org/themes/) bằng cách gửi một pull request tới [repo omarchy-site](https://github.com/omacom-io/omarchy-site).
