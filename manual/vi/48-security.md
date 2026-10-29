# Bảo mật

Omarchy cực kỳ nghiêm túc về bảo mật. Đây là một hệ điều hành để bạn làm _Real Work_ trong _Real World_. Nơi đánh mất một chiếc laptop không thể trở thành một tình huống khẩn cấp về bảo mật. Sau đây là những gì chúng tôi làm:

1. *Mã hóa toàn bộ đĩa là bắt buộc*: Đây là bước quan trọng nhất để bảo vệ dữ liệu của bạn về mặt vật lý. Nếu máy tính bị thất lạc hoặc bị đánh cắp, dữ liệu được mã hóa hoàn toàn bằng LUKS (Linux Unified Key Setup) tiêu chuẩn.
2. *Tường lửa được bật mặc định*: Mọi lưu lượng đến đều bị chặn mặc định, ngoại trừ cổng 53317 cho [LocalSend](https://localsend.org/). Ngay cả ssh cũng tắt cho đến khi bạn bật nó qua _Setup > Security > SSHD_, thao tác này mở cổng 22 (có giới hạn tốc độ để chống brute force) như một phần của quá trình thiết lập. Chúng tôi thậm chí còn khóa quyền truy cập Docker bằng thiết lập [ufw-docker](https://github.com/chaifeng/ufw-docker) để ngăn các container của bạn vô tình bị lộ ra bên ngoài.
3. *Arch luôn có các bản cập nhật mới nhất*: Arch, distro nền tảng mà Omarchy được xây dựng trên đó, là một bản phân phối rolling. Điều này có nghĩa là bất kỳ lỗ hổng bảo mật nào được phát hiện và vá trong bất kỳ gói nào cũng nhanh chóng có sẵn để cài đặt bằng `omarchy-update`. Bằng cách đó, bạn luôn chạy các phiên bản mới nhất và an toàn nhất của mọi thứ.
4. *Omarchy tự duy trì các gói và mirror của riêng mình*: Mặc định, Omarchy chỉ dựa vào các gói từ các repository core/extra/multilib của chính Arch và Omarchy Package Repository của riêng mình. Bạn có thể cài đặt phần mềm trực tiếp từ AUR, nhưng bản cài đặt cơ sở thì không — chỉ một vài cài đặt tùy chọn, như các trình duyệt của bên thứ ba, mới lấy từ AUR.
5. *Cloudflare bảo vệ chúng tôi khỏi DDoS*: Hạ tầng phân phối của Omarchy — các ISO, các gói Omarchy, mirror của Arch — được bảo vệ sau lá chắn DDoS đáng gờm của Cloudflare và được lưu trữ trên CDN của họ. Điều này mang lại khả năng sẵn sàng tuyệt vời.

## Đổi mật khẩu của bạn

Trên một bản cài đặt đã mã hóa, bạn có hai mật khẩu: một mật khẩu để mở khóa ổ đĩa khi khởi động, và một mật khẩu bạn dùng để đăng nhập và `sudo`. Setup đặt chúng giống nhau. Cả hai đều có thể thay đổi trong _Update > Password_ ở menu Omarchy — _Drive Encryption_ cho mật khẩu đầu tiên, _User_ cho mật khẩu thứ hai. Việc đổi mật khẩu ổ đĩa sẽ yêu cầu mật khẩu hiện tại trước, vì vậy hãy chuẩn bị sẵn. Nếu việc thay đổi bị gián đoạn, hãy chạy lại _Drive Encryption_: nó sẽ yêu cầu mật khẩu mở khóa ổ đĩa hiện tại và hoàn tất việc thay đổi.

## Chuyển giao một chiếc máy bạn đã sử dụng

Nếu bạn trao máy của mình cho người khác, bạn không cần phải cài đặt lại. Chạy _Setup > Reset Computer_ trong menu Omarchy, gõ `reset` để xác nhận, rồi khởi động lại. Thao tác đó xóa mọi tài khoản người dùng và mọi thứ trong `/home`, loại bỏ tất cả các gói và thay đổi hệ thống bạn đã thực hiện kể từ khi cài đặt, và xóa danh tính của máy — các kết nối mạng, host key, và tất cả. Thứ hiện lên sau đó là trình hướng dẫn thiết lập từ lần khởi động đầu tiên, sẵn sàng để chủ sở hữu mới nhập tên, mật khẩu và mật khẩu mã hóa của riêng họ.

Nó hoạt động bằng cách khôi phục snapshot cơ sở mà trình cài đặt tạo ra, vì vậy nó chỉ khả dụng trên các máy được cài đặt từ ISO của Omarchy. Và trên một ổ đĩa không có mã hóa, việc đặt lại là xóa bỏ chứ không phải xóa an toàn, vì vậy nếu dữ liệu nhạy cảm, hãy cài đặt mới thay vào đó.

## sudo không cần mật khẩu

Đôi khi bạn muốn `sudo` ngừng hỏi, thường nhất là khi một AI agent đang thực hiện một đoạn công việc hệ thống dài cho bạn. _Setup > Security > Passwordless Sudo_ hỏi bạn muốn cho phép truy cập trong bao lâu: **15 phút**, **1 giờ**, **1 ngày**, hoặc **Vĩnh viễn**. Một biểu tượng cảnh báo màu đỏ xuất hiện bên cạnh các chỉ báo khác trên thanh menu trong khi quyền truy cập đang hoạt động. Nhấp vào nó hoặc chạy lại lệnh để tắt quyền truy cập. Bạn cũng có thể truyền số phút của riêng mình (từ 1 đến 1440) bằng `omarchy-sudo-passwordless 30`, hoặc dùng `omarchy-sudo-passwordless permanent`.

Quyền truy cập có thời hạn tự động hết hạn, bao gồm ngay sau khi tiếp tục từ trạng thái suspend đã vượt qua thời hạn. Khởi động lại máy tính sẽ kết thúc nó sớm. Quyền truy cập vĩnh viễn vẫn còn sau khi khởi động lại và vẫn được bật cho đến khi bạn tắt nó.

Việc cập nhật hoặc gỡ bỏ gói settings của Omarchy sẽ kết thúc mọi cấp quyền tạm thời trước khi hỗ trợ hết hạn của nó thay đổi. Nếu lệnh báo lỗi ủy quyền hoặc lỗi dọn dẹp, hãy giải quyết nó trước khi cố bật một cấp quyền khác; một lỗi không có nghĩa là quyền truy cập không cần mật khẩu đang không hoạt động.

Hãy tỉnh táo về điều này: trong khi nó đang bật, bất cứ thứ gì chạy dưới người dùng của bạn đều có thể làm bất cứ điều gì với quyền root mà không cần hỏi. Đó là toàn bộ mục đích, và đó cũng là toàn bộ rủi ro.

## Khóa ký

Khóa công khai cho mọi chữ ký ISO và gói repo của Omarchy là `40DFB630FF42BCFFB047046CF0134EE680CAC571` ([xác minh tại openpgp.org](https://keys.openpgp.org/search?q=pkgs%40omarchy.org)). Gói `omarchy/omarchy-keyring` cũng chứa khóa này và sẽ được dùng để triển khai mọi bản cập nhật tiềm năng một cách liền mạch.

Bạn có thể tìm chữ ký cho bất kỳ bản phát hành ISO nào bằng cách thêm `.sig` vào URL của nó, như `https://iso.omarchy.org/omarchy-x.x.x.iso.sig`.
