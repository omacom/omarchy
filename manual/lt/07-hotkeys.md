# Spartieji klavišai

Visus pagrindinius klavišų susiejimus galite pamatyti paspaudę `Super + K` (Tmux susiejimus – `Super + Alt + K`, o Herdr susiejimus – `Super + Ctrl + K`).

## Kaip išdėstyti spartieji klavišai

Kiekvienas spartusis klavišas yra vienoje plokštumoje, kurią nustato jo modifikatoriai, ir kiekviena plokštuma turi vieną paskirtį. Būtent tai neleidžia spartiesiems klavišams susilieti tarpusavyje, todėl paprastai galite atspėti, kur kas yra.

| Plokštuma | Kas joje yra | Pavyzdžiai |
| --- | --- | --- |
| `Super + key` | Sistema: langai, darbo sritys, išdėstymai ir pagrindiniai meniu | `Super + Space` Omarchy meniu, `Super + W` uždaryti langą, `Super + F` per visą ekraną |
| `Super + Shift + key` | Programos | `Super + Shift + B` naršyklė, `Super + Shift + E` el. paštas, `Super + Shift + N` redaktorius |
| `Super + Ctrl + key` | Skydeliai ir sistemos meniu | `Super + Ctrl + A` garsas, `Super + Ctrl + N` tinklas, `Super + Ctrl + C` fiksavimo meniu |
| `Super + Ctrl + Alt + key` | Greiti veiksmai ir pranešimai | `Super + Ctrl + Alt + T` rodyti laiką, `Super + Ctrl + Alt + B` baterija, `Super + Ctrl + Alt + C` ekrano kopija |

Pridėjus `Alt` prie sparčiojo klavišo, gaunate to paties dalyko variantą, niekada nieko nesusijusio:

- `Super + Shift + B` atidaro naršyklę; `Super + Shift + Alt + B` atidaro privatų langą
- `Super + Shift + E` atidaro el. paštą; `Super + Shift + Alt + E` pradeda naują laišką
- `Super + F` įjungia visą ekraną; `Super + Alt + F` išplečia per visą plotį
- `Super + Ctrl + C` atidaro fiksavimo meniu; `Super + Ctrl + Alt + C` praleidžia meniu ir daro ekrano kopiją

Pridėdami spartųjį klavišą:

1. Plokštumą rinkitės pagal tai, ką klavišas daro, tada rinkitės klavišą.
2. Neperkelkite esamo sparčiojo klavišo, kad atlaisvintumėte vietos. Raskite laisvą klavišą tinkamoje plokštumoje.
3. `Alt` naudokite tik to paties sparčiojo klavišo be jo variantui.

