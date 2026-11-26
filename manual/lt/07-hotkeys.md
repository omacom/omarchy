# Spartieji klavišai

Visus pagrindinius klavišų susiejimus galite matyti paspaudę `Super + K` (Tmux susiejimus — `Super + Alt + K`, o Herdr susiejimus — `Super + Ctrl + K`).

## Kaip išdėstyti spartieji klavišai

Kiekvienas spartusis klavišas yra tam tikroje plokštumoje, kurią nustato jo modifikatoriai, ir kiekviena plokštuma turi vieną paskirtį. Būtent tai neleidžia spartiesiems klavišams susilieti tarpusavyje ir leidžia paprastai atspėti, kur kas yra.

| Plokštuma | Kas joje yra | Pavyzdžiai |
| --- | --- | --- |
| `Super + key` | Sistema: langai, darbo sritys, išdėstymai ir pagrindiniai meniu | `Super + Space` Omarchy meniu, `Super + W` uždaryti langą, `Super + F` per visą ekraną |
| `Super + Shift + key` | Programos | `Super + Shift + B` naršyklė, `Super + Shift + E` el. paštas, `Super + Shift + N` redaktorius |
| `Super + Ctrl + key` | Skydeliai ir sistemos meniu | `Super + Ctrl + A` garsas, `Super + Ctrl + N` tinklas, `Super + Ctrl + C` fiksavimo meniu |
| `Super + Ctrl + Alt + key` | Greiti veiksmai ir pranešimai | `Super + Ctrl + Alt + T` rodyti laiką, `Super + Ctrl + Alt + B` baterija, `Super + Ctrl + Alt + C` ekrano kopija |

Pridėjus `Alt` prie sparčiojo klavišo, gaunamas to paties dalyko variantas, niekada kažkas nesusijusio:

- `Super + Shift + B` atidaro naršyklę; `Super + Shift + Alt + B` atidaro privatų langą
- `Super + Shift + E` atidaro el. paštą; `Super + Shift + Alt + E` pradeda naują laišką
- `Super + F` pereina į viso ekrano režimą; `Super + Alt + F` pereina į viso pločio režimą
- `Super + Ctrl + C` atidaro fiksavimo meniu; `Super + Ctrl + Alt + C` praleidžia meniu ir daro ekrano kopiją

Kai pridedate spartųjį klavišą:

1. Pagal tai, ką jis daro, pasirinkite plokštumą, tada pasirinkite klavišą.
2. Neperkeldinėkite esamo sparčiojo klavišo, kad atlaisvintumėte vietos. Raskite laisvą klavišą tinkamoje plokštumoje.
3. `Alt` naudokite tik to paties sparčiojo klavišo be jo variantui.

Keletas sparčiųjų klavišų pažeidžia šias taisykles, nes taip patogu. `Shift` su rodykle arba `Tab` perkelia arba apgręžia, o ne atidaro programą, o `Print`, medijos klavišai, `Alt + Tab` ir `Ctrl + Alt + Del` veikia taip, kaip visur kitur. Tai išimtys, o ne pavyzdžiai, kuriuos reikėtų kopijuoti.

Jei numatytasis variantas jums netinka (pavyzdžiui, norite `Super + Shift + S` ekrano kopijoms kaip Windows), perriškite jį `~/.config/hypr/bindings.lua`.

## Naršymas

