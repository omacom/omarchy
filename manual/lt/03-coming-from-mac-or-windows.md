# Jei ateinate iš Mac arba Windows

Jei praleidote metus su macOS arba Windows, jūsų pirštai žino šimtą dalykų, kurių jūsų smegenys jau pamiršo, kad kada nors išmoko. Šis skyrius yra vertimo sluoksnis: kur tie instinktai nukeliauja Omarchy aplinkoje. Pačios funkcijos išsamiai aprašytos kitur — čia tik žemėlapis.

### Super yra visa ko centras

Visa raumenų atmintis, kurią susikūrėte aplink Cmd arba Windows klavišą, persikelia į vieną klavišą: Super. Tai Windows klavišas PC klaviatūroje, ir jis yra beveik kiekvieno sparčiojo klavišo pagrindas Omarchy aplinkoje.

Jūsų Spotlight, Raycast ar Start meniu refleksas tampa `Super + Space`. Tai atidaro Omarchy meniu, kuris paleidžia programas, keičia nustatymus, diegia programinę įrangą, fiksuoja ekraną — beveik viską. Pradėkite rašyti, kad filtruotumėte. `Super + Alt + Space` rodo visas programas viename tinklelyje, kaip tai daro Launchpad. Žr. [navigaciją](04-navigation.md).

### Nėra darbalaukio piktogramų, o dokas atsiranda tik plaukiojančiose darbo srityse

Jokių piktogramų, kurias reikėtų dėlioti darbalaukyje, ir jokio doko plytelinio išdėstymo darbo srityje — dokas atsiranda tik plaukiojančioje darbo srityje (žr. [navigaciją](04-navigation.md)). Programos paleidžiamos sparčiuoju klavišu (`Super + Return` terminalui, `Super + Shift + Return` naršyklei ir `Super + K` visų priskirtų klavišų sąrašui) arba iš meniu. Vienintelė nuolatinė sąsajos dalis yra [viršutinė juosta](05-the-top-bar.md), kuri atstoja tai, ką anksčiau jums darė meniu juosta, sistemos dėklas ir Notification Center — ir beveik kiekvienas jos valdiklis ką nors daro spustelėjus kairiuoju, dešiniuoju ir viduriniuoju mygtuku.

### Langai patys susidėlioja

Didžiausias mąstymo pokytis: jūs nevelkate langų iš vietos į vietą ir nepritvirtinate jų prie ekrano pusių. Atidarote langą ir jis užima visą ekraną. Atidarote antrą ir jie pasidalija ekraną. Niekada nereikia traukti lango iš po kito, nes langai nesidengia.

Kai jums tikrai reikia plaukiojančio lango, `Super + T` perjungia aktyvų langą iš plytelinio išdėstymo (ir atgal). Bet pirmiausia duokite plyteliniam išdėstymui tikrą šansą — tai yra viso reikalo širdis. [Navigacijos](04-navigation.md) skyrius jus per tai praves.

Darbo sritys atrodys pažįstamos: tai macOS Spaces arba Windows virtualūs darbalaukiai, tik skirtumas tas, kad jūs iš tikrųjų jas naudosite, nes `Super + 1/2/3/4` iškart peršoka į pasirinktą, o `Super + Shift + 1/2/3/4` ten nusiunčia aktyvų langą. Jokio animacijos vėlavimo, tik akimirksnio šuoliai. Tai reiškia, kad jums gali net nebereikėti kelių monitorių, jei anksčiau buvote prie to pripratę.

### Kopijavimas ir įklijavimas tiesiog veikia

Mac kompiuteryje visur turėjote Cmd + C. Windows kompiuteryje visur turėjote Ctrl + C — išskyrus terminalą, kur tai užmuša jūsų programą. Omarchy jums duoda `Super + C`, `Super + X` ir `Super + V`, ir jie veikia visur, įskaitant terminalą. Jokio atskiro reflekso, kurio reikėtų mokytis apvalkalui.

