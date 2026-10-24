# Nazoratsiz oʻrnatishlar

Omarchy ISO klaviaturada hech kim boʻlmasa ham oʻzini oʻrnata oladi. Agar oʻrnatuvchi konfiguratsiya fayllarini olib yuruvchi `cidata` deb etiketlangan ikkinchi drayvni topsa, ularni nusxalab oladi, sozlash ustasini butunlay oʻtkazib yuboradi va oʻzi yopilgan tizimga qayta yuklanadi. Maxsus ISO qurilishi yoʻq, qoʻshimcha yuklash menyusi yozuvi yoʻq — bunday drayv biriktirilmagan boʻlsa, hech narsa oʻzgarmaydi va siz oddiy ustani olasiz.

Bu Omarchy ni bir martalik dev muhitlari uchun asosiy tasvir sifatida ajoyib qiladi: Proxmox da yoki Packer bilan VM yarating, uni yuklang, keting, SSH kiring. `cidata` cloud-init `NoCloud` etiketi, shuning uchun barcha keng tarqalgan virtualizatsiya vositalari allaqachon bunday drayvni qanday biriktirishni biladi.

## Konfiguratsiya fayllari

Fayllar oʻrnatuvchining oʻz ustasi yozganlarining aynan oʻzi, shuning uchun boshlanish toʻplamini olishning eng oson yoʻli bitta interaktiv oʻrnatishni (aytaylik, VM da) ishlatish va u `/root` ga yozganini nusxalashdir:

| Fayl | Kerak | Maqsad |
|------|----------|---------|
| `user_configuration.json` | Ha | Disk, hostname, vaqt mintaqasi, klaviatura |
| `user_credentials.json` | Ha | Foydalanuvchi nomi va parol xeshi |
| `user_full_name.txt` | Yoʻq | Git toʻliq nomi |
| `user_email_address.txt` | Yoʻq | Git email |
| `user_encrypt_installation.txt` | Yoʻq | Konfiguratsiya `disk_encryption` blokini olib yurganda `true` |
| `authorized_keys` | Yoʻq | SSH ochiq kalitlar, har qatorda bitta |
| `tailscale_authkey` | Yoʻq | Birinchi yuklashda tailnetingizga qoʻshilish uchun Tailscale auth kaliti |

`user_credentials.json` uchun parol xeshini `openssl passwd -6 "yourpassword"` bilan yarating.

Siz shuningdek `user_credentials.json` oʻrniga `defer-provisioning` deb nomlangan boʻsh faylni tashlashingiz mumkin. Bu siz interaktiv tarzda ishga tushirishingiz mumkin boʻlgan bir xil [boshqa-egaga-tayyor oʻrnatishni](02-getting-started.md) ishlatadi: mashina shaxsiy tafsilotsiz oʻrnatiladi va uni birinchi yuklagan kim boʻlsa, uning klaviaturasini tanlaydi va foydalanuvchini yaratadi. Bu tasvir riglariga rejim, unda drayv hech qanday kimsa maʼlumotlarini olib yurishi kerak emas.

## SSH kirish

`authorized_keys` mavjud boʻlganda, oʻrnatish kalitlarni foydalanuvchining `~/.ssh/authorized_keys` sifatida sozlaydi, `sshd` ni yoqadi va u uchun firewallni ochadi. (Birja Omarchy oʻrnatishi xizmat oʻchirilgan va port yopiq holatda openssh ni joʻnatadi, shuning uchun nazoratsiz mashina boshqacha boʻlmaganda yetib boʻlmaydigan boʻlardi.) Oʻrnatish faqat kalitlaringizni qoʻshadi — u SSH demonining boshqa autentifikatsiya sozlamalaridan hech birini yumshatmaydi.

`tailscale_authkey` mavjud boʻlganda, mashina uning oʻrniga birinchi yuklashda tarmogʻingizga qoʻshiladi: Tailscale ISO ning birlashtirilgan paketlaridan oʻrnatiladi, firewall tailnet interfeysiga ruxsat beradi va orqa fon ishi mashina aslida tarmoqqa ega boʻlishi bilanoq qoʻshilishni ishlatadi, muvaffaqiyatli boʻlguncha qayta urinib koʻradi. Bitta drayv tasviri koʻp mashinlarga xizmat qila olishi uchun qayta ishlatiladigan, oldindan avtorizatsiya qilingan kalitdan foydalaning.

## cidata drayvini qurish

Toʻgʻri etiketga ega har qanday fayl tizimi ishlaydi. Kichkina ISO oson yoʻl:

```bash
mkdir cidata
cp user_configuration.json user_credentials.json authorized_keys cidata/
genisoimage -output cidata.iso -volid cidata -joliet -rock cidata/
```

Keyin uni Omarchy ISO bilan birga VM ga biriktiring. Mana toʻliq Proxmox misoli:

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

Yuklash tartibi maqsadda diskni birinchi roʻyxatlaydi: boʻsh disk birinchi yuklashda ISO ga tushadi va oʻrnatilgan tizim shundan keyin doimo diskdan yuklanadi.

## Ikki ogohlantirish

Shifrlangan nazoratsiz oʻrnatishlar toʻliq nazoratsiz emas — kimdir hali birinchi yuklashda LUKS parolini yozishi kerak. Va `user_configuration.json` dagi `disk_encryption` bloki ushbu parolni oddiy matnda olib yuradi, shuning uchun shifrlangan oʻrnatilishdan qurilgan cidata drayvini u boʻlgan sir kabi muomala qiling.
