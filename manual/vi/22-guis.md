# GUI

## Files

Files (Nautilus) là trình quản lý tệp đồ họa. `Super + Shift + F` mở nó, và `Super + Shift + Alt + F` mở nó trong thư mục mà terminal của bạn đang ở, giúp tiết kiệm rất nhiều lần nhấp chuột. `Ctrl + L` cho phép bạn gõ một đường dẫn, và nhấn `Space` trên bất kỳ tệp nào sẽ cho bạn xem trước nhanh mà không cần mở gì cả.

Cắm một thẻ USB hoặc thẻ SD vào và nó sẽ được gắn tự động, vì vậy nó chỉ xuất hiện trong thanh bên. Đối với những việc phức tạp hơn — định dạng ổ đĩa, kiểm tra tình trạng SMART, tạo phân vùng — hãy khởi chạy _Disks_ từ trình khởi chạy ứng dụng (`Super + Space`).

Nhấp đúp tuân theo các mặc định hợp lý: hình ảnh mở trong imv, video trong mpv, PDF trong Document Viewer, và văn bản thuần trong Neovim.

## Disktree

Khi ổ đĩa đầy mà bạn không biết thứ gì đang ngốn nó, hãy khởi chạy [Disktree](https://github.com/tobi/disktree) từ trình khởi chạy ứng dụng (`Super + Space`). Nó hiển thị một bản đồ cây đồ họa của thư mục nhà của bạn. Các khối lớn hơn chiếm nhiều không gian hơn; di chuyển vào các thư mục bằng bàn phím hoặc chuột, đánh dấu những gì cần loại bỏ, và xem lại lựa chọn của bạn trước khi xóa bất cứ thứ gì. Chạy `disktree --disk` để quét toàn bộ đĩa.

## Obsidian

[Obsidian](https://obsidian.md/) là một ứng dụng ghi chú miễn phí và có khả năng mở rộng cao, sử dụng các tệp Markdown đơn giản để lưu trữ.

Obsidian miễn phí cho mọi mục đích, bao gồm sử dụng cá nhân, thương mại và phi lợi nhuận.

Obsidian cũng cung cấp một [tiện ích bổ sung thương mại để đồng bộ](https://obsidian.md/sync) với các ứng dụng di động trên iOS và Android. (https://obsidian.md/pricing).

Bạn khởi động Obsidian bằng `Super + Shift + O`. Để sử dụng đồng bộ giao diện, bạn phải chọn giao diện `Omarchy` trong phần cài đặt.

## Omawrite

[Omawrite](https://github.com/omacom-io/omawrite) là ứng dụng viết Markdown cực kỳ đơn giản của chính Omarchy. Không kho lưu trữ, không plugin, chỉ có bạn và những con chữ.

Bạn khởi động Omawrite bằng `Super + Shift + W`.

## Pinta

[Pinta](https://www.pinta-project.com/) là một công cụ chỉnh sửa hình ảnh cơ bản, tuyệt vời cho việc cắt, thay đổi kích thước và các thao tác cơ bản khác. Chỉ đừng kỳ vọng nó là một lựa chọn thay thế cho Photoshop. Nhưng nó vẫn có Magic Wand và các lớp!

Bạn khởi động Pinta qua trình khởi chạy ứng dụng (`Super + Space`).

## Aether

[Aether](https://github.com/bjarneo/aether) là một ứng dụng tạo giao diện có thể trích xuất màu sắc từ một hình nền và biến chúng thành một giao diện hoàn chỉnh, hài hòa. Đây là cách dễ nhất để [tự tạo giao diện của riêng bạn](43-making-your-own-theme.md).

Bạn khởi động Aether qua trình khởi chạy ứng dụng (`Super + Space`).

## LocalSend

[LocalSend](https://localsend.org/) cho phép bạn gửi tệp đến các thiết bị khác trên cùng mạng đang chạy ứng dụng, giống như AirDrop của Apple. Tuy nhiên, nó là đa nền tảng, vì vậy bạn có thể gửi tệp đến và nhận tệp từ Windows, macOS, Android, iOS, và tất nhiên cả Linux.

Bạn có thể mở menu Share bằng `Super + Ctrl + S` hoặc trong _Kích hoạt > Chia sẻ_ trong menu Omarchy. Nó cho bạn bốn tùy chọn:

- **Clipboard** gửi bất cứ thứ gì bạn đã sao chép dưới dạng một tệp văn bản. Rất tuyệt để đưa một liên kết hoặc một đoạn mã lên điện thoại của bạn mà không cần tự gửi email cho mình.
- **File** mở một bộ chọn tệp nơi bạn có thể chọn nhiều tệp cùng lúc.
- **Folder** gửi toàn bộ một thư mục.
- **Receive** mở chính LocalSend để một thiết bị khác có thể gửi thứ gì đó cho bạn.

Điều tương tự cũng hoạt động từ terminal với `omarchy share clipboard`, `omarchy share file [path]` và `omarchy share folder [path]`. Bỏ qua đường dẫn và bạn sẽ nhận được bộ chọn.

Bạn cũng có thể gửi thẳng từ trình quản lý tệp: nhấp chuột phải vào bất kỳ lựa chọn nào trong Nautilus và chọn _Send via LocalSend_.

Tường lửa của Omarchy đóng theo mặc định ngoại trừ cổng của LocalSend, vì vậy tính năng này hoạt động ngay từ đầu trên một bản cài đặt mới. Xem [bảo mật](48-security.md).

## LibreOffice

[LibreOffice](https://www.libreoffice.org/) là một bộ ứng dụng văn phòng hoàn chỉnh với trình xử lý văn bản, bảng tính, thuyết trình, ứng dụng vẽ và nhiều thứ khác. Nó tương thích với các tệp từ Microsoft Office, vì vậy đây là cách tuyệt vời để có thể mở những tài liệu Word đó.

Bạn khởi động LibreOffice qua trình khởi chạy ứng dụng (`Super + Space`).

## Hype

[Hype](https://github.com/omacom/hype) là ứng dụng thuyết trình cực kỳ đơn giản của chính Omarchy. Bài thuyết trình của bạn là một tệp Markdown duy nhất với hình ảnh và video nằm bên cạnh: viết mỗi trang chiếu bên dưới phần xem trước trực tiếp, kéo các trang chiếu vào đúng thứ tự, rồi trình chiếu toàn màn hình hoặc xuất ra PDF và PowerPoint. Nó thậm chí còn nhận giao diện Omarchy của bạn.

Bạn khởi động Hype qua trình khởi chạy ứng dụng (`Super + Space`). Nhấn `?` bên trong nó để xem mọi phím tắt.

## Signed

[Signed](https://github.com/omacom/signed) là cách cực kỳ đơn giản của chính Omarchy để ký PDF và điền vào chúng. Đặt chữ ký đã lưu, văn bản và ngày hôm nay ở bất cứ đâu trên một trang, rồi lưu một bản sao đã ký bên cạnh bản gốc. Xem [Điền PDF](27-filling-out-pdfs.md) để biết cách thực hiện.

Bạn khởi động Signed qua trình khởi chạy ứng dụng (`Super + Space`), hoặc mở một PDF bằng nó từ trình quản lý tệp.

## Omacalc

[Omacalc](https://github.com/omacom-io/omacalc) là máy tính cực kỳ đơn giản của chính Omarchy, mở ra trong một cửa sổ nổi.

Bạn khởi động Omacalc bằng `Super + Ctrl + Q` (hoặc phím máy tính, nếu bàn phím của bạn có).

## Signal

[Signal](https://signal.org/) là người tiên phong trong nhắn tin mã hóa đầu cuối (E2E), và là một lựa chọn liên lạc tuyệt vời cho bất kỳ ai không muốn đi qua một trong các tập đoàn công nghệ lớn.

Bạn khởi động Signal bằng `Super + Shift + G`. Nó không phải là một phần của bản cài đặt cơ sở, vì vậy lần đầu tiên bạn nhấn phím đó, Omarchy sẽ đề nghị cài đặt nó cho bạn (nó cũng nằm trong _Cài đặt > Dịch vụ_ trong menu Omarchy).

## mpv

[mpv](https://mpv.io/) là một trình phát đa phương tiện đơn giản, nhanh chóng, có thể phát gần như mọi thứ từ bất kỳ nguồn nào. Rất tuyệt để xem video.

Bạn khởi động mpv qua trình khởi chạy ứng dụng (`Super + Space`) hoặc chỉ cần nhấp đúp vào một video trong trình quản lý tệp.

## Omacut

[Omacut](https://github.com/omacom-io/omacut) là công cụ cắt video cực kỳ đơn giản của chính Omarchy. Khi tất cả những gì bạn cần là cắt phần đầu và cuối của một đoạn clip, nó thắng việc phải mở một trình biên tập video đầy đủ.

Bạn khởi động Omacut qua trình khởi chạy ứng dụng (`Super + Space`).

## Monologue

[Monologue](https://github.com/omacom/monologue) là trình ghi webcam cực kỳ đơn giản của chính Omarchy. Chọn camera và micro của bạn một lần, rồi nhấn `Space` để ghi, và nhấn lại để tạm dừng và tiếp tục cùng một đoạn ghi. Nó luôn ghi ở độ phân giải cao nhất của camera, với một đồng hồ đo micro trực tiếp để bạn có thể kiểm tra mức âm lượng trước khi bắt đầu.

Dừng đoạn ghi và nó sẽ mở ngay trong một trình biên tập tích hợp sẵn. Nhấp đúp vào một clip để chia nó ra, kéo các tay cầm để cắt từng đoạn, và loại bỏ những phần bạn không muốn. Sau đó lưu nó dưới dạng MP4. Bản ghi gốc của bạn được giữ cho đến khi bạn loại bỏ nó, vì vậy bạn luôn có thể quay lại và cắt nó theo cách khác.

Bạn khởi động Monologue qua trình khởi chạy ứng dụng (`Super + Space`).
