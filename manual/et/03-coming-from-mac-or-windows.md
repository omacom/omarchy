# Macilt või Windowsilt tulles

Kui oled aastaid kasutanud macOS-i või Windowsi, teavad su sõrmed sadat asja, mille õppimise su aju on juba ammu unustanud. See peatükk on tõlkekiht: kuhu need instinktid Omarchys lähevad. Funktsioone endid käsitletakse põhjalikult mujal — see on lihtsalt kaart.

### Super on kõige keskmes

Kogu lihasmälu, mille oled Cmd või Windowsi klahvi ümber üles ehitanud, kandub üle ühele klahvile: Super. See on PC klaviatuuril Windowsi klahv ja see on peaaegu iga Omarchy kiirklahvi ankur.

Sinu Spotlighti või Raycasti või Start-menüü refleksist saab `Super + Space`. See avab Omarchy menüü, mis käivitab rakendusi, muudab sätteid, installib tarkvara, jäädvustab ekraani — peaaegu kõike. Alusta tippimist, et filtreerida. `Super + Alt + Space` näitab kõiki rakendusi ühel ruudustikul, nagu Launchpad teeb. Vaata [navigatsiooni](04-navigation.md).

### Töölaual pole ikoone ja dokk ilmub ainult siis, kui hõljutad

Pole ikoone, mida töölaual paigutada, ja plaatidega tööruumis pole dokki — dokk ilmub ainult hõljuval tööruumil (vaata [navigatsiooni](04-navigation.md)). Rakendused käivituvad kiirklahviga (`Super + Return` terminali jaoks, `Super + Shift + Return` brauseri jaoks ja `Super + K` kõigi kaardistatud asjade loendi jaoks) või menüüst. Ainus püsiv kasutajaliidese osa on [ülemine riba](05-the-top-bar.md), mis katab selle, mida menüüriba, süsteemisalv ja Notification Center sinu jaoks varem tegid — ja peaaegu iga vidin sellel teeb midagi vasaku, parema ja keskmise klõpsu korral.

### Aknad paigutavad end ise

Suurim mõtteviisi muutus: sa ei lohista aknaid ringi ega haara neid ekraani poolte külge. Ava aken ja see võtab kogu ekraani. Ava teine ja nad jagavad selle. Sa ei püüa kunagi akent teise alt välja, sest aknad ei kattu.

Kui vajad tõesti hõljuvat akent, lülitab `Super + T` aktiivse akna plaatide seast välja (ja tagasi). Kuid anna plaatidele esmalt tõeline võimalus — see on kogu asja süda. [Navigatsioon](04-navigation.md) juhendab sind sellest läbi.

Tööruumid tunduvad tuttavad: need on macOS-i Spaces või Windowsi virtuaalsed töölauad, välja arvatud et sa kasutad neid tegelikult, sest `Super + 1/2/3/4` hüppab otse ühele ja `Super + Shift + 1/2/3/4` saadab aktiivse akna sinna. Pole animatsiooni viivitust, ainult kohesed hüpped. See tähendab, et sul ei pruugi isegi mitut monitori vaja olla, kui olid sellega varem harjunud.

### Kopeerimine ja kleepimine lihtsalt töötavad

Macil oli sul kõikjal Cmd + C. Windowsis oli sul kõikjal Ctrl + C — välja arvatud terminalis, kus see tapab su programmi. Omarchy annab sulle `Super + C`, `Super + X` ja `Super + V` ning need töötavad kõikjal, ka terminalis. Kesta jaoks pole vaja eraldi refleksi õppida.

Windowsi inimesed: sinu Win + V lõikelaua ajalugu elab `Super + Ctrl + V` all ja see hoiab nii pilte kui ka teksti. Vaata [ühtset lõikelauda ja ajalugu](08-unified-clipboard-history.md).

### Tõlketabel

| Mille järele haarad | Omarchys |
| ------------- | ---------- |
| Spotlight / Raycast / Start menu | `Super + Space` — Omarchy menüü |
| AirDrop | LocalSend, `Super + Ctrl + S` kaudu — vaata [GUI-sid](22-guis.md) |
| Cmd + Shift + 4 / Win + Shift + S | `Super + Ctrl + Alt + C` või `Print Screen` — vaata [ekraanipilte ja salvestamist](12-screenshots-recording.md) |
| Notification Center | Teavituste ajalugu `Super + Shift + Alt + ,` peal |
| Time Machine (süsteemi jaoks) | Automaatsed [süsteemi hetktõmmised](47-system-snapshots.md) igal värskendusel |
| App Store / installeri allalaadimine | _Install_ menüüs või `omarchy pkg add` — vaata [teisi pakette](29-other-packages.md) |
| System Settings / Control Panel | _Setup_ menüüs, mis redigeerib tavalisi konfiguratsioonifaile — vaata [dotfiles](31-dotfiles.md) |
| Finder / File Explorer | Files, `Super + Shift + F` peal — vaata [GUI-sid](22-guis.md) |
| Safari / Edge | Google Chrome `Super + Shift + Return` peal; vali teine _Setup > Defaults > Browser_ alt — vaata [brausereid](23-browsers.md) |
| Preview / Photos | Omaview piltide, video ja muusika jaoks, Document Viewer PDF-ide jaoks — vaata [GUI-sid](22-guis.md) |
| TextEdit / Notepad | Plain, `Super + Shift + N` peal; vali teine _Setup > Defaults > Editor_ alt |

### Mõned asjad on tõesti teistmoodi

Paljud sätted elavad tekstifailides, mida redigeerid, mitte paneelides, mida läbi klõpsid. See kõlab primitiivselt, kuni taipad, et see tähendab, et iga muudatust saab näha, kopeerida oma järgmisele masinale ja panna versioonihaldusse. _Setup_ menüü viib su otse õige faili juurde ja taaskäivitab selle, mida on vaja taaskäivitada, kui oled valmis.

Värskendused tulevad ühe käsu kaudu — _Update > Omarchy_ — mis värskendab Omarchyt ennast ja iga paketti süsteemis, tehes esmalt hetktõmmise. Pole eraldi rakenduste värskendajaid, mis suvalisel ajal noriksid. Vaata [värskendusi](30-updates.md).

Tarkvara tuleb paketihaldurist, mitte allalaaditud installeritest.

Ja kui sulged akna, rakendus tegelikult sulgub. Pole macOS-i limbot, kus programm jätkab akendeta töötamist. `Super + W` — või `Super + Q`, kui see on sõrmemälu, millega saabusid — tähendab kadunud.

### Maci riistvaral

Omarchy töötab hästi Intel Macidel — vaata [Maci tuge](44-mac-support.md). Ja klaviatuur on sinu vastu lahke: Omarchy ei kaardista midagi ümber ja Linux käsitleb Command klahvi kui Superit, nii et Super istub täpselt seal, kus Cmd alati oli. Su pöial ei märka kolimist.

### Anna sellele kaks nädalat

Instinktid kanduvad üle kiiremini, kui arvaksid. Sirvi [kiirklahvide](07-hotkeys.md) peatükki üks kord ja kui mõni seos meelest läheb, vajuta `Super + K` — see näitab sulle kõiki. See on ainus kiirklahv, mille pead tegelikult pähe õppima.
