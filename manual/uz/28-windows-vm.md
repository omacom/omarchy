# Windows VM

Omarchy x86_64 mashinalarida Docker VM orqali Windows ni ishga tushirishning oson usulini taklif qiladi. Uni Omarchy menyusidagi (`Super + Space`) _Install > Windows_ orqali o'rnatishingiz mumkin.

Mashinangizda buning uchun KVM virtualizatsiyasi kerak bo'ladi, aksariyat mashinalarda u bor — lekin ba'zan u BIOS da o'chirilgan bo'ladi, shunday bo'lsa, o'rnatuvchi sizga bu haqda aytadi. Sizga diskdagi joy ham kerak bo'ladi: Windows ga ajratgan hajmingiz, ustiga tasvirning o'zi uchun taxminan 10GB.

O'rnatuvchi qancha RAM, nechta CPU yadrosi va qancha disk ajratishni so'raydi (64GB yoki undan ko'pi — oqilona minimum), so'ng Windows foydalanuvchi nomi va parolini so'raydi. Ularni bo'sh qoldirsangiz, `docker` / `admin` ni olasiz. Yuklab olish biroz vaqt oladi — 10-15 daqiqa odatiy hol — va jarayonni brauzerda `http://127.0.0.1:8006` manzilida kuzatishingiz mumkin. Konsolni ochishdan oldin brauzer xuddi shu foydalanuvchi nomi va parolni so'raydi.

 ![windows-vm](images/windows-vm.webp)

## Undan foydalanish

U o'rnatilgach, ilovalarni ishga tushirgichdan _Windows_ ni ishga tushiring. Bu, agar VM allaqachon ishlamayotgan bo'lsa, uni ishga tushiradi va sizni RDP orqali, to'liq ekranda ulaydi. Sovuq ishga tushirishda unga 15-30 soniya bering.

RDP sessiyasi ovozni, mikrofoningizni va umumiy almashish buferini olib o'tadi, shuning uchun Linux va Windows o'rtasida matnni nusxalash shunchaki ishlaydi. Ekran o'lchami oynangizga moslashadi va Omarchy displey masshtabini ham o'tkazib yuboradi, shuning uchun HiDPI ekranda u xira chalkashlikka aylanmaydi.

RDP oynasini yopganingizda, VM avtomatik ravishda o'chadi. Agar uni ishlab turgan holatda qoldirishni afzal ko'rsangiz — aytaylik, ichkarida biror narsa ishlashda davom etayotgan bo'lsa — uning o'rniga uni `omarchy windows vm launch --keep-alive` bilan ishga tushiring.

Qolgan boshqaruv elementlari ham xuddi shu buyruqda:

```bash
omarchy windows vm status    # is it running?
omarchy windows vm stop      # shut it down
omarchy windows vm launch    # start and connect
```

## Fayllarni almashish

Uy katalogingizdagi `~/Windows` katalogi avtomatik ravishda VM bilan almashiladi. Fayllar Windows uchun ochiq bo'lishini istasangiz, ularni o'sha yerga qo'ying. VM fayl tizimingizning boshqa hech bir qismiga kira olmaydi, shuning uchun Windows tomondan keladigan har qanday yomon narsadan himoyalangansiz. Uning o'z virtual diski `~/.windows` da mavjud.

Ushbu tanish uy yo'llari o'z fayl tizimlarida qoladi. Ular sizga tegishli kataloglarga symlinklar ham bo'lishi mumkin, bu virtual disk kattaroq diskda joylashganda foydali. O'rnatuvchi bo'sh joyni `~/.windows` ni haqiqatan o'z ichiga olgan fayl tizimida o'lchaydi, bu har doim ham uy katalogingizni o'z ichiga olgan fayl tizimi bo'lavermaydi.

Disk va almashiladigan yo'llarni alohida, bir-biri bilan kesishmaydigan kataloglar sifatida saqlang. Olib tashlash ataylab disk katalogini bo'shatadi, lekin almashiladigan katalogni saqlab qoladi. O'chirishdan darhol oldin Omarchy chegaralangan tekshiruvni amalga oshiradi va agar bu tekshiruvning vaqti tugasa yoki ikkita daraxt alohida ekanini isbotlay olmasa, hech narsani olib tashlashdan bosh tortadi.

VM ishga tushishidan oldin Omarchy o'sha ikkita katalogni ochadi va mahkamlaydi, so'ng aniq katalog inodelarini `/var/lib/omarchy/windows/mounts` ostidagi xususiy, har bir foydalanuvchiga mo'ljallangan langarlarga bind-mount qiladi. Docker faqat root bilan himoyalangan o'sha langarlarni ko'radi. Bu maxsus disk joylashuvlarini saqlab qoladi, shu bilan birga siz sifatida ishlayotgan boshqa jarayon imtiyozli konteyner tekshirilgan yo'lni ishlatishidan oldin uni almashtirib qo'yishining oldini oladi. Mavjud disk va almashiladigan kataloglar migratsiya paytida `0700` rejimiga qadar kuchaytiriladi, shunda boshqa mahalliy hisoblar ularning tarkibini ko'rib chiqa olmaydi.

VM portlari faqat localhost ga bog'langan, shuning uchun tarmog'ingizdagi hech narsa Windows mashinasiga kira olmaydi. Veb-konsol ham sozlangan Windows foydalanuvchi nomi va parolini talab qiladi, bu boshqa mahalliy hisobning port 8006 orqali VM ni boshqarishiga to'sqinlik qiladi.

## Cheklovlar va litsenziyalash

Bu sozlamada GPU passthrough yo'q, shuning uchun u o'yin o'ynash yoki videoni tahrirlash uchun mos emas. U Microsoft Office ni yoki sizga mutlaqo kerak bo'lgan boshqa har qanday narsani ishga tushirishning ajoyib usuli.

O'rnatiladigan versiya — Windows 11 Pro, faollashtirilmagan. Cheklangan funksiyalardan foydalanish uchun sizga o'zingizning litsenziya kalitingiz kerak bo'ladi.

Agar bu kompyuter Windows bilan birga kelgan bo'lsa, Omarchy o'rnatilgandan keyin ham OEM kaliti firmware da qoladi. Uni `omarchy windows key` bilan chop eting. Bu kalit ushbu mashinaga bog'langan — u ushbu apparatda qayta o'rnatilgan Windows ni faollashtiradi, lekin odatda VM ni faollashtirmaydi.

Resurslar taqsimotini keyinroq terminalda `omarchy windows vm install` ni ishga tushirib o'zgartirishingiz mumkin, bu sizning javoblaringiz asosida VM konfiguratsiyasini qayta yozadi. Compose faylining o'zi endi `/var/lib/omarchy/windows/docker-compose.yml` da joylashgan va root ga tegishli — bu ataylab qilingan, shunda siz sifatida ishlayotgan jarayon uni qayta yoza olmaydi va imtiyozli ishga tushirish butun diskingizni konteynerga mount qilishiga erisha olmaydi. Agar uni qo'lda tahrir qilishingiz kerak bo'lsa (masalan, USB qurilmasini mount qilish uchun), uni `sudo` bilan tahrir qiling va barcha variantlarni [Dockur Windows loyihasida](https://github.com/dockur/windows) ko'ring.

Hammasidan xalos bo'lish uchun Omarchy menyusidan _Remove > Windows_ ni ishlating. Bu `~/.windows` dagi VM diskini va Windows ichida o'rnatilgan hamma narsani o'chiradi, shuning uchun kerakli narsalaringizni avval VM dan nusxalab oling. Almashiladigan `~/Windows` jildingizga tegilmaydi.
