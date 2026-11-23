# Tizim uyqusi

Omarchy sukut boʻyicha suspendni yoqadi, hibernation esa sozlangandan keyin yoqiladi, lekin mashinangizda ulardan biri bilan muammo boʻlsa, ularni oʻchirib qoʻyishingiz mumkin.

NVIDIA GB10 mashinalarida, masalan DGX Spark va ASUS Ascent GX10 da, suspend va hibernation oʻchirilgan — NVIDIAʼning DGX OSʼidagi kabi — chunki bu uskunada uyqu hali ishlashi koʻrsatilmagan. Xuddi shu holat ASUS Zenbook A16 (UX3607OA) ga ham tegishli, u yerda suspend chipni hali toʻliq uyquga yubormaydi va kechasi osilib qolishi mumkin. Suspendni yoqib-oʻchirish va hibernation sozlash u yerda qoʻllanilmaydi. Uyquni qayta yoqish uchun `/etc/systemd/sleep.conf.d/omarchy-sleep-disabled.conf` ni `sudo rm` bilan oʻchirib tashlang; shunda Suspend menyuga qaytadi va hibernationni boshqa mashinalardagi kabi sozlash mumkin boʻladi. `sudo omarchy apply hardware --install-user "$USER"` ni ishga tushirish faylni qayta joyiga qoʻyadi.

### Quvvat profillari

Noutbukda Omarchy quvvat profilingizni tarmoqqa ulangan holat va batareyada ishlash holati uchun alohida eslab qoladi va siz ulab-uzganingizda ikkisi oʻrtasida almashadi. Qutidan chiqqan holatida bu AC da performance va batareyada balanced deganini anglatadi.

Mashinangiz nimalarni taklif qilishini `omarchy powerprofiles list` bilan koʻrishingiz mumkin, hozir boʻlib turgan holatingiz uchun kerakli profilni esa `omarchy powerprofiles set autodetect power-saver` bilan oʻrnatasiz. Hech narsani uzmasdan boshqa holatni sozlash uchun uni toʻgʻridan-toʻgʻri nomlang: `omarchy powerprofiles set battery power-saver`. Nimani tanlasangiz, keyingi safar oʻsha holatga tushganingizda aynan oʻshani olasiz.

### Suspendni yoqib-oʻchirish

Suspendni terminaldan `omarchy toggle suspend` ni ishga tushirib yoqib-oʻchirasiz. Bu shunchaki _Tizim_ ostidagi variantni koʻrsatadi/yashiradi (yoki `Super + Esc`), keyin uning tizimingizda barqaror ishlashini koʻrishingiz mumkin. Ishlamasa, xuddi shu buyruq bilan uni yana yashirib qoʻyishingiz mumkin.

### Hibernationni yoqib-oʻchirish

Hibernationni terminaldan `omarchy hibernation setup` ni ishga tushirib sozlaysiz (u Apple Silicon Macʼlarda mavjud emas). Hibernation yuklanish diskingizda jismoniy RAM ajratmangiz hajmiga teng /swap subvolume yaratadi, shuning uchun yetarlicha boʻsh joyingiz borligiga ishonch hosil qiling. 32GB lik mashinada bu volume uchun doim 32GB+ boʻsh joy kerak boʻladi. Hibernation shuningdek standart Limine bootloaderʼini ham talab qiladi.

Sozlangach, hibernate variantini _Tizim_ ostida koʻrasiz (yoki `Super + Esc`), keyin uning tizimingizda barqaror ishlashini koʻrishingiz mumkin. Ishlamasa, `omarchy hibernation remove` ni ishga tushirib uni yana olib tashlashingiz mumkin.
