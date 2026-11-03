# Phím tắt

Bạn có thể xem tất cả các phím tắt bàn phím chính bằng `Super + K` (các phím tắt Tmux bằng `Super + Alt + K` và các phím tắt Herdr bằng `Super + Ctrl + K`).

## Cách bố trí phím tắt

Mỗi phím tắt nằm trên một tầng, được xác định bởi các phím bổ trợ của nó, và mỗi tầng có một nhiệm vụ. Đó là thứ giữ cho các phím tắt không nhập nhằng vào nhau, và nó có nghĩa là bạn thường có thể đoán được một thứ gì đó sống ở đâu.

| Tầng | Cái gì sống ở đó | Ví dụ |
| --- | --- | --- |
| `Super + key` | Hệ thống: cửa sổ, workspace, bố cục và các menu cốt lõi | `Super + Space` menu Omarchy, `Super + W` đóng cửa sổ, `Super + F` toàn màn hình |
| `Super + Shift + key` | Ứng dụng | `Super + Shift + B` trình duyệt, `Super + Shift + E` email, `Super + Shift + N` trình soạn thảo |
| `Super + Ctrl + key` | Bảng điều khiển và menu hệ thống | `Super + Ctrl + A` âm thanh, `Super + Ctrl + N` mạng, `Super + Ctrl + C` menu chụp |
| `Super + Ctrl + Alt + key` | Thao tác nhanh và thông báo trạng thái | `Super + Ctrl + Alt + T` hiển thị giờ, `Super + Ctrl + Alt + B` pin, `Super + Ctrl + Alt + C` ảnh chụp màn hình |

Thêm `Alt` vào một phím tắt cho bạn một biến thể của cùng một thứ, không bao giờ là một thứ không liên quan:

- `Super + Shift + B` mở trình duyệt; `Super + Shift + Alt + B` mở một cửa sổ riêng tư
- `Super + Shift + E` mở email; `Super + Shift + Alt + E` bắt đầu một email mới
- `Super + F` vào toàn màn hình; `Super + Alt + F` vào toàn chiều rộng
- `Super + Ctrl + C` mở menu chụp; `Super + Ctrl + Alt + C` bỏ qua menu và chụp ảnh màn hình

Khi thêm một phím tắt:

1. Chọn tầng từ việc nó làm, rồi chọn phím.
2. Đừng di chuyển một phím tắt hiện có để lấy chỗ. Tìm một phím trống trên tầng phù hợp.
3. Chỉ dùng `Alt` cho một biến thể của phím tắt không có nó.

Một vài phím tắt phá vỡ các quy tắc này vì chúng tiện lợi. `Shift` với một phím mũi tên hoặc `Tab` di chuyển hoặc đảo ngược thay vì mở một ứng dụng, và `Print`, các phím media, `Alt + Tab`, và `Ctrl + Alt + Del` hoạt động theo cách chúng hoạt động ở mọi nơi khác. Chúng là các ngoại lệ, không phải các mẫu để sao chép.

Nếu một mặc định không phù hợp với bạn (chẳng hạn bạn muốn `Super + Shift + S` cho ảnh chụp màn hình giống như trên Windows), hãy gán lại nó trong `~/.config/hypr/bindings.lua`.

## Điều hướng

