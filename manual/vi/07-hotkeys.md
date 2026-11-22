# Phím tắt

Bạn có thể xem mọi gán phím chính bằng `Super + K` (gán phím Tmux bằng `Super + Alt + K` và gán phím Herdr bằng `Super + Ctrl + K`).

## Phím tắt được bố trí như thế nào

Mỗi phím tắt nằm trên một mặt phẳng, được xác định bởi các phím bổ trợ của nó, và mỗi mặt phẳng có một nhiệm vụ. Đó là thứ giữ cho các phím tắt không bị lẫn vào nhau, và nó có nghĩa là bạn thường có thể đoán được một thứ gì đó sống ở đâu.

| Mặt phẳng | Những gì sống ở đó | Ví dụ |
| --- | --- | --- |
| `Super + key` | Hệ thống: cửa sổ, không gian làm việc, bố cục và các menu cốt lõi | `Super + Space` menu Omarchy, `Super + W` đóng cửa sổ, `Super + F` toàn màn hình |
| `Super + Shift + key` | Ứng dụng | `Super + Shift + B` trình duyệt, `Super + Shift + E` email, `Super + Shift + N` trình soạn thảo |
| `Super + Ctrl + key` | Bảng điều khiển và menu hệ thống | `Super + Ctrl + A` âm thanh, `Super + Ctrl + N` mạng, `Super + Ctrl + C` menu chụp |
| `Super + Ctrl + Alt + key` | Hành động nhanh và thông báo ngắn | `Super + Ctrl + Alt + T` hiển thị giờ, `Super + Ctrl + Alt + B` pin, `Super + Ctrl + Alt + C` ảnh chụp màn hình |

Thêm `Alt` vào một phím tắt cho bạn một biến thể của cùng một thứ, không bao giờ là thứ gì đó không liên quan:

- `Super + Shift + B` mở trình duyệt; `Super + Shift + Alt + B` mở một cửa sổ riêng tư
- `Super + Shift + E` mở email; `Super + Shift + Alt + E` bắt đầu một email mới
- `Super + F` vào toàn màn hình; `Super + Alt + F` vào toàn chiều rộng
- `Super + Ctrl + C` mở menu chụp; `Super + Ctrl + Alt + C` bỏ qua menu và chụp ảnh màn hình

Khi thêm một phím tắt:

1. Chọn mặt phẳng từ chức năng của nó, rồi chọn phím.
2. Đừng di chuyển một phím tắt hiện có để lấy chỗ. Hãy tìm một phím còn trống trên đúng mặt phẳng.
3. Chỉ dùng `Alt` cho một biến thể của phím tắt không có nó.

Một vài phím tắt phá vỡ các quy tắc này vì chúng tiện lợi. `Shift` với một mũi tên hoặc `Tab` di chuyển hoặc đảo ngược thay vì mở một ứng dụng, và `Print`, các phím media, `Alt + Tab`, và `Ctrl + Alt + Del` hoạt động theo cách chúng hoạt động ở mọi nơi khác. Chúng là ngoại lệ, không phải khuôn mẫu để sao chép.

Nếu một phím mặc định không phù hợp với bạn (ví dụ bạn muốn `Super + Shift + S` cho ảnh chụp màn hình như trên Windows), hãy gán lại nó trong `~/.config/hypr/bindings.lua`.

## Điều hướng

