# Trình duyệt

Omarchy đi kèm [Chromium](https://www.chromium.org/) làm trình duyệt mặc định. Đây là bản dựng mã nguồn mở thuần, được tùy chỉnh giao diện để khớp với phần còn lại của hệ thống của bạn, và nó là thứ mà `Super + Shift + Return` mở ra cũng như là nơi mọi [ứng dụng web](25-web-apps.md) chạy bên trong.

Nếu Chromium không hợp khẩu vị của bạn, bạn không bị kẹt với nó. Trong _Cài đặt > Trình duyệt_ của menu Omarchy, bạn sẽ tìm thấy Chrome, Edge, Brave, Brave Origin, Firefox và [Zen](https://zen-browser.app/). Chọn một cái và Omarchy sẽ cài đặt nó, thiết lập thư mục chính sách của nó, và áp dụng giao diện hiện tại của bạn cho nó.

## Đặt một trình duyệt làm mặc định

Cài đặt một trình duyệt không biến nó thành mặc định. Khi nó đã có trên máy, hãy vào _Thiết lập > Mặc định > Trình duyệt_ và chọn nó — menu chỉ liệt kê các trình duyệt bạn thực sự đã cài đặt, và đánh dấu mặc định hiện tại bằng một dấu tích.

Từ terminal, lệnh là:

```bash
omarchy default browser firefox
```

Chạy nó mà không có đối số và nó sẽ cho bạn biết mặc định hiện tại. Lệnh này đặt trình xử lý XDG, vì vậy không chỉ các phím tắt của Omarchy tuân theo — bất cứ thứ gì mở một liên kết, từ ứng dụng trò chuyện đến một lệnh terminal, đều đi đến trình duyệt bạn đã chọn.

## Sao chép URL và Tải video

Các trình duyệt họ Chromium (chính Chromium, Chrome, Edge và Brave) đi kèm hai tiện ích mở rộng của Omarchy vươn ra ngoài trình duyệt và vào phần còn lại của hệ thống của bạn.

**Copy URL** đặt địa chỉ của tab hiện tại vào khay nhớ tạm của bạn bằng `Alt + Shift + L`. Điều đó nhanh hơn việc nhấp vào thanh địa chỉ và sao chép, và vì nó đi qua khay nhớ tạm của hệ thống thay vì của trình duyệt, bạn nhận được một thông báo của Omarchy xác nhận điều đó và URL ngay lập tức có sẵn trong [lịch sử khay nhớ tạm](08-unified-clipboard-history.md) và mọi ứng dụng khác. Ngoài ra còn có một nút trên thanh công cụ, nếu bạn thích nhấp chuột.

**Download Video** tải video đang phát trên trang bạn đang xem bằng `Alt + Shift + D`. Nó truyền URL cho [yt-dlp](https://github.com/yt-dlp/yt-dlp), vì vậy nó hoạt động trên nhiều thứ hơn là YouTube, và bản tải về nằm trong `~/Videos`. Tiến trình hiển thị trong cùng một màn hình hiển thị trên màn hình mà âm lượng và độ sáng sử dụng, cập nhật tại chỗ thay vì xếp chồng các thông báo. Đặt `OMARCHY_YTDLP_DIR` nếu bạn muốn các tệp đi đến nơi khác — xem [FAQ](46-faq.md) để biết nơi đặt các biến môi trường.

Cả hai tiện ích mở rộng đều giao tiếp với Omarchy thông qua một máy chủ nhắn tin gốc nhỏ, được cài đặt cho bạn cùng với trình duyệt. Đó là thành phần cho phép video của một trang web kết thúc trong thư mục nhà của bạn và một URL kết thúc trong trình quản lý khay nhớ tạm của bạn, điều mà một tiện ích mở rộng thông thường không thể tự làm được.

Những tính năng này chỉ dành cho họ Chromium. Firefox và Zen không có chúng.

## Firefox và Zen

Firefox và Zen thuộc một họ khác, vì vậy chúng nhận được sự đối xử khác: Omarchy cài đặt một tệp chính sách cho các mặc định hợp lý và chuyển chúng sang chế độ Wayland gốc, điều bạn muốn để có chia tỷ lệ phân đoạn và cuộn bằng bàn di chuột mượt mà.

Chúng không nhận được các tiện ích mở rộng Chromium ở trên, và chúng không được Omarchy tùy chỉnh giao diện, vì vậy những phần đó của trải nghiệm là do bạn tự thiết lập.

## Gỡ bỏ một trình duyệt

Bất cứ thứ gì bạn đã cài đặt ở đây đều có thể gỡ bỏ trong _Gỡ bỏ > Trình duyệt_. Chromium không có trong danh sách đó — nó là một phần của hệ thống cơ sở.
