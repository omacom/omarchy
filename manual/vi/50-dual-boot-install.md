# Cài đặt khởi động kép

Bạn có thể cài đặt Omarchy vào một phân vùng duy nhất bên cạnh Windows hoặc các bản cài đặt khác.

Phương pháp cài đặt này vẫn đi kèm mã hóa LUKS cho phân vùng theo mặc định nên về cơ bản nó không khác gì toàn bộ ổ đĩa và đơn giản chỉ yêu cầu có không gian trống trên đĩa.

## Tạo không gian trên Windows

Để cài đặt bên cạnh Windows, gõ `disk management` trong menu bắt đầu và chọn tùy chọn **Create and format hard disk partitions**.

 ![dual-boot-1](images/dual-boot-1.webp)

Tìm phân vùng thích hợp, nhấp chuột phải, và chọn **Shrink Volume**.

![dual-boot-2](images/dual-boot-2.webp)

 Nhập dung lượng bạn muốn thu nhỏ volume. Lưu ý rằng đây sẽ là kích thước của bản cài đặt Omarchy trong tương lai của bạn bao gồm cả phân vùng khởi động.

 ![dual-boot-3](images/dual-boot-3.webp)

Khi bạn hoàn tất, bạn sẽ thấy thứ gì đó như thế này trong đó phần 50GB là nơi chúng ta sẽ cài đặt Omarchy trong ví dụ này.

 ![dual-boot-4](images/dual-boot-4.webp)

## Cài đặt Omarchy

Quá trình cài đặt Omarchy về cơ bản giống như bình thường. Sau khi bạn chọn đĩa của mình, bạn sẽ được cho tùy chọn **Free space install**. Chọn tùy chọn đó để tránh xóa toàn bộ đĩa.

 ![dual-boot-5](images/dual-boot-5.webp)

Xác nhận rằng mọi thứ trông ổn và chờ quá trình cài đặt hoàn tất như bình thường. Đây cũng là nơi bạn có thể chọn cài đặt không mã hóa (không khuyến nghị) giống như trên một bản cài đặt toàn bộ ổ đĩa.
 ![dual-boot-6](images/dual-boot-6.webp)

## Thêm các bản cài đặt khác vào Bootloader

Khi bạn hoàn tất việc cài đặt Omarchy, bạn sẽ nhận thấy rằng bootloader Limine giờ là mặc định. Với nó, bạn cũng có thể thêm các tùy chọn vào Limine cho các bản cài đặt khác của mình như Windows.

Để làm điều đó, hãy chạy `limine-scan` và làm theo các lời nhắc để thêm bất kỳ mục nào bạn muốn vào cấu hình limine của mình. Sau đó khi bạn khởi động, bạn sẽ thấy các tùy chọn thông thường của mình cho Omarchy, cũng như Windows Boot Manager hoặc các tùy chọn khác.

## Bitlocker

Điều quan trọng cần lưu ý là phương pháp cài đặt này không tương thích với Bitlocker vì nó mã hóa toàn bộ ổ đĩa, không chỉ phân vùng. Nếu bạn gặp một lỗi nói rằng Bitlocker đang bật, hãy khởi động vào Windows, vào **Settings -> Privacy & Security -> Device encryption** và tắt Bitlocker. Có thể mất một thời gian để giải mã ổ đĩa.

 ![dual-boot-7](images/dual-boot-7.webp)
