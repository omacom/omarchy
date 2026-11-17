# Terminal

[Foot](https://codeberg.org/dnkl/foot) là terminal mặc định cho Omarchy. Nó nhanh, nhẹ và tương thích ngay cả với các máy tính cũ. Tuy nhiên, nó không hỗ trợ tab hoặc chia màn hình gốc.

Nếu bạn dùng Tmux, bạn có thể không bận tâm, nhưng nếu không, chúng tôi cũng hỗ trợ đầy đủ _Alacritty_, _Ghostty_ và _Kitty_ làm các tùy chọn. Chọn sở thích của bạn trong _Cài đặt > Terminal_ trong menu Omarchy.

Bạn khởi động một terminal mới bằng `Super + Return`. (Phím gán này sẽ tự động chỉ tới bất kỳ Terminal nào bạn đã cài đặt qua _Cài đặt > Terminal_, và bạn có thể chuyển đổi giữa các terminal đã cài đặt trong _Thiết lập > Mặc định > Terminal_.)

## Tmux

Tmux cung cấp một giao diện nhất quán, có thể lập trình cho các ô, cửa sổ (hay còn gọi là tab) và các phiên có thể tiếp tục bất kể terminal của bạn. Nó thậm chí hoạt động trên các máy chủ từ xa, vì vậy khi bạn SSH vào một máy chủ, bạn có thể dùng cùng một cách tiếp cận.

Bạn khởi động một phiên Tmux mới trong một terminal mới bằng `Super + Alt + Return`, và vì Tmux là một tiến trình bền vững, bạn có thể tiếp tục phiên của mình ngay cả khi bạn đóng terminal đó. Chỉ cần nhấn `Ctrl + Space` (được gọi là phím tiền tố) rồi `s` để xem tất cả các phiên đang hoạt động của bạn.

Omarchy đi kèm với một cấu hình Tmux được tối ưu hóa về công thái học, có rất nhiều phím gán cần học, vì vậy hãy giữ [bảng gian lận tiện dụng](07-hotkeys.md#tmux).

## Hàm bố cục Tmux

Vì Tmux có thể lập trình được, chúng ta có thể dùng các hàm để tạo bố cục. Omarchy đi kèm với bốn hàm khác nhau cho các bố cục phổ biến dành cho nhà phát triển.

`tdl [agent]` khởi động một giao diện giống IDE chia ba với `$EDITOR` ở bên trái, AI agent bạn đã chọn ở bên phải (như `c` cho opencode hoặc `cx` cho Claude hoặc `codex` cho OpenAI), và sau đó một terminal ở phía dưới.

Vì vậy `tdl c` sẽ khởi động cái này (hoặc chỉ `ic`):

 ![tmux-tdl](images/tmux-tdl.webp)

Bạn cũng có thể khởi động một agent thứ hai bằng `tdl c cx` (opencode + claude) (hoặc chỉ `icx`):

 ![tmux-tdl2](images/tmux-tdl2.webp)

Ngoài ra còn có `tds`, khởi động một hình vuông bốn ô với trình soạn thảo ở trên bên trái, một trình theo dõi diff trực tiếp ở trên bên phải, một terminal ở dưới bên trái, và opencode ở dưới bên phải.

Bạn cũng có thể khởi động cấu hình bố cục này cho mọi thư mục con trong thư mục hiện tại bằng `tdlm [agent]`, sau đó điều hướng bằng `alt + 1/2/3/4/5/...`:

 ![tmux-tdlm](images/tmux-tdlm.webp)

Cuối cùng, bạn có thể khởi động một đàn agent bằng `tsl [panes] [command]`. Vì vậy `tsl 4 c` sẽ cho bạn một lưới bốn ô các agent opencode:

 ![tmux-tsl](images/tmux-tsl.webp)
