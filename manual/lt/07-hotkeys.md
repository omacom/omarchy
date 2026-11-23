# Spartieji klavišai

Visus pagrindinius klavišų susiejimus galite pamatyti paspaudę `Super + K` (Tmux susiejimus – `Super + Alt + K`, o Herdr susiejimus – `Super + Ctrl + K`).

## Kaip išdėstyti spartieji klavišai

Kiekvienas spartusis klavišas yra tam tikroje plokštumoje, kurią nustato jo modifikatoriai, ir kiekviena plokštuma turi vieną paskirtį. Būtent tai neleidžia spartiesiems klavišams susilieti tarpusavyje, todėl paprastai galite atspėti, kur kas yra.

| Plokštuma | Kas joje yra | Pavyzdžiai |
| --- | --- | --- |
| `Super + key` | Sistema: langai, darbo sritys, išdėstymai ir pagrindiniai meniu | `Super + Space` Omarchy meniu, `Super + W` uždaryti langą, `Super + F` viso ekrano režimas |
| `Super + Shift + key` | Programos | `Super + Shift + B` naršyklė, `Super + Shift + E` el. paštas, `Super + Shift + N` redaktorius |
| `Super + Ctrl + key` | Skydeliai ir sistemos meniu | `Super + Ctrl + A` garsas, `Super + Ctrl + N` tinklas, `Super + Ctrl + C` fiksavimo meniu |
| `Super + Ctrl + Alt + key` | Greiti veiksmai ir pranešimai | `Super + Ctrl + Alt + T` rodyti laiką, `Super + Ctrl + Alt + B` akumuliatorius, `Super + Ctrl + Alt + C` ekrano nuotrauka |

Pridėjus `Alt` prie sparčiojo klavišo, gaunate to paties dalyko variantą, niekada nieko nesusijusio:

- `Super + Shift + B` atidaro naršyklę; `Super + Shift + Alt + B` atidaro privatų langą
- `Super + Shift + E` atidaro el. paštą; `Super + Shift + Alt + E` pradeda naują laišką
- `Super + F` įjungia viso ekrano režimą; `Super + Alt + F` įjungia viso pločio režimą
- `Super + Ctrl + C` atidaro fiksavimo meniu; `Super + Ctrl + Alt + C` praleidžia meniu ir padaro ekrano nuotrauką

Kai pridedate spartųjį klavišą:

1. Pasirinkite plokštumą pagal tai, ką jis daro, tada pasirinkite klavišą.
2. Neperkelkite esamo sparčiojo klavišo, kad atlaisvintumėte vietos. Raskite laisvą klavišą tinkamoje plokštumoje.
3. `Alt` naudokite tik sparčiojo klavišo be jo variantui.

Keletas sparčiųjų klavišų pažeidžia šias taisykles, nes taip patogiau. `Shift` su rodykle arba `Tab` perkelia arba veikia atvirkščiai, o ne atidaro programą, o `Print`, medijos klavišai, `Alt + Tab` ir `Ctrl + Alt + Del` veikia taip, kaip ir visur kitur. Tai išimtys, o ne pavyzdžiai, kuriuos reikėtų kopijuoti.

Jei numatytasis variantas jums netinka (tarkime, norite `Super + Shift + S` ekrano nuotraukoms kaip Windows), pakeiskite susiejimą faile `~/.config/hypr/bindings.lua`.

## Naršymas

