# Snimke zaslona i snimanje

Sve što možete zgrabiti sa zaslona visi o tipki Print Screen. Sama tipka snima sliku, a modifikatori snimaju video, boju ili tekst unutar regije. Ako vaša tipkovnica uopće nema tipku Print Screen, `Super + Ctrl + Alt + C` snima istu snimku zaslona, a `Super + Ctrl + C` otvara cijeli skup kao izbornik.

| Prečac | Funkcija |
| ------ | -------- |
| `Print Screen` | Snimka zaslona |
| `Super + Ctrl + Alt + C` | Snimka zaslona |
| `Alt + Print Screen` | Snimanje zaslona (ili zaustavi ono koje već radi) |
| `Super + Print Screen` | Odabir boje |
| `Super + Ctrl + Print Screen` | Izvuci tekst iz regije |
| `Super + Ctrl + C` | Izbornik za hvatanje |
| `Super + Ctrl + .` | Transkodiraj sliku ili video |

## Snimke zaslona

Pritisnite `Print Screen` (ili `Super + Ctrl + Alt + C`) i Omasnap će uhvatiti fokusirani monitor prije nego što se pojavi njegov sloj, pa vam se ništa neće pomaknuti dok ciljate. Povucite slobodnu regiju, kliknite prozor da biste ga uhvatili ili kliknite prazan prostor da biste uhvatili cijeli monitor. Pritisnite `S` prije crtanja da biste uhvatili regiju za pomicanje. Predomislili ste se? Ponovno pritisnite istu tipku da biste zatvorili Omasnap.

Nakon što odaberete područje, Omasnap sprema snimku, kopira je u međuspremnik i prikazuje obavijest s njezinom sličicom, kao što to radi spremljena snimka zaslona. Odaberite Open da biste spremljenu snimku pogledali u pregledniku slika ili Edit da biste je označili.

Uređivač za označavanje može crtati strelice, crte, oblike, isticanja, numerirane oznake, tekst i sigurne redakcije; obrezati ili izrezati dio slike; OCR-om izvući njezin tekst; i dodati pozadinu. U uređivaču pritisnite `Enter` da biste kopirali i spremili gotovi PNG, `Ctrl + C` da biste ga kopirali bez spremanja ili `Ctrl + S` da biste ga spremili bez kopiranja.

Spremljene snimke zaslona prema zadanim postavkama završavaju u `~/Pictures/Screenshots`, s imenom poput `screenshot-2026-08-13_14-22-05-firefox.png`. Postavite `OMASNAP_SCREENSHOT_DIR` da biste koristili drugi direktorij — pogledajte [često postavljana pitanja](46-faq.md) za to gdje staviti varijable okruženja sesije. Omasnap stvara direktorij kad sprema prvu snimku. Postavite `[output] autosave = false` u `~/.config/omasnap/omasnap.conf` da biste onemogućili automatsko spremanje; snimke se tada samo kopiraju i prikazuju u pregledu na 10 sekundi, koji možete zadržati na zaslonu njegovim gumbom za prikvačivanje ili s `Ctrl + P`.

Iz terminala, `omarchy screenshot` otvara isti sloj, a možete odabrati i njegov početni način: `omarchy capture screenshot region`, `windows`, `fullscreen` ili `scroll`. Drugi argument `copy` ili `save` šalje snimku izravno na to odredište. Da biste uredili prije izlaza, upotrijebite `omarchy screenshot --editor=overlay` za uređivač preko cijelog zaslona ili `omarchy screenshot --editor=window` za zaseban prozor.

### Upravljanje odabirom s tipkovnice

Dok je odabir otvoren, uopće ne morate koristiti miš:

| Tipka | Funkcija |
| --- | -------- |
| `S` | Uključi/isključi način regije za pomicanje |
| `Super + Arrow keys` | Kretanje među prozorima u načinu Window |
| `Return` | Uhvati istaknuti prozor |
| `Ctrl + A` | Uhvati cijeli fokusirani monitor |
| `R` | Vrati posljednju regiju nacrtanu u ovoj sesiji |
| `Esc` | Zatvori Omasnap |

Ove veze postoje samo dok je Omasnap otvoren, pa se ne mogu sudariti ni s čim u vašoj vlastitoj konfiguraciji.

## Snimanje zaslona

`Alt + Print Screen` otvara _Trigger > Capture > Screenrecord_, koji vas pita što želite na zvučnoj podlozi: bez zvuka, zvuk radne površine, zvuk radne površine plus mikrofon ili zvuk radne površine plus mikrofon plus web-kameru. Ta posljednja opcija pojavljuje se samo ako vam je kamera stvarno priključena. Odaberite jednu i Omarchyjev odabir za snimanje omogućuje vam da povučete regiju ili kliknete prozor ili monitor.

