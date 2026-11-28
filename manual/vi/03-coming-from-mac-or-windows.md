# Chuyển từ Mac hoặc Windows sang

Nếu bạn đã dành nhiều năm trên macOS hoặc Windows, ngón tay của bạn biết hàng trăm thứ mà bộ não của bạn đã quên mất là mình từng học. Chương này là lớp dịch: những bản năng đó đi đâu trong Omarchy. Bản thân các tính năng được trình bày chuyên sâu ở những chỗ khác — đây chỉ là bản đồ.

### Super là trung tâm của mọi thứ

Tất cả ký ức cơ bắp bạn đã xây dựng quanh Cmd hoặc phím Windows đều chuyển sang một phím duy nhất: Super. Đó là phím Windows trên bàn phím PC, và nó là điểm neo cho gần như mọi phím tắt trong Omarchy.

Phản xạ Spotlight hoặc Raycast hoặc menu Start của bạn trở thành `Super + Space`. Thao tác đó mở menu Omarchy, nơi khởi chạy ứng dụng, thay đổi cài đặt, cài đặt phần mềm, chụp màn hình — gần như mọi thứ. Bắt đầu gõ để lọc. `Super + Alt + Space` hiển thị mọi ứng dụng trên một lưới, giống như Launchpad. Xem [điều hướng](04-navigation.md).

### Không có biểu tượng trên desktop, và dock luôn tránh đường

Không có biểu tượng nào để sắp xếp trên desktop, và dock sẽ ẩn đi khi một workspace có cửa sổ, cho đến khi bạn đẩy con trỏ tới cạnh màn hình của nó, cạnh bên phải trừ khi bạn di chuyển nó (xem [điều hướng](04-navigation.md)). Ứng dụng khởi chạy từ một phím tắt (`Super + Return` cho terminal, `Super + Shift + Return` cho trình duyệt, và `Super + K` cho danh sách mọi thứ đã được gán phím) hoặc từ menu. Mảnh giao diện duy nhất luôn hiện diện là [thanh trên cùng](05-the-top-bar.md), thứ đảm nhiệm những gì thanh menu, khay hệ thống và Notification Center từng làm cho bạn trước đây — và gần như mọi widget trên đó đều làm gì đó khi nhấp chuột trái, phải và giữa.

### Cửa sổ tự sắp xếp vị trí

Thay đổi tư duy lớn nhất: bạn không kéo cửa sổ đi khắp nơi hay gắn chúng vào nửa màn hình. Mở một cửa sổ và nó chiếm toàn bộ màn hình. Mở cửa sổ thứ hai và chúng chia màn hình ra. Bạn không bao giờ phải mò một cửa sổ ra từ dưới một cửa sổ khác, vì các cửa sổ không chồng lên nhau.

Khi bạn thực sự cần một cửa sổ nổi, `Super + T` sẽ chuyển cửa sổ đang hoạt động ra khỏi chế độ xếp lớp (và quay lại). Nhưng hãy cho chế độ xếp lớp một cơ hội thực sự trước — nó là trái tim của toàn bộ hệ thống. [Điều hướng](04-navigation.md) sẽ hướng dẫn bạn qua nó.

Workspace sẽ có cảm giác quen thuộc: chúng là Spaces của macOS hoặc desktop ảo của Windows, ngoại trừ việc bạn sẽ thực sự dùng chúng, vì `Super + 1/2/3/4` nhảy thẳng tới một workspace và `Super + Shift + 1/2/3/4` gửi cửa sổ đang hoạt động tới đó. Không có độ trễ hoạt ảnh, chỉ là những cú nhảy tức thì. Điều này có nghĩa là bạn thậm chí có thể không cần nhiều màn hình, nếu trước đây bạn đã quen với điều đó.

### Sao chép và dán cứ thế mà hoạt động

Trên Mac, bạn có Cmd + C ở khắp mọi nơi. Trên Windows, bạn có Ctrl + C ở khắp mọi nơi — ngoại trừ terminal, nơi nó kết liễu chương trình của bạn. Omarchy cho bạn `Super + C`, `Super + X` và `Super + V`, và chúng hoạt động ở khắp mọi nơi, kể cả terminal. Không cần học một phản xạ riêng cho shell.

