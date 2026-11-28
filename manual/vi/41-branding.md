# Thương hiệu

Omarchy cho phép bạn đặt logo công ty hoặc hình ảnh cá nhân của mình cho cả màn hình mở khóa khi khởi động, trình bảo vệ màn hình và màn hình giới thiệu.

### Mở khóa khi khởi động

Bạn có thể dùng `omarchy plymouth preview` để xem logo và màu sắc tùy chỉnh của bạn sẽ trông như thế nào. Lệnh này nhận một màu nền, một màu chữ, một logo png và một đường dẫn cho hình ảnh xem trước:

```
omarchy plymouth preview '#1d2021' '#ebdbb2' logo.png preview.png
```

Sau đó áp dụng thiết lập bằng `omarchy plymouth set '#1d2021' '#ebdbb2' logo.png`, lệnh này cũng sẽ áp dụng cùng màu sắc và logo đó cho màn hình đăng nhập SDDM. Nếu bạn muốn hoàn nguyên, bạn có thể dùng `omarchy plymouth reset`.

 ![branding-plymouth-shopify](images/branding-plymouth-shopify.webp)

### Trình bảo vệ màn hình

Bạn có thể thay đổi logo dùng cho trình bảo vệ màn hình trong _Giao diện > Thương hiệu > Trình bảo vệ màn hình_. Đó là một logo ASCII, vì vậy bạn có thể chỉnh sửa trực tiếp văn bản, nhưng bạn cũng có thể đưa cho nó một hình ảnh png hoặc svg, và chúng tôi sẽ chuyển đổi hình ảnh đó thành ASCII. Trông nó khá ngầu.

 ![branding-screensaver](images/branding-screensaver.webp)

Có ba mục trong menu đó:

- **Chỉnh sửa văn bản** mở `~/.config/omarchy/branding/screensaver.txt` trong trình soạn thảo của bạn. Nhập hoặc dán bất cứ thứ gì bạn thích — hình ASCII, tên của bạn, một từ thô tục. Lưu và thoát, và trình bảo vệ màn hình sẽ khởi động ngay lập tức để bạn có thể nhìn thấy nó.
- **Đặt từ hình ảnh** mở một trình chọn tệp cho một tệp png hoặc svg, chuyển đổi nó thành ASCII và cho bạn xem kết quả. Các logo có hình bóng rõ ràng hoạt động tốt hơn nhiều so với ảnh chụp.
- **Khôi phục mặc định** đưa logo Omarchy trở lại.

### Màn hình giới thiệu

Ba tùy chọn tương tự nằm trong _Giao diện > Thương hiệu > Giới thiệu_ cho màn hình _Giới thiệu_ mà bạn mở từ menu Omarchy, và chúng hoạt động giống hệt — tệp là `~/.config/omarchy/branding/about.txt`, và cửa sổ Giới thiệu sẽ bật lên sau mỗi thay đổi. Hình Giới thiệu được chuyển đổi sang kích thước nhỏ hơn so với hình của trình bảo vệ màn hình, vì nó phải vừa trong một cửa sổ thay vì phủ kín màn hình hiển thị của bạn.

Trong khi cửa sổ đang mở, một dải ánh sáng trắng chói lướt nghiêng qua hình cứ sau vài giây rồi lại để nó đứng yên. Hình của riêng bạn cũng có hiệu ứng đó, miễn là mọi ký tự trong đó đều rộng một cột — mọi thứ mà _Đặt từ hình ảnh_ tạo ra đều như vậy. Hình được tạo từ emoji hoặc các ký tự có độ rộng gấp đôi sẽ đứng yên thay vào đó, và màn hình cũng vậy nếu bạn giữ một cấu hình fastfetch của riêng mình: một logo đứng yên trong những trường hợp đó là do hoạt ảnh tránh sang một bên chứ không phải bị lỗi, vì việc trượt một tia sáng lấp lánh qua chúng sẽ khiến phần còn lại của dòng nằm sai vị trí.

 ![branding-about](images/branding-about.webp)

### Tự chuyển đổi hình ảnh

Cả hai tùy chọn _Đặt từ hình ảnh_ đều chỉ đơn giản là gọi `omarchy transcode ascii`, lệnh mà bạn có thể chạy trực tiếp nếu muốn kiểm soát việc chuyển đổi:

```
omarchy transcode ascii ~/logo.svg ~/.config/omarchy/branding/screensaver.txt --width 100
```

Nó nhận `--width` và `--height` theo số cột và số hàng của terminal, một `--mode` là `braille` (mặc định, và mịn hơn nhiều) hoặc `block`, một tỷ lệ phần trăm `--threshold` để quyết định pixel nào được tính là một phần của logo, và `--invert` dành cho trường hợp logo của bạn sáng trên nền tối. Nếu kết quả chuyển đổi trông như một cục mờ, ngưỡng thường là nút vặn cần chỉnh.

### Chữ thay vì logo

`omarchy ascii` vẽ văn bản bằng Delta Corps Priest 1, phông chữ FIGlet mà chính wordmark của Omarchy được vẽ bằng phông đó, vì vậy trình bảo vệ màn hình có thể nói điều gì đó thay vì hiển thị một bức tranh:

```
omarchy ascii "Back in five" > ~/.config/omarchy/branding/screensaver.txt
```

Nó nhận văn bản dưới dạng các đối số, hoặc đọc văn bản từ một pipe khi không được cung cấp đối số nào. Phông chữ chỉ chứa các chữ cái và dấu cách — nó được vẽ mà không có chữ số hay dấu câu — vì vậy bất cứ thứ gì khác đều bị loại bỏ và được nêu tên trên stderr thay vì bị nuốt mất trong im lặng.
