# Chuyển từ Mac hoặc Windows

Nếu bạn đã dành nhiều năm trên macOS hoặc Windows, ngón tay bạn biết cả trăm thứ mà não bạn đã quên là mình từng học. Chương này là lớp dịch thuật: những bản năng đó đi về đâu trong Omarchy. Bản thân các tính năng được trình bày chuyên sâu ở nơi khác — đây chỉ là bản đồ.

### Super là trung tâm của mọi thứ

Mọi trí nhớ cơ bắp bạn đã xây dựng quanh Cmd hoặc phím Windows đều chuyển sang một phím duy nhất: Super. Đó là phím Windows trên bàn phím PC, và nó là điểm neo cho gần như mọi phím tắt trong Omarchy.

Phản xạ Spotlight hoặc Raycast hoặc menu Start của bạn trở thành `Super + Space`. Thao tác đó mở menu Omarchy, nơi khởi chạy ứng dụng, thay đổi cài đặt, cài đặt phần mềm, chụp màn hình — gần như mọi thứ. Bắt đầu gõ để lọc. `Super + Alt + Space` hiển thị mọi ứng dụng trên một lưới duy nhất, giống như cách Launchpad làm. Xem [điều hướng](04-navigation.md).

### Không có biểu tượng trên desktop, và dock luôn tránh đường

Không có biểu tượng nào để sắp xếp trên desktop, và dock sẽ ẩn đi khi một workspace có cửa sổ, cho đến khi bạn đẩy con trỏ tới cạnh màn hình của nó, cạnh dưới trừ khi bạn di chuyển nó (xem [điều hướng](04-navigation.md)). Các ứng dụng khởi chạy từ một phím tắt (`Super + Return` cho terminal, `Super + Shift + Return` cho trình duyệt, và `Super + K` cho danh sách mọi thứ đã được gán phím) hoặc từ menu. Phần giao diện duy nhất luôn hiện diện là [thanh trên cùng](05-the-top-bar.md), đảm nhiệm những gì thanh menu, khay hệ thống và Notification Center từng làm cho bạn trước đây — và gần như mọi widget trên đó đều làm gì đó khi nhấp chuột trái, chuột phải và chuột giữa.

### Cửa sổ tự sắp xếp vị trí

Thay đổi tư duy lớn nhất: bạn không kéo cửa sổ đi khắp nơi hay gắn chúng vào nửa màn hình. Mở một cửa sổ và nó chiếm toàn bộ màn hình. Mở cửa sổ thứ hai và chúng chia đôi màn hình. Bạn không bao giờ phải mò tìm một cửa sổ bị che dưới cửa sổ khác, vì các cửa sổ không chồng lên nhau.

Khi bạn thực sự cần một cửa sổ nổi, `Super + T` sẽ chuyển cửa sổ đang hoạt động ra khỏi cơ chế xếp lát (và quay lại). Nhưng trước tiên hãy cho cơ chế xếp lát một cơ hội thực sự — đó là trái tim của toàn bộ hệ thống. [Điều hướng](04-navigation.md) sẽ hướng dẫn bạn qua nó.

Các workspace sẽ cảm thấy quen thuộc: chúng là Spaces của macOS hoặc desktop ảo của Windows, ngoại trừ việc bạn sẽ thực sự dùng chúng, vì `Super + 1/2/3/4` nhảy thẳng đến một workspace và `Super + Shift + 1/2/3/4` gửi cửa sổ đang hoạt động đến đó. Không có độ trễ hoạt ảnh, chỉ có những bước nhảy tức thì. Điều này có nghĩa là bạn thậm chí có thể không cần nhiều màn hình, nếu trước đây bạn đã quen với điều đó.

### Sao chép và dán cứ thế mà hoạt động

Trên Mac bạn có Cmd + C ở khắp mọi nơi. Trên Windows bạn có Ctrl + C ở khắp mọi nơi — ngoại trừ terminal, nơi nó giết chương trình của bạn. Omarchy cho bạn `Super + C`, `Super + X`, và `Super + V`, và chúng hoạt động ở khắp mọi nơi, kể cả terminal. Không cần học một phản xạ riêng cho shell.

