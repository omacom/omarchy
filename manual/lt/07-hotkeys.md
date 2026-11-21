# Spartieji klavišai

Visus pagrindinius klavišų derinius galite pamatyti paspaudę `Super + K` (Tmux derinius – `Super + Alt + K`, o Herdr derinius – `Super + Ctrl + K`).

## Kaip išdėstyti spartieji klavišai

Kiekvienas spartusis klavišas yra tam tikroje plokštumoje, kurią nustato jo modifikatoriai, ir kiekviena plokštuma turi vieną paskirtį. Būtent tai neleidžia spartiesiems klavišams susilieti į vieną masę ir reiškia, kad paprastai galite atspėti, kur kas yra.

| Plokštuma | Kas čia yra | Pavyzdžiai |
| --- | --- | --- |
| `Super + key` | Sistema: langai, darbo erdvės, išdėstymai ir pagrindiniai meniu | `Super + Space` Omarchy meniu, `Super + W` uždaryti langą, `Super + F` per visą ekraną |
| `Super + Shift + key` | Programos | `Super + Shift + B` naršyklė, `Super + Shift + E` el. paštas, `Super + Shift + N` redaktorius |
| `Super + Ctrl + key` | Skydeliai ir sistemos meniu | `Super + Ctrl + A` garsas, `Super + Ctrl + N` tinklas, `Super + Ctrl + C` fiksavimo meniu |
| `Super + Ctrl + Alt + key` | Greiti veiksmai ir pranešimai | `Super + Ctrl + Alt + T` rodyti laiką, `Super + Ctrl + Alt + B` baterija, `Super + Ctrl + Alt + C` ekrano kopija |

Pridėjus `Alt` prie sparčiojo klavišo, gaunamas to paties dalyko variantas, niekada kažkas nesusijusio:

- `Super + Shift + B` atidaro naršyklę; `Super + Shift + Alt + B` atidaro privatų langą
- `Super + Shift + E` atidaro el. paštą; `Super + Shift + Alt + E` pradeda naują laišką
- `Super + F` pereina per visą ekraną; `Super + Alt + F` pereina per visą plotį
- `Super + Ctrl + C` atidaro fiksavimo meniu; `Super + Ctrl + Alt + C` praleidžia meniu ir padaro ekrano kopiją

Pridedant spartųjį klavišą:

1. Pagal tai, ką jis daro, pasirinkite plokštumą, tada pasirinkite klavišą.
2. Neperkelkite esamo sparčiojo klavišo, kad atlaisvintumėte vietos. Raskite laisvą klavišą tinkamoje plokštumoje.
3. `Alt` naudokite tik sparčiojo klavišo be jo variantui.

Keletas sparčiųjų klavišų pažeidžia šias taisykles, nes taip patogiau. `Shift` su rodykle arba `Tab` perkelia arba apgręžia, užuot atidaręs programą, o `Print`, medijos klavišai, `Alt + Tab` ir `Ctrl + Alt + Del` veikia taip, kaip ir visur kitur. Tai išimtys, o ne pavyzdžiai, kuriuos reikėtų kopijuoti.

