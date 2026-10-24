# Bảng nhớ tạm & Lịch sử thống nhất

Thông thường trên Linux, bạn cần `Ctrl + Shift + C/V` để sao chép và dán trong terminal và `Ctrl + C/V` để làm điều đó ở khắp mọi nơi khác. Điều đó khó làm quen đối với bất kỳ ai chưa sinh ra và lớn lên trên Linux! Việc chuyển từ super sang ctrl cũng vậy, nếu bạn đến từ Mac.

Omarchy giải quyết cả hai vấn đề bằng các phím tắt bảng nhớ tạm thống nhất hoạt động (gần như) ở khắp mọi nơi. Chúng là:

| Phím tắt | Lệnh |
| ------- | ----------- |
| Super + C | Sao chép |
| Super + X | Cắt |
| Super + V | Dán |
| Super + Ctrl + V | Lịch sử bảng nhớ tạm |

_Lưu ý rằng hầu hết các khung agent sẽ dùng `Ctrl + V` để dán hình ảnh, nhưng `Super + V` để dán văn bản._

### Lịch sử bảng nhớ tạm

Lịch sử bảng nhớ tạm được cung cấp bởi shell Omarchy và hoạt động cho cả văn bản và hình ảnh. Bạn kích hoạt nó bằng `Super + Ctrl + V`, chọn mục của bạn bằng phím return, và sau đó mục đó sẽ được đặt trên bảng nhớ tạm sẵn sàng để dán bằng `Super + V`.

 ![clipboard-history](images/clipboard-history.webp)

Bạn cũng có thể tìm kiếm lịch sử chỉ bằng cách bắt đầu gõ:

 ![clipboard-history-search](images/clipboard-history-search.webp)
