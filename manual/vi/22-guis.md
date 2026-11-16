# GUIs

## Files

Files (Nautilus) là trình quản lý tệp đồ họa. `Super + Shift + F` mở nó, và `Super + Shift + Alt + F` mở nó tại thư mục mà terminal của bạn đang ở, giúp bạn đỡ phải nhấp chuột rất nhiều. `Ctrl + L` cho phép bạn nhập đường dẫn, và nhấn `Space` trên bất kỳ tệp nào sẽ cho bạn bản xem trước nhanh mà không cần mở bất cứ thứ gì.

Cắm USB hoặc thẻ SD vào và nó sẽ được gắn tự động, vì vậy nó cứ thế hiện lên trong thanh bên. Với bất cứ việc gì phức tạp hơn — định dạng ổ đĩa, kiểm tra tình trạng SMART, tạo phân vùng — hãy khởi chạy _Disks_ từ trình khởi chạy ứng dụng (`Super + Space`).

Nhấp đúp tuân theo các mặc định hợp lý: hình ảnh, video và nhạc mở trong Omaview, PDF trong Document Viewer, Markdown trong Omawrite, và văn bản thuần trong trình soạn thảo được chọn tại _Setup > Default > Editor_.

## Disktree

Khi ổ đĩa đầy và bạn không biết thứ gì đang ngốn nó, hãy khởi chạy [Disktree](https://github.com/tobi/disktree) từ trình khởi chạy ứng dụng (`Super + Space`). Nó hiển thị sơ đồ treemap đồ họa của thư mục home của bạn. Các khối lớn hơn chiếm nhiều dung lượng hơn; di chuyển vào các thư mục bằng bàn phím hoặc chuột, đánh dấu những gì cần xóa, và xem lại các lựa chọn của bạn trước khi xóa bất cứ thứ gì. Chạy `disktree --disk` để quét toàn bộ đĩa.

## Obsidian

[Obsidian](https://obsidian.md/) là một ứng dụng ghi chú miễn phí và có khả năng mở rộng cao, sử dụng các tệp Markdown đơn giản để lưu trữ.

Obsidian miễn phí cho mọi mục đích, bao gồm sử dụng cá nhân, thương mại và phi lợi nhuận.

Obsidian cũng cung cấp một [tiện ích bổ sung thương mại để đồng bộ hóa](https://obsidian.md/sync) với các ứng dụng di động trên iOS và Android. (https://obsidian.md/pricing).

Bạn khởi động Obsidian bằng `Super + Shift + O`. Để dùng đồng bộ hóa giao diện, bạn phải chọn giao diện `Omarchy` trong phần cài đặt.

## Omawrite

[Omawrite](https://github.com/omacom-io/omawrite) là ứng dụng viết Markdown siêu đơn giản của chính Omarchy. Không vault, không plugin, chỉ có bạn và những con chữ.

Bạn khởi động Omawrite bằng `Super + Shift + W`.

## Pinta

[Pinta](https://www.pinta-project.com/) là một công cụ chỉnh sửa ảnh cơ bản, rất tuyệt để cắt, thay đổi kích thước và các thao tác cơ bản khác. Chỉ đừng mong đợi nó là một lựa chọn thay thế Photoshop. Nhưng nó vẫn có Magic Wand và các lớp!

Bạn khởi động Pinta qua trình khởi chạy ứng dụng (`Super + Space`).

## Aether

[Aether](https://github.com/bjarneo/aether) là một ứng dụng tạo giao diện có thể trích xuất màu từ một ảnh nền và biến chúng thành một giao diện hoàn chỉnh, hài hòa. Đây là cách dễ nhất để [tự tạo giao diện của riêng bạn](43-making-your-own-theme.md).

Bạn khởi động Aether qua trình khởi chạy ứng dụng (`Super + Space`).

## LocalSend

[LocalSend](https://localsend.org/) cho phép bạn gửi tệp tới các thiết bị khác trên cùng mạng đang chạy ứng dụng này, giống như AirDrop của Apple. Nhưng nó đa nền tảng, vì vậy bạn có thể gửi tệp đến và từ Windows, macOS, Android, iOS và tất nhiên là Linux.

Bạn có thể mở menu Share trên `Super + Ctrl + S` hoặc tại _Trigger > Share_ trong menu Omarchy. Nó cho bạn bốn tùy chọn:

- **Clipboard** gửi bất cứ thứ gì bạn đã sao chép dưới dạng tệp văn bản. Rất tuyệt để đưa một liên kết hoặc một đoạn mã lên điện thoại của bạn mà không phải tự gửi email cho chính mình.
- **File** mở trình chọn tệp, nơi bạn có thể chọn nhiều tệp cùng lúc.
- **Folder** gửi toàn bộ một thư mục.
- **Receive** mở chính LocalSend để một thiết bị khác có thể gửi thứ gì đó cho bạn.

Điều tương tự cũng hoạt động từ terminal với `omarchy share clipboard`, `omarchy share file [path]` và `omarchy share folder [path]`. Bỏ đường dẫn đi và bạn sẽ nhận được trình chọn tệp.

Bạn cũng có thể gửi thẳng từ trình quản lý tệp: nhấp chuột phải vào bất kỳ lựa chọn nào trong Nautilus và chọn _Send via LocalSend_.

Tường lửa của Omarchy đóng theo mặc định ngoại trừ cổng của LocalSend, vì vậy việc này hoạt động ngay từ đầu trên một bản cài đặt mới. Xem [bảo mật](48-security.md).

## LibreOffice

[LibreOffice](https://www.libreoffice.org/) là một bộ ứng dụng văn phòng hoàn chỉnh với trình xử lý văn bản, bảng tính, trình chiếu, ứng dụng vẽ và nhiều hơn nữa. Nó tương thích với các tệp từ Microsoft Office, vì vậy đây là một cách tuyệt vời để có thể mở những tài liệu Word đó.

Bạn khởi động LibreOffice qua trình khởi chạy ứng dụng (`Super + Space`).

## Hype

[Hype](https://github.com/omacom/hype) là ứng dụng trình chiếu siêu đơn giản của chính Omarchy. Bài trình chiếu của bạn là một tệp Markdown duy nhất với hình ảnh và video của nó nằm bên cạnh: viết mỗi slide bên dưới bản xem trước trực tiếp, kéo các slide vào thứ tự, rồi trình chiếu toàn màn hình hoặc xuất ra PDF và PowerPoint. Nó thậm chí còn tự nhận giao diện Omarchy của bạn.

Bạn khởi động Hype qua trình khởi chạy ứng dụng (`Super + Space`). Nhấn `?` bên trong nó để xem mọi phím tắt.

## Signed

[Signed](https://github.com/omacom/signed) là cách siêu đơn giản của chính Omarchy để ký PDF và điền vào chúng. Đặt chữ ký đã lưu, văn bản và ngày hôm nay của bạn ở bất cứ đâu trên một trang, rồi lưu một bản đã ký bên cạnh bản gốc. Xem [Điền vào PDF](27-filling-out-pdfs.md) để biết cách làm.

Bạn khởi động Signed qua trình khởi chạy ứng dụng (`Super + Space`), hoặc mở một tệp PDF bằng nó từ trình quản lý tệp.

## Checkmate

[Checkmate](https://github.com/omacom/checkmate) là trò chơi cờ vua 3D của chính Omarchy. Chơi với một người bạn trên cùng một máy tính hoặc với đối thủ tích hợp sẵn ở ba cấp độ, trên bốn bộ cờ được tạo hình mà mỗi bộ di chuyển theo cách riêng của chúng: tàu quỹ đạo, gỗ và ngà voi chạm khắc, các sinh vật rừng và kẹo. Các ván cờ không có đồng hồ và được lưu sau mỗi nước đi.

Bạn khởi động Checkmate qua trình khởi chạy ứng dụng (`Super + Space`), nơi nó được liệt kê là Chess. Nhấn `?` bên trong nó để xem mọi phím tắt.

## Omacalc

[Omacalc](https://github.com/omacom-io/omacalc) là máy tính siêu đơn giản của chính Omarchy, mở trong một cửa sổ nổi.

Bạn khởi động Omacalc bằng `Super + Shift + Q` (hoặc phím máy tính, nếu bàn phím của bạn có một phím như vậy).

## Signal

[Signal](https://signal.org/) là ứng dụng tiên phong về nhắn tin mã hóa E2E, và là một lựa chọn liên lạc tuyệt vời cho bất kỳ ai muốn tránh đi qua một trong những tập đoàn công nghệ lớn.

Bạn khởi động Signal bằng `Super + Shift + G`. Nó không phải là một phần của bản cài đặt cơ bản, vì vậy lần đầu tiên bạn nhấn phím đó, Omarchy sẽ đề nghị cài đặt nó cho bạn (nó cũng nằm tại _Install > Service_ trong menu Omarchy).

## Omaview

[Omaview](https://github.com/omacom/omaview) là trình xem ảnh và trình phát đa phương tiện siêu đơn giản của chính Omarchy: một cửa sổ cho ảnh, video và nhạc của bạn. Mở một ảnh và các phím mũi tên sẽ bước qua phần còn lại của thư mục của nó, `N` và `P` làm điều đó cho bất cứ thứ gì, và `Ctrl + M` hiển thị toàn bộ thư mục dưới dạng lưới. Nó cũng hiển thị ảnh HEIC, AVIF và JPEG XL, và tiếp tục từ nơi bạn đã dừng lại trong bất cứ thứ gì dài.

Nhấn `F` để toàn màn hình, `E` để chỉnh sửa ảnh trong Omasnap hoặc cắt video trong Omacut, `Ctrl + P` để in một ảnh, và `Delete` để chuyển một tệp vào Trash (`Ctrl + Z` sẽ đưa nó trở lại). Nhấn `?` bên trong nó để xem mọi phím tắt.

Bạn khởi động Omaview dưới tên _Media Viewer_ qua trình khởi chạy ứng dụng (`Super + Space`), hoặc chỉ cần nhấp đúp vào một ảnh, video hoặc bài hát trong trình quản lý tệp.

## Omacut

[Omacut](https://github.com/omacom-io/omacut) là trình cắt video siêu đơn giản của chính Omarchy. Khi tất cả những gì bạn cần là cắt bỏ phần đầu và phần cuối của một clip, nó hơn hẳn việc phải bật cả một trình chỉnh sửa video đầy đủ.

Bạn khởi động Omacut qua trình khởi chạy ứng dụng (`Super + Space`).

## Monologue

[Monologue](https://github.com/omacom/monologue) là trình ghi webcam siêu đơn giản của chính Omarchy. Chọn camera và microphone của bạn một lần, rồi nhấn `Space` để ghi, và nhấn lần nữa để tạm dừng và tiếp tục cùng một lần ghi. Nó luôn ghi ở độ phân giải cao nhất của camera của bạn, với một đồng hồ đo microphone trực tiếp để bạn có thể kiểm tra mức âm lượng trước khi bắt đầu.

Dừng lần ghi và nó sẽ mở ngay trong một trình chỉnh sửa tích hợp sẵn. Nhấp đúp vào một clip để chia nó, kéo các tay cầm để cắt mỗi đoạn, và loại bỏ những phần bạn không muốn. Sau đó lưu nó dưới dạng MP4. Bản ghi gốc của bạn được giữ lại cho đến khi bạn loại bỏ nó, vì vậy bạn luôn có thể quay lại và cắt nó theo cách khác.

Bạn khởi động Monologue qua trình khởi chạy ứng dụng (`Super + Space`).
