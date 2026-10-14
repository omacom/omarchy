# Tizim uyqu

Omarchy standart holatda kutish va uyqu rejimini yoqadi, lekin agar mashinangizda ikkalasidan ham muammolaringiz boʻlsa, ularni oʻchirishingiz mumkin.

### Quvvat profillari

Noutbukda Omarchy sizning quvvat profilingizni elektrga ulangan va batareyada ishlashi uchun alohida eslab qoladi va siz ulab-uzganingizda ikki oʻrtasida almashinadi. Qutidan chiqqan holda bu AC da unumdorlik va batareyada muvozanat demakdir.

Mashinangiz nima taklif qilishini `omarchy powerprofiles list` bilan koʻrishingiz va hozir boʻlgan holatingiz uchun kerakligini `omarchy powerprofiles set autodetect power-saver` bilan oʻrnatishingiz mumkin. Hech narsani uzmasdan boshqa holatni oʻrnatish uchun uni toʻgʻridan-toʻgʻri nomlang: `omarchy powerprofiles set battery power-saver`. Nimani tanlasangiz, keyingi marta oʻsha holatda boʻlganingizda shuni qaytarib olasiz.

### Kutishni almashtirish

Siz kutishni terminaldan `omarchy toggle suspend` ni ishga tushirish bilan almashtirasz. Bu shunchaki _Tizim_ (yoki `Super + Esc`) ostidagi variantni koʻrsatadi/yashiradi, keyin u tizimingizda izchil ishlashini tekshirishingiz mumkin. Boʻlmasa, xuddi shu buyruq bilan yana yashirishingiz mumkin.

### Hibernatsiyani almashtirish

Siz hibernatsiyani terminaldan `omarchy hibernation setup` ni ishga tushirish bilan sozlaysiz. Hibernatsiya yuklash drayvingizda fizik operativ xotira ajratilmangiz hajmidagi /swap qismida yaratadi, shuning uchun boʻsh joyingiz koʻpligiga ishonch hosil qiling. 32GB mashinada bu hajm uchun har doim 32GB+ boʻsh kerak boʻladi. Hibernatsiya shuningdek standart Limine bootloaderi talab qiladi.

Sozlanganda, siz _Tizim_ (yoki `Super + Esc`) ostida hibernatsiya variantini koʻrasiz, keyin u tizimingizda izchil ishlashini tekshirishingiz mumkin. Boʻlmasa, `omarchy hibernation remove` ni ishga tushirib yana olib tashlashingiz mumkin.
