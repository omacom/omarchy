# Atėjus iš Mac arba Windows

Jei metų metus praleidote su macOS arba Windows, jūsų pirštai žino šimtą dalykų, kuriuos smegenys pamiršo kada nors išmokusios. Šis skyrius yra vertimo sluoksnis: kur tie instinktai atsiduria Omarchy. Pačios funkcijos išsamiai aprašytos kitur — čia tik žemėlapis.

### Super yra visko centras

Visa raumenų atmintis, susikaupusi aplink Cmd arba Windows klavišą, persikelia į vieną klavišą: Super. Tai Windows klavišas PC klaviatūroje, ir jis yra beveik kiekvieno Omarchy sparčiojo klavišo pagrindas.

Jūsų Spotlight, Raycast ar Start meniu refleksas tampa `Super + Space`. Tai atidaro Omarchy meniu, kuris paleidžia programas, keičia nustatymus, diegia programinę įrangą, daro ekrano kopijas — beveik viską. Pradėkite rašyti, kad filtruotumėte. `Super + Alt + Space` rodo visas programas viename tinklelyje, kaip tai daro Launchpad. Žr. [navigaciją](04-navigation.md).

### Jokių darbalaukio piktogramų, o dokas nesimaišo

Nėra piktogramų, kurias reikėtų dėlioti darbalaukyje, o dokas pasislepia, kai tik darbo srityje atsiranda langas, kol nenuvedate žymeklio prie jo ekrano krašto — dešiniojo, nebent jį perkeltumėte (žr. [navigaciją](04-navigation.md)). Programos paleidžiamos sparčiuoju klavišu (`Super + Return` terminalui, `Super + Shift + Return` naršyklei ir `Super + K` visų susietų klavišų sąrašui) arba iš meniu. Vienintelis nuolatinis sąsajos elementas yra [viršutinė juosta](05-the-top-bar.md), kuri atlieka tai, ką anksčiau jums darė meniu juosta, sistemos dėklas ir Notification Center — ir beveik kiekvienas jos valdiklis kažką daro spustelėjus kairiuoju, dešiniuoju ir viduriniuoju pelės mygtuku.

### Langai išsidėsto patys

Didžiausias mąstymo pokytis: nereikia tempti langų ar pritraukti jų prie ekrano pusių. Atidarote langą ir jis užima visą ekraną. Atidarote antrą ir jie pasidalija ekraną. Niekada nereikia žvejoti lango iš po kito, nes langai nesidengia.

Kai tikrai reikia slankiojo lango, `Super + T` iškelia aktyvų langą iš išdėstymo (ir grąžina atgal). Bet pirmiausia duokite išdėstymui realią progą — tai visos sistemos širdis. [Navigacija](04-navigation.md) jus per tai praves.

Darbo sritys atrodys pažįstamos: tai macOS Spaces arba Windows virtualūs darbalaukiai, tik čia jūs jas tikrai naudosite, nes `Super + 1/2/3/4` iškart nuveda į pasirinktą, o `Super + Shift + 1/2/3/4` ten nusiunčia aktyvų langą. Jokio animacijos vėlavimo, tik momentiniai šuoliai. Tai reiškia, kad jums gali net nebereikėti kelių monitorių, jei anksčiau buvote prie jų pripratę.

### Kopijavimas ir įklijavimas tiesiog veikia

Mac kompiuteryje visur turėjote Cmd + C. Windows sistemoje visur turėjote Ctrl + C — išskyrus terminalą, kur jis nužudo jūsų programą. Omarchy jums duoda `Super + C`, `Super + X` ir `Super + V`, ir jie veikia visur, įskaitant terminalą. Nereikia mokytis atskiro reflekso apvalkalui.

Windows žmonės: jūsų Win + V iškarpinės istorija gyvena ant `Super + Ctrl + V` ir saugo ne tik tekstą, bet ir vaizdus. Žr. [vieningą iškarpinę ir istoriją](08-unified-clipboard-history.md).

