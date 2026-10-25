# Snimke zaslona i snimanje

Sve što možete zgrabiti sa zaslona visi o tipki Print Screen. Sama tipka snima sliku, a modifikatori snimaju video, boju ili tekst unutar područja. Ako vaša tipkovnica uopće nema tipku Print Screen, `Super + Ctrl + Alt + C` snima istu snimku zaslona, a `Super + Ctrl + C` otvara cijeli skup kao izbornik.

| Tipkovnički prečac | Funkcija |
| ------ | -------- |
| `Print Screen` | Snimka zaslona |
| `Super + Ctrl + Alt + C` | Snimka zaslona |
| `Alt + Print Screen` | Snimanje zaslona (ili zaustavljanje onog koje je u tijeku) |
| `Super + Print Screen` | Birač boja |
| `Super + Ctrl + Print Screen` | Izdvajanje teksta iz područja |
| `Super + Ctrl + C` | Izbornik snimanja |
| `Super + Ctrl + .` | Transkodiranje slike ili videa |

## Snimke zaslona

Pritisnite `Print Screen` (ili `Super + Ctrl + Alt + C`) i Omasnap snima fokusirani monitor prije nego što se pojavi njegov sloj, pa se ništa ne pomiče pod vama dok ciljate. Povucite slobodno područje, kliknite prozor da biste ga snimili ili kliknite prazan prostor da biste snimili cijeli monitor. Pritisnite `S` prije crtanja da biste snimili područje koje se pomiče. Predomislili ste se? Ponovno pritisnite istu tipku da biste zatvorili Omasnap.

Nakon što odaberete područje, Omasnap sprema snimku, kopira je u međuspremnik i prikazuje pretpregled na 10 sekundi. Upotrijebite gumb za prikvačivanje u pretpregledu ili `Ctrl + P` da bi ostao na zaslonu ili odaberite Edit da biste mu dodali bilješke.

Uređivač bilješki može crtati strelice, crte, oblike, isticanja, numerirane oznake, tekst i sigurne redakcije; obrezati ili izrezati dio slike; OCR-om izdvojiti njezin tekst; i dodati pozadinu. U uređivaču pritisnite `Enter` da biste kopirali i spremili dovršeni PNG, `Ctrl + C` da biste ga kopirali bez spremanja ili `Ctrl + S` da biste ga spremili bez kopiranja.

Spremljene snimke zaslona prema zadanim postavkama završavaju u `~/Pictures/Screenshots`, s nazivom kao što je `screenshot-2026-08-13_14-22-05-firefox.png`. Postavite `OMASNAP_SCREENSHOT_DIR` da biste upotrijebili drugi direktorij — pogledajte [Česta pitanja](46-faq.md) za to gdje staviti varijable okruženja sesije. Omasnap stvara direktorij kada sprema prvu snimku. Postavite `[output] autosave = false` u `~/.config/omasnap/omasnap.conf` da biste onemogućili automatsko spremanje.

Iz terminala `omarchy screenshot` otvara isti sloj, a možete odabrati i njegov početni način rada: `omarchy capture screenshot region`, `windows`, `fullscreen` ili `scroll`. Drugi argument `copy` ili `save` preskače pretpregled i šalje snimku izravno na to odredište. Za uređivanje prije izlaza upotrijebite `omarchy screenshot --editor=overlay` za uređivač preko cijelog zaslona ili `omarchy screenshot --editor=window` za zaseban prozor.

### Upravljanje biračem s tipkovnice

Dok je odabir otvoren, uopće ne morate upotrebljavati miš:

| Tipka | Funkcija |
| --- | -------- |
| `S` | Uključivanje/isključivanje načina područja koje se pomiče |
| `Super + Arrow keys` | Kretanje među prozorima u načinu Window |
| `Return` | Snimanje istaknutog prozora |
| `Ctrl + A` | Snimanje cijelog fokusiranog monitora |
| `R` | Vraćanje posljednjeg područja nacrtanog u ovoj sesiji |
| `Esc` | Zatvaranje Omasnapa |

Ove tipkovničke veze postoje samo dok je Omasnap otvoren, pa se ne mogu sudariti ni s čim u vašoj vlastitoj konfiguraciji.

## Snimanje zaslona

`Alt + Print Screen` otvara _Trigger > Capture > Screenrecord_, koji pita što želite na zvučnom zapisu: bez zvuka, zvuk radne površine, radnu površinu plus mikrofon ili radnu površinu plus mikrofon plus web-kameru. To posljednje pojavljuje se samo ako vam je kamera doista priključena. Odaberite jedno i Omarchyjev birač snimanja omogućit će vam da povučete područje ili kliknete prozor ili monitor.

