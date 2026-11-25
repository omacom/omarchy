# Windows VM

Omarchy cung cấp một cách dễ dàng để chạy Windows thông qua một Docker VM trên các máy x86_64. Bạn có thể cài đặt nó bằng _Install > Windows_ từ menu Omarchy (`Super + Space`).

Máy của bạn cần ảo hóa KVM cho việc này, mà hầu hết máy đều có — nhưng đôi khi nó bị tắt trong BIOS, và trình cài đặt sẽ cho bạn biết nếu đúng là như vậy. Bạn cũng sẽ cần dung lượng ổ đĩa: bất kỳ dung lượng nào bạn cấp cho Windows, cộng thêm khoảng 10GB cho chính image.

Trình cài đặt sẽ hỏi bạn muốn cấp bao nhiêu RAM, bao nhiêu lõi CPU và bao nhiêu dung lượng ổ đĩa (64GB trở lên là mức sàn hợp lý), rồi hỏi tên người dùng và mật khẩu Windows. Cứ để trống những trường đó và bạn sẽ có `docker` / `admin`. Việc tải xuống mất một lúc — 10-15 phút là bình thường — và bạn có thể theo dõi tiến trình trong trình duyệt tại `http://127.0.0.1:8006`. Trình duyệt sẽ yêu cầu cùng tên người dùng và mật khẩu đó trước khi mở console.

 ![windows-vm](images/windows-vm.webp)

## Sử dụng

Sau khi cài đặt xong, hãy khởi chạy _Windows_ từ app launcher. Thao tác đó sẽ khởi động VM nếu nó chưa chạy và kết nối bạn qua RDP, toàn màn hình. Hãy cho nó 15-30 giây khi khởi động nguội.

Phiên RDP mang theo âm thanh, microphone của bạn và một clipboard dùng chung, nên việc sao chép văn bản qua lại giữa Linux và Windows cứ thế là hoạt động. Độ phân giải đi theo cửa sổ của bạn, và Omarchy chuyển tiếp tỷ lệ hiển thị của bạn, nên nó không phải là một mớ mờ nhoè trên màn hình HiDPI.

Khi bạn đóng cửa sổ RDP, VM sẽ tự động tắt. Nếu bạn muốn cứ để nó chạy — chẳng hạn bạn có thứ gì đó đang làm việc ở trong đó — thay vào đó hãy khởi chạy nó bằng `omarchy windows vm launch --keep-alive`.

Các điều khiển còn lại đều nằm trên cùng một lệnh:

```bash
omarchy windows vm status    # is it running?
omarchy windows vm stop      # shut it down
omarchy windows vm launch    # start and connect
```

## Chia sẻ tệp

Thư mục `~/Windows` trong thư mục home của bạn được tự động chia sẻ với VM. Hãy đặt các tệp vào đó nếu bạn muốn chúng có thể truy cập được từ Windows. VM không có quyền truy cập vào bất kỳ phần nào khác trong hệ thống tệp của bạn, nên bạn an toàn trước bất cứ thứ gì khó chịu ở phía Windows. Ổ đĩa ảo của chính nó nằm tại `~/.windows`.

Những đường dẫn home quen thuộc đó nằm trên các filesystem riêng của chúng. Chúng cũng có thể là symlink tới các thư mục thuộc sở hữu của bạn, điều này hữu ích khi ổ đĩa ảo nằm trên một ổ đĩa lớn hơn. Trình cài đặt đo dung lượng trống trên filesystem thực sự chứa `~/.windows`, chứ không nhất thiết là filesystem chứa thư mục home của bạn.

Hãy giữ đường dẫn ổ đĩa và đường dẫn chia sẻ là các thư mục riêng biệt, không chồng chéo lên nhau. Việc gỡ bỏ cố ý làm trống thư mục ổ đĩa nhưng giữ nguyên thư mục chia sẻ. Ngay trước khi xóa, Omarchy thực hiện một kiểm tra ngăn chặn có giới hạn và từ chối xóa bất cứ thứ gì nếu kiểm tra đó hết thời gian chờ hoặc không thể chứng minh hai cây thư mục là riêng biệt.

Trước khi VM khởi động, Omarchy mở và ghim hai thư mục đó, rồi bind-mount chính xác các inode thư mục đó lên các điểm neo riêng tư theo từng người dùng bên dưới `/var/lib/omarchy/windows/mounts`. Docker chỉ nhìn thấy những điểm neo được root bảo vệ đó. Điều này giữ nguyên các vị trí ổ đĩa tùy chỉnh đồng thời ngăn một tiến trình khác chạy dưới danh nghĩa của bạn hoán đổi một đường dẫn đã được kiểm tra trước khi container có đặc quyền sử dụng nó. Các thư mục ổ đĩa và thư mục chia sẻ hiện có được siết chặt thành mode `0700` trong quá trình di chuyển để các tài khoản cục bộ khác không thể duyệt nội dung của chúng.

Các cổng của VM chỉ được liên kết với localhost, nên không có gì trên mạng của bạn có thể chạm tới máy Windows. Web console cũng yêu cầu tên người dùng và mật khẩu Windows đã cấu hình, ngăn một tài khoản cục bộ khác điều khiển VM qua cổng 8006.

## Giới hạn và cấp phép

Không có GPU passthrough với thiết lập này, nên nó không phù hợp để chơi game hay chỉnh sửa video. Nó là một cách tuyệt vời để chạy Microsoft Office hoặc bất cứ thứ gì khác mà bạn nhất định phải có.

Phiên bản được cài đặt là Windows 11 Pro, chưa kích hoạt. Bạn sẽ cần license key của riêng mình để sử dụng các tính năng bị giới hạn.

Nếu máy tính này được bán kèm Windows, OEM key vẫn còn trong firmware ngay cả sau khi cài đặt Omarchy. Hãy in nó ra bằng `omarchy windows key`. Key đó gắn với máy này — nó sẽ kích hoạt Windows được cài lại trên phần cứng này, nhưng thường sẽ không kích hoạt VM.

Bạn có thể thay đổi việc phân bổ tài nguyên sau này bằng cách chạy `omarchy windows vm install` trong terminal, lệnh này sẽ viết lại cấu hình của VM từ các câu trả lời của bạn. Bản thân compose file giờ nằm tại `/var/lib/omarchy/windows/docker-compose.yml` và thuộc sở hữu của root — đó là có chủ ý, để một tiến trình chạy dưới danh nghĩa của bạn không thể viết lại nó và khiến quá trình khởi động có đặc quyền mount toàn bộ ổ đĩa của bạn vào container. Nếu bạn cần chỉnh sửa thủ công (ví dụ để mount một thiết bị USB), hãy sửa nó bằng `sudo` và xem mọi tùy chọn trên [dự án Dockur Windows](https://github.com/dockur/windows).

Để loại bỏ toàn bộ thứ này, hãy dùng _Remove > Windows_ từ menu Omarchy. Thao tác đó sẽ xóa ổ đĩa của VM trong `~/.windows` và mọi thứ đã cài đặt bên trong Windows, nên hãy sao chép bất cứ thứ gì bạn cần ra khỏi VM trước. Thư mục `~/Windows` dùng chung của bạn sẽ được để yên.
