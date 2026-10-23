# Thương hiệu

Omarchy cho phép bạn đặt logo công ty hoặc hình ảnh cá nhân của bạn cho cả màn hình mở khóa khi khởi động, trình bảo vệ màn hình và màn hình giới thiệu.

### Mở khóa khi khởi động

Bạn có thể dùng `omarchy plymouth preview` để xem logo và màu sắc tùy chỉnh của bạn sẽ trông như thế nào. Nó nhận một màu nền, một màu chữ, một tệp png logo và một đường dẫn cho hình ảnh xem trước:

```
omarchy plymouth preview '#1d2021' '#ebdbb2' logo.png preview.png
```

Sau đó áp dụng thiết lập bằng `omarchy plymouth set '#1d2021' '#ebdbb2' logo.png`, lệnh này cũng sẽ cho màn hình đăng nhập SDDM cùng màu sắc và logo. Nếu bạn muốn quay lại, bạn có thể dùng `omarchy plymouth reset`.

 ![branding-plymouth-shopify](images/branding-plymouth-shopify.webp)

### Bảo vệ màn hình

Bạn có thể thay đổi logo dùng cho trình bảo vệ màn hình dưới _Phong cách > Bảo vệ màn hình_. Đó là một logo ASCII, nên bạn có thể sửa văn bản trực tiếp, nhưng bạn cũng có thể đưa cho nó một hình ảnh png hoặc svg, và chúng tôi sẽ chuyển nó thành ASCII. Trông khá ngầu.

 ![branding-screensaver](images/branding-screensaver.webp)

Có ba mục trong menu đó:

- **Sửa văn bản** mở `~/.config/omarchy/branding/screensaver.txt` trong trình soạn thảo của bạn. Gõ hoặc dán bất cứ thứ gì bạn thích — nghệ thuật ASCII, tên của bạn, một từ thô lỗ. Lưu và thoát, và trình bảo vệ màn hình sẽ khởi động ngay lập tức để bạn có thể nhìn thấy nó.
- **Đặt từ hình ảnh** mở một bộ chọn tệp cho một tệp png hoặc svg, chuyển nó thành ASCII và cho bạn xem kết quả. Các logo có bóng rõ nét hoạt động tốt hơn nhiều so với ảnh chụp.
- **Khôi phục mặc định** đưa logo Omarchy trở lại.

### Màn hình giới thiệu

Ba tùy chọn tương tự nằm dưới _Phong cách > Giới thiệu_ cho màn hình _Giới thiệu_ mà bạn nhận được từ menu Omarchy, và chúng hoạt động y hệt nhau — tệp là `~/.config/omarchy/branding/about.txt`, và cửa sổ Giới thiệu bật lên sau mỗi lần thay đổi. Nghệ thuật của Giới thiệu được chuyển đổi thành kích thước nhỏ hơn so với của trình bảo vệ màn hình, vì nó phải vừa trong một cửa sổ thay vì lấp đầy màn hình của bạn.

Trong khi cửa sổ đang mở, một tia sáng xanh lá nghiêng qua tác phẩm nghệ thuật vài giây một lần rồi lại để nó đứng yên. Nghệ thuật của riêng bạn cũng nhận được hiệu ứng đó, miễn là mọi ký tự trong đó đều rộng một cột — bất cứ thứ gì _Đặt từ hình ảnh_ tạo ra đều như vậy. Nghệ thuật được xây dựng từ emoji hoặc các ký tự có độ rộng gấp đôi sẽ đứng yên thay vào đó, và màn hình cũng vậy nếu bạn giữ một cấu hình fastfetch của riêng mình: một logo đứng yên trong những trường hợp đó là hiệu ứng đang tránh đường chứ không phải bị lỗi, vì việc trượt một tia sáng qua chúng sẽ khiến phần còn lại của dòng rơi vào sai vị trí.

 ![branding-about](images/branding-about.webp)

### Tự chuyển đổi hình ảnh

Cả hai tùy chọn _Đặt từ hình ảnh_ đều chỉ đang gọi `omarchy transcode ascii`, lệnh mà bạn có thể chạy trực tiếp nếu muốn kiểm soát quá trình chuyển đổi:

```
omarchy transcode ascii ~/logo.svg ~/.config/omarchy/branding/screensaver.txt --width 100
```

Nó nhận `--width` và `--height` theo cột và hàng của terminal, một `--mode` là `braille` (mặc định, và mịn hơn nhiều) hoặc `block`, một tỷ lệ phần trăm `--threshold` để quyết định những pixel nào được tính là một phần của logo, và `--invert` cho trường hợp logo của bạn sáng trên nền tối. Nếu một bản chuyển đổi cho ra một cục mờ, ngưỡng thường là núm cần vặn.

### Chữ thay vì logo

`omarchy ascii` vẽ văn bản bằng Delta Corps Priest 1, phông chữ FIGlet mà chính wordmark của Omarchy được vẽ bằng, nên một trình bảo vệ màn hình có thể nói điều gì đó thay vì hiển thị một bức tranh:

```
omarchy ascii "Back in five" > ~/.config/omarchy/branding/screensaver.txt
```

Nó nhận văn bản dưới dạng đối số, hoặc đọc nó từ một pipe khi không được cho đối số nào. Phông chữ chỉ mang các chữ cái và dấu cách — nó được vẽ mà không có chữ số hoặc dấu câu — nên bất cứ thứ gì khác đều bị loại bỏ và được nêu tên trên stderr thay vì bị nuốt lặng lẽ.