Jei numatytasis derinys jums netinka (tarkime, norite `Super + Shift + S` ekrano kopijoms kaip Windows), perriškite jį faile `~/.config/hypr/bindings.lua`.

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
| `Super + M` | Sumažinti langą į doką |
| `Super + T`               | Perjungti langą tarp išdėstymo plytelėmis ir slankiojo režimo             |
| `Super + J` | Perjungti lango padėtį (horizontali / vertikali) |
| `Super + O`               | Perjungti lango pavertimą prilipusiu slankiuoju |
| `Super + L`               | Cikliškai perjungti dwindle, scrolling ir floating išdėstymus |
| `Super + Alt + L`         | Cikliškai perjungti išdėstymus atvirkštine tvarka |
| `Super + P`               | Perjungti pseudo lango stilių (natūralus ar ištemptas) |
| `Super + F`                 | Per visą ekraną              |
| `Super + Alt + F`                 | Per visą plotį              |
| `Super + Ctrl + F`                 | Per visą ekraną lango viduje              |
| `Super + 1…9/0`         | Pereiti į konkrečią darbo erdvę (0 yra 10) fokusuotame monitoriuje |
| `Super + Tab` | Pereiti į kitą darbo erdvę fokusuotame monitoriuje |
| `Super + Shift + Tab` | Pereiti į ankstesnę darbo erdvę fokusuotame monitoriuje |
| `Super + Ctrl + Tab` | Pereiti į buvusią darbo erdvę fokusuotame monitoriuje |
| `Super + Shift + 1…9/0` | Perkelti langą į darbo erdvę fokusuotame monitoriuje |
| `Super + Shift + Alt + 1…9/0` | Perkelti langą į darbo erdvę fokusuotame monitoriuje nesekant paskui |
| `Super + S` | Perjungti visą scratchpad |
| `Super + Alt + S` | Perkelti langą į visą scratchpad |
| `Super + Grave` | Perjungti Quake konsolę |
| `Super + Shift + Grave` | Perkelti langą į Quake konsolę |
| `Super + Shift + Ctrl + Arrows` | Perkelti langą į monitorių ta kryptimi |
| `Super + Shift + Alt + Arrows` | Perkelti darbo erdvę į monitorių ta kryptimi |
| `Super + Arrow`  | Perkelti fokusą į langą rodyklės kryptimi, ekrano krašte pereinant į tos pusės monitorių |
| `Super + Shift + Arrow`  | Sukeisti langą su kitu rodyklės kryptimi, įskaitant esantį tos pusės monitoriuje |
| `Super + Minus` | Išplėsti langą į kairę |
| `Super + Equal` | Suspausti langą į kairę |
| `Super + Shift + Minus` | Suspausti langą į viršų |
| `Super + Shift + Equal` | Išplėsti langą į apačią |
| `Super + Alt + Minus/Equal` | Tas pats dydžio keitimas mažesniais žingsniais |
| `Super + Ctrl + Minus/Equal` | Tas pats dydžio keitimas didesniais žingsniais |
| `Super + Alt + Home` | Išsaugoti lango plotį |
| `Super + Home` | Atkurti išsaugotą lango plotį |
| `Super + Left Mouse` | Vilkti langą |
| `Super + Right Mouse` | Keisti lango dydį |
| `Super + Scroll Wheel` | Slinkti per darbo erdves fokusuotame monitoriuje |
| `Super + G`               | Perjungti langų grupavimą      |
| `Super + Alt + G`               | Perkelti langą iš grupavimo      |
| `Super + Alt + Tab`               | Cikliškai perjungti langus grupėje      |
| `Super + Alt + Shift + Tab`               | Cikliškai perjungti langus grupėje atgal      |
| `Super + Alt + Scroll Wheel` | Cikliškai perjungti langus grupėje |
| `Super + Alt + 1/2/3/4/5`               | Pereiti į konkretų langą grupėje      |
| `Super + Alt + Arrow`  | Perkelti langą į grupavimą rodyklės kryptimi, įskaitant esantį tos pusės monitoriuje |
| `Super + Ctrl + Left/Right`  | Judėti tarp langų plytelių grupėje |
| `Super + Ctrl + Z` | Priartinti ekraną (kartokite, kad priartintumėte dar labiau) |
| `Super + Ctrl + Alt + Z` | Visiškai atitolinti nuo ekrano |
| `Super + /` | Žingsnis pirmyn per monitoriaus mastelio parinktis |
| `Super + Alt + /` | Žingsnis atgal per monitoriaus mastelio parinktis |
| `Alt + Tab` | Cikliškai perjungti langus aktyvioje darbo erdvėje pirmyn |
| `Alt + Shift + Tab` | Cikliškai perjungti langus aktyvioje darbo erdvėje atgal |
| `Ctrl + Alt + Tab`| Cikliškai perkelti fokusą per monitorius pirmyn |
| `Ctrl + Alt + Shift + Tab`| Cikliškai perkelti fokusą per monitorius atgal |
| `Super + I` | Perjungti įvesties kalbą (kai yra daugiau nei vienas išdėstymas ar įvesties metodas) |
| `Super + Shift + I` | Perjungti įvesties kalbą atgal |

