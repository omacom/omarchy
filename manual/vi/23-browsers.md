# Trình duyệt

Omarchy đi kèm với [Google Chrome](https://www.google.com/chrome/) làm trình duyệt mặc định. Nó được áp dụng giao diện để khớp với phần còn lại của hệ thống của bạn, và đó là thứ mà `Super + Shift + Return` (hoặc `Super + Shift + B`) mở ra, với `Super + Shift + Alt + B` cho một cửa sổ riêng tư, và là nơi mọi [ứng dụng web](25-web-apps.md) chạy bên trong. Nó mở thẳng vào một cửa sổ trình duyệt: không có màn hình chào mừng hay lời nhắc đăng nhập, thống kê sử dụng và báo cáo sự cố không được gửi tới Google, và các lời nhắc về quyền riêng tư quảng cáo đã bị tắt. Bạn vẫn có thể đăng nhập vào tài khoản Google của mình từ nút hồ sơ bất cứ khi nào bạn muốn đồng bộ hóa.

Nếu Chrome không hợp gu của bạn, bạn không bị kẹt với nó. Trong _Cài đặt > Trình duyệt_ ở menu Omarchy, bạn sẽ tìm thấy [Chromium](https://www.chromium.org/) (bản dựng mã nguồn mở thuần túy mà Chrome được tạo ra từ đó), Edge, Brave, Brave Origin, Firefox, [Zen](https://zen-browser.app/), và [Ladybird](https://ladybird.org/) (Edge chỉ có trên các máy x86). Chọn một trình duyệt và Omarchy sẽ cài đặt nó, thiết lập thư mục chính sách của nó, và áp dụng giao diện hiện tại của bạn cho nó.

## Đặt một trình duyệt làm mặc định

Cài đặt một trình duyệt không tự đưa nó lên làm mặc định. Để chuyển đổi, hãy vào _Thiết lập > Mặc định > Trình duyệt_ và chọn một trình duyệt. Trình duyệt mặc định hiện tại được đánh dấu bằng một dấu kiểm, và việc chọn một trình duyệt bạn chưa có sẽ cài đặt nó trước.

Từ terminal, lệnh là:

```bash
omarchy default browser firefox
```

Chạy lệnh mà không có đối số và nó sẽ cho bạn biết trình duyệt mặc định hiện tại. Thao tác này đặt trình xử lý XDG, vì vậy không chỉ các phím tắt của Omarchy tuân theo — bất cứ thứ gì mở một liên kết, từ một ứng dụng trò chuyện đến một lệnh terminal, đều đi tới trình duyệt bạn đã chọn.

## Sao chép URL và tải video

Các trình duyệt thuộc họ Chromium (bản thân Chromium, Chrome, Edge, Brave, và Brave Origin) đi kèm với ba tiện ích mở rộng của Omarchy: hai tiện ích vươn ra khỏi trình duyệt và vào phần còn lại của hệ thống của bạn, và một tiện ích dọn dẹp WhatsApp cho gọn gàng.

**Copy URL** đặt địa chỉ của tab hiện tại vào clipboard của bạn bằng `Alt + Shift + L`. Cách đó nhanh hơn việc nhấp vào thanh địa chỉ và sao chép, và vì nó đi qua clipboard của hệ thống thay vì của trình duyệt, bạn nhận được một thông báo của Omarchy xác nhận điều đó và URL ngay lập tức có sẵn trong [lịch sử clipboard](08-unified-clipboard-history.md) và mọi ứng dụng khác. Cũng có một nút trên thanh công cụ, nếu bạn thích nhấp chuột hơn.

**Download Video** lấy video đang phát trên trang bạn đang xem bằng `Alt + Shift + D`. Nó chuyển URL cho [yt-dlp](https://github.com/yt-dlp/yt-dlp), vì vậy nó hoạt động trên nhiều thứ hơn hẳn YouTube, và bản tải xuống sẽ nằm trong `~/Videos`. Tiến trình hiển thị trong cùng một hiển thị trên màn hình mà âm lượng và độ sáng sử dụng, cập nhật tại chỗ thay vì xếp chồng các thông báo. Đặt `OMARCHY_YTDLP_DIR` nếu bạn muốn các tệp đi tới nơi khác — xem [FAQ](46-faq.md) để biết nơi đặt các biến môi trường.

Cả hai tiện ích mở rộng đều giao tiếp với Omarchy thông qua một native messaging host nhỏ, được cài đặt cho bạn cùng với trình duyệt. Đó là thành phần cho phép video của một trang web kết thúc trong thư mục chính của bạn và một URL kết thúc trong trình quản lý clipboard của bạn, điều mà một tiện ích mở rộng thông thường không thể tự làm được.

**WhatsApp Slim** giúp WhatsApp Web tuân theo giao diện hệ thống của bạn và thu gọn danh sách trò chuyện của nó khi cửa sổ hẹp.

Những tiện ích này chỉ dành cho họ Chromium. Firefox và Zen không có chúng.

## Firefox và Zen

Firefox và Zen thuộc một họ khác, vì vậy chúng được đối xử khác: Omarchy cài đặt một tệp policies cho các giá trị mặc định hợp lý và chuyển chúng sang chế độ Wayland gốc, điều bạn muốn để có chia tỷ lệ phân số và cuộn trackpad mượt mà.

Chúng không nhận được các tiện ích mở rộng Chromium ở trên, và chúng không được Omarchy áp dụng giao diện, vì vậy những phần đó của trải nghiệm là do bạn tự thiết lập.

## Ladybird

Ladybird là một trình duyệt được viết từ đầu, với engine riêng của nó thay vì của Chromium hay Firefox. Nó vẫn đang ở giai đoạn alpha, vì vậy hãy lường trước việc có những trang web chưa hoạt động, và Omarchy cài đặt nó nguyên trạng như khi nó đến: không tiện ích mở rộng, không giao diện, không chính sách. Nó cũng không có cửa sổ riêng tư, vì vậy `Super + Shift + Alt + B` mở nó với một hồ sơ tạm thời sẽ bị xóa khi bạn đóng nó. [Ứng dụng web](25-web-apps.md) vẫn tiếp tục chạy trong Chrome hoặc Chromium.

## Gỡ bỏ một trình duyệt

Bất kỳ trình duyệt nào trong số này, kể cả Chrome, đều có thể được gỡ bỏ lại trong _Gỡ bỏ > Trình duyệt_. Các liên kết sau đó sẽ đi tới Chrome hoặc Chromium nếu trình duyệt còn lại vẫn được cài đặt.
