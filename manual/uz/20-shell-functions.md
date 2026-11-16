# Shell funksiyalari

Omarchy keng tarqalgan vazifalarni soddalashtirish va murakkab parametr chaqiruvlarini inkapsulyatsiya qilish uchun shell funksiyalari toʻplami bilan keladi.

## Siqish

- `compress [file/dir]`: Fayl/katalogdan tar.gz arxivini yarating.
- `decompress [file.tar.gz]`: tar.gz faylini kengaytiring.

## Disklar

- `iso2sd [image.iso]`: Koʻrsatilgan iso faylidan foydalanib va diskni interaktiv tanlab, SD kartada yuklanadigan disk yarating.
- `format-drive [device] [name]`: Butun diskni bitta exFAT boʻlimi bilan formatlang (u Windows va macOS da ham ishlaydi). Mavjud disklarni koʻrish uchun uni argumentsiz ishga tushiring. Ehtiyot boʻling!

## Dev tartiblar

tmux uchun tezkor koʻp panelli dasturlash tartiblari:

- `tdl [ai]`: Muharriringiz, AI agent va terminal bilan Tmux Dev Layout yarating. Agent aliaslaridan foydalaning, masalan opencode uchun `tdl c` yoki Claude Code uchun `tdl cx`, yoki ikkalasini ham ishga tushirish uchun ikkinchi agentni bering, masalan `tdl c cx`.
- `tds`: Muharrir, diff kuzatish (`hunk diff --watch` orqali), terminal va opencode bilan Tmux Dev Square yarating.
- `tdlm [ai]`: Joriy katalogdagi har bir ichki katalog uchun `tdl` oynasini yarating.
- `tsl [count] [command]`: Hammasi bir xil buyruqni ishga tushiruvchi panellar toʻplamini panjara shaklida joylashtirib yarating (AI agentlar uchun juda yaxshi).

Xuddi shu tartiblar Herdr uchun `hdl`, `hds`, `hdlm` va `hsl` sifatida mavjud.

## Git worktreelar

- `ga [branch]`: Joriy repozitoriy yonida yangi worktree va branch yarating va unga sakrab oʻting.
- `gd`: Joriy worktree va uning branchini olib tashlang (avval tasdiqlashni soʻraydi).

## Rsync kuzatuvchilar

- `rsw [source] [destination]`: Biror narsa oʻzgarganida manbani manzilga rsync qiluvchi fon kuzatuvchisini boshlang. Manzil masofadagi host boʻlishi mumkin, masalan `rsw ~/Work/app nyc-dev:Work/app`.
- `lsw`: Barcha faol kuzatuvchilarni roʻyxat qiling.
- `dsw`: Barcha faol kuzatuvchilarni toʻxtating.

## SSH port yoʻnaltirish

Masofadagi mashinaga qarshi localhost xavfsiz kontekst imtiyozlari bilan veb dasturlash qilish uchun ideal.

- `fip`: SSH orqali masofadagi hostdan localhost ga bir yoki bir nechta portni yoʻnaltiring.
- `dip`: Bir yoki bir nechta yoʻnaltirilgan portni uzing.
- `lip`: Barcha faol SSH port yoʻnaltirishlarini roʻyxat qiling.

Aytaylik, `nyc-dev` sifatida kirish mumkin boʻlgan mashinada `3000` portda dev serverni boshlaysiz, keyin oʻsha portni yoʻnaltirish uchun `fip nyc-dev 3000` ni ishga tushirishingiz mumkin, shunday qilib `localhost:3000` aslida `nyc-dev:3000` ga yetadi, lekin veb soketlar yoki shunga oʻxshash narsalarni sinash uchun kerak boʻlgan xavfsiz kontekstni oʻrnatish uchun SSL sertifikatlariga ehtiyoj boʻlmaydi.

## SSH qayta ulanish

`ssh` ning oʻzi shunday funksiyaga oʻralganki, agar masofadagi tmux, Herdr yoki muharrir terminalni egallagan paytda ulanish uzilib qolsa, u terminalni tozalaydi va keyin interaktiv sessiya uzilib qolganda avtomatik qayta ulanadi (Ctrl-C qayta urinish siklini toʻxtatadi).
