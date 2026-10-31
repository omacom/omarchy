# Teksta izvilkšana un diktēšana

### Teksta izvilkšana

Nospiediet `Super + Ctrl + PrtScr`, lai atlasītu ekrāna apgabalu teksta izvilkšanai. Pēc tam tesseract atvērtā koda OCR modelis ātri pārveidos šo atlasi tekstā un ievietos to starpliktuvē. Tad vienkārši nospiediet `Super + V`, lai ielīmētu.

Tas ļoti palīdz izkopēt adreses no attēlu kājenēm vai tālruņa numurus, kas iegulti tīmekļa vietņu virsrakstos.

 ![text-extraction](images/text-extraction.webp)

### Diktēšana

Jaunās instalācijās [Superwhisper](https://superwhisper.com/) ir noklusējuma diktēšanas aizmugursistēma, kas izmanto apstrādi mākonī bez bezsaistes modeļu lejupielādes. Izvēlieties Superwhisper vai [Voxtype](https://voxtype.io/) caur _Setup > Defaults > Dictation_ Omarchy izvēlnē. Aizmugursistēmas izvēle to instalē, ja nepieciešams, un padara to par noklusējumu diktēšanai. Voxtype ielādē bāzes angļu valodas modeli, kas aizņem 150MB; mainiet modeli ar `voxtype setup model` un citus iestatījumus caur `~/.config/voxtype/config.toml`. Superwhisper atver savus iestatījumus, lai izvēlētos apstrādi mākonī vai lokāli, un OPR uztur lietojumprogrammu atjauninātu.

Jūs diktējat, turot nospiestu `Right Alt` vai pārslēdzot ar `Alt + Space`, un diktētais teksts parādīsies fokusētajā ievades laukā. Šie īsinājumtaustiņi izmanto atlasīto aizmugursistēmu. Right Alt sāk diktēšanu arī tad, ja to izmanto modificētāja akordā; šiem akordiem izmantojiet Left Alt. Tastatūras izkārtojumos, kuros Right Alt ir AltGr, izmantojiet `Alt + Space`, lai AltGr paliktu pieejams rakstīšanai. Instalācijas no laika, pirms Alt + Space kļuva par noklusējumu, saglabā `F9` runāšanai turot nospiestu un `Super + Ctrl + X` pārslēgšanai, kas pievienoti `~/.config/hypr/bindings.lua`; noņemiet tos tur, lai atdotu šos taustiņus lietojumprogrammām.

Tie paši īsinājumtaustiņi darbojas ar abām aizmugursistēmām. Atlasiet savu aizmugursistēmu caur Setup > Defaults > Dictation. Aizmugursistēmas instalētājs to konfigurē un saglabā izvēli. Palaidiet `omarchy default dictation`, lai redzētu, kura ir atlasīta. Izvēle tiek saglabāta `~/.config/omarchy/defaults/dictation`. Jaunās instalācijās Superwhisper tiek atlasīts automātiski.

Omarchy automātiski ielādē atlasītās aizmugursistēmas darbvirsmas integrāciju. `~/.config/hypr/` nav nepieciešama nekāda Superwhisper konfigurācija.

Pielāgotas piesaistes un skripti var izmantot `omarchy dictation start`, `omarchy dictation stop` un `omarchy dictation toggle`. Atlasītā aizmugursistēma apstrādā ierakstīšanu un transkripciju. Superwhisper atlasīšana atspējo tā sākotnējo turēšanas īsinājumtaustiņu un iestata tā sākotnējo pārslēgšanu uz `Ctrl + Alt + Space`, turot to atsevišķi no Omarchy ierakstīšanas taustiņiem. Superwhisper pieprasa vismaz vienu sākotnējo ierakstīšanas īsinājumtaustiņu, un tā atcelšanas īsinājumtaustiņš paliek pieejams.

Papildu aizmugursistēmas var integrēties, nemainot Omarchy. Nodrošiniet izpildāmu failu ar nosaukumu `omarchy-dictation-<backend>` PATH, kas pieņem `start`, `stop` un `toggle` un atgriežas nekavējoties, ar statusu, kas nav nulle, kļūmes gadījumā. Tā instalētājs konfigurē pakalpojumu sniedzēju un pēc veiksmīgas iestatīšanas izsauc `omarchy-dictation-use <backend>`. Tas aptur iepriekšējo aizmugursistēmu un atomāri saglabā izvēli; `stop` jāizdodas, kad pakalpojumu sniedzējs ir dīkstāvē vai nav pieejams. Aizmugursistēmu nosaukumos izmanto mazos burtus, ciparus un defises. Nodrošiniet `omarchy-install-dictation-<backend>` iestatīšanai; `omarchy default dictation <backend>` to palaiž. Pievienojiet Defaults izvēlnes ierakstu caur Omarchy izvēlnes paplašinājumu, lai izsauktu šo atlasītāju. Neobligāta darbvirsmas integrācija var atrasties `${XDG_CONFIG_HOME:-$HOME/.config}/<backend>/shortcuts.lua`.
