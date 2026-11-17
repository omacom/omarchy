# Snimke zaslona i snimanje

Sve što možete zgrabiti sa zaslona visi o tipki Print Screen. Sama tipka snima sliku, a modifikatori snimaju video, boju ili tekst unutar područja. Ako vaša tipkovnica uopće nema tipku Print Screen, `Super + Ctrl + Alt + C` snima istu snimku zaslona, a `Super + Ctrl + C` otvara cijeli skup kao izbornik.

| Prečac | Funkcija |
| ------ | -------- |
| `Print Screen` | Snimka zaslona |
| `Super + Ctrl + Alt + C` | Snimka zaslona |
| `Alt + Print Screen` | Snimanje zaslona (ili zaustavljanje onoga koje je u tijeku) |
| `Super + Print Screen` | Odabir boje |
| `Super + Ctrl + Print Screen` | Izdvoji tekst iz područja |
| `Super + Ctrl + C` | Izbornik snimanja |
| `Super + Ctrl + .` | Transkodiraj sliku ili video |

## Snimke zaslona

Pritisnite `Print Screen` (ili `Super + Ctrl + Alt + C`) i Omasnap snima fokusirani monitor prije nego što se pojavi njegov sloj, pa se ništa ne pomiče pod vama dok ciljate. Povucite slobodno područje, kliknite prozor da ga snimite ili kliknite prazan prostor da snimite cijeli monitor. Pritisnite `S` prije crtanja da snimite područje s pomicanjem. Predomislili ste se? Ponovno pritisnite istu tipku da zatvorite Omasnap.

Nakon što odaberete područje, Omasnap sprema snimku, kopira je u međuspremnik i prikazuje obavijest s njezinom sličicom, kao što to čini spremljeno snimanje zaslona. Odaberite Open da pogledate spremljenu snimku u svom pregledniku slika ili Edit da je označite.

Uređivač za označavanje može crtati strelice, crte, oblike, isticanja, numerirane oznake, tekst i sigurne redakcije; obrezati ili izrezati dio slike; OCR-om izdvojiti njezin tekst; i dodati pozadinu. U uređivaču pritisnite `Enter` da kopirate i spremite gotovi PNG, `Ctrl + C` da ga kopirate bez spremanja ili `Ctrl + S` da ga spremite bez kopiranja.

Spremljene snimke zaslona prema zadanim postavkama završavaju u `~/Pictures/Screenshots`, s nazivom poput `screenshot-2026-08-13_14-22-05-firefox.png`. Postavite `OMASNAP_SCREENSHOT_DIR` da koristite drugi direktorij — pogledajte [Česta pitanja](46-faq.md) za to gdje staviti varijable okruženja sesije. Omasnap stvara direktorij kada sprema prvu snimku. Postavite `[output] autosave = false` u `~/.config/omasnap/omasnap.conf` da onemogućite automatsko spremanje; snimke se tada samo kopiraju i prikazuju u pregledu na 10 sekundi koji možete zadržati na zaslonu njegovim gumbom za prikvačivanje ili s `Ctrl + P`.

Iz terminala, `omarchy screenshot` otvara isti sloj, a možete odabrati i njegov početni način: `omarchy capture screenshot region`, `windows`, `fullscreen` ili `scroll`. Drugi argument `copy` ili `save` šalje snimku izravno na to odredište. Da uredite prije ispisa, upotrijebite `omarchy screenshot --editor=overlay` za uređivač preko cijelog zaslona ili `omarchy screenshot --editor=window` za zaseban prozor.

### Upravljanje odabirom s tipkovnice

Dok je odabir otvoren, uopće ne morate koristiti miš:

| Tipka | Funkcija |
| --- | -------- |
| `S` | Prebaci način područja s pomicanjem |
| `Super + Arrow keys` | Kreći se među prozorima u načinu Window |
| `Return` | Snimi istaknuti prozor |
| `Ctrl + A` | Snimi cijeli fokusirani monitor |
| `R` | Vrati posljednje područje nacrtano u ovoj sesiji |
| `Esc` | Zatvori Omasnap |

Te veze postoje samo dok je Omasnap otvoren, pa se ne mogu sudariti s bilo čime u vašoj vlastitoj konfiguraciji.

## Snimanje zaslona

`Alt + Print Screen` otvara _Trigger > Capture > Screenrecord_, koji pita što želite na zvučnoj podlozi: bez zvuka, zvuk radne površine, radnu površinu plus mikrofon ili radnu površinu plus mikrofon plus web-kameru. Ta posljednja opcija pojavljuje se samo ako vam je kamera stvarno priključena. Odaberite jednu i Omarchyjev odabir za snimanje omogućuje vam da povučete područje ili kliknete prozor ili monitor.

