# Teksta izgūšana un diktēšana

### Teksta izgūšana

Nospiediet `Super + Ctrl + PrtScr`, lai atlasītu ekrāna apgabalu teksta izgūšanai. Atvērtā koda OCR modelis tesseract pēc tam ātri pārveidos šo atlasi tekstā un ievietos to starpliktuvē. Pēc tam vienkārši nospiediet `Super + V`, lai ielīmētu.

Tas ir ļoti noderīgi, lai izgūtu adreses no attēlu kājenēm vai tālruņa numurus, kas iegulti tīmekļa vietņu virsrakstos.

 ![text-extraction](images/text-extraction.webp)

### Diktēšana

Jaunās instalācijās [Superwhisper](https://superwhisper.com/) ir noklusējuma diktēšanas aizmugursistēma, kas izmanto mākoņapstrādi bez bezsaistes modeļu lejupielādes. Izvēlieties Superwhisper, [Voxtype](https://voxtype.io/) vai [Hex](https://anoma.ly/hex/) Omarchy izvēlnē sadaļā _Setup > Defaults > Dictation_. Aizmugursistēmas izvēle to instalē, ja nepieciešams, un padara to par diktēšanas noklusējumu. Voxtype ielādē pamata angļu valodas modeli, kas aizņem 150MB; mainiet modeli ar `voxtype setup model` un citus iestatījumus sadaļā `~/.config/voxtype/config.toml`. Superwhisper atver savus iestatījumus, lai izvēlētos mākoņa vai lokālo apstrādi, un OPR uztur lietojumprogrammu atjauninātu. Hex iestatīšanas laikā lejupielādē savu ierīcē esošo runas modeli un darbojas kā `hex.service` lietotāja pakalpojums; atveriet tā logu no joslas teknes ikonas vai palaižot `hex`, lai mainītu modeli un citus iestatījumus.

Jūs diktējat, turot nospiestu `Right Alt` vai pārslēdzot ar `Alt + Space`, un nodiktētais teksts parādīsies fokusētajā ievades laukā. Šie saīsinājumi izmanto izvēlēto aizmugursistēmu. Right Alt sāk diktēšanu arī tad, ja to izmanto modifikatora akordā; šādiem akordiem izmantojiet Left Alt. Tastatūras izkārtojumos, kuros Right Alt ir AltGr, tostarp tad, ja šāds izkārtojums ir viens no tiem, uz kuriem pārslēdzaties, turiet to atsevišķi vienu brīdi, lai diktētu; AltGr, nospiežot kopā ar citu taustiņu, joprojām ievada tā rakstzīmi. Instalācijas no laika pirms Alt + Space kļuva par noklusējumu saglabā `F9` runāšanai turot un `Super + Ctrl + X` pārslēgšanai, kas pievienoti `~/.config/hypr/bindings.lua`, kur šis `Super + Ctrl + X` ieņem aģentu paneļa vietu; noņemiet tos tur, lai atdotu šos taustiņus lietojumprogrammām un panelim.

Tie paši saīsinājumi darbojas ar katru aizmugursistēmu. Izvēlieties savu aizmugursistēmu sadaļā Setup > Defaults > Dictation. Aizmugursistēmas instalētājs to konfigurē un saglabā izvēli. Palaidiet `omarchy default dictation`, lai redzētu, kura ir izvēlēta. Izvēle tiek saglabāta `~/.config/omarchy/defaults/dictation`. Jaunas instalācijas automātiski izvēlas Superwhisper.

Omarchy automātiski ielādē izvēlētās aizmugursistēmas darbvirsmas integrāciju. Nekāda Superwhisper konfigurācija sadaļā `~/.config/hypr/` nav nepieciešama.

Pielāgotas saistes un skripti var izmantot `omarchy dictation start`, `omarchy dictation stop` un `omarchy dictation toggle`. Izvēlētā aizmugursistēma veic ierakstīšanu un transkripciju. Superwhisper izvēle atspējo tā vietējo turēšanas saīsinājumu un iestata tā vietējo pārslēgšanu uz `Ctrl + Alt + Space`, turot to atsevišķi no Omarchy ierakstīšanas taustiņiem. Superwhisper pieprasa vismaz vienu vietējo ierakstīšanas saīsinājumu, un tā atcelšanas saīsinājums paliek pieejams.

Papildu aizmugursistēmas var integrēties, nemainot Omarchy. Nodrošiniet izpildāmu failu ar nosaukumu `omarchy-dictation-<backend>` PATH, kas pieņem `start`, `stop` un `toggle` un atgriežas nekavējoties, kļūmes gadījumā ar statusu, kas nav nulle. Tā instalētājs konfigurē nodrošinātāju un pēc veiksmīgas iestatīšanas izsauc `omarchy-dictation-use <backend>`. Tas aptur iepriekšējo aizmugursistēmu un atomiski saglabā izvēli; `stop` ir jāizdodas, kad nodrošinātājs ir dīkstāvē vai nav pieejams. Aizmugursistēmu nosaukumos izmanto mazos burtus, ciparus un defises. Nodrošiniet `omarchy-install-dictation-<backend>` iestatīšanai; `omarchy default dictation <backend>` to palaiž. Pievienojiet Defaults izvēlnes ierakstu, izmantojot Omarchy izvēlnes paplašinājumu, lai izsauktu šo atlasītāju. Neobligātā darbvirsmas integrācija var atrasties `${XDG_CONFIG_HOME:-$HOME/.config}/<backend>/shortcuts.lua`.