Snimanje radi na gpu-screen-recorder, koji kodira na GPU-u pri 60fps i vraća se na CPU ako mora. Rezultat je MP4 u `~/Videos`, nazvan `screenrecording-2026-08-13_14-22-05.mp4`. Postavite `OMARCHY_SCREENRECORD_DIR` da biste to promijenili — ali imajte na umu da, za razliku od direktorija za snimke zaslona, ovaj već mora postojati, inače snimanje odbija započeti.

Dok snimate, u traci se pojavljuje mali indikator. Kliknite ga da biste zaustavili. Možete zaustaviti i ponovnim pritiskom na `Alt + Print Screen` ili unosom _Stop Screenrecording_ pod _Trigger > Capture > Screenrecord_, koji se pojavljuje samo dok se nešto stvarno snima.

Zaustavljanje malo pospremi prije nego što vam preda datoteku: prvi kadar se odreže, a ako ima zvuka, normalizira se na -14 LUFS, pri čemu se puknuće PipeWire hvatanja na samom početku utiša. Zatim se pojavljuje obavijest sa sličicom iz snimke. Kliknite je da biste datoteku reproducirali u mpv.

### Preklapanje web-kamere

Kad snimate s web-kamerom, kamera se pojavljuje kao prikvačen, obrezan portretni prozor u donjem desnom kutu onoga što snimate. Ako vam stoji na nečemu što vam treba, promijenite joj veličinu u letu:

| Prečac | Funkcija |
| ------ | -------- |
| `Super + Alt + [` | Smanji preklapanje web-kamere |
| `Super + Alt + ]` | Povećaj preklapanje web-kamere |

Postoje tri veličine — mala, srednja i velika — a prečaci se kreću između njih. Srednja je zadana. Proporcionalne su snimci, pa kamera zauzima isti udio kadra bez obzira snimate li 1080p monitor ili 6K monitor. A ako ste snimili regiju, a ne cijeli zaslon, preklapanje se sidri za kut te regije, a ne monitora, pa ostaje unutar snimke.

Možete ga pozvati i izravno s `omarchy-capture-webcam-resize small` ili `reset` da biste se vratili na srednju veličinu.

## Tekst, QR kodovi i boje

`Super + Ctrl + Print Screen` odabire regiju i OCR-om je šalje u međuspremnik. To je kako treba obrađeno u [Izdvajanje teksta i diktiranje](11-text-extraction-dictation.md).

_Trigger > Capture > QR Code_ radi isti trik za QR kodove. Odaberite regiju s kodom u njoj i dekodirana vrijednost ide u međuspremnik. Traži samo QR kodove — gust sadržaj zaslona inače ima naviku lažno se prikazivati kao crtični kod. Vrijedi znati: dekodirana vrijednost ide u međuspremnik i nigdje drugdje. Ne ispisuje se, nije u obavijesti i označena je kao osjetljiva, pa ne ostaje u [povijesti međuspremnika](08-unified-clipboard-history.md). QR kodovi rutinski nose tajne — `otpauth://` URI iza koda za postavljanje 2FA, na primjer — a to ne želite u zapisniku. Lijepljenje i dalje radi bez problema.

`Super + Print Screen` (ili _Trigger > Capture > Color_) pretvara pokazivač u kapaljku. Kliknite bilo što na zaslonu i boja završava u međuspremniku. Ponovno pritisnite prečac da biste odustali bez odabira.

## Transkodiranje prije dijeljenja

4K snimka zaslona ili sirovi HEIC s telefona često su preveliki da biste ih samo poslali. `Super + Ctrl + .` (ili _Trigger > Transcode_) to rješava. Nudi vam neizraziti odabir datoteka nad `~/Pictures` i `~/Videos`, a zatim pita za format i veličinu.

Slike idu u jpg ili png pri visokoj, srednjoj ili niskoj kvaliteti, što ograničava širinu na 3160, 2160 i 1080 piksela. Videozapisi idu u mp4 ili animirani gif pri 4k, 1080p ili 720p. Pretvorena datoteka zapisuje se pokraj izvornika, s razlučivošću u imenu — `demo-1080p.mp4` — a putanja se kopira u međuspremnik kao URI datoteke, pa je možete zalijepiti izravno u aplikaciju koja prima ispuštanje datoteka.

Radi i iz terminala, ako već znate što želite: `omarchy transcode ~/Videos/demo.mov mp4 1080p`. Postoji i `omarchy transcode ascii`, koji sliku pretvara u ASCII umjetnost — taj je uglavnom za [brendiranje](41-branding.md).

## Slanje nekamo

Kad imate datoteku, `Super + Ctrl + S` otvara izbornik Share i šalje je na drugi uređaj na vašoj mreži putem LocalSend. Za to pogledajte [GUI-je](22-guis.md).