Jutikliniame kilimėlyje trijų ir keturių pirštų perbraukimai perjungia darbo erdves, perkelia langus ir atidaro meniu bei Quake konsolę; gestus žr. [klaviatūra, pelė ir jutiklinis kilimėlis](34-keyboard-mouse-trackpad.md).

Dydžio keitimo spartieji klavišai naudoja fizinius klavišus `code:20` ir `code:21` (XKB `<AE11>` ir `<AE12>`), nepriklausomai nuo ant klaviatūros atspausdintų simbolių. JAV klaviatūrose šie klavišai yra `-` ir `=`; japonų (JIS) klaviatūrose jie yra `-` ir `^`; ispaniškose klaviatūrose jie yra `'` ir `¡`. JIS klaviatūroje `Super + ^` yra `Super + Equal`, o `Super + Shift + -` (kuriuo įvedama `=`) yra `Super + Shift + Minus`.

## Sistemos valdikliai

| Spartusis klavišas                  | Funkcija              |
| ----------------------- | --------------------- |
| `Super + Ctrl + A`           | Garso skydelis    |
| `Super + Ctrl + B`           | Bluetooth skydelis    |
| `Super + Ctrl + N`           | Wi-Fi / tinklo skydelis    |
| `Super + Ctrl + D`           | Ekrano skydelis    |
| `Super + Ctrl + P`           | Maitinimo skydelis    |
| `Super + Ctrl + X`           | Agentų skydelis    |
| `Super + Ctrl + Shift + X`           | Vietinių modelių skydelis    |
| `Super + Ctrl + Alt + D`           | Kalendoriaus skydelis    |
| `Super + Ctrl + Alt + E`           | Pasaulio laikrodžio skydelis    |
| `Super + Ctrl + 1-9`           | Perjungti juostos skydelį pagal padėtį    |
| `Super + Ctrl + S` | Bendrinimo meniu (per LocalSend) |
| `Super + Ctrl + C` | Fiksavimo valdikliai (ekrano kopija/-įrašymas/parinkiklis) |
| `Super + Ctrl + O` | Perjungti meniu |
| `Super + Ctrl + H` | Aparatūros meniu |
| `Super + Ctrl + E` | Jaustukų parinkiklis |
| `Super + Ctrl + .` | Perkuoduoti mediją |
| `Super + Shift + Ctrl + A` | Pasirinkti AI agentą |
| `Power` key | Sistemos meniu |
| `Super + Shift + Copilot` key | Omarchy meniu |

## Koregavimai

| Spartusis klavišas                  | Funkcija              |
| ----------------------- | --------------------- |
| `Shift + Brightness Up` | Maksimalus ekrano ryškumas |
| `Shift + Brightness Down` | Minimalus ekrano ryškumas |
| `Alt + Brightness Up/Down` | Tikslūs 1% ryškumo pakeitimai |
| `Alt + Volume Up/Down` | Tikslūs 1% garsumo pakeitimai |
| `Keyboard Brightness Up/Down` | Klaviatūros apšvietimą ryškinti / blankinti |
| `Keyboard Backlight` | Cikliškai perjungti klaviatūros apšvietimo lygius |
| `Ctrl + Brightness Up/Down` | Klaviatūros apšvietimą ryškinti / blankinti klaviatūrose be savų klavišų |
| `Mic Mute` | Nutildyti mikrofoną |
| `Shift + Mute` | Perjungti garso išvestį |
| `Touchpad Toggle` | Įjungti arba išjungti jutiklinį kilimėlį |
| `Display` key | Cikliškai perjungti darbo erdvės išdėstymą |
| `Alt + Play` | Kitas takelis |
| `Alt + Shift + Play` | Ankstesnis takelis |

## Programų paleidimas

| Spartusis klavišas                  | Funkcija              |
| ----------------------- | --------------------- |
| `Super + Return`           | Terminalas    |
| `Super + Alt + Return` | Tmux terminalas |
| `Super + Ctrl + Return` | Herdr (agentų tvarkyklė) |
| `Super + Shift + Return` or `Super + Shift + B`  | Naršyklė    |
| `Super + Shift + Alt + B`           | Naršyklė (privatus / inkognito)    |
| `Super + Shift + F`           | Failų tvarkyklė    |
| `Super + Shift + Alt + F`           | Failų tvarkyklė terminalo cwd aplanke    |
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
| `Super + Shift + Alt + X`           | X (naujas įrašas) |
| `Super + Shift + Y`           | YouTube |

