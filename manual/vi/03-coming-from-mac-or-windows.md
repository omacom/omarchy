# Chuyển từ Mac hoặc Windows

Nếu bạn đã dùng macOS hoặc Windows nhiều năm, ngón tay của bạn biết hàng trăm thứ mà bộ não đã quên là mình từng học. Chương này là lớp chuyển đổi: những bản năng đó sẽ đi đâu trong Omarchy. Bản thân các tính năng đã được trình bày kỹ ở nơi khác — đây chỉ là bản đồ.

### Super là trung tâm của mọi thứ

Toàn bộ trí nhớ cơ bắp bạn đã xây dựng quanh Cmd hoặc phím Windows đều chuyển sang một phím duy nhất: Super. Đó là phím Windows trên bàn phím PC, và nó là điểm neo cho gần như mọi phím tắt trong Omarchy.

Phản xạ Spotlight hoặc Raycast hoặc menu Start của bạn trở thành `Super + Space`. Phím này mở menu Omarchy, nơi khởi chạy ứng dụng, thay đổi cài đặt, cài đặt phần mềm, chụp màn hình — gần như mọi thứ. Bắt đầu gõ để lọc. `Super + Alt + Space` hiển thị mọi ứng dụng trên một lưới, giống như Launchpad. Xem [điều hướng](04-navigation.md).

### Không có biểu tượng trên màn hình nền, và dock chỉ hiện ra khi bạn chuyển sang chế độ nổi

Không có biểu tượng để sắp xếp trên màn hình nền, và không có dock trên một không gian làm việc tiling — dock chỉ xuất hiện trên một không gian làm việc nổi (xem [điều hướng](04-navigation.md)). Ứng dụng khởi chạy từ một phím tắt (`Super + Return` cho terminal, `Super + Shift + Return` cho trình duyệt, và `Super + K` cho danh sách mọi thứ đã được gán phím) hoặc từ menu. Thành phần giao diện duy nhất luôn hiện diện là [thanh trên cùng](05-the-top-bar.md), đảm nhiệm những gì thanh menu, khay hệ thống và Notification Center từng làm cho bạn trước đây — và gần như mọi widget trên đó đều làm gì đó khi nhấp chuột trái, phải và giữa.

### Cửa sổ tự sắp xếp vị trí

Thay đổi tư duy lớn nhất: bạn không kéo cửa sổ đi khắp nơi hay gắn chúng vào nửa màn hình. Mở một cửa sổ và nó chiếm toàn bộ màn hình. Mở cửa sổ thứ hai và chúng chia đôi màn hình. Bạn không bao giờ phải moi một cửa sổ ra từ dưới cửa sổ khác, vì các cửa sổ không chồng lên nhau.

Khi bạn thực sự cần một cửa sổ nổi, `Super + T` sẽ chuyển cửa sổ đang hoạt động ra khỏi chế độ tiling (và ngược lại). Nhưng hãy cho tiling một cơ hội thực sự trước — đó là trái tim của toàn bộ hệ thống. [Điều hướng](04-navigation.md) sẽ hướng dẫn bạn.

Các không gian làm việc sẽ cảm thấy quen thuộc: chúng là Spaces của macOS hoặc màn hình ảo của Windows, ngoại trừ việc bạn sẽ thực sự dùng chúng, vì `Super + 1/2/3/4` nhảy thẳng tới một không gian và `Super + Shift + 1/2/3/4` gửi cửa sổ đang hoạt động tới đó. Không có độ trễ hoạt ảnh, chỉ là nhảy tức thì. Điều này có nghĩa là bạn thậm chí có thể không cần nhiều màn hình, nếu trước đây bạn đã quen với điều đó.

### Sao chép và dán cứ thế mà hoạt động

Trên Mac bạn có Cmd + C ở mọi nơi. Trên Windows bạn có Ctrl + C ở mọi nơi — ngoại trừ terminal, nơi nó giết chương trình của bạn. Omarchy cho bạn `Super + C`, `Super + X` và `Super + V`, và chúng hoạt động ở mọi nơi, kể cả terminal. Không cần học một phản xạ riêng cho shell.