| Phím tắt                  | Chức năng              |
| ----------------------- | --------------------- |
| `Super + Space`           | Menu Omarchy (ứng dụng và mọi thứ khác)    |
| `Super + Alt + Space` | Lưới ứng dụng |
| `Super + Escape` | Menu hệ thống (tạm dừng, khởi động lại, v.v.)  |
| `Super + Ctrl + L` | Khóa máy tính |
| `Super + W` or `Super + Q` | Đóng cửa sổ             |
| `Ctrl + Alt + Del` | Đóng tất cả cửa sổ |
| `Super + T`               | Chuyển cửa sổ giữa tiling/floating             |
| `Super + J` | Chuyển vị trí cửa sổ (ngang/dọc) |
| `Super + O`               | Chuyển cửa sổ bật lên thành sticky'n'floating |
| `Super + L`               | Xoay vòng qua các bố cục dwindle, scrolling và floating |
| `Super + Alt + L`         | Xoay vòng qua các bố cục theo chiều ngược lại |
| `Super + P`               | Chuyển kiểu cửa sổ pseudo (natural v stretch) |
| `Super + F`                 | Vào toàn màn hình              |
| `Super + Alt + F`                 | Vào toàn chiều rộng              |
| `Super + Ctrl + F`                 | Vào toàn màn hình bên trong cửa sổ              |
| `Super + 1/2/3/4`         | Nhảy đến workspace cụ thể trên màn hình đang được focus |
| `Super + Tab` | Nhảy đến workspace tiếp theo trên màn hình đang được focus |
| `Super + Shift + Tab` | Nhảy đến workspace trước đó trên màn hình đang được focus |
| `Super + Ctrl + Tab` | Nhảy đến workspace trước đây trên màn hình đang được focus |
| `Super + Shift + 1/2/3/4` | Di chuyển cửa sổ đến workspace trên màn hình đang được focus |
| `Super + Shift + Alt + 1/2/3/4` | Di chuyển cửa sổ đến workspace trên màn hình đang được focus mà không đi theo |
| `Super + S` | Bật/tắt scratchpad đầy đủ |
| `Super + Alt + S` | Di chuyển cửa sổ đến scratchpad đầy đủ |
| `Super + Grave` | Bật/tắt Quake console |
| `Super + Shift + Grave` | Di chuyển cửa sổ đến Quake console |
| `Super + Shift + Ctrl + Arrows` | Di chuyển cửa sổ đến màn hình theo hướng đó |
| `Super + Shift + Alt + Arrows` | Di chuyển workspace đến màn hình theo hướng đó |
| `Super + Arrow`  | Di chuyển focus đến cửa sổ theo hướng mũi tên, băng sang màn hình ở phía đó khi ở cạnh màn hình |
| `Super + Shift + Arrow`  | Hoán đổi cửa sổ với một cửa sổ khác theo hướng mũi tên, bao gồm cả cửa sổ trên màn hình ở phía đó |
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
| `Super + Scroll Wheel` | Cuộn qua các workspace trên màn hình đang được focus |
| `Super + G`               | Bật/tắt nhóm cửa sổ      |
| `Super + Alt + G`               | Đưa cửa sổ ra khỏi nhóm      |
| `Super + Alt + Tab`               | Xoay vòng giữa các cửa sổ trong nhóm      |
| `Super + Alt + Shift + Tab`               | Xoay vòng ngược lại giữa các cửa sổ trong nhóm      |
| `Super + Alt + Scroll Wheel` | Xoay vòng giữa các cửa sổ trong nhóm |
| `Super + Alt + 1/2/3/4/5`               | Nhảy đến cửa sổ cụ thể trong nhóm      |
| `Super + Alt + Arrow`  | Di chuyển cửa sổ vào nhóm theo hướng mũi tên, bao gồm cả cửa sổ trên màn hình ở phía đó |
| `Super + Ctrl + Left/Right`  | Di chuyển giữa các cửa sổ bên trong một nhóm tiling |
| `Super + Ctrl + Z` | Phóng to màn hình (lặp lại để phóng to hơn) |
| `Super + Ctrl + Alt + Z` | Thu nhỏ hoàn toàn khỏi màn hình |
| `Super + /` | Tiến lên qua các tùy chọn tỷ lệ màn hình |
| `Super + Alt + /` | Lùi lại qua các tùy chọn tỷ lệ màn hình |
| `Alt + Tab` | Xoay vòng tiến lên qua các cửa sổ trên workspace đang hoạt động |
| `Alt + Shift + Tab` | Xoay vòng ngược lại qua các cửa sổ trên workspace đang hoạt động |
| `Ctrl + Alt + Tab`| Xoay vòng focus tiến lên qua các màn hình |
| `Ctrl + Alt + Shift + Tab`| Xoay vòng focus ngược lại qua các màn hình |

Các phím tắt thay đổi kích thước dùng các phím vật lý `code:20` và `code:21` (XKB `<AE11>` và `<AE12>`), bất kể các ký tự được in trên bàn phím. Trên bàn phím US các phím này là `-` và `=`; trên bàn phím Nhật Bản (JIS) chúng là `-` và `^`; trên bàn phím Tây Ban Nha chúng là `'` và `¡`. Trên JIS, `Super + ^` là `Super + Equal`, trong khi `Super + Shift + -` (gõ ra `=`) là `Super + Shift + Minus`.

## Điều khiển hệ thống

