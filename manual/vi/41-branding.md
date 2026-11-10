# Thương hiệu

Omarchy cho phép bạn đặt logo công ty hoặc hình ảnh cá nhân cho cả màn hình mở khóa khi khởi động, trình bảo vệ màn hình và màn hình giới thiệu.

### Mở khóa khi khởi động

Bạn có thể dùng `omarchy plymouth preview` để xem logo và màu sắc tùy chỉnh của bạn sẽ trông như thế nào. Lệnh này nhận một màu nền, một màu chữ, một logo png và một đường dẫn cho hình ảnh xem trước:

```
omarchy plymouth preview '#1d2021' '#ebdbb2' logo.png preview.png
```

Sau đó áp dụng thiết lập bằng `omarchy plymouth set '#1d2021' '#ebdbb2' logo.png`, lệnh này cũng sẽ áp dụng cùng màu sắc và logo cho màn hình đăng nhập SDDM. Nếu muốn khôi phục lại, bạn có thể dùng `omarchy plymouth reset`.

 ![branding-plymouth-shopify](images/branding-plymouth-shopify.webp)

### Trình bảo vệ màn hình

Bạn có thể thay đổi logo dùng cho trình bảo vệ màn hình trong _Appearance > Branding > Screensaver_. Đó là một logo ASCII, nên bạn có thể chỉnh sửa văn bản trực tiếp, nhưng bạn cũng có thể đưa cho nó một hình ảnh png hoặc svg, và chúng tôi sẽ chuyển đổi hình ảnh đó thành ASCII. Trông khá ngầu đấy.

 ![branding-screensaver](images/branding-screensaver.webp)

Có ba mục trong menu đó:

- **Chỉnh sửa văn bản** mở `~/.config/omarchy/branding/screensaver.txt` trong trình soạn thảo của bạn. Nhập hoặc dán bất cứ thứ gì bạn thích — nghệ thuật ASCII, tên của bạn, một từ thô tục. Lưu và thoát, và trình bảo vệ màn hình sẽ khởi động ngay lập tức để bạn có thể xem nó.
- **Đặt từ hình ảnh** mở một trình chọn tệp cho png hoặc svg, chuyển đổi nó thành ASCII và hiển thị kết quả cho bạn. Các logo có hình bóng rõ ràng hoạt động tốt hơn nhiều so với ảnh chụp.
- **Khôi phục mặc định** đưa logo Omarchy trở lại.

### Màn hình giới thiệu

Ba tùy chọn tương tự nằm trong _Appearance > Branding > About_ dành cho màn hình _About_ bạn mở từ menu Omarchy, và chúng hoạt động giống hệt — tệp là `~/.config/omarchy/branding/about.txt`, và cửa sổ About sẽ bật lên sau mỗi thay đổi. Hình ảnh About được chuyển đổi sang kích thước nhỏ hơn so với của trình bảo vệ màn hình, vì nó phải vừa trong một cửa sổ thay vì lấp đầy màn hình của bạn.

Khi cửa sổ đang mở, một vệt sáng xanh lục lướt nghiêng qua hình ảnh vài giây một lần rồi lại để nó đứng yên. Hình ảnh của chính bạn cũng có hiệu ứng đó, miễn là mọi ký tự trong đó đều rộng một cột — bất cứ thứ gì _Set From Image_ tạo ra đều như vậy. Hình ảnh được tạo từ emoji hoặc các ký tự có độ rộng gấp đôi sẽ đứng yên thay vào đó, và màn hình cũng vậy nếu bạn giữ một cấu hình fastfetch của riêng mình: một logo đứng yên trong những trường hợp đó là do hoạt ảnh tránh làm phiền chứ không phải bị lỗi, vì việc trượt một vệt sáng qua chúng sẽ khiến phần còn lại của dòng bị lệch vị trí.

 ![branding-about](images/branding-about.webp)

### Tự chuyển đổi hình ảnh

Cả hai tùy chọn _Set From Image_ đều chỉ đang gọi `omarchy transcode ascii`, lệnh mà bạn có thể chạy trực tiếp nếu muốn kiểm soát việc chuyển đổi:

```
omarchy transcode ascii ~/logo.svg ~/.config/omarchy/branding/screensaver.txt --width 100
```

Nó nhận `--width` và `--height` theo số cột và hàng của terminal, một `--mode` là `braille` (mặc định, và mịn hơn nhiều) hoặc `block`, một `--threshold` theo phần trăm để quyết định pixel nào được tính là một phần của logo, và `--invert` cho trường hợp logo của bạn sáng trên nền tối. Nếu một bản chuyển đổi cho ra một khối blob, threshold thường là núm cần vặn.

### Dùng chữ thay vì logo

`omarchy ascii` vẽ văn bản bằng Delta Corps Priest 1, font FIGlet mà chính wordmark của Omarchy được vẽ bằng nó, vì vậy một trình bảo vệ màn hình có thể nói điều gì đó thay vì hiển thị một hình ảnh:

```
omarchy ascii "Back in five" > ~/.config/omarchy/branding/screensaver.txt
```

Nó nhận văn bản dưới dạng đối số, hoặc đọc nó từ một pipe khi không được cung cấp đối số nào. Font này chỉ có chữ cái và dấu cách — nó được vẽ mà không có chữ số hay dấu câu — vì vậy bất cứ thứ gì khác sẽ bị loại bỏ và được nêu tên trên stderr thay vì bị âm thầm nuốt mất.
