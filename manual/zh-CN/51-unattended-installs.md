# 无人值守安装

Omarchy ISO 可以在无人操作键盘的情况下自动完成安装。如果安装程序找到一个标为 `cidata` 的第二块驱动器（其中包含其配置文件），它会复制这些文件，完全跳过设置向导，并自动重启进入已完成的系统。无需特殊 ISO 构建，无需额外启动菜单条目——没有附加此类驱动器时，一切照常，你会得到普通的向导。

这让 Omarchy 成为一次性开发环境的绝佳基础镜像：在 Proxmox 或用 Packer 创建一个虚拟机，启动它，走开，然后通过 SSH 进入。`cidata` 是 cloud-init 的 `NoCloud` 标签，所以所有常见的虚拟化工具都知道如何附加这样的驱动器。

## 配置文件

这些文件正是安装程序自己的向导所写入的内容，所以获得一套初始文件最简便的方法是运行一次交互式安装（例如在虚拟机里），并复制它写入 `/root` 的东西：

| 文件 | 是否必需 | 用途 |
|------|----------|---------|
| `user_configuration.json` | 是 | 磁盘、主机名、时区、键盘 |
| `user_credentials.json` | 是 | 用户名和密码哈希 |
| `user_full_name.txt` | 否 | Git 全名 |
| `user_email_address.txt` | 否 | Git 邮箱 |
| `user_encrypt_installation.txt` | 否 | 当配置包含 `disk_encryption` 块时为 `true` |
| `authorized_keys` | 否 | SSH 公钥，每行一个 |
| `tailscale_authkey` | 否 | 用于首次开机时加入你的 tailnet 的 Tailscale 授权密钥 |

使用 `openssl passwd -6 "yourpassword"` 为 `user_credentials.json` 生成密码哈希。

你也可以用一个名为 `defer-provisioning` 的空文件代替 `user_credentials.json`。这会运行与你可以交互式触发的相同的[为另一位拥有者准备的安装](02-getting-started.md)：机器安装时没有任何个人信息，谁先启动它，谁就选择键盘并创建其用户。这是为成像设备准备的模式，其中驱动器根本不应该携带任何人的凭据。

## SSH 访问

当 `authorized_keys` 存在时，安装会将这些密钥设置为用户的 `~/.ssh/authorized_keys`，启用 `sshd`，并为之打开防火墙。（标准的 Omarchy 安装附带 openssh，但服务处于禁用状态且端口关闭，所以一台无人值守的机器否则将无法访问。）安装仅添加你的密钥——它不会放宽 SSH 守护进程的任何其他身份验证设置。

当 `tailscale_authkey` 存在时，机器会在首次启动时加入你的 tailnet：Tailscale 从 ISO 附带的软件包安装，防火墙允许 tailnet 接口，一个后台作业会在机器实际联网后立即运行加入，并一直重试直到成功。使用一个可重复使用且预先授权的密钥，这样一个驱动器镜像可以为很多机器服务。

## 构建 cidata 驱动器

任何带有正确标签的文件系统都可以。一个小 ISO 是简单方式：

```bash
mkdir cidata
cp user_configuration.json user_credentials.json authorized_keys cidata/
genisoimage -output cidata.iso -volid cidata -joliet -rock cidata/
```

然后把它和 Omarchy ISO 一起附加到虚拟机上。下面是一个完整的 Proxmox 示例：

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

启动顺序故意把磁盘列在第一位：空磁盘在第一次引导时穿透到 ISO，而之后已安装的系统始终从磁盘启动。

## 两个注意事项

加密的无人值守安装并非完全无人值守——首次引导时仍然需要有人输入 LUKS 密码。并且 `user_configuration.json` 中的 `disk_encryption` 块以明文携带该密码，所以要把从加密安装构建的 cidata 驱动器当作秘密来对待，因为它就是。
