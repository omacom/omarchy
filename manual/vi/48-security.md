# Bảo mật

Omarchy cực kỳ nghiêm túc về bảo mật. Đây là một hệ điều hành được thiết kế để bạn có thể dùng để làm _Công Việc Thực Sự_ trong _Thế Giới Thực_. Nơi việc đánh mất một chiếc laptop không thể dẫn đến một tình huống khẩn cấp về bảo mật. Vì vậy, đây là những gì chúng tôi làm:

1. *Mã hóa toàn bộ đĩa được bật theo mặc định*: Đây là bước quan trọng nhất để bảo vệ dữ liệu của bạn về mặt vật lý. Nếu máy tính của bạn bị mất hoặc bị đánh cắp, dữ liệu được mã hóa hoàn toàn bằng LUKS (Linux Unified Key Setup) tiêu chuẩn. Trình cài đặt cho phép bạn chọn không dùng tính năng này đối với những máy dùng xong rồi bỏ (xem [Bắt đầu](02-getting-started.md)); một bản cài đặt không có mã hóa sẽ không có lớp bảo vệ này, và bất kỳ ai cầm ổ đĩa đều có thể đọc nó.
2. *Tường lửa được bật theo mặc định*: Mọi lưu lượng đến đều bị chặn theo mặc định, với một vài ngoại lệ: cổng 53317 cho [LocalSend](https://localsend.org/); các truy vấn DNS tới trình phân giải của chính máy tính tại địa chỉ Docker bridge (172.17.0.1), được chấp nhận từ các dải địa chỉ riêng mà Docker cấp cho các container của nó; và multicast DNS (cổng 5353), tính năng này cho phép máy in và các thiết bị khác trên mạng của bạn tìm thấy nhau và cũng thông báo tên máy tính của bạn ở đó. Ngoài những trường hợp đó, tường lửa vẫn giữ các cho phép tiêu chuẩn của UFW đối với ping, việc nhận địa chỉ từ router của bạn (DHCP), và khám phá UPnP. Ngay cả ssh cũng tắt cho đến khi bạn bật nó qua _Setup > Security > SSHD_, bước này cấp quyền cho SSH key của bạn, tắt đăng nhập bằng mật khẩu, và chỉ sau đó mới mở cổng 22 (được giới hạn tốc độ để chống brute force). Chúng tôi thậm chí còn khóa chặt quyền truy cập Docker bằng thiết lập [ufw-docker](https://github.com/chaifeng/ufw-docker) để ngăn các container của bạn vô tình bị lộ ra ngoài thế giới.
3. *Arch luôn có các bản cập nhật mới nhất*: Arch, bản phân phối nền tảng mà Omarchy được xây dựng trên đó, là một bản phân phối rolling. Điều này có nghĩa là bất kỳ lỗ hổng bảo mật nào được phát hiện và vá trong bất kỳ gói nào cũng sẽ nhanh chóng sẵn sàng để cài đặt bằng `omarchy-update`. Bằng cách đó, bạn luôn chạy các phiên bản mới nhất, an toàn nhất của mọi thứ.
4. *Omarchy tự duy trì các gói và mirror của riêng mình*: Theo mặc định, Omarchy chỉ dựa vào các gói từ các kho core/extra/multilib của chính Arch (Arch Linux ARM trên các máy ARM, cộng với Asahi ALARM trên Apple Silicon) và Omarchy Package Repository của riêng nó. Bạn có thể cài đặt phần mềm trực tiếp từ AUR, nhưng bản cài đặt cơ sở thì không — chỉ một vài bản cài đặt tùy chọn, như các trình duyệt của bên thứ ba, mới lấy từ AUR.
5. *Cloudflare bảo vệ chúng tôi khỏi DDoS*: Cơ sở hạ tầng phân phối của Omarchy — các ISO, các gói Omarchy, Arch mirror — được bảo vệ sau lá chắn DDoS đáng gờm của Cloudflare và được lưu trữ trên CDN của họ. Điều này mang lại khả năng sẵn sàng tuyệt vời.

## Thay đổi mật khẩu của bạn

Trên một bản cài đặt có mã hóa, bạn có hai mật khẩu: một mật khẩu để mở khóa ổ đĩa khi khởi động, và một mật khẩu bạn dùng để đăng nhập và `sudo`. Quá trình thiết lập đặt chúng giống nhau. _Update > Password_ trong menu Omarchy thay đổi cả hai cùng lúc, vì vậy chúng vẫn giống nhau: nó yêu cầu mật khẩu ổ đĩa hiện tại, sau đó là mật khẩu mới, thay đổi mật khẩu của ổ đĩa rồi đặt mật khẩu đăng nhập của bạn cho khớp. Nếu không có mã hóa ổ đĩa, nó chỉ thay đổi mật khẩu đăng nhập của bạn. Nếu một lần thay đổi bị gián đoạn, hãy chạy lại _Update > Password_: nó sẽ yêu cầu mật khẩu hiện đang mở khóa ổ đĩa, hoàn tất việc thay đổi, và đặt mật khẩu đăng nhập của bạn thành mật khẩu đó. Để thay đổi mật khẩu của một ổ đĩa đã mã hóa khác, hãy chạy `omarchy-drive-password` trong một terminal.

## Bàn giao một chiếc máy bạn đã sử dụng

Nếu bạn đang bàn giao máy của mình cho người khác, bạn không cần phải cài đặt lại. Hãy chạy _Remove > Factory Reset_ trong menu Omarchy, gõ `reset` để xác nhận, nhập mật khẩu mã hóa ổ đĩa của bạn nếu được yêu cầu, và khởi động lại. Thao tác đó xóa mọi tài khoản người dùng và mọi thứ trong `/home`, loại bỏ tất cả các gói và thay đổi hệ thống bạn đã thực hiện kể từ khi cài đặt, và xóa danh tính của máy — các kết nối mạng, host keys, và tất cả. Thứ khởi động trở lại là trình hướng dẫn thiết lập từ lần khởi động đầu tiên, sẵn sàng để chủ sở hữu mới nhập tên, mật khẩu và mật khẩu mã hóa của riêng họ.

Tính năng này hoạt động bằng cách khôi phục snapshot cơ sở mà trình cài đặt tạo ra, vì vậy nó chỉ khả dụng trên các máy được cài đặt từ Omarchy ISO. Và trên một ổ đĩa không có mã hóa, việc đặt lại là xóa chứ không phải là xóa an toàn, vì vậy nếu dữ liệu nhạy cảm, hãy thực hiện cài đặt mới thay thế.

## sudo không cần mật khẩu

Đôi khi bạn muốn `sudo` ngừng yêu cầu mật khẩu, thường nhất là khi một AI agent đang thực hiện một đoạn dài công việc hệ thống cho bạn. _Setup > Security > Passwordless Sudo_ hỏi bạn muốn cho phép truy cập trong bao lâu: **15 minutes**, **1 Hour**, **1 Day**, hoặc **Permanently**. Một biểu tượng cảnh báo màu đỏ xuất hiện bên cạnh các chỉ báo khác trên thanh menu trong khi quyền truy cập đang hoạt động. Nhấp vào nó hoặc chạy lại lệnh để tắt quyền truy cập. Bạn cũng có thể truyền số phút của riêng mình (từ 1 đến 1440) bằng `omarchy-sudo-passwordless 30`, hoặc dùng `omarchy-sudo-passwordless permanent`.

Quyền truy cập có thời hạn sẽ tự động hết hạn, bao gồm ngay sau khi tiếp tục từ trạng thái tạm dừng đã vượt qua thời hạn. Khởi động lại máy tính sẽ kết thúc nó sớm. Quyền truy cập vĩnh viễn vẫn tồn tại qua các lần khởi động lại và vẫn được bật cho đến khi bạn tắt nó.

Việc cập nhật hoặc gỡ bỏ gói cài đặt của Omarchy sẽ kết thúc mọi cấp quyền tạm thời trước khi hỗ trợ hết hạn của nó thay đổi. Nếu lệnh báo lỗi về cấp quyền hoặc dọn dẹp, hãy giải quyết nó trước khi cố gắng bật một cấp quyền khác; một lỗi không có nghĩa là quyền truy cập không cần mật khẩu đang không hoạt động.

Hãy tỉnh táo về điều này: trong khi nó đang bật, bất kỳ thứ gì chạy dưới người dùng của bạn đều có thể làm bất kỳ điều gì dưới quyền root mà không cần được hỏi. Đó là toàn bộ mục đích, và đó cũng là toàn bộ rủi ro.

## Khóa ký

Khóa công khai cho tất cả các chữ ký ISO và gói của kho Omarchy là `40DFB630FF42BCFFB047046CF0134EE680CAC571` ([xác minh tại openpgp.org](https://keys.openpgp.org/search?q=pkgs%40omarchy.org)). Gói `omarchy/omarchy-keyring` cũng chứa khóa này và sẽ được dùng để triển khai mọi bản cập nhật tiềm năng một cách liền mạch.

Bạn có thể tìm chữ ký cho bất kỳ bản phát hành ISO nào bằng cách thêm `.sig` vào URL của nó, như `https://iso.omarchy.org/omarchy-x.x.x.iso.sig`.