Snimanje radi na gpu-screen-recorder, koji kodira na GPU-u pri 60fps i po potrebi se vraća na CPU. Rezultat je MP4 u `~/Videos`, nazvan `screenrecording-2026-08-13_14-22-05.mp4`. Postavite `OMARCHY_SCREENRECORD_DIR` da biste to promijenili — ali imajte na umu da, za razliku od direktorija za snimke zaslona, ovaj već mora postojati, inače snimanje odbija započeti.

Dok snimate, u traci se pojavljuje mali pokazatelj. Kliknite ga da biste zaustavili snimanje. Možete ga zaustaviti i ponovnim pritiskom na `Alt + Print Screen` ili unosom _Stop Screenrecording_ pod _Trigger > Capture > Screenrecord_, koji se pojavljuje samo dok se nešto doista snima.

Zaustavljanje malo pospremi prije nego što vam preda datoteku: prvi kadar se odreže, a ako ima zvuka, normalizira se na -14 LUFS, pri čemu se pucketanje PipeWire snimanja na samom početku utiša. Zatim se pojavljuje obavijest sa sličicom iz snimke. Kliknite je da biste datoteku reproducirali u mpv.

### Sloj web-kamere

Kada snimate s web-kamerom, kamera se pojavljuje kao prikvačen, obrezan portretni prozor u donjem desnom kutu onoga što snimate. Ako stoji na nečemu što vam treba, promijenite joj veličinu u letu:

| Tipkovnički prečac | Funkcija |
| ------ | -------- |
| `Super + Alt + [` | Smanjivanje sloja web-kamere |
| `Super + Alt + ]` | Povećavanje sloja web-kamere |

Postoje tri veličine — mala, srednja i velika — a tipkovnički prečaci korakuju između njih. Srednja je zadana. Proporcionalne su snimci, pa kamera zauzima isti udio kadra bez obzira snimate li 1080p monitor ili 6K monitor. A ako ste snimili područje, a ne cijeli zaslon, sloj se sidri u kut tog područja, a ne monitora, pa ostaje unutar snimke.

Možete ga pozvati i izravno s `omarchy-capture-webcam-resize small` ili s `reset` da biste se vratili na srednju veličinu.

## Tekst, QR kodovi i boje

`Super + Ctrl + Print Screen` odabire područje i OCR-om ga prenosi u međuspremnik. To je kako treba obrađeno u [Izdvajanje teksta i diktiranje](11-text-extraction-dictation.md).

_Trigger > Capture > QR Code_ radi isti trik za QR kodove. Odaberite područje u kojem je kod i dekodirana vrijednost odlazi u međuspremnik. Traži samo QR kodove — gust sadržaj zaslona inače ima naviku lažno se pokazati kao crtični kod. Vrijedi znati: dekodirana vrijednost odlazi u međuspremnik i nigdje drugdje. Ne ispisuje se, nije u obavijesti i označena je kao osjetljiva, pa ne ostaje u [povijesti međuspremnika](08-unified-clipboard-history.md). QR kodovi redovito nose tajne — `otpauth://` URI iza koda za postavljanje 2FA, na primjer — a to ne želite u zapisniku. Lijepljenje i dalje radi bez problema.

`Super + Print Screen` (ili _Trigger > Capture > Color_) pretvara pokazivač u kapaljku. Kliknite bilo što na zaslonu i boja završava u međuspremniku. Ponovno pritisnite tipkovnički prečac da biste odustali bez odabira.

## Transkodiranje prije dijeljenja

Snimka zaslona u 4K ili sirovi HEIC s telefona često su preveliki da biste ih samo poslali. `Super + Ctrl + .` (ili _Trigger > Transcode_) to rješava. Nudi vam neizraziti birač datoteka nad `~/Pictures` i `~/Videos`, a zatim pita za format i veličinu.

Slike idu u jpg ili png na visokoj, srednjoj ili niskoj razini, koje ograničavaju širinu na 3160, 2160 i 1080 piksela. Videozapisi idu u mp4 ili animirani gif na 4k, 1080p ili 720p. Pretvorena datoteka zapisuje se pokraj izvornika, s razlučivošću u nazivu — `demo-1080p.mp4` — a putanja se kopira u međuspremnik kao URI datoteke, pa je možete zalijepiti izravno u aplikaciju koja prima ispuštanje datoteka.

Radi i iz terminala, ako već znate što želite: `omarchy transcode ~/Videos/demo.mov mp4 1080p`. Postoji i `omarchy transcode ascii`, koji sliku pretvara u ASCII umjetnost — taj je uglavnom za [brendiranje](41-branding.md).

## Slanje nekamo

Kada imate datoteku, `Super + Ctrl + S` otvara izbornik Share i šalje je na drugi uređaj na vašoj mreži putem LocalSend. Za to pogledajte [GUI-ji](22-guis.md).
