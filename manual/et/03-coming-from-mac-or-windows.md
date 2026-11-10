# Macist või Windowsist tulles

Kui oled aastaid macOS-i või Windowsi kasutanud, teavad su sõrmed sadat asja, mille õppimise su aju on ammu unustanud. See peatükk on tõlkekiht: kuhu need instinktid Omarchys lähevad. Funktsioone endid käsitletakse põhjalikult mujal — see on lihtsalt kaart.

### Super on kõige keskmes

Kogu lihasmälu, mille oled Cmd või Windowsi klahvi ümber ehitanud, kandub üle ühele klahvile: Super. See on PC klaviatuuril Windowsi klahv ja see on peaaegu iga Omarchy kiirklahvi ankur.

Sinu Spotlighti, Raycasti või Start-menüü refleksist saab `Super + Space`. See avab Omarchy menüü, mis käivitab rakendusi, muudab sätteid, paigaldab tarkvara, jäädvustab ekraani — peaaegu kõike. Alusta tippimist, et filtreerida. `Super + Alt + Space` näitab kõiki rakendusi ühel ruudustikul, nagu Launchpad teeb. Vaata [navigatsioon](04-navigation.md).

### Dokki ega töölauaikoone ei ole

Pole midagi, millele asjade käivitamiseks klõpsata, ega ikoone, mida töölaual sättida. Rakendused käivituvad kiirklahviga (`Super + Return` terminali jaoks, `Super + Shift + Return` brauseri jaoks ja `Super + K` kõigi kaardistatud toimingute loendi jaoks) või menüüst. Ainus püsiv liideseosa on [ülemine riba](05-the-top-bar.md), mis katab selle, mida menüüriba, süsteemisalv ja Notification Center sinu jaoks varem tegid — ja peaaegu iga vidin sellel teeb midagi vasaku, parema ja keskmise klõpsu korral.

### Aknad paigutavad end ise

Suurim mõtteviisi muutus: sa ei lohista aknaid ringi ega haaku neid ekraani poolte külge. Ava aken ja see võtab kogu ekraani. Ava teine ja need jagavad selle omavahel. Sa ei püüa kunagi akent teise alt välja, sest aknad ei kattu.

Kui sul on tõesti ujuvat akent vaja, lülitab `Super + T` aktiivse akna paigutusest välja (ja tagasi). Aga anna paigutusele enne päris võimalus — see on kogu asja süda. [Navigatsioon](04-navigation.md) juhatab su sellest läbi.

Tööruumid tunduvad tuttavad: need on macOS-i Spaces või Windowsi virtuaalsed töölauad, ainult et sa ka tegelikult kasutad neid, sest `Super + 1/2/3/4` hüppab otse ühele ja `Super + Shift + 1/2/3/4` saadab aktiivse akna sinna. Ilma animatsiooniviivituseta, lihtsalt kohesed hüpped. See tähendab, et sul ei pruugi isegi mitut monitori vaja minna, kui olid sellega varem harjunud.

### Kopeerimine ja kleepimine lihtsalt töötavad

Macis oli sul kõikjal Cmd + C. Windowsis oli sul kõikjal Ctrl + C — välja arvatud terminalis, kus see tapab su programmi. Omarchy annab sulle `Super + C`, `Super + X` ja `Super + V` ning need töötavad kõikjal, ka terminalis. Kesta jaoks pole vaja eraldi refleksi õppida.

Windowsi rahvas: sinu Win + V lõikelaua ajalugu elab `Super + Ctrl + V` all ja see hoiab lisaks tekstile ka pilte. Vaata [ühendatud lõikelaud ja ajalugu](08-unified-clipboard-history.md).

### Tõlketabel

| Mille järele haarad | Omarchys |
| ------------- | ---------- |
| Spotlight / Raycast / Start-menüü | `Super + Space` — Omarchy menüü |
| AirDrop | LocalSend, `Super + Ctrl + S` kaudu — vaata [GUIs](22-guis.md) |
| Cmd + Shift + 4 / Win + Shift + S | `Super + Ctrl + Alt + C` või `Print Screen` — vaata [ekraanipildid ja salvestamine](12-screenshots-recording.md) |
| Notification Center | Teavituste ajalugu `Super + Shift + Alt + ,` all |
| Time Machine (süsteemi jaoks) | Automaatsed [süsteemitõmmised](47-system-snapshots.md) igal värskendusel |
| App Store / paigaldaja allalaadimine | _Install_ menüüs või `omarchy pkg add` — vaata [muud paketid](29-other-packages.md) |
| System Settings / Control Panel | _Setup_ menüüs, mis redigeerib lihtsaid konfiguratsioonifaile — vaata [dotfiles](31-dotfiles.md) |

### Mõned asjad ongi tõesti teisiti

Paljud sätted elavad tekstifailides, mida redigeerid, mitte paneelides, mida läbi klõpsad. See kõlab primitiivselt, kuni taipad, et see tähendab, et iga muudatust saab näha, oma järgmisse masinasse kopeerida ja versioonihaldusesse panna. Menüü _Setup_ viskab su otse õigesse faili ja taaskäivitab lõpetamisel kõik, mis taaskäivitamist vajab.

Värskendused tulevad ühe käsu kaudu — _Update > Omarchy_ — mis värskendab Omarchyt ennast ja iga süsteemi paketti, tehes enne tõmmise. Ükski rakendusesisene värskendaja ei kiusa sind suvalistel hetkedel. Vaata [värskendused](30-updates.md).

Tarkvara tuleb paketihaldurist, mitte allalaaditud paigaldajatest.

Ja kui akna sulged, sulgub rakendus ka päriselt. Pole mingit macOS-i vahepealset olekut, kus programm töötab edasi ilma akendeta. `Super + W` — või `Super + Q`, kui see on sõrmemälu, millega saabusid — tähendab läinud.

### Maci riistvaral

Omarchy töötab Intel Macidel hästi — vaata [Maci tugi](44-mac-support.md). Ja klaviatuur on sinu vastu lahke: Omarchy ei kaardista midagi ümber ja Linux käsitleb Command klahvi Superina, nii et Super istub täpselt seal, kus Cmd alati oli. Su pöial ei märkagi kolimist.

### Anna sellele kaks nädalat

Instinktid kanduvad üle kiiremini, kui arvad. Vaata [kiirklahvide](07-hotkeys.md) peatükk korra üle ja alati, kui klahvikombinatsioon meelest läheb, vajuta `Super + K` — see näitab sulle kõiki. See on ainus kiirklahv, mis sul tegelikult pähe õppida tuleb.