Keiskite / pridėkite derinius faile `~/.config/hypr/bindings.lua`.

## Universali iškarpinė

| Spartusis klavišas                  | Funkcija              |
| ----------------------- | --------------------- |
| `Super + A`           | Pasirinkti viską programose, kurios palaiko `Ctrl + A`    |
| `Super + C`           | Kopijuoti    |
| `Super + X`           | Iškirpti (ne terminale)    |
| `Super + V`           | Įklijuoti    |
| `Super + Ctrl + V`           | Iškarpinės tvarkyklė    |

Paprastai Linux sistemoje terminale kopijuoti ir įklijuoti reikia `Ctrl + Shift + C/V`, o visur kitur – `Ctrl + C/V`. Šie Omarchy vieningos iškarpinės spartieji klavišai veikia visur.

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
| `Super + Alt + [` | Sumažinti internetinės kameros perdangą įrašymo metu |
| `Super + Alt + ]` | Padidinti internetinės kameros perdangą įrašymo metu |
| `Alt + Shift + L` | Kopijuoti dabartinį URL iš žiniatinklio programos ar naršyklės |
| `Alt + Shift + D` | Atsisiųsti dabartinio puslapio vaizdo įrašą į `~/Videos` |
| `Alt + Space` | Pradėti / sustabdyti diktavimą (reikia _Setup > Defaults > Dictation_) |
| `Right Alt` | Laikykite, kad diktuotumėte (reikia _Setup > Defaults > Dictation_) |

Atliekant ekrano įrašymus, spartusis klavišas pirmiausia paklausia, kokio garso norite, tada pradeda įrašyti. Paspauskite jį dar kartą, kad sustabdytumėte. Išsamesnės informacijos žr. [ekrano kopijos ir įrašymas](12-screenshots-recording.md).

Visos fiksavimo parinktys taip pat pasiekiamos Omarchy meniu (`Super + Space`) skiltyje _Trigger > Capture_.

## Pranešimai

| Spartusis klavišas                  | Funkcija              |
| ----------------------- | --------------------- |
| `Super + ,` | Veikti su naujausiu pranešimu: atidaryti jį arba paspausti vienintelį jo mygtuką, pasirinkti iš jo parinkčių arba atmesti, kai jų nėra  |
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

Papildomi fono paveikslėliai yra `~/.config/omarchy/backgrounds/<theme name>`. Taip pat pasiekiama Omarchy meniu per _Install > Style > Background_.

Visos stiliaus parinktys taip pat pasiekiamos Omarchy meniu (`Super + Space`) skiltyje _Appearance_.

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

Prefikso klavišas yra `Ctrl + Space` (taip pat veikia `Ctrl + B`). Šiuos derinius galite keisti faile `~/.config/tmux/tmux.conf`.

### Polangiai

| Spartusis klavišas                  | Funkcija              |
| ----------------------- | --------------------- |
| `Prefix + v` | Padalyti polangį šalia (vertikaliai) |
| `Prefix + h` | Padalyti polangį žemiau (horizontaliai) |
| `Prefix + x` | Sunaikinti polangį |
| `Prefix + z` | Perjungti polangio priartinimą (per visą ekraną) |
| `Alt + Enter` | Padalyti polangį žemiau (be prefikso) |
| `Alt + Shift + Enter` | Padalyti polangį šalia (be prefikso) |
| `Alt + Escape` | Sunaikinti polangį (be prefikso) |
| `Ctrl + Alt + Arrows` | Judėti tarp polangių |
| `Ctrl + Alt + Shift + Arrows` | Keisti polangių dydį |

### Langai

| Spartusis klavišas                  | Funkcija              |
| ----------------------- | --------------------- |
| `Prefix + c` | Naujas langas |
| `Prefix + k` | Sunaikinti langą |
| `Prefix + r` | Pervadinti langą |
| `Alt + 1-9` | Pereiti į konkretų langą |
| `Alt + Arrow Left/Right` | Judėti tarp langų |
| `Alt + Shift + Arrow Left/Right` | Perkelti langą į kairę / į dešinę |

