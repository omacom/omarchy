# Spartieji klavišai

Visas pagrindines klavišų kombinacijas galite pamatyti paspaudę `Super + K` (Tmux kombinacijas — `Super + Alt + K`, o Herdr kombinacijas — `Super + Ctrl + K`).

## Kaip išdėstyti spartieji klavišai

Kiekvienas spartusis klavišas yra plokštumoje, kurią nustato jo modifikatoriai, ir kiekviena plokštuma turi vieną paskirtį. Dėl to spartieji klavišai nesusilieja į vieną krūvą, o jūs paprastai galite atspėti, kur kas yra.

| Plokštuma | Kas joje yra | Pavyzdžiai |
| --- | --- | --- |
| `Super + key` | Sistema: langai, darbo sritys, išdėstymai ir pagrindiniai meniu | `Super + Space` Omarchy meniu, `Super + W` uždaryti langą, `Super + F` visas ekranas |
| `Super + Shift + key` | Programos | `Super + Shift + B` naršyklė, `Super + Shift + E` el. paštas, `Super + Shift + N` redaktorius |
| `Super + Ctrl + key` | Skydeliai ir sistemos meniu | `Super + Ctrl + A` garsas, `Super + Ctrl + N` tinklas, `Super + Ctrl + C` fiksavimo meniu |
| `Super + Ctrl + Alt + key` | Greiti veiksmai ir pranešimai | `Super + Ctrl + Alt + T` rodyti laiką, `Super + Ctrl + Alt + B` akumuliatorius, `Super + Ctrl + Alt + C` ekrano nuotrauka |

Pridėjus `Alt` prie sparčiojo klavišo, gaunamas to paties dalyko variantas, niekada kažkas nesusijusio:

- `Super + Shift + B` atidaro naršyklę; `Super + Shift + Alt + B` atidaro privatų langą
- `Super + Shift + E` atidaro el. paštą; `Super + Shift + Alt + E` pradeda naują laišką
- `Super + F` įjungia visą ekraną; `Super + Alt + F` įjungia visą plotį
- `Super + Ctrl + C` atidaro fiksavimo meniu; `Super + Ctrl + Alt + C` praleidžia meniu ir padaro ekrano nuotrauką

Pridėdami spartųjį klavišą:

1. Pasirinkite plokštumą pagal tai, ką jis daro, tada pasirinkite klavišą.
2. Neperkelkite esamo sparčiojo klavišo, kad atlaisvintumėte vietą. Raskite laisvą klavišą tinkamoje plokštumoje.
3. Naudokite `Alt` tik to paties sparčiojo klavišo be jo variantui.

Keli spartieji klavišai laužo šias taisykles, nes taip patogu. `Shift` su rodykle arba `Tab` perkelia arba apgręžia, o ne atidaro programą, o `Print`, medijos klavišai, `Alt + Tab` ir `Ctrl + Alt + Del` veikia taip, kaip visur kitur. Tai išimtys, o ne pavyzdžiai, kuriuos reikėtų kopijuoti.

Jei numatytasis jums netinka (tarkime, norite `Super + Shift + S` ekrano nuotraukoms kaip Windows sistemoje), perriškite jį faile `~/.config/hypr/bindings.lua`.

## Naršymas

