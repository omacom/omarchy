# Nazoratsiz o'rnatishlar

Omarchy ISO hech kim klaviatura oldida bo'lmasa ham o'zini o'zi o'rnatishi mumkin. Agar o'rnatuvchi konfiguratsiya fayllarini o'z ichiga olgan `cidata` yorlig'li ikkinchi diskni topsa, u ularni nusxalaydi, sozlash ustasini butunlay o'tkazib yuboradi va mustaqil ravishda tayyor tizimga qayta yuklanadi. Maxsus ISO yig'ilishi ham, qo'shimcha yuklash menyusi bandi ham kerak emas — bunday disk ulanmagan bo'lsa, hech narsa o'zgarmaydi va siz oddiy ustani olasiz.

Bu Omarchy ni bir martalik dev muhitlari uchun ajoyib bazaviy obrazga aylantiradi: Proxmox da yoki Packer bilan VM yarating, uni yuklang, keting, SSH orqali kiring. `cidata` — bu cloud-init `NoCloud` yorlig'i, shuning uchun barcha keng tarqalgan virtualizatsiya vositalari bunday diskni qanday ulashni allaqachon biladi.

## Konfiguratsiya fayllari

Fayllar aynan o'rnatuvchining o'z ustasi yozadigan fayllardir, shuning uchun boshlang'ich to'plamni olishning eng oson yo'li — bitta interaktiv o'rnatishni amalga oshirish (masalan, VM da) va u `/root` ga yozgan narsalarni nusxalashdir:

| Fayl | Majburiy | Maqsadi |
|------|----------|---------|
| `user_configuration.json` | Ha | Disk, xost nomi, vaqt mintaqasi, klaviatura |
| `user_credentials.json` | Ha | Foydalanuvchi nomi va parol xeshi |
| `user_encrypt_installation.txt` | Yo'q | Konfiguratsiyada `disk_encryption` bloki bo'lganda `true` |
| `authorized_keys` | Yo'q | SSH ochiq kalitlari, har qatorda bittadan |
| `tailscale_authkey` | Yo'q | Birinchi yuklanishda tailnet ingizga qo'shilish uchun Tailscale auth kaliti |

`user_credentials.json` uchun parol xeshini `openssl passwd -6 "yourpassword"` bilan yarating.

Git commit lari uchun ism va email o'rnatishning bir qismi emas. Mashina ishga tushgandan so'ng ularni o'rnating, masalan SSH orqali, `omarchy setup git --name "Jane Doe" --email jane@example.com` bilan.

Shuningdek, `user_credentials.json` o'rniga `defer-provisioning` nomli bo'sh faylni ham tashlab qo'yishingiz mumkin. Bu siz interaktiv tarzda ishga tushirishingiz mumkin bo'lgan o'sha [boshqa egasi uchun tayyorlash o'rnatishini](02-getting-started.md) bajaradi: mashina hech qanday shaxsiy ma'lumotlarsiz o'rnatiladi va uni birinchi bo'lib yuklagan kishi klaviaturasini tanlaydi va o'z foydalanuvchisini yaratadi. Bu obraz yaratish stendlari uchun rejim bo'lib, bunda disk umuman hech kimning hisob ma'lumotlarini saqlamasligi kerak.

## SSH kirishi

`authorized_keys` mavjud bo'lganda, o'rnatish kalitlarni foydalanuvchining `~/.ssh/authorized_keys` sifatida o'rnatadi, `sshd` ni yoqadi va uning uchun firewall ni ochadi. (Standart Omarchy o'rnatishi openssh ni xizmati o'chirilgan va porti yopiq holda yetkazib beradi, shuning uchun nazoratsiz mashinaga aks holda umuman kirib bo'lmasdi.) O'rnatish faqat kalitlaringizni qo'shadi — u SSH daemon ining boshqa autentifikatsiya sozlamalarining hech birini yumshatmaydi.

`tailscale_authkey` mavjud bo'lganda, mashina buning o'rniga birinchi yuklanishda tailnet ingizga qo'shiladi: Tailscale ISO ning to'plamdagi paketlaridan o'rnatiladi, firewall tailnet interfeysiga ruxsat beradi va fon vazifasi mashinada haqiqatan ham tarmoq paydo bo'lishi bilan qo'shilishni ishga tushiradi, muvaffaqiyatga erishguncha qayta urinib turadi. Bitta disk obrazi ko'plab mashinalarga xizmat qilishi uchun qayta ishlatiladigan, oldindan avtorizatsiya qilingan kalitdan foydalaning.

## cidata diskini yaratish

To'g'ri yorliqqa ega har qanday fayl tizimi ishlaydi. Kichik ISO — eng oson yo'li:

```bash
mkdir cidata
cp user_configuration.json user_credentials.json authorized_keys cidata/
genisoimage -output cidata.iso -volid cidata -joliet -rock cidata/
```

Keyin uni Omarchy ISO bilan birga VM ga ulang. Mana to'liq Proxmox misoli:

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

Yuklash tartibida disk ataylab birinchi ko'rsatilgan: bo'sh disk birinchi yuklanishda ISO ga o'tib ketadi va o'rnatilgan tizim undan keyin har doim diskdan yuklanadi.

## Ikkita ogohlantirish

Shifrlangan nazoratsiz o'rnatishlar to'liq nazoratsiz emas — birinchi yuklanishda kimdir baribir LUKS parol iborasini kiritishi kerak. Va `user_configuration.json` dagi `disk_encryption` bloki o'sha parol iborasini ochiq matnda saqlaydi, shuning uchun shifrlangan o'rnatishdan yaratilgan cidata diskiga u bo'lgan sirdek munosabatda bo'ling.
