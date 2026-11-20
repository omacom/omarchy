# Cài đặt Dual Boot

Bạn có thể cài đặt Omarchy vào một phân vùng duy nhất cùng với Windows hoặc các bản cài đặt khác.

Phương pháp cài đặt này vẫn đi kèm với mã hóa LUKS cho phân vùng theo mặc định, vì vậy về cơ bản nó không khác gì cài đặt trên toàn bộ ổ đĩa và chỉ đơn giản là yêu cầu có dung lượng trống sẵn trên đĩa.

## Tạo không gian trống trên Windows

Để cài đặt cùng với Windows, nhập `disk management` trong menu start và chọn tùy chọn **Create and format hard disk partitions**.

 ![dual-boot-1](images/dual-boot-1.webp)

Tìm phân vùng thích hợp, nhấp chuột phải, và chọn **Shrink Volume**.

![dual-boot-2](images/dual-boot-2.webp)

 Nhập dung lượng mà bạn muốn thu nhỏ ổ đĩa. Lưu ý rằng đây sẽ là kích thước của bản cài đặt Omarchy trong tương lai của bạn, bao gồm cả phân vùng khởi động.

 ![dual-boot-3](images/dual-boot-3.webp)

Khi bạn hoàn tất, bạn sẽ thấy một thứ gì đó như thế này, trong đó phần 50GB là nơi chúng ta sẽ cài đặt Omarchy trong ví dụ này.

 ![dual-boot-4](images/dual-boot-4.webp)

## Cài đặt Omarchy

Quá trình cài đặt Omarchy về cơ bản giống như bình thường. Sau khi bạn chọn đĩa của mình, bạn sẽ được cung cấp tùy chọn **Free space install**. Chọn tùy chọn đó để ngăn việc xóa toàn bộ đĩa.

 ![dual-boot-5](images/dual-boot-5.webp)

Xác nhận rằng mọi thứ trông ổn và đợi quá trình cài đặt hoàn tất như bình thường. Đây cũng là nơi bạn có thể chọn cài đặt không mã hóa (không khuyến nghị) giống như khi cài đặt trên toàn bộ ổ đĩa.
 ![dual-boot-6](images/dual-boot-6.webp)

## Thêm các bản cài đặt khác vào Bootloader

Khi bạn hoàn tất việc cài đặt Omarchy, bạn sẽ nhận thấy bootloader Limine hiện là mặc định. Với bootloader này, bạn cũng có thể thêm các tùy chọn vào Limine cho các bản cài đặt khác của mình, chẳng hạn như Windows.

Để thêm các hệ điều hành khác, hãy chạy `limine-scan` và làm theo các lời nhắc để thêm các mục bạn muốn vào cấu hình Limine của mình. Menu khởi động vẫn bị ẩn theo mặc định và khởi động Omarchy sau một giây. Để chọn Windows hoặc một mục khác, hãy nhấn bất kỳ phím nào ngay khi Limine khởi động; khi menu xuất hiện, hãy sử dụng các phím mũi tên để chọn một mục và nhấn Enter. Nếu Omarchy khởi động trước khi bạn nhấn phím, hãy khởi động lại và thử lại.

## Bitlocker

Điều quan trọng cần lưu ý là phương pháp cài đặt này không tương thích với Bitlocker vì nó mã hóa toàn bộ ổ đĩa, không chỉ phân vùng. Nếu bạn gặp lỗi cho biết Bitlocker đã được bật, hãy khởi động vào Windows, đi tới **Settings -> Privacy & Security -> Device encryption** và tắt Bitlocker. Có thể mất một thời gian để giải mã ổ đĩa.

 ![dual-boot-7](images/dual-boot-7.webp)
