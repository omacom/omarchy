# Ekrānuzņēmumi un ierakstīšana

Viss, ko tu vari paņemt no ekrāna, karājas uz taustiņa Print Screen. Viens taustiņš pats uzņem attēlu, un modifikatori uzņem ierakstu, krāsu vai tekstu reģiona iekšpusē. Ja tavai tastatūrai vispār nav taustiņa Print Screen, `Super + Ctrl + C` atver to pašu kopu kā izvēlni.

| Karstā taustiņa kombinācija | Funkcija |
| ------ | -------- |
| `Print Screen` | Ekrānuzņēmums |
| `Alt + Print Screen` | Ekrāna ieraksts (vai apturēt to, kas darbojas) |
| `Super + Print Screen` | Krāsu atlasītājs |
| `Super + Ctrl + Print Screen` | Iegūt tekstu no reģiona |
| `Super + Ctrl + C` | Uzņemšanas izvēlne |
| `Super + Ctrl + .` | Pārkodēt attēlu vai video |

## Ekrānuzņēmumi

Nospied `Print Screen`, un Omasnap uzņem fokusēto monitoru, pirms parādās tā pārklājums, tāpēc nekas zem tevis nepārvietojas, kamēr tu tēmē. Velc brīvas formas reģionu, noklikšķini uz loga, lai to uzņemtu, vai noklikšķini tukšā vietā, lai uzņemtu visu monitoru. Pirms zīmēšanas nospied `S`, lai uzņemtu ritinošu reģionu. Pārdomāji? Nospied `Print Screen` vēlreiz, lai aizvāktu Omasnap.

Pēc tam, kad tu atlasi apgabalu, Omasnap saglabā uzņemto, kopē to starpliktuvē un 10 sekundes rāda priekšskatījumu. Izmanto priekšskatījuma piespraušanas pogu vai `Ctrl + P`, lai to paturētu ekrānā, vai izvēlies Rediģēt, lai to anotētu.

Anotāciju redaktors var zīmēt bultiņas, līnijas, figūras, izgaismojumus, numurētus marķierus, tekstu un drošas redakcijas; apgriezt vai izgriezt daļu attēla; OCR tā tekstu; un pievienot fonu. Redaktorā nospied `Enter`, lai kopētu un saglabātu pabeigto PNG, `Ctrl + C`, lai kopētu to bez saglabāšanas, vai `Ctrl + S`, lai saglabātu to bez kopēšanas.

Saglabātie ekrānuzņēmumi pēc noklusējuma nonāk `~/Pictures/Screenshots` ar nosaukumu, piemēram, `screenshot-2026-08-13_14-22-05-firefox.png`. Iestati `OMASNAP_SCREENSHOT_DIR`, lai izmantotu citu direktoriju — skat. [BUJ](46-faq.md), kur ievietot sesijas vides mainīgos. Omasnap izveido direktoriju, kad saglabā pirmo uzņemto. Iestati `[output] autosave = false` failā `~/.config/omasnap/omasnap.conf`, lai atspējotu automātisko saglabāšanu.

No termināla `omarchy screenshot` atver to pašu pārklājumu, un tu vari izvēlēties tā sākuma režīmu: `omarchy capture screenshot region`, `windows`, `fullscreen` vai `scroll`. Otrais arguments `copy` vai `save` izlaiž priekšskatījumu un nosūta uzņemto tieši uz šo galamērķi. Lai rediģētu pirms izvades, izmanto `omarchy screenshot --editor=overlay` pilnekrāna redaktoram vai `omarchy screenshot --editor=window` atsevišķam logam.

### Atlasītāja vadīšana no tastatūras

Kamēr atlase ir augšā, tev vispār nav jāizmanto pele:

| Taustiņš | Funkcija |
| --- | -------- |
| `S` | Pārslēgt ritinoša reģiona režīmu |
| `Super + Arrow keys` | Pārvietoties starp logiem logu režīmā |
| `Return` | Uzņemt izgaismoto logu |
| `Ctrl + A` | Uzņemt visu fokusēto monitoru |
| `R` | Atjaunot pēdējo šajā sesijā uzzīmēto reģionu |
| `Esc` | Aizvākt Omasnap |

Šīs piesaistes pastāv tikai kamēr Omasnap ir atvērts, tāpēc tās nevar sadurties ne ar ko tavā konfigurācijā.

## Ekrāna ierakstīšana

`Alt + Print Screen` atver _Palaist > Uzņemt > Ekrāna ieraksts_, kas jautā, ko tu vēlies skaņu celiņā: bez audio, darbvirsmas audio, darbvirsmas plus mikrofons vai darbvirsmas plus mikrofons plus tīmekļa kamera. Pēdējais parādās tikai tad, ja tev patiešām ir pievienota kamera. Izvēlies vienu, un Omarchy ierakstīšanas atlasītājs ļauj tev vilkt reģionu vai noklikšķināt uz loga vai monitora.

Ierakstīšana darbojas ar gpu-screen-recorder, kas kodē GPU ar 60 kadriem/s un atkāpjas uz CPU, ja nepieciešams. Rezultāts ir MP4 mapē `~/Videos` ar nosaukumu `screenrecording-2026-08-13_14-22-05.mp4`. Iestati `OMARCHY_SCREENRECORD_DIR`, lai to mainītu — bet ņem vērā, ka atšķirībā no ekrānuzņēmumu direktorijas šai ir jāpastāv jau iepriekš, citādi ierakstīšana atteiksies sākties.

