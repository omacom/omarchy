# Ứng dụng Web

Bạn có thể thêm các ứng dụng web của riêng mình bằng _Install > Web App_ trong menu Omarchy (`Super + Space`). Nó sẽ yêu cầu bạn nhập tên ứng dụng, URL của ứng dụng và URL của biểu tượng, nếu nó không thể lấy được biểu tượng qua favicon. Bạn có thể lấy các biểu tượng PNG tuyệt vời cho nhiều ứng dụng web phổ biến trên [Dashboard Icons](https://dashboardicons.com).

Sau đó, chúng sẽ có thể truy cập được qua trình khởi chạy ứng dụng (`Super + Space`), và sử dụng cửa sổ ứng dụng web không viền đẹp đẽ.

Nếu bạn muốn xóa một ứng dụng web, chỉ cần vào _Remove > Web App_ trong menu Omarchy.

Tốt nhất là bạn nên đăng nhập vào tất cả các tài khoản của mình bằng một trình duyệt thông thường trước khi dùng các phím tắt ứng dụng web. Khung bao mỏng này không hoạt động tốt với 1password, nên cứ đăng nhập trực tiếp trước cho dễ.

Tất cả các phím tắt cho các ứng dụng web này đều có thể thay đổi trong `~/.config/hypr/bindings.lua`.

Khi đang ở trong một ứng dụng web, bạn có thể sao chép URL hiện tại vào clipboard bằng `Shift + Alt + L`.

Theo mặc định, Omarchy đã đi kèm sẵn một loạt ứng dụng mặc định:

## HEY

[HEY](https://www.hey.com/) là một dịch vụ email và lịch, đóng vai trò là lựa chọn thay thế tuyệt vời cho những người đã chán Gmail, Outlook hoặc Apple Mail. Nó được làm bởi [37signals](https://37signals.com/), nơi Omarchy ra đời.

Bạn có thể khởi động HEY Email bằng `Super + Shift + E`, nhảy thẳng đến việc soạn một email mới bằng `Super + Shift + Alt + E`, và khởi động HEY Calendar bằng `Super + Shift + C`.

## Basecamp

[Basecamp](https://basecamp.com/) là một dịch vụ quản lý dự án giúp các đội nhỏ làm việc nhanh hơn và đạt được nhiều tiến bộ hơn. Thay vì chắp vá một mớ hỗn độn gồm Trello, Slack, Asana, Notion hay bất cứ thứ gì khác, bạn có thể có tất cả trong một nơi với Basecamp. Nó được làm bởi [37signals](https://37signals.com/), nơi Omarchy ra đời.

Bạn có thể khởi động Basecamp bằng trình khởi chạy ứng dụng (`Super + Space`)

## ChatGPT

[ChatGPT](https://chatgpt.com) là chat bot AI phổ biến nhất thế giới.

Bạn có thể khởi động ChatGPT bằng `Super + Shift + A`.

## Grok

[Grok](https://grok.com) là chat bot của xAI.

Bạn có thể khởi động Grok bằng `Super + Shift + Alt + A`.

## WhatsApp

[WhatsApp](https://www.whatsapp.com/) là một trong những dịch vụ nhắn tin phổ biến nhất thế giới, và phiên bản web là một lựa chọn tuyệt vời cho Linux.

Bạn có thể khởi động WhatsApp bằng `Super + Shift + Alt + G`.

## Các ứng dụng Google

Google Messages, Google Photos, Google Maps và Google Contacts cũng đều được bao gồm dưới dạng ứng dụng web.

Bạn có thể khởi động Google Messages bằng `Super + Shift + Ctrl + G`, Google Photos bằng `Super + Shift + P`, và Google Maps bằng `Super + Shift + S`. Google Contacts có sẵn qua trình khởi chạy ứng dụng (`Super + Space`).

## X

X là nơi tin nóng nổ ra.

Bạn có thể khởi động X bằng `Super + Shift + X` và đi thẳng đến việc viết một bài đăng mới bằng `Super + Shift + Alt + X`.

## YouTube

[YouTube](https://youtube.com/) là nền tảng video phổ biến nhất thế giới.

Bạn có thể khởi động YouTube bằng `Super + Shift + Y`.

## Zoom

[Zoom](https://zoom.us/) là hệ thống trò chuyện video phổ biến nhất được dùng ở Mỹ. Các kết nối tuyệt vời trên khắp thế giới. Và các cuộc họp kéo dài 40 phút có thể được tổ chức mà không cần tài khoản trả phí. Omarchy bao bọc client web của Zoom, và các liên kết cuộc họp zoom sẽ mở thẳng vào đó.

Bạn khởi động Zoom bằng trình khởi chạy ứng dụng (`Super + Space`).

## Discord

[Discord](https://discord.com/) là nơi hầu hết các cộng đồng gaming và mã nguồn mở tụ tập, bao gồm cả [cộng đồng của riêng Omarchy](https://discord.gg/tXFUdasqhY).

Bạn khởi động Discord bằng trình khởi chạy ứng dụng (`Super + Space`).

## Các ứng dụng Microsoft

Chọn _Install > Service > Microsoft_ để thêm Outlook, Word, Excel, PowerPoint, Teams và OneDrive dưới dạng ứng dụng web. Mỗi ứng dụng có trình khởi chạy riêng và mở trực tiếp, sử dụng các URL Microsoft 365 thương mại và hồ sơ trình duyệt hiện có của bạn. Chúng mở trong cùng các cửa sổ ứng dụng trình duyệt như các ứng dụng web khác của Omarchy; chúng không cài đặt client Teams for Linux riêng biệt.

Xóa gói này bằng _Remove > Service > Microsoft_, hoặc xóa từng ứng dụng riêng lẻ bằng _Remove > Web App_. Bạn cũng có thể cài đặt chỉ những ứng dụng bạn muốn qua _Install > Web App_.

Đối với đám mây chính phủ hoặc đám mây có chủ quyền, hãy chỉnh sửa URL trên dòng `Exec=` trong trình khởi chạy liên quan dưới `~/.local/share/applications/`, chẳng hạn như `Microsoft Teams.desktop`, sử dụng URL do tổ chức của bạn cung cấp. Viết bất kỳ dấu `%` theo nghĩa đen nào trong dòng đó dưới dạng `%%`. Các thay đổi sẽ áp dụng vào lần khởi động tiếp theo. Chạy lại trình cài đặt gói sẽ thay thế các trình khởi chạy của nó bằng các URL mặc định.

Để giữ các lần đăng nhập công việc tách biệt, hãy thêm một thư mục dữ liệu trình duyệt vào dòng `Exec=` của mỗi trình khởi chạy:

```ini
Exec=omarchy-launch-webapp "https://teams.cloud.microsoft/" --user-data-dir=/absolute/path/to/work-browser-profile
```

Thay thư mục ví dụ bằng một đường dẫn tuyệt đối do bạn chọn và sử dụng cùng một đường dẫn cho cả sáu trình khởi chạy để chia sẻ các lần đăng nhập công việc giữa chúng. Các ứng dụng web sử dụng trình duyệt được hỗ trợ mà Omarchy đã chọn, và sẽ chuyển sang dùng Chrome khi trình duyệt mặc định không được hỗ trợ.
