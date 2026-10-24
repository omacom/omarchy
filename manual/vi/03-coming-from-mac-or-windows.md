# Chuyển từ Mac hoặc Windows sang

Nếu bạn đã dành nhiều năm trên macOS hoặc Windows, các ngón tay của bạn biết cả trăm điều mà bộ não của bạn đã quên là nó từng học. Chương này là lớp dịch thuật: những bản năng đó đi đâu trong Omarchy. Bản thân các tính năng được trình bày sâu ở những nơi khác — đây chỉ là bản đồ.

### Super là trung tâm của mọi thứ

Mọi trí nhớ cơ bắp mà bạn đã xây dựng quanh phím Cmd hoặc phím Windows đều chuyển sang một phím duy nhất: Super. Đó là phím Windows trên bàn phím PC, và nó là điểm neo cho gần như mọi phím tắt trong Omarchy.

Phản xạ Spotlight hoặc Raycast hoặc menu Start của bạn trở thành `Super + Space`. Thao tác đó mở menu Omarchy, nơi khởi chạy ứng dụng, thay đổi cài đặt, cài đặt phần mềm, chụp màn hình — hầu như mọi thứ. Bắt đầu gõ để lọc. `Super + Alt + Space` hiển thị mọi ứng dụng trên một lưới duy nhất, giống như Launchpad. Xem [điều hướng](04-navigation.md).

### Không có dock và không có biểu tượng trên desktop

Không có gì để nhấp vào nhằm khởi chạy mọi thứ, không có biểu tượng nào để sắp xếp trên desktop. Các ứng dụng khởi động từ một phím tắt (`Super + Return` cho terminal, `Super + Shift + Return` cho trình duyệt, và `Super + K` cho danh sách mọi thứ đã được gán) hoặc từ menu. Phần giao diện người dùng cố định duy nhất là [thanh trên cùng](05-the-top-bar.md), nơi đảm nhiệm những gì thanh menu, khay hệ thống và Trung tâm thông báo từng làm cho bạn trước đây — và gần như mọi tiện ích trên đó đều làm điều gì đó khi nhấp chuột trái, phải và giữa.

### Cửa sổ tự đặt vị trí cho mình

Sự thay đổi tư duy lớn nhất: bạn không kéo cửa sổ đi khắp nơi hay gắn chúng vào nửa màn hình. Mở một cửa sổ và nó chiếm toàn bộ màn hình. Mở cửa sổ thứ hai và chúng chia đôi màn hình. Bạn không bao giờ phải lôi một cửa sổ ra khỏi phía dưới một cửa sổ khác, vì các cửa sổ không chồng lên nhau.

Khi bạn thực sự cần một cửa sổ nổi, `Super + T` chuyển cửa sổ đang hoạt động ra khỏi chế độ xếp ô (và quay lại). Nhưng trước tiên hãy cho chế độ xếp ô một cơ hội thực sự — đó là trái tim của toàn bộ hệ thống. [Điều hướng](04-navigation.md) sẽ hướng dẫn bạn qua nó.

Các không gian làm việc sẽ cảm thấy quen thuộc: chúng là Spaces của macOS hoặc desktop ảo của Windows, ngoại trừ việc bạn sẽ thực sự sử dụng chúng, vì `Super + 1/2/3/4` nhảy thẳng tới một không gian và `Super + Shift + 1/2/3/4` gửi cửa sổ đang hoạt động tới đó. Không có độ trễ hiệu ứng, chỉ là những cú nhảy tức thì. Điều này có nghĩa là bạn thậm chí có thể không cần nhiều màn hình, nếu trước đây bạn đã quen với điều đó.

### Sao chép và dán cứ thế mà hoạt động

Trên Mac bạn có Cmd + C ở khắp mọi nơi. Trên Windows bạn có Ctrl + C ở khắp mọi nơi — ngoại trừ terminal, nơi nó giết chương trình của bạn. Omarchy cho bạn `Super + C`, `Super + X` và `Super + V`, và chúng hoạt động ở khắp mọi nơi, kể cả terminal. Không cần học một phản xạ riêng cho shell.

