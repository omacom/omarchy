# Windows VM

Omarchy Windows ni Docker VM orqali ishlatishning oson usulini taklif etadi. Uni Omarchy menyusidagi (`Super + Space`) _Oʻrnatish > Windows_ yordamida oʻrnatishingiz mumkin.

Buning uchun mashinangizga KVM virtualizatsiyasi kerak, koʻpchiligida bor — lekin u baʼzan BIOS da oʻchirilgan boʻladi va oʻrnatuvchi agar shunday boʻlsa sizga aytadi. Siz disk joyini ham xohlaysiz: Windows ga beradigan har qanday narsangiz, plyus obrazning oʻzi uchun taxminan 10GB.

Oʻrnatuvchi qancha RAM, nechta CPU yadrosi va qancha disk topshirish kerakligini soʻraydi (64GB yoki undan koʻp oqilona minimum), keyin Windows foydalanuvchi nomi va parolini soʻraydi. Ularni boʻsh qoldiring va siz `docker` / `admin` olasiz. Yuklab olish bir oz vaqt oladi — 10–15 daqiqa normal — va jarayonni brauzerda shu manzilda kuzatishingiz mumkin: `http://127.0.0.1:8006`. Brauzer konsolni ochishdan oldin oʻsha foydalanuvchi nomi va parolni soʻraydi.

 ![windows-vm](images/windows-vm.webp)

## Undan foydalanish

U oʻrnatilgach, ilova ishga tushirgichidan _Windows_ ni ishga tushiring. Bu VM ni agar u allaqachon ishlamayotgan boʻlsa boshlaydi va sizni RDP orqali, toʻliq ekran ulaydi. Sovuq boshlashda unga 15–30 soniya bering.

RDP sessiyasi ovoz, mikrofoningiz va ulashilgan almashish buferini olib yuradi, shuning uchun Linux va Windows orasida matndan nusxa olish shunchaki ishlaydi. Aniqlik oynangizga ergashadi va Omarchy displey miqyoslashingizni oʻtkazadi, shuning uchun u HiDPI ekranda loyqa tartibsizlik emas.

RDP oynasini yopganingizda VM avtomatik oʻchadi. Agar uni ishlatib qoldirishni afzal koʻrsangiz — aytaylik, unda biror narsa ishlab turibdi — uning oʻrniga `omarchy windows vm launch --keep-alive` bilan ishga tushiring.

Qolgan boshqaruv elementlari oʻsha buyruqda:

```bash
omarchy windows vm status    # is it running?
omarchy windows vm stop      # shut it down
omarchy windows vm launch    # start and connect
```

## Fayllarni ulashish

Uy kataloggingizdagi `~/Windows` katalogi VM bilan avtomatik ulashiladi. Agar fayllar Windows ga kirish mumkin boʻlishini istasangiz, ularni u yerga qoʻying. VM fayl tizimingizning boshqa har qanday qismiga kira olmaydi, shuning uchun Windows tomonidagi har qanday yomon narsadan xavfsizsiz. Uning oʻz virtual diski `~/.windows` da mavjud.

Oʻsha tanish uy yoʻllari oʻz fayl tizimlarida qoladi. Ular sizga tegishli kataloglarga symlinklar ham boʻlishi mumkin, bu virtual disk kattaroq diskda yashaganda foydali. Oʻrnatuvchi boʻsh joyni aslida `~/.windows` ni oʻz ichiga olgan fayl tizimida oʻlchaydi, uy kataloggingizni oʻz ichiga olgan fayl tizimida boʻlishi shart emas.

Disk va ulashilgan yoʻllarni alohida, bir-birini qoplamaydigan kataloglar sifatida saqlang. Olib tashlash ataylab disk katalogini boʻshatadi, lekin ulashilgan katalogni saqlaydi. Oʻchirishdan darhol oldin Omarchy chegaralangan saqlash tekshiruvini bajaradi va agar oʻsha tekshiruv vaqti tugasa yoki ikki daraxt alohida ekanligini isbotlay olmasa, biror narsani olib tashlashdan bosh tortadi.

VM boshlanishidan oldin Omarchy oʻsha ikki katalogni ochadi va biriktiradi, keyin aniq katalog inode larini `/var/lib/omarchy/windows/mounts` ostidagi shaxsiy har bir foydalanuvchi uchun langarlarga bind-mount qiladi. Docker faqat oʻsha root tomonidan himoyalangan langarlarni koʻradi. Bu maxsus disk joylarini saqlaydi, shu bilan birga siz sifatida ishlaydigan boshqa jarayonning imtiyozli konteyner uni isteʼmol qilishidan oldin tekshirilgan yoʻlni almashtirishining oldini oladi. Mavjud disk va ulashilgan kataloglar migratsiya davomida boshqa mahalliy hisoblar ularning mazmunini koʻra olmasligi uchun `0700` rejimiga tortiladi.

VM ning portlari faqat localhost ga bogʻlangan, shuning uchun tarmogʻingizdagi hech narsa Windows mashinasiga yeta olmaydi. Veb konsoli ham sozlangan Windows foydalanuvchi nomi va parolini talab qiladi, boshqa mahalliy hisobning 8006-port orqali VM ni boshqaruvining oldini oladi.

## Cheklovlar va litsenziyalash

Bu sozlama bilan GPU oʻtkazish yoʻq, shuning uchun u oʻyin yoki video tahrirlash uchun mos emas. Bu Microsoft Office yoki sizga mutlaqo kerak boʻlgan boshqa har qanday narsani ishlatishning ajoyib usulidir.

Oʻrnatilgan versiya Windows 11 Pro, faollashtirilmagan. Darvoza bilan yopilgan funksiyalardan foydalanish uchun oʻz litsenziya kalitingiz kerak boʻladi.

Agar bu kompyuter Windows bilan kelgan boʻlsa, OEM kaliti Omarchy ni oʻrnatgandan keyin ham proshivkada qoladi. Uni `omarchy windows key` bilan chop eting. Oʻsha kalit bu mashinaga bogʻlangan — u bu uskunada qayta oʻrnatilgan Windows ni faollashtiradi, lekin odatda VM ni faollashtirmaydi.

Resurs taqsimotini keyinroq `omarchy-windows-vm install` ni qayta ishga tushirish orqali oʻzgartirishingiz mumkin, u VM konfiguratsiyasini javoblaringizdan qayta yozadi. Compose faylining oʻzi endi `/var/lib/omarchy/windows/docker-compose.yml` da yashaydi va root ga tegishli — bu ataylab, shuning uchun siz sifatida ishlaydigan jarayon uni qayta yoza olmaydi va imtiyozli ishga tushirish butun diskingizni konteynerga ulay olmaydi. Agar uni qoʻlda tahrirlashingiz kerak boʻlsa (masalan USB qurilmani ulash uchun), uni `sudo` bilan tahrirlang va [Dockur Windows loyihasi](https://github.com/dockur/windows) dagi barcha variantlarni koʻring.

Butun narsadan qutulish uchun Omarchy menyusidagi _Olib tashlash > Windows_ dan foydalaning. Bu VM ning diski va uning barcha maʼlumotlarini oʻchiradi, shuning uchun avval sizga ahamiyatli har qanday narsa `~/Windows` dan chiqqaniga ishonch hosil qiling.
