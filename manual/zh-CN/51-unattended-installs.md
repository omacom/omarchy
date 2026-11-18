# 无人值守安装

Omarchy ISO 可以在键盘前无人操作的情况下完成自我安装。如果安装程序发现第二块标有 `cidata` 标签、带着其配置文件的驱动器，它就会把这些文件复制出来，完全跳过设置向导，并自动重启进入已完成的系统。无需专门的 ISO 构建版本，也无需额外的启动菜单项——如果没有连接这样的驱动器，一切都不会改变，你看到的仍是正常的向导。

这使得 Omarchy 非常适合作为一次性开发环境的基础镜像：在 Proxmox 中或用 Packer 创建一台 VM，启动它，走开，然后通过 SSH 连进来。`cidata` 是 cloud-init 的 `NoCloud` 标签，因此所有常见的虚拟化工具都已经知道如何挂载这样的驱动器。

## 配置文件

这些文件正是安装程序自己的向导所写出的文件，因此获取一套起始文件的最简单方法，就是运行一次交互式安装（比如在一台 VM 中），然后复制它写入 `/root` 的内容：

| File | Required | Purpose |
|------|----------|---------|
| `user_configuration.json` | Yes | 磁盘、主机名、时区、键盘 |
| `user_credentials.json` | Yes | 用户名和密码哈希 |
| `user_encrypt_installation.txt` | No | 当配置带有 `disk_encryption` 块时为 `true` |
| `authorized_keys` | No | SSH 公钥，每行一个 |
| `tailscale_authkey` | No | 用于在首次启动时加入你的 tailnet 的 Tailscale 身份验证密钥 |

使用 `openssl passwd -6 "yourpassword"` 为 `user_credentials.json` 生成密码哈希。

用于 git 提交的姓名和电子邮件不属于安装的一部分。等机器启动后，再通过例如 SSH，用 `omarchy setup git --name "Jane Doe" --email jane@example.com` 设置它们。

你还可以用一个名为 `defer-provisioning` 的空文件代替 `user_credentials.json`。这会运行与你可以交互式触发的相同的[为另一位所有者做准备的安装](02-getting-started.md)：机器在不带任何个人信息的情况下完成安装，第一个启动它的人来选择自己的键盘并创建自己的用户。这正是成像设备所用的模式，在这种模式下，驱动器根本不应该携带任何人的凭据。

## SSH 访问

当 `authorized_keys` 存在时，安装程序会将这些密钥设置成用户的 `~/.ssh/authorized_keys`，启用 `sshd`，并在防火墙中为它打开端口。（标准的 Omarchy 安装附带 openssh，但服务处于禁用状态且端口关闭，因此无人值守的机器否则将无法连接。）安装程序只会添加你的密钥——它不会放宽 SSH 守护进程的任何其他身份验证设置。

当 `tailscale_authkey` 存在时，机器则会在首次启动时加入你的 tailnet：Tailscale 会从 ISO 附带的软件包中安装，防火墙会允许 tailnet 接口，并且一个后台任务会在机器真正获得网络后立即运行加入操作，并不断重试直到成功。使用可重复使用、预先授权的密钥，这样一个驱动器镜像就可以服务多台机器。

## 构建 cidata 驱动器

任何带有正确标签的文件系统都可以。一个小小的 ISO 是最简单的方法：

```bash
mkdir cidata
cp user_configuration.json user_credentials.json authorized_keys cidata/
genisoimage -output cidata.iso -volid cidata -joliet -rock cidata/
```

然后将它与 Omarchy ISO 一起挂载到 VM 上。以下是一个完整的 Proxmox 示例：

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

启动顺序特意将磁盘列在第一位：空磁盘在首次启动时会穿透到 ISO，而安装好的系统此后则始终从磁盘启动。

## 两个注意事项

加密的无人值守安装并非完全无人值守——在首次启动时，仍然需要有人输入 LUKS 密码。而且 `user_configuration.json` 中的 `disk_encryption` 块以明文形式携带了该密码，因此请将从加密安装构建的 cidata 驱动器当作它本就是的秘密来对待。
