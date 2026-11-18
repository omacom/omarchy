# Chủ đề

Omarchy đi kèm với hai mươi hai chủ đề tuyệt đẹp. Bạn có thể lựa chọn giữa chúng qua _Giao diện > Chủ đề_ trong Omarchy Menu (`Super + Space`) hoặc nhảy thẳng tới bộ chọn chủ đề bằng `Super + Ctrl + T`.

Mỗi chủ đề định kiểu cho màn hình nền, terminal, neovim, màn hình hoạt động (btop), Chromium, và toàn bộ lớp vỏ Omarchy: thanh trên cùng, menu, thông báo, OSD, và màn hình khóa. (Đối với Obsidian, bạn phải tự chọn chủ đề Omarchy qua _Giao diện > Chủ đề_ bên trong ứng dụng).

Các chủ đề có một tập hợp hình nền mà bạn có thể lựa chọn giữa chúng bằng `Super + Ctrl + W`.

Bạn có thể tìm thêm nhiều chủ đề nữa trên [trang chủ đề bổ sung](https://omarchy.org/themes/) hoặc thậm chí [tự tạo chủ đề của riêng bạn](43-making-your-own-theme.md).

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

### Biểu tượng ứng dụng

Các biểu tượng trong trình khởi chạy ứng dụng và dock được vẽ theo màu sắc của chủ đề của bạn, vì vậy chúng thay đổi theo chủ đề. Chúng đến từ một bộ biểu tượng, mà bạn chọn riêng biệt với chủ đề dưới _Giao diện > Biểu tượng_, từ các bản xem trước của mỗi bộ, giống như cách bạn chọn một chủ đề:

- _Papercraft_ là mặc định: mọi thứ được cài đặt sẵn, được vẽ theo một phong cách duy nhất. Các ứng dụng được biết đến qua logo của chúng, như Chrome, HEY, hay YouTube, giữ nguyên hình dạng của chúng và khoác lên màu sắc của chủ đề.
- _Arcade_ vẽ cùng các ứng dụng đó dưới dạng nghệ thuật điểm ảnh 8-bit, như một máy chơi game console cũ sẽ vẽ.
- _Original_ hiển thị mọi ứng dụng với biểu tượng mà người tạo ra nó đã gán cho nó.

Bạn có thể cài đặt một bộ biểu tượng do người khác tạo bằng _Cài đặt > Phong cách > Biểu tượng_ (hoặc `omarchy icons install <git url>`), và gỡ bỏ nó lại dưới _Gỡ bỏ > Biểu tượng_. _Cập nhật > Biểu tượng bổ sung_ sẽ tải phiên bản mới nhất của các bộ bạn đã cài đặt.

Để tự tạo bộ của riêng bạn, hãy đặt các biểu tượng của bạn vào `~/.config/omarchy/icons/<name>/`, mỗi ứng dụng một tệp, được đặt tên theo dòng `Icon=` trong tệp `.desktop` của ứng dụng. Một tệp kết thúc bằng `.svg` sẽ được hiển thị nguyên như vậy. Một tệp kết thúc bằng `.svg.tpl` sẽ được vẽ theo màu sắc của chủ đề: hãy viết `{{ icon_main }}`, `{{ icon_mark }}`, `{{ icon_paper }}`, `{{ icon_body }}`, `{{ icon_edge }}`, `{{ icon_ink }}` hoặc `{{ icon_shadow }}` tại vị trí cần đặt một màu. Bộ mặc định trong `/usr/share/omarchy/icons/papercraft/` là một điểm khởi đầu tốt. Hãy thêm một tệp `preview.png` để hiển thị bộ của bạn trong bộ chọn; nếu không có, Omarchy sẽ vẽ một bản xem trước từ các biểu tượng của bạn. Để thay đổi một biểu tượng duy nhất của bộ mặc định, hãy đặt phiên bản của bạn vào `~/.config/omarchy/icons/papercraft/`.

### Mở khóa

Các chủ đề cũng có thể có một thiết kế mở khóa tùy chỉnh, được sử dụng cho quá trình giải mã khi khởi động. Bạn có thể chọn một trong số chúng dưới _Giao diện > Mở khóa_. Chúng trông như thế này:

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

 ![lumon](../themes/lumon/preview-unlock.png)
_Lumon_

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

 ![tokyo-night](../themes/tokyo-night/preview-unlock.png)
_Tokyo Night_

 ![vantablack](../themes/vantablack/preview-unlock.png)
_Vantablack_

 ![white](../themes/white/preview-unlock.png)
_White_
