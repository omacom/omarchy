# Đến từ Mac hay Windows

Nếu bạn đã dành nhiều năm trên macOS hay Windows, ngón tay của bạn biết hàng trăm thứ mà não bạn đã quên là mình từng học. Chương này là lớp dịch: những bản năng đó đi về đâu trong Omarchy. Bản thân các tính năng được trình bày sâu ở nơi khác — đây chỉ là tấm bản đồ.

### Super là trung tâm của mọi thứ

Tất cả trí nhớ cơ bắp bạn đã xây dựng quanh Cmd hay phím Windows đều chuyển sang một phím: Super. Đó là phím Windows trên bàn phím PC, và nó là điểm neo cho gần như mọi phím tắt trong Omarchy.

Phản xạ Spotlight hay Raycast hay menu Start của bạn trở thành `Super + Space`. Thao tác đó mở menu Omarchy, nơi khởi chạy ứng dụng, thay đổi cài đặt, cài đặt phần mềm, chụp màn hình — gần như mọi thứ. Cứ bắt đầu gõ để lọc. `Super + Alt + Space` hiển thị mọi ứng dụng trên một lưới duy nhất, như cách Launchpad làm. Xem [điều hướng](04-navigation.md).

### Không có biểu tượng trên màn hình nền, và dock chỉ xuất hiện khi bạn ở chế độ nổi

Không có biểu tượng nào để sắp xếp trên màn hình nền, và không có dock trên không gian làm việc xếp ô — dock chỉ xuất hiện trên không gian làm việc nổi (xem [điều hướng](04-navigation.md)). Ứng dụng khởi động từ một phím tắt (`Super + Return` cho terminal, `Super + Shift + Return` cho trình duyệt, và `Super + K` cho danh sách mọi thứ đã được gán) hoặc từ menu. Mảnh giao diện duy nhất luôn hiện diện là [thanh trên cùng](05-the-top-bar.md), thứ đảm nhiệm những gì thanh menu, khay hệ thống và Notification Center từng làm cho bạn trước đây — và gần như mọi widget trên đó đều làm gì đó khi nhấp trái, phải và giữa.

### Cửa sổ tự sắp xếp vị trí

Thay đổi tư duy lớn nhất: bạn không kéo cửa sổ đi khắp nơi hay gắn chúng vào nửa màn hình. Mở một cửa sổ và nó chiếm toàn bộ màn hình. Mở cửa sổ thứ hai và chúng chia màn hình ra. Bạn không bao giờ phải lôi một cửa sổ ra từ dưới một cửa sổ khác, vì cửa sổ không chồng lên nhau.

Khi bạn thực sự cần một cửa sổ nổi, `Super + T` chuyển cửa sổ đang hoạt động ra khỏi chế độ xếp ô (và ngược lại). Nhưng hãy cho chế độ xếp ô một cơ hội thực sự trước — đó là trái tim của toàn bộ hệ thống. [Điều hướng](04-navigation.md) sẽ dẫn bạn đi qua nó.

Không gian làm việc sẽ cảm thấy quen thuộc: chúng là macOS Spaces hay màn hình ảo của Windows, ngoại trừ việc bạn sẽ thực sự dùng chúng, vì `Super + 1/2/3/4` nhảy thẳng đến một cái và `Super + Shift + 1/2/3/4` gửi cửa sổ đang hoạt động đến đó. Không có độ trễ hoạt ảnh, chỉ là những cú nhảy tức thì. Điều này có nghĩa là bạn thậm chí có thể không cần nhiều màn hình nữa, nếu trước đây bạn đã quen với điều đó.

### Sao chép và dán cứ thế mà hoạt động

Trên Mac bạn có Cmd + C ở khắp nơi. Trên Windows bạn có Ctrl + C ở khắp nơi — ngoại trừ terminal, nơi nó giết chương trình của bạn. Omarchy cho bạn `Super + C`, `Super + X`, và `Super + V`, và chúng hoạt động ở khắp nơi, kể cả terminal. Không có phản xạ riêng nào phải học cho shell.

