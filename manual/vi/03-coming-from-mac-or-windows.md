# Chuyển từ Mac hoặc Windows

Nếu bạn đã dành nhiều năm trên macOS hoặc Windows, các ngón tay của bạn biết hàng trăm thứ mà bộ não của bạn đã quên là mình từng học. Chương này là lớp dịch thuật: những bản năng đó sẽ đi về đâu trong Omarchy. Bản thân các tính năng được trình bày chi tiết ở nơi khác — đây chỉ là tấm bản đồ.

### Super là trung tâm của mọi thứ

Toàn bộ trí nhớ cơ bắp mà bạn đã xây dựng quanh Cmd hoặc phím Windows đều chuyển sang một phím: Super. Đó là phím Windows trên bàn phím PC, và nó là điểm neo cho gần như mọi phím tắt trong Omarchy.

Phản xạ Spotlight hoặc Raycast hoặc menu Start của bạn trở thành `Super + Space`. Thao tác đó mở menu Omarchy, nơi khởi chạy ứng dụng, thay đổi cài đặt, cài đặt phần mềm, chụp màn hình — gần như mọi thứ. Cứ bắt đầu gõ để lọc. `Super + Alt + Space` hiển thị mọi ứng dụng trên một lưới, giống như cách Launchpad làm. Xem [điều hướng](04-navigation.md).

### Không có dock và không có biểu tượng trên desktop

Không có gì để nhấp vào nhằm khởi chạy mọi thứ, không có biểu tượng nào để sắp xếp trên desktop. Ứng dụng khởi động từ một phím tắt (`Super + Return` cho terminal, `Super + Shift + Return` cho trình duyệt, và `Super + K` cho danh sách mọi thứ đã được ánh xạ) hoặc từ menu. Mảnh giao diện người dùng duy nhất luôn hiện diện là [thanh trên cùng](05-the-top-bar.md), thứ đảm nhiệm những gì thanh menu, khay hệ thống và Notification Center từng làm cho bạn trước đây — và gần như mọi widget trên đó đều làm gì đó khi nhấp chuột trái, chuột phải và chuột giữa.

### Cửa sổ tự sắp xếp vị trí

Thay đổi tư duy lớn nhất: bạn không kéo cửa sổ đi khắp nơi hay gắn chúng vào các nửa màn hình. Mở một cửa sổ và nó chiếm toàn bộ màn hình. Mở cửa sổ thứ hai và chúng chia đôi màn hình. Bạn không bao giờ phải moi một cửa sổ ra từ bên dưới một cửa sổ khác, vì các cửa sổ không chồng lên nhau.

Khi bạn thực sự cần một cửa sổ nổi, `Super + T` sẽ chuyển cửa sổ đang hoạt động ra khỏi chế độ xếp lớp (và quay lại). Nhưng hãy cho chế độ xếp lớp một cơ hội thực sự trước — đó là trái tim của toàn bộ hệ thống này. [Điều hướng](04-navigation.md) sẽ hướng dẫn bạn qua nó.

Workspace sẽ có cảm giác quen thuộc: chúng là macOS Spaces hoặc desktop ảo của Windows, ngoại trừ việc bạn sẽ thực sự dùng chúng, vì `Super + 1/2/3/4` nhảy thẳng tới một workspace và `Super + Shift + 1/2/3/4` gửi cửa sổ đang hoạt động tới đó. Không có độ trễ hoạt ảnh, chỉ là những cú nhảy tức thì. Điều này có nghĩa là bạn thậm chí có thể không cần nhiều màn hình, nếu trước đây bạn đã quen với điều đó.

### Sao chép và dán cứ thế hoạt động

Trên Mac, bạn có Cmd + C ở khắp mọi nơi. Trên Windows, bạn có Ctrl + C ở khắp mọi nơi — ngoại trừ terminal, nơi nó giết chương trình của bạn. Omarchy cho bạn `Super + C`, `Super + X` và `Super + V`, và chúng hoạt động ở khắp mọi nơi, kể cả terminal. Không cần học một phản xạ riêng cho shell.

