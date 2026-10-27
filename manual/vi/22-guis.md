# GUI

## Files

Files (Nautilus) là trình quản lý tệp đồ họa. `Super + Shift + F` mở nó, và `Super + Shift + Alt + F` mở nó trong thư mục mà terminal của bạn đang ở, giúp bạn tiết kiệm được rất nhiều lần nhấp chuột. `Ctrl + L` cho phép bạn nhập một đường dẫn, và nhấn `Space` trên bất kỳ tệp nào sẽ cho bạn bản xem trước nhanh mà không cần mở bất cứ thứ gì.

Cắm USB hoặc thẻ SD vào và nó sẽ được gắn tự động, nên nó chỉ việc xuất hiện trong thanh bên. Với bất cứ việc gì phức tạp hơn — định dạng ổ đĩa, kiểm tra tình trạng SMART, tạo phân vùng — hãy khởi chạy _Disks_ từ trình khởi chạy ứng dụng (`Super + Space`).

Nhấp đúp chuột tuân theo các mặc định hợp lý: hình ảnh mở trong imv, video trong mpv, PDF trong Document Viewer, và văn bản thuần trong Neovim.

## Disktree

Khi ổ đĩa đầy và bạn không biết thứ gì đang ngốn dung lượng, hãy khởi chạy [Disktree](https://github.com/tobi/disktree) từ trình khởi chạy ứng dụng (`Super + Space`). Nó hiển thị một treemap đồ họa của thư mục home của bạn. Các khối lớn hơn chiếm nhiều dung lượng hơn; đi vào các thư mục bằng bàn phím hoặc chuột, đánh dấu những gì cần xóa, và xem lại các lựa chọn của bạn trước khi xóa bất cứ thứ gì. Chạy `disktree --disk` để quét toàn bộ ổ đĩa.

## Obsidian

[Obsidian](https://obsidian.md/) là một ứng dụng ghi chú miễn phí và có khả năng mở rộng cao, sử dụng các tệp Markdown đơn giản để lưu trữ.

Obsidian miễn phí cho mọi mục đích, bao gồm sử dụng cá nhân, thương mại và phi lợi nhuận.

Obsidian cũng cung cấp một [tiện ích bổ sung thương mại để đồng bộ hóa](https://obsidian.md/sync) với các ứng dụng di động trên iOS và Android. (https://obsidian.md/pricing).

Bạn khởi chạy Obsidian bằng `Super + Shift + O`. Để sử dụng tính năng đồng bộ theme, bạn phải chọn theme `Omarchy` trong phần cài đặt.

## Omawrite

[Omawrite](https://github.com/omacom-io/omawrite) là ứng dụng viết Markdown cực kỳ đơn giản của chính Omarchy. Không vault, không plugin, chỉ có bạn và những con chữ.

Bạn khởi chạy Omawrite bằng `Super + Shift + W`.

## Pinta

[Pinta](https://www.pinta-project.com/) là một công cụ chỉnh sửa hình ảnh cơ bản, rất tuyệt để cắt, thay đổi kích thước và các thao tác cơ bản khác. Chỉ đừng mong đợi một sự thay thế cho Photoshop. Nhưng nó vẫn có Magic Wand và các layer!

Bạn khởi chạy Pinta qua trình khởi chạy ứng dụng (`Super + Space`).

## Aether

[Aether](https://github.com/bjarneo/aether) là một ứng dụng tạo theme có thể trích xuất màu sắc từ một hình nền và biến chúng thành một theme hoàn chỉnh, hài hòa. Đây là cách dễ nhất để [tự tạo theme của riêng bạn](43-making-your-own-theme.md).

Bạn khởi chạy Aether qua trình khởi chạy ứng dụng (`Super + Space`).

## LocalSend

[LocalSend](https://localsend.org/) cho phép bạn gửi tệp tới các thiết bị khác trên cùng mạng đang chạy ứng dụng này, giống như AirDrop của Apple. Tuy nhiên, nó đa nền tảng, nên bạn có thể gửi tệp đến và từ Windows, macOS, Android, iOS, và tất nhiên là Linux.

Bạn có thể mở menu Share trên `Super + Ctrl + S` hoặc trong _Trigger > Share_ trong menu Omarchy. Nó cho bạn bốn lựa chọn:

- **Clipboard** gửi bất cứ thứ gì bạn đã sao chép dưới dạng một tệp văn bản. Rất tuyệt để đưa một liên kết hoặc một đoạn mã lên điện thoại mà không cần tự gửi email cho mình.
- **File** mở một trình chọn tệp, nơi bạn có thể chọn nhiều tệp cùng lúc.
- **Folder** gửi toàn bộ một thư mục.
- **Receive** mở LocalSend đúng nghĩa để một thiết bị khác có thể gửi thứ gì đó cho bạn.

Điều tương tự cũng hoạt động từ terminal với `omarchy share clipboard`, `omarchy share file [path]`, và `omarchy share folder [path]`. Bỏ đường dẫn đi và bạn sẽ nhận được trình chọn tệp.

Bạn cũng có thể gửi thẳng từ trình quản lý tệp: nhấp chuột phải vào bất kỳ lựa chọn nào trong Nautilus và chọn _Send via LocalSend_.

Tường lửa của Omarchy đóng theo mặc định ngoại trừ cổng của LocalSend, nên tính năng này hoạt động ngay từ đầu trên một bản cài đặt mới. Xem [bảo mật](48-security.md).

## LibreOffice

[LibreOffice](https://www.libreoffice.org/) là một bộ ứng dụng văn phòng hoàn chỉnh với trình xử lý văn bản, bảng tính, trình chiếu, ứng dụng vẽ, và nhiều hơn nữa. Nó tương thích với các tệp từ Microsoft Office, nên đây là một cách tuyệt vời để có thể mở những tài liệu Word đó.

Bạn khởi chạy LibreOffice qua trình khởi chạy ứng dụng (`Super + Space`).

## Hype

[Hype](https://github.com/omacom/hype) là ứng dụng trình chiếu cực kỳ đơn giản của chính Omarchy. Bộ slide của bạn là một tệp Markdown duy nhất với các hình ảnh và video của nó nằm bên cạnh: viết mỗi slide bên dưới một bản xem trước trực tiếp, kéo các slide theo thứ tự, rồi trình chiếu toàn màn hình hoặc xuất ra PDF và PowerPoint. Nó thậm chí còn nhận theme Omarchy của bạn.

Bạn khởi chạy Hype qua trình khởi chạy ứng dụng (`Super + Space`). Nhấn `?` bên trong nó để xem mọi phím tắt.

## Signed

[Signed](https://github.com/omacom/signed) là cách cực kỳ đơn giản của chính Omarchy để ký PDF và điền vào chúng. Đặt chữ ký đã lưu, văn bản, và ngày hôm nay của bạn ở bất cứ đâu trên một trang, rồi lưu một bản sao đã ký bên cạnh bản gốc. Xem [Điền vào PDF](27-filling-out-pdfs.md) để biết cách làm.

Bạn khởi chạy Signed qua trình khởi chạy ứng dụng (`Super + Space`), hoặc mở một PDF bằng nó từ trình quản lý tệp.

## Omacalc

[Omacalc](https://github.com/omacom-io/omacalc) là máy tính cực kỳ đơn giản của chính Omarchy, mở trong một cửa sổ nổi.

Bạn khởi chạy Omacalc bằng `Super + Shift + Q` (hoặc phím máy tính, nếu bàn phím của bạn có phím đó).

## Signal

[Signal](https://signal.org/) là ứng dụng tiên phong về nhắn tin mã hóa E2E, và là một lựa chọn giao tiếp tuyệt vời cho bất kỳ ai không muốn đi qua một trong những tập đoàn công nghệ lớn.

Bạn khởi chạy Signal bằng `Super + Shift + G`. Nó không phải là một phần của bản cài đặt cơ bản, nên lần đầu tiên bạn nhấn phím đó, Omarchy sẽ đề nghị cài đặt nó cho bạn (nó cũng nằm trong _Install > Service_ trong menu Omarchy).

## mpv

[mpv](https://mpv.io/) là một trình phát đa phương tiện đơn giản, nhanh, sẽ phát gần như bất cứ thứ gì từ bất kỳ nguồn nào. Rất tuyệt để xem video.

Bạn khởi chạy mpv qua trình khởi chạy ứng dụng (`Super + Space`) hoặc chỉ cần nhấp đúp vào một video trong trình quản lý tệp.

## Omacut

[Omacut](https://github.com/omacom-io/omacut) là trình cắt video cực kỳ đơn giản của chính Omarchy. Khi tất cả những gì bạn cần là cắt bỏ phần đầu và phần cuối của một clip, nó hơn hẳn việc phải khởi động một trình chỉnh sửa video đầy đủ.

Bạn khởi chạy Omacut qua trình khởi chạy ứng dụng (`Super + Space`).

## Monologue

[Monologue](https://github.com/omacom/monologue) là trình ghi webcam cực kỳ đơn giản của chính Omarchy. Chọn camera và microphone của bạn một lần, rồi nhấn `Space` để ghi, và nhấn lại để tạm dừng và tiếp tục cùng một lần ghi. Nó luôn ghi ở độ phân giải cao nhất của camera của bạn, với một đồng hồ đo microphone trực tiếp để bạn có thể kiểm tra mức âm lượng trước khi bắt đầu.

Dừng lần ghi và nó sẽ mở ngay trong một trình chỉnh sửa tích hợp. Nhấp đúp vào một clip để chia nó ra, kéo các tay cầm để cắt mỗi phần, và loại bỏ những phần bạn không muốn. Sau đó lưu nó dưới dạng MP4. Bản ghi gốc của bạn được giữ lại cho đến khi bạn loại bỏ nó, nên bạn luôn có thể quay lại và cắt nó theo cách khác.

Bạn khởi chạy Monologue qua trình khởi chạy ứng dụng (`Super + Space`).
