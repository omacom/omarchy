# 無人值守安裝

Omarchy ISO 可以在鍵盤前無人的情況下自行完成安裝。若安裝程式找到第二個標示為 `cidata` 且帶有其設定檔的磁碟，它會將這些檔案複製過來，完全跳過設定精靈，並自行重新開機進入已完成安裝的系統。不需要特殊的 ISO 建置，也不需要額外的開機選單項目 — 若沒有接上這類磁碟，一切都不會改變，你會看到一般的精靈。

這讓 Omarchy 非常適合作為一次性開發環境的基礎映像：在 Proxmox 中或使用 Packer 建立 VM，開機，走開，然後透過 SSH 連入。`cidata` 是 cloud-init 的 `NoCloud` 標籤，因此所有常見的虛擬化工具都已經知道如何接上這類磁碟。

## 設定檔案

這些檔案正是安裝程式自己的精靈所寫出的內容，因此取得一組起始檔案最簡單的方法，是執行一次互動式安裝（例如在 VM 裡），並將它寫入 `/root` 的內容複製出來：

| 檔案 | 必要 | 用途 |
|------|----------|---------|
| `user_configuration.json` | Yes | 磁碟、主機名稱、時區、鍵盤 |
| `user_credentials.json` | Yes | 使用者名稱與密碼雜湊，以及加密安裝所需的 LUKS 通行碼 |
| `user_encrypt_installation.txt` | No | 當設定帶有 `disk_encryption` 區塊時為 `true` |
| `authorized_keys` | No | SSH 公鑰，每行一個 |
| `tailscale_authkey` | No | 用於在首次開機時加入你的 tailnet 的 Tailscale auth key |

使用 `openssl passwd -6 "yourpassword"` 產生 `user_credentials.json` 所需的密碼雜湊。

git 提交所用的姓名與電子郵件不屬於安裝的一部分。等機器啟動完成後再設定，例如透過 SSH 使用 `omarchy setup git --name "Jane Doe" --email jane@example.com`。

你也可以放入一個名為 `defer-provisioning` 的空白檔案，以取代 `user_credentials.json`。這會執行與你可互動觸發的相同的[為另一位擁有者做準備的安裝](02-getting-started.md)：機器會在不帶任何個人資料的情況下完成安裝，而第一個開機的人可以選擇自己的鍵盤並建立自己的使用者。這是製作映像的設備所用的模式，在這種情況下，該磁碟根本不應該帶有任何人的憑證。

## SSH 存取

當 `authorized_keys` 存在時，安裝會將這些金鑰設定為使用者的 `~/.ssh/authorized_keys`，啟用 `sshd`，並在防火牆開放它。（Omarchy 的標準安裝會隨附 openssh，但該服務處於停用狀態且連接埠關閉，因此無人值守的機器否則將無法連入。）安裝只會加入你的金鑰 — 它不會放寬 SSH 守護程式的任何其他驗證設定。

當 `tailscale_authkey` 存在時，機器則會在首次開機時加入你的 tailnet：Tailscale 會從 ISO 隨附的套件安裝，防火牆會允許 tailnet 介面，而一個背景工作會在機器實際連上網路後立即執行加入，並持續重試直到成功。請使用可重複使用、預先授權的金鑰，這樣一個磁碟映像就能服務許多機器。

## 建立 cidata 磁碟

任何具有正確標籤的檔案系統都可以。一個小型的 ISO 是簡單的方法：

```bash
mkdir cidata
cp user_configuration.json user_credentials.json authorized_keys cidata/
genisoimage -output cidata.iso -volid cidata -joliet -rock cidata/
```

接著將它與 Omarchy ISO 一起接上 VM。以下是一個完整的 Proxmox 範例：

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

開機順序故意將磁碟列在第一位：空磁碟在第一次開機時會落空並轉到 ISO，而安裝完成的系統在此之後將一律從磁碟開機。

## 兩個注意事項

加密的無人值守安裝並非完全無人值守 — 首次開機時仍需要有人輸入 LUKS 通行碼。而該通行碼位於 `user_credentials.json` 的最上層，欄位為 `encryption_password` — archinstall 是從那裡讀取它，而不是從 `user_configuration.json` 中的 `disk_encryption` 區塊讀取 — 因此，凡是源自加密安裝的 cidata 磁碟，都請把它當成機密對待，因為它確實是機密。
