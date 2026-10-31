# Bắt đầu sử dụng

Omarchy được cài đặt bằng một ISO. Bạn có thể chọn giữa cài đặt toàn bộ ổ đĩa, tức chiếm toàn bộ ổ đĩa, hoặc cài đặt vào vùng trống, tức đặt Omarchy vào vùng chưa cấp phát trên ổ đĩa — đó là cách bạn dual boot song song với Windows hoặc một hệ điều hành khác (xem [cài đặt dual-boot](50-dual-boot-install.md) — lưu ý rằng trước tiên bạn sẽ cần tắt BitLocker trong Windows). Dù theo cách nào, quá trình cài đặt cũng mặc định dùng mã hóa toàn bộ, và tùy chọn toàn bộ ổ đĩa sẽ xóa sạch ổ đĩa đã chọn, vì vậy hãy chắc chắn sao lưu trước khi dùng một ổ đĩa có sẵn!

Hãy [tải Omarchy ISO](https://omarchy.org/) trước, chép nó vào một USB (dùng [balenaEtcher](https://etcher.balena.io/) trên Mac/Windows hoặc [caligula](https://github.com/ifd3f/caligula) trên Linux), và khởi động từ USB đó.

_Bạn phải tắt Secure Boot và/hoặc TPM trong BIOS. Bạn phải tắt chúng mới cài đặt được Omarchy. Chúng là các cơ chế bảo mật của Microsoft dành cho Windows và các bản phân phối Linux liên kết với Microsoft._

Sau đó hãy trả lời các câu hỏi cấu hình, và xác nhận chúng như thế này:

 ![install-config](images/install-config.webp)

Sau đó chọn một ổ đĩa cho bản cài đặt của bạn, rồi ngồi thư giãn và xem màn trình diễn cài đặt diễn ra. Việc này có thể hoàn thành trong chưa đầy một phút trên những chiếc máy hiện đại nhanh nhất, nhưng ngay cả trên một máy tính cũ hơn cũng không nên mất quá 5 phút.

 ![install-done](images/install-done.webp)

Giờ bạn đã sẵn sàng để Omarchy!

### Hãy dùng bàn phím có dây hoặc 2.4ghz!

Mã hóa toàn bộ ổ đĩa sẽ không cho phép bạn nhập mật khẩu từ bàn phím Bluetooth lúc khởi động. Cũng giống như bạn không thể dùng bàn phím Bluetooth để vào BIOS trên một chiếc PC vậy. Bạn sẽ cần một bàn phím dùng dongle 2.4ghz hoặc dùng cáp (dù sao thì cáp cũng cho độ trễ ngon hơn nhiều!). Cá nhân tôi cực kỳ yêu thích [Lofree Flow84](https://www.lofree.co/products/lofree-flow-the-smoothest-mechanical-keyboard)!

### Cài đặt cho một chủ sở hữu khác

Nếu bạn đang thiết lập máy cho người khác — một thành viên gia đình, một nhân viên mới, một người mua — bạn không nên trả lời các câu hỏi cá nhân thay cho họ. Hãy nhấn `Ctrl + C` ngay tại màn hình đầu tiên của trình cài đặt (màn hình chọn bàn phím), và Omarchy sẽ đề xuất chuẩn bị máy cho một chủ sở hữu khác thay vào đó. Hệ thống được cài đặt ngay lập tức, nhưng toàn bộ phần thiết lập cá nhân — bố cục bàn phím, tên người dùng, mật khẩu — sẽ được hoãn lại cho đến khi máy khởi động lần đầu tiên. Ổ đĩa vẫn được mã hóa theo mặc định, và mật khẩu mà chủ sở hữu mới chọn trong lần khởi động đầu tiên đó cũng trở thành mật khẩu mã hóa luôn. (Một chiếc máy bạn đã sử dụng cũng có thể được bàn giao mà không cần cài lại — xem [đặt lại máy tính](48-security.md).)

### Cài đặt không cần giám sát

ISO cũng có thể cài đặt hoàn toàn tự động — không cần bàn phím, không cần trình hướng dẫn — khi nó được đưa cấu hình của mình trên một ổ đĩa thứ hai. Đó là cách để dùng Omarchy như một image nền cho các VM và các máy trong cả một dàn máy. Xem [cài đặt không cần giám sát](51-unattended-installs.md).

### Cài đặt không mã hóa

Omarchy được cài đặt kèm mã hóa theo mặc định. Đó là lựa chọn an toàn và có trách nhiệm cho bất kỳ máy tính nào có khả năng bị thất lạc hoặc đánh cắp. Bạn đâu muốn bất kỳ ai tiếp cận được phần cứng của mình cũng có thể lấy được dữ liệu của bạn!

Nhưng trong những trường hợp đặc biệt, như cài đặt Omarchy từ xa trên các máy tính đã được bảo vệ hoặc cho những bản cài đặt dùng rồi bỏ mà không có dữ liệu nhạy cảm, bạn có thể muốn cài đặt mà không có mã hóa. Bạn có thể nhấn `Ctrl + C` tại màn hình xác nhận định dạng ổ đĩa để chuyển sang cài đặt không mã hóa.

### Ngôn ngữ

Omarchy nói được 50 ngôn ngữ — cùng một bộ ngôn ngữ với omarchy.org — và Tiếng Anh là mặc định. Để chuyển đổi, hãy mở menu Omarchy và vào _Setup > Language_, hoặc chạy `omarchy language <code>` trong terminal (`omarchy language list` sẽ hiển thị các mã). Menu, desktop và các thông báo riêng của chính Omarchy sẽ thay đổi ngôn ngữ ngay lập tức, và mọi ứng dụng bạn mở sau đó cũng sẽ đi theo. Các ứng dụng đã mở sẵn sẽ chuyển đổi sau khi bạn khởi động lại chúng.

### Trợ giúp nếu bạn bị kẹt

Nếu bạn bị kẹt, bạn thường có thể tìm được người sẵn sàng giúp đỡ trong kênh _#omarchy-help_ trên [Discord của cộng đồng](https://omarchy.org/discord).
