# Spartieji klavišai

Visus pagrindinius klavišų susiejimus galite pamatyti paspaudę `Super + K` (Tmux susiejimus su `Super + Alt + K`, o Herdr susiejimus su `Super + Ctrl + K`).

## Kaip išdėstyti spartieji klavišai

Kiekvienas spartusis klavišas yra tam tikroje plokštumoje, kurią nustato jo modifikatoriai, ir kiekviena plokštuma turi vieną paskirtį. Dėl to spartieji klavišai nesupainiojami tarpusavyje, ir paprastai galite atspėti, kur kas yra.

| Plokštuma | Kas joje yra | Pavyzdžiai |
| --- | --- | --- |
| `Super + key` | Sistema: langai, darbo sritys, išdėstymai ir pagrindiniai meniu | `Super + Space` Omarchy meniu, `Super + W` uždaryti langą, `Super + F` visas ekranas |
| `Super + Shift + key` | Programos | `Super + Shift + B` naršyklė, `Super + Shift + E` el. paštas, `Super + Shift + N` redaktorius |
| `Super + Ctrl + key` | Skydeliai ir sistemos meniu | `Super + Ctrl + A` garsas, `Super + Ctrl + N` tinklas, `Super + Ctrl + C` fiksavimo meniu |
| `Super + Ctrl + Alt + key` | Greiti veiksmai ir informaciniai pranešimai | `Super + Ctrl + Alt + T` rodyti laiką, `Super + Ctrl + Alt + B` baterija, `Super + Ctrl + Alt + C` ekrano kopija |

Pridėjus `Alt` prie sparčiojo klavišo, gaunamas to paties dalyko variantas, niekada kažkas nesusijusio:

- `Super + Shift + B` atidaro naršyklę; `Super + Shift + Alt + B` atidaro privatų langą
- `Super + Shift + E` atidaro el. paštą; `Super + Shift + Alt + E` pradeda naują laišką
- `Super + F` įjungia visą ekraną; `Super + Alt + F` įjungia visą plotį
- `Super + Ctrl + C` atidaro fiksavimo meniu; `Super + Ctrl + Alt + C` praleidžia meniu ir daro ekrano kopiją

Kai pridedate spartųjį klavišą:

1. Pagal tai, ką jis daro, pasirinkite plokštumą, tada pasirinkite klavišą.
2. Neperkeldinėkite esamo sparčiojo klavišo, kad atlaisvintumėte vietos. Raskite laisvą klavišą tinkamoje plokštumoje.
3. `Alt` naudokite tik sparčiojo klavišo be jo variantui.

Kai kurie spartieji klavišai laužo šias taisykles, nes taip patogiau. `Shift` su rodykle arba `Tab` perkelia arba apgręžia, o ne atidaro programą, o `Print`, medijos klavišai, `Alt + Tab` ir `Ctrl + Alt + Del` veikia taip, kaip ir visur kitur. Tai išimtys, o ne pavyzdžiai, kuriuos reikėtų kopijuoti.

Jei numatytasis variantas jums netinka (tarkime, norite `Super + Shift + S` ekrano kopijoms, kaip Windows), perriškite jį faile `~/.config/hypr/bindings.lua`.

## Naršymas

