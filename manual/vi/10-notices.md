# Thông báo

Thông báo xuất hiện ở góc trên bên phải của màn hình đang được tập trung. Bạn cũng có thể nhanh chóng truy cập ngày và giờ, trạng thái pin và thời tiết hiện tại bằng các thông báo phím nóng.

## Thông báo

Thông báo từ cùng một ứng dụng hoặc trang web xếp chồng thành một bộ, vì vậy một kênh Slack ồn ào sẽ không đẩy thông báo lỗi build của bạn ra khỏi màn hình. Di chuột qua một bộ để xòe nó ra; không có gì mới trượt vào dưới con trỏ của bạn trong khi bạn đang đọc. Nhấp vào một thẻ để nhảy đến nơi nó xuất phát, nhấp chuột phải, nhấp chuột giữa, hoặc nhấn ✕ để loại bỏ nó.

Thẻ cung cấp những gì chúng mang theo: _Copy code_ cho mã xác minh (được giữ ngoài [lịch sử clipboard](08-unified-clipboard-history.md) và bị xóa sau một phút), cùng với bất kỳ nút nào ứng dụng cung cấp. Liên kết trong văn bản của thông báo sẽ mở khi được nhấp.

`Super + ,` loại bỏ thông báo mới nhất, hoặc mở thứ nó trỏ tới khi nó cung cấp điều đó, `Super + Alt + ,` chỉ loại bỏ thông báo cuối cùng, `Super + Shift + ,` loại bỏ tất cả, và `Super + Shift + Alt + ,` mở lịch sử. Để sử dụng chúng mà không cần chuột, nhấn `Super + Ctrl + ,`. Thông báo mới nhất được chọn và các nút của nó được đánh số: nhấn một số để dùng một nút, `Enter` để nhấp vào thông báo, `↑` và `↓` để di chuyển giữa các thông báo, `Delete` để loại bỏ một thông báo, và `Esc` để trả lại bàn phím. Nó cũng tự nhả ra sau vài giây không hoạt động.

Tắt tiếng thông báo sẽ giữ chúng lại, ngoại trừ các xác nhận của chính Omarchy, cảnh báo khẩn cấp và mã xác minh mà bạn vừa yêu cầu cách đây ít lâu. Đưa vài thông báo gần nhất trở lại màn hình, bị giữ lại hay không, bằng `Super + Shift + Alt + ,`. Lịch sử được giữ trong một ngày.

## Thông báo phím nóng

### Ngày & Giờ

`Super + Ctrl + Alt + T`

 ![notice-datetime](images/notice-datetime.webp)

### Thời tiết

`Super + Ctrl + Alt + W`

 ![notice-weather](images/notice-weather.webp)

Vị trí được phát hiện từ địa chỉ IP của bạn, thường đủ gần, nhưng không phải lúc nào cũng vậy. Bạn có thể ghim nó lại bằng `omarchy weather location --set Malibu`, hoặc chính xác về nó bằng cách thêm tọa độ: `omarchy weather location --set Malibu 34.0259,-118.7798`. Chạy `omarchy weather location` riêng lẻ để xem nó nghĩ bạn đang ở đâu, và `--clear` để quay lại tự động phát hiện.

### Pin

`Super + Ctrl + Alt + B`

 ![notice-battery](images/notice-battery.webp)
