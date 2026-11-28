# Neovim

[Neovim](https://neovim.io/) là một bản triển khai hiện đại của [trình soạn thảo vi](<https://en.wikipedia.org/wiki/Vi_(text_editor)>) do Bill Joy tạo ra từ tận năm 1976. Đây là một trình soạn thảo theo chế độ (modal editor), trong đó chế độ chèn và chế độ lệnh được tách riêng, và nó đúng là một siêu năng lực một khi bạn học được dù chỉ một phần nhỏ trong bộ lệnh phím cực kỳ phong phú của nó. Nhưng đường học của nó cũng dốc ra trò đấy!

Nếu bạn hoàn toàn mới với kiểu soạn thảo vim, tôi khuyên bạn nên xem loạt video [ThePrimeagen's Vim As Your Editor](https://www.youtube.com/watch?v=X6AR2RMB5tE&list=PLm323Lc7iSW_wuxqmKx_xxNtJC_hJbQ7R) trên YouTube. Loạt video đó sẽ dạy bạn những điều cơ bản. Chỉ cần biết rằng, không giống các trình soạn thảo phổ thông tương tự khác, bạn sẽ mất nhiều thời gian hơn để đạt được mức thành thạo cơ bản với vim. Nhưng một khi đã đạt được, phần thưởng cũng lớn hơn.

Neovim về cơ bản có thể tùy biến vô hạn. Nếu bạn thực sự muốn chơi tới bến, bạn có thể tự tạo cấu hình Neovim của riêng mình từ đầu. Có một khóa học tuyệt vời từ [Typecraft về cách thiết lập Neovim từ đầu](https://www.youtube.com/watch?v=zHTeCSVAFNY). Và [ThePrimeagen cũng có một khóa như vậy](https://www.youtube.com/watch?v=w7i4amO_zaE).

Nhưng Omarchy được cài sẵn một bộ Neovim hoàn chỉnh — gói `omarchy-nvim` — đã được tinh chỉnh đầy tâm huyết để phô diễn những gì tốt nhất có thể làm được ngay khi cài xong. Mà bạn không cần phải viết một dòng cấu hình nào! Nó được xây dựng trên [LazyVim](https://www.lazyvim.org/), một bản phân phối gồm các plugin và cấu hình cho Neovim. Nó tuyệt lắm.

## Kiến thức cơ bản về LazyVim

Như đã nói, tôi sẽ không dạy bạn vim trong phần giới thiệu ngắn này, nhưng tôi có thể chỉ cho bạn vài điều cơ bản về LazyVim và cách di chuyển trong đó.

Đầu tiên, Neovim có khái niệm phím leader. Đó về cơ bản là cánh cổng dẫn tới mọi lệnh. LazyVim đã đặt phím đó là `Space`. Vậy nên cứ nhấn phím đó, đợi một giây, và bạn sẽ thấy một loạt tùy chọn được giải thích ngay tại chỗ như thế này:

Dưới đây là một số lệnh cơ bản mà tôi dùng suốt:

- `Space Space` - Tìm mờ bất kỳ file nào trong thư mục hiện tại.
- `Space S G` - Tìm kiếm trong mọi file bằng grep với phần xem trước.
- `Space E` - Bật/tắt cây file.
- `Ctrl + W W` - Nhảy từ cây file sang trình soạn thảo và ngược lại.
- `Shift + H` - Di chuyển sang trái giữa các tab đang mở (vim gọi chúng là buffer).
- `Shift + L` - Di chuyển sang phải giữa các tab đang mở.
- `Space B D` - Đóng một tab.
- `Space B O` - Đóng mọi tab khác trừ tab hiện tại.
- `Space G G` - Mở LazyGit trong một khung nổi từ thư mục hiện tại.
- `Space U W` - Bật/tắt xuống dòng mềm (soft wrap).

Khi đang ở trong cây file (`Space E` để hiện nó, `Ctrl + W W` để nhảy sang đó), bạn có thể thêm một file mới bằng `a` hoặc một thư mục mới bằng `A`. Nhấn `?` khi đang ở trong cây file để xem mọi lệnh.

Nếu bạn muốn nắm được ngôn ngữ vim cơ bản, tôi đã viết về [cú pháp ba phần](https://world.hey.com/dhh/wonderful-vi-a1d034d3) và cách thực hiện những chiêu combo cực ngầu đó!

Bạn có thể xem mọi lệnh có thể dùng trên [trang LazyVim Keymaps](https://www.lazyvim.org/keymaps).

## Khởi động Neovim

`Super + Shift + N` mở trình soạn thảo mặc định của bạn, vốn là Plain trên các bản cài mới; hãy chọn Neovim trong _Setup > Defaults > Editor_ để thay vào đó nó mở Neovim. Nhưng thường thì điều khiển nó từ terminal sẽ dễ hơn, bằng cách di chuyển tới thư mục bạn muốn làm việc và gõ `n`. `n` là alias của `nvim`, và theo mặc định nó sẽ dùng thư mục hiện tại để mở. Bạn có thể mở một file duy nhất bằng `n myfile.txt`.

## Dùng Neovim để sửa file bằng sudo

Nếu bạn cần sửa các file mà chỉ có thể thay đổi với tư cách super user, hãy chạy `sudoedit /etc/sudoers.d/00-sudo-only-file`. Nó mở trình soạn thảo mặc định của bạn, vậy nên hãy đặt Neovim trong _Setup > Defaults > Editor_ nếu bạn muốn dùng nó ở đó với mọi plugin của mình.
