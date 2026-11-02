# غیر حاضر انسٹالز

Omarchy ISO خود کو انسٹال کر سکتی ہے جب کی بورڈ پر کوئی موجود نہ ہو۔ اگر انسٹالر کو `cidata` کے لیبل والی دوسری ڈرائیو مل جائے جس پر اس کی کنفیگریشن فائلیں موجود ہوں، تو وہ انہیں کاپی کر لیتا ہے، سیٹ اپ wizard کو مکمل طور پر چھوڑ دیتا ہے، اور خود ہی تیار سسٹم میں ری بوٹ ہو جاتا ہے۔ کوئی خاص ISO build نہیں، کوئی اضافی بوٹ مینیو انٹری نہیں — ایسی کوئی ڈرائیو منسلک نہ ہو تو کچھ نہیں بدلتا اور آپ کو معمول کا wizard ملتا ہے۔

اس سے Omarchy عارضی dev ماحول کے لیے ایک بہترین base image بن جاتی ہے: Proxmox میں یا Packer کے ساتھ ایک VM بنائیں، اسے بوٹ کریں، وہاں سے چل دیں، SSH سے اندر آ جائیں۔ `cidata` اصل میں cloud-init کا `NoCloud` لیبل ہے، اس لیے تمام عام virtualization ٹولنگ پہلے سے جانتی ہے کہ ایسی ڈرائیو کیسے منسلک کرنی ہے۔

## کنفیگریشن فائلیں

یہ فائلیں بالکل وہی ہیں جو انسٹالر کا اپنا wizard لکھتا ہے، اس لیے ابتدائی سیٹ حاصل کرنے کا سب سے آسان طریقہ یہ ہے کہ ایک انٹرایکٹو انسٹال چلائیں (مثلاً ایک VM میں) اور جو کچھ اس نے `/root` میں لکھا ہو اسے کاپی کر لیں:

| File | Required | Purpose |
|------|----------|---------|
| `user_configuration.json` | جی ہاں | ڈسک، hostname، timezone، کی بورڈ |
| `user_credentials.json` | جی ہاں | یوزر نیم اور پاس ورڈ hash |
| `user_encrypt_installation.txt` | نہیں | `true` جب کنفیگریشن میں `disk_encryption` بلاک موجود ہو |
| `authorized_keys` | نہیں | SSH پبلک کیز، ہر سطر میں ایک |
| `tailscale_authkey` | نہیں | پہلے بوٹ پر آپ کے tailnet میں شامل ہونے کے لیے Tailscale auth key |

`user_credentials.json` کے لیے پاس ورڈ hash اس کمانڈ سے بنائیں: `openssl passwd -6 "yourpassword"`۔

git commits کے لیے نام اور ای میل انسٹال کا حصہ نہیں ہیں۔ مشین تیار ہو جانے کے بعد انہیں ایک بار سیٹ کر دیں، مثلاً SSH کے ذریعے، اس کمانڈ کے ساتھ: `omarchy setup git --name "Jane Doe" --email jane@example.com`۔

آپ `user_credentials.json` کی جگہ `defer-provisioning` نامی خالی فائل بھی رکھ سکتے ہیں۔ اس سے وہی [دوسرے مالک کے لیے تیاری والا انسٹال](02-getting-started.md) چلتا ہے جسے آپ انٹرایکٹو طور پر بھی شروع کر سکتے ہیں: مشین بغیر کسی ذاتی تفصیلات کے انسٹال ہو جاتی ہے، اور جو بھی اسے پہلے بوٹ کرے وہ اپنا کی بورڈ منتخب کرتا ہے اور اپنا یوزر بناتا ہے۔ یہ imaging rigs کے لیے موڈ ہے، جہاں ڈرائیو پر کسی کی بھی اسناد موجود ہی نہیں ہونی چاہئیں۔

## SSH رسائی

جب `authorized_keys` موجود ہو تو انسٹال ان کیز کو یوزر کی `~/.ssh/authorized_keys` کے طور پر سیٹ کر دیتا ہے، `sshd` کو فعال کرتا ہے، اور اس کے لیے firewall کھول دیتا ہے۔ (عام Omarchy انسٹال میں openssh آتا ہے لیکن سروس غیر فعال اور پورٹ بند رہتی ہے، اس لیے غیر حاضر مشین تک ورنہ پہنچا ہی نہ جا سکتا۔) انسٹال صرف آپ کی کیز شامل کرتا ہے — یہ SSH daemon کی دیگر توثیقی سیٹنگز میں سے کسی کو بھی ڈھیلا نہیں کرتا۔

جب `tailscale_authkey` موجود ہو تو اس کے بجائے مشین پہلے بوٹ پر آپ کے tailnet میں شامل ہو جاتی ہے: Tailscale ISO کے بنڈل شدہ packages سے انسٹال ہوتا ہے، firewall tailnet انٹرفیس کی اجازت دیتا ہے، اور ایک background job مشین کے اصل میں نیٹ ورک سے جڑتے ہی شامل ہونے کا عمل چلا دیتا ہے، کامیابی تک بار بار کوشش کرتا رہتا ہے۔ دوبارہ استعمال کے قابل، پہلے سے منظور شدہ key استعمال کریں تاکہ ایک ڈرائیو image کئی مشینوں کے کام آ سکے۔

## cidata ڈرائیو بنانا

درست لیبل والا کوئی بھی filesystem کام کرے گا۔ ایک چھوٹی ISO آسان طریقہ ہے:

```bash
mkdir cidata
cp user_configuration.json user_credentials.json authorized_keys cidata/
genisoimage -output cidata.iso -volid cidata -joliet -rock cidata/
```

پھر اسے Omarchy ISO کے ساتھ VM سے منسلک کر دیں۔ یہ رہی Proxmox کی مکمل مثال:

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

بوٹ order میں ڈسک جان بوجھ کر پہلے درج ہے: پہلے بوٹ پر خالی ڈسک آگے بڑھ کر ISO تک جا پہنچتی ہے، اور اس کے بعد انسٹال شدہ سسٹم ہمیشہ ڈسک سے بوٹ ہوتا ہے۔

## دو تنبیہات

Encrypted غیر حاضر انسٹال مکمل طور پر غیر حاضر نہیں ہوتے — پہلے بوٹ پر کسی کو پھر بھی LUKS passphrase ٹائپ کرنا پڑتا ہے۔ اور `user_configuration.json` میں `disk_encryption` بلاک اس passphrase کو سادہ متن میں رکھتا ہے، لہٰذا encrypted انسٹال سے بنی cidata ڈرائیو کو اسی راز کی طرح سمجھیں جو وہ واقعی ہے۔