| Phím tắt                  | Chức năng              |
| ----------------------- | --------------------- |
| `Super + Ctrl + A`           | Bảng âm thanh    |
| `Super + Ctrl + B`           | Bảng Bluetooth    |
| `Super + Ctrl + N`           | Bảng Wi-Fi/mạng    |
| `Super + Ctrl + D`           | Bảng hiển thị    |
| `Super + Ctrl + P`           | Bảng nguồn    |
| `Super + Ctrl + Alt + D`           | Bảng lịch    |
| `Super + Ctrl + Alt + E`           | Bảng đồng hồ thế giới    |
| `Super + Ctrl + 1-9`           | Bật/tắt bảng trên thanh theo vị trí    |
| `Super + Ctrl + S` | Menu chia sẻ (qua LocalSend) |
| `Super + Ctrl + C` | Điều khiển chụp (ảnh chụp màn hình/quay màn hình/bộ chọn) |
| `Super + Ctrl + O` | Menu bật/tắt |
| `Super + Ctrl + H` | Menu phần cứng |
| `Super + Ctrl + E` | Bộ chọn emoji |
| `Super + Ctrl + .` | Chuyển mã media |
| `Super + Shift + Ctrl + A` | Chọn một AI agent |

## Điều chỉnh

| Phím tắt                  | Chức năng              |
| ----------------------- | --------------------- |
| `Shift + Brightness Up` | Độ sáng màn hình tối đa |
| `Shift + Brightness Down` | Độ sáng màn hình tối thiểu |
| `Alt + Brightness Up/Down` | Thay đổi độ sáng chính xác 1% |
| `Alt + Volume Up/Down` | Thay đổi âm lượng chính xác 1% |
| `Keyboard Brightness Up/Down` | Đèn nền bàn phím sáng hơn/mờ hơn |
| `Keyboard Backlight` | Xoay vòng các mức đèn nền bàn phím |
| `Alt + Play` | Bài tiếp theo |
| `Alt + Shift + Play` | Bài trước đó |

## Khởi chạy ứng dụng

