# Posnetki zaslona in snemanje

Vse, kar lahko zajamete z zaslona, je vezano na tipko Print Screen. Tipka sama po sebi posname sliko, modifikatorji pa posnamejo posnetek, barvo ali besedilo znotraj območja. Če vaša tipkovnica tipke Print Screen sploh nima, `Super + Ctrl + Alt + C` posname isti posnetek zaslona, `Super + Ctrl + C` pa odpre celoten nabor kot meni.

| Bližnjica | Funkcija |
| ------ | -------- |
| `Print Screen` | Posnetek zaslona |
| `Super + Ctrl + Alt + C` | Posnetek zaslona |
| `Alt + Print Screen` | Snemanje zaslona (ali zaustavitev tistega, ki trenutno teče) |
| `Super + Print Screen` | Izbirnik barv |
| `Super + Ctrl + Print Screen` | Izvleci besedilo iz območja |
| `Super + Ctrl + C` | Meni za zajemanje |
| `Super + Ctrl + .` | Prekodiraj sliko ali video |

## Posnetki zaslona

Pritisnite `Print Screen` (ali `Super + Ctrl + Alt + C`) in Omasnap zajame osredotočeni monitor, preden se prikaže njegovo prekrivanje, tako da se vam med merjenjem nič ne premakne. Povlecite prosto območje, kliknite okno, da ga zajamete, ali kliknite prazen prostor, da zajamete celoten monitor. Pred risanjem pritisnite `S`, da zajamete drseče območje. Ste si premislili? Znova pritisnite isto tipko, da zaprete Omasnap.

Ko izberete območje, Omasnap shrani zajem, ga kopira v odložišče in prikaže obvestilo z njegovo sličico, podobno kot pri shranjenem posnetku zaslona. Izberite Open, da si shranjeni posnetek ogledate v pregledovalniku slik, ali Edit, da ga opremite z opombami.

Urejevalnik za opombe lahko riše puščice, črte, oblike, poudarke, oštevilčene oznake, besedilo in varne redakcije; obreže ali izreže del slike; z optičnim prepoznavanjem znakov prebere njeno besedilo; in doda ozadje. V urejevalniku pritisnite `Enter`, da kopirate in shranite dokončano sliko PNG, `Ctrl + C`, da jo kopirate brez shranjevanja, ali `Ctrl + S`, da jo shranite brez kopiranja.

Shranjeni posnetki zaslona privzeto pristanejo v `~/Pictures/Screenshots`, z imenom, kot je `screenshot-2026-08-13_14-22-05-firefox.png`. Nastavite `OMASNAP_SCREENSHOT_DIR`, če želite uporabiti drugo mapo — glejte [pogosta vprašanja](46-faq.md), kje lahko nastavite okoljske spremenljivke seje. Omasnap mapo ustvari, ko shrani prvi posnetek. Nastavite `[output] autosave = false` v `~/.config/omasnap/omasnap.conf`, da onemogočite samodejno shranjevanje; zajemi se nato samo kopirajo in prikažejo v predogledu za 7 sekund, ki ga lahko s pripenjalnim gumbom ali `Ctrl + P` obdržite na zaslonu.

Iz terminala `omarchy screenshot` odpre isto prekrivanje, izberete pa lahko tudi njegov začetni način: `omarchy capture screenshot region`, `windows`, `fullscreen` ali `scroll`. Drugi argument `copy` ali `save` posnetek pošlje naravnost na ta cilj. Za urejanje pred izhodom uporabite `omarchy screenshot --editor=overlay` za celozaslonski urejevalnik ali `omarchy screenshot --editor=window` za ločeno okno.

### Upravljanje izbirnika s tipkovnico

Medtem ko je izbor prikazan, miške sploh ne potrebujete:

| Tipka | Funkcija |
| --- | -------- |
| `S` | Preklopi način drsečega območja |
| `Super + Arrow keys` | Premikanje med okni v okenskem načinu |
| `Return` | Zajemi označeno okno |
| `Ctrl + A` | Zajemi celoten osredotočeni monitor |
| `R` | Obnovi zadnje območje, narisano v tej seji |
| `Esc` | Zapri Omasnap |

Te vezave obstajajo le, ko je Omasnap odprt, zato ne morejo trčiti z ničimer v vaši lastni konfiguraciji.

## Snemanje zaslona

`Alt + Print Screen` odpre _Trigger > Capture > Screenrecord_, ki vas vpraša, kaj želite na zvočnem posnetku: brez zvoka, zvok namizja, zvok namizja in mikrofon ali zvok namizja, mikrofon in spletno kamero. Zadnja možnost se prikaže le, če imate dejansko priključeno kamero. Izberite eno in Omarchyjev izbirnik za snemanje vam omogoči, da povlečete območje ali kliknete okno ali monitor.

