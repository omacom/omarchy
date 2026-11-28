# Snimke zaslona i snimanje

Sve što možete skinuti sa zaslona visi o tipki Print Screen. Jedna tipka sama snima sliku, a modifikatori snimaju video, boju ili tekst unutar regije. Ako vaša tipkovnica uopće nema tipku Print Screen, `Super + Ctrl + Alt + C` snima istu snimku zaslona, a `Super + Ctrl + C` otvara cijeli skup kao izbornik.

| Prečac | Funkcija |
| ------ | -------- |
| `Print Screen` | Snimka zaslona |
| `Super + Ctrl + Alt + C` | Snimka zaslona |
| `Alt + Print Screen` | Snimanje zaslona (ili zaustavljanje onoga koje je u tijeku) |
| `Super + Print Screen` | Birač boje |
| `Super + Ctrl + Print Screen` | Izdvajanje teksta iz regije |
| `Super + Ctrl + C` | Izbornik snimanja |
| `Super + Ctrl + .` | Transkodiranje slike ili videa |

## Snimke zaslona

Pritisnite `Print Screen` (ili `Super + Ctrl + Alt + C`) i Omasnap će snimiti fokusirani monitor prije nego što se pojavi njegov sloj, pa se ništa ne pomiče pod vama dok ciljate. Povucite slobodnu regiju, kliknite prozor da ga snimite ili kliknite prazan prostor da snimite cijeli monitor. Pritisnite `S` prije crtanja da snimite regiju koja se pomiče. Predomislili ste se? Ponovno pritisnite istu tipku da odbacite Omasnap.

Nakon što odaberete područje, Omasnap sprema snimku, kopira je u međuspremnik i prikazuje obavijest s njezinom minijaturom, kao što to čini spremljena snimka zaslona. Odaberite Open da pogledate spremljenu snimku u svom pregledniku slika ili Edit da je označite.

Uređivač za označavanje može crtati strelice, crte, oblike, isticanja, numerirane oznake, tekst i sigurne redakcije; izrezati ili izbaciti dio slike; OCR-om izdvojiti njezin tekst; i dodati pozadinu. U uređivaču pritisnite `Enter` da kopirate i spremite gotovi PNG, `Ctrl + C` da ga kopirate bez spremanja ili `Ctrl + S` da ga spremite bez kopiranja.

Spremljene snimke zaslona prema zadanim postavkama završavaju u `~/Pictures/Screenshots`, s nazivom poput `screenshot-2026-08-13_14-22-05-firefox.png`. Postavite `OMASNAP_SCREENSHOT_DIR` da koristite drugi direktorij — pogledajte [Česta pitanja](46-faq.md) za mjesto gdje se stavljaju varijable okruženja sesije. Omasnap stvara direktorij kada sprema prvu snimku. Postavite `[output] autosave = false` u `~/.config/omasnap/omasnap.conf` da onemogućite automatsko spremanje; snimke se tada samo kopiraju i prikazuju u pregledu na 7 sekundi, koji možete zadržati na zaslonu njegovim gumbom za prikvačivanje ili s `Ctrl + P`.

Iz terminala `omarchy screenshot` otvara isti sloj, a možete odabrati i njegov početni način: `omarchy capture screenshot region`, `windows`, `fullscreen` ili `scroll`. Drugi argument `copy` ili `save` šalje snimku izravno na to odredište. Da uredite prije izlaza, upotrijebite `omarchy screenshot --editor=overlay` za uređivač preko cijelog zaslona ili `omarchy screenshot --editor=window` za zaseban prozor.

### Upravljanje biračem s tipkovnice

Dok je odabir otvoren, uopće ne morate koristiti miš:

| Tipka | Funkcija |
| --- | -------- |
| `S` | Uključivanje/isključivanje načina regije koja se pomiče |
| `Super + Arrow keys` | Kretanje među prozorima u načinu Window |
| `Return` | Snimanje istaknutog prozora |
| `Ctrl + A` | Snimanje cijelog fokusiranog monitora |
| `R` | Vraćanje posljednje regije nacrtane u ovoj sesiji |
| `Esc` | Odbacivanje Omasnapa |

Te veze postoje samo dok je Omasnap otvoren, pa se ne mogu sudariti ni s čim u vašoj vlastitoj konfiguraciji.

## Snimanje zaslona

`Alt + Print Screen` otvara _Trigger > Capture > Screenrecord_, koji pita što želite na zvučnoj podlozi: bez zvuka, zvuk radne površine, zvuk radne površine plus mikrofon ili zvuk radne površine plus mikrofon plus web-kameru. Ta posljednja opcija prikazuje se samo ako vam je kamera stvarno priključena. Odaberite jednu i Omarchyjev birač snimanja omogućit će vam da povučete regiju ili kliknete prozor ili monitor.

