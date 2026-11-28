# Macist või Windowsist tulles

Kui oled aastaid kasutanud macOS-i või Windowsi, teavad su sõrmed sadat asja, mille õppimise su aju on juba unustanud. See peatükk on tõlkekiht: kuhu need instinktid Omarchys lähevad. Funktsioone endid käsitletakse põhjalikult mujal — see siin on lihtsalt kaart.

### Super on kõige keskmes

Kogu lihasmälu, mille oled Cmd või Windowsi klahvi ümber üles ehitanud, kandub üle ühele klahvile: Super. See on PC-klaviatuuril Windowsi klahv ja see on peaaegu iga Omarchy kiirklahvi ankur.

Sinu Spotlighti või Raycasti või Start-menüü refleksist saab `Super + Space`. See avab Omarchy menüü, mis käivitab rakendusi, muudab seadeid, paigaldab tarkvara, jäädvustab ekraani — peaaegu kõike. Filtreerimiseks hakka lihtsalt kirjutama. `Super + Alt + Space` näitab kõiki rakendusi ühel ruudustikul, nagu Launchpad seda teeb. Vaata [navigeerimist](04-navigation.md).

### Töölaual pole ikoone ja dokk püsib eemal

Töölaual pole ikoone, mida sättida, ja dokk peidab end, kui tööruumis on aken, kuni lükkad kursori ekraani selle serva juurde, alumise juurde, kui sa seda mujale ei vii (vaata [navigeerimist](04-navigation.md)). Rakendused käivituvad kiirklahviga (`Super + Return` terminali jaoks, `Super + Shift + Return` brauseri jaoks ja `Super + K` kõige kaardistatu loendi jaoks) või menüüst. Ainus püsiv kasutajaliidese osa on [ülemine riba](05-the-top-bar.md), mis katab selle, mida menüüriba, süsteemisalv ja Notification Center sinu jaoks varem tegid — ja peaaegu iga vidin sellel teeb midagi vasaku, parema ja keskmise klõpsu korral.

### Aknad paigutavad end ise

Suurim mõtteviisi muutus: sa ei lohista aknaid ringi ega haagi neid ekraani poolte külge. Ava aken ja see võtab enda alla kogu ekraani. Ava teine ja nad jagavad ekraani omavahel. Sa ei püüa kunagi üht akent teise alt välja, sest aknad ei kattu.

Kui vajad tõesti ujuvat akent, lülitab `Super + T` aktiivse akna paigutusest välja (ja tagasi). Aga anna paigutusele enne päris võimalus — see on kogu asja süda. [Navigeerimine](04-navigation.md) juhatab sind sellest läbi.

Tööruumid tunduvad tuttavad: need on macOS-i Spaces või Windowsi virtuaalsed töölauad, ainult et sa hakkad neid päriselt kasutama, sest `Super + 1/2/3/4` hüppab otse ühte ja `Super + Shift + 1/2/3/4` saadab aktiivse akna sinna. Animatsiooni viivitust pole, lihtsalt hetkelised hüpped. See tähendab, et sul ei pruugi isegi mitut monitori vaja olla, kui olid sellega varem harjunud.

### Kopeerimine ja kleepimine lihtsalt töötavad

Macil oli sul Cmd + C kõikjal. Windowsis oli sul Ctrl + C kõikjal — välja arvatud terminalis, kus see tapab su programmi. Omarchy annab sulle `Super + C`, `Super + X` ja `Super + V` ning need töötavad kõikjal, ka terminalis. Kesta jaoks pole vaja eraldi refleksi õppida.

Windowsi rahvas: teie Win + V lõikelaua ajalugu elab `Super + Ctrl + V` all ja see hoiab lisaks tekstile ka pilte. Vaata [ühendatud lõikelauda ja ajalugu](08-unified-clipboard-history.md).

### Tõlketabel

| Mille järele haarad | Omarchys |
| ------------- | ---------- |
| Spotlight / Raycast / Start-menüü | `Super + Space` — Omarchy menüü |
| AirDrop | LocalSend, `Super + Ctrl + S` kaudu — vaata [GUI-rakendusi](22-guis.md) |
| Cmd + Shift + 4 / Win + Shift + S | `Super + Ctrl + Alt + C` või `Print Screen` — vaata [ekraanipilte ja salvestamist](12-screenshots-recording.md) |
| Notification Center | Teavituste ajalugu `Super + Shift + Alt + ,` all |
| Time Machine (süsteemi jaoks) | Automaatsed [süsteemi hetktõmmised](47-system-snapshots.md) iga värskenduse korral |
| App Store / paigaldaja allalaadimine | _Install_ menüüs või `omarchy pkg add` — vaata [teisi pakette](29-other-packages.md) |
| System Settings / Control Panel | _Setup_ menüüs, mis redigeerib lihtsaid konfiguratsioonifaile — vaata [dotfaile](31-dotfiles.md) |
| Finder / File Explorer | Files, `Super + Shift + F` korral — vaata [GUI-rakendusi](22-guis.md) |
| Safari / Edge | Google Chrome `Super + Shift + Return` korral; vali teine _Setup > Defaults > Browser_ alt — vaata [brausereid](23-browsers.md) |
| Preview / Photos | Omaview piltide, video ja muusika jaoks, Document Viewer PDF-ide jaoks — vaata [GUI-rakendusi](22-guis.md) |
| TextEdit / Notepad | Plain, `Super + Shift + N` korral; vali teine _Setup > Defaults > Editor_ alt |

### Mõned asjad on tõesti teistmoodi

Paljud seaded elavad tekstifailides, mida sa redigeerid, mitte paneelides, mida läbi klõpsid. See kõlab primitiivselt, kuni mõistad, et see tähendab, et iga muudatust saab näha, oma järgmisse masinasse kopeerida ja versioonihaldusesse panna. _Setup_ menüü viskab su otse õigesse faili ja taaskäivitab selle, mis vajab taaskäivitamist, kui oled valmis.

Värskendused tulevad ühe käsu kaudu — _Update > Omarchy_ — mis värskendab Omarchyt ennast ja iga süsteemi paketti, tehes enne hetktõmmise. Ükski eraldi rakenduste värskendaja ei kiusa sind juhuslikel hetkedel. Vaata [värskendusi](30-updates.md).

Tarkvara tuleb paketihaldurist, mitte allalaaditud paigaldajatest.

Ja kui sulged akna, sulgub rakendus päriselt. Pole mingit macOS-i vahepealset olekut, kus programm jääb ilma akendeta edasi jooksma. `Super + W` — või `Super + Q`, kui see on sõrmemälu, millega saabusid — tähendab: läinud.

### Maci riistvaral

Omarchy jookseb hästi Inteli Macidel ning M1, M2 ja M3 Macidel koos Omarchy for Apple Siliconiga. Vaata [Maci tuge](44-mac-support.md). Ja klaviatuur on sinu vastu lahke: Omarchy ei kaardista midagi ümber ja Linux kohtleb Command-klahvi kui Superit, nii et Super istub täpselt seal, kus Cmd alati oli. Su pöial ei märkagi kolimist.

### Anna sellele kaks nädalat

Instinktid kanduvad üle kiiremini, kui arvaksid. Sirvi [kiirklahvide](07-hotkeys.md) peatükki üks kord läbi ja kui mõni seos meelest läheb, vajuta `Super + K` — see näitab sulle kõiki. See on ainus kiirklahv, mille sa tegelikult pead pähe õppima.
