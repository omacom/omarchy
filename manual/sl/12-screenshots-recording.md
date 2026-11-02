# Posnetki zaslona in snemanje

Vse, kar lahko zgrabite z zaslona, visi na tipki Print Screen. Tipka sama po sebi posname sliko, modifikatorji pa posnamejo snemanje, barvo ali besedilo znotraj območja. Če vaša tipkovnica tipke Print Screen sploh nima, `Super + Ctrl + Alt + C` posname isti posnetek zaslona, `Super + Ctrl + C` pa odpre celoten nabor kot meni.

| Hotkey | Function |
| ------ | -------- |
| `Print Screen` | Posnetek zaslona |
| `Super + Ctrl + Alt + C` | Posnetek zaslona |
| `Alt + Print Screen` | Snemanje zaslona (ali zaustavitev tistega, ki se izvaja) |
| `Super + Print Screen` | Izbirnik barv |
| `Super + Ctrl + Print Screen` | Izvleči besedilo iz območja |
| `Super + Ctrl + C` | Meni za zajemanje |
| `Super + Ctrl + .` | Prekodiraj sliko ali videoposnetek |

## Posnetki zaslona

Pritisnite `Print Screen` (ali `Super + Ctrl + Alt + C`) in Omasnap zajame osredotočeni monitor, preden se pojavi njegova prekrivna plast, tako da se med merjenjem pod vami nič ne premakne. Povlecite prosto oblikovano območje, kliknite okno, da ga zajamete, ali kliknite prazen prostor, da zajamete celoten monitor. Pred risanjem pritisnite `S`, da zajamete drseče območje. Ste si premislili? Znova pritisnite isto tipko, da zaprete Omasnap.

Ko izberete območje, Omasnap shrani zajem, ga kopira v odložišče in pokaže obvestilo z njegovo sličico, podobno kot shranjen posnetek zaslona. Izberite Open, da si shranjeni posnetek ogledate v pregledovalniku slik, ali Edit, da ga opremite z opombami.

Urejevalnik opomb lahko riše puščice, črte, oblike, poudarke, oštevilčene oznake, besedilo in varne redakcije; obreže ali izreže del slike; OCR-a njeno besedilo; in doda ozadje. V urejevalniku pritisnite `Enter`, da končano sliko PNG kopirate in shranite, `Ctrl + C`, da jo kopirate brez shranjevanja, ali `Ctrl + S`, da jo shranite brez kopiranja.

Shranjeni posnetki zaslona privzeto pristanejo v `~/Pictures/Screenshots` z imenom, kot je `screenshot-2026-08-13_14-22-05-firefox.png`. Nastavite `OMASNAP_SCREENSHOT_DIR`, da uporabite drug imenik — glejte [pogosta vprašanja](46-faq.md) za to, kam postaviti okoljske spremenljivke seje. Omasnap imenik ustvari, ko shrani prvi posnetek. Nastavite `[output] autosave = false` v `~/.config/omasnap/omasnap.conf`, da onemogočite samodejno shranjevanje; zajemi se nato samo kopirajo in za 10 sekund pokažejo v predogledu, ki ga lahko s pripenjalnim gumbom ali `Ctrl + P` obdržite na zaslonu.

Iz terminala `omarchy screenshot` odpre isto prekrivno plast, izberete pa lahko njen začetni način: `omarchy capture screenshot region`, `windows`, `fullscreen` ali `scroll`. Drugi argument `copy` ali `save` pošlje posnetek naravnost na to destinacijo. Za urejanje pred izhodom uporabite `omarchy screenshot --editor=overlay` za celozaslonski urejevalnik ali `omarchy screenshot --editor=window` za ločeno okno.

### Upravljanje izbirnika s tipkovnico

Medtem ko je izbor prikazan, miške sploh ne potrebujete:

| Key | Function |
| --- | -------- |
| `S` | Preklopi način drsečega območja |
| `Super + Arrow keys` | Premikaj se med okni v okenskem načinu |
| `Return` | Zajemi označeno okno |
| `Ctrl + A` | Zajemi celoten osredotočeni monitor |
| `R` | Obnovi zadnje območje, narisano v tej seji |
| `Esc` | Zapri Omasnap |

Te vezave obstajajo samo, ko je Omasnap odprt, zato se ne morejo spopasti z ničimer v vaši lastni konfiguraciji.

## Snemanje zaslona

`Alt + Print Screen` odpre _Trigger > Capture > Screenrecord_, ki vas vpraša, kaj želite na zvočnem posnetku: brez zvoka, zvok namizja, zvok namizja in mikrofon ali zvok namizja, mikrofon in spletna kamera. Zadnja možnost se pojavi samo, če imate dejansko priključeno kamero. Izberite eno in Omarchyjev izbirnik snemanja vam omogoča, da povlečete območje ali kliknete okno ali monitor.