Keli spartieji klavišai laužo šias taisykles, nes taip patogiau. `Shift` su rodykle arba `Tab` perkelia arba apgręžia, o ne atidaro programą, o `Print`, medijos klavišai, `Alt + Tab` ir `Ctrl + Alt + Del` veikia taip, kaip visur kitur. Tai išimtys, o ne pavyzdžiai, kuriuos reikėtų kopijuoti.

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
| `Super + T` | Perjungti langą tarp išdėstymo plytelėmis ir slankiojo režimo |
| `Super + J` | Perjungti lango padėtį (horizontali / vertikali) |
| `Super + O` | Perjungti lango pavertimą lipniu slankiuoju langu |
| `Super + L` | Cikliškai perjungti dwindle, slinkties ir slankųjį išdėstymus |
| `Super + Alt + L` | Cikliškai perjungti išdėstymus atvirkštine tvarka |
| `Super + P` | Perjungti pseudo lango stilių (natūralus ar ištemptas) |
| `Super + F` | Įjungti visą ekraną |
| `Super + Alt + F` | Išplėsti per visą plotį |
| `Super + Ctrl + F` | Įjungti visą ekraną lango viduje |
| `Super + 1/2/3/4` | Pereiti į konkrečią darbo sritį fokusuotame monitoriuje |
| `Super + Tab` | Pereiti į kitą darbo sritį fokusuotame monitoriuje |
| `Super + Shift + Tab` | Pereiti į ankstesnę darbo sritį fokusuotame monitoriuje |
| `Super + Ctrl + Tab` | Pereiti į buvusią darbo sritį fokusuotame monitoriuje |
| `Super + Shift + 1/2/3/4` | Perkelti langą į darbo sritį fokusuotame monitoriuje |
| `Super + Shift + Alt + 1/2/3/4` | Perkelti langą į darbo sritį fokusuotame monitoriuje nesekant paskui jį |
| `Super + S` | Perjungti visą juodraštį |
| `Super + Alt + S` | Perkelti langą į visą juodraštį |
| `Super + Grave` | Įjungti / išjungti Quake konsolę |
| `Super + Shift + Grave` | Perkelti langą į Quake konsolę |
| `Super + Shift + Ctrl + Arrows` | Perkelti langą į monitorių ta kryptimi |
| `Super + Shift + Alt + Arrows` | Perkelti darbo sritį į monitorių ta kryptimi |
| `Super + Arrow` | Perkelti fokusą į langą rodyklės kryptimi, ekrano krašte pereinant į tos pusės monitorių |
| `Super + Shift + Arrow` | Sukeisti langą su kitu rodyklės kryptimi, įskaitant langą tos pusės monitoriuje |
| `Super + Minus` | Išplėsti langą į kairę |
| `Super + Equal` | Susiaurinti langą į kairę |
| `Super + Shift + Minus` | Sumažinti langą į viršų |
| `Super + Shift + Equal` | Išplėsti langą žemyn |
| `Super + Alt + Minus/Equal` | Tas pats dydžio keitimas mažesniais žingsniais |
| `Super + Ctrl + Minus/Equal` | Tas pats dydžio keitimas didesniais žingsniais |
| `Super + Alt + Home` | Įrašyti lango plotį |
| `Super + Home` | Atkurti įrašytą lango plotį |
| `Super + Left Mouse` | Vilkti langą |
| `Super + Right Mouse` | Keisti lango dydį |
| `Super + Scroll Wheel` | Slinkti per darbo sritis fokusuotame monitoriuje |
| `Super + G` | Įjungti / išjungti langų grupavimą |
| `Super + Alt + G` | Perkelti langą iš grupės |
| `Super + Alt + Tab` | Cikliškai perjungti langus grupėje |
| `Super + Alt + Shift + Tab` | Cikliškai perjungti langus grupėje atgal |
| `Super + Alt + Scroll Wheel` | Cikliškai perjungti langus grupėje |
| `Super + Alt + 1/2/3/4/5` | Pereiti į konkretų langą grupėje |
| `Super + Alt + Arrow` | Perkelti langą į grupę rodyklės kryptimi, įskaitant langą tos pusės monitoriuje |
| `Super + Ctrl + Left/Right` | Judėti tarp langų plytelių grupės viduje |
| `Super + Ctrl + Z` | Priartinti ekraną (kartokite, kad priartintumėte daugiau) |
| `Super + Ctrl + Alt + Z` | Visiškai atitolinti ekraną |
| `Super + /` | Pereiti pirmyn per monitoriaus mastelio parinktis |
| `Super + Alt + /` | Pereiti atgal per monitoriaus mastelio parinktis |
| `Alt + Tab` | Cikliškai pereiti pirmyn per langus aktyvioje darbo srityje |
| `Alt + Shift + Tab` | Cikliškai pereiti atgal per langus aktyvioje darbo srityje |
| `Ctrl + Alt + Tab` | Cikliškai perkelti fokusą pirmyn per monitorius |
| `Ctrl + Alt + Shift + Tab` | Cikliškai perkelti fokusą atgal per monitorius |

Dydžio keitimo spartieji klavišai naudoja fizinius klavišus `code:20` ir `code:21` (XKB `<AE11>` ir `<AE12>`), nepriklausomai nuo ant klaviatūros atspausdintų simbolių. JAV klaviatūrose šie klavišai yra `-` ir `=`; japoniškose (JIS) klaviatūrose – `-` ir `^`; ispaniškose klaviatūrose – `'` ir `¡`. JIS klaviatūroje `Super + ^` yra `Super + Equal`, o `Super + Shift + -` (kuriuo įvedama `=`) yra `Super + Shift + Minus`.

