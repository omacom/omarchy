# Ứng dụng web

Bạn có thể thêm ứng dụng web của riêng mình bằng _Cài đặt > Ứng dụng web_ trong menu Omarchy (`Super + Space`). Nó sẽ hỏi bạn tên ứng dụng, URL ứng dụng và URL biểu tượng, nếu nó không thể lấy được qua favicon. Bạn có thể nhận các biểu tượng PNG tuyệt vời cho nhiều ứng dụng web phổ biến trên [Dashboard Icons](https://dashboardicons.com).

Sau đó chúng sẽ có thể truy cập qua trình khởi chạy ứng dụng (`Super + Space`), và sử dụng cửa sổ ứng dụng web không khung tuyệt đẹp.

Nếu bạn muốn gỡ bỏ một ứng dụng web, chỉ cần vào _Gỡ bỏ > Ứng dụng web_ trong menu Omarchy.

Tốt nhất là bạn nên đăng nhập vào tất cả các tài khoản của mình bằng một trình duyệt thông thường trước khi dùng các phím tắt ứng dụng web. Khung bao mỏng không hoạt động tốt với 1password, vì vậy sẽ dễ hơn nếu bạn đã đăng nhập trực tiếp trước.

Mọi phím tắt cho các ứng dụng web này đều có thể thay đổi trong `~/.config/hypr/bindings.lua`.

Khi bạn đang ở trong một ứng dụng web, bạn có thể sao chép URL hiện tại vào khay nhớ tạm bằng `Shift + Alt + L`.

Theo mặc định, Omarchy đã đi kèm một loạt ứng dụng mặc định:

## HEY

[HEY](https://www.hey.com/) là một dịch vụ email và lịch, là lựa chọn thay thế tuyệt vời cho những ai đã chán Gmail, Outlook hoặc Apple Mail. Nó được tạo bởi [37signals](https://37signals.com/) nơi Omarchy bắt nguồn.

Bạn có thể khởi động HEY Email bằng `Super + Shift + E`, nhảy thẳng đến soạn một email mới bằng `Super + Shift + Alt + E`, và khởi động HEY Calendar bằng `Super + Shift + C`.

## Basecamp

[Basecamp](https://basecamp.com/) là một dịch vụ quản lý dự án giúp các nhóm nhỏ tiến nhanh hơn và đạt nhiều tiến bộ hơn. Thay vì chắp vá một mớ Trello, Slack, Asana, Notion hay bất cứ thứ gì khác, bạn có thể có tất cả ở một nơi với Basecamp. Nó được tạo bởi [37signals](https://37signals.com/) nơi Omarchy bắt nguồn.

Bạn có thể khởi động Basecamp bằng trình khởi chạy ứng dụng (`Super + Space`)

## ChatGPT

[ChatGPT](https://chatgpt.com) là chatbot AI phổ biến nhất trên thế giới.

Bạn có thể khởi động ChatGPT bằng `Super + Shift + A`.

## Grok

[Grok](https://grok.com) là chatbot của xAI.

Bạn có thể khởi động Grok bằng `Super + Shift + Alt + A`.

## WhatsApp

[WhatsApp](https://www.whatsapp.com/) là một trong những dịch vụ nhắn tin phổ biến nhất trên thế giới, và phiên bản web là một lựa chọn tuyệt vời cho Linux.

Bạn có thể khởi động WhatsApp bằng `Super + Shift + Alt + G`.

## Các ứng dụng Google

Google Messages, Google Photos, Google Maps và Google Contacts đều được bao gồm dưới dạng ứng dụng web.

Bạn có thể khởi động Google Messages bằng `Super + Shift + Ctrl + G`, Google Photos bằng `Super + Shift + P`, và Google Maps bằng `Super + Shift + S`. Google Contacts có sẵn qua trình khởi chạy ứng dụng (`Super + Space`).

## X

X là nơi tin tức bùng nổ.

Bạn có thể khởi động X bằng `Super + Shift + X` và đi thẳng đến việc viết một bài đăng mới bằng `Super + Shift + Alt + X`.

## YouTube

[YouTube](https://youtube.com/) là nền tảng video phổ biến nhất trên thế giới.

Bạn có thể khởi động YouTube bằng `Super + Shift + Y`.

## Zoom

[Zoom](https://zoom.us/) là hệ thống trò chuyện video phổ biến nhất được sử dụng tại Hoa Kỳ. Kết nối tuyệt vời trên toàn thế giới. Và các cuộc họp 40 phút có thể được tổ chức mà không cần tài khoản trả phí. Omarchy bao bọc ứng dụng web của Zoom, và các liên kết cuộc họp zoom sẽ mở thẳng vào đó.

Bạn khởi động Zoom bằng trình khởi chạy ứng dụng (`Super + Space`).

## Discord

[Discord](https://discord.com/) là nơi hầu hết các cộng đồng trò chơi và mã nguồn mở tụ họp, bao gồm cả [cộng đồng của chính Omarchy](https://discord.gg/tXFUdasqhY).

Bạn khởi động Discord bằng trình khởi chạy ứng dụng (`Super + Space`).

## Các ứng dụng Microsoft

Chọn _Cài đặt > Dịch vụ > Microsoft_ để thêm Outlook, Word, Excel, PowerPoint, Teams và OneDrive dưới dạng ứng dụng web. Mỗi ứng dụng có trình khởi chạy riêng và mở trực tiếp, sử dụng các URL thương mại của Microsoft 365 và hồ sơ trình duyệt hiện có của bạn. Chúng mở trong cùng các cửa sổ ứng dụng trình duyệt như các ứng dụng web khác của Omarchy; chúng không cài đặt ứng dụng Teams for Linux riêng biệt.

Gỡ bỏ gói bằng _Gỡ bỏ > Dịch vụ > Microsoft_, hoặc gỡ bỏ từng ứng dụng riêng lẻ bằng _Gỡ bỏ > Ứng dụng web_. Bạn cũng có thể cài đặt chỉ những ứng dụng bạn muốn qua _Cài đặt > Ứng dụng web_.

Đối với một đám mây của chính phủ hoặc có chủ quyền, hãy sửa URL trên dòng `Exec=` trong trình khởi chạy liên quan dưới `~/.local/share/applications/`, chẳng hạn như `Microsoft Teams.desktop`, bằng URL do tổ chức của bạn cung cấp. Viết bất kỳ ký tự `%` nguyên văn nào trong dòng đó thành `%%`. Các thay đổi có hiệu lực ở lần khởi chạy tiếp theo. Chạy lại trình cài đặt gói sẽ thay thế các trình khởi chạy của nó bằng các URL mặc định.

Để giữ các lần đăng nhập công việc tách biệt, hãy thêm một thư mục dữ liệu trình duyệt vào dòng `Exec=` của mỗi trình khởi chạy:

```ini
Exec=omarchy-launch-webapp "https://teams.cloud.microsoft/" --user-data-dir=/absolute/path/to/work-browser-profile
```

Thay thế thư mục ví dụ bằng một đường dẫn tuyệt đối do bạn chọn và dùng cùng một đường dẫn cho cả sáu trình khởi chạy để chia sẻ các lần đăng nhập công việc giữa chúng. Các ứng dụng web sử dụng trình duyệt được hỗ trợ mà Omarchy đã chọn, và quay về Chromium khi trình duyệt mặc định không được hỗ trợ.
