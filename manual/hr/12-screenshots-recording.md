# Snimke zaslona i snimanje

Sve što možete zgrabiti sa zaslona visi o tipki Print Screen. Jedna tipka sama po sebi snima sliku, a modifikatori snimaju video, boju ili tekst unutar područja. Ako vaša tipkovnica uopće nema tipku Print Screen, `Super + Ctrl + C` otvara isti skup kao izbornik.

| Prečac | Funkcija |
| ------ | -------- |
| `Print Screen` | Snimka zaslona |
| `Alt + Print Screen` | Snimanje zaslona (ili zaustavi ono koje se izvodi) |
| `Super + Print Screen` | Birač boja |
| `Super + Ctrl + Print Screen` | Izdvoji tekst iz područja |
| `Super + Ctrl + C` | Izbornik snimanja |
| `Super + Ctrl + .` | Transkodiraj sliku ili video |

## Snimke zaslona

Pritisnite `Print Screen` i Omasnap snima fokusirani monitor prije nego što se pojavi njegov sloj, pa se ništa ne pomiče ispod vas dok ciljate. Povucite slobodno područje, kliknite prozor da ga snimite ili kliknite prazan prostor da snimite cijeli monitor. Pritisnite `S` prije crtanja da snimite pomično područje. Predomislili ste se? Ponovno pritisnite `Print Screen` da odbacite Omasnap.

Nakon što odaberete područje, Omasnap sprema snimku, kopira je u međuspremnik i prikazuje pregled 10 sekundi. Upotrijebite tipku za prikvačivanje pregleda ili `Ctrl + P` da ga zadržite na zaslonu ili odaberite Uredi da ga označite.

Uređivač za označavanje može crtati strelice, crte, oblike, isticanja, numerirane oznake, tekst i sigurne redakcije; obrezati ili izrezati dio slike; OCR-om izvući njezin tekst; i dodati pozadinu. U uređivaču pritisnite `Enter` za kopiranje i spremanje dovršenoga PNG-a, `Ctrl + C` za kopiranje bez spremanja ili `Ctrl + S` za spremanje bez kopiranja.

Spremljene snimke zaslona prema zadanim postavkama završavaju u `~/Pictures/Screenshots`, s nazivom poput `screenshot-2026-08-13_14-22-05-firefox.png`. Postavite `OMASNAP_SCREENSHOT_DIR` da koristite drugi direktorij — pogledajte [FAQ](46-faq.md) za to gdje staviti varijable okruženja sesije. Omasnap stvara direktorij kada sprema prvu snimku. Postavite `[output] autosave = false` u `~/.config/omasnap/omasnap.conf` da onemogućite automatsko spremanje.

Iz terminala `omarchy screenshot` otvara isti sloj, a možete odabrati njegov početni način: `omarchy capture screenshot region`, `windows`, `fullscreen` ili `scroll`. Drugi argument `copy` ili `save` preskače pregled i šalje snimku ravno na to odredište. Za uređivanje prije izlaza koristite `omarchy screenshot --editor=overlay` za uređivač na cijelom zaslonu ili `omarchy screenshot --editor=window` za zasebni prozor.

### Upravljanje biračem tipkovnicom

Dok je odabir aktivan, uopće ne morate koristiti miš:

| Tipka | Funkcija |
| --- | -------- |
| `S` | Prebaci način pomičnoga područja |
| `Super + Arrow keys` | Kreći se među prozorima u načinu Prozor |
| `Return` | Snimi istaknuti prozor |
| `Ctrl + A` | Snimi cijeli fokusirani monitor |
| `R` | Vrati posljednje nacrtano područje u ovoj sesiji |
| `Esc` | Odbaci Omasnap |

Te poveznice postoje samo dok je Omasnap otvoren, pa se ne mogu sukobiti s bilo čime u vašoj vlastitoj konfiguraciji.

## Snimanje zaslona

`Alt + Print Screen` otvara _Pokreni > Snimaj > Snimanje zaslona_, što vas pita što želite na zvučnome zapisu: bez zvuka, zvuk radne površine, radna površina plus mikrofon ili radna površina plus mikrofon plus web-kamera. To posljednje pojavljuje se samo ako doista imate uključenu kameru. Odaberite jedno i Omarchyjev birač snimanja omogućuje vam da povučete područje ili kliknete prozor ili monitor.

