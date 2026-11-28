# Tizim uyqusi

Omarchy sukut bo'yicha suspend rejimini, sozlangandan keyin esa hibernation rejimini yoqadi, lekin mashinangizda ulardan biri bilan muammolar bo'lsa, ularni o'chirib qo'yishingiz mumkin.

DGX Spark va ASUS Ascent GX10 kabi NVIDIA GB10 mashinalarida suspend va hibernation o'chirib qo'yilgan, xuddi NVIDIA'ning DGX OS tizimidagi kabi, chunki uyqu rejimi bu uskunada hali ishlashi ko'rsatilmagan. U yerda suspend tugmasi va hibernation sozlamalari qo'llanilmaydi. Uyqu rejimini qayta yoqish uchun `/etc/systemd/sleep.conf.d/omarchy-sleep-disabled.conf` faylini `sudo rm` bilan o'chiring; shunda Suspend menyuga qaytadi va hibernation boshqa mashinalardagi kabi sozlanishi mumkin. `sudo omarchy apply hardware --install-user "$USER"` buyrug'ini ishga tushirish faylni joyiga qaytaradi.

### Quvvat profillari

Noutbukda Omarchy quvvat profilingizni tarmoqqa ulangan holat va batareyada ishlayotgan holat uchun alohida eslab qoladi va ulaganda hamda uzganda ikkisi o'rtasida almashadi. Dastlab bu AC rejimida performance va batareyada balanced deganidir.

Mashinangiz nimalarni taklif qilishini `omarchy powerprofiles list` bilan ko'rishingiz va hozir bo'lgan holatingiz uchun keraklisini `omarchy powerprofiles set autodetect power-saver` bilan o'rnatishingiz mumkin. Hech narsani uzmasdan boshqa holatni o'rnatish uchun uni to'g'ridan-to'g'ri nomlang: `omarchy powerprofiles set battery power-saver`. Tanlaganingiz nima bo'lsa, keyingi safar shu holatda bo'lganingizda aynan o'shani olasiz.

### Suspend rejimini yoqish/o'chirish

Suspend rejimini terminaldan `omarchy toggle suspend` buyrug'ini ishga tushirib yoqasiz/o'chirasiz. Bu _System_ (yoki `Super + Esc`) ostidagi variantni shunchaki ko'rsatadi/yashiradi, keyin esa uning tizimingizda barqaror ishlashini tekshirib ko'rishingiz mumkin. Ishlamasa, xuddi shu buyruq bilan uni yana yashirib qo'yishingiz mumkin.

### Hibernation rejimini yoqish/o'chirish

Hibernation rejimini terminaldan `omarchy hibernation setup` buyrug'ini ishga tushirib sozlaysiz (u Apple Silicon Mac'larda mavjud emas). Hibernation yuklanish diskingizda jismoniy RAM hajmingizga teng /swap subvolume yaratadi, shuning uchun bo'sh joyingiz yetarlicha ko'p ekaniga ishonch hosil qiling. 32GB mashinada bu volume uchun sizga doim 32GB+ bo'sh joy kerak bo'ladi. Hibernation yana sukut bo'yicha Limine bootloader'ini talab qiladi.

Sozlangandan keyin _System_ (yoki `Super + Esc`) ostida hibernate variantini ko'rasiz, keyin esa uning tizimingizda barqaror ishlashini tekshirib ko'rishingiz mumkin. Ishlamasa, `omarchy hibernation remove` buyrug'ini ishga tushirib uni yana olib tashlashingiz mumkin.
