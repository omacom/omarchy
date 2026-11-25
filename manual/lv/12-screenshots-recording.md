# Ekrānuzņēmumi un ierakstīšana

Viss, ko varat noķert no ekrāna, ir piesaistīts taustiņam Print Screen. Viens taustiņš pats par sevi uzņem attēlu, bet modifikatori veic ierakstīšanu, paņem krāsu vai tekstu reģiona iekšienē. Ja jūsu tastatūrai vispār nav taustiņa Print Screen, `Super + Ctrl + Alt + C` uzņem to pašu ekrānuzņēmumu, un `Super + Ctrl + C` atver visu kopu kā izvēlni.

| Saīsne | Funkcija |
| ------ | -------- |
| `Print Screen` | Ekrānuzņēmums |
| `Super + Ctrl + Alt + C` | Ekrānuzņēmums |
| `Alt + Print Screen` | Ekrāna ierakstīšana (vai apturēt pašlaik notiekošo) |
| `Super + Print Screen` | Krāsu atlasītājs |
| `Super + Ctrl + Print Screen` | Izvilkt tekstu no reģiona |
| `Super + Ctrl + C` | Uzņemšanas izvēlne |
| `Super + Ctrl + .` | Pārkodēt attēlu vai video |

## Ekrānuzņēmumi

Nospiediet `Print Screen` (vai `Super + Ctrl + Alt + C`), un Omasnap nofiksē fokusēto monitoru, pirms parādās tā pārklājums, tāpēc nekas nepārbīdās zem jums, kamēr tēmējat. Velciet brīvas formas reģionu, noklikšķiniet uz loga, lai to uzņemtu, vai noklikšķiniet uz tukšas vietas, lai uzņemtu visu monitoru. Nospiediet `S` pirms zīmēšanas, lai uzņemtu ritināmu reģionu. Pārdomājāt? Nospiediet to pašu taustiņu vēlreiz, lai aizvērtu Omasnap.

Pēc reģiona atlasīšanas Omasnap saglabā uzņemto, kopē to starpliktuvē un parāda paziņojumu ar tā sīktēlu, tāpat kā saglabāts ekrāna ieraksts. Izvēlieties Open, lai skatītu saglabāto kadru savā attēlu skatītājā, vai Edit, lai to anotētu.

Anotāciju redaktors var zīmēt bultiņas, līnijas, figūras, izcēlumus, numurētus marķierus, tekstu un drošas redakcijas; apgriezt vai izgriezt daļu attēla; veikt tā teksta OCR; un pievienot fonu. Redaktorā nospiediet `Enter`, lai kopētu un saglabātu gatavo PNG, `Ctrl + C`, lai to kopētu, nesaglabājot, vai `Ctrl + S`, lai to saglabātu, nekopējot.

Saglabātie ekrānuzņēmumi pēc noklusējuma nonāk `~/Pictures/Screenshots` ar nosaukumu, piemēram, `screenshot-2026-08-13_14-22-05-firefox.png`. Iestatiet `OMASNAP_SCREENSHOT_DIR`, lai izmantotu citu direktoriju — skatiet [BUJ](46-faq.md), kur likt sesijas vides mainīgos. Omasnap izveido direktoriju, kad saglabā pirmo kadru. Iestatiet `[output] autosave = false` failā `~/.config/omasnap/omasnap.conf`, lai atspējotu automātisko saglabāšanu; uzņemtie tad tiek tikai kopēti un parādīti priekšskatījumā uz 7 sekundēm, ko varat paturēt ekrānā ar tā piespraušanas pogu vai `Ctrl + P`.

No termināļa `omarchy screenshot` atver to pašu pārklājumu, un varat izvēlēties tā sākuma režīmu: `omarchy capture screenshot region`, `windows`, `fullscreen` vai `scroll`. Otrais arguments `copy` vai `save` nosūta kadru tieši uz to galamērķi. Lai rediģētu pirms izvades, izmantojiet `omarchy screenshot --editor=overlay` pilnekrāna redaktoram vai `omarchy screenshot --editor=window` atsevišķam logam.

### Atlasītāja vadīšana no tastatūras

Kamēr atlase ir atvērta, pele jums vispār nav jāizmanto:

| Taustiņš | Funkcija |
| --- | -------- |
| `S` | Pārslēgt ritināmā reģiona režīmu |
| `Super + Arrow keys` | Pārvietoties starp logiem logu režīmā |
| `Return` | Uzņemt izcelto logu |
| `Ctrl + A` | Uzņemt visu fokusēto monitoru |
| `R` | Atjaunot pēdējo šajā sesijā uzzīmēto reģionu |
| `Esc` | Aizvērt Omasnap |

Šīs saīsnes pastāv tikai tad, kamēr Omasnap ir atvērts, tāpēc tās nevar konfliktēt ne ar ko jūsu pašu konfigurācijā.

## Ekrāna ierakstīšana

`Alt + Print Screen` atver _Trigger > Capture > Screenrecord_, kas jautā, ko vēlaties skaņu celiņā: bez audio, darbvirsmas audio, darbvirsmas plus mikrofons vai darbvirsmas plus mikrofons plus tīmekļa kamera. Pēdējais parādās tikai tad, ja jums tiešām ir pievienota kamera. Izvēlieties vienu, un Omarchy ierakstīšanas atlasītājs ļauj vilkt reģionu vai noklikšķināt uz loga vai monitora.

