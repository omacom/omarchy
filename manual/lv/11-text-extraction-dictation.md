# Teksta izvilkšana un diktēšana

### Teksta izvilkšana

Nospiediet `Super + Ctrl + PrtScr`, lai atlasītu apgabalu ekrānā teksta izvilkšanai. Atvērtā koda OCR modelis tesseract pēc tam ātri pārvērtīs šo atlasi tekstā un ievietos to starpliktuvē. Pēc tam vienkārši nospiediet `Super + V`, lai ielīmētu.

Tas ir ļoti noderīgi, lai paņemtu adreses no attēlu kājenēm vai tālruņa numurus, kas iegulti vietņu virsrakstos.

 ![text-extraction](images/text-extraction.webp)

### Diktēšana

Jaunās instalācijās [Superwhisper](https://superwhisper.com/) ir noklusējuma diktēšanas aizmugursistēma, kas izmanto mākoņapstrādi bez bezsaistes modeļu lejupielādēm. Izvēlieties Superwhisper, [Voxtype](https://voxtype.io/) vai [Hex](https://anoma.ly/hex/) Omarchy izvēlnē sadaļā _Setup > Defaults > Dictation_. Aizmugursistēmas atlasīšana to vajadzības gadījumā instalē un padara par diktēšanas noklusējumu. Voxtype ielādē pamata angļu valodas modeli, kas aizņem 150MB; mainiet modeli ar `voxtype setup model` un citus iestatījumus failā `~/.config/voxtype/config.toml`. Superwhisper atver savus iestatījumus, lai izvēlētos mākoņa vai lokālo apstrādi, un OPR uztur lietotni atjauninātu. Hex iestatīšanas laikā lejupielādē savu ierīcē esošo runas modeli un darbojas kā `hex.service` lietotāja pakalpojums; atveriet tā logu no joslas teknes ikonas vai palaižot `hex`, lai mainītu modeli un citus iestatījumus.

Jūs diktējat, turot nospiestu `Right Alt` vai pārslēdzot ar `Alt + Space`, un nodiktētais teksts parādīsies fokusētajā ievades laukā. Šie īsinājumtaustiņi izmanto atlasīto aizmugursistēmu. Right Alt arī sāk diktēšanu, kad to izmanto modifikatora akordā; šādiem akordiem izmantojiet Left Alt. Tastatūras izkārtojumos, kur Right Alt ir AltGr, izmantojiet `Alt + Space`, lai AltGr paliktu pieejams rakstīšanai. Instalācijās, kas izveidotas pirms `Alt + Space` kļuva par noklusējumu, ir saglabāts `F9` nospiešanai un runāšanai un `Super + Ctrl + X` pārslēgšanai, kas pievienoti failam `~/.config/hypr/bindings.lua`; noņemiet tos tur, lai atdotu šos taustiņus lietotnēm.

Tie paši īsinājumtaustiņi darbojas ar katru aizmugursistēmu. Atlasiet savu aizmugursistēmu sadaļā Setup > Defaults > Dictation. Aizmugursistēmas instalētājs to konfigurē un saglabā atlasi. Palaidiet `omarchy default dictation`, lai redzētu, kura ir atlasīta. Atlase tiek saglabāta failā `~/.config/omarchy/defaults/dictation`. Jaunās instalācijās Superwhisper tiek atlasīts automātiski.

Omarchy automātiski ielādē atlasītās aizmugursistēmas darbvirsmas integrāciju. Nekāda Superwhisper konfigurācija mapē `~/.config/hypr/` nav nepieciešama.

Pielāgotas saites un skripti var izmantot `omarchy dictation start`, `omarchy dictation stop` un `omarchy dictation toggle`. Atlasītā aizmugursistēma apstrādā ierakstīšanu un transkripciju. Superwhisper atlasīšana atspējo tā vietējo turēšanas īsinājumtaustiņu un iestata tā vietējo pārslēgšanu uz `Ctrl + Alt + Space`, turot to atsevišķi no Omarchy ierakstīšanas taustiņiem. Superwhisper prasa vismaz vienu vietējo ierakstīšanas īsinājumtaustiņu, un tā atcelšanas īsinājumtaustiņš paliek pieejams.

Papildu aizmugursistēmas var integrēties, nemainot Omarchy. Nodrošiniet izpildāmo failu ar nosaukumu `omarchy-dictation-<backend>`, kas atrodas PATH, pieņem `start`, `stop` un `toggle` un nekavējoties atgriežas, kļūmes gadījumā ar statusu, kas nav nulle. Tā instalētājs konfigurē nodrošinātāju un pēc veiksmīgas iestatīšanas izsauc `omarchy-dictation-use <backend>`. Tas aptur iepriekšējo aizmugursistēmu un atomiski saglabā atlasi; `stop` ir jāizdodas, kad nodrošinātājs ir dīkstāvē vai nav pieejams. Aizmugursistēmu nosaukumos tiek izmantoti mazie burti, cipari un defises. Nodrošiniet `omarchy-install-dictation-<backend>` iestatīšanai; `omarchy default dictation <backend>` to palaiž. Pievienojiet Defaults izvēlnes ierakstu, izmantojot Omarchy izvēlnes paplašinājumu, lai izsauktu šo atlasītāju. Papildu darbvirsmas integrācija var atrasties `${XDG_CONFIG_HOME:-$HOME/.config}/<backend>/shortcuts.lua`.