| Phím tắt                  | Chức năng              |
| ----------------------- | --------------------- |
| `Super + Space`           | Menu Omarchy (ứng dụng và mọi thứ khác)    |
| `Super + Alt + Space` | Lưới ứng dụng |
| `Super + Escape` | Menu hệ thống (tạm dừng, khởi động lại, v.v.)  |
| `Super + Ctrl + L` | Khóa máy tính |
| `Super + W` hoặc `Super + Q` | Đóng cửa sổ             |
| `Ctrl + Alt + Del` | Đóng mọi cửa sổ |
| `Super + K` | Hiển thị mọi phím tắt |
| `Super + Alt + K` | Hiển thị phím tắt tmux |
| `Super + Ctrl + K` | Hiển thị phím tắt herdr |
| `Super + M` | Thu nhỏ cửa sổ xuống dock |
| `Super + T`               | Chuyển cửa sổ giữa dạng xếp kề/dạng nổi             |
| `Super + J` | Chuyển vị trí cửa sổ (ngang/dọc) |
| `Super + O`               | Bật/tắt việc đưa cửa sổ vào trạng thái sticky'n'floating |
| `Super + L`               | Luân chuyển qua các bố cục dwindle, scrolling và floating |
| `Super + Alt + L`         | Luân chuyển qua các bố cục theo chiều ngược lại |
| `Super + P`               | Chuyển kiểu cửa sổ pseudo (tự nhiên so với kéo giãn) |
| `Super + F`                 | Vào toàn màn hình              |
| `Super + Alt + F`                 | Vào toàn chiều rộng              |
| `Super + Ctrl + F`                 | Vào toàn màn hình bên trong cửa sổ              |
| `Super + 1…9/0`         | Nhảy tới không gian làm việc cụ thể (0 là 10) trên màn hình đang được tập trung |
| `Super + Tab` | Nhảy tới không gian làm việc tiếp theo trên màn hình đang được tập trung |
| `Super + Shift + Tab` | Nhảy tới không gian làm việc trước đó trên màn hình đang được tập trung |
| `Super + Ctrl + Tab` | Nhảy tới không gian làm việc trước đây trên màn hình đang được tập trung |
| `Super + Shift + 1…9/0` | Di chuyển cửa sổ tới không gian làm việc trên màn hình đang được tập trung |
| `Super + Shift + Alt + 1…9/0` | Di chuyển cửa sổ tới không gian làm việc trên màn hình đang được tập trung mà không đi theo |
| `Super + S` | Bật/tắt scratchpad toàn phần |
| `Super + Alt + S` | Di chuyển cửa sổ tới scratchpad toàn phần |
| `Super + Grave` | Bật/tắt bảng điều khiển Quake |
| `Super + Shift + Grave` | Di chuyển cửa sổ tới bảng điều khiển Quake |
| `Super + Shift + Ctrl + Arrows` | Di chuyển cửa sổ tới màn hình theo hướng đó |
| `Super + Shift + Alt + Arrows` | Di chuyển không gian làm việc tới màn hình theo hướng đó |
| `Super + Arrow`  | Di chuyển tiêu điểm tới cửa sổ theo hướng mũi tên, vượt sang màn hình ở phía đó khi ở mép màn hình |
| `Super + Shift + Arrow`  | Hoán đổi cửa sổ với một cửa sổ khác theo hướng mũi tên, bao gồm một cửa sổ trên màn hình ở phía đó |
| `Super + Minus` | Mở rộng cửa sổ sang trái |
| `Super + Equal` | Thu hẹp cửa sổ sang trái |
| `Super + Shift + Minus` | Thu hẹp cửa sổ lên trên |
| `Super + Shift + Equal` | Mở rộng cửa sổ xuống dưới |
| `Super + Alt + Minus/Equal` | Thay đổi kích thước tương tự theo các bước nhỏ hơn |
| `Super + Ctrl + Minus/Equal` | Thay đổi kích thước tương tự theo các bước lớn hơn |
| `Super + Alt + Home` | Lưu chiều rộng cửa sổ |
| `Super + Home` | Khôi phục chiều rộng cửa sổ đã lưu |
| `Super + Left Mouse` | Kéo cửa sổ đi khắp nơi |
| `Super + Right Mouse` | Thay đổi kích thước cửa sổ |
| `Super + Scroll Wheel` | Cuộn qua các không gian làm việc trên màn hình đang được tập trung |
| `Super + G`               | Bật/tắt nhóm cửa sổ      |
| `Super + Alt + G`               | Đưa cửa sổ ra khỏi nhóm      |
| `Super + Alt + Tab`               | Luân chuyển giữa các cửa sổ trong nhóm      |
| `Super + Alt + Shift + Tab`               | Luân chuyển ngược lại giữa các cửa sổ trong nhóm      |
| `Super + Alt + Scroll Wheel` | Luân chuyển giữa các cửa sổ trong nhóm |
| `Super + Alt + 1/2/3/4/5`               | Nhảy tới cửa sổ cụ thể trong nhóm      |
| `Super + Alt + Arrow`  | Đưa cửa sổ vào nhóm theo hướng mũi tên, bao gồm một cửa sổ trên màn hình ở phía đó |
| `Super + Ctrl + Left/Right`  | Di chuyển giữa các cửa sổ bên trong một nhóm xếp kề |
| `Super + Ctrl + Z` | Phóng to màn hình (lặp lại để phóng to hơn) |
| `Super + Ctrl + Alt + Z` | Thu nhỏ hoàn toàn khỏi màn hình |
| `Super + /` | Tiến qua các tùy chọn tỉ lệ màn hình |
| `Super + Alt + /` | Lùi qua các tùy chọn tỉ lệ màn hình |
| `Alt + Tab` | Luân chuyển về phía trước qua các cửa sổ trên không gian làm việc đang hoạt động |
| `Alt + Shift + Tab` | Luân chuyển về phía sau qua các cửa sổ trên không gian làm việc đang hoạt động |
| `Ctrl + Alt + Tab`| Luân chuyển tiêu điểm về phía trước qua các màn hình |
| `Ctrl + Alt + Shift + Tab`| Luân chuyển tiêu điểm về phía sau qua các màn hình |
| `Super + I` | Chuyển ngôn ngữ nhập liệu (khi có nhiều hơn một bố cục hoặc phương thức nhập) |
| `Super + Shift + I` | Chuyển ngôn ngữ nhập liệu trở lại |

