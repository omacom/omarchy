# Clipboard thống nhất & Lịch sử

Thông thường trên Linux, bạn cần `Ctrl + Shift + C/V` để sao chép và dán trong terminal và `Ctrl + C/V` để làm điều đó ở mọi nơi khác. Thật khó làm quen với điều đó đối với bất kỳ ai không sinh ra và lớn lên cùng Linux! Việc chuyển từ Super sang Ctrl cũng vậy, nếu bạn chuyển đến từ Mac.

Omarchy giải quyết cả hai vấn đề bằng các phím tắt clipboard thống nhất hoạt động (gần như) ở mọi nơi. Chúng là:

| Phím tắt | Lệnh |
| ------- | ----------- |
| Super + A | Chọn tất cả |
| Super + C | Sao chép |
| Super + X | Cắt |
| Super + V | Dán |
| Super + Ctrl + V | Lịch sử clipboard |

_Lưu ý rằng hầu hết các agent harness sẽ dùng `Ctrl + V` để dán hình ảnh, nhưng dùng `Super + V` để dán văn bản._

Dùng `Super + A`, sau đó `Super + C` để sao chép mọi thứ trong một trường văn bản đang được focus hoặc ứng dụng khác hỗ trợ `Ctrl + A`. Trong terminal, `Ctrl + A` sẽ di chuyển đến đầu dòng lệnh thay vì chọn văn bản của nó.

### Lịch sử clipboard

Lịch sử clipboard được cung cấp bởi shell của Omarchy và hoạt động với cả văn bản và hình ảnh. Bạn kích hoạt nó bằng `Super + Ctrl + V`, chọn mục của bạn bằng phím Return, và mục đó sau đó sẽ được đặt vào clipboard, sẵn sàng để dán bằng `Super + V`.

 ![clipboard-history](images/clipboard-history.webp)

Bạn cũng có thể tìm kiếm trong lịch sử chỉ bằng cách bắt đầu gõ:

 ![clipboard-history-search](images/clipboard-history-search.webp)
