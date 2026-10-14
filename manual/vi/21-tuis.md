# TUI

## Lazygit

[Lazygit](https://github.com/jesseduffield/lazygit) là một lựa chọn thay thế thú vị cho những ứng dụng như GitHub Desktop, và nó chạy ngay trong terminal.

Bạn có thể chạy nó trực tiếp bằng cách đến bất kỳ thư mục nào do git quản lý và chạy `lazygit`. Hoặc bạn có thể chạy nó trong Neovim, nơi nó có thể khởi động bằng `Space G G`.

Bạn nhảy qua lại giữa các ngăn khác nhau bằng `Tab`. Trong ngăn Files, bạn chọn tệp để đưa vào vùng staging bằng `Space`, rồi tạo một commit mới bằng `c`. Bạn có thể xem mọi lệnh khả dụng bằng `?`.

## Btop

[Btop](https://github.com/aristocratos/btop) là một trình quản lý tài nguyên đẹp mắt, hiển thị mức sử dụng bộ nhớ, CPU, đĩa và mạng. Nó cũng liệt kê mọi tiến trình đang hoạt động và cho phép bạn quản lý chúng.

Omarchy gọi nó là Activity, và bạn khởi động nó bằng `Super + Ctrl + T`. Nó mở ra dưới dạng một cửa sổ nổi, mà bạn có thể xếp thành ô bằng `Super + T`.

## Herdr

[Herdr](https://github.com/omacom-io/herdr) là một trình quản lý không gian làm việc terminal, cho bạn các workspace, tab và ngăn, và giữ tất cả chạy trong một phiên bền vững mà bạn có thể tách ra và quay lại sau.

Bạn khởi động nó (hoặc gắn lại vào phiên hiện có của mình) bằng `Super + Ctrl + Return`. Omarchy đi kèm một cấu hình Herdr phản chiếu cấu hình Tmux của nó, vì vậy phím tiền tố ở đây cũng là `Ctrl + Space`. Bạn có thể duyệt mọi phím tắt bằng `Super + Ctrl + K`.

## Fastfetch

[Fastfetch](https://github.com/fastfetch-cli/fastfetch) hiển thị thông tin hệ thống, như phiên bản nhân, thời gian hoạt động, giao diện, CPU, bộ nhớ và nhiều thứ khác. Đây là người kế nhiệm của công cụ neofetch phổ biến.

Omarchy đã đóng gói nó thành _Giới thiệu_ trong menu Omarchy (`Super + Space`).

## Cliamp

[Cliamp](https://www.cliamp.stream/) là một trình phát nhạc terminal mang phong cách hoài cổ lấy cảm hứng từ Winamp 2.x, đi kèm các đài phát thanh tích hợp sẵn cho nhạc lo-fi. Khởi chạy nó bằng `Super + Shift + Alt + M`, hoặc từ menu Omarchy trong mục _Ứng dụng_. Nhấn `?` để xem danh sách phím tắt đầy đủ.

## Còn Wi-Fi và Bluetooth thì sao?

Bạn sẽ không tìm thấy TUI cho Wi-Fi và Bluetooth — những công việc đó thuộc về shell của Omarchy. Nhấp vào biểu tượng Wi-Fi trên thanh trên cùng (hoặc nhấn `Super + Ctrl + W`) để xem các mạng và kết nối, và nhấp vào biểu tượng Bluetooth (hoặc nhấn `Super + Ctrl + B`) để ghép nối và kết nối thiết bị. Xem [mạng](35-networking.md) để biết toàn bộ câu chuyện.

## Thêm của riêng bạn

Bất kỳ chương trình terminal nào cũng có thể được đối xử như một ứng dụng hoàn chỉnh. Vào _Cài đặt > TUI_ trong menu Omarchy (`Super + Space`), đặt cho nó một cái tên, một lệnh khởi chạy, một kiểu cửa sổ và một biểu tượng, và nó sẽ xuất hiện trong trình khởi chạy ứng dụng như bất kỳ ứng dụng nào khác. Bạn có thể gỡ bỏ nó trong _Gỡ bỏ > TUI_.