## Sistemos valdikliai

| Spartusis klavišas | Funkcija |
| ----------------------- | --------------------- |
| `Super + Ctrl + A` | Garso skydelis |
| `Super + Ctrl + B` | Bluetooth skydelis |
| `Super + Ctrl + N` | Wi-Fi / tinklo skydelis |
| `Super + Ctrl + D` | Ekrano skydelis |
| `Super + Ctrl + P` | Maitinimo skydelis |
| `Super + Ctrl + Alt + D` | Kalendoriaus skydelis |
| `Super + Ctrl + Alt + E` | Pasaulio laikrodžio skydelis |
| `Super + Ctrl + 1-9` | Perjungti juostos skydelį pagal padėtį |
| `Super + Ctrl + S` | Bendrinimo meniu (per LocalSend) |
| `Super + Ctrl + C` | Fiksavimo valdikliai (ekrano kopija / įrašymas / parinkiklis) |
| `Super + Ctrl + O` | Perjungti meniu |
| `Super + Ctrl + H` | Aparatinės įrangos meniu |
| `Super + Ctrl + E` | Jaustukų parinkiklis |
| `Super + Ctrl + .` | Transkoduoti mediją |
| `Super + Shift + Ctrl + A` | Pasirinkti AI agentą |

## Reguliavimas

| Spartusis klavišas | Funkcija |
| ----------------------- | --------------------- |
| `Shift + Brightness Up` | Didžiausias ekrano ryškumas |
| `Shift + Brightness Down` | Mažiausias ekrano ryškumas |
| `Alt + Brightness Up/Down` | Tikslūs 1 % ryškumo pokyčiai |
| `Alt + Volume Up/Down` | Tikslūs 1 % garsumo pokyčiai |
| `Keyboard Brightness Up/Down` | Klaviatūros apšvietimas ryškiau / blankiau |
| `Keyboard Backlight` | Cikliškai perjungti klaviatūros apšvietimo lygius |
| `Alt + Play` | Kitas takelis |
| `Alt + Shift + Play` | Ankstesnis takelis |

## Programų paleidimas

| Spartusis klavišas | Funkcija |
| ----------------------- | --------------------- |
| `Super + Return` | Terminalas |
| `Super + Alt + Return` | Tmux terminalas |
| `Super + Ctrl + Return` | Herdr (agentų tvarkytuvė) |
| `Super + Shift + Return` | Naršyklė |
| `Super + Shift + Alt + B` | Naršyklė (privatus / inkognito režimas) |
| `Super + Shift + F` | Failų tvarkytuvė |
| `Super + Shift + Alt + F` | Failų tvarkytuvė terminalo cwd aplanke |
| `Super + Shift + M` | Muzika (Spotify) |
| `Super + Shift + Alt + M` | Muzika (cliamp) |
| `Super + Shift + /` | Slaptažodžių tvarkytuvė (1password) |
| `Super + Shift + Q` | Skaičiuotuvas (Omacalc) |
| `Super + Shift + T` | Aktyvumas (btop) |
| `Super + Shift + N` | Redaktorius (Neovim) |
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
| `Super + Shift + Alt + X` | X Compose |
| `Super + Shift + Y` | YouTube |

Keiskite / pridėkite susiejimus faile `~/.config/hypr/bindings.lua`.

## Universali iškarpinė

| Spartusis klavišas | Funkcija |
| ----------------------- | --------------------- |
| `Super + A` | Pažymėti viską programose, kurios palaiko `Ctrl + A` |
| `Super + C` | Kopijuoti |
| `Super + X` | Iškirpti (ne terminale) |
| `Super + V` | Įklijuoti |
| `Super + Ctrl + V` | Iškarpinės tvarkytuvė |

Paprastai Linux sistemoje terminale kopijuoti ir įklijuoti reikia `Ctrl + Shift + C/V`, o visur kitur – `Ctrl + C/V`. Šie Omarchy suvienodinti iškarpinės spartieji klavišai veikia visur.