Những người dùng Windows: lịch sử bảng nhớ tạm Win + V của bạn nằm trên `Super + Ctrl + V`, và nó chứa cả hình ảnh lẫn văn bản. Xem [bảng nhớ tạm & lịch sử thống nhất](08-unified-clipboard-history.md).

### Bảng dịch thuật

| Bạn với tay tới | Trong Omarchy |
| ------------- | ---------- |
| Spotlight / Raycast / menu Start | `Super + Space` — menu Omarchy |
| AirDrop | LocalSend, qua `Super + Ctrl + S` — xem [GUI](22-guis.md) |
| Cmd + Shift + 4 / Win + Shift + S | `Print Screen` — xem [ảnh chụp màn hình & ghi hình](12-screenshots-recording.md) |
| Trung tâm thông báo | Lịch sử thông báo trên `Super + Shift + Alt + ,` |
| Time Machine (cho hệ thống) | [Ảnh chụp hệ thống](47-system-snapshots.md) tự động trong mỗi lần cập nhật |
| App Store / tải xuống trình cài đặt | _Cài đặt_ trong menu, hoặc `omarchy pkg add` — xem [các gói khác](29-other-packages.md) |
| Cài đặt hệ thống / Bảng điều khiển | _Thiết lập_ trong menu, nơi chỉnh sửa các tệp cấu hình thuần túy — xem [dotfiles](31-dotfiles.md) |

### Một số điều thực sự khác biệt

Rất nhiều cài đặt nằm trong các tệp văn bản mà bạn chỉnh sửa, chứ không phải các bảng mà bạn nhấp qua. Điều đó nghe có vẻ thô sơ cho đến khi bạn nhận ra nó có nghĩa là mọi tinh chỉnh đều có thể được nhìn thấy, sao chép sang máy tiếp theo của bạn, và đưa vào hệ thống quản lý phiên bản. Menu _Thiết lập_ đưa bạn thẳng vào đúng tệp và khởi động lại bất cứ thứ gì cần khởi động lại khi bạn hoàn tất.

Các bản cập nhật đến qua một lệnh duy nhất — _Cập nhật > Omarchy_ — lệnh này cập nhật chính Omarchy và mọi gói trên hệ thống, đồng thời tạo một ảnh chụp trước. Không có trình cập nhật riêng cho từng ứng dụng làm phiền bạn vào những lúc ngẫu nhiên. Xem [cập nhật](30-updates.md).

Phần mềm đến từ một trình quản lý gói, chứ không phải từ các trình cài đặt được tải xuống.

Và khi bạn đóng một cửa sổ, ứng dụng thực sự thoát. Không có tình trạng lấp lửng kiểu macOS nơi chương trình tiếp tục chạy mà không có cửa sổ nào. `Super + W` — hoặc `Super + Q`, nếu đó là trí nhớ ngón tay bạn mang theo — có nghĩa là biến mất.

### Trên phần cứng Mac

Omarchy chạy tốt trên các máy Mac Intel — xem [hỗ trợ Mac](44-mac-support.md). Và bàn phím rất thân thiện với bạn: Omarchy không ánh xạ lại bất cứ thứ gì, và Linux coi phím Command là Super, vì vậy Super nằm ngay tại nơi Cmd luôn ở đó. Ngón tay cái của bạn sẽ không nhận ra sự thay đổi.

### Hãy cho nó hai tuần

Các bản năng chuyển đổi nhanh hơn bạn nghĩ. Đọc lướt chương [phím tắt](07-hotkeys.md) một lần, và bất cứ khi nào bạn quên một phím gán, nhấn `Super + K` — nó hiển thị tất cả chúng cho bạn. Đó là phím tắt duy nhất bạn thực sự phải ghi nhớ.
