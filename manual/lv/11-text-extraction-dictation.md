# Teksta iegūšana un diktēšana

### Teksta iegūšana

Nospied `Super + Ctrl + PrtScr`, lai atlasītu ekrāna apgabalu teksta iegūšanai. Pēc tam atvērtā koda OCR modelis tesseract ātri pārveidos šo atlasi tekstā un ievietos to starpliktuvē. Pēc tam vienkārši nospied `Super + V`, lai ielīmētu.

Tas ir ļoti noderīgi, lai iegūtu adreses no attēlu kājenēm vai tālruņa numurus, kas iegulti vietņu virsrakstos.

 ![text-extraction](images/text-extraction.webp)

### Diktēšana

Jaunās instalācijās [Superwhisper](https://superwhisper.com/) ir noklusējuma diktēšanas aizmugursistēma, kas izmanto mākoņapstrādi bez bezsaistes modeļu lejupielādes. Izvēlies Superwhisper, [Voxtype](https://voxtype.io/) vai [Hex](https://anoma.ly/hex/) Omarchy izvēlnē sadaļā _Setup > Defaults > Dictation_. Aizmugursistēmas atlasīšana to instalē, ja nepieciešams, un padara to par diktēšanas noklusējumu. Voxtype ielādē bāzes angļu valodas modeli, kas aizņem 150MB; maini modeli ar `voxtype setup model` un citus iestatījumus sadaļā `~/.config/voxtype/config.toml`. Superwhisper atver savus iestatījumus, lai izvēlētos mākoņa vai lokālo apstrādi, un OPR uztur lietojumprogrammu atjauninātu. Hex iestatīšanas laikā lejupielādē savu ierīcē esošo runas modeli un darbojas kā `hex.service` lietotāja pakalpojums; atver tā logu no joslas teknes ikonas vai palaižot `hex`, lai mainītu modeli un citus iestatījumus.

Tu diktē, turot nospiestu `Right Alt`, vai pārslēdzot ar `Alt + Space`, un diktētais teksts parādīsies fokusētajā ievades laukā. Šie saīsinājumtaustiņi izmanto atlasīto aizmugursistēmu. Right Alt arī sāk diktēšanu, ja to izmanto modifikatora akordā; šiem akordiem izmanto Left Alt. Tastatūras izkārtojumos, kuros Right Alt ir AltGr, izmanto `Alt + Space`, lai AltGr paliktu pieejams rakstīšanai. Instalācijas no laika, pirms Alt + Space kļuva par noklusējumu, saglabā `F9` runāšanai turot nospiestu un `Super + Ctrl + X` pārslēgšanai, kas pievienoti `~/.config/hypr/bindings.lua`, kur šis `Super + Ctrl + X` aizņem aģentu paneļa vietu; noņem tos tur, lai atdotu šos taustiņus lietojumprogrammām un panelim.

Tie paši saīsinājumtaustiņi darbojas ar katru aizmugursistēmu. Atlasi savu aizmugursistēmu sadaļā Setup > Defaults > Dictation. Aizmugursistēmas instalētājs to konfigurē un saglabā atlasi. Palaid `omarchy default dictation`, lai redzētu, kura ir atlasīta. Atlase tiek saglabāta `~/.config/omarchy/defaults/dictation`. Jaunās instalācijas automātiski atlasa Superwhisper.

Omarchy automātiski ielādē atlasītās aizmugursistēmas darbvirsmas integrāciju. Nekāda Superwhisper konfigurācija nav nepieciešama `~/.config/hypr/`.

Pielāgotas piesaistes un skripti var izmantot `omarchy dictation start`, `omarchy dictation stop` un `omarchy dictation toggle`. Atlasītā aizmugursistēma apstrādā ierakstīšanu un transkripciju. Superwhisper atlasīšana atspējo tā vietējo turēšanas saīsinājumtaustiņu un iestata tā vietējo pārslēgšanu uz `Ctrl + Alt + Space`, turot to atsevišķi no Omarchy ierakstīšanas taustiņiem. Superwhisper ir nepieciešams vismaz viens vietējais ierakstīšanas saīsinājumtaustiņš, un tā atcelšanas saīsinājumtaustiņš paliek pieejams.

Papildu aizmugursistēmas var integrēties, nemainot Omarchy. Nodrošini izpildāmo failu ar nosaukumu `omarchy-dictation-<backend>` PATH, kas pieņem `start`, `stop` un `toggle` un nekavējoties atgriežas, kļūmes gadījumā ar statusu, kas nav nulle. Tā instalētājs konfigurē nodrošinātāju un pēc veiksmīgas iestatīšanas izsauc `omarchy-dictation-use <backend>`. Tas aptur iepriekšējo aizmugursistēmu un atomāri saglabā atlasi; `stop` ir jāizdodas, kad nodrošinātājs ir dīkstāvē vai nav pieejams. Aizmugursistēmu nosaukumos izmanto mazos burtus, ciparus un defises. Nodrošini `omarchy-install-dictation-<backend>` iestatīšanai; `omarchy default dictation <backend>` to palaiž. Pievieno Defaults izvēlnes ierakstu, izmantojot Omarchy izvēlnes paplašinājumu, lai izsauktu šo atlasītāju. Izvēles darbvirsmas integrācija var atrasties `${XDG_CONFIG_HOME:-$HOME/.config}/<backend>/shortcuts.lua`.