## Fiksavimas

| Spartusis klavišas | Funkcija |
| ------------------- | ------------------------------ |
| `Print Screen` | Ekrano kopija |
| `Super + Ctrl + Alt + C` | Ekrano kopija (tas pats kadras, klaviatūroms be Print Screen klavišo) |
| `Super + Ctrl + C` | Fiksavimo meniu |
| `Alt + Print Screen` | Ekrano įrašymas |
| `Super + Print Screen` | Spalvų parinkiklis |
| `Super + Ctrl + Print Screen` | Teksto išgavimas į iškarpinę |
| `Super + Alt + [` | Sumažinti internetinės kameros perdangą įrašymo metu |
| `Super + Alt + ]` | Padidinti internetinės kameros perdangą įrašymo metu |
| `Alt + Shift + L` | Kopijuoti dabartinį URL iš žiniatinklio programos arba Chromium |
| `Alt + Shift + D` | Atsisiųsti dabartinio puslapio vaizdo įrašą į `~/Videos` |
| `Alt + Space` | Pradėti / sustabdyti diktavimą (reikia _Setup > Defaults > Dictation_) |
| `Right Alt` | Laikyti nuspaudus, kad diktuotumėte (reikia _Setup > Defaults > Dictation_) |

Ekrano įrašymų atveju spartusis klavišas pirmiausia paklausia, kokio garso norite, tada pradeda įrašyti. Paspauskite jį dar kartą, kad sustabdytumėte. Išsamesnės informacijos žr. [ekrano kopijos ir įrašymas](12-screenshots-recording.md).

Visos fiksavimo parinktys taip pat pasiekiamos Omarchy meniu (`Super + Space`) skiltyje _Trigger > Capture_.

## Pranešimai

| Spartusis klavišas | Funkcija |
| ----------------------- | --------------------- |
| `Super + ,` | Atlikti veiksmą su naujausiu pranešimu: atidaryti jį arba paspausti vienintelį jo mygtuką, pasirinkti iš jo parinkčių arba atmesti jį, kai jis neturi nė vienos |
| `Super + Shift + ,` | Atmesti visus pranešimus |
| `Super + Ctrl + ,` | Valdyti pranešimus klaviatūra |
| `Super + Alt + ,` | Atmesti naujausią pranešimą |
| `Super + Shift + Alt + ,` | Atidaryti pranešimų istoriją |
| `Super + Ctrl + Alt + ,` | Įjungti / išjungti pranešimų nutildymą |

## Stilius

| Spartusis klavišas | Funkcija |
| ----------------------- | --------------------- |
| `Super + Ctrl + T` | Pasirinkti naują temą (taip pat `Super + Ctrl + Shift + Space`) |
| `Super + Ctrl + W` | Pasirinkti temos foną (taip pat `Super + Ctrl + Space`) |
| `Super + Backspace` | Įjungti / išjungti lango skaidrumą |
| `Super + Ctrl + Backspace` | Įjungti / išjungti vieno lango kvadratinį kraštinių santykį |

Papildomi fono paveikslėliai yra `~/.config/omarchy/backgrounds/<theme name>`. Taip pat pasiekiama Omarchy meniu per _Install > Style > Background_.

Visos stiliaus parinktys taip pat pasiekiamos Omarchy meniu (`Super + Space`) skiltyje _Style_.

## Perjungimai

| Spartusis klavišas | Funkcija |
| ----------------------- | --------------------- |
| `Super + Ctrl + I` | Įjungti / išjungti užrakinimą esant neaktyvumui |
| `Super + Ctrl + Delete` | Įjungti / išjungti nešiojamojo kompiuterio ekraną |
| `Super + Ctrl + Alt + Delete` | Įjungti / išjungti nešiojamojo kompiuterio ekrano veidrodinį atspindėjimą |
| `Super + Shift + Space` | Įjungti / išjungti viršutinę juostą |
| `Shift + Mute` | Perjungti į kitą garso išvestį |
| `Shift + Play` | Perjungti į kitą medijos šaltinį |
| `Super + Shift + Backspace` | Įjungti / išjungti tarpus tarp langų |
| `Super + Ctrl + Alt + F` | Įjungti / išjungti viso ekrano darbalaukį (viršutinė juosta + tarpai tarp langų) |

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
| `Super + Ctrl + Alt + W` | Įjungti / išjungti orus kaip pranešimą |

