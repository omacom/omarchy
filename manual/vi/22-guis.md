# Các ứng dụng giao diện đồ họa (GUI)

## Files

Files (Folio) là trình quản lý tệp đồ họa. `Super + Shift + F` mở nó, còn `Super + Shift + Alt + F` mở nó ngay tại thư mục mà terminal của bạn đang đứng, giúp bạn đỡ phải nhấp chuột rất nhiều. `Ctrl + L` cho phép bạn gõ một đường dẫn, và nhấn `Space` trên bất kỳ tệp nào sẽ xem trước tệp đó ở kích thước đầy đủ mà không mở nó ra.

Cắm một USB hay thẻ SD vào là nó được gắn tự động, nên nó cứ thế xuất hiện trong thanh bên. Với bất cứ việc gì phức tạp hơn — định dạng ổ đĩa, kiểm tra tình trạng SMART, tạo phân vùng — hãy khởi chạy _Disks_ từ trình khởi chạy ứng dụng (`Super + Space`).

Một ổ đĩa đã mã hoá sẽ hỏi mật khẩu của nó khi được cắm vào. Để một ổ đĩa tự mở khoá, hãy thêm một keyfile vào nó bằng `sudo cryptsetup luksAddKey /dev/sdX1 <keyfile>` và đặt keyfile đó tại `~/.config/omarchy/drive-keys/<UUID>`, được đặt tên theo UUID mà `lsblk -dno UUID /dev/sdX1` in ra cho phân vùng đã mã hoá, và chỉ mình bạn đọc được (`chmod 600`). Nếu keyfile đó bị thiếu hoặc bị từ chối, bạn sẽ được hỏi mật khẩu như bình thường.

Nhấp đúp chuột tuân theo các mặc định hợp lý: hình ảnh, video và nhạc mở trong Omaview, PDF trong Document Viewer, Markdown trong Omawrite, và văn bản thuần trong trình soạn thảo của bạn, Plain trừ khi bạn chọn một trình khác trong _Setup > Defaults > Editor_.

## Disktree