Ierakstīšana darbojas ar gpu-screen-recorder, kas kodē ar GPU pie 60fps un, ja nepieciešams, atgriežas pie CPU; GPU, ko tas neatbalsta, piemēram, Apple Silicon, Omarchy tā vietā ieraksta ar wf-recorder. Rezultāts ir MP4 failā `~/Videos` ar nosaukumu `screenrecording-2026-08-13_14-22-05.mp4`. Iestatiet `OMARCHY_SCREENRECORD_DIR`, lai to mainītu — bet ņemiet vērā, ka atšķirībā no ekrānuzņēmumu direktorija šim jau ir jāpastāv, citādi ierakstīšana atsakās sākties.

Kamēr ierakstāt, joslā parādās mazs indikators. Noklikšķiniet uz tā, lai apturētu. Varat apturēt arī ar `Alt + Print Screen` vēlreiz vai ar ierakstu _Stop Screenrecording_ sadaļā _Trigger > Capture > Screenrecord_, kas parādās tikai tad, kamēr kaut kas tiešām tiek ierakstīts.

Apturēšana pirms faila nodošanas jums veic nelielu sakārtošanu: pirmais kadrs tiek apgriezts, un, ja ir audio, tas tiek normalizēts līdz -14 LUFS, pašā sākumā izslēdzot PipeWire uzņemšanas klikšķi. Pēc tam parādās paziņojums ar ieraksta sīktēlu. Izvēlieties _Open_, lai atskaņotu failu Omaview, vai _Cut_, lai to apgrieztu Omacut.

### Tīmekļa kameras pārklājums

Kad ierakstāt ar tīmekļa kameru, kamera parādās kā piesprausts, apgriezts portreta logs tā apakšējā labajā stūrī, ko ierakstāt. Ja tā atrodas virsū kaut kam vajadzīgam, mainiet tās izmēru lidojumā:

| Saīsne | Funkcija |
| ------ | -------- |
| `Super + Alt + [` | Padarīt tīmekļa kameras pārklājumu mazāku |
| `Super + Alt + ]` | Padarīt tīmekļa kameras pārklājumu lielāku |

Ir trīs izmēri — mazs, vidējs un liels — un saīsnes pārslēdzas starp tiem. Vidējs ir noklusējums. Tie ir proporcionāli ierakstam, tāpēc kamera aizņem vienādu kadra daļu neatkarīgi no tā, vai ierakstāt 1080p monitoru vai 6K monitoru. Un, ja ierakstījāt reģionu, nevis visu displeju, pārklājums noenkurojas pie tā reģiona stūra, nevis monitora stūra, tāpēc tas paliek kadra iekšienē.

Varat to izsaukt arī tieši ar `omarchy-capture-webcam-resize small` vai `reset`, lai atgrieztos pie vidējā.

## Teksts, QR kodi un krāsas

`Super + Ctrl + Print Screen` atlasa reģionu un veic tā OCR uz starpliktuvi. Tas ir kārtīgi aprakstīts sadaļā [Teksta izvilkšana un diktēšana](11-text-extraction-dictation.md).

_Trigger > Capture > QR Code_ dara to pašu triku QR kodiem. Atlasiet reģionu ar kodu tajā, un atšifrētā vērtība nonāk starpliktuvē. Tas meklē tikai QR kodus — blīvam ekrāna saturam citādi ir ieradums kļūdaini tikt uztvertam kā svītrkodam. Vērts zināt: atšifrētā vērtība nonāk starpliktuvē un nekur citur. Tā netiek drukāta, tās nav paziņojumā, un tā ir atzīmēta kā sensitīva, tāpēc tā nepaliek [starpliktuves vēsturē](08-unified-clipboard-history.md). QR kodi regulāri nes noslēpumus — piemēram, `otpauth://` URI aiz 2FA iestatīšanas koda — un jūs to nevēlaties žurnālā. Ielīmēšana joprojām darbojas labi.

`Super + Print Screen` (vai _Trigger > Capture > Color_) pārvērš kursoru par pipeti. Noklikšķiniet uz jebkā ekrānā, un krāsa nonāk starpliktuvē. Nospiediet saīsni vēlreiz, lai izietu, neko neizvēloties.

## Pārkodēšana pirms kopīgošanas

4K ekrāna ieraksts vai neapstrādāts HEIC no jūsu tālruņa bieži ir pārāk liels, lai to vienkārši nosūtītu. `Super + Ctrl + .` (vai _Trigger > Transcode_) to atrisina. Tas piedāvā jums failu atlasītāju ar izplūdušo meklēšanu pār `~/Pictures` un `~/Videos`, pēc tam jautā formātu un izmēru.

Attēli tiek pārveidoti par jpg vai png augstā, vidējā vai zemā kvalitātē, kas ierobežo platumu līdz 3160, 2160 un 1080 pikseļiem. Video tiek pārveidoti par mp4 vai animētu gif ar 4k, 1080p vai 720p. Pārveidotais fails tiek ierakstīts blakus oriģinālam ar izšķirtspēju nosaukumā — `demo-1080p.mp4` — un ceļš tiek kopēts starpliktuvē kā faila URI, tāpēc varat to ielīmēt tieši lietotnē, kas pieņem failu nomešanu.

Tas darbojas arī no termināļa, ja jau zināt, ko vēlaties: `omarchy transcode ~/Videos/demo.mov mp4 1080p`. Ir arī `omarchy transcode ascii`, kas pārvērš attēlu ASCII mākslā — tas galvenokārt paredzēts [zīmola veidošanai](41-branding.md).

## Nosūtīšana kaut kur

Kad fails ir gatavs, `Super + Ctrl + S` atver izvēlni Share un nosūta to uz citu ierīci jūsu tīklā, izmantojot LocalSend. Par to skatiet [GUI](22-guis.md).
