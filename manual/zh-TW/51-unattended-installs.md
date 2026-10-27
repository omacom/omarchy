# 無人值守安裝

Omarchy ISO 可以在鍵盤前沒有任何人的情況下自行完成安裝。如果安裝程式找到第二個標記為 `cidata`、且帶有其設定檔的磁碟機，它會將這些檔案複製出來、完全跳過設定精靈，並自行重新開機進入已完成的系統。不需要特殊的 ISO 建置，也不需要額外的開機選單項目——如果沒有連接這類磁碟機，一切都不會改變，你看到的仍是一般的精靈。

這讓 Omarchy 非常適合作為一次性開發環境的基礎映像：在 Proxmox 或用 Packer 建立一台 VM，開機，走開，然後透過 SSH 連進去。`cidata` 是 cloud-init 的 `NoCloud` 標籤，因此所有常見的虛擬化工具都已經知道如何連接這類磁碟機。

## 設定檔

這些檔案正是安裝程式自己的精靈所寫入的檔案，因此取得一組起始檔案最簡單的方法，就是執行一次互動式安裝（例如在 VM 中），然後將它寫入 `/root` 的內容複製出來：

| File | Required | Purpose |
|------|----------|---------|
| `user_configuration.json` | 是 | 磁碟、主機名稱、時區、鍵盤 |
| `user_credentials.json` | 是 | 使用者名稱與密碼雜湊 |
| `user_encrypt_installation.txt` | 否 | 當設定帶有 `disk_encryption` 區塊時為 `true` |
| `authorized_keys` | 否 | SSH 公鑰，每行一把 |
| `tailscale_authkey` | 否 | Tailscale 驗證金鑰，用於首次開機時加入你的 tailnet |

使用 `openssl passwd -6 "yourpassword"` 產生 `user_credentials.json` 所需的密碼雜湊。

git 提交所用的姓名與電子郵件並不屬於安裝的一部分。等機器啟動後再設定即可，例如透過 SSH 使用 `omarchy setup git --name "Jane Doe" --email jane@example.com`。

你也可以放入一個名為 `defer-provisioning` 的空檔案，來取代 `user_credentials.json`。這會執行與你可透過互動方式觸發的相同[為另一位擁有者做準備的安裝](02-getting-started.md)：機器會在不帶任何個人資料的情況下完成安裝，而第一個開機的人可以選擇自己的鍵盤並建立自己的使用者。這是映像製作設備所用的模式，在這種情況下，磁碟機上完全不應該攜帶任何人的憑證。

## SSH 存取

當 `authorized_keys` 存在時，安裝程式會將這些金鑰設定為使用者的 `~/.ssh/authorized_keys`、啟用 `sshd`，並在防火牆中為其開啟連接埠。（標準的 Omarchy 安裝隨附的 openssh 會停用服務並關閉連接埠，因此無人值守的機器否則將無法連線。）安裝程式只會加入你的金鑰——它不會放寬 SSH 守護程序的任何其他驗證設定。

當 `tailscale_authkey` 存在時，機器會改為在首次開機時加入你的 tailnet：Tailscale 會從 ISO 隨附的套件中安裝，防火牆會允許 tailnet 介面，而背景工作會在機器實際連上網路後立即執行加入動作，並持續重試直到成功為止。請使用可重複使用、預先授權的金鑰，這樣一份磁碟機映像就能供許多台機器使用。

## 建立 cidata 磁碟機

任何帶有正確標籤的檔案系統都可以。一份小型的 ISO 是最簡單的方法：

```bash
mkdir cidata
cp user_configuration.json user_credentials.json authorized_keys cidata/
genisoimage -output cidata.iso -volid cidata -joliet -rock cidata/
```

然後將它與 Omarchy ISO 一起連接到 VM。以下是一個完整的 Proxmox 範例：

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

開機順序刻意將磁碟列在第一位：空磁碟在首次開機時會直接略過並轉而使用 ISO，而安裝好的系統在此後永遠都會從磁碟開機。

## 兩點注意事項

加密的無人值守安裝並非完全無人值守——首次開機時，仍然需要有人輸入 LUKS 密碼。而且 `user_configuration.json` 中的 `disk_encryption` 區塊會以明文形式攜帶該密碼，因此請將由加密安裝所建立的 cidata 磁碟機，視為它本身所是的機密來對待。