Snemanje teče na gpu-screen-recorder, ki kodira na GPU pri 60fps in po potrebi preklopi na CPU; na GPU, ki jih ne podpira, kot je Apple Silicon, Omarchy namesto tega snema z wf-recorder. Rezultat je MP4 v `~/Videos`, poimenovan `screenrecording-2026-08-13_14-22-05.mp4`. Nastavite `OMARCHY_SCREENRECORD_DIR`, da to spremenite — vendar upoštevajte, da mora ta mapa, za razliko od mape za posnetke zaslona, že obstajati, sicer se snemanje noče začeti.

Med snemanjem se v vrstici pokaže majhen kazalnik. Kliknite ga, da ustavite snemanje. Ustavite lahko tudi z `Alt + Print Screen` ali z vnosom _Stop Screenrecording_ pod _Trigger > Capture > Screenrecord_, ki se prikaže le, ko nekaj dejansko snema.

Ustavitev pred predajo datoteke opravi nekaj pospravljanja: prva sličica se odreže, in če je prisoten zvok, se normalizira na -14 LUFS, pri čemer se pok pri zajemu PipeWire na samem začetku utiša. Nato se prikaže obvestilo s sličico iz posnetka. Izberite _Open_, da datoteko predvajate v Omaview, ali _Cut_, da jo obrežete v Omacut.

### Prekrivanje spletne kamere

Ko snemate s spletno kamero, se kamera prikaže kot pripeto, obrezano portretno okno v spodnjem desnem kotu tega, kar snemate. Če leži na nečem, kar potrebujete, jo sproti spremenite:

| Bližnjica | Funkcija |
| ------ | -------- |
| `Super + Alt + [` | Pomanjšaj prekrivanje spletne kamere |
| `Super + Alt + ]` | Povečaj prekrivanje spletne kamere |

Na voljo so tri velikosti — majhna, srednja in velika — in bližnjice stopnjujejo med njimi. Srednja je privzeta. Sorazmerne so z posnetkom, tako da kamera zavzame enak delež kadra, ne glede na to, ali snemate monitor 1080p ali 6K. Če ste namesto celotnega zaslona posneli območje, se prekrivanje zasidra v kot tega območja in ne monitorja, tako da ostane znotraj posnetka.

Neposredno ga lahko pokličete tudi z `omarchy-capture-webcam-resize small`, ali z `reset`, da se vrnete na srednjo velikost.

## Besedilo, kode QR in barve

`Super + Ctrl + Print Screen` izbere območje in njegovo besedilo z optičnim prepoznavanjem znakov kopira v odložišče. To je ustrezno obravnavano v [Izvlečenje besedila in narekovanje](11-text-extraction-dictation.md).

_Trigger > Capture > QR Code_ naredi isti trik za kode QR. Izberite območje s kodo v njem in dekodirana vrednost gre v odložišče. Išce samo kode QR — gosta vsebina zaslona se sicer rada lažno prepozna kot črtna koda. Vedeti je treba: dekodirana vrednost gre v odložišče in nikamor drugam. Ni natisnjena, ni v obvestilu in je označena kot občutljiva, da ne ostane v [zgodovini odložišča](08-unified-clipboard-history.md). Kode QR redno nosijo skrivnosti — na primer URI `otpauth://` za kodo za nastavitev 2FA — in tega ne želite v dnevniku. Lepljenje še vedno deluje brez težav.

`Super + Print Screen` (ali _Trigger > Capture > Color_) spremeni kazalec v kapalko. Kliknite karkoli na zaslonu in barva pristane v odložišču. Znova pritisnite bližnjico, da izstopite brez izbiranja.

## Prekodiranje pred deljenjem

Posnetek zaslona 4K ali surova slika HEIC iz telefona je pogosto prevelika, da bi jo kar poslali. `Super + Ctrl + .` (ali _Trigger > Transcode_) to odpravi. Ponudi vam mehak izbirnik datotek nad `~/Pictures` in `~/Videos`, nato pa vpraša po formatu in velikosti.

Slike gredo v jpg ali png pri visoki, srednji ali nizki kakovosti, ki omejijo širino na 3160, 2160 in 1080 slikovnih pik. Videi gredo v mp4 ali animirani gif pri 4k, 1080p ali 720p. Pretvorjena datoteka se zapiše poleg izvirnika, z ločljivostjo v imenu — `demo-1080p.mp4` — pot pa se kot URI datoteke kopira v odložišče, tako da jo lahko prilepite neposredno v aplikacijo, ki sprejema spuščanje datotek.

Deluje tudi iz terminala, če že veste, kaj želite: `omarchy transcode ~/Videos/demo.mov mp4 1080p`. Na voljo je tudi `omarchy transcode ascii`, ki sliko spremeni v umetnost ASCII — ta je večinoma za [blagovno znamko](41-branding.md).

## Pošiljanje nekam drugam

Ko imate datoteko, `Super + Ctrl + S` odpre meni Share in jo prek LocalSend pošlje drugi napravi v vašem omrežju. Za to glejte [grafične vmesnike](22-guis.md).