Snimanje radi na gpu-screen-recorderu, koji kodira na GPU-u pri 60fps i vraća se na CPU ako mora. Rezultat je MP4 u `~/Videos`, nazvan `screenrecording-2026-08-13_14-22-05.mp4`. Postavite `OMARCHY_SCREENRECORD_DIR` da to promijenite — ali imajte na umu da, za razliku od direktorija za snimke zaslona, ovaj već mora postojati, inače snimanje odbija započeti.

Dok snimate, u traci se pojavljuje mali pokazatelj. Kliknite ga da zaustavite snimanje. Možete zaustaviti i ponovnim pritiskom na `Alt + Print Screen` ili unosom _Stop Screenrecording_ pod _Trigger > Capture > Screenrecord_, koji se pojavljuje samo dok se nešto stvarno snima.

Zaustavljanje malo pospremi prije nego što vam preda datoteku: prvi kadar se odreže, a ako ima zvuka, normalizira se na -14 LUFS, uz utišan zvuk pucanja PipeWire snimanja na samom početku. Zatim se pojavljuje obavijest sa sličicom iz snimke. Kliknite je da reproducirate datoteku u Omaviewu.

### Sloj web-kamere

Kada snimate s web-kamerom, kamera se pojavljuje kao prikvačen, obrezan portretni prozor u donjem desnom kutu onoga što snimate. Ako vam stoji na nečemu što vam treba, promijenite joj veličinu u letu:

| Prečac | Funkcija |
| ------ | -------- |
| `Super + Alt + [` | Smanji sloj web-kamere |
| `Super + Alt + ]` | Povećaj sloj web-kamere |

Postoje tri veličine — mala, srednja i velika — a prečaci se kreću među njima. Srednja je zadana. Proporcionalne su snimci, pa kamera zauzima isti udio kadra bez obzira snimate li monitor od 1080p ili 6K. A ako ste snimili područje, a ne cijeli zaslon, sloj se sidri u kut tog područja, a ne monitora, pa ostaje unutar snimke.

Možete ga pozvati i izravno s `omarchy-capture-webcam-resize small` ili `reset` da se vratite na srednju veličinu.

## Tekst, QR kodovi i boje

`Super + Ctrl + Print Screen` odabire područje i OCR-om ga prenosi u međuspremnik. To je kako treba opisano u [Izdvajanje teksta i diktiranje](11-text-extraction-dictation.md).

_Trigger > Capture > QR Code_ radi isti trik za QR kodove. Odaberite područje s kodom u njemu i dekodirana vrijednost odlazi u međuspremnik. Traži samo QR kodove — gust sadržaj zaslona inače ima naviku lažno se prikazivati kao crtični kod. Vrijedi znati: dekodirana vrijednost odlazi u međuspremnik i nigdje drugdje. Ne ispisuje se, nije u obavijesti i označena je kao osjetljiva pa ne ostaje u [povijesti međuspremnika](08-unified-clipboard-history.md). QR kodovi rutinski nose tajne — `otpauth://` URI iza koda za postavljanje 2FA, na primjer — i ne želite to u zapisniku. Lijepljenje i dalje radi sasvim dobro.

`Super + Print Screen` (ili _Trigger > Capture > Color_) pretvara pokazivač u kapaljku. Kliknite bilo što na zaslonu i boja završava u međuspremniku. Ponovno pritisnite prečac da odustanete bez odabira.

## Transkodiranje prije dijeljenja

Snimka zaslona u 4K ili sirovi HEIC s telefona često je prevelika da je samo tako pošaljete. `Super + Ctrl + .` (ili _Trigger > Transcode_) to rješava. Nudi vam neprecizan odabir datoteka preko `~/Pictures` i `~/Videos`, a zatim pita za format i veličinu.

Slike idu u jpg ili png pri visokoj, srednjoj ili niskoj kvaliteti, što ograničava širinu na 3160, 2160 i 1080 piksela. Videozapisi idu u mp4 ili animirani gif pri 4k, 1080p ili 720p. Pretvorena datoteka zapisuje se pokraj izvornika s razlučivošću u nazivu — `demo-1080p.mp4` — a putanja se kopira u međuspremnik kao URI datoteke, pa je možete zalijepiti izravno u aplikaciju koja prima ispuštanje datoteka.

Radi i iz terminala, ako već znate što želite: `omarchy transcode ~/Videos/demo.mov mp4 1080p`. Postoji i `omarchy transcode ascii`, koji sliku pretvara u ASCII umjetnost — taj je uglavnom za [brendiranje](41-branding.md).

## Slanje nekamo

Kad imate datoteku, `Super + Ctrl + S` otvara izbornik Share i šalje je na drugi uređaj na vašoj mreži putem LocalSenda. Za to pogledajte [GUIs](22-guis.md).