Snimanje se izvodi na gpu-screen-recorderu, koji kodira na GPU-u pri 60 fps i vraća se na CPU ako mora. Rezultat je MP4 u `~/Videos`, nazvan `screenrecording-2026-08-13_14-22-05.mp4`. Postavite `OMARCHY_SCREENRECORD_DIR` da to promijenite — ali imajte na umu da, za razliku od direktorija snimki zaslona, ovaj mora već postojati, inače snimanje odbija započeti.

Dok snimate, u traci se pojavljuje maleni pokazatelj. Kliknite ga da zaustavite. Zaustaviti možete i ponovnim prečacom `Alt + Print Screen` ili unosom _Zaustavi snimanje zaslona_ pod _Pokreni > Snimaj > Snimanje zaslona_, koji se pojavljuje samo dok se nešto doista snima.

Zaustavljanje napravi malo pospremanja prije nego što vam preda datoteku: prvi kadar se podrezuje, a ako ima zvuka, normalizira se na -14 LUFS s PipeWire pucketanjem na samome početku utišanim. Zatim se pojavljuje obavijest s minijaturom iz snimke. Kliknite je da reproducirate datoteku u mpv-u.

### Sloj web-kamere

Kada snimate s web-kamerom, kamera se pojavljuje kao prikvačen, obrezan portretni prozor u donjem desnom kutu onoga što snimate. Ako sjedi na vrhu nečega što vam treba, promijenite mu veličinu u hodu:

| Prečac | Funkcija |
| ------ | -------- |
| `Super + Alt + [` | Smanji sloj web-kamere |
| `Super + Alt + ]` | Povećaj sloj web-kamere |

Postoje tri veličine — mala, srednja i velika — a prečaci koračaju između njih. Srednja je zadana. Proporcionalne su snimci, pa kamera zauzima isti udio kadra snimali vi 1080p monitor ili 6K monitor. A ako ste snimili područje umjesto cijeloga zaslona, sloj se sidri uz kut toga područja umjesto kut monitora, pa ostaje unutar snimke.

Možete ga pozvati i izravno s `omarchy-capture-webcam-resize small` ili `reset` za povratak na srednju.

## Tekst, QR kodovi i boje

`Super + Ctrl + Print Screen` odabire područje i OCR-om ga šalje u međuspremnik. To je pravilno obrađeno u [Izdvajanju teksta i diktiranju](11-text-extraction-dictation.md).

_Pokreni > Snimaj > QR kod_ radi isti trik za QR kodove. Odaberite područje s kodom i dekodirana vrijednost odlazi u međuspremnik. Traži samo QR kodove — gusti sadržaj zaslona inače ima naviku lažno se prepoznati kao barkod. Vrijedi znati: dekodirana vrijednost odlazi u međuspremnik i nigdje drugdje. Ne ispisuje se, nije u obavijesti i označena je kao osjetljiva pa ne ostaje u [povijesti međuspremnika](08-unified-clipboard-history.md). QR kodovi rutinski nose tajne — `otpauth://` URI iza 2FA koda za postavljanje, na primjer — i ne želite to u zapisniku. Lijepljenje i dalje radi u redu.

`Super + Print Screen` (ili _Pokreni > Snimaj > Boja_) pretvara pokazivač u kapaljku za oči. Kliknite bilo što na zaslonu i boja završi u međuspremniku. Ponovno pritisnite prečac da izađete bez odabira.

## Transkodiranje prije dijeljenja

4K snimka zaslona ili sirovi HEIC s vašega telefona često je prevelik da biste ga samo poslali. `Super + Ctrl + .` (ili _Pokreni > Transkodiraj_) to rješava. Nudi vam fuzzy birač datoteka nad `~/Pictures` i `~/Videos`, zatim pita za format i veličinu.

Slike idu u jpg ili png pri visokoj, srednjoj ili niskoj, što širinu ograničava na 3160, 2160 i 1080 piksela. Videozapisi idu u mp4 ili animirani gif pri 4k, 1080p ili 720p. Pretvorena datoteka zapisuje se pokraj izvornika s razlučivosti u nazivu — `demo-1080p.mp4` — a put se kopira u međuspremnik kao URI datoteke, pa je možete zalijepiti izravno u aplikaciju koja prima ispuštanja datoteka.

Radi i iz terminala, ako već znate što želite: `omarchy transcode ~/Videos/demo.mov mp4 1080p`. Tu je i `omarchy transcode ascii`, koji sliku pretvara u ASCII umjetnost — taj je uglavnom za [branding](41-branding.md).

## Slanje negdje

Jednom kada imate datoteku, `Super + Ctrl + S` otvara izbornik Dijeli i šalje je drugome uređaju na vašoj mreži putem LocalSenda. Pogledajte [GUI-je](22-guis.md) za to.
