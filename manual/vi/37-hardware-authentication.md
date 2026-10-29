# Xác thực phần cứng

### Xác thực vân tay

Rất nhiều laptop được trang bị cảm biến vân tay để xác thực. Bạn có thể dùng tính năng này với Omarchy bằng cách chạy _Setup > Security > Fingerprint_ trong menu Omarchy (`Super + Space`).

Thao tác đó sẽ cài đặt gói vân tay, thu thập vân tay của bạn, xác thực nó, và bạn sẽ sẵn sàng sử dụng vân tay để mở khóa từ màn hình khóa (mà bạn có thể kích hoạt bằng `Super + Ctrl + L`), vào chế độ sudo, và ủy quyền cho các lời nhắc của hệ thống.

Một khi màn hình khóa đã tắt màn hình, cảm biến sẽ nghỉ để tiết kiệm điện, vì vậy hãy đánh thức màn hình bằng bất kỳ phím nào hoặc touchpad trước khi chạm vào nó.

Khi nắp laptop của bạn đóng, lời nhắc vân tay sẽ tự động bị bỏ qua, vì vậy bạn sẽ đi thẳng đến lời nhắc mật khẩu thay vì chờ đợi một cảm biến mà bạn không thể chạm tới. Nếu trong trường hợp khác bạn cần làm việc trên một bàn phím ngoài không có cảm biến, chỉ cần nhấn `CTRL + C`, khi bạn được nhắc nhập vân tay trong lúc dùng `sudo`.

Bạn có thể gỡ bỏ xác thực vân tay trong _Remove > Security > Fingerprint_ ở menu Omarchy.

### Xác thực Fido2

Nếu bạn đang sử dụng thiết bị Fido2, bạn có thể thiết lập nó cho xác thực `sudo` bằng cách dùng _Setup > Security > Fido2_ trong menu Omarchy (`Super + Space`). Tuy nhiên, nó chỉ áp dụng cho `sudo` và các lời nhắc ủy quyền của hệ thống, chứ không dùng để mở khóa máy tính của bạn.

Bạn có thể gỡ bỏ xác thực fido2 trong _Remove > Security > Fido2_ ở menu Omarchy.
