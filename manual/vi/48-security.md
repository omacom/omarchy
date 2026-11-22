# Bảo mật

Omarchy cực kỳ nghiêm túc về bảo mật. Đây phải là một hệ điều hành bạn có thể dùng để làm _Real Work_ trong _Real World_. Nơi việc đánh mất một chiếc laptop không thể dẫn tới một tình huống khẩn cấp về bảo mật. Vì vậy, đây là những gì chúng tôi làm:

1. *Mã hóa toàn bộ đĩa được bật mặc định*: Đây là bước quan trọng nhất để bảo vệ dữ liệu của bạn về mặt vật lý. Nếu máy tính của bạn bị mất hoặc bị đánh cắp, dữ liệu được mã hóa hoàn toàn bằng LUKS (Linux Unified Key Setup) tiêu chuẩn. Trình cài đặt cho phép bạn từ chối trên các máy dùng rồi bỏ (xem [Bắt đầu](02-getting-started.md)); một bản cài đặt không có mã hóa sẽ không có lớp bảo vệ này, và bất kỳ ai cầm ổ đĩa đều có thể đọc được nó.
2. *Tường lửa được bật mặc định*: Mọi lưu lượng đến đều bị chặn mặc định, với một vài ngoại lệ: cổng 53317 cho [LocalSend](https://localsend.org/); các truy vấn DNS tới trình phân giải của chính máy tính tại địa chỉ Docker bridge (172.17.0.1), được chấp nhận từ các dải địa chỉ riêng mà Docker cấp cho các container của nó; và multicast DNS (cổng 5353), cho phép máy in và các thiết bị khác trên mạng của bạn tìm thấy nhau và cũng thông báo tên máy tính của bạn ở đó. Ngoài những trường hợp đó, tường lửa vẫn giữ các cho phép tiêu chuẩn của UFW cho ping, lấy địa chỉ từ router của bạn (DHCP), và khám phá UPnP. Ngay cả ssh cũng tắt cho tới khi bạn bật nó qua _Setup > Security > SSHD_, thao tác này ủy quyền SSH key của bạn, tắt đăng nhập bằng mật khẩu, và chỉ khi đó mới mở cổng 22 (giới hạn tốc độ để chống brute force). Chúng tôi thậm chí còn khóa quyền truy cập Docker bằng thiết lập [ufw-docker](https://github.com/chaifeng/ufw-docker) để ngăn các container của bạn vô tình bị lộ ra ngoài thế giới.
3. *Arch luôn có các bản cập nhật mới nhất*: Arch, bản phân phối nền tảng mà Omarchy được xây dựng trên đó, là một bản phân phối rolling. Điều đó có nghĩa là bất kỳ lỗ hổng bảo mật nào được phát hiện và vá trong bất kỳ gói nào cũng nhanh chóng có sẵn để cài đặt bằng `omarchy-update`. Nhờ vậy, bạn luôn chạy các phiên bản mới nhất, an toàn nhất của mọi thứ.
4. *Omarchy duy trì các gói và mirror của riêng mình*: Mặc định, Omarchy chỉ dựa vào các gói từ các kho core/extra/multilib của chính Arch (của Arch Linux ARM trên các máy ARM, cộng thêm Asahi ALARM trên Apple Silicon) và Omarchy Package Repository của riêng mình. Bạn có thể cài đặt phần mềm trực tiếp từ AUR, nhưng bản cài đặt cơ bản thì không — chỉ một vài bản cài đặt tùy chọn, như các trình duyệt của bên thứ ba, mới lấy từ AUR.
5. *Cloudflare bảo vệ chúng tôi khỏi DDoS*: Hạ tầng phân phối của Omarchy — các ISO, các gói Omarchy, Arch mirror — được bảo vệ sau lá chắn DDoS đáng gờm của Cloudflare và được lưu trữ trên CDN của họ. Điều này mang lại độ sẵn sàng tuyệt vời.

## Thay đổi mật khẩu của bạn

Bạn có hai mật khẩu trên một bản cài đặt đã mã hóa: mật khẩu mở khóa ổ đĩa lúc khởi động, và mật khẩu bạn dùng để đăng nhập và `sudo`. Setup đặt chúng giống nhau. Cả hai đều có thể thay đổi trong _Update > Password_ ở menu Omarchy — _Drive Encryption_ cho mật khẩu đầu tiên, _User_ cho mật khẩu thứ hai. Việc thay đổi mật khẩu ổ đĩa sẽ yêu cầu mật khẩu hiện tại trước, vì vậy hãy chuẩn bị sẵn. Nếu việc thay đổi bị gián đoạn, hãy chạy lại _Drive Encryption_: nó sẽ yêu cầu mật khẩu mở khóa ổ đĩa hiện tại và hoàn tất việc thay đổi.

## Chuyển giao một máy bạn đã sử dụng

Nếu bạn bàn giao máy của mình cho người khác, bạn không phải cài đặt lại. Hãy chạy _Remove > Factory Reset_ trong menu Omarchy, gõ `reset` để xác nhận, nhập mật khẩu mã hóa ổ đĩa nếu được yêu cầu, và khởi động lại. Thao tác đó xóa mọi tài khoản người dùng và mọi thứ trong `/home`, loại bỏ tất cả các gói và thay đổi hệ thống bạn đã thực hiện kể từ khi cài đặt, và xóa sạch danh tính của máy — các kết nối mạng, host keys, và tất cả. Thứ khởi động trở lại là trình hướng dẫn thiết lập từ lần khởi động đầu tiên, sẵn sàng cho chủ sở hữu mới nhập tên, mật khẩu, và mật khẩu mã hóa của riêng họ.

Nó hoạt động bằng cách khôi phục snapshot nền tảng mà trình cài đặt tạo ra, vì vậy nó chỉ có sẵn trên các máy được cài đặt từ Omarchy ISO. Và trên một ổ đĩa không có mã hóa, việc đặt lại là xóa bỏ chứ không phải xóa an toàn, vì vậy nếu dữ liệu nhạy cảm, hãy cài đặt mới thay vào đó.

## sudo không cần mật khẩu

Đôi khi bạn muốn `sudo` ngừng hỏi, thường nhất là khi một AI agent đang làm một đợt công việc hệ thống dài cho bạn. _Setup > Security > Passwordless Sudo_ hỏi bạn muốn cho phép truy cập trong bao lâu: **15 minutes**, **1 Hour**, **1 Day**, hoặc **Permanently**. Một biểu tượng cảnh báo màu đỏ xuất hiện bên cạnh các chỉ báo khác trên thanh menu trong khi quyền truy cập đang hoạt động. Nhấp vào nó hoặc chạy lại lệnh để tắt quyền truy cập. Bạn cũng có thể truyền số phút của riêng mình (từ 1 tới 1440) bằng `omarchy-sudo-passwordless 30`, hoặc dùng `omarchy-sudo-passwordless permanent`.

Quyền truy cập có thời hạn sẽ tự động hết hạn, bao gồm ngay sau khi tiếp tục từ trạng thái tạm dừng đã vượt qua thời hạn. Việc khởi động lại máy tính sẽ kết thúc nó sớm. Quyền truy cập vĩnh viễn vẫn tồn tại qua các lần khởi động lại và duy trì cho tới khi bạn tắt nó.

Việc cập nhật hoặc gỡ bỏ gói cài đặt của Omarchy sẽ kết thúc mọi cấp quyền tạm thời trước khi hỗ trợ hết hạn của nó thay đổi. Nếu lệnh báo lỗi ủy quyền hoặc lỗi dọn dẹp, hãy giải quyết nó trước khi cố bật một cấp quyền khác; một lỗi không có nghĩa là quyền truy cập không cần mật khẩu đang không hoạt động.

Hãy tỉnh táo về điều này: trong khi nó đang bật, bất kỳ thứ gì chạy dưới người dùng của bạn đều có thể làm bất cứ điều gì với quyền root mà không bị hỏi. Đó là toàn bộ mục đích, và đó cũng là toàn bộ rủi ro.

## Khóa ký

Khóa công khai cho mọi chữ ký ISO và gói của kho Omarchy là `40DFB630FF42BCFFB047046CF0134EE680CAC571` ([xác minh tại openpgp.org](https://keys.openpgp.org/search?q=pkgs%40omarchy.org)). Gói `omarchy/omarchy-keyring` cũng chứa khóa này và sẽ được dùng để triển khai mọi bản cập nhật tiềm năng một cách liền mạch.

Bạn có thể tìm chữ ký cho bất kỳ bản phát hành ISO nào bằng cách thêm `.sig` vào URL của nó, như `https://iso.omarchy.org/omarchy-x.x.x.iso.sig`.
