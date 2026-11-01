# Tizim uyqusi

Omarchy sukut bo'yicha to'xtatib turish va gibernatsiyani yoqadi, ammo mashinangizda ulardan biri bilan muammo bo'lsa, ularni o'chirib qo'yishingiz mumkin.

NVIDIA GB10 mashinalarida, masalan DGX Spark va ASUS Ascent GX10 da, to'xtatib turish va gibernatsiya o'chirilgan, xuddi NVIDIA'ning DGX OS'idagi kabi, chunki uyqu hali bu uskunada ishlashi ko'rsatilmagan. To'xtatib turishni almashtirish va gibernatsiyani sozlash u yerda qo'llanilmaydi. Uyquni qayta yoqish uchun `/etc/systemd/sleep.conf.d/omarchy-sleep-disabled.conf` ni `sudo rm` bilan olib tashlang; shundan so'ng To'xtatib turish menyuga qaytadi va gibernatsiyani boshqa mashinalardagi kabi sozlash mumkin. `sudo omarchy apply hardware --install-user "$USER"` ni ishga tushirish faylni qayta joyiga qo'yadi.

### Quvvat profillari

Noutbukda Omarchy quvvat profilingizni tarmoqqa ulangan va batareyada ishlayotgan holatlar uchun alohida eslab qoladi va ulaganda hamda uzganda ikkisi o'rtasida almashadi. Dastlab bu AC da unumdorlik va batareyada muvozanatli deganidir.

Mashinangiz nimalarni taklif qilishini `omarchy powerprofiles list` bilan ko'rishingiz mumkin, hozir bo'lib turgan holatingiz uchun keraklisini esa `omarchy powerprofiles set autodetect power-saver` bilan o'rnatasiz. Hech narsani uzmasdan boshqa holatni o'rnatish uchun uni to'g'ridan-to'g'ri nomlang: `omarchy powerprofiles set battery power-saver`. Nimani tanlasangiz, keyingi safar o'sha holatda bo'lganingizda aynan o'shani olasiz.

### To'xtatib turishni yoqish/o'chirish

To'xtatib turishni terminaldan `omarchy toggle suspend` ni ishga tushirib almashtirasiz. Bu shunchaki _System_ (yoki `Super + Esc`) ostidagi variantni ko'rsatadi/yashiradi, shundan so'ng u tizimingizda barqaror ishlashini ko'rishingiz mumkin. Agar ishlamasa, xuddi shu buyruq bilan uni yana yashirishingiz mumkin.

### Gibernatsiyani yoqish/o'chirish

Gibernatsiyani terminaldan `omarchy hibernation setup` ni ishga tushirib sozlaysiz. Gibernatsiya yuklash diskingizda jismoniy RAM hajmingizga teng /swap subvolume yaratadi, shuning uchun bo'sh joyingiz yetarlicha ko'p ekaniga ishonch hosil qiling. 32GB mashinada bu volume uchun sizga har doim 32GB+ bo'sh joy kerak bo'ladi. Gibernatsiya shuningdek sukut bo'yicha Limine bootloader'ini talab qiladi.

Sozlanganda, gibernatsiya variantini _System_ (yoki `Super + Esc`) ostida ko'rasiz, shundan so'ng u tizimingizda barqaror ishlashini ko'rishingiz mumkin. Agar ishlamasa, `omarchy hibernation remove` ni ishga tushirib uni yana olib tashlashingiz mumkin.
