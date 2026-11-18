# Ekrānuzņēmumi un ierakstīšana

Viss, ko vari sagrābt no ekrāna, karājas pie Print Screen taustiņa. Viens pats taustiņš uzņem attēlu, bet modifikatori uzņem ierakstu, krāsu vai tekstu kādā apgabalā. Ja tavai tastatūrai Print Screen taustiņa vispār nav, `Super + Ctrl + Alt + C` uzņem to pašu ekrānuzņēmumu, bet `Super + Ctrl + C` atver visu kopu kā izvēlni.

| Taustiņkombinācija | Funkcija |
| ------ | -------- |
| `Print Screen` | Ekrānuzņēmums |
| `Super + Ctrl + Alt + C` | Ekrānuzņēmums |
| `Alt + Print Screen` | Ekrāna ieraksts (vai apturēt notiekošo) |
| `Super + Print Screen` | Krāsu pipete |
| `Super + Ctrl + Print Screen` | Izvilkt tekstu no apgabala |
| `Super + Ctrl + C` | Uzņemšanas izvēlne |
| `Super + Ctrl + .` | Pārkodēt attēlu vai video |

## Ekrānuzņēmumi

Nospied `Print Screen` (vai `Super + Ctrl + Alt + C`), un Omasnap uzņems fokusēto monitoru, pirms parādās tā pārklājums, tāpēc nekas zem tevis nepakustas, kamēr tēmē. Velc brīvas formas apgabalu, noklikšķini uz loga, lai to uzņemtu, vai noklikšķini uz tukšas vietas, lai uzņemtu visu monitoru. Pirms zīmēšanas nospied `S`, lai uzņemtu ritināmu apgabalu. Pārdomāji? Nospied to pašu taustiņu vēlreiz, lai aizvērtu Omasnap.

Kad esi izvēlējies apgabalu, Omasnap saglabā uzņemto, kopē to starpliktuvē un parāda paziņojumu ar tā sīktēlu, tāpat kā saglabāts ekrāna ieraksts. Izvēlies Open, lai skatītu saglabāto uzņēmumu savā attēlu skatītājā, vai Edit, lai to anotētu.

Anotāciju redaktors var zīmēt bultas, līnijas, figūras, izcēlumus, numurētus marķierus, tekstu un drošus aizklājumus; apgriezt vai izgriezt daļu attēla; veikt tā teksta OCR; un pievienot fonu. Redaktorā nospied `Enter`, lai kopētu un saglabātu gatavo PNG, `Ctrl + C`, lai to kopētu nesaglabājot, vai `Ctrl + S`, lai to saglabātu nekopējot.

Saglabātie ekrānuzņēmumi pēc noklusējuma nonāk `~/Pictures/Screenshots` ar nosaukumu, piemēram, `screenshot-2026-08-13_14-22-05-firefox.png`. Iestati `OMASNAP_SCREENSHOT_DIR`, lai izmantotu citu direktoriju — sk. [BUJ](46-faq.md), kur likt sesijas vides mainīgos. Omasnap izveido direktoriju, kad saglabā pirmo uzņēmumu. Iestati `[output] autosave = false` failā `~/.config/omasnap/omasnap.conf`, lai atspējotu automātisko saglabāšanu; uzņemtais tad tiek tikai kopēts un parādīts priekšskatījumā uz 10 sekundēm, ko vari paturēt uz ekrāna ar tā piespraušanas pogu vai `Ctrl + P`.

No termināļa `omarchy screenshot` atver to pašu pārklājumu, un vari izvēlēties tā sākuma režīmu: `omarchy capture screenshot region`, `windows`, `fullscreen` vai `scroll`. Otrais arguments `copy` vai `save` nosūta uzņēmumu uzreiz uz attiecīgo galamērķi. Lai pirms izvades rediģētu, izmanto `omarchy screenshot --editor=overlay` pilnekrāna redaktoram vai `omarchy screenshot --editor=window` atsevišķam logam.

### Atlasītāja vadīšana no tastatūras

Kamēr izvēle ir atvērta, pele tev vispār nav jāizmanto:

| Taustiņš | Funkcija |
| --- | -------- |
| `S` | Pārslēgt ritināmā apgabala režīmu |
| `Super + Arrow keys` | Pārvietoties starp logiem Window režīmā |
| `Return` | Uzņemt izcelto logu |
| `Ctrl + A` | Uzņemt visu fokusēto monitoru |
| `R` | Atjaunot pēdējo šajā sesijā uzzīmēto apgabalu |
| `Esc` | Aizvērt Omasnap |

Šīs piesaistes pastāv tikai kamēr Omasnap ir atvērts, tāpēc tās nevar konfliktēt ne ar ko tavā paša konfigurācijā.

## Ekrāna ierakstīšana

`Alt + Print Screen` atver _Trigger > Capture > Screenrecord_, kas jautā, ko vēlies skaņu celiņā: bez audio, darbvirsmas audio, darbvirsmas plus mikrofona vai darbvirsmas plus mikrofona plus tīmekļa kameras. Tas pēdējais parādās tikai tad, ja tev tiešām ir pieslēgta kamera. Izvēlies vienu, un Omarchy ieraksta atlasītājs ļauj tev vilkt apgabalu vai noklikšķināt uz loga vai monitora.