| Spartusis klavišas                  | Funkcija              |
| ----------------------- | --------------------- |
| `Super + Space`           | Omarchy meniu (programos ir visa kita)    |
| `Super + Alt + Space` | Programų tinklelis |
| `Super + Escape` | Sistemos meniu (pristabdyti, paleisti iš naujo ir kt.)  |
| `Super + Ctrl + L` | Užrakinti kompiuterį |
| `Super + W` or `Super + Q` | Uždaryti langą             |
| `Ctrl + Alt + Del` | Uždaryti visus langus |
| `Super + K` | Rodyti visus sparčiuosius klavišus |
| `Super + Alt + K` | Rodyti tmux sparčiuosius klavišus |
| `Super + Ctrl + K` | Rodyti herdr sparčiuosius klavišus |
| `Super + M` | Sumažinti langą į doką |
| `Super + T`               | Perjungti langą tarp išklotinės ir slankiojo režimo             |
| `Super + J` | Perjungti lango padėtį (horizontali / vertikali) |
| `Super + O`               | Perjungti lango pervedimą į prisegtą slankųjį režimą (sticky'n'floating) |
| `Super + L`               | Perjungti dwindle, scrolling ir floating išdėstymus iš eilės |
| `Super + Alt + L`         | Perjungti išdėstymus atvirkštine tvarka |
| `Super + P`               | Perjungti pseudo lango stilių (natūralus ar ištemptas) |
| `Super + F`                 | Įjungti viso ekrano režimą              |
| `Super + Alt + F`                 | Įjungti viso pločio režimą              |
| `Super + Ctrl + F`                 | Įjungti viso ekrano režimą lango viduje              |
| `Super + 1…9/0`         | Pereiti į nurodytą darbo sritį (0 yra 10) fokusuotame monitoriuje |
| `Super + Tab` | Pereiti į kitą darbo sritį fokusuotame monitoriuje |
| `Super + Shift + Tab` | Pereiti į ankstesnę darbo sritį fokusuotame monitoriuje |
| `Super + Ctrl + Tab` | Pereiti į buvusią darbo sritį fokusuotame monitoriuje |
| `Super + Shift + 1…9/0` | Perkelti langą į darbo sritį fokusuotame monitoriuje |
| `Super + Shift + Alt + 1…9/0` | Perkelti langą į darbo sritį fokusuotame monitoriuje nesekant paskui |
| `Super + S` | Perjungti visą laikinąją sritį (scratchpad) |
| `Super + Alt + S` | Perkelti langą į visą laikinąją sritį |
| `Super + Grave` | Perjungti Quake konsolę |
| `Super + Shift + Grave` | Perkelti langą į Quake konsolę |
| `Super + Shift + Ctrl + Arrows` | Perkelti langą į monitorių ta kryptimi |
| `Super + Shift + Alt + Arrows` | Perkelti darbo sritį į monitorių ta kryptimi |
| `Super + Arrow`  | Perkelti fokusą į langą rodyklės kryptimi, ekrano krašte pereinant į tos pusės monitorių |
| `Super + Shift + Arrow`  | Sukeisti langą su kitu rodyklės kryptimi, įskaitant langą tos pusės monitoriuje |
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
| `Super + Alt + Tab`               | Perjungti langus grupėje iš eilės      |
| `Super + Alt + Shift + Tab`               | Perjungti langus grupėje atvirkštine tvarka      |
| `Super + Alt + Scroll Wheel` | Perjungti langus grupėje iš eilės |
| `Super + Alt + 1/2/3/4/5`               | Pereiti į nurodytą langą grupėje      |
| `Super + Alt + Arrow`  | Perkelti langą į grupę rodyklės kryptimi, įskaitant langą tos pusės monitoriuje |
| `Super + Ctrl + Left/Right`  | Judėti tarp langų išklotinės grupėje |
| `Super + Ctrl + Z` | Priartinti ekraną (kartokite, kad priartintumėte dar labiau) |
| `Super + Ctrl + Alt + Z` | Visiškai atitolinti ekraną |
| `Super + /` | Pereiti į priekį per monitoriaus mastelio parinktis |
| `Super + Alt + /` | Pereiti atgal per monitoriaus mastelio parinktis |
| `Alt + Tab` | Perjungti langus aktyvioje darbo srityje į priekį |
| `Alt + Shift + Tab` | Perjungti langus aktyvioje darbo srityje atvirkštine tvarka |
| `Ctrl + Alt + Tab`| Perjungti fokusą per monitorius į priekį |
| `Ctrl + Alt + Shift + Tab`| Perjungti fokusą per monitorius atgal |
| `Super + I` | Perjungti įvesties kalbą (kai yra daugiau nei vienas išdėstymas ar įvesties būdas) |
| `Super + Shift + I` | Perjungti įvesties kalbą atgal |