| Spartusis klavišas                  | Funkcija              |
| ----------------------- | --------------------- |
| `Super + Space`           | Omarchy meniu (programos ir visa kita)    |
| `Super + Alt + Space` | Programų tinklelis |
| `Super + Escape` | Sistemos meniu (pristabdyti, paleisti iš naujo ir t. t.)  |
| `Super + Ctrl + L` | Užrakinti kompiuterį |
| `Super + W` or `Super + Q` | Uždaryti langą             |
| `Ctrl + Alt + Del` | Uždaryti visus langus |
| `Super + K` | Rodyti visus sparčiuosius klavišus |
| `Super + Alt + K` | Rodyti tmux sparčiuosius klavišus |
| `Super + Ctrl + K` | Rodyti herdr sparčiuosius klavišus |
| `Super + M` | Suskleisti langą į doką |
| `Super + T`               | Perjungti langą tarp išdėstymo plytelėmis ir slankiojo režimo             |
| `Super + J` | Perjungti lango padėtį (horizontali / vertikali) |
| `Super + O`               | Perjungti lango pavertimą prilipusiu ir slankiuoju |
| `Super + L`               | Cikliškai perjungti dwindle, slinkties ir slankųjį išdėstymus |
| `Super + Alt + L`         | Cikliškai perjungti išdėstymus atvirkštine tvarka |
| `Super + P`               | Perjungti pseudolango stilių (natūralus ar ištemptas) |
| `Super + F`                 | Pereiti į viso ekrano režimą              |
| `Super + Alt + F`                 | Pereiti į viso pločio režimą              |
| `Super + Ctrl + F`                 | Pereiti į viso ekrano režimą lango viduje              |
| `Super + 1…9/0`         | Pereiti į konkrečią darbo sritį (0 yra 10) fokusuotame monitoriuje |
| `Super + Tab` | Pereiti į kitą darbo sritį fokusuotame monitoriuje |
| `Super + Shift + Tab` | Pereiti į ankstesnę darbo sritį fokusuotame monitoriuje |
| `Super + Ctrl + Tab` | Pereiti į buvusią darbo sritį fokusuotame monitoriuje |
| `Super + Shift + 1…9/0` | Perkelti langą į darbo sritį fokusuotame monitoriuje |
| `Super + Shift + Alt + 1…9/0` | Perkelti langą į darbo sritį fokusuotame monitoriuje nesekant paskui |
| `Super + S` | Perjungti visą juodraštinę sritį |
| `Super + Alt + S` | Perkelti langą į visą juodraštinę sritį |
| `Super + the key above Tab` (JAV išdėstymuose — gravis) | Perjungti Quake konsolę |
| `Super + Shift + the key above Tab` (JAV išdėstymuose — gravis) | Perkelti langą į Quake konsolę |
| `Super + Shift + Ctrl + Arrows` | Perkelti langą į monitorių ta kryptimi |
| `Super + Shift + Alt + Arrows` | Perkelti darbo sritį į monitorių ta kryptimi |
| `Super + Arrow`  | Perkelti fokusą į langą rodyklės kryptimi, ekrano krašte pereinant į tos pusės monitorių |
| `Super + Shift + Arrow`  | Sukeisti langą su kitu rodyklės kryptimi, įskaitant esantį tos pusės monitoriuje |
| `Super + Minus` | Išplėsti langą į kairę |
| `Super + Equal` | Suspausti langą į kairę |
| `Super + Shift + Minus` | Suspausti langą aukštyn |
| `Super + Shift + Equal` | Išplėsti langą žemyn |
| `Super + Alt + Minus/Equal` | Tas pats dydžio keitimas mažesniais žingsniais |
| `Super + Ctrl + Minus/Equal` | Tas pats dydžio keitimas didesniais žingsniais |
| `Super + Alt + Home` | Įrašyti lango plotį |
| `Super + Home` | Atkurti įrašytą lango plotį |
| `Super + Left Mouse` | Vilkti langą |
| `Super + Right Mouse` | Keisti lango dydį |
| `Super + Scroll Wheel` | Slinkti per darbo sritis fokusuotame monitoriuje |
| `Super + G`               | Perjungti langų grupavimą      |
| `Super + Alt + G`               | Iškelti langą iš grupės      |
| `Super + Alt + Tab`               | Cikliškai perjungti langus grupėje      |
| `Super + Alt + Shift + Tab`               | Cikliškai perjungti langus grupėje atgal      |
| `Super + Alt + Scroll Wheel` | Cikliškai perjungti langus grupėje |
| `Super + Alt + 1/2/3/4/5`               | Pereiti į konkretų langą grupėje      |
| `Super + Alt + Arrow`  | Perkelti langą į grupę rodyklės kryptimi, įskaitant esantį tos pusės monitoriuje |
| `Super + Ctrl + Left/Right`  | Judėti tarp langų plytelių grupės viduje |
| `Super + Ctrl + Z` | Priartinti ekraną (kartokite, kad priartintumėte dar labiau) |
| `Super + Ctrl + Alt + Z` | Visiškai atitolinti ekraną |
| `Super + /` | Pereiti į priekį per monitoriaus mastelio parinktis |
| `Super + Alt + /` | Pereiti atgal per monitoriaus mastelio parinktis |
| `Alt + Tab` | Cikliškai pereiti į priekį per langus aktyvioje darbo srityje |
| `Alt + Shift + Tab` | Cikliškai pereiti atgal per langus aktyvioje darbo srityje |
| `Ctrl + Alt + Tab`| Cikliškai perkelti fokusą į priekį per monitorius |
| `Ctrl + Alt + Shift + Tab`| Cikliškai perkelti fokusą atgal per monitorius |
| `Super + I` | Perjungti įvesties kalbą (kai yra daugiau nei vienas išdėstymas ar įvesties būdas) |
| `Super + Shift + I` | Perjungti įvesties kalbą atgal |