## Tmux

Prefikso klavišas yra `Ctrl + Space` (`Ctrl + B` taip pat veikia). Šiuos susiejimus galite keisti faile `~/.config/tmux/tmux.conf`.

### Sritys

| Spartusis klavišas | Funkcija |
| ----------------------- | --------------------- |
| `Prefix + v` | Padalyti sritį šalia (vertikaliai) |
| `Prefix + h` | Padalyti sritį žemiau (horizontaliai) |
| `Prefix + x` | Uždaryti sritį |
| `Prefix + z` | Įjungti / išjungti srities priartinimą (per visą ekraną) |
| `Alt + Enter` | Padalyti sritį žemiau (be prefikso) |
| `Alt + Shift + Enter` | Padalyti sritį šalia (be prefikso) |
| `Alt + Escape` | Uždaryti sritį (be prefikso) |
| `Ctrl + Alt + Arrows` | Judėti tarp sričių |
| `Ctrl + Alt + Shift + Arrows` | Keisti sričių dydį |

### Langai

| Spartusis klavišas | Funkcija |
| ----------------------- | --------------------- |
| `Prefix + c` | Naujas langas |
| `Prefix + k` | Uždaryti langą |
| `Prefix + r` | Pervadinti langą |
| `Alt + 1-9` | Pereiti į konkretų langą |
| `Alt + Arrow Left/Right` | Judėti tarp langų |
| `Alt + Shift + Arrow Left/Right` | Perkelti langą į kairę / dešinę |

### Seansai

| Spartusis klavišas | Funkcija |
| ----------------------- | --------------------- |
| `Prefix + C` | Naujas seansas |
| `Prefix + K` | Užbaigti seansą |
| `Prefix + R` | Pervadinti seansą |
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

### Bendri

| Spartusis klavišas | Funkcija |
| ----------------------- | --------------------- |
| `Prefix + q` | Įkelti konfigūraciją iš naujo |
| `Prefix + ?` | Rodyti Tmux klavišų susiejimus |
| `Prefix + :` | Komandinė eilutė |

### Tmux išdėstymo funkcijos

Šios funkcijos turi būti vykdomos Tmux seanso viduje.

| Komanda | Funkcija |
| ------- | -------- |
| `tdl <ai> [<second_ai>]` | Sukurti kūrimo išdėstymą su redaktoriumi, AI ir terminalu |
| `tdlm <ai> [<second_ai>]` | Sukurti kūrimo išdėstymą kiekvienam pokatalogiui |
| `tsl <count> <command>` | Sukurti kelių sričių spiečiaus išdėstymą |

## Ghostty terminalas

Ghostty terminalas įdiegiamas Omarchy meniu per _Install > Terminal_.

| Spartusis klavišas | Funkcija |
| ----------------------- | --------------------- |
| `Ctrl + Shift + E` | Naujas padalijimas žemiau |
| `Ctrl + Shift + O` | Naujas padalijimas šalia |
| `Ctrl + Alt + Arrows` | Judėti tarp padalijimų |
| `Super + Ctrl + Shift + Arrows` | Keisti padalijimo dydį 10 eilučių |
| `Super + Ctrl + Shift + Alt + Arrows` | Keisti padalijimo dydį 100 eilučių |
| `Ctrl + Shift + T` | Naujas skirtukas |
| `Ctrl + Shift + Arrows` | Judėti tarp skirtukų |
| `Alt + Numbers` | Pereiti į konkretų skirtuką |
| `Shift + Pg Up/Down` | Slinkti per istoriją |
| `Ctrl + Left mouse` | Atidaryti nuorodą naršyklėje |

## Failų tvarkytuvė

