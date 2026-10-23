# Cài đặt không giám sát

ISO Omarchy có thể tự cài đặt mà không cần ai ở bàn phím. Nếu trình cài đặt tìm thấy một ổ đĩa thứ hai có nhãn `cidata` mang các tệp cấu hình của nó, nó sẽ sao chép chúng ra, bỏ qua hoàn toàn trình hướng dẫn thiết lập và tự khởi động lại vào hệ thống đã hoàn thiện. Không cần bản dựng ISO đặc biệt, không cần mục menu khởi động bổ sung — khi không có ổ đĩa như vậy được gắn, không có gì thay đổi và bạn nhận được trình hướng dẫn thông thường.

Điều này khiến Omarchy tuyệt vời như một image cơ sở cho các môi trường phát triển dùng một lần: tạo một VM trong Proxmox hoặc bằng Packer, khởi động nó, bỏ đi, SSH vào. `cidata` là nhãn `NoCloud` của cloud-init, nên mọi công cụ ảo hóa phổ biến đều đã biết cách gắn một ổ đĩa như vậy.

## Các tệp cấu hình

Các tệp chính xác là những gì trình hướng dẫn của chính trình cài đặt ghi, nên cách dễ nhất để có một bộ khởi đầu là chạy một lần cài đặt tương tác (chẳng hạn trong một VM) và sao chép những gì nó đã ghi vào `/root`:

| Tệp | Bắt buộc | Mục đích |
|------|----------|---------|
| `user_configuration.json` | Có | Đĩa, tên máy, múi giờ, bàn phím |
| `user_credentials.json` | Có | Tên người dùng và hash mật khẩu |
| `user_full_name.txt` | Không | Họ tên đầy đủ cho Git |
| `user_email_address.txt` | Không | Email cho Git |
| `user_encrypt_installation.txt` | Không | `true` khi cấu hình mang một khối `disk_encryption` |
| `authorized_keys` | Không | Các khóa công khai SSH, mỗi dòng một khóa |
| `tailscale_authkey` | Không | Khóa xác thực Tailscale để tham gia tailnet của bạn trong lần khởi động đầu tiên |

Tạo hash mật khẩu cho `user_credentials.json` bằng `openssl passwd -6 "yourpassword"`.

Bạn cũng có thể thả vào một tệp trống có tên `defer-provisioning` thay cho `user_credentials.json`. Việc đó chạy cùng một [cài đặt chuẩn bị cho chủ sở hữu khác](02-getting-started.md) mà bạn có thể kích hoạt một cách tương tác: máy cài đặt mà không có chi tiết cá nhân, và bất cứ ai khởi động nó lần đầu sẽ chọn bàn phím của họ và tạo người dùng của họ. Đó là chế độ cho các dàn tạo image, nơi ổ đĩa hoàn toàn không nên mang thông tin xác thực của bất kỳ ai.

## Truy cập SSH

Khi `authorized_keys` hiện diện, quá trình cài đặt sẽ thiết lập các khóa làm `~/.ssh/authorized_keys` của người dùng, bật `sshd` và mở tường lửa cho nó. (Một bản cài đặt Omarchy gốc đi kèm openssh với dịch vụ bị tắt và cổng bị đóng, nên một máy không giám sát nếu không sẽ không thể truy cập được.) Quá trình cài đặt chỉ thêm các khóa của bạn — nó không nới lỏng bất kỳ cài đặt xác thực nào khác của daemon SSH.

Khi `tailscale_authkey` hiện diện, thay vào đó máy sẽ tham gia tailnet của bạn trong lần khởi động đầu tiên: Tailscale được cài đặt từ các gói đi kèm của ISO, tường lửa cho phép giao diện tailnet, và một tác vụ nền chạy việc tham gia ngay khi máy thực sự có mạng, thử lại cho đến khi thành công. Hãy dùng một khóa có thể tái sử dụng, đã được cấp quyền trước để một image ổ đĩa có thể phục vụ nhiều máy.

## Xây dựng ổ đĩa cidata

Bất kỳ hệ thống tệp nào có nhãn đúng đều hoạt động. Một ISO nhỏ là cách dễ dàng:

```bash
mkdir cidata
cp user_configuration.json user_credentials.json authorized_keys cidata/
genisoimage -output cidata.iso -volid cidata -joliet -rock cidata/
```

Sau đó gắn nó vào VM bên cạnh ISO Omarchy. Đây là một ví dụ Proxmox đầy đủ:

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

Thứ tự khởi động cố ý liệt kê đĩa trước: đĩa trống sẽ chuyển qua ISO trong lần khởi động đầu tiên, và hệ thống đã cài đặt sẽ khởi động từ đĩa mãi về sau.

## Hai lưu ý

Các bản cài đặt không giám sát đã mã hóa không hoàn toàn không giám sát — ai đó vẫn phải gõ cụm mật khẩu LUKS trong lần khởi động đầu tiên. Và khối `disk_encryption` trong `user_configuration.json` mang cụm mật khẩu đó ở dạng văn bản thuần, nên hãy đối xử với một ổ đĩa cidata được xây dựng từ một bản cài đặt đã mã hóa như bí mật mà nó vốn là.
