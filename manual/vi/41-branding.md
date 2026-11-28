# Thương hiệu

Omarchy cho phép bạn đặt logo công ty hoặc hình ảnh cá nhân của mình cho cả trình bảo vệ màn hình lẫn màn hình giới thiệu.

### Trình bảo vệ màn hình

Bạn có thể thay đổi logo dùng cho trình bảo vệ màn hình tại _Appearance > Branding > Screensaver_. Đó là một logo ASCII, nên bạn có thể chỉnh sửa trực tiếp phần chữ, nhưng bạn cũng có thể đưa cho nó một hình ảnh png hoặc svg, và chúng tôi sẽ chuyển đổi hình đó thành ASCII. Trông khá ngầu đấy.

 ![branding-screensaver](images/branding-screensaver.webp)

Có ba mục trong menu đó:

- **Edit Text** mở `~/.config/omarchy/branding/screensaver.txt` trong trình soạn thảo của bạn. Gõ hoặc dán bất cứ thứ gì bạn thích — tranh ASCII, tên của bạn, một từ thô tục. Lưu lại và thoát ra, và trình bảo vệ màn hình sẽ bật lên ngay lập tức để bạn xem.
- **Set From Image** mở trình chọn tệp cho một tệp png hoặc svg, chuyển đổi nó thành ASCII, và cho bạn xem kết quả. Các logo có hình bóng rõ ràng hiệu quả tốt hơn hẳn so với ảnh chụp.
- **Restore Default** đặt lại logo Omarchy.

### Màn hình giới thiệu

Ba tùy chọn tương tự nằm tại _Appearance > Branding > About_ dành cho màn hình _About_ mà bạn mở từ menu Omarchy, và chúng hoạt động y hệt — tệp là `~/.config/omarchy/branding/about.txt`, và cửa sổ About sẽ bật lên sau mỗi thay đổi. Tác phẩm About được chuyển đổi với kích thước nhỏ hơn của trình bảo vệ màn hình, vì nó phải vừa trong một cửa sổ thay vì phủ kín màn hình của bạn.

Khi cửa sổ đang mở, cứ vài giây lại có một dải ánh sáng trắng sáng nghiêng lướt qua tác phẩm rồi lại để nó đứng yên. Tác phẩm của riêng bạn cũng có hiệu ứng đó, miễn là mọi ký tự trong đó đều rộng một cột — mọi thứ do _Set From Image_ tạo ra đều như vậy. Tác phẩm được dựng từ emoji hoặc các ký tự có độ rộng gấp đôi thì thay vào đó sẽ đứng yên, và màn hình cũng vậy nếu bạn giữ một cấu hình fastfetch của riêng mình: logo đứng yên trong những trường hợp đó là do hoạt ảnh tự tránh sang một bên chứ không phải bị lỗi, vì trượt một vệt sáng qua chúng sẽ khiến phần còn lại của dòng rơi vào sai vị trí.

 ![branding-about](images/branding-about.webp)

### Tự chuyển đổi hình ảnh

Cả hai tùy chọn _Set From Image_ đều chỉ gọi `omarchy transcode ascii`, lệnh mà bạn có thể chạy trực tiếp nếu muốn kiểm soát quá trình chuyển đổi:

```
omarchy transcode ascii ~/logo.svg ~/.config/omarchy/branding/screensaver.txt --width 100
```

Nó nhận `--width` và `--height` theo số cột và số hàng của terminal, một `--mode` là `braille` (mặc định, và mịn hơn nhiều) hoặc `block`, một tỷ lệ phần trăm `--threshold` để quyết định pixel nào được tính là một phần của logo, và `--invert` cho trường hợp logo của bạn sáng trên nền tối. Nếu kết quả chuyển đổi trông như một cục nhòe, ngưỡng thường là nút vặn cần chỉnh.

### Chữ thay vì logo

`omarchy ascii` vẽ chữ bằng Delta Corps Priest 1, phông chữ FIGlet mà chính wordmark của Omarchy cũng được vẽ bằng nó, vì vậy một trình bảo vệ màn hình có thể nói điều gì đó thay vì hiển thị một bức tranh:

```
omarchy ascii "Back in five" > ~/.config/omarchy/branding/screensaver.txt
```

Nó nhận văn bản dưới dạng các đối số, hoặc đọc nó từ một pipe khi không được cung cấp đối số nào. Phông chữ chỉ có các chữ cái và dấu cách — nó được vẽ mà không có chữ số hay dấu câu — vì vậy bất kỳ thứ gì khác đều bị loại bỏ và được nêu tên trên stderr thay vì bị nuốt mất một cách lặng lẽ.