Kamēr tu ieraksti, joslā parādās mazs rādītājs. Noklikšķini uz tā, lai apturētu. Tu vari arī apturēt vēlreiz ar `Alt + Print Screen` vai ar ierakstu _Apturēt ekrāna ierakstu_ zem _Palaist > Uzņemt > Ekrāna ieraksts_, kas parādās tikai kamēr kaut kas patiešām ieraksta.

Apturēšana veic mazliet sakopšanas, pirms tā tev nodod failu: pirmais kadrs tiek apgriezts, un, ja ir audio, tas tiek normalizēts uz -14 LUFS ar PipeWire uzņemšanas sprakšķi pašā sākumā izslēgtu. Pēc tam parādās paziņojums ar sīktēlu no ieraksta. Noklikšķini uz tā, lai atskaņotu failu mpv.

### Tīmekļa kameras pārklājums

Kad tu ieraksti ar tīmekļa kameru, kamera parādās kā piesprausts, apgriezts portreta logs tā, ko tu ieraksti, apakšējā labajā stūrī. Ja tā sēž virsū kaut kam, kas tev vajadzīgs, maini tā izmēru lidojumā:

| Karstā taustiņa kombinācija | Funkcija |
| ------ | -------- |
| `Super + Alt + [` | Padarīt tīmekļa kameras pārklājumu mazāku |
| `Super + Alt + ]` | Padarīt tīmekļa kameras pārklājumu lielāku |

Ir trīs izmēri — mazs, vidējs un liels —, un karstās taustiņu kombinācijas soļo starp tiem. Vidējs ir noklusējums. Tie ir proporcionāli ierakstam, tāpēc kamera aizņem tādu pašu kadra daļu neatkarīgi no tā, vai tu ieraksti 1080p monitoru vai 6K monitoru. Un, ja tu ierakstīji reģionu, nevis visu displeju, pārklājums noenkurojas pie šī reģiona stūra, nevis monitora stūra, tāpēc tas paliek kadra iekšpusē.

Tu vari to izsaukt tieši arī ar `omarchy-capture-webcam-resize small` vai `reset`, lai atgrieztos pie vidēja.

## Teksts, QR kodi un krāsas

`Super + Ctrl + Print Screen` atlasa reģionu un OCR to starpliktuvē. Tas ir pareizi apskatīts [Teksta iegūšana un diktēšana](11-text-extraction-dictation.md).

_Palaist > Uzņemt > QR kods_ dara to pašu triku QR kodiem. Atlasi reģionu ar kodu tajā, un dekodētā vērtība nonāk starpliktuvē. Tā meklē tikai QR kodus — blīvam ekrāna saturam citādi ir ieradums kļūdaini pozitīvi izpausties kā svītrkodam. Ir vērts zināt: dekodētā vērtība nonāk starpliktuvē un nekur citur. Tā netiek izdrukāta, tā nav paziņojumā, un tā ir atzīmēta kā sensitīva, tāpēc tā nepaliek [starpliktuves vēsturē](08-unified-clipboard-history.md). QR kodi regulāri nes noslēpumus — piemēram, `otpauth://` URI aiz 2FA iestatīšanas koda —, un tu to nevēlies žurnālā. Ielīmēšana joprojām darbojas labi.

`Super + Print Screen` (vai _Palaist > Uzņemt > Krāsa_) pārvērš kursoru par pipeti. Noklikšķini uz jebkā ekrānā, un krāsa nonāk starpliktuvē. Nospied karsto taustiņa kombināciju vēlreiz, lai atkāptos, neizvēloties.

## Pārkodēšana pirms kopīgošanas

4K ekrāna ieraksts vai neapstrādāts HEIC no tava tālruņa bieži ir pārāk liels, lai vienkārši nosūtītu. `Super + Ctrl + .` (vai _Palaist > Pārkodēt_) to izlabo. Tas piedāvā tev izplūdušu failu atlasītāju virs `~/Pictures` un `~/Videos`, pēc tam jautā formātu un izmēru.

Attēli nonāk jpg vai png formātā augstā, vidējā vai zemā kvalitātē, kas ierobežo platumu līdz 3160, 2160 un 1080 pikseļiem. Video nonāk mp4 vai animētā gif formātā 4k, 1080p vai 720p. Pārvērstais fails tiek ierakstīts blakus oriģinālam ar izšķirtspēju nosaukumā — `demo-1080p.mp4` —, un ceļš tiek kopēts starpliktuvē kā faila URI, tāpēc tu vari to ielīmēt tieši lietotnē, kas pieņem failu nomešanu.

Tas darbojas arī no termināla, ja tu jau zini, ko vēlies: `omarchy transcode ~/Videos/demo.mov mp4 1080p`. Ir arī `omarchy transcode ascii`, kas pārvērš attēlu ASCII mākslā — tas galvenokārt ir paredzēts [zīmolvedībai](41-branding.md).

## Nosūtīšana kaut kur

Kad tev ir fails, `Super + Ctrl + S` atver izvēlni Koplietot un nosūta to citai ierīcei tavā tīklā, izmantojot LocalSend. Skat. [GUI](22-guis.md) par to.
