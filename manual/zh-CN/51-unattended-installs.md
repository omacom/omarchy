# 无人值守安装

Omarchy ISO 可以在键盘前无人的情况下自行完成安装。如果安装程序发现第二块标有 `cidata` 的驱动器并载有其配置文件，它会将这些文件复制下来，完全跳过安装向导，并自行重启进入安装完成的系统。不需要特殊的 ISO 构建版本，不需要额外的启动菜单项——如果没有连接这样的驱动器，一切都不会改变，你得到的仍是正常的向导。

这让 Omarchy 非常适合用作一次性开发环境的基础镜像：在 Proxmox 中或使用 Packer 创建一台 VM，启动它，走开，然后通过 SSH 登录。`cidata` 是 cloud-init 的 `NoCloud` 标签，因此所有常见的虚拟化工具都已经知道如何挂载这样的驱动器。

## 配置文件

这些文件正是安装程序自己的向导所写出的内容，因此获取一套初始文件最简单的方法是运行一次交互式安装（比如在 VM 中），然后将它写到 `/root` 中的内容复制出来：

| 文件 | 必需 | 用途 |
|------|----------|---------|
| `user_configuration.json` | 是 | 磁盘、主机名、时区、键盘 |
| `user_credentials.json` | 是 | 用户名和密码哈希，以及加密安装的 LUKS 密码 |
| `user_encrypt_installation.txt` | 否 | 当配置带有 `disk_encryption` 块时为 `true` |
| `authorized_keys` | 否 | SSH 公钥，每行一个 |
| `tailscale_authkey` | 否 | 用于在首次启动时加入你的 tailnet 的 Tailscale 认证密钥 |

使用 `openssl passwd -6 "yourpassword"` 为 `user_credentials.json` 生成密码哈希。

git 提交所用的姓名和邮箱并不属于安装的一部分。等机器启动后，再进行设置，例如通过 SSH 使用 `omarchy setup git --name "Jane Doe" --email jane@example.com`。

你也可以放入一个名为 `defer-provisioning` 的空文件来替代 `user_credentials.json`。这会运行与你以交互方式触发的相同的[为另一位所有者做准备的安装](02-getting-started.md)：机器在安装时不带任何个人信息，第一个启动它的人来选择自己的键盘并创建自己的用户。这正是装机平台所用的模式，在这种情况下，驱动器根本不应该携带任何人的凭据。

## SSH 访问

当存在 `authorized_keys` 时，安装会将这些密钥设置为用户的 `~/.ssh/authorized_keys`，启用 `sshd`，并在防火墙中为其放行。（原装的 Omarchy 安装附带 openssh，但服务处于禁用状态且端口关闭，因此无人值守的机器否则将无法访问。）安装只会添加你的密钥——它不会放宽 SSH 守护进程的任何其他认证设置。

当存在 `tailscale_authkey` 时，机器改为在首次启动时加入你的 tailnet：Tailscale 会从 ISO 捆绑的软件包中安装，防火墙会放行 tailnet 接口，并且一个后台任务会在机器真正联网后立即运行加入操作，并不断重试直到成功。使用可重复使用、预先授权的密钥，这样一个驱动器镜像就能供许多台机器使用。

## 构建 cidata 驱动器

任何带有正确标签的文件系统都可以。一个微型 ISO 是简单的做法：

```bash
mkdir cidata
cp user_configuration.json user_credentials.json authorized_keys cidata/
genisoimage -output cidata.iso -volid cidata -joliet -rock cidata/
```

然后将其与 Omarchy ISO 一起挂载到 VM 上。这是一个完整的 Proxmox 示例：

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

启动顺序特意将磁盘列在第一位：空磁盘在首次启动时会回落到 ISO，之后安装好的系统便始终从磁盘启动。

## 两点注意事项

加密的无人值守安装并非完全无人值守——在首次启动时，仍然需要有人输入 LUKS 密码。而且该密码位于 `user_credentials.json` 的顶层，名为 `encryption_password`——archinstall 会从那里读取它，而不是从 `user_configuration.json` 中的 `disk_encryption` 块读取——因此，请将从加密安装构建出的 cidata 驱动器当作机密来对待，它本质上就是机密。