Những người dùng Windows: lịch sử clipboard Win + V của bạn nằm ở `Super + Ctrl + V`, và nó lưu cả hình ảnh lẫn văn bản. Xem [clipboard & lịch sử hợp nhất](08-unified-clipboard-history.md).

### Bảng dịch thuật

| Bạn tìm đến | Trong Omarchy |
| ------------- | ---------- |
| Spotlight / Raycast / menu Start | `Super + Space` — menu Omarchy |
| AirDrop | LocalSend, qua `Super + Ctrl + S` — xem [GUIs](22-guis.md) |
| Cmd + Shift + 4 / Win + Shift + S | `Super + Ctrl + Alt + C` hoặc `Print Screen` — xem [ảnh chụp màn hình & ghi hình](12-screenshots-recording.md) |
| Notification Center | Lịch sử thông báo bằng `Super + Shift + Alt + ,` |
| Time Machine (cho hệ thống) | [Snapshot hệ thống](47-system-snapshots.md) tự động mỗi khi cập nhật |
| App Store / tải một trình cài đặt | _Install_ trong menu, hoặc `omarchy pkg add` — xem [các gói khác](29-other-packages.md) |
| System Settings / Control Panel | _Setup_ trong menu, nơi chỉnh sửa các file cấu hình văn bản thuần — xem [dotfiles](31-dotfiles.md) |
| Finder / File Explorer | Files, bằng `Super + Shift + F` — xem [GUIs](22-guis.md) |
| Safari / Edge | Google Chrome bằng `Super + Shift + Return`; chọn trình duyệt khác trong _Setup > Defaults > Browser_ — xem [trình duyệt](23-browsers.md) |
| Preview / Photos | Omaview cho hình ảnh, video và nhạc, Document Viewer cho PDF — xem [GUIs](22-guis.md) |
| TextEdit / Notepad | Plain, bằng `Super + Shift + N`; chọn trình soạn thảo khác trong _Setup > Defaults > Editor_ |

### Một số thứ thực sự khác biệt

Nhiều cài đặt nằm trong các file văn bản mà bạn chỉnh sửa, không phải trong các bảng điều khiển để bạn nhấp qua. Nghe có vẻ thô sơ cho đến khi bạn nhận ra điều đó có nghĩa là mọi tinh chỉnh đều có thể nhìn thấy, sao chép sang máy tiếp theo của bạn và đưa vào quản lý phiên bản. Menu _Setup_ đưa bạn thẳng đến đúng file và khởi động lại bất cứ thứ gì cần khởi động lại khi bạn xong việc.

Các bản cập nhật đến qua một lệnh duy nhất — _Update > Omarchy_ — lệnh này cập nhật chính Omarchy và mọi gói trên hệ thống, đồng thời tạo một snapshot trước. Không còn trình cập nhật riêng của từng ứng dụng làm phiền bạn vào những lúc bất chợt. Xem [cập nhật](30-updates.md).

Phần mềm đến từ một trình quản lý gói, không phải từ các trình cài đặt được tải xuống.

Và khi bạn đóng một cửa sổ, ứng dụng thực sự thoát. Không có tình trạng lấp lửng kiểu macOS, nơi chương trình vẫn tiếp tục chạy mà không có cửa sổ nào. `Super + W` — hoặc `Super + Q`, nếu đó là trí nhớ ngón tay bạn mang theo — có nghĩa là biến mất.

### Trên phần cứng Mac

Omarchy chạy tốt trên các máy Mac dùng Intel, và trên các máy Mac M1, M2 và M3 với Omarchy for Apple Silicon. Xem [hỗ trợ Mac](44-mac-support.md). Và bàn phím rất thân thiện với bạn: Omarchy không ánh xạ lại bất cứ thứ gì, và Linux coi phím Command là Super, vì vậy Super nằm ngay tại vị trí Cmd luôn ở đó. Ngón tay cái của bạn sẽ không nhận ra sự thay đổi.

### Hãy dành cho nó hai tuần

Các bản năng chuyển giao nhanh hơn bạn nghĩ. Hãy đọc lướt chương [phím tắt](07-hotkeys.md) một lần, và bất cứ khi nào bạn quên một phím gán, hãy nhấn `Super + K` — nó sẽ cho bạn thấy tất cả. Đó là phím tắt duy nhất bạn thực sự phải ghi nhớ.