Snimanje radi na gpu-screen-recorderu, koji kodira na GPU-u pri 60fps i prelazi na CPU ako mora; na GPU-ovima koje ne podržava, poput onih Apple Silicona, Omarchy umjesto toga snima s wf-recorderom. Rezultat je MP4 u `~/Videos`, pod nazivom `screenrecording-2026-08-13_14-22-05.mp4`. Postavite `OMARCHY_SCREENRECORD_DIR` da to promijenite — ali imajte na umu da, za razliku od direktorija za snimke zaslona, ovaj već mora postojati, inače se snimanje odbija pokrenuti.

Dok snimate, u traci se pojavljuje mali pokazatelj. Kliknite ga da zaustavite. Možete zaustaviti i ponovnim pritiskom na `Alt + Print Screen` ili unosom _Stop Screenrecording_ pod _Trigger > Capture > Screenrecord_, koji se pojavljuje samo dok se nešto stvarno snima.

Zaustavljanje prije predaje datoteke malo pospremi: prvi kadar se odreže, a ako ima zvuka, normalizira se na -14 LUFS, pri čemu se škljocanje PipeWire snimanja na samom početku utiša. Zatim se pojavljuje obavijest s minijaturom iz snimke. Odaberite _Open_ da reproducirate datoteku u Omaviewu ili _Cut_ da je odrežete u Omacutu.

### Sloj web-kamere

Kada snimate web-kamerom, kamera se pojavljuje kao prikvačen, izrezan portretni prozor u donjem desnom kutu onoga što snimate. Ako vam stoji preko nečega što vam treba, promijenite joj veličinu u letu:

| Prečac | Funkcija |
| ------ | -------- |
| `Super + Alt + [` | Smanjivanje sloja web-kamere |
| `Super + Alt + ]` | Povećavanje sloja web-kamere |

Postoje tri veličine — mala, srednja i velika — a prečaci korak po korak prelaze između njih. Srednja je zadana. Proporcionalne su snimci, pa kamera zauzima isti udio kadra bez obzira snimate li monitor od 1080p ili 6K. A ako ste snimili regiju, a ne cijeli zaslon, sloj se sidri za kut te regije, a ne monitora, pa ostaje unutar kadra.

Možete ga pozvati i izravno s `omarchy-capture-webcam-resize small` ili `reset` da se vratite na srednju veličinu.

## Tekst, QR kodovi i boje

`Super + Ctrl + Print Screen` odabire regiju i OCR-om je pretvara u tekst u međuspremniku. To je kako treba obrađeno u [Izdvajanju teksta i diktiranju](11-text-extraction-dictation.md).

_Trigger > Capture > QR Code_ radi isti trik za QR kodove. Odaberite regiju s kodom i dekodirana vrijednost odlazi u međuspremnik. Traži samo QR kodove — gust sadržaj zaslona inače se često lažno prepoznaje kao crtični kod. Vrijedi znati: dekodirana vrijednost odlazi u međuspremnik i nigdje drugdje. Ne ispisuje se, nema je u obavijesti i označena je kao osjetljiva pa ne ostaje u [povijesti međuspremnika](08-unified-clipboard-history.md). QR kodovi rutinski nose tajne — `otpauth://` URI iza koda za postavljanje 2FA, primjerice — a to ne želite u zapisniku. Lijepljenje i dalje radi bez problema.

`Super + Print Screen` (ili _Trigger > Capture > Color_) pretvara pokazivač u kapaljku. Kliknite bilo što na zaslonu i boja završava u međuspremniku. Ponovno pritisnite prečac da izađete bez biranja.

## Transkodiranje prije dijeljenja

Snimka zaslona u 4K ili sirovi HEIC s telefona često su preveliki da ih samo pošaljete. `Super + Ctrl + .` (ili _Trigger > Transcode_) to rješava. Nudi vam birač datoteka s neizrazitim pretraživanjem nad `~/Pictures` i `~/Videos`, a zatim traži format i veličinu.

Slike idu u jpg ili png pri visokoj, srednjoj ili niskoj kvaliteti, što širinu ograničava na 3160, 2160 i 1080 piksela. Videozapisi idu u mp4 ili animirani gif pri 4k, 1080p ili 720p. Pretvorena datoteka zapisuje se pokraj izvornika, s razlučivošću u nazivu — `demo-1080p.mp4` — a putanja se kopira u međuspremnik kao URI datoteke, pa je možete zalijepiti izravno u aplikaciju koja prima ispuštanje datoteka.

Radi i iz terminala, ako već znate što želite: `omarchy transcode ~/Videos/demo.mov mp4 1080p`. Postoji i `omarchy transcode ascii`, koji sliku pretvara u ASCII umjetnost — taj je uglavnom za [brendiranje](41-branding.md).

## Slanje nekamo

Kad imate datoteku, `Super + Ctrl + S` otvara izbornik Share i šalje je na drugi uređaj na vašoj mreži putem LocalSenda. Za to pogledajte [GUIs](22-guis.md).
