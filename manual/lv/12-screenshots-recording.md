# Ekrānuzņēmumi un ierakstīšana

Viss, ko varat noķert no ekrāna, ir pakārtots Print Screen taustiņam. Taustiņš viens pats uzņem attēlu, bet modifikatori veic ierakstu, paņem krāsu vai tekstu reģiona iekšienē. Ja jūsu tastatūrai Print Screen taustiņa nav vispār, `Super + Ctrl + Alt + C` uzņem to pašu ekrānuzņēmumu, bet `Super + Ctrl + C` atver visu kopu kā izvēlni.

| Taustiņu kombinācija | Funkcija |
| ------ | -------- |
| `Print Screen` | Ekrānuzņēmums |
| `Super + Ctrl + Alt + C` | Ekrānuzņēmums |
| `Alt + Print Screen` | Ekrāna ieraksts (vai apturēt to, kas pašlaik darbojas) |
| `Super + Print Screen` | Krāsu atlasītājs |
| `Super + Ctrl + Print Screen` | Izvilkt tekstu no reģiona |
| `Super + Ctrl + C` | Tveršanas izvēlne |
| `Super + Ctrl + .` | Pārkodēt attēlu vai videoklipu |

## Ekrānuzņēmumi

Nospiediet `Print Screen` (vai `Super + Ctrl + Alt + C`), un Omasnap tver fokusēto monitoru, pirms parādās tā pārklājums, tāpēc nekas zem jums nepārbīdās, kamēr tēmējat. Velciet brīvas formas reģionu, noklikšķiniet uz loga, lai to tvertu, vai noklikšķiniet uz tukšas vietas, lai tvertu visu monitoru. Pirms zīmēšanas nospiediet `S`, lai tvertu ritināmu reģionu. Pārdomājāt? Nospiediet to pašu taustiņu vēlreiz, lai aizvērtu Omasnap.

Kad esat izvēlējies apgabalu, Omasnap saglabā uzņēmumu, kopē to starpliktuvē un 10 sekundes rāda priekšskatījumu. Izmantojiet priekšskatījuma piespraušanas pogu vai `Ctrl + P`, lai to paturētu uz ekrāna, vai izvēlieties Edit, lai to anotētu.

Anotāciju redaktors var zīmēt bultas, līnijas, formas, izcēlumus, numurētus marķierus, tekstu un drošas redakcijas; apgriezt vai izgriezt daļu attēla; veikt tā teksta OCR; un pievienot fonu. Redaktorā nospiediet `Enter`, lai kopētu un saglabātu gatavo PNG, `Ctrl + C`, lai to kopētu nesaglabājot, vai `Ctrl + S`, lai to saglabātu nekopējot.

Saglabātie ekrānuzņēmumi pēc noklusējuma nonāk `~/Pictures/Screenshots` ar nosaukumu, piemēram, `screenshot-2026-08-13_14-22-05-firefox.png`. Iestatiet `OMASNAP_SCREENSHOT_DIR`, lai izmantotu citu direktoriju — skatiet [BUJ](46-faq.md), kur likt sesijas vides mainīgos. Omasnap izveido direktoriju, kad tas saglabā pirmo uzņēmumu. Iestatiet `[output] autosave = false` failā `~/.config/omasnap/omasnap.conf`, lai atspējotu automātisko saglabāšanu.

No termināļa `omarchy screenshot` atver to pašu pārklājumu, un varat izvēlēties tā sākuma režīmu: `omarchy capture screenshot region`, `windows`, `fullscreen` vai `scroll`. Otrais arguments `copy` vai `save` izlaiž priekšskatījumu un nosūta uzņēmumu tieši uz attiecīgo galamērķi. Lai pirms izvades rediģētu, izmantojiet `omarchy screenshot --editor=overlay` pilnekrāna redaktoram vai `omarchy screenshot --editor=window` atsevišķam logam.

### Atlases vadīšana ar tastatūru

Kamēr atlase ir atvērta, pele jums nemaz nav vajadzīga:

| Taustiņš | Funkcija |
| --- | -------- |
| `S` | Pārslēgt ritināma reģiona režīmu |
| `Super + Arrow keys` | Pārvietoties starp logiem logu režīmā |
| `Return` | Tvert izcelto logu |
| `Ctrl + A` | Tvert visu fokusēto monitoru |
| `R` | Atjaunot pēdējo šajā sesijā uzzīmēto reģionu |
| `Esc` | Aizvērt Omasnap |

Šīs piesaistes pastāv tikai tad, kamēr Omasnap ir atvērts, tāpēc tās nevar konfliktēt ne ar ko jūsu pašu konfigurācijā.

## Ekrāna ierakstīšana

`Alt + Print Screen` atver _Trigger > Capture > Screenrecord_, kas jautā, ko vēlaties skaņu celiņā: bez audio, darbvirsmas audio, darbvirsma plus mikrofons vai darbvirsma plus mikrofons plus tīmekļa kamera. Pēdējā opcija parādās tikai tad, ja jums tiešām ir pievienota kamera. Izvēlieties vienu, un Omarchy ieraksta atlasītājs ļauj jums vilkt reģionu vai noklikšķināt uz loga vai monitora.