Trên bàn di chuột, vuốt ba và bốn ngón tay chuyển không gian làm việc, di chuyển cửa sổ, và mở menu và bảng điều khiển Quake; xem [bàn phím, chuột và bàn di chuột](34-keyboard-mouse-trackpad.md) để biết các cử chỉ.

Các phím tắt thay đổi kích thước dùng các phím vật lý `code:20` và `code:21` (XKB `<AE11>` và `<AE12>`), bất kể các ký tự được in trên bàn phím. Trên bàn phím US các phím này là `-` và `=`; trên bàn phím Nhật (JIS) chúng là `-` và `^`; trên bàn phím Tây Ban Nha chúng là `'` và `¡`. Trên JIS, `Super + ^` là `Super + Equal`, trong khi `Super + Shift + -` (gõ ra `=`) là `Super + Shift + Minus`.

## Điều khiển hệ thống

| Phím tắt                  | Chức năng              |
| ----------------------- | --------------------- |
| `Super + Ctrl + A`           | Bảng âm thanh    |
| `Super + Ctrl + B`           | Bảng Bluetooth    |
| `Super + Ctrl + N`           | Bảng Wi-Fi/mạng    |
| `Super + Ctrl + D`           | Bảng màn hình    |
| `Super + Ctrl + P`           | Bảng nguồn    |
| `Super + Ctrl + X`           | Bảng Agents    |
| `Super + Ctrl + Alt + X`           | Bảng mô hình cục bộ    |
| `Super + Ctrl + Alt + D`           | Bảng lịch    |
| `Super + Ctrl + Alt + E`           | Bảng đồng hồ thế giới    |
| `Super + Ctrl + 1-9`           | Bật/tắt bảng trên thanh theo vị trí    |
| `Super + Ctrl + S` | Menu chia sẻ (qua LocalSend) |
| `Super + Ctrl + C` | Điều khiển chụp (ảnh chụp màn hình/ghi hình/bộ chọn) |
| `Super + Ctrl + O` | Bật/tắt menu |
| `Super + Ctrl + H` | Menu phần cứng |
| `Super + Ctrl + E` | Bộ chọn emoji |
| `Super + Ctrl + .` | Chuyển mã phương tiện |
| `Super + Shift + Ctrl + A` | Khởi động agent mặc định của bạn |
| `Power` key | Menu hệ thống |
| `Super + Shift + Copilot` key | Menu Omarchy |

## Điều chỉnh

| Phím tắt                  | Chức năng              |
| ----------------------- | --------------------- |
| `Shift + Brightness Up` | Độ sáng màn hình tối đa |
| `Shift + Brightness Down` | Độ sáng màn hình tối thiểu |
| `Alt + Brightness Up/Down` | Thay đổi độ sáng chính xác 1% |
| `Alt + Volume Up/Down` | Thay đổi âm lượng chính xác 1% |
| `Keyboard Brightness Up/Down` | Đèn nền bàn phím sáng hơn/mờ hơn |
| `Keyboard Backlight` | Luân chuyển các mức đèn nền bàn phím |
| `Ctrl + Brightness Up/Down` | Đèn nền bàn phím sáng hơn/mờ hơn, trên các bàn phím không có phím riêng của chúng |
| `Mic Mute` | Tắt tiếng micrô |
| `Shift + Mute` | Chuyển đầu ra âm thanh |
| `Touchpad Toggle` | Bật hoặc tắt bàn di chuột |
| `Display` key | Luân chuyển bố cục không gian làm việc |
| `Alt + Play` | Bài tiếp theo |
| `Alt + Shift + Play` | Bài trước đó |

