# TUIs

## Lazygit

[Lazygit](https://github.com/jesseduffield/lazygit) là một lựa chọn thay thế thú vị cho những ứng dụng như GitHub Desktop, và nó chạy ngay bên trong terminal.

Bạn có thể chạy nó trực tiếp bằng cách đi tới bất kỳ thư mục nào được quản lý bởi git và chạy `lazygit`. Hoặc bạn có thể chạy nó bên trong Neovim, nơi nó có thể được khởi động bằng `Space G G`.

Bạn chuyển qua lại giữa các pane khác nhau bằng `Tab`. Trong pane Files, bạn chọn các file để staging bằng `Space`, rồi bạn có thể tạo một commit mới bằng `c`. Bạn có thể xem tất cả các lệnh có sẵn bằng `?`.

## Btop

[Btop](https://github.com/aristocratos/btop) là một trình quản lý tài nguyên đẹp mắt, hiển thị mức sử dụng bộ nhớ, CPU, ổ đĩa và mạng. Nó cũng liệt kê tất cả các tiến trình đang hoạt động và cho phép bạn quản lý chúng.

Omarchy gọi nó là Activity Monitor, và bạn khởi động nó từ app launcher hoặc bằng cách nhấn `Super + Shift + T`. Nó mở ra dưới dạng một cửa sổ nổi, cửa sổ mà bạn có thể chuyển sang dạng tile bằng `Super + T`.

## Herdr

[Herdr](https://herdr.dev) là một trình quản lý workspace trong terminal, mang đến cho bạn các workspace, tab và pane, đồng thời giữ tất cả chúng tiếp tục chạy trong một session bền vững mà bạn có thể detach khỏi đó và quay lại sau.

Bạn khởi động nó (hoặc reattach vào session hiện có của bạn) từ app launcher hoặc bằng `Super + Ctrl + Return`. Omarchy đi kèm với một cấu hình Herdr phản chiếu cấu hình Tmux của nó, vì vậy prefix key ở đây cũng là `Ctrl + Space`. Bạn có thể duyệt tất cả các keybinding bằng `Super + Ctrl + K`.

## Fastfetch

[Fastfetch](https://github.com/fastfetch-cli/fastfetch) hiển thị thông tin hệ thống, như phiên bản kernel, uptime, theme, CPU, bộ nhớ, và nhiều hơn nữa. Nó là phiên bản kế nhiệm của công cụ neofetch phổ biến.

Omarchy đã đóng gói tính năng này dưới dạng _System > About_ trong menu Omarchy (`Super + Space`).

## Cliamp

[Cliamp](https://www.cliamp.stream/) là một trình phát nhạc trong terminal theo phong cách retro lấy cảm hứng từ Winamp 2.x, đi kèm với các đài radio tích hợp sẵn cho những bản lo-fi beats. Khởi động nó bằng `Super + Shift + Alt + M`, hoặc từ menu Omarchy trong mục _Apps_. Nhấn `?` để xem danh sách keybinding đầy đủ.

## Thế còn Wi-Fi và Bluetooth thì sao?

Bạn sẽ không tìm thấy TUI nào cho Wi-Fi và Bluetooth — những công việc đó thuộc về shell của Omarchy. Nhấp vào biểu tượng Wi-Fi trên thanh trên cùng (hoặc nhấn `Super + Ctrl + N`) để xem các mạng và kết nối, và nhấp vào biểu tượng Bluetooth (hoặc nhấn `Super + Ctrl + B`) để ghép nối và kết nối các thiết bị. Xem [kết nối mạng](35-networking.md) để biết toàn bộ câu chuyện.

## Thêm ứng dụng của riêng bạn

Bất kỳ chương trình terminal nào cũng có thể được đối xử đầy đủ như một ứng dụng. Vào _Install > TUI_ trong menu Omarchy (`Super + Space`), đặt cho nó một cái tên, một lệnh khởi động, một kiểu cửa sổ, và một biểu tượng, và nó sẽ xuất hiện trong app launcher như bất kỳ ứng dụng nào khác. Bạn có thể gỡ bỏ nó một lần nữa trong _Remove > TUI_.
