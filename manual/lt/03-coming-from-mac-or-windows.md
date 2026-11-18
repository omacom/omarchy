# Atkeliavus iš „Mac“ ar „Windows“

Jei metų metus naudojote macOS arba Windows, jūsų pirštai žino šimtą dalykų, kuriuos jūsų smegenys jau pamiršo kada nors išmokusios. Šis skyrius yra vertimo sluoksnis: kur tie įpročiai atsiduria Omarchy. Pačios funkcijos išsamiai aprašytos kitur — čia tik žemėlapis.

### Super yra viso ko centras

Visa raumenų atmintis, susikaupusi aplink Cmd arba Windows klavišą, persikelia į vieną klavišą: Super. Tai Windows klavišas PC klaviatūroje, ir jis yra beveik kiekvieno sparčiojo klavišo Omarchy pagrindas.

Jūsų Spotlight, Raycast ar Pradžios meniu refleksas tampa `Super + Space`. Tai atidaro Omarchy meniu, kuris paleidžia programas, keičia nustatymus, diegia programinę įrangą, daro ekrano nuotraukas — praktiškai viską. Pradėkite rašyti, kad filtruotumėte. `Super + Alt + Space` rodo visas programas viename tinklelyje, kaip tai daro Launchpad. Žr. [navigacija](04-navigation.md).

### Nėra nei doko, nei darbalaukio piktogramų

Nieko, ką spustelėjus būtų galima paleisti programas, jokių piktogramų, kurias reikėtų dėlioti darbalaukyje. Programos paleidžiamos sparčiuoju klavišu (`Super + Return` — terminalas, `Super + Shift + Return` — naršyklė, o `Super + K` — visko, kas priskirta, sąrašas) arba iš meniu. Vienintelis nuolatinis sąsajos elementas yra [viršutinė juosta](05-the-top-bar.md), kuri atlieka tai, ką anksčiau jums darė meniu juosta, sistemos dėklas ir Notification Center — ir beveik kiekvienas jos valdiklis ką nors daro spustelėjus kairiuoju, dešiniuoju ir viduriniu pelės mygtuku.

### Langai išsidėsto patys

Didžiausias mąstymo pokytis: jūs netampote langų ir neprilipdote jų prie ekrano pusių. Atidarote langą ir jis užima visą ekraną. Atidarote antrą ir jie pasidalija ekraną. Niekada nereikia iš po kito ištraukti lango, nes langai nesidengia.

Kai jums tikrai reikia plūduriuojančio lango, `Super + T` iškelia aktyvų langą iš plytelių išdėstymo (ir grąžina atgal). Bet pirmiausia duokite plytelių išdėstymui realią progą — tai visos sistemos širdis. [Navigacija](04-navigation.md) jus per tai praves.

Darbo sritys atrodys pažįstamos: tai macOS Spaces arba Windows virtualūs darbalaukiai, tik čia jūs jas iš tiesų naudosite, nes `Super + 1/2/3/4` iškart peršoka į norimą, o `Super + Shift + 1/2/3/4` ten nusiunčia aktyvų langą. Jokio animacijos vėlavimo, tik momentiniai peršokimai. Tai reiškia, kad jums gali net nebereikėti kelių monitorių, jei anksčiau buvote prie to pripratę.

### Kopijavimas ir įklijavimas tiesiog veikia

„Mac“ kompiuteryje visur turėjote Cmd + C. Windows kompiuteryje visur turėjote Ctrl + C — išskyrus terminalą, kur tai nužudo jūsų programą. Omarchy jums duoda `Super + C`, `Super + X` ir `Super + V`, ir jie veikia visur, įskaitant terminalą. Nereikia mokytis atskiro reflekso apvalkalui.

Windows žmonėms: jūsų Win + V mainų srities istorija gyvena ant `Super + Ctrl + V` ir saugo ne tik tekstą, bet ir vaizdus. Žr. [vieninga mainų sritis ir istorija](08-unified-clipboard-history.md).

### Vertimo lentelė

| Ko ieškote | Omarchy sistemoje |
| ------------- | ---------- |
| Spotlight / Raycast / Pradžios meniu | `Super + Space` — Omarchy meniu |
| AirDrop | LocalSend, per `Super + Ctrl + S` — žr. [grafinės sąsajos](22-guis.md) |
| Cmd + Shift + 4 / Win + Shift + S | `Super + Ctrl + Alt + C` arba `Print Screen` — žr. [ekrano nuotraukos ir įrašymas](12-screenshots-recording.md) |
| Notification Center | Pranešimų istorija ant `Super + Shift + Alt + ,` |
| Time Machine (sistemai) | Automatinės [sistemos momentinės kopijos](47-system-snapshots.md) kiekvieno atnaujinimo metu |
| App Store / diegimo programos atsisiuntimas | _Install_ meniu arba `omarchy pkg add` — žr. [kiti paketai](29-other-packages.md) |
| System Settings / Control Panel | _Setup_ meniu, kuris redaguoja paprastus konfigūracijos failus — žr. [dotfiles](31-dotfiles.md) |

### Kai kurie dalykai iš tiesų kitokie

Daug nustatymų gyvena tekstiniuose failuose, kuriuos redaguojate, o ne skydeliuose, kuriuos spustelėjate. Tai skamba primityviai, kol nesuprantate, kad tai reiškia, jog kiekvieną pakeitimą galima pamatyti, nukopijuoti į kitą savo kompiuterį ir laikyti versijų valdyme. _Setup_ meniu jus iškart nukelia prie tinkamo failo ir, kai baigiate, iš naujo paleidžia viską, ką reikia paleisti iš naujo.

Atnaujinimai ateina per vieną komandą — _Update > Omarchy_ — kuri atnaujina pačią Omarchy ir kiekvieną sistemos paketą, prieš tai padarydama momentinę kopiją. Jokių atskirų programų naujintojų, erzinančių jus atsitiktiniais momentais. Žr. [atnaujinimai](30-updates.md).

Programinė įranga ateina iš paketų tvarkyklės, o ne iš atsisiųstų diegimo programų.

Ir kai uždarote langą, programa iš tiesų išsijungia. Nėra jokio macOS limbo, kur programa toliau veikia be langų. `Super + W` — arba `Super + Q`, jei atėjote su tokia pirštų atmintimi — reiškia dingo.

### „Mac“ aparatinėje įrangoje

Omarchy gerai veikia Intel Mac kompiuteriuose — žr. [Mac palaikymas](44-mac-support.md). Ir klaviatūra jums palanki: Omarchy nieko neperpriskiria, o Linux Command klavišą laiko Super, taigi Super yra būtent ten, kur visada buvo Cmd. Jūsų nykštys persikėlimo net nepastebės.

### Duokite tam dvi savaites

Įpročiai persikelia greičiau, nei manote. Kartą peržvelkite [sparčiųjų klavišų](07-hotkeys.md) skyrių, o kai užmiršite priskyrimą, spauskite `Super + K` — jis jums parodys juos visus. Tai vienintelis spartusis klavišas, kurį iš tiesų turite įsiminti.
