# Chủ đề

Omarchy đi kèm với hai mươi ba theme tuyệt đẹp. Bạn có thể chọn giữa chúng qua _Appearance > Theme_ trong Omarchy Menu (`Super + Space`) hoặc nhảy thẳng tới trình chọn theme bằng `Super + Ctrl + T`.

Mỗi theme tạo phong cách cho desktop, terminal, neovim, màn hình hoạt động (btop), trình duyệt của bạn (Chrome, Chromium, Edge hoặc Brave), và toàn bộ shell của Omarchy: thanh trên cùng, menu, thông báo, OSD, và màn hình khóa. (Đối với Obsidian, bạn phải tự chọn theme Omarchy qua _Appearance > Themes_ bên trong ứng dụng).

Các theme có một bộ hình nền mà bạn có thể chọn qua lại bằng `Super + Ctrl + W`.

Bạn có thể tìm thêm nhiều theme nữa trên [trang theme bổ sung](https://omarchy.org/themes/) hoặc thậm chí [tự tạo theme của riêng bạn](43-making-your-own-theme.md).

 ![tokyo-night](../themes/tokyo-night/preview.png)
_Tokyo Night_

 ![catppuccin](../themes/catppuccin/preview.png)
_Catppuccin_

 ![lumon](../themes/lumon/preview.png)
_Lumon_

 ![ethereal](../themes/ethereal/preview.png)
_Ethereal_

 ![everforest](../themes/everforest/preview.png)
_Everforest_

 ![gruvbox](../themes/gruvbox/preview.png)
_Gruvbox_

 ![miasma](../themes/miasma/preview.png)
_Miasma_

 ![hackerman](../themes/hackerman/preview.png)
_Hackerman_

 ![jade-horse](../themes/jade-horse/preview.png)
_Jade Horse_

 ![kanagawa](../themes/kanagawa/preview.png)
_Kanagawa_

 ![nord](../themes/nord/preview.png)
_Nord_

 ![matte-black](../themes/matte-black/preview.png)
_Matte Black_

 ![vantablack](../themes/vantablack/preview.png)
_Vantablack_

 ![ristretto](../themes/ristretto/preview.png)
_Ristretto_

 ![retro-82](../themes/retro-82/preview.png)
_Retro 82_

 ![flexoki-light](../themes/flexoki-light/preview.png)
_Flexoki Light_

 ![rose-pine](../themes/rose-pine/preview.png)
_Rose Pine_

 ![catppuccin-latte](../themes/catppuccin-latte/preview.png)
_Catppuccin Latte_

 ![white](../themes/white/preview.png)
_White_

 ![last-horizon](../themes/last-horizon/preview.png)
_Last Horizon_

 ![lupine](../themes/lupine/preview.png)
_Lupine_

 ![solitude](../themes/solitude/preview.png)
_Solitude_

 ![starship](../themes/starship/preview.png)
_Starship_

### Biểu tượng ứng dụng

Các biểu tượng trong trình khởi chạy ứng dụng và dock được vẽ theo màu của theme của bạn, vì vậy chúng thay đổi cùng với theme. Chúng đến từ một bộ biểu tượng, mà bạn chọn tách biệt với theme trong _Appearance > Icons_, từ các bản xem trước của mỗi bộ, theo cùng cách bạn chọn một theme:

- _Papercraft_ là mặc định: mọi thứ được cài sẵn, được vẽ theo một phong cách duy nhất. Các ứng dụng được nhận biết qua logo của chúng, như Chrome, HEY, hoặc YouTube, giữ nguyên hình dạng của logo và mang màu của theme.
- _Arcade_ vẽ cùng các ứng dụng đó dưới dạng pixel art 8-bit, như một máy chơi game console cũ sẽ vẽ.
- _Original_ hiển thị mọi ứng dụng với biểu tượng mà nhà sản xuất của nó đã tạo cho nó.

Bạn có thể cài đặt một bộ biểu tượng do người khác tạo bằng _Install > Style > Icons_ (hoặc `omarchy icons install <git url>`), và gỡ bỏ nó lại trong _Remove > Icons_. _Update > Extra Icons_ tải phiên bản mới nhất của các bộ bạn đã cài đặt.

Để tự tạo bộ của riêng bạn, hãy đặt các biểu tượng của bạn vào `~/.config/omarchy/icons/<name>/`, mỗi ứng dụng một tệp, được đặt tên theo dòng `Icon=` của tệp `.desktop` của ứng dụng. Một tệp kết thúc bằng `.svg` sẽ được hiển thị nguyên như vậy. Một tệp kết thúc bằng `.svg.tpl` sẽ được vẽ theo màu của theme: viết `{{ icon_main }}`, `{{ icon_mark }}`, `{{ icon_paper }}`, `{{ icon_body }}`, `{{ icon_edge }}`, `{{ icon_ink }}` hoặc `{{ icon_shadow }}` tại nơi cần đặt màu. Bộ mặc định trong `/usr/share/omarchy/icons/papercraft/` là một nơi tốt để bắt đầu. Thêm một tệp `preview.png` để hiển thị bộ của bạn trong trình chọn; nếu không có, Omarchy sẽ vẽ một bản xem trước từ các biểu tượng của bạn. Để thay đổi một biểu tượng duy nhất của bộ mặc định, hãy đặt phiên bản của bạn vào `~/.config/omarchy/icons/papercraft/`.

### Khởi động và đăng nhập

Màn hình yêu cầu mật khẩu ổ đĩa của bạn khi máy tính khởi động, và màn hình đăng nhập, cũng đi theo theme. Mỗi lần bạn chuyển theme, chúng sẽ nhận lấy màu nền, màu chữ, màu nhấn, và màu đỏ của theme đó, vì vậy không có thiết kế mở khóa riêng nào để chọn. Trên các máy Mac dùng Apple Silicon, màn hình mật khẩu ổ đĩa giữ nguyên diện mạo mặc định của Omarchy bất kể theme nào.
