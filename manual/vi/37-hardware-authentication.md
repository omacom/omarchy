# Xác thực phần cứng

### Xác thực bằng vân tay

Rất nhiều laptop được trang bị cảm biến vân tay để xác thực. Bạn có thể dùng tính năng này với Omarchy bằng cách chạy _Setup > Security > Fingerprint_ trong menu Omarchy (`Super + Space`).

Thao tác đó sẽ mở một hình vân tay toàn màn hình, hình này sẽ được tô đầy dần khi bạn chạm vào cảm biến. Ở phía sau, Omarchy sẽ cài gói vân tay, thu thập dấu vân tay của bạn, xác minh nó, và bạn sẽ sẵn sàng dùng vân tay để mở khóa từ màn hình khóa (màn hình mà bạn có thể kích hoạt bằng `Super + Ctrl + L`), vào chế độ sudo, và xác thực các hộp thoại hệ thống.

Khi màn hình khóa đã tắt màn hình, cảm biến sẽ nghỉ để tiết kiệm điện, vì vậy hãy đánh thức màn hình bằng bất kỳ phím nào hoặc bàn di chuột trước khi chạm vào cảm biến.

Khi nắp laptop của bạn đang đóng, hộp thoại vân tay sẽ tự động bị bỏ qua, vì vậy bạn sẽ đi thẳng tới hộp thoại mật khẩu thay vì phải chờ một cảm biến mà bạn không thể chạm tới. Nếu trong trường hợp khác bạn cần làm việc trên một bàn phím ngoài không có cảm biến, chỉ cần nhấn `CTRL + C` khi bạn được yêu cầu nhập vân tay trong lúc dùng `sudo`.

Bạn có thể gỡ bỏ xác thực bằng vân tay tại _Remove > Security > Fingerprint_ trong menu Omarchy.

### Xác thực Fido2

Nếu bạn đang dùng một thiết bị Fido2, bạn có thể thiết lập nó cho xác thực `sudo` bằng cách dùng _Setup > Security > Fido2_ trong menu Omarchy (`Super + Space`). Tuy nhiên, nó bao gồm `sudo` và các hộp thoại ủy quyền hệ thống, chứ không phải mở khóa máy tính của bạn.

Bạn có thể gỡ bỏ xác thực fido2 tại _Remove > Security > Fido2_ trong menu Omarchy.