| Spartusis klavišas                  | Funkcija              |
| ----------------------- | --------------------- |
| `Super + Space`           | Omarchy meniu (programos ir visa kita)    |
| `Super + Alt + Space` | Programų tinklelis |
| `Super + Escape` | Sistemos meniu (pristabdyti, paleisti iš naujo ir kt.)  |
| `Super + Ctrl + L` | Užrakinti kompiuterį |
| `Super + W` or `Super + Q` | Uždaryti langą             |
| `Ctrl + Alt + Del` | Uždaryti visus langus |
| `Super + T`               | Perjungti langą tarp išklotinės / slankiojo režimų             |
| `Super + J` | Perjungti lango padėtį (horizontali / vertikali) |
| `Super + O`               | Perjungti lango iššokimą į lipnų ir slankųjį režimą |
| `Super + L`               | Perjungti dwindle, scrolling ir floating išdėstymus paeiliui |
| `Super + Alt + L`         | Perjungti išdėstymus paeiliui atvirkščia tvarka |
| `Super + P`               | Perjungti pseudo lango stilių (natūralus ar ištemptas) |
| `Super + F`                 | Įjungti visą ekraną              |
| `Super + Alt + F`                 | Įjungti visą plotį              |
| `Super + Ctrl + F`                 | Įjungti visą ekraną lango viduje              |
| `Super + 1/2/3/4`         | Pereiti į konkrečią darbo sritį fokusuotame monitoriuje |
| `Super + Tab` | Pereiti į kitą darbo sritį fokusuotame monitoriuje |
| `Super + Shift + Tab` | Pereiti į ankstesnę darbo sritį fokusuotame monitoriuje |
| `Super + Ctrl + Tab` | Pereiti į buvusią darbo sritį fokusuotame monitoriuje |
| `Super + Shift + 1/2/3/4` | Perkelti langą į darbo sritį fokusuotame monitoriuje |
| `Super + Shift + Alt + 1/2/3/4` | Perkelti langą į darbo sritį fokusuotame monitoriuje nesekant paskui |
| `Super + S` | Perjungti visą scratchpad |
| `Super + Alt + S` | Perkelti langą į visą scratchpad |
| `Super + Grave` | Perjungti Quake konsolę |
| `Super + Shift + Grave` | Perkelti langą į Quake konsolę |
| `Super + Shift + Ctrl + Arrows` | Perkelti langą į monitorių ta kryptimi |
| `Super + Shift + Alt + Arrows` | Perkelti darbo sritį į monitorių ta kryptimi |
| `Super + Arrow`  | Perkelti fokusą į langą rodyklės kryptimi, ekrano krašte pereinant į monitorių toje pusėje |
| `Super + Shift + Arrow`  | Sukeisti langą su kitu rodyklės kryptimi, įskaitant esantį monitoriuje toje pusėje |
| `Super + Minus` | Išplėsti langą į kairę |
| `Super + Equal` | Susiaurinti langą į kairę |
| `Super + Shift + Minus` | Sumažinti langą į viršų |
| `Super + Shift + Equal` | Išplėsti langą žemyn |
| `Super + Alt + Minus/Equal` | Tas pats dydžio keitimas mažesniais žingsniais |
| `Super + Ctrl + Minus/Equal` | Tas pats dydžio keitimas didesniais žingsniais |
| `Super + Alt + Home` | Išsaugoti lango plotį |
| `Super + Home` | Atkurti išsaugotą lango plotį |
| `Super + Left Mouse` | Vilkti langą |
| `Super + Right Mouse` | Keisti lango dydį |
| `Super + Scroll Wheel` | Slinkti per darbo sritis fokusuotame monitoriuje |
| `Super + G`               | Perjungti langų grupavimą      |
| `Super + Alt + G`               | Iškelti langą iš grupės      |
| `Super + Alt + Tab`               | Perjungti langus grupėje paeiliui      |
| `Super + Alt + Shift + Tab`               | Perjungti langus grupėje paeiliui atgal      |
| `Super + Alt + Scroll Wheel` | Perjungti langus grupėje paeiliui |
| `Super + Alt + 1/2/3/4/5`               | Pereiti į konkretų langą grupėje      |
| `Super + Alt + Arrow`  | Perkelti langą į grupę rodyklės kryptimi, įskaitant esantį monitoriuje toje pusėje |
| `Super + Ctrl + Left/Right`  | Judėti tarp langų išklotinės grupės viduje |
| `Super + Ctrl + Z` | Priartinti ekraną (kartokite, kad priartintumėte daugiau) |
| `Super + Ctrl + Alt + Z` | Visiškai atitolinti ekraną |
| `Super + /` | Pereiti į priekį per monitoriaus mastelio parinktis |
| `Super + Alt + /` | Pereiti atgal per monitoriaus mastelio parinktis |
| `Alt + Tab` | Perjungti langus aktyvioje darbo srityje į priekį paeiliui |
| `Alt + Shift + Tab` | Perjungti langus aktyvioje darbo srityje atgal paeiliui |
| `Ctrl + Alt + Tab`| Perjungti fokusą per monitorius į priekį paeiliui |
| `Ctrl + Alt + Shift + Tab`| Perjungti fokusą per monitorius atgal paeiliui |

