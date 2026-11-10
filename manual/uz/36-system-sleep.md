# Tizim uyqusi

Omarchy sukut bo‘yicha to‘xtatib turish va gibernatsiyani yoqadi, lekin mashinangizda ulardan biri bilan muammo bo‘lsa, ularni o‘chirib qo‘yishingiz mumkin.

NVIDIA GB10 mashinalarida, masalan DGX Spark va ASUS Ascent GX10 da, to‘xtatib turish va gibernatsiya o‘chirilgan, xuddi NVIDIA ning DGX OS dagidek, chunki uyqu rejimi bu apparatda hali ishlashi isbotlanmagan. Xuddi shu holat ASUS Zenbook A16 (UX3607OA) ga ham tegishli, unda to‘xtatib turish chipni hali to‘liq uyquga o‘tkazmaydi va kechasi osilib qolishi mumkin. To‘xtatib turishni almashtirish va gibernatsiyani sozlash u yerda qo‘llanilmaydi. Uyquni qayta yoqish uchun `/etc/systemd/sleep.conf.d/omarchy-sleep-disabled.conf` ni `sudo rm` bilan o‘chirib tashlang; Shunda Suspend menyuga qaytadi va gibernatsiyani boshqa mashinalardagi kabi sozlash mumkin bo‘ladi. `sudo omarchy apply hardware --install-user "$USER"` ni ishga tushirish faylni qayta joyiga qo‘yadi.

### Quvvat profillari

Laptopda Omarchy quvvat profilingizni tarmoqqa ulangan va batareyada ishlayotgan holat uchun alohida eslab qoladi va siz ulaganingizda hamda uzganingizda ikkalasi o‘rtasida almashadi. Qutidan chiqqan holida bu AC da unumdorlik va batareyada muvozanatli degani.

Mashinangiz nimani taklif qilishini `omarchy powerprofiles list` bilan ko‘rishingiz va hozir bo‘lgan holatingiz uchun keraklisini `omarchy powerprofiles set autodetect power-saver` bilan o‘rnatishingiz mumkin. Hech narsani uzmasdan boshqa holatni o‘rnatish uchun uni to‘g‘ridan-to‘g‘ri nomlang: `omarchy powerprofiles set battery power-saver`. Nimani tanlasangiz, keyingi safar shu holatda bo‘lganingizda xuddi shuni olasiz.

### To‘xtatib turishni yoqish/o‘chirish

To‘xtatib turishni terminaldan `omarchy toggle suspend` ni ishga tushirib almashtirasiz. Bu shunchaki _System_ (yoki `Super + Esc`) ostidagi variantni ko‘rsatadi/yashiradi, keyin tizimingizda u barqaror ishlashini tekshirib ko‘rishingiz mumkin. Agar ishlamasa, xuddi shu buyruq bilan uni yana yashirib qo‘yishingiz mumkin.

### Gibernatsiyani yoqish/o‘chirish

Giberrnatsiyani terminaldan `omarchy hibernation setup` ni ishga tushirib sozlaysiz. Gibernatsiya yuklash diskingizda jismoniy RAM hajmingizga teng /swap quyi jildini yaratadi, shuning uchun yetarlicha bo‘sh joyingiz borligiga ishonch hosil qiling. 32GB li mashinada bu jild uchun har doim 32GB+ bo‘sh joy kerak bo‘ladi. Gibernatsiya shuningdek sukut bo‘yicha Limine yuklovchisini talab qiladi.

Sozlangach, _System_ (yoki `Super + Esc`) ostida gibernatsiya variantini ko‘rasiz, keyin u tizimingizda barqaror ishlashini tekshirib ko‘rishingiz mumkin. Agar ishlamasa, `omarchy hibernation remove` ni ishga tushirib uni yana olib tashlashingiz mumkin.
