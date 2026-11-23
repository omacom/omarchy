# Cài đặt không cần can thiệp

ISO Omarchy có thể tự cài đặt mà không cần ai ngồi trước bàn phím. Nếu trình cài đặt tìm thấy một ổ đĩa thứ hai có nhãn `cidata` chứa các tập tin cấu hình của nó, nó sẽ sao chép chúng ra, bỏ qua hoàn toàn trình hướng dẫn thiết lập, và tự khởi động lại vào hệ thống đã hoàn thiện. Không cần bản dựng ISO đặc biệt, không cần thêm mục nào trong menu khởi động — khi không gắn ổ đĩa như vậy, mọi thứ không thay đổi và bạn sẽ thấy trình hướng dẫn bình thường.

Điều này khiến Omarchy trở thành một image nền tuyệt vời cho các môi trường phát triển dùng một lần: tạo một VM trong Proxmox hoặc bằng Packer, khởi động nó, bỏ đi chỗ khác, rồi SSH vào. `cidata` là nhãn `NoCloud` của cloud-init, vì vậy mọi công cụ ảo hóa phổ biến đều đã biết cách gắn một ổ đĩa như vậy.

## Các tập tin cấu hình

Các tập tin này chính là những gì trình hướng dẫn của trình cài đặt tự ghi ra, vì vậy cách dễ nhất để có một bộ khởi đầu là chạy một lần cài đặt có tương tác (chẳng hạn trong một VM) và sao chép những gì nó đã ghi vào `/root`:

| Tập tin | Bắt buộc | Mục đích |
|------|----------|---------|
| `user_configuration.json` | Có | Đĩa, tên máy chủ, múi giờ, bàn phím |
| `user_credentials.json` | Có | Tên người dùng và hàm băm mật khẩu |
| `user_encrypt_installation.txt` | Không | `true` khi cấu hình chứa một khối `disk_encryption` |
| `authorized_keys` | Không | Các khóa công khai SSH, mỗi khóa một dòng |
| `tailscale_authkey` | Không | Khóa xác thực Tailscale để tham gia tailnet của bạn trong lần khởi động đầu tiên |

Tạo hàm băm mật khẩu cho `user_credentials.json` bằng `openssl passwd -6 "yourpassword"`.

Tên và email cho các commit git không phải là một phần của quá trình cài đặt. Hãy đặt chúng sau khi máy đã hoạt động, chẳng hạn qua SSH, bằng `omarchy setup git --name "Jane Doe" --email jane@example.com`.

Bạn cũng có thể đặt một tập tin trống có tên `defer-provisioning` thay cho `user_credentials.json`. Cách này chạy cùng một [quá trình cài đặt chuẩn bị cho chủ sở hữu khác](02-getting-started.md) mà bạn có thể kích hoạt khi cài đặt có tương tác: máy được cài đặt mà không có bất kỳ thông tin cá nhân nào, và người đầu tiên khởi động nó sẽ chọn bàn phím của họ và tạo người dùng của họ. Đó là chế độ dành cho các hệ thống tạo image, nơi ổ đĩa hoàn toàn không nên mang theo thông tin đăng nhập của bất kỳ ai.

## Truy cập SSH

Khi có `authorized_keys`, quá trình cài đặt sẽ thiết lập các khóa này thành `~/.ssh/authorized_keys` của người dùng, bật `sshd`, và mở tường lửa cho nó. (Một bản cài đặt Omarchy nguyên bản đi kèm openssh với dịch vụ bị tắt và cổng bị đóng, vì vậy một máy không có người giám sát sẽ không thể truy cập được nếu không có điều này.) Quá trình cài đặt chỉ thêm các khóa của bạn — nó không nới lỏng bất kỳ cài đặt xác thực nào khác của SSH daemon.

Khi có `tailscale_authkey`, máy sẽ tham gia tailnet của bạn trong lần khởi động đầu tiên thay vào đó: Tailscale được cài đặt từ các gói đi kèm trong ISO, tường lửa cho phép giao diện tailnet, và một tác vụ nền sẽ thực hiện việc tham gia ngay khi máy thực sự có mạng, thử lại cho đến khi thành công. Hãy dùng một khóa có thể tái sử dụng và đã được cấp quyền trước để một image ổ đĩa có thể phục vụ nhiều máy.

## Tạo ổ đĩa cidata

Bất kỳ hệ thống tập tin nào có nhãn đúng đều hoạt động. Một ISO nhỏ là cách dễ dàng:

```bash
mkdir cidata
cp user_configuration.json user_credentials.json authorized_keys cidata/
genisoimage -output cidata.iso -volid cidata -joliet -rock cidata/
```

Sau đó gắn nó vào VM cùng với ISO Omarchy. Dưới đây là một ví dụ đầy đủ trên Proxmox:

```bash
qm create 101 --name my-omarchy \
  --bios ovmf --machine q35 --cpu host --cores 4 --memory 8192 \
  --ostype l26 --scsihw virtio-scsi-single \
  --efidisk0 local-lvm:0,efitype=4m,pre-enrolled-keys=0 \
  --scsi0 local-lvm:40,discard=on,iothread=1 \
  --net0 virtio,bridge=vmbr0 --vga virtio --serial0 socket \
  --ide2 local:iso/omarchy.iso,media=cdrom \
  --ide3 local:iso/cidata.iso,media=cdrom \
  --boot order='scsi0;ide2'

qm start 101
```

Thứ tự khởi động cố ý liệt kê ổ đĩa trước: ổ đĩa trống sẽ chuyển tiếp sang ISO trong lần khởi động đầu tiên, và hệ thống đã cài đặt sẽ khởi động từ ổ đĩa mãi về sau.

## Hai lưu ý

Các cài đặt được mã hóa mà không cần giám sát không hoàn toàn không cần giám sát — vẫn phải có người nhập cụm mật khẩu LUKS trong lần khởi động đầu tiên. Và khối `disk_encryption` trong `user_configuration.json` chứa cụm mật khẩu đó dưới dạng văn bản thuần, vì vậy hãy đối xử với một ổ đĩa cidata được tạo từ một cài đặt đã mã hóa đúng như bí mật mà nó vốn là.