Windows naudotojams: jūsų Win + V iškarpinės istorija yra ant `Super + Ctrl + V`, ir joje saugomi ne tik tekstai, bet ir vaizdai. Žr. [vieningą iškarpinę ir istoriją](08-unified-clipboard-history.md).

### Vertimo lentelė

| Ko ieškote | Omarchy aplinkoje |
| ------------- | ---------- |
| Spotlight / Raycast / Start menu | `Super + Space` — Omarchy meniu |
| AirDrop | LocalSend, per `Super + Ctrl + S` — žr. [GUIs](22-guis.md) |
| Cmd + Shift + 4 / Win + Shift + S | `Super + Ctrl + Alt + C` arba `Print Screen` — žr. [ekrano kopijas ir įrašymą](12-screenshots-recording.md) |
| Notification Center | Pranešimų istorija per `Super + Shift + Alt + ,` |
| Time Machine (sistemai) | Automatinės [sistemos momentinės kopijos](47-system-snapshots.md) kaskart atnaujinant |
| App Store / diegimo programos atsisiuntimas | _Install_ meniu arba `omarchy pkg add` — žr. [kitus paketus](29-other-packages.md) |
| System Settings / Control Panel | _Setup_ meniu, kuris redaguoja paprastus konfigūracijos failus — žr. [dotfiles](31-dotfiles.md) |
| Finder / File Explorer | Files, per `Super + Shift + F` — žr. [GUIs](22-guis.md) |
| Safari / Edge | Google Chrome per `Super + Shift + Return`; kitą pasirinkite skiltyje _Setup > Defaults > Browser_ — žr. [naršykles](23-browsers.md) |
| Preview / Photos | Omaview paveikslėliams, vaizdo ir muzikos įrašams, Document Viewer PDF failams — žr. [GUIs](22-guis.md) |
| TextEdit / Notepad | Plain, per `Super + Shift + N`; kitą pasirinkite skiltyje _Setup > Defaults > Editor_ |

### Kai kurie dalykai tikrai yra kitokie

Daug nustatymų gyvena tekstiniuose failuose, kuriuos redaguojate, o ne skydeliuose, kuriuose spaudinėjate mygtukus. Tai skamba primityviai, kol nesuprantate, kad tai reiškia, jog kiekvieną pakeitimą galima pamatyti, nukopijuoti į kitą kompiuterį ir įdėti į versijų kontrolę. _Setup_ meniu jus nukreipia tiesiai į reikiamą failą ir, kai baigiate, iš naujo paleidžia tai, ką reikia paleisti iš naujo.

Atnaujinimai ateina per vieną komandą — _Update > Omarchy_ — kuri atnaujina patį Omarchy ir kiekvieną sistemos paketą, prieš tai padarydama momentinę kopiją. Jokių atskirų programų atnaujintojų, kurie priekabiautų prie jūsų atsitiktiniais momentais. Žr. [atnaujinimus](30-updates.md).

Programinė įranga ateina iš paketų tvarkytuvės, o ne iš atsisiųstų diegimo programų.

O kai uždarote langą, programa iš tikrųjų išsijungia. Nėra macOS būsenos, kai programa toliau veikia be jokių langų. `Super + W` — arba `Super + Q`, jei atvykote su tokia pirštų atmintimi — reiškia dingo.

### Mac aparatinėje įrangoje

Omarchy gerai veikia Intel Mac kompiuteriuose — žr. [Mac palaikymą](44-mac-support.md). O klaviatūra jums palanki: Omarchy nieko iš naujo nepriskiria, o Linux laiko Command klavišą Super, todėl Super yra būtent ten, kur visada buvo Cmd. Jūsų nykštys nė nepastebės persikėlimo.

### Duokite tam dvi savaites

Instinktai persikelia greičiau, nei manote. Vieną kartą permeskite akimis [sparčiųjų klavišų](07-hotkeys.md) skyrių, o kai tik užstrigsite ties kokiu nors priskyrimu, spauskite `Super + K` — jis parodys juos visus. Tai vienintelis spartusis klavišas, kurį iš tikrųjų turite įsiminti.
