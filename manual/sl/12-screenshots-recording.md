# Posnetki zaslona in snemanje

Vse, kar lahko zgrabiš z zaslona, visi na tipki Print Screen. Tipka sama zase posname sliko, modifikatorji pa posnamejo posnetek, barvo ali besedilo znotraj območja. Če tvoja tipkovnica tipke Print Screen sploh nima, `Super + Ctrl + Alt + C` posname isti posnetek zaslona, `Super + Ctrl + C` pa odpre celoten nabor kot meni.

| Bližnjica | Funkcija |
| ------ | -------- |
| `Print Screen` | Posnetek zaslona |
| `Super + Ctrl + Alt + C` | Posnetek zaslona |
| `Alt + Print Screen` | Snemanje zaslona (ali zaustavitev tistega, ki teče) |
| `Super + Print Screen` | Izbirnik barv |
| `Super + Ctrl + Print Screen` | Pridobivanje besedila iz območja |
| `Super + Ctrl + C` | Meni za zajem |
| `Super + Ctrl + .` | Prekodiranje slike ali videa |

## Posnetki zaslona

Pritisni `Print Screen` (ali `Super + Ctrl + Alt + C`) in Omasnap zajame osredotočeni monitor, preden se pojavi njegova prekrivna plast, tako da se nič ne premakne pod teboj, medtem ko meriš. Povleci prostoročno območje, klikni okno, da ga zajameš, ali klikni prazen prostor, da zajameš celoten monitor. Pred risanjem pritisni `S`, da zajameš drseče območje. Si si premislil? Znova pritisni isto tipko, da zapreš Omasnap.

Ko izbereš območje, Omasnap shrani zajem, ga kopira v odložišče in za 10 sekund pokaže predogled. Uporabi gumb za pripenjanje v predogledu ali `Ctrl + P`, da ga obdržiš na zaslonu, ali izberi Uredi, da ga opremiš z opombami.

Urejevalnik opomb lahko riše puščice, črte, oblike, poudarke, oštevilčene oznake, besedilo in varne redakcije; obreže ali izreže del slike; z OCR prebere njeno besedilo; in doda ozadje. V urejevalniku pritisni `Enter`, da kopiraš in shraniš končano datoteko PNG, `Ctrl + C`, da jo kopiraš brez shranjevanja, ali `Ctrl + S`, da jo shraniš brez kopiranja.

Shranjeni posnetki zaslona privzeto pristanejo v `~/Pictures/Screenshots` z imenom, kot je `screenshot-2026-08-13_14-22-05-firefox.png`. Nastavi `OMASNAP_SCREENSHOT_DIR`, da uporabiš drugo mapo — glej [pogosta vprašanja](46-faq.md) za to, kam dati okoljske spremenljivke seje. Omasnap ustvari mapo, ko shrani prvi posnetek. Nastavi `[output] autosave = false` v `~/.config/omasnap/omasnap.conf`, da onemogočiš samodejno shranjevanje.

Iz terminala `omarchy screenshot` odpre isto prekrivno plast, izbereš pa lahko tudi njen začetni način: `omarchy capture screenshot region`, `windows`, `fullscreen` ali `scroll`. Drugi argument `copy` ali `save` preskoči predogled in pošlje posnetek naravnost na to ciljno mesto. Za urejanje pred izhodom uporabi `omarchy screenshot --editor=overlay` za celozaslonski urejevalnik ali `omarchy screenshot --editor=window` za ločeno okno.

### Upravljanje izbirnika s tipkovnico

Medtem ko je izbor odprt, miške sploh ne potrebuješ:

| Tipka | Funkcija |
| --- | -------- |
| `S` | Preklop načina drsečega območja |
| `Super + Arrow keys` | Premikanje med okni v načinu oken |
| `Return` | Zajem označenega okna |
| `Ctrl + A` | Zajem celotnega osredotočenega monitorja |
| `R` | Obnovitev zadnjega območja, narisanega v tej seji |
| `Esc` | Zaprtje Omasnap |

Te vezave obstajajo samo, ko je Omasnap odprt, zato ne morejo trčiti z ničemer v tvoji lastni konfiguraciji.

## Snemanje zaslona

`Alt + Print Screen` odpre _Sprožilec > Zajem > Snemanje zaslona_, ki vpraša, kaj želiš na zvočnem posnetku: brez zvoka, zvok namizja, namizje in mikrofon ali namizje, mikrofon in spletno kamero. Zadnja možnost se pokaže samo, če imaš kamero dejansko priklopljeno. Izberi eno in Omarchyjev izbirnik za snemanje ti omogoči, da povlečeš območje ali klikneš okno ali monitor.