| Spartusis klavišas | Funkcija |
| ----------------------- | --------------------- |
| `Super + Space` | Omarchy meniu (programos ir visa kita) |
| `Super + Alt + Space` | Programų tinklelis |
| `Super + Escape` | Sistemos meniu (pristabdyti, paleisti iš naujo ir kt.) |
| `Super + Ctrl + L` | Užrakinti kompiuterį |
| `Super + W` or `Super + Q` | Uždaryti langą |
| `Ctrl + Alt + Del` | Uždaryti visus langus |
| `Super + K` | Rodyti visus sparčiuosius klavišus |
| `Super + Alt + K` | Rodyti tmux sparčiuosius klavišus |
| `Super + Ctrl + K` | Rodyti herdr sparčiuosius klavišus |
| `Super + M` | Sumažinti langą į doką |
| `Super + T` | Perjungti langą tarp plytelių ir slankiojančio režimų |
| `Super + J` | Perjungti lango padėtį (horizontali / vertikali) |
| `Super + O` | Perjungti lango iškėlimą į lipnų ir slankiojantį režimą |
| `Super + L` | Perjunginėti dwindle, scrolling ir floating išdėstymus |
| `Super + Alt + L` | Perjunginėti išdėstymus atvirkštine tvarka |
| `Super + P` | Perjungti pseudo lango stilių (natūralus ar ištemptas) |
| `Super + F` | Įjungti visą ekraną |
| `Super + Alt + F` | Įjungti visą plotį |
| `Super + Ctrl + F` | Įjungti visą ekraną lango viduje |
| `Super + 1…9/0` | Pereiti į konkrečią darbo sritį (0 yra 10) fokusuotame monitoriuje |
| `Super + Tab` | Pereiti į kitą darbo sritį fokusuotame monitoriuje |
| `Super + Shift + Tab` | Pereiti į ankstesnę darbo sritį fokusuotame monitoriuje |
| `Super + Ctrl + Tab` | Pereiti į buvusią darbo sritį fokusuotame monitoriuje |
| `Super + Shift + 1…9/0` | Perkelti langą į darbo sritį fokusuotame monitoriuje |
| `Super + Shift + Alt + 1…9/0` | Perkelti langą į darbo sritį fokusuotame monitoriuje nesisekant paskui jį |
| `Super + S` | Perjungti visą įrašų sritį |
| `Super + Alt + S` | Perkelti langą į visą įrašų sritį |
| `Super + Grave` | Perjungti Quake konsolę |
| `Super + Shift + Grave` | Perkelti langą į Quake konsolę |
| `Super + Shift + Ctrl + Arrows` | Perkelti langą į monitorių ta kryptimi |
| `Super + Shift + Alt + Arrows` | Perkelti darbo sritį į monitorių ta kryptimi |
| `Super + Arrow` | Perkelti fokusą į langą rodyklės kryptimi, ekrano krašte pereinant į tos pusės monitorių |
| `Super + Shift + Arrow` | Sukeisti langą su kitu rodyklės kryptimi, įskaitant esantį tos pusės monitoriuje |
| `Super + Minus` | Išplėsti langą į kairę |
| `Super + Equal` | Sumažinti langą į kairę |
| `Super + Shift + Minus` | Sumažinti langą aukštyn |
| `Super + Shift + Equal` | Išplėsti langą žemyn |
| `Super + Alt + Minus/Equal` | Tas pats dydžio keitimas mažesniais žingsniais |
| `Super + Ctrl + Minus/Equal` | Tas pats dydžio keitimas didesniais žingsniais |
| `Super + Alt + Home` | Išsaugoti lango plotį |
| `Super + Home` | Atkurti išsaugotą lango plotį |
| `Super + Left Mouse` | Vilkti langą aplink |
| `Super + Right Mouse` | Keisti lango dydį |
| `Super + Scroll Wheel` | Slinkti per darbo sritis fokusuotame monitoriuje |
| `Super + G` | Perjungti langų grupavimą |
| `Super + Alt + G` | Perkelti langą iš grupavimo |
| `Super + Alt + Tab` | Perjunginėti langus grupavime |
| `Super + Alt + Shift + Tab` | Atvirkščiai perjunginėti langus grupavime |
| `Super + Alt + Scroll Wheel` | Perjunginėti langus grupavime |
| `Super + Alt + 1/2/3/4/5` | Pereiti į konkretų langą grupavime |
| `Super + Alt + Arrow` | Perkelti langą į grupavimą rodyklės kryptimi, įskaitant esantį tos pusės monitoriuje |
| `Super + Ctrl + Left/Right` | Judėti tarp langų plytelių grupėje |
| `Super + Ctrl + Z` | Priartinti ekraną (kartokite, kad priartintumėte dar labiau) |
| `Super + Ctrl + Alt + Z` | Visiškai nutolinti ekraną |
| `Super + /` | Pereiti į priekį per monitoriaus mastelio parinktis |
| `Super + Alt + /` | Pereiti atgal per monitoriaus mastelio parinktis |
| `Alt + Tab` | Perjunginėti langus į priekį aktyvioje darbo srityje |
| `Alt + Shift + Tab` | Perjunginėti langus atgal aktyvioje darbo srityje |
| `Ctrl + Alt + Tab` | Perjunginėti fokusą į priekį per monitorius |
| `Ctrl + Alt + Shift + Tab` | Perjunginėti fokusą atgal per monitorius |
| `Super + I` | Perjungti įvesties kalbą (kai yra daugiau nei vienas išdėstymas ar įvesties metodas) |
| `Super + Shift + I` | Perjungti įvesties kalbą atgal |