Snemanje teče na gpu-screen-recorder, ki kodira na GPU pri 60fps in se po potrebi zateče na CPU. Rezultat je MP4 v `~/Videos` z imenom `screenrecording-2026-08-13_14-22-05.mp4`. Nastavite `OMARCHY_SCREENRECORD_DIR`, da to spremenite — vendar upoštevajte, da mora ta imenik, za razliko od imenika za posnetke zaslona, že obstajati, sicer se snemanje noče začeti.

Med snemanjem se v vrstici pokaže majhen indikator. Kliknite ga, da ustavite. Ustavite lahko tudi z vnovičnim `Alt + Print Screen` ali z vnosom _Stop Screenrecording_ pod _Trigger > Capture > Screenrecord_, ki se pojavi samo, ko se nekaj dejansko snema.

Ustavljanje pred predajo datoteke opravi nekaj čiščenja: prvi okvir se obreže, in če je prisoten zvok, se normalizira na -14 LUFS, pri čemer se pok pri zajemu PipeWire na samem začetku utiša. Nato se pojavi obvestilo s sličico iz posnetka. Kliknite ga, da datoteko predvajate v mpv.

### Prekrivna plast spletne kamere

Ko snemate s spletno kamero, se kamera pokaže kot pripeto, obrezano portretno okno v spodnjem desnem kotu tega, kar snemate. Če leži na nečem, kar potrebujete, ji sproti spremenite velikost:

| Hotkey | Function |
| ------ | -------- |
| `Super + Alt + [` | Pomanjšaj prekrivno plast spletne kamere |
| `Super + Alt + ]` | Povečaj prekrivno plast spletne kamere |

Na voljo so tri velikosti — majhna, srednja in velika — bližnjice pa korakajo med njimi. Srednja je privzeta. Sorazmerne so z posnetkom, tako da kamera zavzame enak delež okvira, ne glede na to, ali snemate monitor 1080p ali 6K. In če ste posneli območje namesto celotnega zaslona, se prekrivna plast zasidra v kot tega območja namesto monitorjevega, tako da ostane znotraj posnetka.

Poklicate jo lahko tudi neposredno z `omarchy-capture-webcam-resize small` ali `reset`, da se vrnete na srednjo.

## Besedilo, kode QR in barve

`Super + Ctrl + Print Screen` izbere območje in ga OCR-a v odložišče. To je ustrezno obravnavano v [Pridobivanje besedila in narekovanje](11-text-extraction-dictation.md).

_Trigger > Capture > QR Code_ naredi isti trik za kode QR. Izberite območje s kodo v njem in dekodirana vrednost gre v odložišče. Išče samo kode QR — gosta vsebina zaslona se sicer rada lažno prepozna kot črtna koda. Vredno je vedeti: dekodirana vrednost gre v odložišče in nikamor drugam. Ni natisnjena, ni v obvestilu in je označena kot občutljiva, tako da ne ostane v [zgodovini odložišča](08-unified-clipboard-history.md). Kode QR običajno nosijo skrivnosti — na primer URI `otpauth://` za nastavitveno kodo 2FA — in tega ne želite v dnevniku. Lepljenje še vedno deluje v redu.

`Super + Print Screen` (ali _Trigger > Capture > Color_) spremeni kazalec v kapalico. Kliknite karkoli na zaslonu in barva pristane v odložišču. Znova pritisnite bližnjico, da izstopite brez izbire.

## Prekodiranje, preden delite

Posnetek zaslona 4K ali surov HEIC z vašega telefona je pogosto prevelik, da bi ga preprosto poslali. `Super + Ctrl + .` (ali _Trigger > Transcode_) to odpravi. Ponudi vam mehki izbirnik datotek po `~/Pictures` in `~/Videos`, nato pa vpraša po zapisu in velikosti.

Slike gredo v jpg ali png pri visoki, srednji ali nizki, ki širino omejijo na 3160, 2160 in 1080 slikovnih pik. Videoposnetki gredo v mp4 ali animirani gif pri 4k, 1080p ali 720p. Pretvorjena datoteka se zapiše poleg izvirnika z ločljivostjo v imenu — `demo-1080p.mp4` — pot pa se kopira v odložišče kot URI datoteke, tako da jo lahko prilepite neposredno v aplikacijo, ki sprejema spuščanje datotek.

Deluje tudi iz terminala, če že veste, kaj želite: `omarchy transcode ~/Videos/demo.mov mp4 1080p`. Obstaja tudi `omarchy transcode ascii`, ki sliko spremeni v umetnost ASCII — ta je večinoma za [blagovno znamko](41-branding.md).

## Pošiljanje nekam

Ko imate datoteko, `Super + Ctrl + S` odpre meni Share in jo prek LocalSend pošlje drugi napravi v vašem omrežju. Za to glejte [grafične vmesnike](22-guis.md).
