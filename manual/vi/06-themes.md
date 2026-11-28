# Chủ đề

Omarchy đi kèm với hai mươi ba chủ đề đẹp. Bạn có thể chọn giữa chúng qua _Appearance > Theme_ trong Omarchy Menu (`Super + Space`) hoặc nhảy thẳng tới trình chọn chủ đề bằng `Super + Ctrl + T`.

Mỗi chủ đề tạo phong cách cho desktop, terminal, neovim, màn hình hoạt động (btop), trình duyệt của bạn (Chrome, Chromium, Edge hoặc Brave), và toàn bộ shell của Omarchy: thanh trên cùng, menu, thông báo, OSD và màn hình khóa. (Đối với Obsidian, bạn phải tự chọn chủ đề Omarchy qua _Appearance > Themes_ bên trong ứng dụng).

Các chủ đề có một bộ hình nền mà bạn có thể chọn qua lại bằng `Super + Ctrl + W`.

Bạn có thể tìm thấy thêm nhiều chủ đề nữa trên [trang chủ đề bổ sung](https://omarchy.org/themes/) hoặc thậm chí [tự tạo chủ đề của riêng bạn](43-making-your-own-theme.md).

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

Các biểu tượng trong trình khởi chạy ứng dụng và dock được vẽ bằng màu sắc của chủ đề của bạn, vì vậy chúng thay đổi theo chủ đề. Chúng đến từ một bộ biểu tượng, mà bạn chọn riêng biệt với chủ đề tại _Appearance > Icons_, từ các bản xem trước của mỗi bộ, giống như cách bạn chọn một chủ đề:

- _Papercraft_ là mặc định: mọi thứ được cài sẵn, được vẽ theo một phong cách duy nhất. Các ứng dụng được nhận biết qua logo của chúng, như Chrome, HEY hoặc YouTube, giữ nguyên hình dạng của logo và mang màu sắc của chủ đề.
- _Arcade_ vẽ cùng các ứng dụng đó dưới dạng pixel art 8-bit, giống như một máy chơi game console cũ sẽ làm vậy.
- _Original_ hiển thị mọi ứng dụng với biểu tượng mà nhà phát triển của nó đã tạo cho nó.

Bạn có thể cài đặt một bộ biểu tượng do người khác tạo bằng _Install > Style > Icons_ (hoặc `omarchy icons install <git url>`), và gỡ bỏ nó lại tại _Remove > Icons_. _Update > Extra Icons_ sẽ tải phiên bản mới nhất của các bộ bạn đã cài đặt.

Để tự tạo bộ của riêng bạn, hãy đặt các biểu tượng của bạn vào `~/.config/omarchy/icons/<name>/`, mỗi ứng dụng một tệp, được đặt tên theo dòng `Icon=` trong tệp `.desktop` của ứng dụng. Một tệp kết thúc bằng `.svg` sẽ được hiển thị nguyên trạng. Một tệp kết thúc bằng `.svg.tpl` sẽ được vẽ bằng màu sắc của chủ đề: hãy viết `{{ icon_main }}`, `{{ icon_mark }}`, `{{ icon_paper }}`, `{{ icon_body }}`, `{{ icon_edge }}`, `{{ icon_ink }}` hoặc `{{ icon_shadow }}` tại vị trí cần đặt màu. Bộ mặc định tại `/usr/share/omarchy/icons/papercraft/` là một nơi tốt để bắt đầu. Hãy thêm một tệp `preview.png` để hiển thị bộ của bạn trong trình chọn; nếu không có, Omarchy sẽ tự vẽ một bản xem trước từ các biểu tượng của bạn. Để thay đổi một biểu tượng duy nhất của bộ mặc định, hãy đặt phiên bản của bạn vào `~/.config/omarchy/icons/papercraft/`.

### Mở khóa

Các chủ đề cũng có thể có một thiết kế mở khóa tùy chỉnh, được dùng cho quá trình giải mã khi khởi động. Bạn có thể chọn một trong số chúng tại _Appearance > Unlock_. Chúng trông như thế này:

 ![catppuccin](../themes/catppuccin/preview-unlock.png)
_Catppuccin_

 ![catppuccin-latte](../themes/catppuccin-latte/preview-unlock.png)
_Catppuccin Latte_

 ![ethereal](../themes/ethereal/preview-unlock.png)
_Ethereal_

 ![everforest](../themes/everforest/preview-unlock.png)
_Everforest_

 ![flexoki-light](../themes/flexoki-light/preview-unlock.png)
_Flexoki Light_

 ![gruvbox](../themes/gruvbox/preview-unlock.png)
_Gruvbox_

 ![hackerman](../themes/hackerman/preview-unlock.png)
_Hackerman_

 ![jade-horse](../themes/jade-horse/preview-unlock.png)
_Jade Horse_

 ![kanagawa](../themes/kanagawa/preview-unlock.png)
_Kanagawa_

 ![last-horizon](../themes/last-horizon/preview-unlock.png)
_Last Horizon_

 ![lumon](../themes/lumon/preview-unlock.png)
_Lumon_

 ![lupine](../themes/lupine/preview-unlock.png)
_Lupine_

 ![matte-black](../themes/matte-black/preview-unlock.png)
_Matte Black_

![miasma](../themes/miasma/preview-unlock.png)
_Miasma_

 ![nord](../themes/nord/preview-unlock.png)
_Nord_

 ![retro-82](../themes/retro-82/preview-unlock.png)
_Retro 82_

 ![ristretto](../themes/ristretto/preview-unlock.png)
_Ristretto_

![rose-pine](../themes/rose-pine/preview-unlock.png)
_Rose Pine_

 ![solitude](../themes/solitude/preview-unlock.png)
_Solitude_

 ![tokyo-night](../themes/tokyo-night/preview-unlock.png)
_Tokyo Night_

 ![vantablack](../themes/vantablack/preview-unlock.png)
_Vantablack_

 ![white](../themes/white/preview-unlock.png)
_White_