Jutikliniame skydelyje trijų ir keturių pirštų perbraukimai perjungia darbo sritis, perkelia langus ir atidaro meniu bei Quake konsolę; gestus žr. [klaviatūra, pelė ir jutiklinis skydelis](34-keyboard-mouse-trackpad.md).

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
| `Super + Ctrl + Alt + X`           | Vietinių modelių skydelis    |
| `Super + Ctrl + Alt + D`           | Kalendoriaus skydelis    |
| `Super + Ctrl + Alt + E`           | Pasaulio laikrodžio skydelis    |
| `Super + Ctrl + 1-9`           | Perjungti juostos skydelį pagal padėtį    |
| `Super + Ctrl + S` | Bendrinimo meniu (per LocalSend) |
| `Super + Ctrl + C` | Fiksavimo valdikliai (ekrano nuotrauka / įrašymas / parinkiklis) |
| `Super + Ctrl + O` | Perjungti meniu |
| `Super + Ctrl + H` | Aparatinės įrangos meniu |
| `Super + Ctrl + E` | Jaustukų parinkiklis |
| `Super + Ctrl + .` | Transkoduoti mediją |
| `Super + Shift + Ctrl + A` | Paleisti numatytąjį agentą |
| `Power` key | Sistemos meniu |
| `Super + Shift + Copilot` key | Omarchy meniu |

## Koregavimai

| Spartusis klavišas                  | Funkcija              |
| ----------------------- | --------------------- |
| `Shift + Brightness Up` | Didžiausias ekrano ryškumas |
| `Shift + Brightness Down` | Mažiausias ekrano ryškumas |
| `Alt + Brightness Up/Down` | Tikslūs 1 % ryškumo pakeitimai |
| `Alt + Volume Up/Down` | Tikslūs 1 % garsumo pakeitimai |
| `Keyboard Brightness Up/Down` | Ryškesnis / blankesnis klaviatūros apšvietimas |
| `Keyboard Backlight` | Perjungti klaviatūros apšvietimo lygius iš eilės |
| `Ctrl + Brightness Up/Down` | Ryškesnis / blankesnis klaviatūros apšvietimas klaviatūrose be atskirų klavišų |
| `Mic Mute` | Nutildyti mikrofoną |
| `Shift + Mute` | Perjungti garso išvestį |
| `Touchpad Toggle` | Įjungti arba išjungti jutiklinį skydelį |
| `Display` key | Perjungti darbo srities išdėstymą iš eilės |
| `Alt + Play` | Kitas takelis |
| `Alt + Shift + Play` | Ankstesnis takelis |

## Programų paleidimas

