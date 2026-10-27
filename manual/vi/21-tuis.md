# TUIs

## Lazygit

[Lazygit](https://github.com/jesseduffield/lazygit) là một lựa chọn thay thế thú vị cho những ứng dụng như GitHub Desktop, và nó chạy ngay bên trong terminal.

Bạn có thể chạy nó trực tiếp, bằng cách đi tới bất kỳ thư mục nào được quản lý bằng git và chạy `lazygit`. Hoặc bạn có thể chạy nó bên trong Neovim, nơi nó có thể được khởi động bằng `Space G G`.

Bạn di chuyển giữa các ngăn khác nhau bằng `Tab`. Trong ngăn Files, bạn chọn các file để đưa vào staging bằng `Space`, sau đó bạn có thể tạo một commit mới bằng `c`. Bạn có thể xem tất cả các lệnh có sẵn bằng `?`.

## Btop

[Btop](https://github.com/aristocratos/btop) là một trình quản lý tài nguyên đẹp mắt hiển thị mức sử dụng bộ nhớ, CPU, ổ đĩa và mạng. Nó cũng liệt kê tất cả các tiến trình đang hoạt động, và cho phép bạn quản lý chúng.

Omarchy gọi nó là Activity, và bạn khởi động nó bằng cách nhấn `Super + Shift + T`. Nó mở dưới dạng một cửa sổ nổi, và bạn có thể xếp nó thành ô bằng `Super + T`.

## Herdr

[Herdr](https://github.com/omacom-io/herdr) là một trình quản lý workspace trong terminal cung cấp cho bạn các workspace, tab và ngăn, đồng thời giữ tất cả chúng chạy trong một phiên bền vững mà bạn có thể tách ra và quay lại sau.

Bạn khởi động nó (hoặc gắn lại vào phiên hiện có của mình) bằng `Super + Ctrl + Return`. Omarchy đi kèm một cấu hình Herdr phản chiếu cấu hình Tmux của nó, vì vậy phím tiền tố ở đây cũng là `Ctrl + Space`. Bạn có thể duyệt tất cả các phím tắt bằng `Super + Ctrl + K`.

## Fastfetch

[Fastfetch](https://github.com/fastfetch-cli/fastfetch) hiển thị thông tin hệ thống, như phiên bản kernel, thời gian hoạt động, theme, CPU, bộ nhớ và nhiều hơn nữa. Nó là phiên bản kế nhiệm của công cụ neofetch phổ biến.

Omarchy đã đóng gói công cụ này dưới tên _Giới thiệu_ trong menu Omarchy (`Super + Space`).

## Cliamp

[Cliamp](https://www.cliamp.stream/) là một trình phát nhạc trong terminal mang phong cách cổ điển lấy cảm hứng từ Winamp 2.x, hoàn chỉnh với các đài radio tích hợp sẵn cho những giai điệu lo-fi. Khởi chạy nó bằng `Super + Shift + Alt + M`, hoặc từ menu Omarchy dưới mục _Ứng dụng_. Nhấn `?` để xem danh sách phím tắt đầy đủ.

## Còn Wi-Fi và Bluetooth thì sao?

Bạn sẽ không tìm thấy TUI nào cho Wi-Fi và Bluetooth — những việc đó thuộc về shell của Omarchy. Nhấp vào biểu tượng Wi-Fi trên thanh trên cùng (hoặc nhấn `Super + Ctrl + N`) để xem các mạng và kết nối, và nhấp vào biểu tượng Bluetooth (hoặc nhấn `Super + Ctrl + B`) để ghép nối và kết nối các thiết bị. Xem [kết nối mạng](35-networking.md) để biết toàn bộ câu chuyện.

## Thêm TUI của riêng bạn

Bất kỳ chương trình terminal nào cũng có thể được đối xử đầy đủ như một ứng dụng. Đi tới _Cài đặt > TUI_ trong menu Omarchy (`Super + Space`), đặt cho nó một tên, một lệnh khởi chạy, một kiểu cửa sổ và một biểu tượng, và nó sẽ xuất hiện trong trình khởi chạy ứng dụng như bất kỳ ứng dụng nào khác. Bạn có thể gỡ bỏ nó một lần nữa dưới mục _Gỡ bỏ > TUI_.