Những người đến từ Windows: lịch sử bảng tạm Win + V của bạn nằm trên `Super + Ctrl + V`, và nó chứa cả hình ảnh lẫn văn bản. Xem [bảng tạm hợp nhất & lịch sử](08-unified-clipboard-history.md).

### Bảng dịch

| Bạn tìm đến | Trong Omarchy |
| ------------- | ---------- |
| Spotlight / Raycast / menu Start | `Super + Space` — menu Omarchy |
| AirDrop | LocalSend, qua `Super + Ctrl + S` — xem [GUIs](22-guis.md) |
| Cmd + Shift + 4 / Win + Shift + S | `Super + Ctrl + Alt + C` hoặc `Print Screen` — xem [ảnh chụp màn hình & quay màn hình](12-screenshots-recording.md) |
| Notification Center | Lịch sử thông báo trên `Super + Shift + Alt + ,` |
| Time Machine (cho hệ thống) | [Bản chụp hệ thống](47-system-snapshots.md) tự động mỗi lần cập nhật |
| App Store / tải xuống một trình cài đặt | _Install_ trong menu, hoặc `omarchy pkg add` — xem [các gói khác](29-other-packages.md) |
| System Settings / Control Panel | _Setup_ trong menu, nơi chỉnh sửa các tệp cấu hình thuần văn bản — xem [dotfiles](31-dotfiles.md) |
| Finder / File Explorer | Files, trên `Super + Shift + F` — xem [GUIs](22-guis.md) |
| Safari / Edge | Google Chrome trên `Super + Shift + Return`; chọn cái khác trong _Setup > Defaults > Browser_ — xem [trình duyệt](23-browsers.md) |
| Preview / Photos | Omaview cho hình ảnh, video và nhạc, Document Viewer cho PDF — xem [GUIs](22-guis.md) |
| TextEdit / Notepad | Plain, trên `Super + Shift + N`; chọn cái khác trong _Setup > Defaults > Editor_ |

### Một số thứ thực sự khác biệt

Rất nhiều cài đặt nằm trong các tệp văn bản bạn chỉnh sửa, chứ không phải các bảng điều khiển bạn nhấp chuột qua. Nghe có vẻ nguyên thủy cho đến khi bạn nhận ra điều đó có nghĩa là mọi tinh chỉnh đều có thể được nhìn thấy, sao chép sang máy tiếp theo của bạn, và đưa vào quản lý phiên bản. Menu _Setup_ đưa bạn thẳng vào đúng tệp và khởi động lại bất cứ thứ gì cần khởi động lại khi bạn xong việc.

Cập nhật đến qua một lệnh duy nhất — _Update > Omarchy_ — lệnh này cập nhật chính Omarchy và mọi gói trên hệ thống, đồng thời tạo một bản chụp trước. Không có trình cập nhật riêng của từng ứng dụng nào làm phiền bạn vào lúc ngẫu nhiên. Xem [cập nhật](30-updates.md).

Phần mềm đến từ một trình quản lý gói, chứ không phải từ các trình cài đặt tải xuống.

Và khi bạn đóng một cửa sổ, ứng dụng thực sự thoát. Không có trạng thái lơ lửng kiểu macOS nơi chương trình vẫn tiếp tục chạy mà không có cửa sổ nào. `Super + W` — hoặc `Super + Q`, nếu đó là trí nhớ ngón tay bạn mang theo — có nghĩa là biến mất.

### Trên phần cứng Mac

Omarchy chạy tốt trên các máy Mac Intel — xem [hỗ trợ Mac](44-mac-support.md). Và bàn phím tử tế với bạn: Omarchy không gán lại bất cứ thứ gì, và Linux coi phím Command là Super, nên Super nằm ngay tại vị trí Cmd luôn ở. Ngón cái của bạn sẽ không nhận ra sự di chuyển này.

### Hãy cho nó hai tuần

Các bản năng chuyển sang nhanh hơn bạn nghĩ. Đọc lướt chương [phím tắt](07-hotkeys.md) một lần, và bất cứ khi nào bạn quên mất một tổ hợp phím, hãy nhấn `Super + K` — nó cho bạn thấy tất cả chúng. Đó là phím tắt duy nhất bạn thực sự phải ghi nhớ.
