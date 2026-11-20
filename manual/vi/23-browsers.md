# Trình duyệt

Omarchy đi kèm với [Google Chrome](https://www.google.com/chrome/) làm trình duyệt mặc định. Nó được áp theme để khớp với phần còn lại của hệ thống của bạn, và đó là thứ mà `Super + Shift + Return` mở ra và là nơi mọi [ứng dụng web](25-web-apps.md) chạy bên trong. Nó mở thẳng vào một cửa sổ trình duyệt: không có màn hình chào mừng hay lời nhắc đăng nhập, thống kê sử dụng và báo cáo sự cố không được gửi cho Google, và các lời nhắc về quyền riêng tư quảng cáo đã bị tắt. Bạn vẫn có thể đăng nhập vào tài khoản Google của mình từ nút hồ sơ bất cứ khi nào bạn muốn đồng bộ.

Nếu Chrome không hợp gu của bạn, bạn không bị kẹt với nó. Trong _Install > Browser_ ở menu Omarchy, bạn sẽ thấy [Chromium](https://www.chromium.org/) (bản dựng mã nguồn mở thuần túy mà Chrome được tạo ra từ đó), Edge, Brave, Brave Origin, Firefox, và [Zen](https://zen-browser.app/). Chọn một cái và Omarchy sẽ cài đặt nó, thiết lập thư mục policy của nó, và áp theme hiện tại của bạn cho nó.

## Đặt một trình duyệt làm mặc định

Cài đặt một trình duyệt không có nghĩa là đưa nó lên làm mặc định. Khi nó đã có trên máy, hãy vào _Setup > Defaults > Browser_ và chọn nó — menu chỉ liệt kê những trình duyệt bạn thực sự đã cài đặt, và đánh dấu trình duyệt mặc định hiện tại bằng một dấu kiểm.

Từ terminal thì là:

```bash
omarchy default browser firefox
```

Chạy lệnh đó mà không kèm đối số và nó sẽ cho bạn biết trình duyệt mặc định hiện tại. Việc này đặt XDG handler, nên không chỉ các phím tắt của Omarchy tuân theo — bất cứ thứ gì mở một liên kết, từ một ứng dụng chat đến một lệnh trong terminal, đều đi đến trình duyệt bạn đã chọn.

## Copy URL và Download Video

Các trình duyệt thuộc họ Chromium (bản thân Chromium, Chrome, Edge, và Brave) đi kèm với hai tiện ích mở rộng của Omarchy vươn ra ngoài trình duyệt và vào phần còn lại của hệ thống của bạn.

**Copy URL** đặt địa chỉ của tab hiện tại vào clipboard của bạn bằng `Alt + Shift + L`. Cách đó nhanh hơn việc nhấp vào thanh địa chỉ và sao chép, và vì nó đi qua clipboard của hệ thống chứ không phải của trình duyệt, bạn nhận được một thông báo của Omarchy xác nhận việc đó và URL ngay lập tức có sẵn trong [lịch sử clipboard](08-unified-clipboard-history.md) và mọi ứng dụng khác. Cũng có một nút trên thanh công cụ, nếu bạn thích nhấp chuột hơn.

**Download Video** lấy video đang phát trên trang bạn đang xem bằng `Alt + Shift + D`. Nó chuyển URL cho [yt-dlp](https://github.com/yt-dlp/yt-dlp), nên nó hoạt động trên nhiều thứ hơn hẳn YouTube, và bản tải xuống sẽ nằm trong `~/Videos`. Tiến trình hiển thị trong cùng một hiển thị trên màn hình mà âm lượng và độ sáng sử dụng, cập nhật tại chỗ thay vì chồng chất các thông báo. Đặt `OMARCHY_YTDLP_DIR` nếu bạn muốn các tệp đi đến nơi khác — xem [FAQ](46-faq.md) để biết nơi đặt các biến môi trường.

Cả hai tiện ích mở rộng đều giao tiếp với Omarchy thông qua một native messaging host nhỏ, thứ được cài đặt cho bạn cùng với trình duyệt. Đó là mảnh ghép cho phép video của một trang web kết thúc trong thư mục home của bạn và một URL kết thúc trong trình quản lý clipboard của bạn, điều mà một tiện ích mở rộng thông thường không thể tự làm được.

Những thứ này chỉ dành cho họ Chromium. Firefox và Zen không có chúng.

## Firefox và Zen

Firefox và Zen thuộc một họ khác, nên chúng được đối xử khác: Omarchy cài đặt một tệp policies cho các mặc định hợp lý và chuyển chúng sang chế độ Wayland gốc, thứ bạn muốn có để scaling phân số và cuộn bằng trackpad mượt mà.

Chúng không có các tiện ích mở rộng Chromium ở trên, và chúng không được Omarchy áp theme, nên những phần đó của trải nghiệm là do bạn tự thiết lập.

## Gỡ bỏ một trình duyệt

Bất kỳ trình duyệt nào trong số này, kể cả Chrome, đều có thể được gỡ bỏ lại trong _Remove > Browser_. Các liên kết sau đó sẽ đi đến Chrome hoặc Chromium nếu trình duyệt còn lại kia vẫn được cài đặt.