Jutiklinio kilimėlio trijų ir keturių pirštų perbraukimai perjungia darbo sritis, perkelia langus ir atidaro meniu bei Quake konsolę; gestus žr. [klaviatūra, pelė ir jutiklinis kilimėlis](34-keyboard-mouse-trackpad.md).

Dydžio keitimo spartieji klavišai naudoja fizinius klavišus `code:20` ir `code:21` (XKB `<AE11>` ir `<AE12>`), nepriklausomai nuo ant klaviatūros atspausdintų simbolių. JAV klaviatūrose šie klavišai yra `-` ir `=`; japoniškose (JIS) klaviatūrose jie yra `-` ir `^`; ispaniškose klaviatūrose jie yra `'` ir `¡`. JIS klaviatūroje `Super + ^` yra `Super + Equal`, o `Super + Shift + -` (kuriuo įvedama `=`) yra `Super + Shift + Minus`.

## Sistemos valdikliai

| Spartusis klavišas | Funkcija |
| ----------------------- | --------------------- |
| `Super + Ctrl + A` | Garso skydelis |
| `Super + Ctrl + B` | Bluetooth skydelis |
| `Super + Ctrl + N` | Wi-Fi / tinklo skydelis |
| `Super + Ctrl + D` | Ekrano skydelis |
| `Super + Ctrl + P` | Maitinimo skydelis |
| `Super + Ctrl + X` | Agentų skydelis |
| `Super + Ctrl + Alt + X` | Vietinių modelių skydelis |
| `Super + Ctrl + Alt + D` | Kalendoriaus skydelis |
| `Super + Ctrl + Alt + E` | Pasaulio laikrodžio skydelis |
| `Super + Ctrl + 1-9` | Perjungti juostos skydelį pagal padėtį |
| `Super + Ctrl + S` | Bendrinimo meniu (per LocalSend) |
| `Super + Ctrl + C` | Fiksavimo valdikliai (ekrano kopija / -įrašymas / rinkiklis) |
| `Super + Ctrl + O` | Perjungimo meniu |
| `Super + Ctrl + H` | Aparatinės įrangos meniu |
| `Super + Ctrl + E` | Jaustukų rinkiklis |
| `Super + Ctrl + .` | Perkoduoti mediją |
| `Super + Shift + Ctrl + A` | Pasirinkti AI agentą |
| `Power` key | Sistemos meniu |
| `Super + Shift + Copilot` key | Omarchy meniu |

## Reguliavimas

| Spartusis klavišas | Funkcija |
| ----------------------- | --------------------- |
| `Shift + Brightness Up` | Didžiausias ekrano ryškumas |
| `Shift + Brightness Down` | Mažiausias ekrano ryškumas |
| `Alt + Brightness Up/Down` | Tikslūs 1 % ryškumo pakeitimai |
| `Alt + Volume Up/Down` | Tikslūs 1 % garsumo pakeitimai |
| `Keyboard Brightness Up/Down` | Klaviatūros apšvietimas ryškesnis / blankesnis |
| `Keyboard Backlight` | Perjunginėti klaviatūros apšvietimo lygius |
| `Ctrl + Brightness Up/Down` | Klaviatūros apšvietimas ryškesnis / blankesnis klaviatūrose be savų klavišų |
| `Mic Mute` | Nutildyti mikrofoną |
| `Shift + Mute` | Perjungti garso išvestį |
| `Touchpad Toggle` | Įjungti arba išjungti jutiklinį kilimėlį |
| `Display` key | Perjunginėti darbo srities išdėstymą |
| `Alt + Play` | Kitas takelis |
| `Alt + Shift + Play` | Ankstesnis takelis |

