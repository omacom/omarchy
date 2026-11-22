# Macilt või Windowsilt tulles

Kui oled veetnud aastaid macOS-i või Windowsi juures, teavad su sõrmed sadat asja, mille õppimise su aju on juba unustanud. See peatükk on tõlkekiht: kuhu need instinktid Omarchys lähevad. Funktsioone endid käsitletakse põhjalikult mujal — see siin on lihtsalt kaart.

### Super on kõige keskmes

Kogu lihasmälu, mille oled Cmd või Windowsi klahvi ümber üles ehitanud, kandub üle ühele klahvile: Super. See on PC klaviatuuril Windowsi klahv ja see on peaaegu iga Omarchy kiirklahvi ankur.

Su Spotlighti või Raycasti või Start-menüü refleks muutub klahvikombinatsiooniks `Super + Space`. See avab Omarchy menüü, mis käivitab rakendusi, muudab seadeid, installib tarkvara, jäädvustab ekraani — peaaegu kõike. Filtreerimiseks hakka lihtsalt kirjutama. `Super + Alt + Space` näitab kõiki rakendusi ühel ruudustikul, nii nagu Launchpad seda teeb. Vt [navigeerimine](04-navigation.md).

### Töölauaikoone pole ja dokk ilmub ainult hõljudes

Töölaual pole ikoone, mida korrastada, ja paanitaval tööruumil pole dokki — dokk ilmub ainult hõljuval tööruumil (vt [navigeerimine](04-navigation.md)). Rakendused käivituvad kiirklahviga (`Super + Return` terminali jaoks, `Super + Shift + Return` brauseri jaoks ja `Super + K` kõige kaardistatu loendi jaoks) või menüüst. Ainus püsiv kasutajaliidese osa on [ülemine riba](05-the-top-bar.md), mis katab selle, mida menüüriba, süsteemisalv ja Notification Center sinu jaoks varem tegid — ja peaaegu iga vidin sellel teeb midagi vasaku, parema ja keskmise klõpsuga.

### Aknad paigutavad end ise

Suurim mõtteviisi muutus: sa ei lohista aknaid ringi ega haagi neid ekraani poolte külge. Ava aken ja see võtab enda alla kogu ekraani. Ava teine ja need jagavad selle. Sa ei püüa kunagi üht akent teise alt välja, sest aknad ei kattu.

Kui sul on tõesti hõljuvat akent vaja, lülitab `Super + T` aktiivse akna paanimisest välja (ja tagasi). Aga anna paanimisele esmalt tõeline võimalus — see on kogu asja süda. [Navigeerimine](04-navigation.md) juhatab sind sellest läbi.

Tööruumid tunduvad tuttavad: need on macOS-i Spaces või Windowsi virtuaalsed töölauad, ainult et sa ka tegelikult kasutad neid, sest `Super + 1/2/3/4` hüppab otse ühele ja `Super + Shift + 1/2/3/4` saadab aktiivse akna sinna. Animatsiooniviivitust pole, ainult vahetud hüpped. See tähendab, et sul ei pruugi isegi mitut monitori vaja minna, kui sa sellega varem harjunud olid.

### Kopeerimine ja kleepimine lihtsalt töötavad

Macil oli sul kõikjal Cmd + C. Windowsil oli sul kõikjal Ctrl + C — välja arvatud terminalis, kus see tapab su programmi. Omarchy annab sulle klahvid `Super + C`, `Super + X` ja `Super + V` ja need töötavad kõikjal, ka terminalis. Kesta jaoks pole eraldi refleksi õppida.

Windowsist tulijad: teie Win + V lõikelaua ajalugu elab klahvikombinatsioonil `Super + Ctrl + V` ja see hoiab lisaks tekstile ka pilte. Vt [ühtne lõikelaud ja ajalugu](08-unified-clipboard-history.md).

### Tõlketabel

| Mille järele sa haarad | Omarchys |
| ------------- | ---------- |
| Spotlight / Raycast / Start menu | `Super + Space` — Omarchy menüü |
| AirDrop | LocalSend, `Super + Ctrl + S` kaudu — vt [GUIs](22-guis.md) |
| Cmd + Shift + 4 / Win + Shift + S | `Super + Ctrl + Alt + C` või `Print Screen` — vt [ekraanipildid ja salvestamine](12-screenshots-recording.md) |
| Notification Center | Teavituste ajalugu klahvikombinatsioonil `Super + Shift + Alt + ,` |
| Time Machine (süsteemi jaoks) | Automaatsed [süsteemi hetktõmmised](47-system-snapshots.md) iga värskenduse korral |
| App Store / installeri allalaadimine | Menüüs _Install_ või `omarchy pkg add` — vt [muud paketid](29-other-packages.md) |
| System Settings / Control Panel | Menüüs _Setup_, mis redigeerib lihtsaid konfiguratsioonifaile — vt [dotfailid](31-dotfiles.md) |
| Finder / File Explorer | Files, klahvikombinatsioonil `Super + Shift + F` — vt [GUIs](22-guis.md) |
| Safari / Edge | Google Chrome klahvikombinatsioonil `Super + Shift + Return`; vali teine asukohas _Setup > Defaults > Browser_ — vt [brauserid](23-browsers.md) |
| Preview / Photos | Omaview piltide, video ja muusika jaoks, Document Viewer PDF-ide jaoks — vt [GUIs](22-guis.md) |
| TextEdit / Notepad | Plain, klahvikombinatsioonil `Super + Shift + N`; vali teine asukohas _Setup > Defaults > Editor_ |

### Mõned asjad on tõesti teistmoodi

Paljud seaded elavad tekstifailides, mida sa redigeerid, mitte paneelides, milles sa ringi klõpsid. See kõlab primitiivselt, kuni taipad, et see tähendab, et iga muudatust saab näha, oma järgmisele masinale kopeerida ja versioonihaldusse panna. _Setup_ menüü viskab su otse õigesse faili ja taaskäivitab lõpetamisel kõik, mis taaskäivitamist vajab.

Värskendused tulevad ühe käsu kaudu — _Update > Omarchy_ — mis värskendab Omarchyt ennast ja iga süsteemi paketti, tehes esmalt hetktõmmise. Ükski rakendusepõhine värskendaja ei kiusa sind suvalistel hetkedel. Vt [värskendused](30-updates.md).

Tarkvara tuleb paketihaldurist, mitte alla laaditud installeritest.

Ja kui sa akna sulged, siis rakendus ka tõesti sulgub. Pole macOS-i vahepealset olekut, kus programm jääb ilma akendeta edasi töötama. `Super + W` — või `Super + Q`, kui see on sõrmemälu, millega sa saabusid — tähendab läinud.

### Maci riistvaral

Omarchy töötab hästi Inteli Macidel ning M1, M2 ja M3 Macidel Omarchy for Apple Siliconiga. Vt [Maci tugi](44-mac-support.md). Ja klaviatuur on sinu vastu lahke: Omarchy ei kaardista midagi ümber ja Linux käsitleb Command klahvi Superina, nii et Super istub täpselt seal, kus Cmd alati oli. Su pöial ei märka kolimist.

### Anna sellele kaks nädalat

Instinktid kanduvad üle kiiremini, kui arvad. Sirvi [kiirklahvid](07-hotkeys.md) peatükki üks kord ja kui sul mõne seose peal mõte tühjaks läheb, vajuta `Super + K` — see näitab sulle kõiki neid. See on ainus kiirklahv, mille sa tegelikult pead pähe õppima.