Khi ổ đĩa đầy và bạn không biết thứ gì đang ngốn nó, hãy khởi chạy [Disktree](https://github.com/tobi/disktree) từ trình khởi chạy ứng dụng (`Super + Space`). Nó hiển thị một treemap đồ họa của thư mục nhà của bạn. Các khối lớn hơn chiếm nhiều không gian hơn; đi vào các thư mục bằng bàn phím hoặc chuột, đánh dấu những gì cần loại bỏ, và xem lại các lựa chọn của bạn trước khi loại bỏ bất cứ thứ gì. Chạy `disktree --disk` để quét toàn bộ đĩa.

## Obsidian

[Obsidian](https://obsidian.md/) là một ứng dụng ghi chú miễn phí và có khả năng mở rộng cao, sử dụng các tệp Markdown đơn giản để lưu trữ.

Obsidian miễn phí cho mọi mục đích, bao gồm sử dụng cá nhân, thương mại và phi lợi nhuận.

Obsidian cũng cung cấp một [tiện ích bổ sung thương mại để đồng bộ hoá](https://obsidian.md/sync) với các ứng dụng di động trên iOS và Android. (https://obsidian.md/pricing).

Bạn khởi chạy Obsidian bằng `Super + Shift + O`. Để sử dụng đồng bộ hoá theme, bạn phải chọn theme `Omarchy` trong phần cài đặt.

## Omawrite

[Omawrite](https://github.com/omacom-io/omawrite) là ứng dụng viết Markdown cực kỳ đơn giản của chính Omarchy. Không vault, không plugin, chỉ có bạn và những con chữ.

Bạn khởi chạy Omawrite bằng `Super + Shift + W`.

## Pinta

[Pinta](https://www.pinta-project.com/) là một công cụ chỉnh sửa hình ảnh cơ bản, rất tuyệt để cắt, thay đổi kích thước và các thao tác cơ bản khác. Chỉ đừng mong đợi một sự thay thế cho Photoshop. Nhưng nó vẫn có Magic Wand và các lớp!

Bạn khởi chạy Pinta qua trình khởi chạy ứng dụng (`Super + Space`).

## Aether

[Aether](https://github.com/bjarneo/aether) là một ứng dụng tạo theme có thể trích xuất màu sắc từ một hình nền và biến chúng thành một theme hoàn chỉnh, hài hoà. Đây là cách dễ nhất để [tự tạo theme cho riêng bạn](43-making-your-own-theme.md).

Bạn khởi chạy Aether qua trình khởi chạy ứng dụng (`Super + Space`).

## LocalSend

[LocalSend](https://localsend.org/) cho phép bạn gửi tệp tới các thiết bị khác trên cùng mạng đang chạy ứng dụng, giống như AirDrop của Apple. Tuy nhiên, nó đa nền tảng, nên bạn có thể gửi tệp đến và từ Windows, macOS, Android, iOS, và tất nhiên là Linux.

Bạn có thể mở menu Share bằng `Super + Ctrl + S` hoặc trong _Trigger > Share_ trong menu của Omarchy. Nó cho bạn bốn tuỳ chọn:

- **Clipboard** gửi bất cứ thứ gì bạn đã sao chép dưới dạng một tệp văn bản. Rất tuyệt để đưa một liên kết hoặc một đoạn mã lên điện thoại của bạn mà không cần tự gửi email cho chính mình.
- **File** mở một bộ chọn tệp nơi bạn có thể chọn nhiều tệp cùng lúc.
- **Folder** gửi toàn bộ một thư mục.
- **Receive** mở chính LocalSend để một thiết bị khác có thể gửi thứ gì đó cho bạn.

Điều tương tự cũng hoạt động từ terminal với `omarchy share clipboard`, `omarchy share file [path]`, và `omarchy share folder [path]`. Bỏ đường dẫn đi và bạn sẽ nhận được bộ chọn tệp.

Bạn cũng có thể gửi thẳng từ trình quản lý tệp: nhấp chuột phải vào bất kỳ lựa chọn nào trong Files và chia sẻ nó bằng LocalSend.

Tường lửa của Omarchy được đóng theo mặc định ngoại trừ cổng của LocalSend, vì vậy việc này hoạt động ngay lập tức trên một bản cài đặt mới. Xem [bảo mật](48-security.md).

## LibreOffice

[LibreOffice](https://www.libreoffice.org/) là một bộ ứng dụng văn phòng hoàn chỉnh với trình xử lý văn bản, bảng tính, trình chiếu, ứng dụng vẽ, và hơn nữa. Nó tương thích với các tệp từ Microsoft Office, vì vậy đây là một cách tuyệt vời để có thể mở những tài liệu Word đó.

Bạn khởi chạy LibreOffice qua trình khởi chạy ứng dụng (`Super + Space`).

## Hype

[Hype](https://github.com/omacom/hype) là ứng dụng trình chiếu cực kỳ đơn giản của chính Omarchy. Bộ slide của bạn là một tệp Markdown duy nhất với hình ảnh và video của nó bên cạnh: viết mỗi slide bên dưới một bản xem trước trực tiếp, kéo các slide theo thứ tự, rồi trình chiếu toàn màn hình hoặc xuất ra PDF và PowerPoint. Nó thậm chí còn tiếp nhận theme Omarchy của bạn.

Bạn khởi chạy Hype qua trình khởi chạy ứng dụng (`Super + Space`). Nhấn `?` bên trong nó để xem mọi phím tắt.

## Signed

[Signed](https://github.com/omacom/signed) là cách cực kỳ đơn giản của chính Omarchy để ký PDF và điền vào chúng. Đặt chữ ký đã lưu, văn bản và ngày hôm nay của bạn ở bất cứ đâu trên một trang, rồi lưu một bản sao đã ký bên cạnh bản gốc. Xem [Điền vào PDF](27-filling-out-pdfs.md) để biết cách làm.

Bạn khởi chạy Signed qua trình khởi chạy ứng dụng (`Super + Space`), hoặc mở một PDF bằng nó từ trình quản lý tệp.

## Game Vibes

Game Vibes, trong trình khởi chạy ứng dụng (`Super + Space`), là nơi các trò chơi nhỏ của Omarchy sống: Checkmate, một trò chơi cờ vua 3D đấu với một người bạn hoặc đối thủ tích hợp sẵn; Cards, trò chơi bài Klondike solitaire; Death Wish, một trò chơi platformer chính xác đến từng pixel gồm mười phòng đầy gai và cưa; và Neon Swarm, một trò chơi bắn súng arcade. Mỗi trò là một trang web duy nhất tuân theo theme của bạn. Chọn một trò bằng các phím mũi tên và `Enter`, và quay lại danh sách bằng `Esc` từ màn hình tiêu đề của một trò chơi hoặc `Q` khi nó đang tạm dừng. Nó mở toàn màn hình: `Super + F` biến nó thành một cửa sổ, và `Super + W` đóng nó.

Các trò chơi bạn tạo bằng một agent cũng xuất hiện ở đây: chọn _Make something cool → Game_ trong bảng agents và mô tả một trò, hoặc nêu tên một trò chơi đã có trong Game Vibes để tiếp tục làm việc với nó. Agent sao chép nó vào `~/Games/vibes`, nơi nó là của bạn để thay đổi, và mở nó khi hoàn thành. Bạn có thể tự tạo bản sao đó bằng `omarchy games vibes copy <game>`. Một trò chơi mà người khác chia sẻ sẽ cài đặt giống như một theme: chọn _Install > Gaming > Game Vibes_ và dán địa chỉ git của nó, hoặc chạy `omarchy games vibes install <git-repo-url>`. _Remove > Gaming_ sẽ loại bỏ một trò một lần nữa, và _Update > Game Vibes Games_ sẽ lấy các phiên bản mới. Các trò chơi tải three.js từ web, vì vậy chúng cần có một kết nối để khởi động.

## Omacalc

[Omacalc](https://github.com/omacom-io/omacalc) là máy tính cực kỳ đơn giản của chính Omarchy, mở trong một cửa sổ nổi.

Bạn khởi chạy Omacalc bằng `Super + Shift + Q` (hoặc phím máy tính, nếu bàn phím của bạn có phím đó).

## Signal

[Signal](https://signal.org/) là tiên phong của nhắn tin được mã hoá E2E, và một lựa chọn giao tiếp tuyệt vời cho bất kỳ ai muốn tránh đi qua một trong những tập đoàn công nghệ lớn.

Bạn khởi chạy Signal bằng `Super + Shift + G`. Nó không phải là một phần của bản cài đặt cơ bản, vì vậy lần đầu tiên bạn nhấn phím đó, Omarchy sẽ đề nghị cài đặt nó cho bạn (nó cũng nằm trong _Install > Service_ trong menu của Omarchy).

## Omaview

[Omaview](https://github.com/omacom/omaview) là trình xem hình ảnh và trình phát đa phương tiện cực kỳ đơn giản của chính Omarchy: một cửa sổ cho ảnh, video và nhạc của bạn. Mở một bức ảnh và các phím mũi tên sẽ bước qua phần còn lại của thư mục của nó, `N` và `P` làm điều đó cho bất cứ thứ gì, và `Ctrl + M` hiển thị toàn bộ thư mục dưới dạng một lưới. Nó cũng hiển thị ảnh HEIC, AVIF và JPEG XL, và tiếp tục từ nơi bạn đã dừng lại trong bất cứ thứ gì dài.

Nhấn `F` để toàn màn hình, `E` để chỉnh sửa một bức ảnh trong Omasnap hoặc cắt một video trong Omacut, `Ctrl + P` để in một bức ảnh, và `Delete` để di chuyển một tệp vào Trash (`Ctrl + Z` sẽ đưa nó trở lại). Nhấn `?` bên trong nó để xem mọi phím tắt.

Bạn khởi chạy Omaview dưới tên _Media Viewer_ qua trình khởi chạy ứng dụng (`Super + Space`), hoặc chỉ cần nhấp đúp vào một bức ảnh, video hoặc bài hát trong trình quản lý tệp.

## Omacut

[Omacut](https://github.com/omacom-io/omacut) là trình cắt video cực kỳ đơn giản của chính Omarchy. Khi tất cả những gì bạn cần là cắt bỏ phần đầu và phần cuối của một clip, nó hơn hẳn việc khởi động một trình chỉnh sửa video đầy đủ.

Bạn khởi chạy Omacut qua trình khởi chạy ứng dụng (`Super + Space`).

## Monologue

[Monologue](https://github.com/omacom/monologue) là trình ghi webcam cực kỳ đơn giản của chính Omarchy. Chọn máy quay và microphone của bạn một lần, rồi nhấn `Space` để ghi, và nhấn lại để tạm dừng và tiếp tục cùng một lần ghi đó. Nó luôn ghi ở độ phân giải cao nhất của máy quay của bạn, với một đồng hồ đo microphone trực tiếp để bạn có thể kiểm tra mức âm lượng của mình trước khi bắt đầu.

Dừng lần ghi và nó mở ngay trong một trình chỉnh sửa tích hợp sẵn. Nhấp đúp vào một clip để chia nó, kéo các tay nắm để cắt mỗi phần, và loại bỏ những phần bạn không muốn. Sau đó lưu nó dưới dạng một MP4. Bản ghi gốc của bạn được giữ cho đến khi bạn loại bỏ nó, vì vậy bạn luôn có thể quay lại và cắt nó theo cách khác.

Bạn khởi chạy Monologue qua trình khởi chạy ứng dụng (`Super + Space`).
