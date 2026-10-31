# Teksta iegūšana un diktēšana

### Teksta iegūšana

Nospied `Super + Ctrl + PrtScr`, lai atlasītu reģionu ekrānā teksta iegūšanai. Tesseract atvērtā koda OCR modelis pēc tam ātri pārvērtīs šo atlasi tekstā un ievietos to starpliktuvē. Pēc tam tu vienkārši nospied `Super + V`, lai ielīmētu.

Tas ir ļoti noderīgi, lai iegūtu adreses no attēlu kājenēm vai tālruņa numurus, kas iegulti vietņu virsrakstos.

 ![text-extraction](images/text-extraction.webp)

### Diktēšana

Svaigās instalācijās [Superwhisper](https://superwhisper.com/) ir noklusējuma diktēšanas aizmugure, izmantojot mākoņa apstrādi bez bezsaistes modeļu lejupielādēm. Izvēlies Superwhisper vai [Voxtype](https://voxtype.io/), izmantojot _Iestatīšana > Noklusējumi > Diktēšana_ Omarchy izvēlnē. Aizmugures atlase to instalē, ja nepieciešams, un padara to par noklusējumu diktēšanai. Voxtype ielādē bāzes angļu valodas modeli, kas aizņem 150 MB; maini modeli ar `voxtype setup model` un citus iestatījumus, izmantojot `~/.config/voxtype/config.toml`. Superwhisper atver savus iestatījumus, lai izvēlētos mākoņa vai lokālo apstrādi, un OPR uztur lietotni atjauninātu.

Tu diktē, turot nospiestu `Right Alt` vai `F9`, vai pārslēdzot ar `Super + Ctrl + X`, un diktētais teksts parādīsies fokusētajā ievades apgabalā. Šīs saīsnes izmanto atlasīto aizmuguri. Right Alt arī sāk diktēšanu, kad to izmanto modifikatora akordā; izmanto Left Alt šiem akordiem. Tastatūras izkārtojumos, kur Right Alt ir AltGr, izmanto `F9`, lai AltGr paliktu pieejams rakstīšanai.

Tās pašas saīsnes darbojas ar jebkuru aizmuguri. Atlasi savu aizmuguri, izmantojot Iestatīšana > Noklusējumi > Diktēšana. Aizmugures instalētājs to konfigurē un saglabā atlasi. Palaid `omarchy default dictation`, lai redzētu, kura ir atlasīta. Atlase tiek saglabāta `~/.config/omarchy/defaults/dictation`. Svaigās instalācijās Superwhisper tiek atlasīts automātiski.

Omarchy automātiski ielādē atlasītās aizmugures darbvirsmas integrāciju. `~/.config/hypr/` nav nepieciešama Superwhisper konfigurācija.

Pielāgotas piesaistes un skripti var izmantot `omarchy dictation start`, `omarchy dictation stop` un `omarchy dictation toggle`. Atlasītā aizmugure apstrādā ierakstīšanu un transkripciju. Superwhisper atlase atspējo tās vietējo turēšanas saīsni un iestata tās vietējo pārslēgšanu uz `Alt + Space`, turot to atsevišķi no Omarchy ierakstīšanas taustiņiem. Superwhisper ir nepieciešama vismaz viena vietējā ierakstīšanas saīsne, un tā atcelšanas saīsne paliek pieejama.

Papildu aizmugures var integrēties, nemainot Omarchy. Nodrošini izpildāmu failu ar nosaukumu `omarchy-dictation-<backend>` PATH, kas pieņem `start`, `stop` un `toggle` un nekavējoties atgriežas, ar statusu, kas nav nulle, kļūmes gadījumā. Tā instalētājs konfigurē nodrošinātāju un pēc veiksmīgas iestatīšanas izsauc `omarchy-dictation-use <backend>`. Tas aptur iepriekšējo aizmuguri un atomiski saglabā atlasi; `stop` ir jāizdodas, kad nodrošinātājs ir dīkstāvē vai nav pieejams. Aizmugures nosaukumi izmanto mazos burtus, ciparus un defises. Nodrošini `omarchy-install-dictation-<backend>` iestatīšanai; `omarchy default dictation <backend>` to palaiž. Pievieno Noklusējumu izvēlnes ierakstu, izmantojot Omarchy izvēlnes paplašinājumu, lai izsauktu šo atlasītāju. Izvēles darbvirsmas integrācija var dzīvot `${XDG_CONFIG_HOME:-$HOME/.config}/<backend>/shortcuts.lua`.
