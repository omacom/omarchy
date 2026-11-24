# Ateinate iš „Mac“ ar „Windows“

Jei metų metus naudojote macOS arba Windows, jūsų pirštai žino šimtą dalykų, kuriuos jūsų smegenys jau pamiršo kada nors išmokusios. Šis skyrius yra vertimo sluoksnis: kur Omarchy atsiduria tie instinktai. Pačios funkcijos išsamiai aptariamos kitur — čia tik žemėlapis.

### Super yra viso ko centras

Visa raumenų atmintis, kurią susikūrėte apie Cmd arba Windows klavišą, perkeliama į vieną klavišą: Super. Tai Windows klavišas PC klaviatūroje, ir jis yra beveik kiekvieno sparčiojo klavišo Omarchy pagrindas.

Jūsų Spotlight, Raycast ar Start meniu refleksas tampa `Super + Space`. Tai atidaro Omarchy meniu, kuris paleidžia programas, keičia nustatymus, įdiegia programinę įrangą, fiksuoja ekraną — beveik viską. Pradėkite rašyti, kad filtruotumėte. `Super + Alt + Space` rodo visas programas viename tinklelyje, kaip tai daro Launchpad. Žr. [navigacija](04-navigation.md).

### Jokių darbalaukio piktogramų, o dokas pasirodo tik plaukiojančioje darbo srityje

Jokių piktogramų, kurias reikėtų dėlioti darbalaukyje, ir jokio doko plytelėmis išdėstomoje darbo srityje — dokas pasirodo tik plaukiojančioje darbo srityje (žr. [navigacija](04-navigation.md)). Programos paleidžiamos sparčiuoju klavišu (`Super + Return` terminalui, `Super + Shift + Return` naršyklei ir `Super + K` visko, kas priskirta, sąrašui) arba iš meniu. Vienintelis nuolatinis sąsajos elementas yra [viršutinė juosta](05-the-top-bar.md), kuri atlieka tai, ką jums anksčiau darė meniu juosta, sistemos dėklas ir Notification Center — ir beveik kiekvienas jos valdiklis ką nors daro paspaudus kairįjį, dešinįjį ir vidurinį pelės mygtuką.

### Langai išsidėsto patys

Didžiausias mąstymo pokytis: jūs nevelkate langų ir nepririšate jų prie ekrano pusių. Atidarykite langą ir jis užims visą ekraną. Atidarykite antrą ir jie pasidalys ekraną. Jums niekada nereikia ištraukti lango iš po kito, nes langai nepersidengia.

Kai jums tikrai reikia plaukiojančio lango, `Super + T` iškelia aktyvų langą iš plytelių išdėstymo (ir grąžina atgal). Bet pirmiausia suteikite plytelių išdėstymui realią galimybę — tai yra viso dalyko esmė. [Navigacija](04-navigation.md) jus per tai praves.

Darbo sritys atrodys pažįstamos: tai macOS Spaces arba Windows virtualūs darbalaukiai, tik jūs jas iš tikrųjų naudosite, nes `Super + 1/2/3/4` iškart peršoka į vieną iš jų, o `Super + Shift + 1/2/3/4` nusiunčia ten aktyvų langą. Jokio animacijos vėlavimo, tik momentiniai peršokimai. Tai reiškia, kad jums gali net nebereikėti kelių monitorių, jei anksčiau buvote prie to pripratę.

### Kopijavimas ir įklijavimas tiesiog veikia

„Mac“ kompiuteryje visur turėjote Cmd + C. Windows kompiuteryje visur turėjote Ctrl + C — išskyrus terminalą, kur tai užmuša jūsų programą. Omarchy suteikia jums `Super + C`, `Super + X` ir `Super + V`, ir jie veikia visur, įskaitant terminalą. Nereikia mokytis atskiro reflekso apvalkalui.

Windows žmonės: jūsų Win + V iškarpinės istorija yra `Super + Ctrl + V`, ir joje laikomi ne tik tekstai, bet ir vaizdai. Žr. [vieninga iškarpinė ir istorija](08-unified-clipboard-history.md).