Jutikliniame kilimėlyje braukimai trimis ir keturiais pirštais perjungia darbo sritis, perkelia langus ir atidaro meniu bei Quake konsolę; gestus žr. [klaviatūra, pelė ir jutiklinis kilimėlis](34-keyboard-mouse-trackpad.md).

Dydžiui keisti naudojami du klavišai į dešinę nuo 0, kad ir kas ant jų būtų atspausdinta jūsų klaviatūroje: `-` ir `=` JAV klaviatūrose, `+` ir `´` danų ir švedų, `+` ir `\` norvegų, `ß` ir `´` vokiečių, `'` ir `¡` ispanų, o `-` ir `^` japonų (JIS). `Super + K` juos pateikia taip, kaip atspausdinta jūsų klaviatūroje. JIS atveju `Super + ^` yra `Super + Equal`, o `Super + Shift + -` (kuriuo įvedama `=`) yra `Super + Shift + Minus`. Monitoriaus mastelis ir slaptažodžių tvarkytuvė naudoja `/`; išdėstymuose, kuriuose `/` įvedama tik su Shift, kaip daugumoje europietiškų, vietoj jo naudojamas klavišas į kairę nuo dešiniojo Shift (`-` danų ir vokiečių).

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
| `Super + Ctrl + C` | Fiksavimo valdikliai (ekrano kopija / įrašymas / parinkiklis) |
| `Super + Ctrl + O` | Perjungti meniu |
| `Super + Ctrl + H` | Aparatūros meniu |
| `Super + Ctrl + E` | Jaustukų parinkiklis |
| `Super + Ctrl + .` | Transkoduoti mediją |
| `Super + Shift + Ctrl + A` | Paleisti numatytąjį agentą |
| `Power` key | Sistemos meniu |
| `Super + Shift + Copilot` key | Omarchy meniu |

## Reguliavimas

| Spartusis klavišas                  | Funkcija              |
| ----------------------- | --------------------- |
| `Shift + Brightness Up` | Didžiausias ekrano ryškumas |
| `Shift + Brightness Down` | Mažiausias ekrano ryškumas |
| `Alt + Brightness Up/Down` | Tikslūs 1 % ryškumo pakeitimai |
| `Alt + Volume Up/Down` | Tikslūs 1 % garsumo pakeitimai |
| `Keyboard Brightness Up/Down` | Ryškesnis / blankesnis klaviatūros apšvietimas |
| `Keyboard Backlight` | Cikliškai perjungti klaviatūros apšvietimo lygius |
| `Ctrl + Brightness Up/Down` | Ryškesnis / blankesnis klaviatūros apšvietimas klaviatūrose be savų klavišų |
| `Mic Mute` | Nutildyti mikrofoną |
| `Shift + Mute` | Perjungti garso išvestį |
| `Touchpad Toggle` | Įjungti arba išjungti jutiklinį kilimėlį |
| `Display` key | Cikliškai perjungti darbo srities išdėstymą |
| `Alt + Play` | Kitas takelis |
| `Alt + Shift + Play` | Ankstesnis takelis |

## Programų paleidimas

