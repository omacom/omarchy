# Cài đặt không cần giám sát

ISO Omarchy có thể tự cài đặt mà không cần ai ngồi trước bàn phím. Nếu trình cài đặt tìm thấy một ổ đĩa thứ hai có nhãn `cidata` mang theo các tệp cấu hình của nó, nó sẽ sao chép chúng ra, bỏ qua hoàn toàn trình hướng dẫn thiết lập, và tự khởi động lại vào hệ thống đã hoàn thiện. Không cần bản dựng ISO đặc biệt, không cần mục menu khởi động bổ sung — khi không gắn ổ đĩa như vậy, không có gì thay đổi và bạn nhận được trình hướng dẫn bình thường.

Điều này khiến Omarchy trở thành một image nền tuyệt vời cho các môi trường dev dùng một lần: tạo một VM trong Proxmox hoặc bằng Packer, khởi động nó, bỏ đi chỗ khác, rồi SSH vào. `cidata` là nhãn `NoCloud` của cloud-init, vì vậy mọi công cụ ảo hóa phổ biến đều đã biết cách gắn một ổ đĩa như vậy.

## Các tệp cấu hình

Các tệp chính xác là những gì trình hướng dẫn của chính trình cài đặt ghi ra, vì vậy cách dễ nhất để có một bộ khởi đầu là chạy một lần cài đặt tương tác (chẳng hạn trong một VM) và sao chép những gì nó đã ghi vào `/root`:

| Tệp | Bắt buộc | Mục đích |
|------|----------|---------|
| `user_configuration.json` | Có | Ổ đĩa, hostname, múi giờ, bàn phím |
| `user_credentials.json` | Có | Tên người dùng và hash mật khẩu, cùng passphrase LUKS cho một bản cài đặt được mã hóa |
| `user_encrypt_installation.txt` | Không | `true` khi cấu hình mang một khối `disk_encryption` |
| `authorized_keys` | Không | Các khóa công khai SSH, mỗi dòng một khóa |
| `tailscale_authkey` | Không | Khóa xác thực Tailscale để tham gia tailnet của bạn trong lần khởi động đầu tiên |

Tạo hash mật khẩu cho `user_credentials.json` bằng `openssl passwd -6 "yourpassword"`.

Tên và email cho các git commit không phải là một phần của quá trình cài đặt. Hãy đặt chúng khi máy đã hoạt động, chẳng hạn qua SSH, bằng `omarchy setup git --name "Jane Doe" --email jane@example.com`.

Bạn cũng có thể thả vào một tệp trống có tên `defer-provisioning` thay cho `user_credentials.json`. Điều đó chạy cùng một [bản cài đặt chuẩn bị cho một chủ sở hữu khác](02-getting-started.md) mà bạn có thể kích hoạt một cách tương tác: máy được cài đặt mà không có thông tin cá nhân nào, và người đầu tiên khởi động nó sẽ chọn bàn phím của họ và tạo người dùng của họ. Đó là chế độ dành cho các dàn máy imaging, nơi ổ đĩa hoàn toàn không nên mang theo thông tin đăng nhập của bất kỳ ai.

## Truy cập SSH

Khi có `authorized_keys`, quá trình cài đặt thiết lập các khóa làm `~/.ssh/authorized_keys` của người dùng, bật `sshd`, và mở firewall cho nó. (Một bản cài đặt Omarchy nguyên bản đi kèm openssh với dịch vụ bị vô hiệu hóa và cổng bị đóng, vì vậy một máy không cần giám sát nếu không sẽ không thể truy cập được.) Quá trình cài đặt chỉ thêm các khóa của bạn — nó không nới lỏng bất kỳ cài đặt xác thực nào khác của SSH daemon.

Khi có `tailscale_authkey`, thay vào đó máy sẽ tham gia tailnet của bạn trong lần khởi động đầu tiên: Tailscale được cài đặt từ các gói đi kèm của ISO, firewall cho phép interface tailnet, và một tác vụ nền chạy việc tham gia ngay khi máy thực sự có mạng, thử lại cho đến khi thành công. Hãy dùng một khóa có thể tái sử dụng, được ủy quyền trước để một image ổ đĩa có thể phục vụ nhiều máy.

## Tạo ổ đĩa cidata

Bất kỳ hệ thống tệp nào có nhãn đúng đều hoạt động. Một ISO nhỏ là cách dễ dàng:

```bash
mkdir cidata
cp user_configuration.json user_credentials.json authorized_keys cidata/
genisoimage -output cidata.iso -volid cidata -joliet -rock cidata/
```

Sau đó gắn nó vào VM cùng với ISO Omarchy. Đây là một ví dụ Proxmox đầy đủ:

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

Thứ tự khởi động liệt kê ổ đĩa trước tiên là có chủ ý: ổ đĩa trống sẽ chuyển sang ISO trong lần khởi động đầu tiên, và hệ thống đã cài đặt sẽ khởi động từ ổ đĩa mãi về sau.

## Hai lưu ý cảnh báo

Các bản cài đặt không cần giám sát được mã hóa không hoàn toàn không cần giám sát — vẫn có người phải gõ passphrase LUKS trong lần khởi động đầu tiên. Và passphrase đó nằm ở cấp cao nhất của `user_credentials.json` dưới dạng `encryption_password` — archinstall đọc nó ở đó, không phải từ khối `disk_encryption` trong `user_configuration.json` — vì vậy hãy đối xử với một ổ đĩa cidata được tạo từ một bản cài đặt được mã hóa như chính bí mật mà nó là.
