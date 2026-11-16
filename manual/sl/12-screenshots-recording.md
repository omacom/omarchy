# Posnetki zaslona in snemanje

Vse, kar lahko poberete z zaslona, visi na tipki Print Screen. Sama tipka posname sliko, modifikatorji pa posnamejo posnetek, barvo ali besedilo znotraj območja. Če vaša tipkovnica tipke Print Screen sploh nima, `Super + Ctrl + Alt + C` posname isti posnetek zaslona, `Super + Ctrl + C` pa odpre celoten nabor kot meni.

| Bližnjica | Funkcija |
| ------ | -------- |
| `Print Screen` | Posnetek zaslona |
| `Super + Ctrl + Alt + C` | Posnetek zaslona |
| `Alt + Print Screen` | Snemanje zaslona (ali ustavitev tistega, ki poteka) |
| `Super + Print Screen` | Izbirnik barv |
| `Super + Ctrl + Print Screen` | Pridobivanje besedila iz območja |
| `Super + Ctrl + C` | Meni za zajem |
| `Super + Ctrl + .` | Prekodiranje slike ali videa |

## Posnetki zaslona

Pritisnite `Print Screen` (ali `Super + Ctrl + Alt + C`) in Omasnap zajame monitor v fokusu, preden se prikaže njegovo prekrivanje, tako da se vam med merjenjem nič ne premakne pod rokami. Povlecite območje poljubne oblike, kliknite okno, da ga zajamete, ali kliknite prazen prostor, da zajamete celoten monitor. Pred risanjem pritisnite `S`, da zajamete drseče območje. Ste si premislili? Znova pritisnite isto tipko, da zaprete Omasnap.

Potem ko izberete območje, Omasnap shrani zajem, ga kopira v odložišče in prikaže obvestilo z njegovo sličico, tako kot shranjeno snemanje zaslona. Izberite Odpri, da si shranjeni posnetek ogledate v pregledovalniku slik, ali Uredi, da ga opremite z opombami.

Urejevalnik za opombe zna risati puščice, črte, oblike, poudarke, oštevilčene oznake, besedilo in varne redakcije; obrezati ali izrezati del slike; z OCR prepoznati njeno besedilo; in dodati ozadje. V urejevalniku pritisnite `Enter`, da končani PNG kopirate in shranite, `Ctrl + C`, da ga kopirate brez shranjevanja, ali `Ctrl + S`, da ga shranite brez kopiranja.

Shranjeni posnetki zaslona privzeto pristanejo v `~/Pictures/Screenshots` z imenom, kot je `screenshot-2026-08-13_14-22-05-firefox.png`. Nastavite `OMASNAP_SCREENSHOT_DIR`, če želite uporabiti drug imenik — kje nastaviti okoljske spremenljivke seje, si oglejte v [pogostih vprašanjih](46-faq.md). Omasnap imenik ustvari, ko shrani prvi posnetek. Nastavite `[output] autosave = false` v `~/.config/omasnap/omasnap.conf`, da onemogočite samodejno shranjevanje; zajemi se nato samo kopirajo in za 10 sekund prikažejo v predogledu, ki ga lahko obdržite na zaslonu z gumbom za pripenjanje ali s `Ctrl + P`.

Iz terminala `omarchy screenshot` odpre isto prekrivanje, izberete pa lahko tudi njegov začetni način: `omarchy capture screenshot region`, `windows`, `fullscreen` ali `scroll`. Drugi argument `copy` ali `save` posnetek pošlje naravnost na ta cilj. Za urejanje pred izhodom uporabite `omarchy screenshot --editor=overlay` za celozaslonski urejevalnik ali `omarchy screenshot --editor=window` za ločeno okno.

### Upravljanje izbirnika s tipkovnico

Dokler je izbira odprta, miške sploh ne potrebujete:

| Tipka | Funkcija |
| --- | -------- |
| `S` | Preklop načina drsečega območja |
| `Super + Arrow keys` | Premikanje med okni v načinu oken |
| `Return` | Zajem označenega okna |
| `Ctrl + A` | Zajem celotnega monitorja v fokusu |
| `R` | Obnovitev zadnjega narisanega območja v tej seji |
| `Esc` | Zaprtje Omasnap |

Te vezave obstajajo samo, dokler je Omasnap odprt, zato ne morejo priti v navzkrižje z ničimer v vaši lastni konfiguraciji.

## Snemanje zaslona

`Alt + Print Screen` odpre _Sprožilec > Zajem > Snemanje zaslona_, kjer vas vpraša, kaj želite na zvočnem posnetku: brez zvoka, zvok namizja, namizje in mikrofon ali namizje, mikrofon in spletno kamero. Zadnja možnost se prikaže samo, če imate dejansko priključeno kamero. Izberite eno in Omarchyjev izbirnik za snemanje vam omogoči, da povlečete območje ali kliknete okno ali monitor.