| Spartusis klavišas | Funkcija |
| ------------------- | ------------------------------ |
| `Ctrl + L` | Eiti į kelią |
| `Space` | Peržiūrėti failą (rodyklėmis naršoma) |
| `Alt + Up` | Eiti į tėvinį aplanką |

## Neovim (su lazyvim)

### Naršymas

| Spartusis klavišas | Funkcija |
| ------------------------ | ------------------------------- |
| `Space` | Rodyti komandų parinktis |
| `Space Space` | Atidaryti failą naudojant apytikslę paiešką |
| `Space E` | Įjungti / išjungti šoninę juostą |
| `Space G G` | Rodyti git valdiklius |
| `Space S G` | Ieškoti failo turinyje |
| `Ctrl + W W` | Šokti tarp šoninės juostos ir redaktoriaus |
| `Ctrl + Left/right arrow` | Keisti šoninės juostos dydį |
| `Shift + H` | Eiti į kairįjį failo skirtuką |
| `Shift + L` | Eiti į dešinįjį failo skirtuką |
| `Space B D` | Uždaryti failo skirtuką |

### Esant šoninėje juostoje

| Spartusis klavišas | Funkcija |
| ------------------------ | ------------------------------- |
| `A` | Pridėti naują failą tėviniame kataloge |
| `Shift + A` | Pridėti naują pokatalogį tėviniame kataloge |
| `D` | Ištrinti pažymėtą failą / katalogą |
| `M` | Perkelti pažymėtą failą / katalogą |
| `R` | Pervadinti pažymėtą failą / katalogą |
| `?` | Rodyti visų komandų žinyną |

[Žiūrėti visus Neovim sparčiuosius klavišus, sukonfigūruotus LazyVim](https://www.lazyvim.org/keymaps).

## Greitieji jaustukai

Galite naudoti `Super + Ctrl + E`, kad pamatytumėte visą jaustukų parinkiklį, kuris įdės pasirinkimą į iškarpinę, arba galite naudoti šias greitosios prieigos parinktis.

| Spartusis klavišas | EM | Užuomina |
| ------------ | -- | ---------- |
| `Shift + CapsLock M S` | 😄 | šypsena |
| `Shift + CapsLock M C` | 😂 | verkti |
| `Shift + CapsLock M L` | 😍 | meilė |
| `Shift + CapsLock M V` | ✌️ | pergalė |
| `Shift + CapsLock M H` | ❤️ | širdis |
| `Shift + CapsLock M Y` | 👍 | taip |
| `Shift + CapsLock M N` | 👎 | ne |
| `Shift + CapsLock M F` | 🖕 | fuck |
| `Shift + CapsLock M W` | 🤞 | noras |
| `Shift + CapsLock M R` | 🤘 | rokas |
| `Shift + CapsLock M K` | 😘 | bučinys |
| `Shift + CapsLock M E` | 🙄 | akių vartymas |
| `Shift + CapsLock M I` | 😉 | mirktelėjimas |
| `Shift + CapsLock M P` | 🙏 | melstis |
| `Shift + CapsLock M D` | 🤤 | seilėtekis |
| `Shift + CapsLock M M` | 💰 | pinigai |
| `Shift + CapsLock M X` | 🎉 | xellebrate |
| `Shift + CapsLock M 1` | 💯 | 100% |
| `Shift + CapsLock M T` | 🥂 | tostas |
| `Shift + CapsLock M O` |👌 | ok |
| `Shift + CapsLock M G` |👋 | pasisveikinimas |
| `Shift + CapsLock M A` |💪 | ranka |
| `Shift + CapsLock M B` |🤯 | sprogsta |

## Greitieji užbaigimai

| Spartusis klavišas | Užbaigimas |
| ------------ |  ---------- |
| `Shift + CapsLock Space Space` | — (mdash) |
| `Shift + CapsLock Space N` | Jūsų vardas (kaip įvesta per sąranką) |
| `Shift + CapsLock Space E` | Jūsų el. paštas (kaip įvesta per sąranką) |

Galite pridėti daugiau savų, redaguodami `~/.XCompose`, tada terminale paleisdami `omarchy-restart-xcompose`, kad pakeitimai būtų pritaikyti.