Snemanje poganja gpu-screen-recorder, ki kodira na GPU pri 60fps in po potrebi preklopi na CPU. Rezultat je datoteka MP4 v `~/Videos` z imenom `screenrecording-2026-08-13_14-22-05.mp4`. Nastavi `OMARCHY_SCREENRECORD_DIR`, da to spremeniš — a upoštevaj, da mora ta mapa za razliko od mape za posnetke zaslona že obstajati, sicer se snemanje noče začeti.

Med snemanjem se v vrstici pojavi majhen kazalnik. Klikni ga, da zaustaviš snemanje. Zaustaviš lahko tudi znova z `Alt + Print Screen` ali z vnosom _Zaustavi snemanje zaslona_ pod _Sprožilec > Zajem > Snemanje zaslona_, ki se pojavi samo, ko se nekaj dejansko snema.

Zaustavitev pred predajo datoteke malo pospravi: prvi kader se odreže, zvok, če obstaja, pa se normalizira na -14 LUFS, pri čemer se pok pri zajemu PipeWire na samem začetku utiša. Nato se pojavi obvestilo s sličico iz posnetka. Klikni ga, da datoteko predvajaš v mpv.

### Prekrivna plast spletne kamere

Ko snemaš s spletno kamero, se kamera pojavi kot pripeto, obrezano portretno okno v spodnjem desnem kotu tega, kar snemaš. Če leži na nečem, kar potrebuješ, ji sproti spremeni velikost:

| Bližnjica | Funkcija |
| ------ | -------- |
| `Super + Alt + [` | Pomanjšanje prekrivne plasti spletne kamere |
| `Super + Alt + ]` | Povečanje prekrivne plasti spletne kamere |

Na voljo so tri velikosti — majhna, srednja in velika — bližnjice pa korakajo med njimi. Srednja je privzeta. Sorazmerne so s posnetkom, zato kamera zavzame enak delež kadra, ne glede na to, ali snemaš monitor 1080p ali 6K. In če si posnel območje in ne celotnega zaslona, se prekrivna plast zasidra v kot tega območja in ne monitorja, zato ostane znotraj posnetka.

Pokličeš jo lahko tudi neposredno z `omarchy-capture-webcam-resize small` ali `reset`, da se vrneš na srednjo.

## Besedilo, kode QR in barve

`Super + Ctrl + Print Screen` izbere območje in z OCR prebere njegovo besedilo v odložišče. To je ustrezno obravnavano v [Pridobivanje besedila in narekovanje](11-text-extraction-dictation.md).

_Sprožilec > Zajem > Koda QR_ naredi isti trik za kode QR. Izberi območje s kodo v njem in dekodirana vrednost gre v odložišče. Išče samo kode QR — gosta vsebina zaslona sicer rada lažno pozitivno izpade kot črtna koda. Dobro je vedeti: dekodirana vrednost gre v odložišče in nikamor drugam. Ni natisnjena, ni v obvestilu in označena je kot občutljiva, zato ne ostane v [zgodovini odložišča](08-unified-clipboard-history.md). Kode QR redno nosijo skrivnosti — na primer URI `otpauth://` za kodo za nastavitev 2FA — in tega nočeš v dnevniku. Lepljenje še vedno deluje brez težav.

`Super + Print Screen` (ali _Sprožilec > Zajem > Barva_) spremeni kazalec v kapalko. Klikni karkoli na zaslonu in barva pristane v odložišču. Znova pritisni bližnjico, da se umakneš brez izbire.

## Prekodiranje pred deljenjem

Posnetek zaslona 4K ali surova datoteka HEIC s telefona je pogosto prevelika, da bi ju kar poslali. `Super + Ctrl + .` (ali _Sprožilec > Prekodiraj_) to popravi. Ponudi ti mehki izbirnik datotek po `~/Pictures` in `~/Videos`, nato vpraša po formatu in velikosti.

Slike gredo v jpg ali png pri visoki, srednji ali nizki, ki širino omejijo na 3160, 2160 in 1080 slikovnih pik. Videi gredo v mp4 ali animirani gif pri 4k, 1080p ali 720p. Pretvorjena datoteka se zapiše poleg izvirnika z ločljivostjo v imenu — `demo-1080p.mp4` — pot pa se kopira v odložišče kot URI datoteke, tako da jo lahko prilepiš neposredno v aplikacijo, ki sprejema spuščanje datotek.

Deluje tudi iz terminala, če že veš, kaj hočeš: `omarchy transcode ~/Videos/demo.mov mp4 1080p`. Na voljo je tudi `omarchy transcode ascii`, ki sliko spremeni v umetnost ASCII — ta je večinoma za [blagovno znamko](41-branding.md).

## Pošiljanje nekam

Ko imaš datoteko, `Super + Ctrl + S` odpre meni Deli in jo prek LocalSend pošlje drugi napravi v tvojem omrežju. Za to glej [grafične vmesnike](22-guis.md).