## Khởi chạy ứng dụng

| Phím tắt                  | Chức năng              |
| ----------------------- | --------------------- |
| `Super + Return`           | Terminal    |
| `Super + Alt + Return` | Terminal Tmux |
| `Super + Ctrl + Return` | Herdr (trình quản lý agent) |
| `Super + Shift + Return` hoặc `Super + Shift + B`  | Trình duyệt    |
| `Super + Shift + Alt + B`           | Trình duyệt (riêng tư/ẩn danh)    |
| `Super + Shift + F`           | Trình quản lý tập tin    |
| `Super + Shift + Alt + F`           | Trình quản lý tập tin trong cwd của terminal    |
| `Super + Shift + M`           | Nhạc (Spotify)    |
| `Super + Shift + Alt + M`           | Nhạc (cliamp)    |
| `Super + Shift + /`           | Trình quản lý mật khẩu (1password)    |
| `Super + Shift + Q` hoặc `Calculator` key  | Máy tính (Omacalc)    |
| `Super + Shift + D`           | Docker (lazydocker, sau khi đã cài đặt)    |
| `Super + Shift + T`           | Hoạt động (btop)    |
| `Super + Shift + N`           | Trình soạn thảo (Plain, hoặc trình mặc định bạn đã chọn)  |
| `Super + Shift + C`           | Lịch ([HEY](https://hey.com/))  |
| `Super + Shift + E`           | Email ([HEY](https://hey.com/))  |
| `Super + Shift + Alt + E`           | Email mới ([HEY](https://hey.com/))  |
| `Super + Shift + A`           | Agent mặc định của bạn, hoặc ChatGPT cho đến khi bạn chọn một agent |
| `Super + Shift + Alt + A`           | AI (Grok)  |
| `Super + Shift + G`           | Nhắn tin (Signal)  |
| `Super + Shift + P`           | Google Photos  |
| `Super + Shift + S`           | Google Maps  |
| `Super + Shift + Alt + G`           | Nhắn tin (WhatsApp)  |
| `Super + Shift + Ctrl + G`           | Nhắn tin (Google)  |
| `Super + Shift + O`           | Obsidian  |
| `Super + Shift + W`           | Viết (Omawrite)  |
| `Super + Shift + X`           | X |
| `Super + Shift + Alt + X`           | X (bài đăng mới) |
| `Super + Shift + Y`           | YouTube |

Thay đổi/thêm các gán phím trong `~/.config/hypr/bindings.lua`.

## Bảng nhớ tạm phổ quát

| Phím tắt                  | Chức năng              |
| ----------------------- | --------------------- |
| `Super + A`           | Chọn tất cả trong các ứng dụng hỗ trợ `Ctrl + A`    |
| `Super + C`           | Sao chép    |
| `Super + X`           | Cắt (không áp dụng trong terminal)    |
| `Super + V`           | Dán    |
| `Super + Ctrl + V`           | Trình quản lý bảng nhớ tạm    |

Thông thường trên Linux, bạn cần `Ctrl + Shift + C/V` để sao chép và dán trong terminal và `Ctrl + C/V` để làm điều đó ở mọi nơi khác. Các phím tắt bảng nhớ tạm hợp nhất này của Omarchy hoạt động ở mọi nơi.

## Chụp

| Phím tắt              | Chức năng                       |
| ------------------- | ------------------------------ |
| `Print Screen`            | Ảnh chụp màn hình                      |
| `Super + Ctrl + Alt + C`            | Ảnh chụp màn hình (cùng một kiểu chụp, dành cho bàn phím không có phím Print Screen) |
| `Super + Ctrl + C` | Menu chụp |
| `Alt + Print Screen`            | Ghi màn hình                     |
| `Super + Shift + Ctrl + Alt + C` | Ghi màn hình không có âm thanh, bỏ qua menu (nhấn lại để dừng) |
| `Super + Print Screen` | Bộ chọn màu |
| `Super + Ctrl + Print Screen` | Trích xuất văn bản vào bảng nhớ tạm |
| `Super + Alt + [` | Thu nhỏ lớp phủ webcam trong khi ghi |
| `Super + Alt + ]` | Phóng to lớp phủ webcam trong khi ghi |
| `Alt + Shift + L` | Sao chép URL hiện tại từ webapp hoặc trình duyệt |
| `Alt + Shift + D` | Tải video trên trang hiện tại xuống `~/Videos` |
| `Alt + Space` | Bắt đầu/dừng đọc chính tả (yêu cầu _Setup > Defaults > Dictation_) |
| `Right Alt` | Giữ để đọc chính tả (yêu cầu _Setup > Defaults > Dictation_) |

Với ghi màn hình, phím tắt trước tiên hỏi bạn muốn âm thanh nào, rồi bắt đầu ghi. Nhấn lại để dừng. Xem [ảnh chụp màn hình và ghi hình](12-screenshots-recording.md) để biết chi tiết.

Mọi tùy chọn chụp cũng có thể truy cập trong _Trigger > Capture_ trong menu Omarchy (`Super + Space`).

## Thông báo

| Phím tắt                  | Chức năng              |
| ----------------------- | --------------------- |
| `Super + ,` | Thao tác với thông báo mới nhất: mở nó hoặc nhấn nút duy nhất của nó, chọn từ các lựa chọn của nó, hoặc bỏ qua nó khi nó không có lựa chọn nào  |
| `Super + Shift + ,` | Bỏ qua mọi thông báo |
| `Super + Ctrl + ,` | Điều khiển thông báo bằng bàn phím  |
| `Super + Alt + ,` | Bỏ qua thông báo mới nhất  |
| `Super + Shift + Alt + ,` | Mở lịch sử thông báo  |
| `Super + Ctrl + Alt + ,` | Bật/tắt việc tắt tiếng thông báo  |

## Phong cách

| Phím tắt                  | Chức năng              |
| ----------------------- | --------------------- |
| `Super + Ctrl + T` | Chọn một theme mới (cũng là `Super + Ctrl + Shift + Space`) |
| `Super + Ctrl + W` | Chọn hình nền của theme (cũng là `Super + Ctrl + Space`) |
| `Super + Backspace` | Bật/tắt độ trong suốt trên một cửa sổ |
| `Super + Ctrl + Backspace` | Bật/tắt tỉ lệ vuông cho một cửa sổ đơn |

Các hình nền bổ sung sống trong `~/.config/omarchy/backgrounds/<theme name>`. Cũng có sẵn qua _Install > Style > Background_ trong menu Omarchy.

Mọi tùy chọn phong cách cũng có thể truy cập trong _Appearance_ trong menu Omarchy (`Super + Space`).

## Các công tắc

| Phím tắt                  | Chức năng              |
| ----------------------- | --------------------- |
| `Super + Ctrl + I` | Bật/tắt khóa khi không hoạt động |
| `Super + Ctrl + Delete` | Bật/tắt màn hình laptop |
| `Super + Ctrl + Alt + Delete` | Bật/tắt phản chiếu màn hình laptop |
| `Super + Shift + Space` | Bật/tắt thanh trên cùng  |
| `Shift + Mute` | Chuyển sang đầu ra âm thanh tiếp theo |
| `Shift + Play` | Chuyển sang nguồn phương tiện tiếp theo |
| `Super + Shift + Backspace` | Bật/tắt khoảng trống giữa các cửa sổ |
| `Super + Ctrl + Alt + F` | Bật/tắt desktop toàn màn hình (thanh trên cùng + khoảng trống giữa các cửa sổ) |

## Nhắc nhở

| Phím tắt                  | Chức năng              |
| ----------------------- | --------------------- |
| `Super + Ctrl + R` | Đặt một nhắc nhở  |
| `Super + Ctrl + Alt + R` | Xem mọi nhắc nhở  |
| `Super + Ctrl + Shift + R` | Xóa mọi nhắc nhở  |

## Thông báo ngắn

| Phím tắt                  | Chức năng              |
| ----------------------- | --------------------- |
| `Super + Ctrl + Alt + T` | Hiển thị giờ dưới dạng thông báo  |
| `Super + Ctrl + Alt + B` | Hiển thị pin dưới dạng thông báo  |
| `Super + Ctrl + Alt + W` | Bật/tắt thời tiết dưới dạng thông báo  |

## Tmux

Phím tiền tố là `Ctrl + Space` (`Ctrl + B` cũng hoạt động). Bạn có thể thay đổi các gán phím này trong `~/.config/tmux/tmux.conf`.

### Các ngăn

| Phím tắt                  | Chức năng              |
| ----------------------- | --------------------- |
| `Prefix + v` | Chia ngăn bên cạnh (dọc) |
| `Prefix + h` | Chia ngăn bên dưới (ngang) |
| `Prefix + x` | Đóng ngăn |
| `Prefix + z` | Bật/tắt phóng to ngăn (toàn màn hình) |
| `Alt + Enter` | Chia ngăn bên dưới (không cần tiền tố) |
| `Alt + Shift + Enter` | Chia ngăn bên cạnh (không cần tiền tố) |
| `Alt + Escape` | Đóng ngăn (không cần tiền tố) |
| `Ctrl + Alt + Arrows` | Di chuyển giữa các ngăn |
| `Ctrl + Alt + Shift + Arrows` | Thay đổi kích thước các ngăn |

### Cửa sổ

| Phím tắt                  | Chức năng              |
| ----------------------- | --------------------- |
| `Prefix + c` | Cửa sổ mới |
| `Prefix + k` | Đóng cửa sổ |
| `Prefix + r` | Đổi tên cửa sổ |
| `Alt + 1-9` | Đi tới cửa sổ cụ thể |
| `Alt + Arrow Left/Right` | Di chuyển giữa các cửa sổ |
| `Alt + Shift + Arrow Left/Right` | Di chuyển cửa sổ sang trái/phải |

### Các phiên

| Phím tắt                  | Chức năng              |
| ----------------------- | --------------------- |
| `Prefix + C` | Phiên mới |
| `Prefix + K` | Đóng phiên |
| `Prefix + R` | Đổi tên phiên |
| `Prefix + N` | Phiên tiếp theo |
| `Prefix + P` | Phiên trước đó |
| `Alt + Arrow Up/Down` | Di chuyển giữa các phiên |
| `Prefix + s` | Liệt kê các phiên |
| `Prefix + d` | Tách khỏi phiên |

### Chế độ sao chép (kiểu vi)

| Phím tắt                  | Chức năng              |
| ----------------------- | --------------------- |
| `Prefix + [` | Vào chế độ sao chép |
| `v` | Bắt đầu chọn (trong chế độ sao chép) |
| `y` | Sao chép vùng chọn (trong chế độ sao chép) |

### Chung

| Phím tắt                  | Chức năng              |
| ----------------------- | --------------------- |
| `Prefix + q` | Tải lại cấu hình |
| `Prefix + ?` | Hiển thị các gán phím Tmux |
| `Prefix + :` | Dấu nhắc lệnh |

### Các hàm bố cục Tmux

Các hàm này phải được chạy bên trong một phiên Tmux.

| Lệnh | Chức năng |
| ------- | -------- |
| `tdl <ai> [<second_ai>]` | Tạo bố cục dev với trình soạn thảo, AI và terminal |
| `tdlm <ai> [<second_ai>]` | Tạo bố cục dev cho mỗi thư mục con |
| `tsl <count> <command>` | Tạo bố cục swarm nhiều ngăn |

## Ghostty Terminal

Terminal Ghostty được cài đặt bằng _Install > Terminal_ qua menu Omarchy.

| Phím tắt                  | Chức năng              |
| ----------------------- | --------------------- |
| `Ctrl + Shift + E` | Chia mới bên dưới |
| `Ctrl + Shift + O` | Chia mới bên cạnh |
| `Ctrl + Alt + Arrows` | Di chuyển giữa các phần chia |
| `Super + Ctrl + Shift + Arrows` | Thay đổi kích thước phần chia theo 10 dòng |
| `Super + Ctrl + Shift + Alt + Arrows` | Thay đổi kích thước phần chia theo 100 dòng |
| `Ctrl + Shift + T` | Tab mới  |
| `Ctrl + Shift + Arrows` | Di chuyển giữa các tab |
| `Alt + Numbers` | Đi tới tab cụ thể |
| `Shift + Pg Up/Down` | Cuộn lịch sử |
| `Ctrl + Left mouse` | Mở liên kết trong trình duyệt |

## Trình quản lý tập tin

| Phím tắt              | Chức năng                       |
| ------------------- | ------------------------------ |
| `Ctrl + L`            | Đi tới đường dẫn                     |
| `Space`               | Xem trước tập tin (các mũi tên để điều hướng) |
| `Alt + Up`       | Đi lên thư mục cha        |

## Neovim (w/ lazyvim)

### Điều hướng

| Phím tắt                   | Chức năng                        |
| ------------------------ | ------------------------------- |
| `Space`                    | Hiển thị các tùy chọn lệnh            |
| `Space Space`              | Mở tập tin qua tìm kiếm mờ      |
| `Space E`                  | Bật/tắt thanh bên                  |
| `Space G G`                | Hiển thị các điều khiển git               |
| `Space S G`                | Tìm kiếm nội dung tập tin             |
| `Ctrl + W W`               | Nhảy giữa thanh bên và trình soạn thảo |
| `Ctrl + Left/right arrow`  | Thay đổi kích thước thanh bên          |
| `Shift + H`                      | Đi tới tab tập tin bên trái             |
| `Shift + L`                      | Đi tới tab tập tin bên phải            |
| `Space B D`                | Đóng tab tập tin                  |

### Khi ở trong thanh bên

| Phím tắt                   | Chức năng                        |
| ------------------------ | ------------------------------- |
| `A`                        | Thêm tập tin mới trong thư mục cha      |
| `Shift + A`                | Thêm thư mục con mới trong thư mục cha    |
| `D`                        | Xóa tập tin/thư mục được đánh dấu     |
| `M`                        | Di chuyển tập tin/thư mục được đánh dấu       |
| `R`                        | Đổi tên tập tin/thư mục được đánh dấu     |
| `?`                        | Hiển thị trợ giúp cho mọi lệnh      |

[Xem mọi phím tắt Neovim được cấu hình bởi LazyVim](https://www.lazyvim.org/keymaps).

## Emoji nhanh

Bạn có thể dùng `Super + Ctrl + E` để hiển thị một bộ chọn emoji đầy đủ sẽ đặt lựa chọn vào bảng nhớ tạm hoặc bạn có thể dùng các tùy chọn truy cập nhanh này.

| Phím tắt       | EM | Gợi ý       |
| ------------ | -- | ---------- |
| `Shift + CapsLock M S` | 😄 | nụ cười      |
| `Shift + CapsLock M C` | 😂 | khóc        |
| `Shift + CapsLock M L` | 😍 | yêu       |
| `Shift + CapsLock M V` | ✌️ | chiến thắng    |
| `Shift + CapsLock M H` | ❤️ | trái tim      |
| `Shift + CapsLock M Y` | 👍 | đồng ý        |
| `Shift + CapsLock M N` | 👎 | không đồng ý         |
| `Shift + CapsLock M F` | 🖕 | chửi       |
| `Shift + CapsLock M W` | 🤞 | điều ước       |
| `Shift + CapsLock M R` | 🤘 | rock       |
| `Shift + CapsLock M K` | 😘 | hôn       |
| `Shift + CapsLock M E` | 🙄 | đảo mắt    |
| `Shift + CapsLock M I` | 😉 | nháy mắt       |
| `Shift + CapsLock M P` | 🙏 | cầu nguyện |
| `Shift + CapsLock M D` | 🤤 | chảy nước dãi      |
| `Shift + CapsLock M M` | 💰 | tiền      |
| `Shift + CapsLock M X` | 🎉 | ăn mừng |
| `Shift + CapsLock M 1` | 💯 | 100%       |
| `Shift + CapsLock M T` | 🥂 | nâng ly      |
| `Shift + CapsLock M O` |👌 | ok |
| `Shift + CapsLock M G` |👋 | chào hỏi |
| `Shift + CapsLock M A` |💪 | cánh tay |
| `Shift + CapsLock M B` |🤯 | bùng nổ |

## Hoàn thành nhanh

| Phím tắt       | Hoàn thành       |
| ------------ |  ---------- |
| `Shift + CapsLock Space Space` | — (mdash)   |
| `Shift + CapsLock Space N` | Tên của bạn (như đã nhập khi thiết lập)  |
| `Shift + CapsLock Space E` | Email của bạn (như đã nhập khi thiết lập)  |

Bạn có thể thêm nhiều hơn của riêng mình bằng cách chỉnh sửa `~/.XCompose`, rồi chạy `omarchy restart xcompose` trong terminal để các thay đổi được áp dụng.