### Vertimo lentelė

| Ko ieškote | Omarchy aplinkoje |
| ------------- | ---------- |
| Spotlight / Raycast / Start meniu | `Super + Space` — Omarchy meniu |
| AirDrop | LocalSend, per `Super + Ctrl + S` — žr. [GUIs](22-guis.md) |
| Cmd + Shift + 4 / Win + Shift + S | `Super + Ctrl + Alt + C` arba `Print Screen` — žr. [ekrano nuotraukos ir įrašymas](12-screenshots-recording.md) |
| Notification Center | Pranešimų istorija per `Super + Shift + Alt + ,` |
| Time Machine (sistemai) | Automatinės [sistemos momentinės kopijos](47-system-snapshots.md) kiekvieno atnaujinimo metu |
| App Store / diegimo programos atsisiuntimas | _Install_ meniu arba `omarchy pkg add` — žr. [kiti paketai](29-other-packages.md) |
| System Settings / Control Panel | _Setup_ meniu, kuris redaguoja paprastus konfigūracijos failus — žr. [dotfiles](31-dotfiles.md) |
| Finder / File Explorer | Files, per `Super + Shift + F` — žr. [GUIs](22-guis.md) |
| Safari / Edge | Google Chrome per `Super + Shift + Return`; kitą pasirinkite _Setup > Defaults > Browser_ — žr. [naršyklės](23-browsers.md) |
| Preview / Photos | Omaview paveikslėliams, vaizdo įrašams ir muzikai, Document Viewer PDF failams — žr. [GUIs](22-guis.md) |
| TextEdit / Notepad | Plain, per `Super + Shift + N`; kitą pasirinkite _Setup > Defaults > Editor_ |

### Kai kas iš tiesų yra kitaip

Daug nustatymų yra tekstiniuose failuose, kuriuos redaguojate, o ne skydeliuose, kuriuos spustelėjate. Tai skamba primityviai, kol nesuvokiate, kad tai reiškia, jog kiekvieną pakeitimą galima pamatyti, nukopijuoti į kitą kompiuterį ir įtraukti į versijų kontrolę. _Setup_ meniu nukelia jus tiesiai į tinkamą failą ir, kai baigsite, paleidžia iš naujo tai, ką reikia paleisti iš naujo.

Atnaujinimai ateina per vieną komandą — _Update > Omarchy_ — kuri atnaujina patį Omarchy ir kiekvieną sistemos paketą, prieš tai padarydama momentinę kopiją. Jokių atskirų programų atnaujintojų, kurie jus trukdytų atsitiktiniais momentais. Žr. [atnaujinimai](30-updates.md).

Programinė įranga ateina iš paketų tvarkytuvės, o ne iš atsisiųstų diegimo programų.

O kai uždarote langą, programa iš tikrųjų išsijungia. Nėra macOS nežinios būsenos, kai programa toliau veikia be langų. `Super + W` — arba `Super + Q`, jei su tokia pirštų atmintimi atvykote — reiškia, kad jos nebėra.

### „Mac“ aparatinėje įrangoje

Omarchy gerai veikia Intel Mac kompiuteriuose, o M1, M2 ir M3 Mac kompiuteriuose — su Omarchy for Apple Silicon. Žr. [Mac palaikymas](44-mac-support.md). O klaviatūra jums palanki: Omarchy nieko neperpriskiria, o Linux laiko Command klavišą kaip Super, todėl Super yra būtent ten, kur visada buvo Cmd. Jūsų nykštys persikėlimo nepastebės.

### Skirkite tam dvi savaites

Instinktai persikelia greičiau, nei manote. Kartą peržvelkite [sparčiųjų klavišų](07-hotkeys.md) skyrių, o kai tik užstrigsite ties priskyrimu, paspauskite `Super + K` — jis parodys juos visus. Tai vienintelis spartusis klavišas, kurį iš tikrųjų turite įsiminti.