Dydžio keitimo spartieji klavišai naudoja fizinius klavišus `code:20` ir `code:21` (XKB `<AE11>` ir `<AE12>`), nepriklausomai nuo ant klaviatūros atspausdintų simbolių. JAV klaviatūrose šie klavišai yra `-` ir `=`; japoniškose (JIS) klaviatūrose jie yra `-` ir `^`; ispaniškose klaviatūrose jie yra `'` ir `¡`. JIS klaviatūroje `Super + ^` yra `Super + Equal`, o `Super + Shift + -` (kuriuo įvedama `=`) yra `Super + Shift + Minus`.

## Sistemos valdikliai

| Spartusis klavišas                  | Funkcija              |
| ----------------------- | --------------------- |
| `Super + Ctrl + A`           | Garso skydelis    |
| `Super + Ctrl + B`           | Bluetooth skydelis    |
| `Super + Ctrl + N`           | Wi-Fi / tinklo skydelis    |
| `Super + Ctrl + D`           | Ekrano skydelis    |
| `Super + Ctrl + P`           | Maitinimo skydelis    |
| `Super + Ctrl + X`           | Agentų skydelis    |
| `Super + Ctrl + Alt + D`           | Kalendoriaus skydelis    |
| `Super + Ctrl + Alt + E`           | Pasaulio laikrodžio skydelis    |
| `Super + Ctrl + 1-9`           | Perjungti juostos skydelį pagal padėtį    |
| `Super + Ctrl + S` | Bendrinimo meniu (per LocalSend) |
| `Super + Ctrl + C` | Fiksavimo valdikliai (ekrano nuotrauka / įrašymas / parinkiklis) |
| `Super + Ctrl + O` | Perjungimo meniu |
| `Super + Ctrl + H` | Aparatūros meniu |
| `Super + Ctrl + E` | Jaustukų parinkiklis |
| `Super + Ctrl + .` | Perkonvertuoti mediją |
| `Super + Shift + Ctrl + A` | Pasirinkti AI agentą |

## Reguliavimai

| Spartusis klavišas                  | Funkcija              |
| ----------------------- | --------------------- |
| `Shift + Brightness Up` | Didžiausias ekrano ryškumas |
| `Shift + Brightness Down` | Mažiausias ekrano ryškumas |
| `Alt + Brightness Up/Down` | Tikslūs 1% ryškumo pakeitimai |
| `Alt + Volume Up/Down` | Tikslūs 1% garsumo pakeitimai |
| `Keyboard Brightness Up/Down` | Klaviatūros apšvietimas ryškesnis / tamsesnis |
| `Keyboard Backlight` | Perjungti klaviatūros apšvietimo lygius paeiliui |
| `Alt + Play` | Kitas takelis |
| `Alt + Shift + Play` | Ankstesnis takelis |

## Programų paleidimas

