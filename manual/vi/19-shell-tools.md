# Công cụ shell

Ngoài các công cụ Linux tiêu chuẩn, Omarchy còn đi kèm một loạt công cụ shell nâng cao. Dưới đây là những công cụ chính.

## fzf

[fzf](https://junegunn.github.io/fzf/) cho phép bạn tìm kiếm mờ các tệp qua bí danh `ff`. Đi đến bất kỳ thư mục nào, gõ `ff`, và bạn sẽ có thể tìm kiếm mờ đến bất kỳ tệp nào trong cây thư mục đó, đồng thời xem trước các tệp đang thu hẹp dần ở phía bên phải.

Bạn có thể dùng `Ctrl + R` để dùng fzf tìm kiếm mờ trong lịch sử lệnh của mình.

Công cụ này cũng được Neovim sử dụng khi bạn gõ `Space Space`.

Bạn có thể tìm hướng dẫn đầy đủ qua `man fzf`.

## Zoxide

[Zoxide](https://github.com/ajeetdsouza/zoxide) là công cụ thay thế cho cd. Nó ghi nhớ các thư mục bạn đã ghé qua, để lần sau bạn dễ dàng nhảy đến đó. Giả sử bạn chạy `cd ~/.config/omarchy` một lần. Lần tới, bạn chỉ cần gõ `cd omarchy` (hoặc thậm chí chỉ `cd oma`), và Zoxide sẽ đưa bạn thẳng đến đó.

Bạn có thể tìm hướng dẫn đầy đủ qua `man zoxide`.

## ripgrep

[ripgrep](https://github.com/BurntSushi/ripgrep) tìm kiếm nội dung các tệp bằng `rg <pattern> <path>`, ví dụ `rg Controller app/` để tìm mọi lần nhắc đến `Controller` trong thư mục app.

Công cụ này cũng được Neovim sử dụng khi bạn gõ `Space S G`.

Bạn có thể tìm hướng dẫn đầy đủ qua `man rg`.

## eza

[eza](https://eza.rocks/) là công cụ thay thế cho ls. Nó hiển thị danh sách thư mục với nhiều thông tin hơn, có màu sắc và biểu tượng. Theo mặc định, eza được đặt bí danh là ls. Bạn cũng có thể dùng `lt` để xem danh sách lồng nhau hai cấp. `lsa` cho bạn danh sách bao gồm các tệp ẩn. Và `lta` là danh sách lồng nhau kèm tệp ẩn.

Bạn có thể tìm hướng dẫn đầy đủ qua `man eza`.

## fd

[fd](https://github.com/sharkdp/fd) là công cụ thay thế dễ dùng hơn cho `find`. Dùng `fd person.rb` để tìm một tệp tên `person.rb` trong cây thư mục hiện tại. `fd person.rb /` sẽ tìm trên toàn bộ hệ thống tệp. `fd person.rb / -H` tìm trên toàn bộ hệ thống tệp, bao gồm cả các thư mục ẩn.

Bạn có thể tìm hướng dẫn đầy đủ qua `man fd`.

## bat

[bat](https://github.com/sharkdp/bat) là `cat` với tô màu cú pháp, số dòng và phân trang. Chạy `bat somefile.rb` và bạn sẽ hiểu vì sao khó mà quay lại. Nó cũng âm thầm làm việc cho bạn ở những nơi khác: nó là thứ tô màu cho các trang man của bạn, và là thứ kết xuất phần xem trước trong `ff`.

Bạn có thể tìm hướng dẫn đầy đủ qua `man bat`.

## tldr

[tldr](https://tldr.sh/) là thuốc giải cho những trang man mở đầu bằng ba màn hình lịch sử trước khi cho bạn thấy một ví dụ duy nhất. `tldr tar` cho bạn một vài cách gọi mà bạn thực sự cần.

## yt-dlp

[yt-dlp](https://github.com/yt-dlp/yt-dlp) tải video từ YouTube và hàng trăm trang khác. `yt-dlp <url>` tải chất lượng tốt nhất có thể vào thư mục hiện tại.

Bạn có thể tìm hướng dẫn đầy đủ qua `man yt-dlp`.

## try

[try](https://github.com/tobi/try) giúp bạn dễ dàng quản lý các thí nghiệm lập trình với các thư mục đóng dấu ngày tháng. Mọi thí nghiệm đều nằm trong `~/Work/tries` và bạn có thể truy cập chúng qua `try`.

Omarchy không tự động thêm thư mục `bin/` của một dự án vào `PATH`. Hãy chạy các công cụ cục bộ đáng tin cậy của dự án bằng đường dẫn tương đối rõ ràng, chẳng hạn `bin/rails` hoặc `./bin/dev`.
