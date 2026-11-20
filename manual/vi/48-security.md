# Bảo mật

Omarchy cực kỳ coi trọng bảo mật. Đây là một hệ điều hành được tạo ra để bạn có thể dùng cho _Công Việc Thực Sự_ trong _Thế Giới Thực_. Nơi việc mất một chiếc laptop không thể dẫn đến một tình huống khẩn cấp về bảo mật. Vì vậy, đây là những gì chúng tôi làm:

1. *Mã hóa toàn bộ đĩa được bật theo mặc định*: Đây là bước quan trọng nhất để bảo vệ dữ liệu của bạn về mặt vật lý. Nếu máy tính của bạn bị mất hoặc bị đánh cắp, dữ liệu sẽ được mã hóa hoàn toàn bằng LUKS (Linux Unified Key Setup) tiêu chuẩn. Trình cài đặt cho phép bạn từ chối trên các máy dùng xong rồi bỏ (xem [Bắt đầu](02-getting-started.md)); một bản cài đặt không có mã hóa sẽ không có lớp bảo vệ này, và bất kỳ ai cầm ổ đĩa đều có thể đọc được nó.
2. *Tường lửa được bật theo mặc định*: Mọi lưu lượng truy cập đến đều bị chặn theo mặc định, với một vài ngoại lệ: cổng 53317 cho [LocalSend](https://localsend.org/); các truy vấn DNS tới trình phân giải tên miền của chính máy tính tại địa chỉ cầu nối Docker (172.17.0.1), được chấp nhận từ các dải địa chỉ riêng tư mà Docker cấp cho các container của nó; và multicast DNS (cổng 5353), cho phép máy in và các thiết bị khác trên mạng của bạn tìm thấy nhau, đồng thời cũng thông báo tên máy tính của bạn ở đó. Ngoài những trường hợp đó, tường lửa vẫn giữ các cho phép tiêu chuẩn của UFW cho ping, nhận địa chỉ từ router của bạn (DHCP), và khám phá UPnP. Ngay cả ssh cũng tắt cho đến khi bạn bật nó qua _Setup > Security > SSHD_, việc này sẽ mở cổng 22 (được giới hạn tốc độ để chống brute force) như một phần của quá trình thiết lập. Chúng tôi thậm chí còn khóa chặt quyền truy cập Docker bằng thiết lập [ufw-docker](https://github.com/chaifeng/ufw-docker) để ngăn các container của bạn vô tình bị phơi bày ra thế giới bên ngoài.
3. *Arch luôn có các bản cập nhật mới nhất*: Arch, bản phân phối nền tảng mà Omarchy được xây dựng trên đó, là một bản phân phối rolling. Điều này có nghĩa là bất kỳ lỗ hổng bảo mật nào được phát hiện và vá trong bất kỳ gói nào cũng sẽ nhanh chóng có sẵn để cài đặt bằng `omarchy-update`. Bằng cách đó, bạn luôn chạy các phiên bản mới nhất, an toàn nhất của mọi thứ.
4. *Omarchy duy trì các gói và mirror của riêng mình*: Theo mặc định, Omarchy chỉ dựa vào các gói từ các kho core/extra/multilib của chính Arch và Omarchy Package Repository của riêng mình. Bạn có thể cài đặt phần mềm trực tiếp từ AUR, nhưng bản cài đặt cơ sở thì không — chỉ một vài bản cài đặt tùy chọn, như các trình duyệt của bên thứ ba, mới lấy từ AUR.
5. *Cloudflare bảo vệ chúng tôi khỏi DDoS*: Cơ sở hạ tầng phân phối của Omarchy — các ISO, các gói Omarchy, mirror của Arch — được bảo vệ sau lá chắn DDoS đáng gờm của Cloudflare và được lưu trữ trên CDN của họ. Điều này mang lại khả năng sẵn sàng tuyệt vời.

## Thay đổi mật khẩu của bạn

Bạn có hai mật khẩu trên một bản cài đặt đã mã hóa: một mật khẩu dùng để mở khóa ổ đĩa khi khởi động, và một mật khẩu bạn dùng để đăng nhập và `sudo`. Quá trình thiết lập đặt chúng giống nhau. Cả hai đều có thể được thay đổi trong _Update > Password_ ở menu Omarchy — _Drive Encryption_ cho mật khẩu đầu tiên, _User_ cho mật khẩu thứ hai. Việc thay đổi mật khẩu ổ đĩa sẽ yêu cầu mật khẩu hiện tại trước, vì vậy hãy chuẩn bị sẵn. Nếu một thay đổi bị gián đoạn, hãy chạy lại _Drive Encryption_: nó sẽ yêu cầu mật khẩu mở khóa ổ đĩa hiện tại và hoàn tất thay đổi.

## Chuyển giao một máy bạn đã sử dụng

Nếu bạn đang bàn giao máy của mình cho người khác, bạn không cần phải cài đặt lại. Hãy chạy _Remove > Factory Reset_ trong menu Omarchy, nhập `reset` để xác nhận, và khởi động lại. Việc này sẽ xóa mọi tài khoản người dùng và mọi thứ trong `/home`, loại bỏ tất cả các gói và thay đổi hệ thống bạn đã thực hiện kể từ khi cài đặt, và xóa danh tính của máy — các kết nối mạng, host keys, và tất cả. Thứ quay trở lại sẽ là trình hướng dẫn thiết lập từ lần khởi động đầu tiên, sẵn sàng cho chủ sở hữu mới nhập tên, mật khẩu, và mật khẩu mã hóa của riêng họ.

Nó hoạt động bằng cách khôi phục snapshot cơ sở mà trình cài đặt đã tạo, vì vậy nó chỉ có sẵn trên các máy được cài đặt từ ISO của Omarchy. Và trên một ổ đĩa không có mã hóa, việc reset là xóa bỏ chứ không phải xóa an toàn, vì vậy nếu dữ liệu nhạy cảm, hãy cài đặt mới thay vào đó.

## Sudo không cần mật khẩu

Đôi khi bạn muốn `sudo` ngừng hỏi, thường nhất là khi một AI agent đang thực hiện một đoạn dài công việc hệ thống cho bạn. _Setup > Security > Passwordless Sudo_ sẽ hỏi cho phép truy cập trong bao lâu: **15 minutes**, **1 Hour**, **1 Day**, hoặc **Permanently**. Một biểu tượng cảnh báo màu đỏ xuất hiện bên cạnh các chỉ báo khác trên thanh menu trong khi quyền truy cập đang hoạt động. Nhấp vào nó hoặc chạy lại lệnh để tắt quyền truy cập. Bạn cũng có thể truyền số phút của riêng mình (từ 1 đến 1440) bằng `omarchy-sudo-passwordless 30`, hoặc dùng `omarchy-sudo-passwordless permanent`.

Quyền truy cập có thời hạn sẽ tự động hết hạn, bao gồm ngay sau khi tiếp tục từ trạng thái tạm dừng đã vượt qua thời hạn. Khởi động lại máy tính sẽ kết thúc nó sớm. Quyền truy cập vĩnh viễn vẫn tồn tại qua các lần khởi động lại và duy trì cho đến khi bạn tắt nó.

Việc cập nhật hoặc gỡ bỏ gói cài đặt của Omarchy sẽ kết thúc mọi cấp quyền tạm thời trước khi hỗ trợ hết hạn của nó thay đổi. Nếu lệnh báo lỗi ủy quyền hoặc lỗi dọn dẹp, hãy giải quyết nó trước khi cố gắng bật một cấp quyền khác; một lỗi không có nghĩa là quyền truy cập không cần mật khẩu đang không hoạt động.

Hãy tỉnh táo về điều này: trong khi nó đang bật, bất kỳ thứ gì chạy dưới người dùng của bạn đều có thể làm bất cứ điều gì với quyền root mà không cần được hỏi. Đó là toàn bộ mục đích, và đó cũng là toàn bộ rủi ro.

## Khóa ký

Khóa công khai cho tất cả các chữ ký ISO và gói của kho Omarchy là `40DFB630FF42BCFFB047046CF0134EE680CAC571` ([xác minh tại openpgp.org](https://keys.openpgp.org/search?q=pkgs%40omarchy.org)). Gói `omarchy/omarchy-keyring` cũng chứa khóa này và sẽ được dùng để triển khai mọi bản cập nhật tiềm năng một cách liền mạch.

Bạn có thể tìm chữ ký cho bất kỳ bản phát hành ISO nào bằng cách thêm `.sig` vào URL của nó, như `https://iso.omarchy.org/omarchy-x.x.x.iso.sig`.