| Spartusis klavišas                  | Funkcija              |
| ----------------------- | --------------------- |
| `Super + Return`           | Terminalas    |
| `Super + Alt + Return` | Tmux terminalas |
| `Super + Ctrl + Return` | Herdr (agentų tvarkyklė) |
| `Super + Shift + Return` or `Super + Shift + B`  | Naršyklė    |
| `Super + Shift + Alt + B`           | Naršyklė (privatus / inkognito režimas)    |
| `Super + Shift + F`           | Failų tvarkyklė    |
| `Super + Shift + Alt + F`           | Failų tvarkyklė terminalo cwd kataloge    |
| `Super + Shift + M`           | Muzika (Spotify)    |
| `Super + Shift + Alt + M`           | Muzika (cliamp)    |
| `Super + Shift + /`           | Slaptažodžių tvarkyklė (1password)    |
| `Super + Shift + Q` or `Calculator` key  | Skaičiuotuvas (Omacalc)    |
| `Super + Shift + D`           | Docker (lazydocker, kai įdiegta)    |
| `Super + Shift + T`           | Veikla (btop)    |
| `Super + Shift + N`           | Redaktorius (Plain arba jūsų pasirinktas numatytasis)  |
| `Super + Shift + C`           | Kalendorius ([HEY](https://hey.com/))  |
| `Super + Shift + E`           | El. paštas ([HEY](https://hey.com/))  |
| `Super + Shift + Alt + E`           | Naujas el. laiškas ([HEY](https://hey.com/))  |
| `Super + Shift + A`           | Jūsų numatytasis agentas arba ChatGPT, kol pasirinksite kitą |
| `Super + Shift + Alt + A`           | AI (Grok)  |
| `Super + Shift + G`           | Susirašinėjimo programa (Signal)  |
| `Super + Shift + P`           | Google Photos  |
| `Super + Shift + S`           | Google Maps  |
| `Super + Shift + Alt + G`           | Susirašinėjimo programa (WhatsApp)  |
| `Super + Shift + Ctrl + G`           | Susirašinėjimo programa (Google)  |
| `Super + Shift + O`           | Obsidian  |
| `Super + Shift + W`           | Rašymas (Omawrite)  |
| `Super + Shift + X`           | X |
| `Super + Shift + Alt + X`           | X (naujas įrašas) |
| `Super + Shift + Y`           | YouTube |

Keiskite / pridėkite susiejimus faile `~/.config/hypr/bindings.lua`.

## Universali iškarpinė

| Spartusis klavišas                  | Funkcija              |
| ----------------------- | --------------------- |
| `Super + A`           | Pažymėti viską programose, kurios palaiko `Ctrl + A`    |
| `Super + C`           | Kopijuoti    |
| `Super + X`           | Iškirpti (ne terminale)    |
| `Super + V`           | Įklijuoti    |
| `Super + Ctrl + V`           | Iškarpinės tvarkyklė    |

Paprastai Linux sistemoje terminale kopijuoti ir įklijuoti reikia `Ctrl + Shift + C/V`, o visur kitur – `Ctrl + C/V`. Šie Omarchy suvienodinti iškarpinės spartieji klavišai veikia visur.

## Fiksavimas

| Spartusis klavišas              | Funkcija                       |
| ------------------- | ------------------------------ |
| `Print Screen`            | Ekrano nuotrauka                      |
| `Super + Ctrl + Alt + C`            | Ekrano nuotrauka (ta pati nuotrauka, klaviatūroms be Print Screen klavišo) |
| `Super + Ctrl + C` | Fiksavimo meniu |
| `Alt + Print Screen`            | Ekrano įrašymas                     |
| `Super + Shift + Ctrl + Alt + C` | Ekrano įrašymas be garso, praleidžiant meniu (paspauskite dar kartą, kad sustabdytumėte) |
| `Super + Print Screen` | Spalvų parinkiklis |
| `Super + Ctrl + Print Screen` | Teksto išgavimas į iškarpinę |
| `Super + Alt + [` | Sumažinti internetinės kameros perdangą įrašymo metu |
| `Super + Alt + ]` | Padidinti internetinės kameros perdangą įrašymo metu |
| `Alt + Shift + L` | Kopijuoti dabartinį URL iš žiniatinklio programos ar naršyklės |
| `Alt + Shift + D` | Atsisiųsti dabartinio puslapio vaizdo įrašą į `~/Videos` |
| `Alt + Space` | Pradėti / sustabdyti diktavimą (reikia _Setup > Defaults > Dictation_) |
| `Right Alt` | Laikykite, kad diktuotumėte (reikia _Setup > Defaults > Dictation_) |

Atliekant ekrano įrašymus, spartusis klavišas pirmiausia paklausia, kokio garso norite, tada pradeda įrašyti. Paspauskite dar kartą, kad sustabdytumėte. Išsamesnės informacijos žr. [ekrano nuotraukos ir įrašymas](12-screenshots-recording.md).

Visos fiksavimo parinktys taip pat pasiekiamos Omarchy meniu (`Super + Space`) skiltyje _Trigger > Capture_.

## Pranešimai

| Spartusis klavišas                  | Funkcija              |
| ----------------------- | --------------------- |
| `Super + ,` | Veikti pagal naujausią pranešimą: atidaryti jį arba paspausti vienintelį jo mygtuką, pasirinkti iš jo parinkčių arba atmesti jį, kai jų nėra  |
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

Papildomi fono vaizdai yra `~/.config/omarchy/backgrounds/<theme name>`. Taip pat pasiekiama Omarchy meniu per _Install > Style > Background_.

Visos stiliaus parinktys taip pat pasiekiamos Omarchy meniu (`Super + Space`) skiltyje _Appearance_.

## Perjungimai

| Spartusis klavišas                  | Funkcija              |
| ----------------------- | --------------------- |
| `Super + Ctrl + I` | Perjungti užrakinimą neveiklos metu |
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

## Informaciniai pranešimai

| Spartusis klavišas                  | Funkcija              |
| ----------------------- | --------------------- |
| `Super + Ctrl + Alt + T` | Rodyti laiką kaip pranešimą  |
| `Super + Ctrl + Alt + B` | Rodyti akumuliatorių kaip pranešimą  |
| `Super + Ctrl + Alt + W` | Perjungti orus kaip pranešimą  |

## Tmux

Priešdėlio klavišas yra `Ctrl + Space` (taip pat veikia `Ctrl + B`). Šiuos susiejimus galite keisti faile `~/.config/tmux/tmux.conf`.

### Srities skydai

| Spartusis klavišas                  | Funkcija              |
| ----------------------- | --------------------- |
| `Prefix + v` | Padalyti sritį greta (vertikaliai) |
| `Prefix + h` | Padalyti sritį žemiau (horizontaliai) |
| `Prefix + x` | Uždaryti sritį |
| `Prefix + z` | Perjungti srities priartinimą (viso ekrano režimas) |
| `Alt + Enter` | Padalyti sritį žemiau (be priešdėlio) |
| `Alt + Shift + Enter` | Padalyti sritį greta (be priešdėlio) |
| `Alt + Escape` | Uždaryti sritį (be priešdėlio) |
| `Ctrl + Alt + Arrows` | Judėti tarp sričių |
| `Ctrl + Alt + Shift + Arrows` | Keisti sričių dydį |

### Langai

| Spartusis klavišas                  | Funkcija              |
| ----------------------- | --------------------- |
| `Prefix + c` | Naujas langas |
| `Prefix + k` | Uždaryti langą |
| `Prefix + r` | Pervadinti langą |
| `Alt + 1-9` | Pereiti į nurodytą langą |
| `Alt + Arrow Left/Right` | Judėti tarp langų |
| `Alt + Shift + Arrow Left/Right` | Perkelti langą į kairę / dešinę |

### Sesijos

| Spartusis klavišas                  | Funkcija              |
| ----------------------- | --------------------- |
| `Prefix + C` | Nauja sesija |
| `Prefix + K` | Uždaryti sesiją |
| `Prefix + R` | Pervadinti sesiją |
| `Prefix + N` | Kita sesija |
| `Prefix + P` | Ankstesnė sesija |
| `Alt + Arrow Up/Down` | Judėti tarp sesijų |
| `Prefix + s` | Rodyti sesijų sąrašą |
| `Prefix + d` | Atsijungti nuo sesijos |

### Kopijavimo režimas (vi stiliaus)

| Spartusis klavišas                  | Funkcija              |
| ----------------------- | --------------------- |
| `Prefix + [` | Įjungti kopijavimo režimą |
| `v` | Pradėti žymėjimą (kopijavimo režime) |
| `y` | Kopijuoti žymėjimą (kopijavimo režime) |

### Bendra

| Spartusis klavišas                  | Funkcija              |
| ----------------------- | --------------------- |
| `Prefix + q` | Iš naujo įkelti konfigūraciją |
| `Prefix + ?` | Rodyti Tmux klavišų susiejimus |
| `Prefix + :` | Komandų eilutė |

### Tmux išdėstymo funkcijos

Šios funkcijos turi būti vykdomos Tmux sesijoje.

| Komanda | Funkcija |
| ------- | -------- |
| `tdl <ai> [<second_ai>]` | Sukurti kūrimo išdėstymą su redaktoriumi, AI ir terminalu |
| `tdlm <ai> [<second_ai>]` | Sukurti kūrimo išdėstymą kiekvienam pakatalogiui |
| `tsl <count> <command>` | Sukurti kelių sričių spiečiaus išdėstymą |

## Ghostty Terminal

Ghostty terminalas įdiegiamas Omarchy meniu per _Install > Terminal_.

| Spartusis klavišas                  | Funkcija              |
| ----------------------- | --------------------- |
| `Ctrl + Shift + E` | Naujas padalijimas žemiau |
| `Ctrl + Shift + O` | Naujas padalijimas greta |
| `Ctrl + Alt + Arrows` | Judėti tarp padalijimų |
| `Super + Ctrl + Shift + Arrows` | Keisti padalijimo dydį 10 eilučių |
| `Super + Ctrl + Shift + Alt + Arrows` | Keisti padalijimo dydį 100 eilučių |
| `Ctrl + Shift + T` | Naujas skirtukas  |
| `Ctrl + Shift + Arrows` | Judėti tarp skirtukų |
| `Alt + Numbers` | Pereiti į nurodytą skirtuką |
| `Shift + Pg Up/Down` | Slinkti istoriją |
| `Ctrl + Left mouse` | Atidaryti nuorodą naršyklėje |

## File Manager

| Spartusis klavišas              | Funkcija                       |
| ------------------- | ------------------------------ |
| `Ctrl + L`            | Eiti į kelią                     |
| `Space`               | Peržiūrėti failą (rodyklėmis naršoma) |
| `Alt + Up`       | Eiti į pirminį aplanką        |

## Neovim (w/ lazyvim)

### Naršymas

| Spartusis klavišas                   | Funkcija                        |
| ------------------------ | ------------------------------- |
| `Space`                    | Rodyti komandų parinktis            |
| `Space Space`              | Atidaryti failą naudojant apytikslę paiešką      |
| `Space E`                  | Perjungti šoninę juostą                  |
| `Space G G`                | Rodyti git valdiklius               |
| `Space S G`                | Ieškoti failo turinyje             |
| `Ctrl + W W`               | Pereiti tarp šoninės juostos ir redaktoriaus |
| `Ctrl + Left/right arrow`  | Keisti šoninės juostos dydį          |
| `Shift + H`                      | Eiti į kairįjį failo skirtuką             |
| `Shift + L`                      | Eiti į dešinįjį failo skirtuką            |
| `Space B D`                | Uždaryti failo skirtuką                  |

### Būnant šoninėje juostoje

| Spartusis klavišas                   | Funkcija                        |
| ------------------------ | ------------------------------- |
| `A`                        | Pridėti naują failą pirminiame kataloge      |
| `Shift + A`                | Pridėti naują pakatalogį pirminiame kataloge    |
| `D`                        | Ištrinti pažymėtą failą / katalogą     |
| `M`                        | Perkelti pažymėtą failą / katalogą       |
| `R`                        | Pervadinti pažymėtą failą / katalogą     |
| `?`                        | Rodyti visų komandų žinyną      |

[Žiūrėti visus Neovim sparčiuosius klavišus, sukonfigūruotus LazyVim](https://www.lazyvim.org/keymaps).

## Greitieji jaustukai

Galite naudoti `Super + Ctrl + E`, kad būtų parodytas visas jaustukų parinkiklis, kuris įdės pasirinkimą į iškarpinę, arba galite naudoti šias greitosios prieigos parinktis.

| Spartusis klavišas       | EM | Užuomina       |
| ------------ | -- | ---------- |
| `Shift + CapsLock M S` | 😄 | šypsena      |
| `Shift + CapsLock M C` | 😂 | verksmas        |
| `Shift + CapsLock M L` | 😍 | meilė       |
| `Shift + CapsLock M V` | ✌️ | pergalė    |
| `Shift + CapsLock M H` | ❤️ | širdis      |
| `Shift + CapsLock M Y` | 👍 | taip        |
| `Shift + CapsLock M N` | 👎 | ne         |
| `Shift + CapsLock M F` | 🖕 | keiksmas       |
| `Shift + CapsLock M W` | 🤞 | noras       |
| `Shift + CapsLock M R` | 🤘 | rokas       |
| `Shift + CapsLock M K` | 😘 | bučinys       |
| `Shift + CapsLock M E` | 🙄 | akių vartymas    |
| `Shift + CapsLock M I` | 😉 | mirktelėjimas       |
| `Shift + CapsLock M P` | 🙏 | malda |
| `Shift + CapsLock M D` | 🤤 | seilėtekis      |
| `Shift + CapsLock M M` | 💰 | pinigai      |
| `Shift + CapsLock M X` | 🎉 | šventė |
| `Shift + CapsLock M 1` | 💯 | 100%       |
| `Shift + CapsLock M T` | 🥂 | tostas      |
| `Shift + CapsLock M O` |👌 | gerai |
| `Shift + CapsLock M G` |👋 | pasisveikinimas |
| `Shift + CapsLock M A` |💪 | ranka |
| `Shift + CapsLock M B` |🤯 | sprogimas |

## Greitieji užbaigimai

| Spartusis klavišas       | Užbaigimas       |
| ------------ |  ---------- |
| `Shift + CapsLock Space Space` | — (ilgas brūkšnys)   |
| `Shift + CapsLock Space N` | Jūsų vardas (kaip įvestas sąrankos metu)  |
| `Shift + CapsLock Space E` | Jūsų el. paštas (kaip įvestas sąrankos metu)  |

Galite pridėti daugiau savųjų redaguodami `~/.XCompose`, tada terminale paleidę `omarchy restart xcompose`, kad pakeitimai būtų pritaikyti.