Ierakstīšana darbojas ar gpu-screen-recorder, kas kodē ar GPU pie 60fps un, ja nepieciešams, pāriet uz CPU. Rezultāts ir MP4 failā `~/Videos` ar nosaukumu `screenrecording-2026-08-13_14-22-05.mp4`. Iestatiet `OMARCHY_SCREENRECORD_DIR`, lai to mainītu — bet ņemiet vērā, ka atšķirībā no ekrānuzņēmumu direktorija šim jau ir jāpastāv, citādi ierakstīšana atsakās sākties.

Kamēr ierakstāt, joslā parādās neliels indikators. Noklikšķiniet uz tā, lai apturētu. Varat apturēt arī vēlreiz ar `Alt + Print Screen` vai ar _Stop Screenrecording_ ierakstu sadaļā _Trigger > Capture > Screenrecord_, kas parādās tikai tad, kamēr kaut kas tiešām tiek ierakstīts.

Apturēšana pirms faila nodošanas jums veic nelielu sakārtošanu: pirmais kadrs tiek apgriezts, un, ja ir audio, tas tiek normalizēts līdz -14 LUFS, apklusinot PipeWire tveršanas klikšķi pašā sākumā. Pēc tam parādās paziņojums ar ieraksta sīktēlu. Noklikšķiniet uz tā, lai atskaņotu failu mpv.

### Tīmekļa kameras pārklājums

Kad ierakstāt ar tīmekļa kameru, kamera parādās kā piesprausts, apgriezts portreta logs tā apakšējā labajā stūrī, ko ierakstāt. Ja tā atrodas virs kaut kā jums vajadzīga, mainiet tās izmēru lidojumā:

| Taustiņu kombinācija | Funkcija |
| ------ | -------- |
| `Super + Alt + [` | Padarīt tīmekļa kameras pārklājumu mazāku |
| `Super + Alt + ]` | Padarīt tīmekļa kameras pārklājumu lielāku |

Ir trīs izmēri — mazs, vidējs un liels —, un karstie taustiņi pārslēdzas starp tiem. Vidējais ir noklusējums. Tie ir proporcionāli ierakstam, tāpēc kamera aizņem to pašu kadra daļu neatkarīgi no tā, vai ierakstāt 1080p monitoru vai 6K monitoru. Un, ja ierakstījāt reģionu, nevis visu displeju, pārklājums noenkurojas pie attiecīgā reģiona stūra, nevis monitora stūra, tāpēc tas paliek uzņēmuma iekšpusē.

Varat to izsaukt arī tieši ar `omarchy-capture-webcam-resize small` vai `reset`, lai atgrieztos pie vidējā.

## Teksts, QR kodi un krāsas

`Super + Ctrl + Print Screen` atlasa reģionu un veic tā OCR starpliktuvē. Tas ir kārtīgi aprakstīts sadaļā [Teksta izvilkšana un diktēšana](11-text-extraction-dictation.md).

_Trigger > Capture > QR Code_ dara to pašu triku ar QR kodiem. Atlasiet reģionu ar kodu, un atšifrētā vērtība nonāk starpliktuvē. Tas meklē tikai QR kodus — blīvs ekrāna saturs citādi mēdz kļūdaini tikt uztverts kā svītrkods. Vērts zināt: atšifrētā vērtība nonāk starpliktuvē un nekur citur. Tā netiek drukāta, tās nav paziņojumā, un tā ir atzīmēta kā sensitīva, tāpēc tā nepaliek [starpliktuves vēsturē](08-unified-clipboard-history.md). QR kodi regulāri nes noslēpumus — piemēram, `otpauth://` URI aiz 2FA iestatīšanas koda —, un jūs to nevēlaties žurnālā. Ielīmēšana joprojām darbojas labi.

`Super + Print Screen` (vai _Trigger > Capture > Color_) pārvērš kursoru par pipeti. Noklikšķiniet uz jebkā uz ekrāna, un krāsa nonāk starpliktuvē. Nospiediet karsto taustiņu vēlreiz, lai izietu, neko nepaņemot.

## Pārkodēšana pirms kopīgošanas

4K ekrāna ieraksts vai neapstrādāts HEIC no tālruņa bieži ir pārāk liels, lai to vienkārši nosūtītu. `Super + Ctrl + .` (vai _Trigger > Transcode_) to izlabo. Tas piedāvā failu atlasītāju ar izplūdušo meklēšanu pāri `~/Pictures` un `~/Videos`, pēc tam jautā formātu un izmēru.

Attēli tiek pārveidoti par jpg vai png augstā, vidējā vai zemā līmenī, kas ierobežo platumu līdz 3160, 2160 un 1080 pikseļiem. Videoklipi tiek pārveidoti par mp4 vai animētu gif ar 4k, 1080p vai 720p. Konvertētais fails tiek ierakstīts blakus oriģinālam ar izšķirtspēju nosaukumā — `demo-1080p.mp4` —, un ceļš tiek kopēts starpliktuvē kā faila URI, tāpēc varat to ielīmēt tieši lietotnē, kas pieņem failu nomešanu.

Tas darbojas arī no termināļa, ja jau zināt, ko vēlaties: `omarchy transcode ~/Videos/demo.mov mp4 1080p`. Ir arī `omarchy transcode ascii`, kas pārvērš attēlu ASCII mākslā — tas galvenokārt ir paredzēts [zīmolvedībai](41-branding.md).

## Nosūtīšana uz citu vietu

Kad fails ir iegūts, `Super + Ctrl + S` atver Share izvēlni un nosūta to uz citu ierīci jūsu tīklā, izmantojot LocalSend. Par to skatiet [GUI](22-guis.md).