## Programų paleidimas

| Spartusis klavišas | Funkcija |
| ----------------------- | --------------------- |
| `Super + Return` | Terminalas |
| `Super + Alt + Return` | Tmux terminalas |
| `Super + Ctrl + Return` | Herdr (agentų tvarkyklė) |
| `Super + Shift + Return` or `Super + Shift + B` | Naršyklė |
| `Super + Shift + Alt + B` | Naršyklė (privati / inkognito) |
| `Super + Shift + F` | Failų tvarkyklė |
| `Super + Shift + Alt + F` | Failų tvarkyklė terminalo cwd kataloge |
| `Super + Shift + M` | Muzika (Spotify) |
| `Super + Shift + Alt + M` | Muzika (cliamp) |
| `Super + Shift + /` | Slaptažodžių tvarkyklė (1password) |
| `Super + Shift + Q` or `Calculator` key | Skaičiuotuvas (Omacalc) |
| `Super + Shift + D` | Docker (lazydocker, kai įdiegta) |
| `Super + Shift + T` | Veikla (btop) |
| `Super + Shift + N` | Redaktorius (Plain arba jūsų pasirinktas numatytasis) |
| `Super + Shift + C` | Kalendorius ([HEY](https://hey.com/)) |
| `Super + Shift + E` | El. paštas ([HEY](https://hey.com/)) |
| `Super + Shift + Alt + E` | Naujas el. laiškas ([HEY](https://hey.com/)) |
| `Super + Shift + A` | AI (ChatGPT) |
| `Super + Shift + Alt + A` | AI (Grok) |
| `Super + Shift + G` | Susirašinėjimo programa (Signal) |
| `Super + Shift + P` | Google Photos |
| `Super + Shift + S` | Google Maps |
| `Super + Shift + Alt + G` | Susirašinėjimo programa (WhatsApp) |
| `Super + Shift + Ctrl + G` | Susirašinėjimo programa (Google) |
| `Super + Shift + O` | Obsidian |
| `Super + Shift + W` | Rašymas (Omawrite) |
| `Super + Shift + X` | X |
| `Super + Shift + Alt + X` | X (naujas įrašas) |
| `Super + Shift + Y` | YouTube |

Keiskite / pridėkite susiejimus faile `~/.config/hypr/bindings.lua`.

## Universali iškarpinė

| Spartusis klavišas | Funkcija |
| ----------------------- | --------------------- |
| `Super + A` | Pasirinkti viską programose, kurios palaiko `Ctrl + A` |
| `Super + C` | Kopijuoti |
| `Super + X` | Iškirpti (ne terminale) |
| `Super + V` | Įklijuoti |
| `Super + Ctrl + V` | Iškarpinės tvarkyklė |

Paprastai Linux sistemoje reikia `Ctrl + Shift + C/V`, kad kopijuotumėte ir įklijuotumėte terminale, ir `Ctrl + C/V`, kad tai darytumėte visur kitur. Šie Omarchy suvienodinti iškarpinės spartieji klavišai veikia visur.

## Fiksavimas

| Spartusis klavišas | Funkcija |
| ------------------- | ------------------------------ |
| `Print Screen` | Ekrano kopija |
| `Super + Ctrl + Alt + C` | Ekrano kopija (ta pati kopija klaviatūroms be Print Screen klavišo) |
| `Super + Ctrl + C` | Fiksavimo meniu |
| `Alt + Print Screen` | Ekrano įrašymas |
| `Super + Shift + Ctrl + Alt + C` | Ekrano įrašymas be garso, praleidžiant meniu (paspauskite dar kartą, kad sustabdytumėte) |
| `Super + Print Screen` | Spalvų rinkiklis |
| `Super + Ctrl + Print Screen` | Teksto išgavimas į iškarpinę |
| `Super + Alt + [` | Įrašant sumažinti žiniatinklio kameros perdangą |
| `Super + Alt + ]` | Įrašant padidinti žiniatinklio kameros perdangą |
| `Alt + Shift + L` | Kopijuoti dabartinį URL iš žiniatinklio programos arba naršyklės |
| `Alt + Shift + D` | Atsisiųsti dabartinio puslapio vaizdo įrašą į `~/Videos` |
| `Alt + Space` | Pradėti / sustabdyti diktavimą (reikia _Sąranka > Numatytieji nustatymai > Diktavimas_) |
| `Right Alt` | Laikyti norint diktuoti (reikia _Sąranka > Numatytieji nustatymai > Diktavimas_) |

Įrašant ekraną, spartusis klavišas pirmiausia paklausia, kurio garso norite, tada pradeda įrašymą. Paspauskite jį dar kartą, kad sustabdytumėte. Išsamesnės informacijos žr. [ekrano kopijos ir įrašymas](12-screenshots-recording.md).

Visos fiksavimo parinktys taip pat pasiekiamos Omarchy meniu (`Super + Space`) skiltyje _Paleidiklis > Fiksavimas_.

## Pranešimai

| Spartusis klavišas | Funkcija |
| ----------------------- | --------------------- |
| `Super + ,` | Veikti pagal naujausią pranešimą: atidaryti jį arba paspausti vienintelį jo mygtuką, pasirinkti iš jo variantų arba atmesti jį, kai variantų nėra |
| `Super + Shift + ,` | Atmesti visus pranešimus |
| `Super + Ctrl + ,` | Valdyti pranešimus klaviatūra |
| `Super + Alt + ,` | Atmesti naujausią pranešimą |
| `Super + Shift + Alt + ,` | Atidaryti pranešimų istoriją |
| `Super + Ctrl + Alt + ,` | Perjungti pranešimų nutildymą |

## Stilius

| Spartusis klavišas | Funkcija |
| ----------------------- | --------------------- |
| `Super + Ctrl + T` | Pasirinkti naują temą (taip pat `Super + Ctrl + Shift + Space`) |
| `Super + Ctrl + W` | Pasirinkti temos foną (taip pat `Super + Ctrl + Space`) |
| `Super + Backspace` | Perjungti lango skaidrumą |
| `Super + Ctrl + Backspace` | Perjungti vieno lango kvadratinį kraštinių santykį |

Papildomi fono vaizdai yra `~/.config/omarchy/backgrounds/<theme name>`. Taip pat pasiekiama Omarchy meniu skiltyje _Diegti > Stilius > Fonas_.

Visos stiliaus parinktys taip pat pasiekiamos Omarchy meniu (`Super + Space`) skiltyje _Išvaizda_.

## Perjungikliai

| Spartusis klavišas | Funkcija |
| ----------------------- | --------------------- |
| `Super + Ctrl + I` | Perjungti užrakinimą esant neaktyvumui |
| `Super + Ctrl + Delete` | Įjungti / išjungti nešiojamojo kompiuterio ekraną |
| `Super + Ctrl + Alt + Delete` | Perjungti nešiojamojo kompiuterio ekrano veidrodinį atspindėjimą |
| `Super + Shift + Space` | Perjungti viršutinę juostą |
| `Shift + Mute` | Perjungti į kitą garso išvestį |
| `Shift + Play` | Perjungti į kitą medijos šaltinį |
| `Super + Shift + Backspace` | Perjungti tarpų tarp langų rodymą |
| `Super + Ctrl + Alt + F` | Perjungti viso ekrano darbalaukį (viršutinė juosta + tarpai tarp langų) |

## Priminimai

| Spartusis klavišas | Funkcija |
| ----------------------- | --------------------- |
| `Super + Ctrl + R` | Nustatyti priminimą |
| `Super + Ctrl + Alt + R` | Žiūrėti visus priminimus |
| `Super + Ctrl + Shift + R` | Išvalyti visus priminimus |

## Informaciniai pranešimai

| Spartusis klavišas | Funkcija |
| ----------------------- | --------------------- |
| `Super + Ctrl + Alt + T` | Rodyti laiką kaip pranešimą |
| `Super + Ctrl + Alt + B` | Rodyti bateriją kaip pranešimą |
| `Super + Ctrl + Alt + W` | Perjungti orų rodymą kaip pranešimą |

## Tmux

Priešdėlio klavišas yra `Ctrl + Space` (taip pat veikia `Ctrl + B`). Šiuos susiejimus galite keisti faile `~/.config/tmux/tmux.conf`.

### Sritys

| Spartusis klavišas | Funkcija |
| ----------------------- | --------------------- |
| `Prefix + v` | Padalyti sritį šalia (vertikaliai) |
| `Prefix + h` | Padalyti sritį apačioje (horizontaliai) |
| `Prefix + x` | Uždaryti sritį |
| `Prefix + z` | Perjungti srities mastelį (visas ekranas) |
| `Alt + Enter` | Padalyti sritį apačioje (be priešdėlio) |
| `Alt + Shift + Enter` | Padalyti sritį šalia (be priešdėlio) |
| `Alt + Escape` | Uždaryti sritį (be priešdėlio) |
| `Ctrl + Alt + Arrows` | Judėti tarp sričių |
| `Ctrl + Alt + Shift + Arrows` | Keisti sričių dydį |

### Langai

| Spartusis klavišas | Funkcija |
| ----------------------- | --------------------- |
| `Prefix + c` | Naujas langas |
| `Prefix + k` | Uždaryti langą |
| `Prefix + r` | Pervardyti langą |
| `Alt + 1-9` | Pereiti į konkretų langą |
| `Alt + Arrow Left/Right` | Judėti tarp langų |
| `Alt + Shift + Arrow Left/Right` | Perkelti langą į kairę / dešinę |

### Seansai

| Spartusis klavišas | Funkcija |
| ----------------------- | --------------------- |
| `Prefix + C` | Naujas seansas |
| `Prefix + K` | Uždaryti seansą |
| `Prefix + R` | Pervardyti seansą |
| `Prefix + N` | Kitas seansas |
| `Prefix + P` | Ankstesnis seansas |
| `Alt + Arrow Up/Down` | Judėti tarp seansų |
| `Prefix + s` | Rodyti seansų sąrašą |
| `Prefix + d` | Atsijungti nuo seanso |

### Kopijavimo režimas (vi stiliaus)

| Spartusis klavišas | Funkcija |
| ----------------------- | --------------------- |
| `Prefix + [` | Įjungti kopijavimo režimą |
| `v` | Pradėti žymėjimą (kopijavimo režime) |
| `y` | Kopijuoti žymėjimą (kopijavimo režime) |

### Bendra

| Spartusis klavišas | Funkcija |
| ----------------------- | --------------------- |
| `Prefix + q` | Iš naujo įkelti konfigūraciją |
| `Prefix + ?` | Rodyti Tmux klavišų susiejimus |
| `Prefix + :` | Komandų eilutė |

### Tmux išdėstymo funkcijos

Šias funkcijas reikia vykdyti Tmux seanso viduje.

| Komanda | Funkcija |
| ------- | -------- |
| `tdl <ai> [<second_ai>]` | Sukurti kūrimo išdėstymą su redaktoriumi, AI ir terminalu |
| `tdlm <ai> [<second_ai>]` | Sukurti kūrimo išdėstymą kiekvienam pakatalogiui |
| `tsl <count> <command>` | Sukurti kelių sričių spiečiaus išdėstymą |

## Ghostty Terminal

Ghostty terminalas įdiegiamas per Omarchy meniu naudojant _Diegti > Terminalas_.

| Spartusis klavišas | Funkcija |
| ----------------------- | --------------------- |
| `Ctrl + Shift + E` | Naujas padalijimas apačioje |
| `Ctrl + Shift + O` | Naujas padalijimas šalia |
| `Ctrl + Alt + Arrows` | Judėti tarp padalijimų |
| `Super + Ctrl + Shift + Arrows` | Keisti padalijimo dydį 10 eilučių |
| `Super + Ctrl + Shift + Alt + Arrows` | Keisti padalijimo dydį 100 eilučių |
| `Ctrl + Shift + T` | Naujas skirtukas |
| `Ctrl + Shift + Arrows` | Judėti tarp skirtukų |
| `Alt + Numbers` | Pereiti į konkretų skirtuką |
| `Shift + Pg Up/Down` | Slinkti istoriją |
| `Ctrl + Left mouse` | Atidaryti nuorodą naršyklėje |

## File Manager

| Spartusis klavišas | Funkcija |
| ------------------- | ------------------------------ |
| `Ctrl + L` | Eiti į kelią |
| `Space` | Peržiūrėti failą (naršoma rodyklėmis) |
| `Alt + Up` | Eiti į pirminį aplanką |

## Neovim (w/ lazyvim)

### Navigation

| Spartusis klavišas | Funkcija |
| ------------------------ | ------------------------------- |
| `Space` | Rodyti komandų parinktis |
| `Space Space` | Atidaryti failą naudojant neaiškią paiešką |
| `Space E` | Perjungti šoninę juostą |
| `Space G G` | Rodyti git valdiklius |
| `Space S G` | Ieškoti failo turinio |
| `Ctrl + W W` | Peršokti tarp šoninės juostos ir redaktoriaus |
| `Ctrl + Left/right arrow` | Keisti šoninės juostos dydį |
| `Shift + H` | Eiti į kairįjį failo skirtuką |
| `Shift + L` | Eiti į dešinįjį failo skirtuką |
| `Space B D` | Uždaryti failo skirtuką |

### Esant šoninėje juostoje

| Spartusis klavišas | Funkcija |
| ------------------------ | ------------------------------- |
| `A` | Pridėti naują failą pirminiame kataloge |
| `Shift + A` | Pridėti naują pakatalogį pirminiame kataloge |
| `D` | Ištrinti pažymėtą failą / katalogą |
| `M` | Perkelti pažymėtą failą / katalogą |
| `R` | Pervardyti pažymėtą failą / katalogą |
| `?` | Rodyti visų komandų pagalbą |

[Žr. visus Neovim sparčiuosius klavišus, kuriuos sukonfigūravo LazyVim](https://www.lazyvim.org/keymaps).

## Greiti jaustukai

Galite naudoti `Super + Ctrl + E`, kad būtų parodytas išsamus jaustukų rinkiklis, kuris pasirinktą jaustuką įdės į iškarpinę, arba galite naudoti šias greitos prieigos parinktis.

| Spartusis klavišas | EM | Užuomina |
| ------------ | -- | ---------- |
| `Shift + CapsLock M S` | 😄 | šypsena |
| `Shift + CapsLock M C` | 😂 | verksmas |
| `Shift + CapsLock M L` | 😍 | meilė |
| `Shift + CapsLock M V` | ✌️ | pergalė |
| `Shift + CapsLock M H` | ❤️ | širdis |
| `Shift + CapsLock M Y` | 👍 | taip |
| `Shift + CapsLock M N` | 👎 | ne |
| `Shift + CapsLock M F` | 🖕 | fuck |
| `Shift + CapsLock M W` | 🤞 | palinkėjimas |
| `Shift + CapsLock M R` | 🤘 | rokas |
| `Shift + CapsLock M K` | 😘 | bučinys |
| `Shift + CapsLock M E` | 🙄 | akių vartymas |
| `Shift + CapsLock M I` | 😉 | mirktelėjimas |
| `Shift + CapsLock M P` | 🙏 | malda |
| `Shift + CapsLock M D` | 🤤 | seilėtekis |
| `Shift + CapsLock M M` | 💰 | pinigai |
| `Shift + CapsLock M X` | 🎉 | xellebrate |
| `Shift + CapsLock M 1` | 💯 | 100% |
| `Shift + CapsLock M T` | 🥂 | tostas |
| `Shift + CapsLock M O` |👌 | ok |
| `Shift + CapsLock M G` |👋 | pasisveikinimas |
| `Shift + CapsLock M A` |💪 | ranka |
| `Shift + CapsLock M B` |🤯 | sprogimas |

## Greiti užbaigimai

| Spartusis klavišas | Užbaigimas |
| ------------ |  ---------- |
| `Shift + CapsLock Space Space` | — (mdash) |
| `Shift + CapsLock Space N` | Jūsų vardas (kaip įvesta sąrankos metu) |
| `Shift + CapsLock Space E` | Jūsų el. paštas (kaip įvesta sąrankos metu) |

Galite pridėti daugiau savų redaguodami `~/.XCompose`, tada terminale paleisdami `omarchy restart xcompose`, kad pakeitimai būtų pritaikyti.