### Vertimo lentelė

| Ko siekiate | Omarchy sistemoje |
| ------------- | ---------- |
| Spotlight / Raycast / Start meniu | `Super + Space` — Omarchy meniu |
| AirDrop | LocalSend, per `Super + Ctrl + S` — žr. [grafines sąsajas](22-guis.md) |
| Cmd + Shift + 4 / Win + Shift + S | `Super + Ctrl + Alt + C` arba `Print Screen` — žr. [ekrano kopijas ir įrašymą](12-screenshots-recording.md) |
| Notification Center | Pranešimų istorija ant `Super + Shift + Alt + ,` |
| Time Machine (sistemai) | Automatinės [sistemos momentinės kopijos](47-system-snapshots.md) kiekvieno atnaujinimo metu |
| App Store / diegimo programos atsisiuntimas | _Įdiegti_ meniu arba `omarchy pkg add` — žr. [kitus paketus](29-other-packages.md) |
| System Settings / Control Panel | _Sąranka_ meniu, kuri redaguoja paprastus konfigūracijos failus — žr. [dotfiles](31-dotfiles.md) |
| Finder / File Explorer | Files, ant `Super + Shift + F` — žr. [grafines sąsajas](22-guis.md) |
| Safari / Edge | Google Chrome ant `Super + Shift + Return`; pasirinkite kitą per _Sąranka > Numatytieji > Naršyklė_ — žr. [naršykles](23-browsers.md) |
| Preview / Photos | Omaview nuotraukoms, vaizdo įrašams ir muzikai, Document Viewer PDF failams — žr. [grafines sąsajas](22-guis.md) |
| TextEdit / Notepad | Plain, ant `Super + Shift + N`; pasirinkite kitą per _Sąranka > Numatytieji > Redaktorius_ |

### Kai kurie dalykai tikrai yra kitokie

Daug nustatymų gyvena tekstiniuose failuose, kuriuos redaguojate, o ne skydeliuose, kuriuos spustelėjate. Tai skamba primityviai, kol nesuprantate, kad dėl to kiekvieną pakeitimą galima pamatyti, nukopijuoti į kitą kompiuterį ir įdėti į versijų kontrolę. Meniu _Sąranka_ nuveda jus tiesiai į reikiamą failą ir, kai baigiate, iš naujo paleidžia tai, ką reikia paleisti iš naujo.

Atnaujinimai ateina per vieną komandą — _Atnaujinti > Omarchy_ — kuri atnaujina pačią Omarchy ir kiekvieną sistemos paketą, prieš tai padarydama momentinę kopiją. Jokių atskirų programų naujintojų, kurie įkyrėtų atsitiktiniais momentais. Žr. [atnaujinimus](30-updates.md).

Programinė įranga ateina iš paketų tvarkytuvės, o ne iš atsisiųstų diegimo programų.

O kai uždarote langą, programa tikrai išsijungia. Nėra macOS limbo, kur programa toliau veikia be langų. `Super + W` — arba `Super + Q`, jei su tokia pirštų atmintimi atvykote — reiškia dingo.

### Mac aparatinėje įrangoje

Omarchy gerai veikia Intel Mac kompiuteriuose, o M1, M2 ir M3 Mac kompiuteriuose — su Omarchy for Apple Silicon. Žr. [Mac palaikymą](44-mac-support.md). O klaviatūra jums palanki: Omarchy nieko iš naujo nesusieja, o Linux laiko Command klavišą Super, todėl Super yra būtent ten, kur visada buvo Cmd. Jūsų nykštys persikėlimo nepastebės.

### Duokite tam dvi savaites

Instinktai persikelia greičiau, nei manote. Vieną kartą permeskite akimis [sparčiųjų klavišų](07-hotkeys.md) skyrių, o kai tik užmiršite susiejimą, spauskite `Super + K` — jis parodys juos visus. Tai vienintelis spartusis klavišas, kurį tikrai turite įsiminti.