Người dùng Windows: lịch sử clipboard Win + V của bạn nằm ở `Super + Ctrl + V`, và nó chứa cả hình ảnh lẫn văn bản. Xem [clipboard hợp nhất & lịch sử](08-unified-clipboard-history.md).

### Bảng đối chiếu

| Bạn tìm đến | Trong Omarchy |
| ------------- | ---------- |
| Spotlight / Raycast / menu Start | `Super + Space` — menu Omarchy |
| AirDrop | LocalSend, qua `Super + Ctrl + S` — xem [GUI](22-guis.md) |
| Cmd + Shift + 4 / Win + Shift + S | `Super + Ctrl + Alt + C` hoặc `Print Screen` — xem [ảnh chụp màn hình & quay màn hình](12-screenshots-recording.md) |
| Notification Center | Lịch sử thông báo trên `Super + Shift + Alt + ,` |
| Time Machine (cho hệ thống) | [Ảnh chụp hệ thống](47-system-snapshots.md) tự động trong mỗi lần cập nhật |
| App Store / tải xuống một trình cài đặt | _Install_ trong menu, hoặc `omarchy pkg add` — xem [các gói khác](29-other-packages.md) |
| System Settings / Control Panel | _Setup_ trong menu, nơi chỉnh sửa các file cấu hình thuần văn bản — xem [dotfiles](31-dotfiles.md) |
| Finder / File Explorer | Files, trên `Super + Shift + F` — xem [GUI](22-guis.md) |
| Safari / Edge | Google Chrome trên `Super + Shift + Return`; chọn một trình duyệt khác trong _Setup > Defaults > Browser_ — xem [trình duyệt](23-browsers.md) |
| Preview / Photos | Omaview cho hình ảnh, video và nhạc, Document Viewer cho PDF — xem [GUI](22-guis.md) |
| TextEdit / Notepad | Plain, trên `Super + Shift + N`; chọn một trình soạn thảo khác trong _Setup > Defaults > Editor_ |

### Một số thứ thực sự khác biệt

Rất nhiều cài đặt nằm trong các file văn bản mà bạn chỉnh sửa, chứ không phải các bảng điều khiển mà bạn nhấp qua. Nghe có vẻ thô sơ cho đến khi bạn nhận ra điều đó có nghĩa là mọi tinh chỉnh đều có thể được nhìn thấy, sao chép sang máy tiếp theo của bạn và đưa vào hệ thống quản lý phiên bản. Menu _Setup_ đưa bạn thẳng tới đúng file và khởi động lại bất cứ thứ gì cần khởi động lại khi bạn xong việc.

Cập nhật đến qua một lệnh duy nhất — _Update > Omarchy_ — lệnh này cập nhật chính Omarchy và mọi gói trên hệ thống, đồng thời tạo một ảnh chụp trước. Không có trình cập nhật riêng của từng ứng dụng làm phiền bạn vào những lúc ngẫu nhiên. Xem [cập nhật](30-updates.md).

Phần mềm đến từ một trình quản lý gói, chứ không phải từ các trình cài đặt tải xuống.

Và khi bạn đóng một cửa sổ, ứng dụng thực sự thoát. Không có trạng thái lấp lửng kiểu macOS, nơi chương trình vẫn tiếp tục chạy mà không có cửa sổ nào. `Super + W` — hoặc `Super + Q`, nếu đó là ký ức ngón tay bạn mang theo — có nghĩa là biến mất.

### Trên phần cứng Mac

Omarchy chạy tốt trên các máy Mac Intel, và trên các máy Mac M1, M2 và M3 với Omarchy for Apple Silicon. Xem [hỗ trợ Mac](44-mac-support.md). Và bàn phím rất tử tế với bạn: Omarchy không gán lại bất cứ thứ gì, và Linux coi phím Command là Super, vì vậy Super nằm ngay tại vị trí Cmd luôn ở. Ngón tay cái của bạn sẽ không nhận ra sự chuyển đổi.

### Hãy cho nó hai tuần

Các bản năng chuyển sang nhanh hơn bạn nghĩ. Hãy đọc lướt chương [phím tắt](07-hotkeys.md) một lần, và mỗi khi bạn quên mất một phím gán nào đó, hãy nhấn `Super + K` — nó cho bạn thấy tất cả. Đó là phím tắt duy nhất bạn thực sự phải ghi nhớ.