Snemanje poganja gpu-screen-recorder, ki kodira na GPU pri 60fps in se po potrebi vrne na CPU. Rezultat je MP4 v `~/Videos` z imenom `screenrecording-2026-08-13_14-22-05.mp4`. To spremenite z `OMARCHY_SCREENRECORD_DIR` — a upoštevajte, da mora ta imenik za razliko od imenika za posnetke zaslona že obstajati, sicer se snemanje noče začeti.

Med snemanjem se v vrstici prikaže majhen kazalnik. Kliknite ga, da ustavite snemanje. Ustavite ga lahko tudi z vnovičnim `Alt + Print Screen` ali z vnosom _Ustavi snemanje zaslona_ pod _Sprožilec > Zajem > Snemanje zaslona_, ki se prikaže samo, dokler nekaj dejansko snema.

Ustavitev pred predajo datoteke opravi nekaj pospravljanja: prva sličica se odreže, zvok, če obstaja, pa se normalizira na -14 LUFS, pri čemer se pok pri zajemu PipeWire na samem začetku utiša. Nato se prikaže obvestilo s sličico iz posnetka. Kliknite ga, da datoteko predvajate v Omaview.

### Prekrivanje spletne kamere

Ko snemate s spletno kamero, se kamera prikaže kot pripeto, obrezano pokončno okno v spodnjem desnem kotu tega, kar snemate. Če leži na nečem, kar potrebujete, ji med snemanjem spremenite velikost:

| Bližnjica | Funkcija |
| ------ | -------- |
| `Super + Alt + [` | Pomanjšanje prekrivanja spletne kamere |
| `Super + Alt + ]` | Povečanje prekrivanja spletne kamere |

Na voljo so tri velikosti — majhna, srednja in velika — bližnjice pa korakajo med njimi. Srednja je privzeta. Sorazmerne so posnetku, zato kamera zavzame enak delež sličice, ne glede na to, ali snemate monitor 1080p ali 6K. In če ste posneli območje namesto celotnega zaslona, se prekrivanje zasidra v kot tega območja namesto monitorjevega, tako da ostane znotraj posnetka.

Neposredno ga lahko pokličete tudi z `omarchy-capture-webcam-resize small` ali z `reset`, da se vrnete na srednjo velikost.

## Besedilo, kode QR in barve

`Super + Ctrl + Print Screen` izbere območje in njegovo besedilo z OCR kopira v odložišče. To je pošteno obdelano v [Pridobivanju besedila in narekovanju](11-text-extraction-dictation.md).

_Sprožilec > Zajem > Koda QR_ naredi isti trik za kode QR. Izberite območje s kodo in dekodirana vrednost gre v odložišče. Išče samo kode QR — gosta vsebina zaslona ima sicer navado, da se lažno prepozna kot črtna koda. Velja vedeti: dekodirana vrednost gre v odložišče in nikamor drugam. Ni natisnjena, ni je v obvestilu in označena je kot občutljiva, tako da ne ostane v [zgodovini odložišča](08-unified-clipboard-history.md). Kode QR redno nosijo skrivnosti — na primer URI `otpauth://` za nastavitveno kodo za 2FA — in tega nočete v dnevniku. Lepljenje še vedno deluje brez težav.

`Super + Print Screen` (ali _Sprožilec > Zajem > Barva_) kazalec spremeni v kapalko. Kliknite karkoli na zaslonu in barva pristane v odložišču. Znova pritisnite bližnjico, da se umaknete, ne da bi karkoli izbrali.

## Prekodiranje, preden delite

Posnetek zaslona 4K ali surov HEIC iz telefona je pogosto prevelik, da bi ga kar poslali. `Super + Ctrl + .` (ali _Sprožilec > Prekodiraj_) to uredi. Ponudi vam mehki izbirnik datotek po `~/Pictures` in `~/Videos`, nato pa vpraša po obliki in velikosti.

Slike gredo v jpg ali png pri visoki, srednji ali nizki kakovosti, ki širino omejijo na 3160, 2160 in 1080 slikovnih pik. Videi gredo v mp4 ali animirani gif pri 4k, 1080p ali 720p. Pretvorjena datoteka se zapiše poleg izvirnika z ločljivostjo v imenu — `demo-1080p.mp4` — pot pa se kopira v odložišče kot URI datoteke, tako da jo lahko prilepite naravnost v aplikacijo, ki sprejema spuščanje datotek.

Deluje tudi iz terminala, če že veste, kaj želite: `omarchy transcode ~/Videos/demo.mov mp4 1080p`. Na voljo je tudi `omarchy transcode ascii`, ki sliko spremeni v umetnost ASCII — ta je večinoma za [blagovno znamko](41-branding.md).

## Pošiljanje nekam

Ko imate datoteko, `Super + Ctrl + S` odpre meni Deli in jo prek LocalSend pošlje drugi napravi v vašem omrežju. Za to si oglejte [GUIs](22-guis.md).
