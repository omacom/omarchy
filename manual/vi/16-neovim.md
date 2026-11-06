# Neovim

[Neovim](https://neovim.io/) là một triển khai hiện đại của [trình soạn thảo vi](<https://en.wikipedia.org/wiki/Vi_(text_editor)>) được tạo ra bởi Bill Joy từ tận năm 1976. Đây là một trình soạn thảo theo chế độ, nơi chế độ chèn và chế độ lệnh được tách biệt, và nó là một siêu năng lực nho nhỏ một khi bạn học được dù chỉ một tập hợp con của bộ lệnh phím vô cùng sâu sắc. Nhưng nó cũng có đường cong học tập khá dốc!

Nếu bạn hoàn toàn mới với việc soạn thảo kiểu vim, tôi khuyên bạn nên xem [loạt bài Vim As Your Editor của ThePrimeagen](https://www.youtube.com/watch?v=X6AR2RMB5tE&list=PLm323Lc7iSW_wuxqmKx_xxNtJC_hJbQ7R) trên YouTube. Loạt bài đó sẽ dạy bạn những điều cơ bản. Chỉ cần biết rằng không giống các trình soạn thảo chính thống tương tự hơn, bạn sẽ mất nhiều thời gian hơn để đạt được trình độ thành thạo cơ bản với vim. Nhưng một khi bạn làm được, phần thưởng cũng lớn hơn.

Giờ Neovim về cơ bản có thể cấu hình vô hạn. Nếu bạn thực sự muốn phát điên, bạn có thể tạo cấu hình Neovim của riêng mình từ đầu. Có một khóa học tuyệt vời từ [Typecraft về việc thiết lập Neovim từ đầu](https://www.youtube.com/watch?v=zHTeCSVAFNY). Và [ThePrimeagen cũng có một khóa](https://www.youtube.com/watch?v=w7i4amO_zaE).

Nhưng Omarchy đi kèm với một thiết lập Neovim hoàn chỉnh — gói `omarchy-nvim` — đã được tinh chỉnh cẩn thận để thể hiện những gì tốt nhất có thể ngay khi mở hộp. Mà bạn không phải viết một dòng cấu hình nào! Nó được xây dựng trên [LazyVim](https://www.lazyvim.org/), một bản phân phối các plugin và cấu hình Neovim. Nó thật tuyệt vời.

## Cơ bản về LazyVim

Như đã đề cập, tôi sẽ không dạy bạn vim trong phần giới thiệu ngắn này, nhưng tôi có thể cho bạn xem một vài điều cơ bản về LazyVim, và cách di chuyển xung quanh.

Đầu tiên, Neovim có ý tưởng về phím leader. Đó về cơ bản là cổng vào mọi lệnh. LazyVim đã đặt phím đó thành `Space`. Vì vậy chỉ cần nhấn phím đó, chờ một giây, và bạn sẽ thấy một loạt tùy chọn được giải thích trực tiếp như thế này:

Dưới đây là một số lệnh cơ bản tôi dùng mọi lúc:

- `Space Space` - Tìm kiếm mờ bất kỳ tệp nào trong thư mục hiện tại.
- `Space S G` - Tìm kiếm tất cả các tệp bằng grep với bản xem trước.
- `Space E` - Bật/tắt cây tệp.
- `Ctrl + W W` - Nhảy từ cây tệp sang trình soạn thảo và ngược lại.
- `Shift + H` - Di chuyển sang trái giữa các tab đang mở (vim gọi chúng là buffer).
- `Shift + L` - Di chuyển sang phải giữa các tab đang mở.
- `Space B D` - Đóng một tab.
- `Space B O` - Đóng tất cả các tab khác ngoại trừ tab hiện tại.
- `Space G G` - Khởi chạy LazyGit trong một ô nổi từ thư mục hiện tại.
- `Space U W` - Bật/tắt xuống dòng mềm.

Trong khi bạn đang ở trong cây tệp (`Space E` để hiện, `Ctrl + W W` để nhảy sang đó), bạn có thể thêm một tệp mới bằng `a` hoặc một thư mục mới bằng `A`. Nhấn `?` khi đang ở trong cây để xem tất cả các lệnh.

Nếu bạn muốn nắm bắt ngôn ngữ vim cơ bản, tôi đã viết về [cú pháp ba phần](https://world.hey.com/dhh/wonderful-vi-a1d034d3) và cách thực hiện những chiêu combo đỉnh cao đó!

Bạn có thể xem tất cả các lệnh có thể trên [trang LazyVim Keymaps](https://www.lazyvim.org/keymaps).

## Khởi động Neovim

Bạn có thể khởi động Neovim bằng `Super + Shift + N` (phím gán khởi chạy trình soạn thảo mặc định của bạn, vốn là Neovim ngay khi mở hộp), nhưng thường dễ dàng hơn khi điều khiển nó từ terminal bằng cách điều hướng tới thư mục bạn muốn làm việc và gõ `n`. `n` là bí danh cho `nvim`, sẽ dùng thư mục hiện tại để mở theo mặc định. Bạn có thể mở một tệp duy nhất bằng `n myfile.txt`.

## Dùng Neovim cho các chỉnh sửa sudo

Nếu bạn cần chỉnh sửa các tệp mà bạn chỉ có thể thay đổi với tư cách người dùng siêu cấp, bạn có thể dùng neovim với tất cả các plugin đã thiết lập bằng cách chạy `sudoedit /etc/sudoers.d/00-sudo-only-file`.
