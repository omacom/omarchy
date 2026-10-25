# Bảo mật

Omarchy cực kỳ nghiêm túc về bảo mật. Đây phải là một hệ điều hành mà bạn có thể dùng để làm _Công Việc Thực Sự_ trong _Thế Giới Thực_. Nơi việc đánh mất một chiếc laptop không thể dẫn đến một tình huống khẩn cấp về bảo mật. Vì vậy đây là những gì chúng tôi làm:

1. *Mã hóa toàn bộ ổ đĩa là bắt buộc*: Đây là bước quan trọng nhất để bảo vệ dữ liệu của bạn về mặt vật lý. Nếu máy tính của bạn bị mất hoặc bị đánh cắp, dữ liệu sẽ được mã hóa hoàn toàn bằng LUKS (Linux Unified Key Setup) tiêu chuẩn.
2. *Tường lửa được bật theo mặc định*: Mọi lưu lượng đến đều bị chặn theo mặc định, ngoại trừ cổng 53317 cho [LocalSend](https://localsend.org/). Ngay cả ssh cũng tắt cho đến khi bạn bật nó qua _Setup > Security > SSHD_, việc này sẽ mở cổng 22 (được giới hạn tốc độ để chống brute force) như một phần của quá trình cài đặt. Chúng tôi thậm chí còn khóa chặt quyền truy cập Docker bằng thiết lập [ufw-docker](https://github.com/chaifeng/ufw-docker) để ngăn các container của bạn vô tình bị lộ ra thế giới bên ngoài.
3. *Arch luôn có các bản cập nhật mới nhất*: Arch, bản phân phối nền tảng mà Omarchy được xây dựng trên đó, là một bản phân phối rolling. Điều này có nghĩa là bất kỳ lỗ hổng bảo mật nào được phát hiện và vá trong bất kỳ gói nào cũng sẽ nhanh chóng có sẵn để cài đặt bằng `omarchy-update`. Bằng cách đó, bạn luôn chạy các phiên bản mới nhất, an toàn nhất của mọi thứ.
4. *Omarchy duy trì các gói và mirror của riêng mình*: Theo mặc định, Omarchy chỉ dựa vào các gói từ các kho core/extra/multilib của chính Arch và Omarchy Package Repository của riêng mình. Bạn có thể cài đặt phần mềm trực tiếp từ AUR, nhưng bản cài đặt cơ sở thì không — chỉ một vài bản cài đặt tùy chọn, như các trình duyệt của bên thứ ba, mới lấy từ AUR.
5. *Cloudflare bảo vệ chúng tôi khỏi DDoS*: Hạ tầng phân phối của Omarchy — các ISO, các gói Omarchy, mirror của Arch — được bảo vệ phía sau lá chắn DDoS đáng gờm của Cloudflare và được lưu trữ trên CDN của họ. Điều này mang lại tính sẵn sàng tuyệt vời.

## Thay đổi mật khẩu của bạn

Bạn có hai mật khẩu trên một bản cài đặt đã mã hóa: một mật khẩu mở khóa ổ đĩa khi khởi động, và một mật khẩu bạn dùng để đăng nhập và `sudo`. Quá trình cài đặt đặt chúng giống nhau. Cả hai đều có thể được thay đổi trong _Update > Password_ ở menu Omarchy — _Drive Encryption_ cho mật khẩu đầu tiên, _User_ cho mật khẩu thứ hai. Việc thay đổi mật khẩu ổ đĩa sẽ yêu cầu mật khẩu hiện tại trước, vì vậy hãy chuẩn bị sẵn nó. Nếu một thay đổi bị gián đoạn, hãy chạy lại _Drive Encryption_: nó sẽ yêu cầu mật khẩu hiện đang mở khóa ổ đĩa và hoàn tất thay đổi.

## Chuyển giao một chiếc máy bạn đã dùng

Nếu bạn đang trao máy của mình cho người khác, bạn không cần phải cài đặt lại. Chạy _Setup > Reset Computer_ trong menu Omarchy, gõ `reset` để xác nhận, và khởi động lại. Việc đó sẽ xóa mọi tài khoản người dùng và mọi thứ trong `/home`, loại bỏ tất cả các gói và thay đổi hệ thống bạn đã thực hiện kể từ khi cài đặt, và xóa danh tính của máy — các kết nối mạng, host keys, và tất cả. Thứ hiện lên sau đó là trình hướng dẫn cài đặt từ lần khởi động đầu tiên, sẵn sàng cho chủ sở hữu mới nhập tên, mật khẩu, và mật khẩu mã hóa của chính họ.

Nó hoạt động bằng cách khôi phục snapshot gốc mà trình cài đặt tạo ra, vì vậy nó chỉ có sẵn trên các máy được cài đặt từ ISO của Omarchy. Và trên một ổ đĩa không có mã hóa, việc đặt lại là xóa chứ không phải xóa an toàn, vì vậy nếu dữ liệu nhạy cảm, hãy cài đặt mới thay vào đó.

## sudo không cần mật khẩu

Đôi khi bạn muốn `sudo` ngừng hỏi, thường nhất là khi một tác nhân AI đang thực hiện một đoạn dài công việc hệ thống cho bạn. _Setup > Security > Passwordless Sudo_ sẽ hỏi cho phép truy cập trong bao lâu: **15 phút**, **1 giờ**, **1 ngày**, hoặc **Vĩnh viễn**. Một biểu tượng cảnh báo màu đỏ xuất hiện bên cạnh các chỉ báo khác trên thanh menu trong khi quyền truy cập đang hoạt động. Nhấp vào nó hoặc chạy lại lệnh để tắt quyền truy cập. Bạn cũng có thể truyền số phút của riêng mình (từ 1 đến 1440) bằng `omarchy-sudo-passwordless 30`, hoặc dùng `omarchy-sudo-passwordless permanent`.

Quyền truy cập có thời hạn sẽ tự động hết hạn, bao gồm ngay sau khi tiếp tục từ trạng thái tạm dừng đã vượt qua thời hạn. Việc khởi động lại máy tính sẽ kết thúc nó sớm. Quyền truy cập vĩnh viễn vẫn tồn tại qua các lần khởi động lại và vẫn được bật cho đến khi bạn tắt nó.

Việc cập nhật hoặc gỡ bỏ gói cài đặt của Omarchy sẽ kết thúc bất kỳ quyền cấp tạm thời nào trước khi hỗ trợ hết hạn của nó thay đổi. Nếu lệnh báo lỗi ủy quyền hoặc dọn dẹp, hãy giải quyết nó trước khi cố gắng bật một quyền cấp khác; một lỗi không có nghĩa là quyền truy cập không cần mật khẩu đang không hoạt động.

Hãy tỉnh táo về điều này: trong khi nó đang bật, bất cứ thứ gì chạy dưới người dùng của bạn đều có thể làm bất cứ điều gì với quyền root mà không cần được hỏi. Đó là toàn bộ mục đích, và cũng là toàn bộ rủi ro.

## Khóa ký

Khóa công khai cho tất cả các chữ ký ISO và gói repo Omarchy là `40DFB630FF42BCFFB047046CF0134EE680CAC571` ([xác minh tại openpgp.org](https://keys.openpgp.org/search?q=pkgs%40omarchy.org)). Gói `omarchy/omarchy-keyring` cũng chứa khóa này và sẽ được dùng để triển khai bất kỳ bản cập nhật tiềm năng nào một cách liền mạch.

Bạn có thể tìm chữ ký cho bất kỳ bản phát hành ISO nào bằng cách thêm .sig vào URL. Chẳng hạn như https://iso.omarchy.org/omarchy-x.x.x.iso.sig.