Những người dùng Windows: lịch sử clipboard Win + V của bạn nằm ở `Super + Ctrl + V`, và nó chứa cả hình ảnh lẫn văn bản. Xem [clipboard hợp nhất & lịch sử](08-unified-clipboard-history.md).

### Bảng dịch thuật

| Bạn tìm đến | Trong Omarchy |
| ------------- | ---------- |
| Spotlight / Raycast / Start menu | `Super + Space` — menu Omarchy |
| AirDrop | LocalSend, qua `Super + Ctrl + S` — xem [GUI](22-guis.md) |
| Cmd + Shift + 4 / Win + Shift + S | `Super + Ctrl + Alt + C` hoặc `Print Screen` — xem [ảnh chụp màn hình & quay màn hình](12-screenshots-recording.md) |
| Notification Center | Lịch sử thông báo trên `Super + Shift + Alt + ,` |
| Time Machine (cho hệ thống) | [Ảnh chụp nhanh hệ thống](47-system-snapshots.md) tự động trong mỗi lần cập nhật |
| App Store / tải xuống trình cài đặt | _Install_ trong menu, hoặc `omarchy pkg add` — xem [các gói khác](29-other-packages.md) |
| System Settings / Control Panel | _Setup_ trong menu, nơi chỉnh sửa các file cấu hình văn bản thuần — xem [dotfiles](31-dotfiles.md) |

### Một số thứ thực sự khác biệt

Rất nhiều cài đặt nằm trong các file văn bản mà bạn chỉnh sửa, chứ không phải các bảng mà bạn nhấp chuột qua. Điều đó nghe có vẻ thô sơ cho đến khi bạn nhận ra nó có nghĩa là mọi tinh chỉnh đều có thể được nhìn thấy, sao chép sang máy tiếp theo của bạn và đưa vào kiểm soát phiên bản. Menu _Setup_ đưa bạn thẳng vào đúng file và khởi động lại bất cứ thứ gì cần khởi động lại khi bạn hoàn tất.

Các bản cập nhật đến qua một lệnh — _Update > Omarchy_ — lệnh này cập nhật chính Omarchy và mọi gói trên hệ thống, đồng thời tạo một ảnh chụp nhanh trước. Không có trình cập nhật riêng cho từng ứng dụng nào quấy rầy bạn vào lúc ngẫu nhiên. Xem [cập nhật](30-updates.md).

Phần mềm đến từ một trình quản lý gói, chứ không phải từ các trình cài đặt đã tải xuống.

Và khi bạn đóng một cửa sổ, ứng dụng thực sự thoát. Không có trạng thái lấp lửng kiểu macOS nơi chương trình tiếp tục chạy mà không có cửa sổ nào. `Super + W` — hoặc `Super + Q`, nếu đó là trí nhớ ngón tay bạn mang theo — có nghĩa là biến mất.

### Trên phần cứng Mac

Omarchy chạy tốt trên các máy Mac Intel — xem [hỗ trợ Mac](44-mac-support.md). Và bàn phím rất tử tế với bạn: Omarchy không ánh xạ lại bất cứ thứ gì, và Linux coi phím Command là Super, vì vậy Super nằm ngay tại vị trí Cmd luôn ở đó. Ngón tay cái của bạn sẽ không nhận ra sự di chuyển này.

### Hãy cho nó hai tuần

Các bản năng chuyển giao nhanh hơn bạn nghĩ. Hãy đọc lướt chương [phím tắt](07-hotkeys.md) một lần, và bất cứ khi nào bạn quên mất một tổ hợp phím, hãy nhấn `Super + K` — nó hiển thị cho bạn tất cả. Đó là phím tắt duy nhất bạn thực sự phải ghi nhớ.
