# Terminal

[Foot](https://codeberg.org/dnkl/foot) Omarchy uchun standart terminaldir. U tezkor, yengil va hattoki eski kompyuterlar bilan ham mos. Ammo u mahalliy tablar yoki boʻlinishlarni qoʻllab-quvvatlamaydi.

Agar Tmux ishlatsangiz, bunga eʼtibor bermasligingiz mumkin, lekin ishlatmasangiz, biz variant sifatida _Alacritty_, _Ghostty_ va _Kitty_ ni ham toʻliq qoʻllab-quvvatlaymiz. Afzalligingizni Omarchy menyusidagi _Oʻrnatish > Terminal_ ostida tanlang.

Yangi terminalni `Super + Return` yordamida boshlaysiz. (Bu bogʻlanish avtomatik ravishda _Oʻrnatish > Terminal_ orqali oʻrnatgan Terminalningizga ishora qiladi va oʻrnatilgan terminallar orasida _Sozlash > Standartlar > Terminal_ ostida almashishingiz mumkin.)

## Tmux

Tmux terminalingizdan qatʼi nazar panel, oynalar (tablar) va davom ettiriladigan sessiyalar uchun izchil, dasturlashtiriladigan interfeys taqdim etadi. U hattoki masofaviy hostlarda ham ishlaydi, shuning uchun serverga SSH qilayotganda xuddi shu yondashuvni ishlatishingiz mumkin.

Yangi terminalda yangi Tmux sessiyasini `Super + Alt + Return` yordamida boshlaysiz va Tmux doimiy jarayon boʻlgani uchun, oʻsha terminalni yopsangiz ham sessiyangizni davom ettirishingiz mumkin. Barcha faol sessiyalaringizni koʻrish uchun shunchaki `Ctrl + Space` (prefiks tugmasi deb ataladi) keyin `s` ni bosing.

Omarchy ergonomik optimallashtirilgan Tmux konfiguratsiyasi bilan keladi, unda oʻrganish uchun koʻp tugmalar bogʻlanishlari bor, shuning uchun [cheatsheetni qoʻlingizda saqlang](07-hotkeys.md#tmux).

## Tmux tartib funksiyalari

Tmux dasturlashtiriladigan boʻlgani uchun, tartiblar yaratish uchun funksiyalardan foydalanishimiz mumkin. Omarchy keng tarqalgan dasturchi tartiblari uchun toʻrtta turli funksiya bilan keladi.

`tdl [agent]` chapda `$EDITOR`, oʻngda tanlangan AI agentingiz (opencode uchun `c` yoki Claude uchun `cx` yoki OpenAI uchun `codex` kabi) va keyin pastda terminal bilan uch tomonlama boʻlinadigan IDE ga oʻxshash interfeysni boshlaydi.

Demak `tdl c` buni boshlaydi (yoki shunchaki `ic`):

 ![tmux-tdl](images/tmux-tdl.webp)

Ikkinchi agentni `tdl c cx` (opencode + claude) bilan ham boshlashingiz mumkin (yoki shunchaki `icx`):

 ![tmux-tdl2](images/tmux-tdl2.webp)

Yana `tds` bor, u yuqorida chapda editor, yuqorida oʻngda jonli diff kuzatuvchisi, pastda chapda terminal va pastda oʻngda opencode bilan toʻrt tomonlama kvadratni boshlaydi.

Bu tartib konfiguratsiyasini joriy katalogdagi har bir subkatalog uchun `tdlm [agent]` yordamida ham boshlashingiz mumkin, keyin `alt + 1/2/3/4/5/...` yordamida harakatlanasiz:

 ![tmux-tdlm](images/tmux-tdlm.webp)

Va nihoyat, `tsl [panes] [command]` yordamida agentlar toʻdasini boshlashingiz mumkin. Demak `tsl 4 c` sizga opencode agentlarining toʻrt tomonlama panjarasini beradi:

 ![tmux-tsl](images/tmux-tsl.webp)
