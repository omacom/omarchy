# Macilt või Windowsist tulles

Kui oled aastaid veetnud macOS-is või Windowsis, teavad su sõrmed sadat asja, mille õppimise su aju on juba unustanud. See peatükk on tõlkekiht: kuhu need instinktid Omarchys lähevad. Funktsioone endid käsitletakse põhjalikult mujal — see siin on lihtsalt kaart.

### Super on kõige keskmes

Kogu lihasmälu, mille oled üles ehitanud Cmd või Windowsi klahvi ümber, kandub üle ühele klahvile: Super. See on PC-klaviatuuril Windowsi klahv ja see on peaaegu iga Omarchy kiirklahvi ankur.

Sinu Spotlighti või Raycasti või Start-menüü refleksist saab `Super + Space`. See avab Omarchy menüü, mis käivitab rakendusi, muudab seadeid, paigaldab tarkvara, jäädvustab ekraani — peaaegu kõike. Filtreerimiseks hakka lihtsalt kirjutama. `Super + Alt + Space` näitab kõiki rakendusi ühel ruudustikul, nagu Launchpad seda teeb. Vt [navigeerimine](04-navigation.md).

### Töölaual pole ikoone ja dokk püsib eemal

Töölaual pole ikoone, mida sättida, ja dokk peidab end, kui tööruumis on aken, kuni lükkad kursori selle ekraaniserva poole, parema poole, kui sa seda ei ole mujale liigutanud (vt [navigeerimine](04-navigation.md)). Rakendused käivituvad kiirklahviga (`Super + Return` terminali jaoks, `Super + Shift + Return` brauseri jaoks ja `Super + K` kõige kaardistatu loendi jaoks) või menüüst. Ainus püsiv kasutajaliidese osa on [ülemine riba](05-the-top-bar.md), mis katab selle, mida menüüriba, süsteemisalv ja Notification Center sinu jaoks varem tegid — ja peaaegu iga vidin sellel teeb midagi vasaku, parema ja keskmise klõpsu peale.

### Aknad paigutavad end ise

Suurim mõtteviisi muutus: sa ei lohista aknaid ringi ega haagi neid ekraanipoolte külge. Ava aken ja see võtab enda alla kogu ekraani. Ava teine ja nad jagavad selle omavahel. Sa ei pea kunagi akent teise alt välja õngitsema, sest aknad ei kattu.

Kui sul on tõesti ujuvat akent vaja, lülitab `Super + T` aktiivse akna paigutusest välja (ja tagasi). Aga anna paigutusele enne päris võimalus — see on kogu asja süda. [Navigeerimine](04-navigation.md) juhatab su sellest läbi.

Tööruumid tunduvad tuttavad: need on macOS-i Spaces või Windowsi virtuaalsed töölauad, ainult et sa hakkad neid päriselt kasutama, sest `Super + 1/2/3/4` hüppab otse ühte ja `Super + Shift + 1/2/3/4` saadab aktiivse akna sinna. Ilma animatsiooniviivituseta, lihtsalt hetkelised hüpped. See tähendab, et sul ei pruugi isegi mitut monitori vaja olla, kui sa olid sellega varem harjunud.

### Kopeerimine ja kleepimine lihtsalt töötavad

Macil oli sul igal pool Cmd + C. Windowsis oli sul igal pool Ctrl + C — välja arvatud terminalis, kus see tapab su programmi. Omarchy annab sulle `Super + C`, `Super + X` ja `Super + V` ning need töötavad igal pool, ka terminalis. Kesta jaoks pole vaja eraldi refleksi õppida.

Windowsi rahvas: sinu Win + V lõikelaua ajalugu elab klahvikombinatsioonil `Super + Ctrl + V` ja see hoiab lisaks tekstile ka pilte. Vt [ühendatud lõikelaud ja ajalugu](08-unified-clipboard-history.md).

### Tõlketabel

| Mille järele haarad | Omarchys |
| ------------- | ---------- |
| Spotlight / Raycast / Start menu | `Super + Space` — Omarchy menüü |
| AirDrop | LocalSend, `Super + Ctrl + S` kaudu — vt [graafilised liidesed](22-guis.md) |
| Cmd + Shift + 4 / Win + Shift + S | `Super + Ctrl + Alt + C` või `Print Screen` — vt [ekraanipildid ja salvestamine](12-screenshots-recording.md) |
| Notification Center | Teavituste ajalugu klahvikombinatsioonil `Super + Shift + Alt + ,` |
| Time Machine (süsteemi jaoks) | Automaatsed [süsteemi hetktõmmised](47-system-snapshots.md) iga värskenduse ajal |
| App Store / paigaldaja allalaadimine | Menüüs _Install_ või `omarchy pkg add` — vt [muud paketid](29-other-packages.md) |
| System Settings / Control Panel | Menüüs _Setup_, mis redigeerib lihtsaid konfiguratsioonifaile — vt [dotfailid](31-dotfiles.md) |
| Finder / File Explorer | Files, klahvikombinatsioonil `Super + Shift + F` — vt [graafilised liidesed](22-guis.md) |
| Safari / Edge | Google Chrome klahvikombinatsioonil `Super + Shift + Return`; vali teine valikus _Setup > Defaults > Browser_ — vt [brauserid](23-browsers.md) |
| Preview / Photos | Omaview piltide, video ja muusika jaoks, Document Viewer PDF-ide jaoks — vt [graafilised liidesed](22-guis.md) |
| TextEdit / Notepad | Plain, klahvikombinatsioonil `Super + Shift + N`; vali teine valikus _Setup > Defaults > Editor_ |

### Mõned asjad on tõesti teistmoodi

Paljud seaded elavad tekstifailides, mida sa redigeerid, mitte paneelides, mida sa läbi klõpsid. See kõlab primitiivselt, kuni taipad, et see tähendab, et iga muudatust saab näha, oma järgmisse masinasse kopeerida ja versioonihaldusse panna. _Setup_ menüü viib su otse õigesse faili ja taaskäivitab lõpetamisel kõik, mis taaskäivitamist vajab.

Värskendused tulevad ühe käsu kaudu — _Update > Omarchy_ —, mis värskendab Omarchyt ennast ja iga paketti süsteemis, tehes enne hetktõmmise. Ükski rakendusesisene värskendaja ei tüüta sind suvalisel ajal. Vt [värskendused](30-updates.md).

Tarkvara tuleb paketihaldurist, mitte allalaaditud paigaldajatest.

Ja kui sa akna sulged, siis rakendus ka päriselt sulgub. Pole macOS-i vahepealset olekut, kus programm töötab edasi ilma akendeta. `Super + W` — või `Super + Q`, kui see on sõrmemälu, millega sa saabusid — tähendab läinud.

### Maci riistvaral

Omarchy töötab hästi Inteli Macidel ning M1, M2 ja M3 Macidel koos Omarchy for Apple Siliconiga. Vt [Maci tugi](44-mac-support.md). Ja klaviatuur on sinu vastu lahke: Omarchy ei kaardista midagi ümber ja Linux käsitleb Command-klahvi Superina, nii et Super istub täpselt seal, kus Cmd alati oli. Su pöial ei märkagi kolimist.

### Anna sellele kaks nädalat

Instinktid kanduvad üle kiiremini, kui arvad. Sirvi [kiirklahvide](07-hotkeys.md) peatükki üks kord ja kui sul mõni seos meelest läheb, vajuta `Super + K` — see näitab sulle kõiki. See on ainus kiirklahv, mille sa päriselt pead pähe õppima.
