# Bảo mật

Omarchy cực kỳ coi trọng bảo mật. Đây được dự định là một hệ điều hành mà bạn có thể dùng để làm _Công Việc Thực Sự_ trong _Thế Giới Thực_. Nơi việc mất một chiếc laptop không thể dẫn tới một tình huống khẩn cấp về bảo mật. Vậy đây là những gì chúng tôi làm:

1. *Mã hóa toàn đĩa là bắt buộc*: Đây là bước quan trọng nhất để bảo vệ vật lý dữ liệu của bạn. Nếu máy tính của bạn bị mất hoặc bị đánh cắp, dữ liệu được mã hóa hoàn toàn bằng LUKS tiêu chuẩn (Linux Unified Key Setup).
2. *Tường lửa được bật theo mặc định*: Mọi lưu lượng đến đều bị chặn theo mặc định ngoại trừ cổng 53317 cho [LocalSend](https://localsend.org/). Ngay cả ssh cũng tắt cho đến khi bạn bật nó qua _Thiết lập > Bảo mật > SSHD_, việc này mở cổng 22 (giới hạn tốc độ chống brute force) như một phần của thiết lập. Chúng tôi thậm chí khóa quyền truy cập Docker bằng thiết lập [ufw-docker](https://github.com/chaifeng/ufw-docker) để ngăn các container của bạn vô tình bị phơi ra thế giới.
3. *Arch luôn có các bản cập nhật mới nhất*: Arch, bản phân phối nền tảng mà Omarchy được xây dựng trên đó, là một bản phân phối rolling. Điều này có nghĩa là bất kỳ lỗ hổng bảo mật nào được phát hiện và vá trong bất kỳ gói nào đều nhanh chóng có sẵn để cài đặt bằng `omarchy-update`. Bạn luôn chạy các phiên bản mới nhất, an toàn nhất của mọi thứ theo cách đó.
4. *Omarchy duy trì các gói và mirror của riêng mình*: Omarchy chỉ dựa vào các gói từ các kho core/extra/multilib của chính Arch và Kho Gói Omarchy của riêng mình theo mặc định. Bạn có thể cài đặt phần mềm trực tiếp từ AUR, nhưng bản cài đặt cơ sở thì không — chỉ một vài bản cài đặt tùy chọn, như các trình duyệt của bên thứ ba, mới kéo từ AUR.
5. *Cloudflare bảo vệ chúng tôi khỏi DDoS*: Toàn bộ hạ tầng phân phối Omarchy — các tệp ISO, các gói Omarchy, mirror Arch — đều được bảo vệ đằng sau lá chắn DDoS đáng gờm của Cloudflare và được lưu trữ trên CDN của họ. Điều này mang lại tính khả dụng tuyệt vời.

## Đổi mật khẩu của bạn

Bạn có hai mật khẩu trên một bản cài đặt đã mã hóa: mật khẩu mở khóa ổ đĩa khi khởi động, và mật khẩu bạn đăng nhập và dùng `sudo`. Thiết lập làm cho chúng giống nhau. Cả hai đều có thể được đổi dưới _Cập nhật > Mật khẩu_ trong menu Omarchy — _Mã hóa ổ đĩa_ cho mật khẩu đầu tiên, _Người dùng_ cho mật khẩu thứ hai. Đổi mật khẩu ổ đĩa sẽ yêu cầu mật khẩu hiện tại trước, nên hãy chuẩn bị sẵn nó. Nếu một lần đổi bị gián đoạn, hãy chạy _Mã hóa ổ đĩa_ lần nữa: nó sẽ yêu cầu mật khẩu mở khóa ổ đĩa hiện tại và hoàn tất việc đổi.

## Bàn giao một máy bạn đã dùng

Nếu bạn đang bàn giao máy của mình cho người khác, bạn không phải cài đặt lại nó. Chạy _Thiết lập > Đặt lại máy_ trong menu Omarchy, gõ `reset` để xác nhận, và khởi động lại. Việc đó xóa mọi tài khoản người dùng và mọi thứ trong `/home`, vứt bỏ mọi gói và thay đổi hệ thống bạn đã thực hiện kể từ khi cài đặt, và xóa danh tính của máy — các kết nối mạng, khóa máy chủ, và tất cả. Thứ quay trở lại là trình hướng dẫn thiết lập từ lần khởi động đầu tiên, sẵn sàng cho chủ sở hữu mới nhập tên, mật khẩu và mật khẩu mã hóa của riêng họ.

Nó hoạt động bằng cách khôi phục ảnh chụp nhanh cơ sở mà trình cài đặt chụp, nên nó chỉ khả dụng trên các máy được cài đặt từ ISO Omarchy. Và trên một ổ đĩa không có mã hóa, việc đặt lại là xóa chứ không phải xóa an toàn, nên nếu dữ liệu nhạy cảm, hãy cài đặt mới thay vào đó.

## Sudo không mật khẩu

Đôi khi bạn muốn `sudo` ngừng hỏi, thường nhất là khi một agent AI đang làm một đoạn dài công việc hệ thống cho bạn. _Thiết lập > Bảo mật > Sudo không mật khẩu_ hỏi thời gian cho phép truy cập trong bao lâu: **15 minutes**, **1 Hour**, **1 Day** hoặc **Permanently**. Một biểu tượng cảnh báo màu đỏ xuất hiện bên cạnh các chỉ báo khác trên thanh menu trong khi quyền truy cập đang hoạt động. Nhấp vào nó hoặc chạy lại lệnh để tắt quyền truy cập. Bạn cũng có thể truyền số phút của riêng mình (từ 1 đến 1440) bằng `omarchy-sudo-passwordless 30`, hoặc dùng `omarchy-sudo-passwordless permanent`.

Quyền truy cập có thời hạn tự động hết hạn, kể cả ngay sau khi tiếp tục từ một lần tạm dừng đã vượt qua hạn chót. Khởi động lại máy tính sẽ kết thúc nó sớm. Quyền truy cập vĩnh viễn tồn tại qua các lần khởi động lại và vẫn bật cho đến khi bạn tắt nó.

Cập nhật hoặc gỡ bỏ gói cài đặt của Omarchy sẽ kết thúc bất kỳ quyền cấp tạm thời nào trước khi hỗ trợ hết hạn của nó thay đổi. Nếu lệnh báo cáo một lỗi cấp quyền hoặc dọn dẹp, hãy giải quyết nó trước khi cố gắng bật một quyền cấp khác; một lỗi không có nghĩa là quyền truy cập không mật khẩu đang không hoạt động.

Hãy nhìn rõ về việc này: trong khi nó đang bật, bất cứ thứ gì chạy với tư cách người dùng của bạn đều có thể làm bất cứ điều gì với quyền root mà không cần được hỏi. Đó là toàn bộ mục đích, và đó cũng là toàn bộ rủi ro.

## Khóa ký

Khóa công khai cho mọi chữ ký ISO và gói repo Omarchy là `40DFB630FF42BCFFB047046CF0134EE680CAC571` ([xác minh tại openpgp.org](https://keys.openpgp.org/search?q=pkgs%40omarchy.org)). Gói `omarchy/omarchy-keyring` cũng chứa khóa này và sẽ được dùng để triển khai mọi bản cập nhật tiềm năng một cách liền mạch.

Bạn có thể tìm chữ ký cho bất kỳ bản phát hành ISO nào bằng cách thêm .sig vào URL. Như https://iso.omarchy.org/omarchy-x.x.x.iso.sig.
