# Giao diện đồ họa

## Files

Files (Folio) là trình quản lý file đồ họa. `Super + Shift + F` mở nó, và `Super + Shift + Alt + F` mở nó tại thư mục mà terminal của bạn đang ở, giúp tiết kiệm rất nhiều lần nhấp chuột. `Ctrl + L` cho phép bạn gõ một đường dẫn, và nhấn `Space` trên bất kỳ file nào sẽ xem trước nó ở kích thước đầy đủ mà không cần mở nó.

Cắm một USB hoặc một thẻ SD vào và nó sẽ được gắn tự động, vì vậy nó cứ thế xuất hiện trong thanh bên. Đối với bất cứ việc gì phức tạp hơn — định dạng một ổ đĩa, kiểm tra tình trạng SMART, tạo các phân vùng — hãy khởi chạy _Disks_ từ trình khởi chạy ứng dụng (`Super + Space`).

Nhấp đúp chuột tuân theo các mặc định hợp lý: hình ảnh, video và nhạc mở trong Omaview, PDF trong Document Viewer, Markdown trong Omawrite, và văn bản thuần trong trình soạn thảo của bạn, Plain trừ khi bạn chọn một trình khác trong _Setup > Defaults > Editor_.

## Disktree

Khi ổ đĩa đầy và bạn không biết thứ gì đang ngốn dung lượng của nó, hãy khởi chạy [Disktree](https://github.com/tobi/disktree) từ trình khởi chạy ứng dụng (`Super + Space`). Nó hiển thị một treemap đồ họa của thư mục home của bạn. Các khối lớn hơn chiếm nhiều dung lượng hơn; đi vào các thư mục bằng bàn phím hoặc chuột, đánh dấu những thứ cần loại bỏ, và xem lại các lựa chọn của bạn trước khi xóa bất cứ thứ gì. Chạy `disktree --disk` để quét toàn bộ ổ đĩa.

## Obsidian

[Obsidian](https://obsidian.md/) là một ứng dụng ghi chú miễn phí và có khả năng mở rộng cao, sử dụng các file Markdown đơn giản để lưu trữ.

Obsidian miễn phí cho mọi mục đích, bao gồm sử dụng cá nhân, thương mại và phi lợi nhuận.

Obsidian cũng cung cấp một [tiện ích bổ sung thương mại để đồng bộ hóa](https://obsidian.md/sync) với các ứng dụng di động trên iOS và Android. (https://obsidian.md/pricing).

Bạn khởi động Obsidian bằng `Super + Shift + O`. Để sử dụng đồng bộ hóa theme, bạn phải chọn theme `Omarchy` trong phần cài đặt.

## Omawrite

[Omawrite](https://github.com/omacom-io/omawrite) là ứng dụng viết Markdown đơn giản hết mức của chính Omarchy. Không vault, không plugin, chỉ có bạn và những con chữ.

Bạn khởi động Omawrite bằng `Super + Shift + W`.

## Pinta

[Pinta](https://www.pinta-project.com/) là một công cụ chỉnh sửa ảnh cơ bản, rất tuyệt để cắt, thay đổi kích thước và các thao tác cơ bản khác. Chỉ đừng mong đợi một lựa chọn thay thế Photoshop. Nhưng nó vẫn có Magic Wand và các layer!

Bạn khởi động Pinta qua trình khởi chạy ứng dụng (`Super + Space`).

## Aether

[Aether](https://github.com/bjarneo/aether) là một ứng dụng tạo theme có thể trích xuất màu sắc từ một hình nền và biến chúng thành một theme hoàn chỉnh, hài hòa. Đây là cách dễ nhất để [tự tạo theme của riêng bạn](43-making-your-own-theme.md).

Bạn khởi động Aether qua trình khởi chạy ứng dụng (`Super + Space`).

## LocalSend

[LocalSend](https://localsend.org/) cho phép bạn gửi file tới các thiết bị khác trên cùng mạng đang chạy ứng dụng, giống như AirDrop của Apple. Tuy nhiên, nó đa nền tảng, vì vậy bạn có thể gửi file qua lại với Windows, macOS, Android, iOS và dĩ nhiên là Linux.

Bạn có thể mở menu Share bằng `Super + Ctrl + S` hoặc trong _Trigger > Share_ trong menu Omarchy. Nó cho bạn bốn tùy chọn:

- **Clipboard** gửi bất cứ thứ gì bạn đã sao chép dưới dạng một file văn bản. Rất tuyệt để đưa một liên kết hoặc một đoạn mã lên điện thoại của bạn mà không cần tự gửi email cho mình.
- **File** mở một trình chọn file, nơi bạn có thể chọn nhiều file cùng lúc.
- **Folder** gửi toàn bộ một thư mục.
- **Receive** mở LocalSend thực sự để một thiết bị khác có thể gửi thứ gì đó cho bạn.

Điều tương tự cũng hoạt động từ terminal với `omarchy share clipboard`, `omarchy share file [path]` và `omarchy share folder [path]`. Bỏ đường dẫn đi và bạn sẽ nhận được trình chọn file.

Bạn cũng có thể gửi thẳng từ trình quản lý file: nhấp chuột phải vào bất kỳ lựa chọn nào trong Files và chia sẻ nó với LocalSend.

Tường lửa của Omarchy đóng theo mặc định ngoại trừ cổng của LocalSend, vì vậy tính năng này hoạt động ngay lập tức trên một bản cài đặt mới. Xem [bảo mật](48-security.md).

## LibreOffice

[LibreOffice](https://www.libreoffice.org/) là một bộ ứng dụng văn phòng hoàn chỉnh với trình xử lý văn bản, bảng tính, bản trình chiếu, ứng dụng vẽ và nhiều hơn nữa. Nó tương thích với các file từ Microsoft Office, vì vậy đây là một cách tuyệt vời để có thể mở những tài liệu Word đó.

Bạn khởi động LibreOffice qua trình khởi chạy ứng dụng (`Super + Space`).

## Hype

[Hype](https://github.com/omacom/hype) là ứng dụng trình chiếu đơn giản hết mức của chính Omarchy. Bộ slide của bạn là một file Markdown duy nhất với các hình ảnh và video của nó bên cạnh: viết mỗi slide bên dưới một bản xem trước trực tiếp, kéo các slide theo thứ tự, sau đó trình chiếu toàn màn hình hoặc xuất ra PDF và PowerPoint. Nó thậm chí còn tự nhận theme Omarchy của bạn.

Bạn khởi động Hype qua trình khởi chạy ứng dụng (`Super + Space`). Nhấn `?` bên trong nó để xem mọi phím tắt.

## Signed

[Signed](https://github.com/omacom/signed) là cách đơn giản hết mức của chính Omarchy để ký các file PDF và điền vào chúng. Đặt chữ ký đã lưu, văn bản và ngày hôm nay của bạn ở bất cứ đâu trên một trang, sau đó lưu một bản đã ký bên cạnh bản gốc. Xem [Điền vào file PDF](27-filling-out-pdfs.md) để biết cách làm.

Bạn khởi động Signed qua trình khởi chạy ứng dụng (`Super + Space`), hoặc mở một file PDF bằng nó từ trình quản lý file.

## Game Vibes

Game Vibes, trong trình khởi chạy ứng dụng (`Super + Space`), là nơi các trò chơi nhỏ của Omarchy cư trú: Checkmate, một trò cờ vua 3D đấu với một người bạn hoặc đối thủ tích hợp sẵn; Cards, bài Klondike solitaire; Death Wish, một trò platformer chính xác đến từng pixel gồm mười phòng đầy gai và cưa; và Neon Swarm, một trò bắn súng arcade. Mỗi trò là một trang web duy nhất tuân theo theme của bạn. Chọn một trò bằng các phím mũi tên và `Enter`, và quay trở lại danh sách bằng `Esc` từ màn hình tiêu đề của một trò chơi hoặc `Q` khi nó đang tạm dừng. Nó mở ở chế độ toàn màn hình: `Super + F` biến nó thành một cửa sổ, và `Super + W` đóng nó.

Các trò chơi bạn tạo với một agent cũng xuất hiện ở đây: chọn _Make something cool → Game_ trong bảng agents và mô tả một trò, hoặc nêu tên một trò chơi đã có trong Game Vibes để tiếp tục làm việc với nó. Agent sao chép nó vào `~/Games/vibes`, nơi nó thuộc về bạn để thay đổi, và mở nó khi nó hoàn thành. Bạn có thể tự tạo bản sao đó bằng `omarchy games vibes copy <game>`. Một trò chơi mà người khác chia sẻ sẽ cài đặt giống như một theme: chọn _Install > Gaming > Game Vibes_ và dán địa chỉ git của nó, hoặc chạy `omarchy games vibes install <git-repo-url>`. _Remove > Gaming_ sẽ loại bỏ một trò, và _Update > Game Vibes Games_ sẽ lấy các phiên bản mới. Các trò chơi tải three.js từ web, vì vậy chúng cần một kết nối để khởi động.

## Omacalc

[Omacalc](https://github.com/omacom-io/omacalc) là máy tính đơn giản hết mức của chính Omarchy, mở trong một cửa sổ nổi.

Bạn khởi động Omacalc bằng `Super + Shift + Q` (hoặc phím máy tính, nếu bàn phím của bạn có phím đó).

## Signal

[Signal](https://signal.org/) là ứng dụng tiên phong về nhắn tin mã hóa E2E, và là một lựa chọn giao tiếp tuyệt vời cho bất kỳ ai không muốn đi qua một trong những tập đoàn công nghệ lớn.

Bạn khởi động Signal bằng `Super + Shift + G`. Nó không phải là một phần của bản cài đặt cơ bản, vì vậy lần đầu tiên bạn nhấn phím đó, Omarchy sẽ đề nghị cài đặt nó cho bạn (nó cũng nằm trong _Install > Service_ trong menu Omarchy).

## Omaview

[Omaview](https://github.com/omacom/omaview) là trình xem ảnh và trình phát đa phương tiện đơn giản hết mức của chính Omarchy: một cửa sổ cho ảnh, video và nhạc của bạn. Mở một bức ảnh và các phím mũi tên sẽ bước qua phần còn lại của thư mục chứa nó, `N` và `P` làm điều đó cho bất cứ thứ gì, và `Ctrl + M` hiển thị toàn bộ thư mục dưới dạng một lưới. Nó cũng hiển thị các ảnh HEIC, AVIF và JPEG XL, và tiếp tục từ nơi bạn đã dừng lại trong bất cứ thứ gì dài.

Nhấn `F` để vào chế độ toàn màn hình, `E` để chỉnh sửa một bức ảnh trong Omasnap hoặc cắt một video trong Omacut, `Ctrl + P` để in một bức ảnh, và `Delete` để di chuyển một file vào Trash (`Ctrl + Z` đưa nó trở lại). Nhấn `?` bên trong nó để xem mọi phím tắt.

Bạn khởi động Omaview dưới tên _Media Viewer_ qua trình khởi chạy ứng dụng (`Super + Space`), hoặc chỉ cần nhấp đúp vào một bức ảnh, video hoặc bài hát trong trình quản lý file.

## Omacut

[Omacut](https://github.com/omacom-io/omacut) là trình cắt video đơn giản hết mức của chính Omarchy. Khi tất cả những gì bạn cần là cắt bỏ phần đầu và phần cuối của một clip, nó ăn đứt việc phải khởi động một trình chỉnh sửa video đầy đủ.

Bạn khởi động Omacut qua trình khởi chạy ứng dụng (`Super + Space`).

## Monologue

[Monologue](https://github.com/omacom/monologue) là trình ghi webcam đơn giản hết mức của chính Omarchy. Chọn camera và microphone của bạn một lần, sau đó nhấn `Space` để ghi, và nhấn lại để tạm dừng và tiếp tục cùng một đoạn ghi. Nó luôn ghi ở độ phân giải cao nhất của camera của bạn, với một đồng hồ đo microphone trực tiếp để bạn có thể kiểm tra các mức của mình trước khi bắt đầu.

Dừng đoạn ghi và nó sẽ mở ngay trong một trình chỉnh sửa tích hợp sẵn. Nhấp đúp vào một clip để chia nó ra, kéo các tay cầm để cắt mỗi đoạn, và loại bỏ những phần bạn không muốn. Sau đó lưu nó dưới dạng một file MP4. Bản ghi gốc của bạn được giữ lại cho đến khi bạn loại bỏ nó, vì vậy bạn luôn có thể quay lại và cắt nó theo một cách khác.

Bạn khởi động Monologue qua trình khởi chạy ứng dụng (`Super + Space`).
