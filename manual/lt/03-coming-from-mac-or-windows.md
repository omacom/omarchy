# Ateinate iš Mac arba Windows

Jei metus praleidote su macOS arba Windows, jūsų pirštai žino šimtą dalykų, kuriuos jūsų smegenys pamiršo kada nors išmokę. Šis skyrius yra vertimo sluoksnis: kur tie instinktai atsiduria Omarchy. Pačios funkcijos išsamiai aptartos kitur — čia tik žemėlapis.

### Super yra visko centras

Visa raumenų atmintis, kurią susikūrėte aplink Cmd arba Windows klavišą, persikelia į vieną klavišą: Super. Tai Windows klavišas PC klaviatūroje ir tai yra beveik kiekvieno sparčiojo klavišo Omarchy pagrindas.

Jūsų Spotlight, Raycast arba meniu Start refleksas tampa `Super + Space`. Tai atidaro Omarchy meniu, kuris paleidžia programas, keičia nuostatas, diegia programinę įrangą, fiksuoja ekraną — beveik viską. Pradėkite rašyti, kad filtruotumėte. `Super + Alt + Space` parodo visas programas viename tinklelyje, kaip tai daro Launchpad. Žr. [naršymą](04-navigation.md).

### Nėra dock ir darbalaukio piktogramų

Nėra ko spausti, kad paleistumėte dalykus, nėra piktogramų, kurias reikėtų išdėlioti darbalaukyje. Programos paleidžiamos sparčiuoju klavišu (`Super + Return` terminalui, `Super + Shift + Return` naršyklei ir `Super + K` visko, kas susieta, sąrašui) arba iš meniu. Vienintelė nuolatinė UI dalis yra [viršutinė juosta](05-the-top-bar.md), kuri apima tai, ką anksčiau už jus darė meniu juosta, sistemos dėklas ir Notification Center — ir beveik kiekvienas jos valdiklis kažką daro paspaudus kairiuoju, dešiniuoju ir viduriniu mygtuku.

### Langai išsidėsto patys

Didžiausias mąstysenos pokytis: jūs nevilkinate langų ir neprilipdote jų prie ekrano pusių. Atidarykite langą ir jis užims visą ekraną. Atidarykite antrą ir jie jį pasidalins. Niekada nereikia ištraukti lango iš po kito, nes langai nepersidengia.

Kai jums tikrai reikia plūduriuojančio lango, `Super + T` perjungia aktyvųjį iš plytelių išdėstymo (ir atgal). Bet pirmiausia duokite plytelių išdėstymui tikrą šansą — tai viso dalyko širdis. [Naršymas](04-navigation.md) jus per tai praves.

Darbo sritys atrodys pažįstamos: tai macOS Spaces arba Windows virtualūs darbalaukiai, tik jūs iš tikrųjų jomis naudositės, nes `Super + 1/2/3/4` šoka tiesiai į vieną, o `Super + Shift + 1/2/3/4` ten nusiunčia aktyvų langą. Jokios animacijos delsos, tik akimirksnio šuoliai. Tai reiškia, kad jums gali net neprireikti kelių monitorių, jei prie to buvote pripratę anksčiau.

### Kopijavimas ir įklijavimas tiesiog veikia

Mac kompiuteryje visur turėjote Cmd + C. Windows visur turėjote Ctrl + C — išskyrus terminalą, kur tai užmuša jūsų programą. Omarchy jums duoda `Super + C`, `Super + X` ir `Super + V` ir jie veikia visur, įskaitant terminalą. Nereikia mokytis atskiro reflekso apvalkalui.

Windows žmonės: jūsų Win + V iškarpinės istorija gyvena ant `Super + Ctrl + V` ir joje laikomi ir paveikslėliai, ir tekstas. Žr. [vieningą iškarpinę ir istoriją](08-unified-clipboard-history.md).

### Vertimo lentelė

| Siekiate | Omarchy |
| ------------- | ---------- |
| Spotlight / Raycast / meniu Start | `Super + Space` — Omarchy meniu |
| AirDrop | LocalSend, per `Super + Ctrl + S` — žr. [GUI](22-guis.md) |
| Cmd + Shift + 4 / Win + Shift + S | `Print Screen` — žr. [ekrano nuotraukas ir įrašymą](12-screenshots-recording.md) |
| Notification Center | Pranešimų istorija ant `Super + Shift + Alt + ,` |
| Time Machine (sistemai) | Automatiniai [sistemos momentiniai atvaizdai](47-system-snapshots.md) kiekvieno atnaujinimo metu |
| App Store / diegimo programos atsisiuntimas | _Įdiegti_ meniu arba `omarchy pkg add` — žr. [kitus paketus](29-other-packages.md) |
| System Settings / Control Panel | _Nuostatos_ meniu, kuris redaguoja paprastus konfigūracijos failus — žr. [dotfiles](31-dotfiles.md) |

### Kai kurie dalykai tikrai skiriasi

Daugelis nuostatų gyvena tekstiniuose failuose, kuriuos redaguojate, o ne skydeliuose, kuriuos spaudžiate. Tai skamba primityviai, kol nesuprantate, kad tai reiškia, jog kiekvieną pataisą galima pamatyti, nukopijuoti į kitą jūsų kompiuterį ir įdėti į versijų kontrolę. Meniu _Nuostatos_ numeta jus tiesiai į tinkamą failą ir, kai baigsite, iš naujo paleidžia tai, ką reikia paleisti iš naujo.

Atnaujinimai ateina per vieną komandą — _Atnaujinti > Omarchy_ — kuri atnaujina pačią Omarchy ir kiekvieną sistemos paketą, prieš tai padarydama momentinį atvaizdą. Jokių atskirų programų naujintuvų, erzinančių jus atsitiktinai. Žr. [atnaujinimus](30-updates.md).

Programinė įranga ateina iš paketų tvarkyklės, o ne iš atsisiųstų diegimo programų.

O kai uždarote langą, programa iš tikrųjų užsidaro. Nėra macOS limbo, kur programa toliau veikia be langų. `Super + W` — arba `Super + Q`, jei atvykote su tokia pirštų atmintimi — reiškia, kad jos nebėra.

### Mac aparatinėje įrangoje

Omarchy gerai veikia Intel Mac kompiuteriuose — žr. [Mac palaikymą](44-mac-support.md). O klaviatūra jums maloni: Omarchy nieko neperžymi, o Linux Command klavišą laiko Super, todėl Super yra ten pat, kur visada buvo Cmd. Jūsų nykštys judėjimo nepastebės.

### Duokite tam dvi savaites

Instinktai persikelia greičiau, nei manote. Vieną kartą peržvelkite skyrių apie [sparčiuosius klavišus](07-hotkeys.md) ir, kai tik užmiršite susiejimą, paspauskite `Super + K` — jis parodys jums juos visus. Tai vienintelis spartusis klavišas, kurį iš tikrųjų turite įsiminti.