Ierakstīšana darbojas uz gpu-screen-recorder, kas kodē uz GPU ar 60fps un, ja nākas, pārslēdzas atpakaļ uz CPU. Rezultāts ir MP4 failā `~/Videos` ar nosaukumu `screenrecording-2026-08-13_14-22-05.mp4`. Iestati `OMARCHY_SCREENRECORD_DIR`, lai to mainītu — bet ņem vērā, ka atšķirībā no ekrānuzņēmumu direktorijas šai jau iepriekš ir jāpastāv, citādi ieraksts atsakās sākties.

Kamēr ieraksti, joslā parādās mazs indikators. Noklikšķini uz tā, lai apturētu. Vari apturēt arī vēlreiz ar `Alt + Print Screen` vai ar _Stop Screenrecording_ ierakstu sadaļā _Trigger > Capture > Screenrecord_, kas parādās tikai kamēr kaut kas tiešām tiek ierakstīts.

Apturēšana pirms faila nodošanas tev veic nelielu sakārtošanu: pirmais kadrs tiek apgriezts, un, ja ir audio, tas tiek normalizēts līdz -14 LUFS, pašā sākumā izslēdzot PipeWire uzņemšanas krakšķi. Pēc tam parādās paziņojums ar ieraksta sīktēlu. Noklikšķini uz tā, lai atskaņotu failu Omaview.

### Tīmekļa kameras pārklājums

Kad ieraksti ar tīmekļa kameru, kamera parādās kā piesprausts, apgriezts portreta logs tā, ko ieraksti, apakšējā labajā stūrī. Ja tā stāv virsū kaut kam, kas tev vajadzīgs, maini tās izmēru lidojumā:

| Taustiņkombinācija | Funkcija |
| ------ | -------- |
| `Super + Alt + [` | Samazināt tīmekļa kameras pārklājumu |
| `Super + Alt + ]` | Palielināt tīmekļa kameras pārklājumu |

Ir trīs izmēri — mazs, vidējs un liels — un karstie taustiņi pārslēdzas starp tiem. Vidējais ir noklusējums. Tie ir proporcionāli ierakstam, tāpēc kamera aizņem to pašu kadra daļu neatkarīgi no tā, vai ieraksti 1080p monitoru vai 6K monitoru. Un, ja ierakstīji apgabalu, nevis visu displeju, pārklājums noenkurojas pie attiecīgā apgabala stūra, nevis monitora, tāpēc tas paliek kadrā.

Vari to izsaukt arī tieši ar `omarchy-capture-webcam-resize small` vai `reset`, lai atgrieztos pie vidējā.

## Teksts, QR kodi un krāsas

`Super + Ctrl + Print Screen` izvēlas apgabalu un veic tā OCR uz starpliktuvi. Tas ir kārtīgi aprakstīts sadaļā [Teksta izvilkšana un diktēšana](11-text-extraction-dictation.md).

_Trigger > Capture > QR Code_ dara to pašu triku ar QR kodiem. Izvēlies apgabalu ar kodu tajā, un atšifrētā vērtība nonāk starpliktuvē. Tas meklē tikai QR kodus — blīvam ekrāna saturam citādi ir paradums kļūdaini izlikties par svītrkodu. Vērts zināt: atšifrētā vērtība nonāk starpliktuvē un nekur citur. Tā netiek izdrukāta, tās nav paziņojumā, un tā ir atzīmēta kā sensitīva, tāpēc tā nepaliek [starpliktuves vēsturē](08-unified-clipboard-history.md). QR kodi regulāri nes noslēpumus — piemēram, `otpauth://` URI aiz 2FA iestatīšanas koda — un tu negribi to žurnālā. Ielīmēšana joprojām darbojas labi.

`Super + Print Screen` (vai _Trigger > Capture > Color_) pārvērš kursoru par pipeti. Noklikšķini uz jebkā uz ekrāna, un krāsa nonāk starpliktuvē. Nospied karsto taustiņu vēlreiz, lai izietu, neko neizvēloties.

## Pārkodēšana pirms kopīgošanas

4K ekrāna ieraksts vai neapstrādāts HEIC no tava tālruņa bieži ir pārāk liels, lai to vienkārši nosūtītu. `Super + Ctrl + .` (vai _Trigger > Transcode_) to salabo. Tas piedāvā tev failu atlasītāju ar neskaidro meklēšanu pāri `~/Pictures` un `~/Videos`, pēc tam jautā formātu un izmēru.

Attēli tiek pārveidoti uz jpg vai png augstā, vidējā vai zemā kvalitātē, kas ierobežo platumu līdz 3160, 2160 un 1080 pikseļiem. Video tiek pārveidoti uz mp4 vai animētu gif ar 4k, 1080p vai 720p. Pārveidotais fails tiek ierakstīts blakus oriģinālam ar izšķirtspēju nosaukumā — `demo-1080p.mp4` — un ceļš tiek kopēts starpliktuvē kā faila URI, tāpēc vari to ielīmēt tieši lietotnē, kas pieņem failu nomešanu.

Tas darbojas arī no termināļa, ja jau zini, ko vēlies: `omarchy transcode ~/Videos/demo.mov mp4 1080p`. Ir arī `omarchy transcode ascii`, kas pārvērš attēlu ASCII mākslā — tas galvenokārt ir paredzēts [zīmolvedei](41-branding.md).

## Nosūtīšana kaut kur

Kad fails tev ir, `Super + Ctrl + S` atver Share izvēlni un nosūta to uz citu ierīci tavā tīklā, izmantojot LocalSend. Par to sk. [GUIs](22-guis.md).