| Spartusis klavišas                  | Funkcija              |
| ----------------------- | --------------------- |
| `Super + Return`           | Terminalas    |
| `Super + Alt + Return` | Tmux terminalas |
| `Super + Ctrl + Return` | Herdr (agentų tvarkytuvė) |
| `Super + Shift + Return` or `Super + Shift + B`  | Naršyklė    |
| `Super + Shift + Alt + B`           | Naršyklė (privatus / inkognito režimas)    |
| `Super + Shift + F`           | Failų tvarkytuvė    |
| `Super + Shift + Alt + F`           | Failų tvarkytuvė terminalo cwd kataloge    |
| `Super + Shift + M`           | Muzika (Spotify)    |
| `Super + Shift + Alt + M`           | Muzika (cliamp)    |
| `Super + Shift + /`           | Slaptažodžių tvarkytuvė (1password)    |
| `Super + Shift + Q` or `Calculator` key  | Skaičiuotuvas (Omacalc)    |
| `Super + Shift + D`           | Docker (lazydocker, kai įdiegta)    |
| `Super + Shift + T`           | Veikla (btop)    |
| `Super + Shift + N`           | Redaktorius (Plain arba jūsų pasirinktas numatytasis)  |
| `Super + Shift + C`           | Kalendorius ([HEY](https://hey.com/))  |
| `Super + Shift + E`           | El. paštas ([HEY](https://hey.com/))  |
| `Super + Shift + Alt + E`           | Naujas el. laiškas ([HEY](https://hey.com/))  |
| `Super + Shift + A`           | DI (ChatGPT)  |
| `Super + Shift + Alt + A`           | DI (Grok)  |
| `Super + Shift + G`           | Susirašinėjimas (Signal)  |
| `Super + Shift + P`           | Google Photos  |
| `Super + Shift + S`           | Google Maps  |
| `Super + Shift + Alt + G`           | Susirašinėjimas (WhatsApp)  |
| `Super + Shift + Ctrl + G`           | Susirašinėjimas (Google)  |
| `Super + Shift + O`           | Obsidian  |
| `Super + Shift + W`           | Rašymas (Omawrite)  |
| `Super + Shift + X`           | X |
| `Super + Shift + Alt + X`           | X (naujas įrašas) |
| `Super + Shift + Y`           | YouTube |

Susiejimus keiskite / pridėkite `~/.config/hypr/bindings.lua`.

## Universali iškarpinė

| Spartusis klavišas                  | Funkcija              |
| ----------------------- | --------------------- |
| `Super + A`           | Pažymėti viską programose, kurios palaiko `Ctrl + A`    |
| `Super + C`           | Kopijuoti    |
| `Super + X`           | Iškirpti (ne terminale)    |
| `Super + V`           | Įklijuoti    |
| `Super + Ctrl + V`           | Iškarpinės tvarkytuvė    |

Paprastai Linux sistemoje terminale kopijuoti ir įklijuoti reikia `Ctrl + Shift + C/V`, o visur kitur — `Ctrl + C/V`. Šie Omarchy suvienodinti iškarpinės spartieji klavišai veikia visur.

## Fiksavimas

| Spartusis klavišas              | Funkcija                       |
| ------------------- | ------------------------------ |
| `Print Screen`            | Ekrano kopija                      |
| `Super + Ctrl + Alt + C`            | Ekrano kopija (tas pats kadras, klaviatūroms be Print Screen klavišo) |
| `Super + Ctrl + C` | Fiksavimo meniu |
| `Alt + Print Screen`            | Ekrano įrašymas                     |
| `Super + Shift + Ctrl + Alt + C` | Ekrano įrašymas be garso, praleidžiant meniu (paspauskite dar kartą, kad sustabdytumėte) |
| `Super + Print Screen` | Spalvų parinkiklis |
| `Super + Ctrl + Print Screen` | Teksto išgavimas į iškarpinę |
| `Super + Alt + [` | Sumažinti internetinės kameros perdangą įrašant |
| `Super + Alt + ]` | Padidinti internetinės kameros perdangą įrašant |
| `Alt + Shift + L` | Kopijuoti dabartinį URL iš žiniatinklio programos ar naršyklės |
| `Alt + Shift + D` | Atsisiųsti dabartinio puslapio vaizdo įrašą į `~/Videos` |
| `Alt + Space` | Pradėti / sustabdyti diktavimą (reikia _Setup > Defaults > Dictation_) |
| `Right Alt` | Laikyti norint diktuoti (reikia _Setup > Defaults > Dictation_) |

Ekrano įrašymų atveju spartusis klavišas pirmiausia paklausia, kokio garso norite, tada pradeda įrašyti. Paspauskite jį dar kartą, kad sustabdytumėte. Išsamesnės informacijos žr. [ekrano kopijos ir įrašymas](12-screenshots-recording.md).

Visos fiksavimo parinktys taip pat pasiekiamos per _Trigger > Capture_ Omarchy meniu (`Super + Space`).

## Pranešimai

| Spartusis klavišas                  | Funkcija              |
| ----------------------- | --------------------- |
| `Super + ,` | Veikti su naujausiu pranešimu: atidaryti jį arba paspausti vienintelį jo mygtuką, pasirinkti iš jo parinkčių arba atmesti jį, kai parinkčių nėra  |
| `Super + Shift + ,` | Atmesti visus pranešimus |
| `Super + Ctrl + ,` | Valdyti pranešimus klaviatūra  |
| `Super + Alt + ,` | Atmesti naujausią pranešimą  |
| `Super + Shift + Alt + ,` | Atidaryti pranešimų istoriją  |
| `Super + Ctrl + Alt + ,` | Perjungti pranešimų tylinimą  |

## Stilius

| Spartusis klavišas                  | Funkcija              |
| ----------------------- | --------------------- |
| `Super + Ctrl + T` | Pasirinkti naują temą (taip pat `Super + Ctrl + Shift + Space`) |
| `Super + Ctrl + W` | Pasirinkti temos foną (taip pat `Super + Ctrl + Space`) |
| `Super + Backspace` | Perjungti lango skaidrumą |
| `Super + Ctrl + Backspace` | Perjungti vieno lango kvadrato formatą |

Papildomi fono paveikslėliai yra `~/.config/omarchy/backgrounds/<theme name>`. Taip pat pasiekiama per _Install > Style > Background_ Omarchy meniu.

Visos stiliaus parinktys taip pat pasiekiamos per _Appearance_ Omarchy meniu (`Super + Space`).

## Perjungikliai

| Spartusis klavišas                  | Funkcija              |
| ----------------------- | --------------------- |
| `Super + Ctrl + I` | Perjungti užrakinimą esant neaktyvumui |
| `Super + Ctrl + Delete` | Įjungti / išjungti nešiojamojo kompiuterio ekraną |
| `Super + Ctrl + Alt + Delete` | Perjungti nešiojamojo kompiuterio ekrano veidrodinį atspindėjimą |
| `Super + Shift + Space` | Perjungti viršutinę juostą  |
| `Shift + Mute` | Perjungti į kitą garso išvestį |
| `Shift + Play` | Perjungti į kitą medijos šaltinį |
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
| `Super + Ctrl + Alt + B` | Rodyti bateriją kaip pranešimą  |
| `Super + Ctrl + Alt + W` | Perjungti orus kaip pranešimą  |

## Tmux

Priešdėlio klavišas yra `Ctrl + Space` (taip pat veikia `Ctrl + B`). Šiuos susiejimus galite keisti `~/.config/tmux/tmux.conf`.

### Sritys

| Spartusis klavišas                  | Funkcija              |
| ----------------------- | --------------------- |
| `Prefix + v` | Padalyti sritį šalia (vertikaliai) |
| `Prefix + h` | Padalyti sritį žemiau (horizontaliai) |
| `Prefix + x` | Nutraukti sritį |
| `Prefix + z` | Perjungti srities priartinimą (per visą ekraną) |
| `Alt + Enter` | Padalyti sritį žemiau (be priešdėlio) |
| `Alt + Shift + Enter` | Padalyti sritį šalia (be priešdėlio) |
| `Alt + Escape` | Nutraukti sritį (be priešdėlio) |
| `Ctrl + Alt + Arrows` | Judėti tarp sričių |
| `Ctrl + Alt + Shift + Arrows` | Keisti sričių dydį |

### Langai

| Spartusis klavišas                  | Funkcija              |
| ----------------------- | --------------------- |
| `Prefix + c` | Naujas langas |
| `Prefix + k` | Nutraukti langą |
| `Prefix + r` | Pervardyti langą |
| `Alt + 1-9` | Eiti į konkretų langą |
| `Alt + Arrow Left/Right` | Judėti tarp langų |
| `Alt + Shift + Arrow Left/Right` | Perkelti langą į kairę / dešinę |

### Seansai

| Spartusis klavišas                  | Funkcija              |
| ----------------------- | --------------------- |
| `Prefix + C` | Naujas seansas |
| `Prefix + K` | Nutraukti seansą |
| `Prefix + R` | Pervardyti seansą |
| `Prefix + N` | Kitas seansas |
| `Prefix + P` | Ankstesnis seansas |
| `Alt + Arrow Up/Down` | Judėti tarp seansų |
| `Prefix + s` | Išvardyti seansus |
| `Prefix + d` | Atsijungti nuo seanso |

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

Šios funkcijos turi būti vykdomos Tmux seanso viduje.

| Komanda | Funkcija |
| ------- | -------- |
| `tdl <ai> [<second_ai>]` | Sukurti kūrimo išdėstymą su redaktoriumi, DI ir terminalu |
| `tdlm <ai> [<second_ai>]` | Sukurti kūrimo išdėstymą kiekvienam pakatalogiui |
| `tsl <count> <command>` | Sukurti kelių sričių spiečiaus išdėstymą |

## Ghostty terminalas

Ghostty terminalas įdiegiamas naudojant _Install > Terminal_ per Omarchy meniu.

| Spartusis klavišas                  | Funkcija              |
| ----------------------- | --------------------- |
| `Ctrl + Shift + E` | Naujas padalijimas žemiau |
| `Ctrl + Shift + O` | Naujas padalijimas šalia |
| `Ctrl + Alt + Arrows` | Judėti tarp padalijimų |
| `Super + Ctrl + Shift + Arrows` | Keisti padalijimo dydį 10 eilučių |
| `Super + Ctrl + Shift + Alt + Arrows` | Keisti padalijimo dydį 100 eilučių |
| `Ctrl + Shift + T` | Naujas skirtukas  |
| `Ctrl + Shift + Arrows` | Judėti tarp skirtukų |
| `Alt + Numbers` | Eiti į konkretų skirtuką |
| `Shift + Pg Up/Down` | Slinkti per istoriją |
| `Ctrl + Left mouse` | Atidaryti nuorodą naršyklėje |

## Failų tvarkytuvė

| Spartusis klavišas              | Funkcija                       |
| ------------------- | ------------------------------ |
| `Ctrl + L`            | Eiti į kelią                     |
| `Space`               | Peržiūrėti failą (rodyklėmis naršoma) |
| `Alt + Up`       | Eiti į tėvinį aplanką        |

## Neovim (su lazyvim)

### Naršymas

| Spartusis klavišas                   | Funkcija                        |
| ------------------------ | ------------------------------- |
| `Space`                    | Rodyti komandų parinktis            |
| `Space Space`              | Atidaryti failą naudojant neaiškiąją paiešką      |
| `Space E`                  | Perjungti šoninę juostą                  |
| `Space G G`                | Rodyti git valdiklius               |
| `Space S G`                | Ieškoti failo turinio             |
| `Ctrl + W W`               | Šokti tarp šoninės juostos ir redaktoriaus |
| `Ctrl + Left/right arrow`  | Keisti šoninės juostos dydį          |
| `Shift + H`                      | Eiti į kairįjį failo skirtuką             |
| `Shift + L`                      | Eiti į dešinįjį failo skirtuką            |
| `Space B D`                | Uždaryti failo skirtuką                  |

### Esant šoninėje juostoje

| Spartusis klavišas                   | Funkcija                        |
| ------------------------ | ------------------------------- |
| `A`                        | Pridėti naują failą tėviniame kataloge      |
| `Shift + A`                | Pridėti naują pakatalogį tėviniame kataloge    |
| `D`                        | Ištrinti pažymėtą failą / katalogą     |
| `M`                        | Perkelti pažymėtą failą / katalogą       |
| `R`                        | Pervardyti pažymėtą failą / katalogą     |
| `?`                        | Rodyti visų komandų žinyną      |

[Žiūrėti visus LazyVim sukonfigūruotus Neovim sparčiuosius klavišus](https://www.lazyvim.org/keymaps).

## Greitieji jaustukai

Galite naudoti `Super + Ctrl + E`, kad būtų parodytas išsamus jaustukų parinkiklis, kuris įdės pasirinkimą į iškarpinę, arba galite naudoti šias greitosios prieigos parinktis.

| Spartusis klavišas       | EM | Užuomina       |
| ------------ | -- | ---------- |
| `Shift + CapsLock M S` | 😄 | šypsena      |
| `Shift + CapsLock M C` | 😂 | ašaros        |
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
| `Shift + CapsLock M P` | 🙏 | malda |
| `Shift + CapsLock M D` | 🤤 | seilėtekis      |
| `Shift + CapsLock M M` | 💰 | pinigai      |
| `Shift + CapsLock M X` | 🎉 | xellebrate |
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
| `Shift + CapsLock Space N` | Jūsų vardas (kaip įvesta sąrankos metu)  |
| `Shift + CapsLock Space E` | Jūsų el. paštas (kaip įvesta sąrankos metu)  |

Galite pridėti daugiau savų redaguodami `~/.XCompose`, tada terminale paleisdami `omarchy restart xcompose`, kad pakeitimai būtų pritaikyti.
