# Cài đặt Dual Boot

Bạn có thể cài đặt Omarchy vào một phân vùng duy nhất cùng với Windows hoặc các bản cài đặt khác.

Phương pháp cài đặt này vẫn mặc định đi kèm mã hóa LUKS cho phân vùng, nên về cơ bản không khác gì cài đặt trên toàn bộ ổ đĩa và chỉ đơn giản yêu cầu có dung lượng trống trên đĩa.

## Tạo dung lượng trống trên Windows

Để cài đặt cùng với Windows, hãy nhập `disk management` trong menu bắt đầu và chọn tùy chọn **Create and format hard disk partitions**.

 ![dual-boot-1](images/dual-boot-1.webp)

Tìm phân vùng phù hợp, nhấp chuột phải và chọn **Shrink Volume**.

![dual-boot-2](images/dual-boot-2.webp)

 Nhập dung lượng bạn muốn thu nhỏ phân vùng. Lưu ý rằng đây sẽ là kích thước của bản cài đặt Omarchy trong tương lai của bạn, bao gồm cả phân vùng khởi động.

 ![dual-boot-3](images/dual-boot-3.webp)

Khi hoàn tất, bạn sẽ thấy một thứ gì đó như thế này, trong đó phần 50GB là nơi chúng ta sẽ cài đặt Omarchy trong ví dụ này.

 ![dual-boot-4](images/dual-boot-4.webp)

## Cài đặt Omarchy

Quá trình cài đặt Omarchy về cơ bản giống như bình thường. Sau khi bạn chọn ổ đĩa, bạn sẽ được cung cấp tùy chọn **Free space install**. Hãy chọn tùy chọn đó để tránh xóa toàn bộ ổ đĩa.

 ![dual-boot-5](images/dual-boot-5.webp)

Xác nhận rằng mọi thứ trông ổn và chờ quá trình cài đặt hoàn tất như bình thường. Đây cũng là nơi bạn có thể chọn cài đặt không mã hóa (không khuyến nghị) giống như khi cài đặt trên toàn bộ ổ đĩa.
 ![dual-boot-6](images/dual-boot-6.webp)

## Thêm các bản cài đặt khác vào Bootloader

Khi hoàn tất cài đặt Omarchy, bạn sẽ nhận thấy bootloader Limine hiện là mặc định. Với bootloader này, bạn cũng có thể thêm các tùy chọn vào Limine cho các bản cài đặt khác của mình, chẳng hạn như Windows.

Để thêm các hệ điều hành khác, hãy chạy `limine-scan` và làm theo các hướng dẫn để thêm các mục bạn muốn vào cấu hình Limine của bạn. Menu khởi động theo mặc định vẫn bị ẩn và khởi động Omarchy sau một giây. Để chọn Windows hoặc một mục khác, hãy nhấn phím bất kỳ ngay khi Limine khởi động; khi menu xuất hiện, hãy sử dụng các phím mũi tên để chọn một mục và nhấn Enter. Nếu Omarchy khởi động trước khi bạn nhấn phím, hãy khởi động lại và thử lại. Nếu bạn đã bật _Setup > Direct Boot_, firmware sẽ bỏ qua Limine hoàn toàn, vì vậy hãy chọn Limine từ menu khởi động BIOS của bạn hoặc chạy lại _Setup > Direct Boot_ để xóa mục đó.

## Bitlocker

Điều quan trọng cần lưu ý là phương pháp cài đặt này không tương thích với Bitlocker vì nó mã hóa toàn bộ ổ đĩa, không chỉ phân vùng. Nếu bạn gặp lỗi cho biết Bitlocker đang được bật, hãy khởi động vào Windows, đi tới **Settings -> Privacy & Security -> Device encryption** và tắt Bitlocker. Có thể mất một chút thời gian để giải mã ổ đĩa.

 ![dual-boot-7](images/dual-boot-7.webp)
