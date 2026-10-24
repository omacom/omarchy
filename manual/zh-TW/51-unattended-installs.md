# 無人值守安裝

Omarchy ISO 可以在無人在鍵盤旁的情況下自行完成安裝。如果安裝程式找到一顆標籤為 `cidata`、攜帶其設定檔的第二磁碟，它就會把設定檔複製出來，完全跳過設定精靈，並自己重新開機進入完成的系統。不需要特殊建置的 ISO，也不需要額外的開機選單項目——沒有接上這類磁碟時，一切照舊，你會得到一般的精靈流程。

這讓 Omarchy 非常適合作為拋棄式開發環境的基礎映像：在 Proxmox 中或用 Packer 建立一台 VM，開機，轉身離開，再用 SSH 連進去。`cidata` 是 cloud-init 的 `NoCloud` 標籤，所以所有常見的虛擬化工具都已經知道如何掛接這種磁碟。

## 設定檔案

這些檔案正是安裝程式自己的精靈所寫出的東西，所以取得一套起手檔案最簡單的方法，是做一次互動式安裝（例如在 VM 中），並把所寫出的檔案複製到 `/root`：

| File | Required | Purpose |
|------|----------|---------|
| `user_configuration.json` | Yes | 磁碟、主機名稱、時區、鍵盤 |
| `user_credentials.json` | Yes | 使用者名稱和密碼雜湊 |
| `user_full_name.txt` | No | Git 全名 |
| `user_email_address.txt` | No | Git 電子郵件 |
| `user_encrypt_installation.txt` | No | 當設定攜帶 `disk_encryption` 區塊時為 `true` |
| `authorized_keys` | No | SSH 公開金鑰，每行一把 |
| `tailscale_authkey` | No | 首次開機時加入你的 tailnet 用的 Tailscale auth key |

用 `openssl passwd -6 "yourpassword"` 為 `user_credentials.json` 產生密碼雜湊。

你也可以放一個名為 `defer-provisioning` 的空檔案來代替 `user_credentials.json`。這會執行和你在互動模式下可觸發的相同[為另一位擁有者準備的安裝](02-getting-started.md)：機器在安裝時不帶任何個人資料，第一次開機的人可以挑選自己的鍵盤並建立自己的使用者。那正是映像製作環境所需要的模式，在那種場合磁碟上根本不該帶任何人的憑證。

## SSH 存取

當 `authorized_keys` 存在時，安裝會把這些金鑰設定為使用者的 `~/.ssh/authorized_keys`，啟用 `sshd`，並為它開啟防火牆。（原版 Omarchy 安裝置有 openssh，但服務停用、連接埠關閉，所以無人值守的機器否則會連不進來。）安裝只會加入你的金鑰——它不會放寬 SSH 守護程式其他任何驗證設定。

當 `tailscale_authkey` 存在時，機器改為在首次開機時加入你的 tailnet：Tailscale 會從 ISO 內附的套件安裝，防火牆會允許 tailnet 介面，而一個背景工作會在機器真正連上網路後立刻執行加入動作，並持續重試直到成功。使用一把可重複使用、預先授權的金鑰，這樣一份磁碟映像就能服務許多台機器。

## 建立 cidata 磁碟

任何帶有正確標籤的檔案系統都行。一份小小的 ISO 就是簡單的方法：

```bash
mkdir cidata
cp user_configuration.json user_credentials.json authorized_keys cidata/
genisoimage -output cidata.iso -volid cidata -joliet -rock cidata/
```

然後把它連同 Omarchy ISO 一起掛接給 VM。以下是一個完整的 Proxmox 範例：

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

開機順序故意把磁碟排在第一位：第一次開機時，空的磁碟會自動轉向 ISO，而安裝好的系統之後就會永遠從磁碟開機。

## 兩個注意事項

加密的無人值守安裝並不是完全無人值守——首次開機時還是得有人輸入 LUKS 密碼。而 `user_configuration.json` 中的 `disk_encryption` 區塊以明文攜帶了那個密碼，所以請把以加密安裝建立的 cidata 磁碟當作機密看待，它本來就如此。