Người dùng Windows: lịch sử clipboard Win + V của bạn nằm ở `Super + Ctrl + V`, và nó lưu cả hình ảnh lẫn văn bản. Xem [clipboard hợp nhất & lịch sử](08-unified-clipboard-history.md).

### Bảng chuyển đổi

| Bạn muốn dùng | Trong Omarchy |
| ------------- | ---------- |
| Spotlight / Raycast / menu Start | `Super + Space` — menu Omarchy |
| AirDrop | LocalSend, qua `Super + Ctrl + S` — xem [GUIs](22-guis.md) |
| Cmd + Shift + 4 / Win + Shift + S | `Super + Ctrl + Alt + C` hoặc `Print Screen` — xem [ảnh chụp màn hình & quay màn hình](12-screenshots-recording.md) |
| Notification Center | Lịch sử thông báo trên `Super + Shift + Alt + ,` |
| Time Machine (cho hệ thống) | [Snapshot hệ thống](47-system-snapshots.md) tự động trên mỗi lần cập nhật |
| App Store / tải xuống một trình cài đặt | _Install_ trong menu, hoặc `omarchy pkg add` — xem [các gói khác](29-other-packages.md) |
| System Settings / Control Panel | _Setup_ trong menu, nơi chỉnh sửa các tệp cấu hình thuần văn bản — xem [dotfiles](31-dotfiles.md) |
| Finder / File Explorer | Files, trên `Super + Shift + F` — xem [GUIs](22-guis.md) |
| Safari / Edge | Google Chrome trên `Super + Shift + Return`; chọn trình duyệt khác trong _Setup > Defaults > Browser_ — xem [trình duyệt](23-browsers.md) |
| Preview / Photos | Omaview cho hình ảnh, video và nhạc, Document Viewer cho PDF — xem [GUIs](22-guis.md) |
| TextEdit / Notepad | Plain, trên `Super + Shift + N`; chọn trình soạn thảo khác trong _Setup > Defaults > Editor_ |

### Một số thứ thực sự khác biệt

Rất nhiều cài đặt nằm trong các tệp văn bản bạn chỉnh sửa, không phải các bảng bạn nhấp qua. Nghe có vẻ thô sơ cho đến khi bạn nhận ra điều đó có nghĩa là mọi tinh chỉnh đều có thể được nhìn thấy, sao chép sang máy tiếp theo của bạn và đưa vào quản lý phiên bản. Menu _Setup_ đưa bạn thẳng vào đúng tệp và khởi động lại bất cứ thứ gì cần khởi động lại khi bạn xong việc.

Cập nhật đến qua một lệnh duy nhất — _Update > Omarchy_ — cập nhật chính Omarchy và mọi gói trên hệ thống, đồng thời tạo một snapshot trước. Không có trình cập nhật riêng cho từng ứng dụng làm phiền bạn vào những lúc ngẫu nhiên. Xem [cập nhật](30-updates.md).

Phần mềm đến từ trình quản lý gói, không phải từ các trình cài đặt tải xuống.

Và khi bạn đóng một cửa sổ, ứng dụng thực sự thoát. Không có trạng thái lửng lơ kiểu macOS nơi chương trình vẫn tiếp tục chạy mà không có cửa sổ nào. `Super + W` — hoặc `Super + Q`, nếu đó là trí nhớ ngón tay bạn mang theo — có nghĩa là biến mất.

### Trên phần cứng Mac

Omarchy chạy tốt trên Mac Intel, và trên Mac M1, M2 và M3 với Omarchy for Apple Silicon. Xem [hỗ trợ Mac](44-mac-support.md). Và bàn phím rất thân thiện với bạn: Omarchy không gán lại bất cứ thứ gì, và Linux coi phím Command là Super, vì vậy Super nằm ngay tại vị trí Cmd luôn ở đó. Ngón tay cái của bạn sẽ không nhận ra sự thay đổi.

### Hãy cho nó hai tuần

Các bản năng chuyển đổi nhanh hơn bạn nghĩ. Hãy lướt qua chương [phím tắt](07-hotkeys.md) một lần, và mỗi khi bạn quên một gán phím, hãy nhấn `Super + K` — nó sẽ hiển thị tất cả cho bạn. Đó là phím tắt duy nhất bạn thực sự phải ghi nhớ.
