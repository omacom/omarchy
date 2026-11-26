# غیر نگرانی شدہ تنصیبات

Omarchy ISO کی بورڈ پر کسی کے موجود ہوئے بغیر خود کو تنصیب کر سکتا ہے۔ اگر installer کو `cidata` لیبل والی دوسری drive مل جائے جس پر اس کی configuration files موجود ہوں، تو وہ انہیں نقل کر لیتا ہے، setup wizard کو مکمل طور پر چھوڑ دیتا ہے، اور خود ہی تیار system میں reboot ہو جاتا ہے۔ نہ کوئی خصوصی ISO build، نہ کوئی اضافی boot menu entry — ایسی drive منسلک نہ ہو تو کچھ نہیں بدلتا اور آپ کو معمول کا wizard ہی ملتا ہے۔

یہ Omarchy کو disposable dev environments کے لیے base image کے طور پر بہترین بناتا ہے: Proxmox میں یا Packer کے ساتھ VM بنائیں، اسے boot کریں، چلے جائیں، SSH کے ذریعے داخل ہو جائیں۔ `cidata` cloud-init کا `NoCloud` لیبل ہے، اس لیے تمام عام virtualization tooling پہلے ہی جانتی ہے کہ ایسی drive کیسے منسلک کرنی ہے۔

## configuration کی فائلیں

یہ فائلیں بالکل وہی ہیں جو installer کا اپنا wizard لکھتا ہے، اس لیے ابتدائی set حاصل کرنے کا سب سے آسان طریقہ ایک interactive install چلانا ہے (مثلاً VM میں) اور اس نے `/root` میں جو کچھ لکھا ہے اسے نقل کر لینا ہے:

| فائل | ضروری | مقصد |
|------|----------|---------|
| `user_configuration.json` | ہاں | Disk، hostname، timezone، keyboard |
| `user_credentials.json` | ہاں | صارف نام اور password hash، اور encrypted install کے لیے LUKS passphrase |
| `user_encrypt_installation.txt` | نہیں | `true` جب configuration میں `disk_encryption` block ہو |
| `authorized_keys` | نہیں | SSH public keys، فی سطر ایک |
| `tailscale_authkey` | نہیں | پہلی boot پر آپ کے tailnet میں شامل ہونے کے لیے Tailscale auth key |

`user_credentials.json` کے لیے password hash `openssl passwd -6 "yourpassword"` کے ساتھ بنائیں۔

git commits کے لیے نام اور email تنصیب کا حصہ نہیں ہیں۔ مشین چل پڑے تو انہیں ایک بار سیٹ کر دیں، مثلاً SSH پر، `omarchy setup git --name "Jane Doe" --email jane@example.com` کے ساتھ۔

آپ `user_credentials.json` کی جگہ `defer-provisioning` نامی خالی فائل بھی رکھ سکتے ہیں۔ یہ وہی [دوسرے مالک کے لیے تیاری والی تنصیب](02-getting-started.md) چلاتا ہے جو آپ interactively بھی شروع کر سکتے ہیں: مشین بغیر کسی ذاتی تفصیلات کے تنصیب ہو جاتی ہے، اور جو اسے پہلے boot کرتا ہے وہ اپنا keyboard منتخب کرتا ہے اور اپنا user بناتا ہے۔ یہ imaging rigs کے لیے mode ہے، جہاں drive پر کسی کے credentials بالکل نہیں ہونے چاہئیں۔

## SSH تک رسائی

جب `authorized_keys` موجود ہو تو تنصیب keys کو user کی `~/.ssh/authorized_keys` کے طور پر سیٹ کر دیتی ہے، `sshd` کو فعال کرتی ہے، اور اس کے لیے firewall کھول دیتی ہے۔ (عام Omarchy تنصیب openssh کے ساتھ آتی ہے جس کی service غیر فعال اور port بند ہوتا ہے، اس لیے غیر نگرانی شدہ مشین بصورتِ دیگر ناقابلِ رسائی رہتی۔) تنصیب صرف آپ کی keys شامل کرتی ہے — یہ SSH daemon کی دیگر authentication settings میں سے کسی کو ڈھیلا نہیں کرتی۔

جب `tailscale_authkey` موجود ہو تو اس کے بجائے مشین پہلی boot پر آپ کے tailnet میں شامل ہو جاتی ہے: Tailscale ISO کے bundled packages سے تنصیب ہوتا ہے، firewall tailnet interface کی اجازت دیتا ہے، اور ایک background job جیسے ہی مشین کو واقعی network ملتا ہے join چلا دیتا ہے، کامیابی تک دوبارہ کوشش کرتا رہتا ہے۔ reusable، pre-authorized key استعمال کریں تاکہ ایک drive image بہت سی مشینوں کے کام آ سکے۔

## cidata drive بنانا

درست لیبل والا کوئی بھی filesystem چل جائے گا۔ چھوٹا سا ISO آسان طریقہ ہے:

```bash
mkdir cidata
cp user_configuration.json user_credentials.json authorized_keys cidata/
genisoimage -output cidata.iso -volid cidata -joliet -rock cidata/
```

پھر اسے Omarchy ISO کے ساتھ VM سے منسلک کر دیں۔ یہ رہی مکمل Proxmox مثال:

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

boot order میں disk جان بوجھ کر پہلے درج ہے: پہلی boot پر خالی disk آگے بڑھ کر ISO تک پہنچ جاتی ہے، اور اس کے بعد تنصیب شدہ system ہمیشہ disk سے boot ہوتا ہے۔

## دو تنبیہات

Encrypted غیر نگرانی شدہ تنصیبات مکمل طور پر غیر نگرانی شدہ نہیں ہوتیں — پہلی boot پر کسی کو پھر بھی LUKS passphrase لکھنا پڑتا ہے۔ اور وہ passphrase `user_credentials.json` کی top level پر `encryption_password` کے طور پر جاتی ہے — archinstall اسے وہیں پڑھتا ہے، `user_configuration.json` میں `disk_encryption` block سے نہیں — اس لیے encrypted install سے بنی cidata drive کو وہی راز سمجھ کر رکھیں جو یہ ہے۔
