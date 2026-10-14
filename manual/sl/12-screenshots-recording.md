# Posnetki zaslona in snemanje

Vse, kar lahko vzamete z zaslona, visi na tipki Print Screen. Ena tipka sama posname sliko, modifikatorji pa posnamejo posnetek, barvo ali besedilo znotraj območja. Če vaša tipkovnica sploh nima tipke Print Screen, `Super + Ctrl + C` odpre enak nabor kot meni.

| Bližnjica | Funkcija |
| ------ | -------- |
| `Print Screen` | Posnetek zaslona |
| `Alt + Print Screen` | Snemanje zaslona (ali ustavi tisto, ki teče) |
| `Super + Print Screen` | Izbirnik barve |
| `Super + Ctrl + Print Screen` | Izvleči besedilo iz območja |
| `Super + Ctrl + C` | Meni za zajem |
| `Super + Ctrl + .` | Prekodiraj sliko ali video |

## Posnetki zaslona

Pritisnite `Print Screen` in Omasnap zajame osredotočeni zaslon, preden se pojavi njegovo prekrivanje, tako da se nič ne premakne pod vami, medtem ko merite. Povlecite prosto obliko, kliknite okno, da ga zajamete, ali kliknite prazen prostor, da zajamete celoten zaslon. Pred risanjem pritisnite `S`, da zajamete drseče območje. Premislili ste si? Znova pritisnite `Print Screen`, da Omasnap odpustite.

Ko izberete območje, Omasnap zajem shrani, ga kopira v odložišče in 10 sekund prikaže predogled. Uporabite gumb za pripono v predogledu ali `Ctrl + P`, da ga obdržite na zaslonu, ali izberite Edit, da ga opremite z obvestili.

Urejevalnik obvestil lahko riše puščice, črte, oblike, osvetlitve, označene oznake, besedilo in varne redakcije; obreže ali izreže del slike; izvede OCR njenega besedila in doda ozadje. V urejevalniku pritisnite `Enter`, da kopirate in shranite končani PNG, `Ctrl + C`, da ga kopirate brez shranjevanja, ali `Ctrl + S`, da ga shranite brez kopiranja.

Shranjeni posnetki zaslona pristanejo privzeto v `~/Pictures/Screenshots` z imenom, kot je `screenshot-2026-08-13_14-22-05-firefox.png`. Nastavite `OMASNAP_SCREENSHOT_DIR`, da uporabite drug imenik — glejte [FAQ](46-faq.md), kam postaviti okoljske spremenljivke seje. Omasnap imenik ustvari, ko shrani prvi posnetek. V `~/.config/omasnap/omasnap.conf` nastavite `[output] autosave = false`, da onemogočite samodejno shranjevanje.

Iz terminala `omarchy screenshot` odpre enako prekrivanje, izberete pa lahko njegov začetni način: `omarchy capture screenshot region`, `windows`, `fullscreen` ali `scroll`. Drugi argument `copy` ali `save` preskoči predogled in posnetek pošlje naravnost na ta cilj. Za urejanje pred izhodom uporabite `omarchy screenshot --editor=overlay` za celozaslonski urejevalnik ali `omarchy screenshot --editor=window` za ločeno okno.

### Vodenje izbirnika s tipkovnico

Medtem ko je izbor prikazan, vam miške sploh ni treba uporabljati:

| Tipka | Funkcija |
| --- | -------- |
| `S` | Preklopi način drsečega območja |
| `Super + Arrow keys` | Premikanje med okni v načinu okna |
| `Return` | Zajemi označeno okno |
| `Ctrl + A` | Zajemi celoten osredotočeni zaslon |
| `R` | Obnovi zadnje narisano območje v tej seji |
| `Esc` | Odpusti Omasnap |

Te vezave obstajajo le, medtem ko je Omasnap odprt, zato ne morejo trčiti z ničemer v vaši konfiguraciji.

## Snemanje zaslona

`Alt + Print Screen` odpre _Trigger > Capture > Screenrecord_, ki vpraša, kaj želite imeti na zvočnem posnetku: brez zvoka, zvok namizja, namizje plus mikrofon ali namizje plus mikrofon plus spletna kamera. Zadnja se prikaže le, če imate dejansko priklopljeno kamero. Izberite eno in Omarchyjev izbirnik snemanja vam omogoči, da povlečete območje ali kliknete okno ali zaslon.

Snemanje teče na gpu-screen-recorderju, ki kodira na GPU pri 60 fps in pade nazaj na CPU, če mora. Rezultat je MP4 v `~/Videos` z imenom `screenrecording-2026-08-13_14-22-05.mp4`. To spremenite z `OMARCHY_SCREENRECORD_DIR` — vendar upoštevajte, da mora za razliko od imenika za posnetke zaslona ta že obstajati, sicer snemanje noče začeti.