| Phím tắt                  | Chức năng              |
| ----------------------- | --------------------- |
| `Super + Return`           | Terminal    |
| `Super + Alt + Return` | Terminal Tmux |
| `Super + Ctrl + Return` | Herdr (trình quản lý agent) |
| `Super + Shift + Return`           | Trình duyệt    |
| `Super + Shift + Alt + B`           | Trình duyệt (riêng tư/ẩn danh)    |
| `Super + Shift + F`           | Trình quản lý tập tin    |
| `Super + Shift + Alt + F`           | Trình quản lý tập tin trong cwd của terminal    |
| `Super + Shift + M`           | Nhạc (Spotify)    |
| `Super + Shift + Alt + M`           | Nhạc (cliamp)    |
| `Super + Shift + /`           | Trình quản lý mật khẩu (1password)    |
| `Super + Shift + Q`           | Máy tính (Omacalc)    |
| `Super + Shift + T`           | Hoạt động (btop)    |
| `Super + Shift + N`           | Trình soạn thảo (Neovim)  |
| `Super + Shift + C`           | Lịch ([HEY](https://hey.com/))  |
| `Super + Shift + E`           | Email ([HEY](https://hey.com/))  |
| `Super + Shift + Alt + E`           | Email mới ([HEY](https://hey.com/))  |
| `Super + Shift + A`           | AI (ChatGPT)  |
| `Super + Shift + Alt + A`           | AI (Grok)  |
| `Super + Shift + G`           | Nhắn tin (Signal)  |
| `Super + Shift + P`           | Google Photos  |
| `Super + Shift + S`           | Google Maps  |
| `Super + Shift + Alt + G`           | Nhắn tin (WhatsApp)  |
| `Super + Shift + Ctrl + G`           | Nhắn tin (Google)  |
| `Super + Shift + O`           | Obsidian  |
| `Super + Shift + W`           | Viết (Omawrite)  |
| `Super + Shift + X`           | X |
| `Super + Shift + Alt + X`           | X Compose |
| `Super + Shift + Y`           | YouTube |

Thay đổi/thêm các phím tắt trong `~/.config/hypr/bindings.lua`.

## Clipboard chung cho mọi nơi

| Phím tắt                  | Chức năng              |
| ----------------------- | --------------------- |
| `Super + A`           | Chọn tất cả trong các ứng dụng hỗ trợ `Ctrl + A`    |
| `Super + C`           | Sao chép    |
| `Super + X`           | Cắt (không dùng trong terminal)    |
| `Super + V`           | Dán    |
| `Super + Ctrl + V`           | Trình quản lý clipboard    |

Thường thì trên Linux, bạn cần `Ctrl + Shift + C/V` để sao chép'n'dán trong terminal và `Ctrl + C/V` để làm việc đó ở mọi nơi khác. Các phím tắt clipboard hợp nhất này của Omarchy hoạt động ở mọi nơi.

## Chụp/quay

| Phím tắt              | Chức năng                       |
| ------------------- | ------------------------------ |
| `Print Screen`            | Ảnh chụp màn hình                      |
| `Super + Ctrl + Alt + C`            | Ảnh chụp màn hình (cùng một kiểu chụp, dành cho bàn phím không có phím Print Screen) |
| `Super + Ctrl + C` | Menu chụp/quay |
| `Alt + Print Screen`            | Quay màn hình                     |
| `Super + Print Screen` | Bộ chọn màu |
| `Super + Ctrl + Print Screen` | Trích xuất văn bản vào clipboard |
| `Super + Alt + [` | Thu nhỏ lớp phủ webcam trong khi quay |
| `Super + Alt + ]` | Phóng to lớp phủ webcam trong khi quay |
| `Alt + Shift + L` | Sao chép URL hiện tại từ webapp hoặc Chromium |
| `Alt + Shift + D` | Tải video trên trang hiện tại xuống `~/Videos` |
| `Alt + Space` | Bắt đầu/dừng đọc chính tả (yêu cầu _Setup > Defaults > Dictation_) |
| `Right Alt` | Giữ để đọc chính tả (yêu cầu _Setup > Defaults > Dictation_) |

Với quay màn hình, phím tắt trước tiên hỏi bạn muốn âm thanh nào, rồi bắt đầu quay. Nhấn nó lần nữa để dừng. Xem [ảnh chụp màn hình và quay màn hình](12-screenshots-recording.md) để biết chi tiết.

Tất cả các tùy chọn chụp/quay cũng có thể truy cập được dưới _Trigger > Capture_ trong menu Omarchy (`Super + Space`).

## Thông báo

| Phím tắt                  | Chức năng              |
| ----------------------- | --------------------- |
| `Super + ,` | Thực hiện hành động trên thông báo mới nhất: mở nó hoặc nhấn nút duy nhất của nó, chọn từ các lựa chọn của nó, hoặc bỏ qua nó khi nó không có lựa chọn nào  |
| `Super + Shift + ,` | Bỏ qua tất cả thông báo |
| `Super + Ctrl + ,` | Điều khiển thông báo bằng bàn phím  |
| `Super + Alt + ,` | Bỏ qua thông báo mới nhất  |
| `Super + Shift + Alt + ,` | Mở lịch sử thông báo  |
| `Super + Ctrl + Alt + ,` | Bật/tắt tắt tiếng thông báo  |

## Phong cách

| Phím tắt                  | Chức năng              |
| ----------------------- | --------------------- |
| `Super + Ctrl + T` | Chọn một theme mới (cũng là `Super + Ctrl + Shift + Space`) |
| `Super + Ctrl + W` | Chọn hình nền của theme (cũng là `Super + Ctrl + Space`) |
| `Super + Backspace` | Bật/tắt độ trong suốt trên một cửa sổ |
| `Super + Ctrl + Backspace` | Bật/tắt tỷ lệ vuông cho một cửa sổ đơn |

Các hình nền bổ sung sống trong `~/.config/omarchy/backgrounds/<theme name>`. Cũng có sẵn qua _Install > Style > Background_ trong menu Omarchy.

Tất cả các tùy chọn phong cách cũng có thể truy cập được dưới _Style_ trong menu Omarchy (`Super + Space`).

## Bật/tắt

| Phím tắt                  | Chức năng              |
| ----------------------- | --------------------- |
| `Super + Ctrl + I` | Bật/tắt khóa khi nhàn rỗi |
| `Super + Ctrl + Delete` | Bật/tắt màn hình laptop |
| `Super + Ctrl + Alt + Delete` | Bật/tắt phản chiếu màn hình laptop |
| `Super + Shift + Space` | Bật/tắt thanh trên cùng  |
| `Shift + Mute` | Chuyển sang đầu ra âm thanh tiếp theo |
| `Shift + Play` | Chuyển sang nguồn media tiếp theo |
| `Super + Shift + Backspace` | Bật/tắt khoảng trống giữa các cửa sổ |
| `Super + Ctrl + Alt + F` | Bật/tắt desktop toàn màn hình (thanh trên cùng + khoảng trống giữa các cửa sổ) |

## Nhắc nhở

| Phím tắt                  | Chức năng              |
| ----------------------- | --------------------- |
| `Super + Ctrl + R` | Đặt một nhắc nhở  |
| `Super + Ctrl + Alt + R` | Xem tất cả nhắc nhở  |
| `Super + Ctrl + Shift + R` | Xóa tất cả nhắc nhở  |

## Thông báo trạng thái

| Phím tắt                  | Chức năng              |
| ----------------------- | --------------------- |
| `Super + Ctrl + Alt + T` | Hiển thị giờ dưới dạng thông báo  |
| `Super + Ctrl + Alt + B` | Hiển thị pin dưới dạng thông báo  |
| `Super + Ctrl + Alt + W` | Bật/tắt hiển thị thời tiết dưới dạng thông báo  |

## Tmux

Phím prefix là `Ctrl + Space` (`Ctrl + B` cũng hoạt động). Bạn có thể thay đổi các phím tắt này trong `~/.config/tmux/tmux.conf`.

### Ngăn

| Phím tắt                  | Chức năng              |
| ----------------------- | --------------------- |
| `Prefix + v` | Chia ngăn sang bên cạnh (dọc) |
| `Prefix + h` | Chia ngăn xuống bên dưới (ngang) |
| `Prefix + x` | Tắt ngăn |
| `Prefix + z` | Bật/tắt zoom ngăn (toàn màn hình) |
| `Alt + Enter` | Chia ngăn xuống bên dưới (không cần prefix) |
| `Alt + Shift + Enter` | Chia ngăn sang bên cạnh (không cần prefix) |
| `Alt + Escape` | Tắt ngăn (không cần prefix) |
| `Ctrl + Alt + Arrows` | Di chuyển giữa các ngăn |
| `Ctrl + Alt + Shift + Arrows` | Thay đổi kích thước các ngăn |

### Cửa sổ

| Phím tắt                  | Chức năng              |
| ----------------------- | --------------------- |
| `Prefix + c` | Cửa sổ mới |
| `Prefix + k` | Tắt cửa sổ |
| `Prefix + r` | Đổi tên cửa sổ |
| `Alt + 1-9` | Đến cửa sổ cụ thể |
| `Alt + Arrow Left/Right` | Di chuyển giữa các cửa sổ |
| `Alt + Shift + Arrow Left/Right` | Di chuyển cửa sổ sang trái/phải |

### Phiên

| Phím tắt                  | Chức năng              |
| ----------------------- | --------------------- |
| `Prefix + C` | Phiên mới |
| `Prefix + K` | Tắt phiên |
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
| `Prefix + ?` | Hiển thị các phím tắt Tmux |
| `Prefix + :` | Dấu nhắc lệnh |

### Các hàm bố cục Tmux

Các hàm này phải được chạy bên trong một phiên Tmux.

| Lệnh | Chức năng |
| ------- | -------- |
| `tdl <ai> [<second_ai>]` | Tạo bố cục phát triển với trình soạn thảo, AI và terminal |
| `tdlm <ai> [<second_ai>]` | Tạo bố cục phát triển cho từng thư mục con |
| `tsl <count> <command>` | Tạo bố cục swarm nhiều ngăn |

## Terminal Ghostty

Terminal Ghostty được cài đặt bằng _Install > Terminal_ qua menu Omarchy.

| Phím tắt                  | Chức năng              |
| ----------------------- | --------------------- |
| `Ctrl + Shift + E` | Chia mới xuống bên dưới |
| `Ctrl + Shift + O` | Chia mới sang bên cạnh |
| `Ctrl + Alt + Arrows` | Di chuyển giữa các phần chia |
| `Super + Ctrl + Shift + Arrows` | Thay đổi kích thước phần chia thêm 10 dòng |
| `Super + Ctrl + Shift + Alt + Arrows` | Thay đổi kích thước phần chia thêm 100 dòng |
| `Ctrl + Shift + T` | Tab mới  |
| `Ctrl + Shift + Arrows` | Di chuyển giữa các tab |
| `Alt + Numbers` | Đến tab cụ thể |
| `Shift + Pg Up/Down` | Cuộn lịch sử |
| `Ctrl + Left mouse` | Mở liên kết trong trình duyệt |

## Trình quản lý tập tin

| Phím tắt              | Chức năng                       |
| ------------------- | ------------------------------ |
| `Ctrl + L`            | Đi đến đường dẫn                     |
| `Space`               | Xem trước tập tin (các phím mũi tên để điều hướng) |
| `Alt + Up`       | Đi lên thư mục cha        |

## Neovim (với lazyvim)

### Điều hướng

| Phím tắt                   | Chức năng                        |
| ------------------------ | ------------------------------- |
| `Space`                    | Hiển thị các tùy chọn lệnh            |
| `Space Space`              | Mở tập tin qua tìm kiếm mờ      |
| `Space E`                  | Bật/tắt thanh bên                  |
| `Space G G`                | Hiển thị các điều khiển git               |
| `Space S G`                | Tìm kiếm nội dung tập tin             |
| `Ctrl + W W`               | Nhảy giữa thanh bên và trình soạn thảo |
| `Ctrl + Left/right arrow`  | Thay đổi kích thước của thanh bên          |
| `Shift + H`                      | Đến tab tập tin bên trái             |
| `Shift + L`                      | Đến tab tập tin bên phải            |
| `Space B D`                | Đóng tab tập tin                  |

### Khi ở thanh bên

| Phím tắt                   | Chức năng                        |
| ------------------------ | ------------------------------- |
| `A`                        | Thêm tập tin mới trong thư mục cha      |
| `Shift + A`                | Thêm thư mục con mới trong thư mục cha    |
| `D`                        | Xóa tập tin/thư mục đang được làm nổi bật     |
| `M`                        | Di chuyển tập tin/thư mục đang được làm nổi bật       |
| `R`                        | Đổi tên tập tin/thư mục đang được làm nổi bật     |
| `?`                        | Hiển thị trợ giúp cho mọi lệnh      |

[Xem tất cả các phím tắt Neovim được cấu hình bởi LazyVim](https://www.lazyvim.org/keymaps).

## Emoji nhanh

Bạn có thể dùng `Super + Ctrl + E` để hiển thị một bộ chọn emoji hoàn chỉnh sẽ đặt lựa chọn vào clipboard hoặc bạn có thể dùng các tùy chọn truy cập nhanh này.

| Phím tắt       | EM | Gợi ý       |
| ------------ | -- | ---------- |
| `Shift + CapsLock M S` | 😄 | smile      |
| `Shift + CapsLock M C` | 😂 | cry        |
| `Shift + CapsLock M L` | 😍 | love       |
| `Shift + CapsLock M V` | ✌️ | victory    |
| `Shift + CapsLock M H` | ❤️ | heart      |
| `Shift + CapsLock M Y` | 👍 | yes        |
| `Shift + CapsLock M N` | 👎 | no         |
| `Shift + CapsLock M F` | 🖕 | fuck       |
| `Shift + CapsLock M W` | 🤞 | wish       |
| `Shift + CapsLock M R` | 🤘 | rock       |
| `Shift + CapsLock M K` | 😘 | kiss       |
| `Shift + CapsLock M E` | 🙄 | eyeroll    |
| `Shift + CapsLock M I` | 😉 | wink       |
| `Shift + CapsLock M P` | 🙏 | pray |
| `Shift + CapsLock M D` | 🤤 | drool      |
| `Shift + CapsLock M M` | 💰 | money      |
| `Shift + CapsLock M X` | 🎉 | xellebrate |
| `Shift + CapsLock M 1` | 💯 | 100%       |
| `Shift + CapsLock M T` | 🥂 | toast      |
| `Shift + CapsLock M O` |👌 | ok |
| `Shift + CapsLock M G` |👋 | greeting |
| `Shift + CapsLock M A` |💪 | arm |
| `Shift + CapsLock M B` |🤯 | blowing |

## Hoàn thành nhanh

| Phím tắt       | Hoàn thành       |
| ------------ |  ---------- |
| `Shift + CapsLock Space Space` | — (mdash)   |
| `Shift + CapsLock Space N` | Tên của bạn (như đã nhập khi cài đặt)  |
| `Shift + CapsLock Space E` | Email của bạn (như đã nhập khi cài đặt)  |

Bạn có thể thêm nhiều hơn của riêng mình bằng cách chỉnh sửa `~/.XCompose`, rồi chạy `omarchy-restart-xcompose` trong terminal để các thay đổi được áp dụng.
