# Perėjus iš Mac ar Windows

Jei metų metus praleidai su macOS ar Windows, tavo pirštai žino šimtą dalykų, kurių smegenys jau pamiršo, kad kada nors išmoko. Šis skyrius yra vertimo sluoksnis: kur tie instinktai atsiduria Omarchy. Pačios funkcijos išsamiai aprašytos kitur — čia tik žemėlapis.

### Super yra visko centras

Visa raumenų atmintis, kurią susikūrei aplink Cmd ar Windows klavišą, perkeliama į vieną klavišą: Super. Tai Windows klavišas PC klaviatūroje, ir jis yra beveik visų Omarchy sparčiųjų klavišų pagrindas.

Tavo Spotlight, Raycast ar Start meniu refleksas tampa `Super + Space`. Tai atidaro Omarchy meniu, kuris paleidžia programas, keičia nustatymus, diegia programinę įrangą, daro ekrano kopijas — beveik viską. Pradėk rašyti, kad filtruotum. `Super + Alt + Space` rodo visas programas viename tinklelyje, kaip tai daro Launchpad. Žr. [navigaciją](04-navigation.md).

### Jokių darbalaukio piktogramų, o dokas nesimaišo

Nėra piktogramų, kurias reikėtų dėlioti darbalaukyje, o dokas pasislepia, kai tik darbo srityje atsiranda langas, kol nustumi žymeklį prie jo ekrano krašto — apatinio, nebent jį perkeltum (žr. [navigaciją](04-navigation.md)). Programos paleidžiamos sparčiuoju klavišu (`Super + Return` terminalui, `Super + Shift + Return` naršyklei ir `Super + K` visko, kas priskirta, sąrašui) arba iš meniu. Vienintelis nuolatinis sąsajos elementas yra [viršutinė juosta](05-the-top-bar.md), kuri apima tai, ką anksčiau tau darė meniu juosta, sistemos dėklas ir Notification Center — ir beveik kiekvienas jos valdiklis kažką daro paspaudus kairįjį, dešinįjį ir vidurinį mygtuką.

### Langai išsidėsto patys

Didžiausias mąstymo pokytis: nereikia tempti langų ar pritraukti jų prie ekrano pusių. Atidarai langą ir jis užima visą ekraną. Atidarai antrą ir jie pasidalija ekraną. Niekada nereikia žvejoti lango iš po kito, nes langai nesidengia.

Kai tikrai reikia plaukiojančio lango, `Super + T` iškelia aktyvųjį iš plytelių išdėstymo (ir grąžina atgal). Bet pirmiausia duok plytelių išdėstymui tikrą šansą — tai yra visko esmė. [Navigacija](04-navigation.md) viską paaiškina.

Darbo sritys atrodys pažįstamos: tai macOS Spaces arba Windows virtualūs darbalaukiai, tik tu tikrai jomis naudosis, nes `Super + 1/2/3/4` iškart peršoka į vieną, o `Super + Shift + 1/2/3/4` ten nusiunčia aktyvų langą. Jokio animacijos vėlavimo, tik momentiniai šuoliai. Tai reiškia, kad tau galbūt net nereikės kelių monitorių, jei buvai prie to pripratęs anksčiau.

### Kopijavimas ir įklijavimas tiesiog veikia

Mac kompiuteryje visur turėjai Cmd + C. Windows kompiuteryje visur turėjai Ctrl + C — išskyrus terminalą, kur tai užmuša tavo programą. Omarchy duoda tau `Super + C`, `Super + X` ir `Super + V`, ir jie veikia visur, įskaitant terminalą. Nereikia mokytis atskiro reflekso apvalkalui.

Windows žmonės: tavo Win + V iškarpinės istorija gyvena ant `Super + Ctrl + V`, ir joje laikomi ir vaizdai, ir tekstas. Žr. [vieningą iškarpinę ir istoriją](08-unified-clipboard-history.md).

### Vertimo lentelė

| Ko ieškai | Omarchy sistemoje |
| ------------- | ---------- |
| Spotlight / Raycast / Start meniu | `Super + Space` — Omarchy meniu |
| AirDrop | LocalSend, per `Super + Ctrl + S` — žr. [GUI](22-guis.md) |
| Cmd + Shift + 4 / Win + Shift + S | `Super + Ctrl + Alt + C` arba `Print Screen` — žr. [ekrano kopijas ir įrašymą](12-screenshots-recording.md) |
| Notification Center | Pranešimų istorija ant `Super + Shift + Alt + ,` |
| Time Machine (sistemai) | Automatinės [sistemos momentinės kopijos](47-system-snapshots.md) su kiekvienu atnaujinimu |
| App Store / diegimo programos atsisiuntimas | _Install_ meniu arba `omarchy pkg add` — žr. [kitus paketus](29-other-packages.md) |
| System Settings / Control Panel | _Setup_ meniu, kuris redaguoja paprastus konfigūracijos failus — žr. [dotfiles](31-dotfiles.md) |
| Finder / File Explorer | Files, ant `Super + Shift + F` — žr. [GUI](22-guis.md) |
| Safari / Edge | Google Chrome ant `Super + Shift + Return`; pasirink kitą skiltyje _Setup > Defaults > Browser_ — žr. [naršykles](23-browsers.md) |
| Preview / Photos | Omaview paveikslėliams, vaizdo įrašams ir muzikai, Document Viewer PDF failams — žr. [GUI](22-guis.md) |
| TextEdit / Notepad | Plain, ant `Super + Shift + N`; pasirink kitą skiltyje _Setup > Defaults > Editor_ |

### Kai kurie dalykai tikrai kitokie

Daug nustatymų gyvena tekstiniuose failuose, kuriuos redaguoji, o ne skydeliuose, kuriuos spaudinėji. Tai skamba primityviai, kol nesupranti, kad tai reiškia, jog kiekvieną pakeitimą galima pamatyti, nukopijuoti į kitą savo kompiuterį ir laikyti versijų valdyme. _Setup_ meniu iškart nuveda tave į reikiamą failą ir, kai baigi, iš naujo paleidžia tai, ką reikia paleisti iš naujo.

Atnaujinimai ateina per vieną komandą — _Update > Omarchy_ — kuri atnaujina pačią Omarchy ir kiekvieną sistemos paketą, prieš tai padarydama momentinę kopiją. Jokių atskirų programų atnaujintojų, kurie erzintų atsitiktiniais momentais. Žr. [atnaujinimus](30-updates.md).

Programinė įranga ateina iš paketų tvarkyklės, o ne iš atsisiųstų diegimo programų.

Ir kai uždarai langą, programa tikrai išsijungia. Nėra macOS limbo, kur programa toliau veikia be langų. `Super + W` — arba `Super + Q`, jei atėjai su ta pirštų atmintimi — reiškia dingo.

### Mac aparatinė įranga

Omarchy gerai veikia Intel Mac kompiuteriuose ir M1, M2 bei M3 Mac kompiuteriuose su Omarchy for Apple Silicon. Žr. [Mac palaikymą](44-mac-support.md). Ir klaviatūra tau palanki: Omarchy nieko neperpriskiria, o Linux laiko Command klavišą Super klavišu, todėl Super yra tiksliai ten, kur visada buvo Cmd. Tavo nykštys persikėlimo nepastebės.

### Duok tam dvi savaites

Instinktai persikelia greičiau, nei manai. Kartą peržvelk [sparčiųjų klavišų](07-hotkeys.md) skyrių, o kai tik užmiršti priskyrimą, spausk `Super + K` — jis parodo juos visus. Tai vienintelis spartusis klavišas, kurį tikrai turi įsiminti.