### Seansai

| Spartusis klavišas                  | Funkcija              |
| ----------------------- | --------------------- |
| `Prefix + C` | Naujas seansas |
| `Prefix + K` | Sunaikinti seansą |
| `Prefix + R` | Pervadinti seansą |
| `Prefix + N` | Kitas seansas |
| `Prefix + P` | Ankstesnis seansas |
| `Alt + Arrow Up/Down` | Judėti tarp seansų |
| `Prefix + s` | Seansų sąrašas |
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
| `Prefix + ?` | Rodyti Tmux klavišų derinius |
| `Prefix + :` | Komandų eilutė |

### Tmux išdėstymo funkcijos

Šios funkcijos turi būti vykdomos Tmux seanso viduje.

| Komanda | Funkcija |
| ------- | -------- |
| `tdl <ai> [<second_ai>]` | Sukurti kūrimo išdėstymą su redaktoriumi, AI ir terminalu |
| `tdlm <ai> [<second_ai>]` | Sukurti kūrimo išdėstymą kiekvienam pakatalogiui |
| `tsl <count> <command>` | Sukurti kelių polangių spiečiaus išdėstymą |

## Ghostty terminalas

Ghostty terminalas įdiegiamas Omarchy meniu per _Install > Terminal_.

| Spartusis klavišas                  | Funkcija              |
| ----------------------- | --------------------- |
| `Ctrl + Shift + E` | Naujas padalijimas žemiau |
| `Ctrl + Shift + O` | Naujas padalijimas šalia |
| `Ctrl + Alt + Arrows` | Judėti tarp padalijimų |
| `Super + Ctrl + Shift + Arrows` | Keisti padalijimo dydį 10 eilučių |
| `Super + Ctrl + Shift + Alt + Arrows` | Keisti padalijimo dydį 100 eilučių |
| `Ctrl + Shift + T` | Naujas skirtukas  |
| `Ctrl + Shift + Arrows` | Judėti tarp skirtukų |
| `Alt + Numbers` | Pereiti į konkretų skirtuką |
| `Shift + Pg Up/Down` | Slinkti per istoriją |
| `Ctrl + Left mouse` | Atidaryti nuorodą naršyklėje |

## Failų tvarkyklė

| Spartusis klavišas              | Funkcija                       |
| ------------------- | ------------------------------ |
| `Ctrl + L`            | Eiti į kelią                     |
| `Space`               | Peržiūrėti failą (rodyklėmis naršoma) |
| `Alt + Up`       | Eiti aukštyn į tėvinį aplanką        |

## Neovim (w/ lazyvim)

### Naršymas

| Spartusis klavišas                   | Funkcija                        |
| ------------------------ | ------------------------------- |
| `Space`                    | Rodyti komandų parinktis            |
| `Space Space`              | Atidaryti failą naudojant apytikslę paiešką      |
| `Space E`                  | Perjungti šoninę juostą                  |
| `Space G G`                | Rodyti git valdiklius               |
| `Space S G`                | Ieškoti failo turinyje             |
| `Ctrl + W W`               | Šokinėti tarp šoninės juostos ir redaktoriaus |
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
| `R`                        | Pervadinti pažymėtą failą / katalogą     |
| `?`                        | Rodyti visų komandų žinyną      |

[Žiūrėti visus Neovim sparčiuosius klavišus, sukonfigūruotus LazyVim](https://www.lazyvim.org/keymaps).

## Greitieji jaustukai

Galite naudoti `Super + Ctrl + E`, kad būtų parodytas visas jaustukų parinkiklis, kuris įdės pasirinkimą į iškarpinę, arba galite naudoti šias greitos prieigos parinktis.

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
| `Shift + CapsLock M D` | 🤤 | seilėjimasis      |
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

Galite pridėti daugiau savų, redaguodami `~/.XCompose`, tada terminale paleidę `omarchy restart xcompose`, kad pakeitimai būtų pritaikyti.