| Spartusis klavišas                  | Funkcija              |
| ----------------------- | --------------------- |
| `Super + Return`           | Terminalas    |
| `Super + Alt + Return` | Tmux terminalas |
| `Super + Ctrl + Return` | Herdr (agentų tvarkyklė) |
| `Super + Shift + Return`           | Naršyklė    |
| `Super + Shift + Alt + B`           | Naršyklė (privatus / inkognito)    |
| `Super + Shift + F`           | Failų tvarkyklė    |
| `Super + Shift + Alt + F`           | Failų tvarkyklė terminalo cwd aplanke    |
| `Super + Shift + M`           | Muzika (Spotify)    |
| `Super + Shift + Alt + M`           | Muzika (cliamp)    |
| `Super + Shift + /`           | Slaptažodžių tvarkyklė (1password)    |
| `Super + Shift + Q`           | Skaičiuotuvas (Omacalc)    |
| `Super + Shift + T`           | Veikla (btop)    |
| `Super + Shift + N`           | Redaktorius (Neovim)  |
| `Super + Shift + C`           | Kalendorius ([HEY](https://hey.com/))  |
| `Super + Shift + E`           | El. paštas ([HEY](https://hey.com/))  |
| `Super + Shift + Alt + E`           | Naujas el. laiškas ([HEY](https://hey.com/))  |
| `Super + Shift + A`           | AI (ChatGPT)  |
| `Super + Shift + Alt + A`           | AI (Grok)  |
| `Super + Shift + G`           | Susirašinėjimas (Signal)  |
| `Super + Shift + P`           | Google Photos  |
| `Super + Shift + S`           | Google Maps  |
| `Super + Shift + Alt + G`           | Susirašinėjimas (WhatsApp)  |
| `Super + Shift + Ctrl + G`           | Susirašinėjimas (Google)  |
| `Super + Shift + O`           | Obsidian  |
| `Super + Shift + W`           | Rašymas (Omawrite)  |
| `Super + Shift + X`           | X |
| `Super + Shift + Alt + X`           | X Compose |
| `Super + Shift + Y`           | YouTube |

Keiskite / pridėkite kombinacijas faile `~/.config/hypr/bindings.lua`.

## Universali iškarpinė

| Spartusis klavišas                  | Funkcija              |
| ----------------------- | --------------------- |
| `Super + A`           | Pasirinkti viską programose, kurios palaiko `Ctrl + A`    |
| `Super + C`           | Kopijuoti    |
| `Super + X`           | Iškirpti (ne terminale)    |
| `Super + V`           | Įklijuoti    |
| `Super + Ctrl + V`           | Iškarpinės tvarkyklė    |

Paprastai Linux sistemoje terminale kopijuoti ir įklijuoti reikia `Ctrl + Shift + C/V`, o visur kitur — `Ctrl + C/V`. Šie Omarchy suvienodinti iškarpinės spartieji klavišai veikia visur.

## Fiksavimas

| Spartusis klavišas              | Funkcija                       |
| ------------------- | ------------------------------ |
| `Print Screen`            | Ekrano nuotrauka                      |
| `Super + Ctrl + Alt + C`            | Ekrano nuotrauka (tas pats kadras, klaviatūroms be Print Screen klavišo) |
| `Super + Ctrl + C` | Fiksavimo meniu |
| `Alt + Print Screen`            | Ekrano įrašymas                     |
| `Super + Print Screen` | Spalvų parinkiklis |
| `Super + Ctrl + Print Screen` | Teksto išgavimas į iškarpinę |
| `Super + Alt + [` | Sumažinti internetinės kameros perdangą įrašant |
| `Super + Alt + ]` | Padidinti internetinės kameros perdangą įrašant |
| `Alt + Shift + L` | Kopijuoti dabartinį URL iš žiniatinklio programos ar naršyklės |
| `Alt + Shift + D` | Atsisiųsti dabartiniame puslapyje esantį vaizdo įrašą į `~/Videos` |
| `Alt + Space` | Pradėti / sustabdyti diktavimą (reikia _Setup > Defaults > Dictation_) |
| `Right Alt` | Laikyti, kad diktuotumėte (reikia _Setup > Defaults > Dictation_) |

Įrašant ekraną, spartusis klavišas pirmiausia paklausia, kokio garso norite, tada pradeda įrašyti. Paspauskite jį dar kartą, kad sustabdytumėte. Išsamesnės informacijos žr. [ekrano nuotraukos ir įrašymas](12-screenshots-recording.md).

Visos fiksavimo parinktys taip pat pasiekiamos Omarchy meniu (`Super + Space`) skiltyje _Trigger > Capture_.

## Pranešimai

| Spartusis klavišas                  | Funkcija              |
| ----------------------- | --------------------- |
| `Super + ,` | Atlikti veiksmą su naujausiu pranešimu: atidaryti jį arba paspausti vienintelį jo mygtuką, pasirinkti iš jo parinkčių arba atmesti jį, kai jis jų neturi  |
| `Super + Shift + ,` | Atmesti visus pranešimus |
| `Super + Ctrl + ,` | Valdyti pranešimus klaviatūra  |
| `Super + Alt + ,` | Atmesti naujausią pranešimą  |
| `Super + Shift + Alt + ,` | Atidaryti pranešimų istoriją  |
| `Super + Ctrl + Alt + ,` | Perjungti pranešimų nutildymą  |

## Stilius

| Spartusis klavišas                  | Funkcija              |
| ----------------------- | --------------------- |
| `Super + Ctrl + T` | Pasirinkti naują temą (taip pat `Super + Ctrl + Shift + Space`) |
| `Super + Ctrl + W` | Pasirinkti temos foną (taip pat `Super + Ctrl + Space`) |
| `Super + Backspace` | Perjungti lango skaidrumą |
| `Super + Ctrl + Backspace` | Perjungti vieno lango kvadratinį kraštinių santykį |

Papildomi fono paveikslėliai yra `~/.config/omarchy/backgrounds/<theme name>`. Taip pat pasiekiama Omarchy meniu skiltyje _Install > Style > Background_.

Visos stiliaus parinktys taip pat pasiekiamos Omarchy meniu (`Super + Space`) skiltyje _Style_.

## Perjungimai

| Spartusis klavišas                  | Funkcija              |
| ----------------------- | --------------------- |
| `Super + Ctrl + I` | Perjungti užrakinimą esant neaktyvumui |
| `Super + Ctrl + Delete` | Įjungti / išjungti nešiojamojo kompiuterio ekraną |
| `Super + Ctrl + Alt + Delete` | Perjungti nešiojamojo kompiuterio ekrano veidrodinį atspindėjimą |
| `Super + Shift + Space` | Perjungti viršutinę juostą  |
| `Shift + Mute` | Pereiti prie kitos garso išvesties |
| `Shift + Play` | Pereiti prie kito medijos šaltinio |
| `Super + Shift + Backspace` | Perjungti langų tarpus |
| `Super + Ctrl + Alt + F` | Perjungti viso ekrano darbalaukį (viršutinė juosta + langų tarpai) |

## Priminimai

| Spartusis klavišas                  | Funkcija              |
| ----------------------- | --------------------- |
| `Super + Ctrl + R` | Nustatyti priminimą  |
| `Super + Ctrl + Alt + R` | Žiūrėti visus priminimus  |
| `Super + Ctrl + Shift + R` | Išvalyti visus priminimus  |

## Informacija

| Spartusis klavišas                  | Funkcija              |
| ----------------------- | --------------------- |
| `Super + Ctrl + Alt + T` | Rodyti laiką kaip pranešimą  |
| `Super + Ctrl + Alt + B` | Rodyti akumuliatorių kaip pranešimą  |
| `Super + Ctrl + Alt + W` | Perjungti orus kaip pranešimą  |

## Tmux

Prefikso klavišas yra `Ctrl + Space` (taip pat veikia `Ctrl + B`). Šias kombinacijas galite keisti faile `~/.config/tmux/tmux.conf`.

### Sritys

| Spartusis klavišas                  | Funkcija              |
| ----------------------- | --------------------- |
| `Prefix + v` | Padalyti sritį šalia (vertikaliai) |
| `Prefix + h` | Padalyti sritį apačioje (horizontaliai) |
| `Prefix + x` | Sunaikinti sritį |
| `Prefix + z` | Perjungti srities priartinimą (visas ekranas) |
| `Alt + Enter` | Padalyti sritį apačioje (be prefikso) |
| `Alt + Shift + Enter` | Padalyti sritį šalia (be prefikso) |
| `Alt + Escape` | Sunaikinti sritį (be prefikso) |
| `Ctrl + Alt + Arrows` | Judėti tarp sričių |
| `Ctrl + Alt + Shift + Arrows` | Keisti sričių dydį |

### Langai

| Spartusis klavišas                  | Funkcija              |
| ----------------------- | --------------------- |
| `Prefix + c` | Naujas langas |
| `Prefix + k` | Sunaikinti langą |
| `Prefix + r` | Pervardyti langą |
| `Alt + 1-9` | Pereiti į konkretų langą |
| `Alt + Arrow Left/Right` | Judėti tarp langų |
| `Alt + Shift + Arrow Left/Right` | Perkelti langą į kairę / dešinę |

### Sesijos

| Spartusis klavišas                  | Funkcija              |
| ----------------------- | --------------------- |
| `Prefix + C` | Nauja sesija |
| `Prefix + K` | Sunaikinti sesiją |
| `Prefix + R` | Pervardyti sesiją |
| `Prefix + N` | Kita sesija |
| `Prefix + P` | Ankstesnė sesija |
| `Alt + Arrow Up/Down` | Judėti tarp sesijų |
| `Prefix + s` | Pateikti sesijų sąrašą |
| `Prefix + d` | Atsijungti nuo sesijos |

### Kopijavimo režimas (vi-style)

| Spartusis klavišas                  | Funkcija              |
| ----------------------- | --------------------- |
| `Prefix + [` | Įjungti kopijavimo režimą |
| `v` | Pradėti pasirinkimą (kopijavimo režime) |
| `y` | Kopijuoti pasirinkimą (kopijavimo režime) |

### Bendra

| Spartusis klavišas                  | Funkcija              |
| ----------------------- | --------------------- |
| `Prefix + q` | Įkelti konfigūraciją iš naujo |
| `Prefix + ?` | Rodyti Tmux klavišų kombinacijas |
| `Prefix + :` | Komandų eilutė |

### Tmux išdėstymo funkcijos

Šios funkcijos turi būti vykdomos Tmux sesijos viduje.

| Komanda | Funkcija |
| ------- | -------- |
| `tdl <ai> [<second_ai>]` | Sukurti kūrimo išdėstymą su redaktoriumi, AI ir terminalu |
| `tdlm <ai> [<second_ai>]` | Sukurti kūrimo išdėstymą kiekvienam pakatalogiui |
| `tsl <count> <command>` | Sukurti kelių sričių spiečiaus išdėstymą |

## Ghostty Terminal

Ghostty terminalas įdiegiamas Omarchy meniu naudojant _Install > Terminal_.

| Spartusis klavišas                  | Funkcija              |
| ----------------------- | --------------------- |
| `Ctrl + Shift + E` | Naujas padalijimas apačioje |
| `Ctrl + Shift + O` | Naujas padalijimas šalia |
| `Ctrl + Alt + Arrows` | Judėti tarp padalijimų |
| `Super + Ctrl + Shift + Arrows` | Keisti padalijimo dydį 10 eilučių |
| `Super + Ctrl + Shift + Alt + Arrows` | Keisti padalijimo dydį 100 eilučių |
| `Ctrl + Shift + T` | Naujas skirtukas  |
| `Ctrl + Shift + Arrows` | Judėti tarp skirtukų |
| `Alt + Numbers` | Pereiti į konkretų skirtuką |
| `Shift + Pg Up/Down` | Slinkti istoriją |
| `Ctrl + Left mouse` | Atidaryti nuorodą naršyklėje |

## Failų tvarkyklė

| Spartusis klavišas              | Funkcija                       |
| ------------------- | ------------------------------ |
| `Ctrl + L`            | Eiti į kelią                     |
| `Space`               | Peržiūrėti failą (rodyklėmis naršoma) |
| `Alt + Up`       | Eiti į pirminį aplanką        |

## Neovim (su lazyvim)

### Naršymas

| Spartusis klavišas                   | Funkcija                        |
| ------------------------ | ------------------------------- |
| `Space`                    | Rodyti komandų parinktis            |
| `Space Space`              | Atidaryti failą naudojant neaiškią paiešką      |
| `Space E`                  | Perjungti šoninę juostą                  |
| `Space G G`                | Rodyti git valdiklius               |
| `Space S G`                | Ieškoti failo turinyje             |
| `Ctrl + W W`               | Pereiti tarp šoninės juostos ir redaktoriaus |
| `Ctrl + Left/right arrow`  | Keisti šoninės juostos dydį          |
| `Shift + H`                      | Eiti į kairįjį failo skirtuką             |
| `Shift + L`                      | Eiti į dešinįjį failo skirtuką            |
| `Space B D`                | Uždaryti failo skirtuką                  |

### Esant šoninėje juostoje

| Spartusis klavišas                   | Funkcija                        |
| ------------------------ | ------------------------------- |
| `A`                        | Pridėti naują failą pirminiame kataloge      |
| `Shift + A`                | Pridėti naują pakatalogį pirminiame kataloge    |
| `D`                        | Ištrinti pažymėtą failą / katalogą     |
| `M`                        | Perkelti pažymėtą failą / katalogą       |
| `R`                        | Pervardyti pažymėtą failą / katalogą     |
| `?`                        | Rodyti visų komandų žinyną      |

[Žiūrėkite visus Neovim sparčiuosius klavišus, kuriuos sukonfigūravo LazyVim](https://www.lazyvim.org/keymaps).

## Greitieji jaustukai

Galite naudoti `Super + Ctrl + E`, kad būtų parodytas visas jaustukų parinkiklis, kuris įdės pasirinktą jaustuką į iškarpinę, arba galite naudoti šias greitosios prieigos parinktis.

| Spartusis klavišas       | EM | Užuomina       |
| ------------ | -- | ---------- |
| `Shift + CapsLock M S` | 😄 | šypsena      |
| `Shift + CapsLock M C` | 😂 | verkti        |
| `Shift + CapsLock M L` | 😍 | meilė       |
| `Shift + CapsLock M V` | ✌️ | pergalė    |
| `Shift + CapsLock M H` | ❤️ | širdis      |
| `Shift + CapsLock M Y` | 👍 | taip        |
| `Shift + CapsLock M N` | 👎 | ne         |
| `Shift + CapsLock M F` | 🖕 | fuck       |
| `Shift + CapsLock M W` | 🤞 | noras       |
| `Shift + CapsLock M R` | 🤘 | rokas       |
| `Shift + CapsLock M K` | 😘 | bučinys       |
| `Shift + CapsLock M E` | 🙄 | akių vartymas    |
| `Shift + CapsLock M I` | 😉 | mirktelėjimas       |
| `Shift + CapsLock M P` | 🙏 | melstis |
| `Shift + CapsLock M D` | 🤤 | seilėjimasis      |
| `Shift + CapsLock M M` | 💰 | pinigai      |
| `Shift + CapsLock M X` | 🎉 | šventė |
| `Shift + CapsLock M 1` | 💯 | 100%       |
| `Shift + CapsLock M T` | 🥂 | tostas      |
| `Shift + CapsLock M O` |👌 | ok |
| `Shift + CapsLock M G` |👋 | pasisveikinimas |
| `Shift + CapsLock M A` |💪 | ranka |
| `Shift + CapsLock M B` |🤯 | sprogdinantis |

## Greitieji užbaigimai

| Spartusis klavišas       | Užbaigimas       |
| ------------ |  ---------- |
| `Shift + CapsLock Space Space` | — (ilgas brūkšnys)   |
| `Shift + CapsLock Space N` | Jūsų vardas (kaip įvestas sąrankos metu)  |
| `Shift + CapsLock Space E` | Jūsų el. paštas (kaip įvestas sąrankos metu)  |

Galite pridėti daugiau savų, redaguodami `~/.XCompose`, tada terminale paleisdami `omarchy-restart-xcompose`, kad pakeitimai būtų pritaikyti.
