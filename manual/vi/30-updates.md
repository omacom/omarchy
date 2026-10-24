# Cập nhật

Omarchy và các gói của bạn được giữ cập nhật qua _Cập nhật > Omarchy_ trong menu Omarchy (`Super + Space`).

Bản thân Omarchy được cài đặt dưới dạng các gói pacman thông thường từ [Kho gói Omarchy](https://github.com/omacom-io/omarchy-pkgs), vì vậy một bản cập nhật sẽ cài đặt [bản phát hành Omarchy mới nhất](https://github.com/omacom/omarchy/releases), chạy mọi di chuyển đang chờ xử lý để đưa hệ thống của bạn đồng bộ với phiên bản mới nhất, và cập nhật mọi gói hệ thống từ [Bản sao Arch của Omarchy](https://github.com/omacom-io/omarchy-mirror) và [AUR](https://aur.archlinux.org/) (nếu bạn đã cài đặt bất kỳ gói AUR nào).

Khi các bản phát hành mới được tạo, một biểu tượng mũi tên hình tròn sẽ xuất hiện ở phía bên phải đồng hồ của bạn. Nhấp vào nó và quá trình cập nhật sẽ bắt đầu.

![update-available](images/update-available.webp)

### Bốn kênh

Omarchy được cập nhật theo bốn kênh: stable, RC, edge và dev. Các bản cài đặt mới bắt đầu trên kênh stable, theo dõi [các bản phát hành chính thức](https://github.com/omacom/omarchy/releases/), cũng như [bản sao Arch ổn định của Omarchy](https://github.com/omacom-io/omarchy-mirror) chạy chậm hơn phiên bản mới nhất một tháng, để chúng tôi có thể bắt được mọi khả năng không tương thích mới đòi hỏi thay đổi cấu hình trước khi chúng gây ra vấn đề cho mọi người.

Nhưng nếu bạn muốn giúp phát hiện những vấn đề tiềm ẩn đó, bạn có thể chạy trên kênh edge. Điều đó sẽ giữ các gói Omarchy của bạn theo dõi các bản dựng phát triển mới nhất, và cho phép bạn cập nhật lên các gói Arch mới nhất ngay khi chúng có sẵn. Bạn chỉ nên làm điều này nếu bạn có kinh nghiệm với Linux, và biết cách khôi phục một hệ thống gặp vấn đề.

Trước bất kỳ bản phát hành lớn mới nào, chúng tôi sẽ thực hiện xác thực cuối cùng bằng kênh RC. Nếu bạn quan tâm đến việc giúp hoàn thiện lần cuối, hãy đến giao lưu trong #omarchy-release-candidates trên Discord.

Cuối cùng, có kênh dev, liên kết Omarchy trực tiếp đến một bản sao git của mã nguồn trong `~/omarchy`, kết hợp với các gói edge. Bạn chỉ nên dùng kênh này nếu bạn là người dùng Linux có kinh nghiệm, đang làm việc trực tiếp trên Omarchy, và sẵn lòng chịu đựng sự cố.

Bạn có thể chuyển đổi giữa các kênh bằng _Cập nhật > Kênh_ từ menu Omarchy (hoặc `omarchy-channel-set` trong terminal).

### Cập nhật firmware

Các gói của bạn không phải là thứ duy nhất trở nên lỗi thời. Nhiều máy tính xách tay và thiết bị ngoại vi cung cấp firmware cho BIOS, SSD và dock thông qua Linux Vendor Firmware Service, và _Cập nhật > Firmware_ trong menu Omarchy sẽ tải về và cài đặt bất cứ thứ gì phần cứng của bạn đang chờ. Nó cài đặt `fwupd` trong lần đầu tiên bạn chạy nó. Nhiều firmware chỉ có thể được ghi trong quá trình khởi động lại, vì vậy đừng ngạc nhiên khi bạn được yêu cầu khởi động lại.

### Cảnh báo về việc cập nhật trực tiếp bằng pacman/yay

Nếu bạn đã quen với Arch, bạn có thể bị cám dỗ chỉ cần tự chạy `pacman -Syu` hoặc `yay -Syu`, nhưng nếu bạn làm vậy, bạn sẽ bỏ lỡ ảnh chụp nhanh (snapshot), các di chuyển và cập nhật cấu hình mà Omarchy chạy cùng với các gói mới. Đó là lý do Omarchy thực tế sẽ chặn một bản nâng cấp hệ thống trực tiếp và chỉ bạn đến `omarchy update` thay thế. (Nếu bạn thực sự biết mình đang làm gì, cơ chế bảo vệ sẽ cho bạn biết cách vượt qua nó cho một giao dịch duy nhất.)

### Khôi phục sau các bản cập nhật lỗi

Nếu bạn gặp vấn đề sau khi cập nhật, bạn có thể khôi phục hệ thống của mình về ảnh chụp nhanh được tạo trước khi cập nhật. Chỉ cần khởi động lại và chọn ảnh chụp nhanh trong menu tải khởi động từ trước khi bạn bắt đầu cập nhật.

![bootloader](images/bootloader.webp)

Nếu bằng cách nào đó các tệp cấu hình của bạn đã bị hỏng, bạn cũng có thể thực hiện cài đặt lại Omarchy bằng `omarchy reinstall` trong terminal. Thao tác này sẽ cài đặt lại mọi gói Omarchy mặc định, đưa bạn về stable và hạ cấp bất kỳ gói nào quá mới, và đặt lại mọi tệp cấu hình. Lưu ý rằng mọi thay đổi cấu hình người dùng của bạn đối với các mặc định của Omarchy sẽ bị ghi đè khi làm điều này!
