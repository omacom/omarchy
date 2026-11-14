# TUIs

## Lazygit

[Lazygit](https://github.com/jesseduffield/lazygit) là một lựa chọn thay thế thú vị cho những thứ như ứng dụng GitHub Desktop, và nó chạy ngay bên trong terminal.

Bạn có thể chạy nó trực tiếp, bằng cách đi tới bất kỳ thư mục nào được git quản lý và chạy `lazygit`. Hoặc bạn có thể chạy nó bên trong Neovim, nơi nó có thể được khởi động bằng `Space G G`.

Bạn di chuyển giữa các khung khác nhau bằng `Tab`. Trong khung Files, bạn chọn các tệp để đưa vào staging bằng `Space`, rồi bạn có thể tạo một commit mới bằng `c`. Bạn có thể xem tất cả các lệnh có sẵn bằng `?`.

## Btop

[Btop](https://github.com/aristocratos/btop) là một trình quản lý tài nguyên đẹp mắt, hiển thị mức sử dụng bộ nhớ, CPU, đĩa và mạng. Nó cũng liệt kê tất cả các tiến trình đang hoạt động, và cho phép bạn quản lý chúng.

Omarchy gọi nó là Activity Monitor, và bạn khởi động nó từ trình khởi chạy ứng dụng hoặc bằng cách nhấn `Super + Shift + T`. Nó mở ra dưới dạng một cửa sổ nổi, và bạn có thể xếp nó vào lưới bằng `Super + T`.

## Herdr

[Herdr](https://github.com/omacom-io/herdr) là một trình quản lý không gian làm việc trong terminal, cung cấp cho bạn các không gian làm việc, các tab và các khung, đồng thời giữ tất cả chúng tiếp tục chạy trong một phiên bền vững mà bạn có thể tách ra và quay lại sau.

Bạn khởi động nó (hoặc gắn lại vào phiên hiện có của mình) bằng `Super + Ctrl + Return`. Omarchy đi kèm một cấu hình Herdr mô phỏng cấu hình Tmux của nó, vì vậy phím tiền tố ở đây cũng là `Ctrl + Space`. Bạn có thể duyệt tất cả các phím tắt bằng `Super + Ctrl + K`.

## Fastfetch

[Fastfetch](https://github.com/fastfetch-cli/fastfetch) hiển thị thông tin hệ thống, như phiên bản kernel, thời gian hoạt động, chủ đề, CPU, bộ nhớ và nhiều hơn nữa. Nó là phiên bản kế nhiệm của công cụ neofetch nổi tiếng.

Omarchy đã đóng gói tính năng này dưới tên _About_ trong menu Omarchy (`Super + Space`).

## Cliamp

[Cliamp](https://www.cliamp.stream/) là một trình phát nhạc trong terminal mang phong cách retro, lấy cảm hứng từ Winamp 2.x, với đầy đủ các đài radio tích hợp sẵn cho những giai điệu lo-fi. Khởi chạy nó bằng `Super + Shift + Alt + M`, hoặc từ menu Omarchy trong mục _Apps_. Nhấn `?` để xem danh sách phím tắt đầy đủ.

## Còn Wi-Fi và Bluetooth thì sao?

Bạn sẽ không tìm thấy TUI nào cho Wi-Fi và Bluetooth — những công việc đó thuộc về shell của Omarchy. Nhấp vào biểu tượng Wi-Fi trên thanh trên cùng (hoặc nhấn `Super + Ctrl + N`) để xem các mạng và kết nối, và nhấp vào biểu tượng Bluetooth (hoặc nhấn `Super + Ctrl + B`) để ghép nối và kết nối các thiết bị. Xem [kết nối mạng](35-networking.md) để biết chi tiết đầy đủ.

## Thêm ứng dụng của riêng bạn

Bất kỳ chương trình terminal nào cũng có thể được đối xử trọn vẹn như một ứng dụng. Đi tới _Install > TUI_ trong menu Omarchy (`Super + Space`), đặt cho nó một cái tên, một lệnh khởi chạy, một kiểu cửa sổ và một biểu tượng, và nó sẽ xuất hiện trong trình khởi chạy ứng dụng giống như bất kỳ ứng dụng nào khác. Bạn có thể gỡ bỏ nó một lần nữa trong mục _Remove > TUI_.
