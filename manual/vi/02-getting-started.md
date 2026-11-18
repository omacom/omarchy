# Bắt đầu

Omarchy được cài đặt bằng một ISO. Bạn có thể chọn giữa cài đặt toàn bộ ổ đĩa, chiếm trọn toàn bộ ổ đĩa, hoặc cài đặt vào vùng trống, đặt Omarchy vào vùng chưa được phân bổ trên một ổ đĩa — đó là cách bạn khởi động song song cùng Windows hoặc một hệ điều hành khác (xem [cài đặt khởi động song song](50-dual-boot-install.md) — lưu ý rằng trước tiên bạn sẽ cần tắt BitLocker trong Windows). Dù chọn cách nào, cài đặt cũng mặc định mã hóa toàn bộ, và tùy chọn toàn bộ ổ đĩa sẽ xóa sạch ổ đĩa đã chọn, vì vậy hãy nhớ sao lưu trước khi dùng một ổ đĩa hiện có!

[Tải xuống ISO của Omarchy](https://omarchy.org/) trước, chép nó vào một chiếc USB (dùng [Rufus](https://rufus.ie/) trên Windows, [balenaEtcher](https://etcher.balena.io/) trên Mac, hoặc [caligula](https://github.com/ifd3f/caligula) trên Linux), và khởi động từ chiếc USB đó.

_Bạn phải tắt Secure Boot và/hoặc TPM trong BIOS. Bạn phải tắt những thứ này để có thể cài đặt Omarchy. Chúng là các cơ chế bảo mật của Microsoft dành cho Windows và các bản phân phối Linux liên kết với Microsoft._

Sau đó trả lời các câu hỏi cấu hình, và xác nhận chúng như thế này:

 ![install-config](images/install-config.webp)

Sau đó chọn một ổ đĩa cho bản cài đặt của bạn, và ngồi thư giãn xem màn trình diễn cài đặt diễn ra. Việc này có thể hoàn thành trong chưa đầy một phút trên những chiếc máy hiện đại nhanh nhất, nhưng ngay cả trên một chiếc máy tính cũ hơn cũng không nên mất quá 5 phút.

 ![install-done](images/install-done.webp)

Giờ bạn đã sẵn sàng để Omarchy!

### Hãy dùng bàn phím có dây hoặc 2.4ghz!

Mã hóa toàn bộ ổ đĩa sẽ không cho phép bạn nhập mật khẩu từ một bàn phím Bluetooth lúc khởi động. Giống như bạn không thể dùng bàn phím Bluetooth để vào BIOS trên một PC vậy. Bạn sẽ cần một bàn phím dùng dongle 2.4ghz hoặc cáp (dù sao thì cáp cũng tốt hơn nhiều về độ trễ!). Cá nhân tôi rất thích [Lofree Flow84](https://www.lofree.co/products/lofree-flow-the-smoothest-mechanical-keyboard)!

### Cài đặt cho một chủ sở hữu khác

Nếu bạn đang thiết lập một chiếc máy cho người khác — một thành viên trong gia đình, một nhân viên mới, một người mua — bạn không nên trả lời các câu hỏi cá nhân thay cho họ. Nhấn `Ctrl + C` trên màn hình đầu tiên của trình cài đặt (phần chọn bàn phím), và Omarchy sẽ đề xuất chuẩn bị máy cho một chủ sở hữu khác thay vào đó. Hệ thống sẽ được cài đặt ngay lập tức, nhưng toàn bộ thiết lập cá nhân — bố cục bàn phím, tên người dùng, mật khẩu — sẽ được hoãn lại cho đến khi máy khởi động lần đầu tiên. Ổ đĩa vẫn được mã hóa theo mặc định, và mật khẩu mà chủ sở hữu mới chọn trong lần khởi động đầu tiên đó cũng sẽ trở thành mật khẩu mã hóa. (Một chiếc máy bạn đã từng sử dụng cũng có thể được bàn giao mà không cần cài đặt lại — xem [đặt lại máy tính](48-security.md).)

### Cài đặt không cần giám sát

ISO cũng có thể tự cài đặt hoàn toàn — không cần bàn phím, không cần trình hướng dẫn — khi nó được cung cấp cấu hình trên một ổ đĩa thứ hai. Đó là cách để coi Omarchy như một ảnh nền cho các VM và các dàn máy. Xem [cài đặt không cần giám sát](51-unattended-installs.md).

### Cài đặt không mã hóa

Omarchy được cài đặt kèm mã hóa theo mặc định. Đó là lựa chọn an toàn, có trách nhiệm cho bất kỳ chiếc máy tính nào có khả năng bị mất hoặc bị đánh cắp. Bạn không muốn bất kỳ ai có quyền tiếp cận phần cứng của bạn cũng có thể lấy được dữ liệu của bạn!

Nhưng trong những trường hợp đặc biệt, như cài đặt Omarchy từ xa trên các máy tính được bảo vệ hoặc cho các bản cài đặt dùng xong rồi bỏ mà không có dữ liệu nhạy cảm, bạn có thể muốn cài đặt mà không mã hóa. Bạn có thể nhấn `Ctrl + C` trên màn hình xác nhận định dạng ổ đĩa để chuyển sang cài đặt không mã hóa.

### Ngôn ngữ

Omarchy nói được 50 ngôn ngữ — cùng bộ với omarchy.org — và tiếng Anh là mặc định. Để chuyển đổi, hãy mở menu Omarchy và đi tới _Thiết lập > Ngôn ngữ_, hoặc chạy `omarchy language <code>` trong một terminal (`omarchy language list` sẽ hiển thị các mã). Menu, màn hình nền, và các thông báo của chính Omarchy sẽ đổi ngôn ngữ ngay lập tức, và mọi ứng dụng bạn mở sau đó cũng sẽ theo như vậy. Các ứng dụng đã mở trước đó sẽ chuyển đổi khi bạn khởi động lại chúng.

### Trợ giúp khi bạn gặp khó khăn

Nếu bạn gặp khó khăn, bạn thường có thể tìm thấy người sẵn lòng giúp đỡ trong kênh _#omarchy-help_ trên [Discord cộng đồng](https://omarchy.org/discord).