Med snemanjem se v vrstici pojavi majhen kazalnik. Kliknite ga, da ustavite. Ustavite lahko tudi z vnovičnim `Alt + Print Screen` ali z vnosom _Stop Screenrecording_ pod _Trigger > Capture > Screenrecord_, ki se pojavi le, medtem ko se nekaj dejansko snema.

Ustavitev naredi nekaj pospravljanja, preden vam izroči datoteko: prvi okvir se odreže, in če je zvok, se normalizira na -14 LUFS, pri čemer je pok zajema PipeWire čisto na začetku utišan. Nato se pojavi obvestilo z sličico iz posnetka. Kliknite jo, da datoteko predvajate v mpv.

### Prekrivanje spletne kamere

Ko snemate s spletno kamero, se kamera pojavi kot pripeto, obrezano portretno okno v spodnjem desnem kotu česar koli že snemate. Če sedi na nečem, kar potrebujete, ji sproti spremenite velikost:

| Bližnjica | Funkcija |
| ------ | -------- |
| `Super + Alt + [` | Pomanjšaj prekrivanje spletne kamere |
| `Super + Alt + ]` | Povečaj prekrivanje spletne kamere |

Obstajajo tri velikosti — majhna, srednja in velika — in bližnjice stopajo med njimi. Srednja je privzeta. So sorazmerne s posnetkom, tako da kamera zasede enak delež okvirja, ne glede na to, ali snemate 1080p zaslon ali 6K zaslon. In če ste posneli območje in ne celotnega zaslona, se prekrivanje sidra na vogal tega območja in ne na vogal zaslona, tako da ostane znotraj posnetka.

Pokličete ga lahko tudi neposredno z `omarchy-capture-webcam-resize small` ali `reset`, da se vrnete na srednjo.

## Besedila, kode QR in barve

`Super + Ctrl + Print Screen` izbere območje in ga z OCR prenese v odložišče. To je pravilno obravnavano v [Izvlečenju besedila in narekovanju](11-text-extraction-dictation.md).

_Trigger > Capture > QR Code_ naredi enak trik za kode QR. Izberite območje s kodo in dekodirana vrednost gre v odložišče. Išče le kode QR — gosta vsebina zaslona se sicer rado zmotno pozitivno javi kot črtna koda. Vredno je vedeti: dekodirana vrednost gre v odložišče in nikamor drugam. Ni natisnjena, ni v obvestilu in je označena kot občutljiva, tako da ne obstane v [zgodovini odložišča](08-unified-clipboard-history.md). Kode QR rutinsko nosijo skrivnosti — na primer URI `otpauth://` za nastavitveno kodo 2FA — in tega ne želite v dnevniku. Lepljenje še vedno deluje dobro.

`Super + Print Screen` (ali _Trigger > Capture > Color_) kazalnik spremeni v pipeto. Kliknite karkoli na zaslonu in barva pristane v odložišču. Znova pritisnite bližnjico, da se umaknete, ne da bi izbrali.

## Prekodiranje pred deljenjem

Posnetek zaslona 4K ali surovi HEIC iz telefona je pogosto prevelik, da bi ga kar poslali. `Super + Ctrl + .` (ali _Trigger > Transcode_) to popravi. Ponudi vam nejasni izbirnik datotek prek `~/Pictures` in `~/Videos`, nato vpraša po formatu in velikosti.

Slike gredo v jpg ali png pri visoki, srednji ali nizki kakovosti, ki širino omejijo na 3160, 2160 in 1080 slikovnih pik. Videi gredo v mp4 ali animirani gif pri 4k, 1080p ali 720p. Pretvorjena datoteka se zapiše poleg izvirnika z ločljivostjo v imenu — `demo-1080p.mp4` — pot pa se kopira v odložišče kot URI datoteke, tako da jo lahko prilepite neposredno v aplikacijo, ki sprejema puščanje datotek.

Deluje tudi iz terminala, če že veste, kaj želite: `omarchy transcode ~/Videos/demo.mov mp4 1080p`. Tu je tudi `omarchy transcode ascii`, ki sliko spremeni v umetnost ASCII — ta je večinoma za [blagovno znamko](41-branding.md).

## Pošiljanje nekam

Ko imate datoteko, `Super + Ctrl + S` odpre meni Deli in jo prek LocalSenda pošlje drugi napravi v vašem omrežju. Za to glejte [GUIs](22-guis.md).
