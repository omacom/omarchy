# Spartieji klavišai

Visus pagrindinius klavišų derinius galite pamatyti paspaudę `Super + K` (Tmux derinius – `Super + Alt + K`, o Herdr derinius – `Super + Ctrl + K`).

## Kaip išdėstyti spartieji klavišai

Kiekvienas spartusis klavišas yra tam tikroje plokštumoje, kurią nustato jo modifikatoriai, ir kiekviena plokštuma turi vieną paskirtį. Tai neleidžia spartiesiems klavišams susilieti tarpusavyje ir paprastai leidžia atspėti, kur kas yra.

| Plokštuma | Kas joje yra | Pavyzdžiai |
| --- | --- | --- |
| `Super + key` | Sistema: langai, darbo erdvės, išdėstymai ir pagrindiniai meniu | `Super + Space` Omarchy meniu, `Super + W` uždaryti langą, `Super + F` per visą ekraną |
| `Super + Shift + key` | Programos | `Super + Shift + B` naršyklė, `Super + Shift + E` el. paštas, `Super + Shift + N` redaktorius |
| `Super + Ctrl + key` | Skydeliai ir sistemos meniu | `Super + Ctrl + A` garsas, `Super + Ctrl + N` tinklas, `Super + Ctrl + C` fiksavimo meniu |
| `Super + Ctrl + Alt + key` | Greiti veiksmai ir informaciniai pranešimai | `Super + Ctrl + Alt + T` rodyti laiką, `Super + Ctrl + Alt + B` baterija, `Super + Ctrl + Alt + C` ekrano kopija |

Pridėjus `Alt` prie sparčiojo klavišo, gaunamas to paties dalyko variantas, niekada kažkas nesusijusio:

- `Super + Shift + B` atidaro naršyklę; `Super + Shift + Alt + B` atidaro privatų langą
- `Super + Shift + E` atidaro el. paštą; `Super + Shift + Alt + E` pradeda naują laišką
- `Super + F` įjungia vaizdą per visą ekraną; `Super + Alt + F` įjungia vaizdą per visą plotį
- `Super + Ctrl + C` atidaro fiksavimo meniu; `Super + Ctrl + Alt + C` praleidžia meniu ir padaro ekrano kopiją

Pridedant spartųjį klavišą:

1. Pasirinkite plokštumą pagal tai, ką jis daro, tada pasirinkite klavišą.
2. Neperkeldinėkite esamo sparčiojo klavišo, kad atlaisvintumėte vietos. Raskite laisvą klavišą tinkamoje plokštumoje.
3. `Alt` naudokite tik to paties sparčiojo klavišo be jo variantui.

Keletas sparčiųjų klavišų pažeidžia šias taisykles, nes taip patogiau. `Shift` su rodykle arba `Tab` perkelia arba apgręžia, o ne atidaro programą, o `Print`, medijos klavišai, `Alt + Tab` ir `Ctrl + Alt + Del` veikia taip, kaip ir visur kitur. Tai išimtys, o ne pavyzdžiai, kuriuos reikėtų kopijuoti.

Jei numatytasis derinys jums netinka (tarkime, norite `Super + Shift + S` ekrano kopijoms, kaip Windows sistemoje), perriškite jį faile `~/.config/hypr/bindings.lua`.

## Naršymas

| Spartusis klavišas | Funkcija |
| ----------------------- | --------------------- |
| `Super + Space` | Omarchy meniu (programos ir visa kita) |
| `Super + Alt + Space` | Programų tinklelis |
| `Super + Escape` | Sistemos meniu (pristabdyti, paleisti iš naujo ir kt.) |
| `Super + Ctrl + L` | Užrakinti kompiuterį |
| `Super + W` arba `Super + Q` | Uždaryti langą |
| `Ctrl + Alt + Del` | Uždaryti visus langus |
| `Super + K` | Rodyti visus sparčiuosius klavišus |
| `Super + Alt + K` | Rodyti tmux sparčiuosius klavišus |
| `Super + Ctrl + K` | Rodyti herdr sparčiuosius klavišus |
| `Super + M` | Sumažinti langą į doką |
| `Super + T` | Perjungti langą tarp plytelių ir plaukiojančio režimo |
| `Super + J` | Perjungti lango padėtį (horizontali / vertikali) |
| `Super + O` | Perjungti lango iškėlimą į lipnų ir plaukiojantį režimą |
| `Super + L` | Cikliškai perjungti dwindle, scrolling ir floating išdėstymus |
| `Super + Alt + L` | Cikliškai perjungti išdėstymus atvirkštine tvarka |
| `Super + P` | Perjungti pseudo lango stilių (natūralus ar ištemptas) |
| `Super + F` | Per visą ekraną |
| `Super + Alt + F` | Per visą plotį |
| `Super + Ctrl + F` | Per visą ekraną lango viduje |
| `Super + 1…9/0` | Pereiti į konkrečią darbo erdvę (0 yra 10) fokusuotame monitoriuje |
| `Super + Tab` | Pereiti į kitą darbo erdvę fokusuotame monitoriuje |
| `Super + Shift + Tab` | Pereiti į ankstesnę darbo erdvę fokusuotame monitoriuje |
| `Super + Ctrl + Tab` | Pereiti į buvusią darbo erdvę fokusuotame monitoriuje |
| `Super + Shift + 1…9/0` | Perkelti langą į darbo erdvę fokusuotame monitoriuje |
| `Super + Shift + Alt + 1…9/0` | Perkelti langą į darbo erdvę fokusuotame monitoriuje nesekant paskui jį |
| `Super + S` | Perjungti visą scratchpad |
| `Super + Alt + S` | Perkelti langą į visą scratchpad |
| `Super + the key above Tab` (JAV išdėstymuose – grave) | Perjungti Quake konsolę |
| `Super + Shift + the key above Tab` (JAV išdėstymuose – grave) | Perkelti langą į Quake konsolę |
| `Super + Shift + Ctrl + Arrows` | Perkelti langą į monitorių ta kryptimi |
| `Super + Shift + Alt + Arrows` | Perkelti darbo erdvę į monitorių ta kryptimi |
| `Super + Arrow` | Perkelti fokusą į langą rodyklės kryptimi, ekrano krašte pereinant į toje pusėje esantį monitorių |
| `Super + Shift + Arrow` | Sukeisti langą su kitu rodyklės kryptimi, įskaitant esantį toje pusėje esančiame monitoriuje |
| `Super + Minus` | Išplėsti langą į kairę |
| `Super + Equal` | Susiaurinti langą į kairę |
| `Super + Shift + Minus` | Susiaurinti langą į viršų |
| `Super + Shift + Equal` | Išplėsti langą žemyn |
| `Super + Alt + Minus/Equal` | Tas pats dydžio keitimas mažesniais žingsniais |
| `Super + Ctrl + Minus/Equal` | Tas pats dydžio keitimas didesniais žingsniais |
| `Super + Alt + Home` | Išsaugoti lango plotį |
| `Super + Home` | Atkurti išsaugotą lango plotį |
| `Super + Left Mouse` | Vilkti langą aplink |
| `Super + Right Mouse` | Keisti lango dydį |
| `Super + Scroll Wheel` | Slinkti per darbo erdves fokusuotame monitoriuje |
| `Super + G` | Perjungti langų grupavimą |
| `Super + Alt + G` | Iškelti langą iš grupės |
| `Super + Alt + Tab` | Cikliškai perjungti grupės langus |
| `Super + Alt + Shift + Tab` | Cikliškai perjungti grupės langus atgal |
| `Super + Alt + Scroll Wheel` | Cikliškai perjungti grupės langus |
| `Super + Alt + 1/2/3/4/5` | Pereiti į konkretų langą grupėje |
| `Super + Alt + Arrow` | Perkelti langą į grupę rodyklės kryptimi, įskaitant esantį toje pusėje esančiame monitoriuje |
| `Super + Ctrl + Left/Right` | Judėti tarp langų plytelių grupėje |
| `Super + Ctrl + Z` | Priartinti ekraną (kartoti, kad priartintumėte dar labiau) |
| `Super + Ctrl + Alt + Z` | Visiškai atitolinti ekraną |
| `Super + /` | Žingsnis pirmyn per monitoriaus mastelio parinktis |
| `Super + Alt + /` | Žingsnis atgal per monitoriaus mastelio parinktis |
| `Alt + Tab` | Cikliškai judėti pirmyn per langus aktyvioje darbo erdvėje |
| `Alt + Shift + Tab` | Cikliškai judėti atgal per langus aktyvioje darbo erdvėje |
| `Ctrl + Alt + Tab` | Cikliškai perkelti fokusą pirmyn per monitorius |
| `Ctrl + Alt + Shift + Tab` | Cikliškai perkelti fokusą atgal per monitorius |
| `Super + I` | Perjungti įvesties kalbą (kai yra daugiau nei vienas išdėstymas ar įvesties metodas) |
| `Super + Shift + I` | Perjungti įvesties kalbą atgal |

Jutikliniame kilimėlyje braukimai trimis ir keturiais pirštais perjungia darbo erdves, perkelia langus ir atidaro meniu bei Quake konsolę; gestus žr. [klaviatūra, pelė ir jutiklinis kilimėlis](34-keyboard-mouse-trackpad.md).

Dydis keičiamas dviem klavišais, esančiais dešinėje nuo 0, kad ir kas ant jų būtų atspausdinta jūsų klaviatūroje: `-` ir `=` JAV klaviatūrose, `+` ir `´` daniškose ir švediškose, `+` ir `\` norvegiškose, `ß` ir `´` vokiškose, `'` ir `¡` ispaniškose ir `-` ir `^` japoniškose (JIS). `Super + K` juos išvardija taip, kaip atspausdinta jūsų klaviatūroje. JIS išdėstyme `Super + ^` yra `Super + Equal`, o `Super + Shift + -` (kuriuo įvedama `=`) yra `Super + Shift + Minus`. Monitoriaus mastelis ir slaptažodžių tvarkyklė naudoja `/`; išdėstymuose, kuriuose `/` įvedamas tik su Shift, kaip daugumoje europietiškų, jie naudoja klavišą, esantį kairėje nuo dešiniojo Shift (`-` daniškame ir vokiškame).

## Sistemos valdikliai

| Spartusis klavišas | Funkcija |
| ----------------------- | --------------------- |
| `Super + Ctrl + A` | Garso skydelis |
| `Super + Ctrl + B` | Bluetooth skydelis |
| `Super + Ctrl + N` | Wifi / tinklo skydelis |
| `Super + Ctrl + D` | Ekrano skydelis |
| `Super + Ctrl + P` | Maitinimo skydelis |
| `Super + Ctrl + X` | Agentų skydelis |
| `Super + Ctrl + Alt + X` | Vietinių modelių skydelis |
| `Super + Ctrl + Alt + D` | Kalendoriaus skydelis |
| `Super + Ctrl + Alt + E` | Pasaulio laikrodžio skydelis |
| `Super + Ctrl + 1-9` | Perjungti juostos skydelį pagal padėtį |
| `Super + Ctrl + S` | Bendrinimo meniu (per LocalSend) |
| `Super + Ctrl + C` | Fiksavimo valdikliai (ekrano kopija / įrašymas / parinkiklis) |
| `Super + Ctrl + O` | Perjungti meniu |
| `Super + Ctrl + H` | Aparatūros meniu |
| `Super + Ctrl + E` | Jaustukų parinkiklis |
| `Super + Ctrl + .` | Transkoduoti mediją |
| `Super + Shift + Ctrl + A` | Paleisti numatytąjį agentą |
| `Power` klavišas | Sistemos meniu |
| `Super + Shift + Copilot` klavišas | Omarchy meniu |

## Koregavimai

| Spartusis klavišas | Funkcija |
| ----------------------- | --------------------- |
| `Shift + Brightness Up` | Didžiausias ekrano ryškumas |
| `Shift + Brightness Down` | Mažiausias ekrano ryškumas |
| `Alt + Brightness Up/Down` | Tikslūs 1 % ryškumo pakeitimai |
| `Alt + Volume Up/Down` | Tikslūs 1 % garsumo pakeitimai |
| `Keyboard Brightness Up/Down` | Klaviatūros apšvietimas ryškesnis / blankesnis |
| `Keyboard Backlight` | Cikliškai perjungti klaviatūros apšvietimo lygius |
| `Ctrl + Brightness Up/Down` | Klaviatūros apšvietimas ryškesnis / blankesnis klaviatūrose be savų klavišų |
| `Mic Mute` | Nutildyti mikrofoną |
| `Shift + Mute` | Perjungti garso išvestį |
| `Touchpad Toggle` | Įjungti arba išjungti jutiklinį kilimėlį |
| `Display` klavišas | Cikliškai perjungti darbo erdvės išdėstymą |
| `Alt + Play` | Kitas takelis |
| `Alt + Shift + Play` | Ankstesnis takelis |

## Programų paleidimas

| Spartusis klavišas | Funkcija |
| ----------------------- | --------------------- |
| `Super + Return` | Terminalas |
| `Super + Alt + Return` | Tmux terminalas |
| `Super + Ctrl + Return` | Herdr (agentų tvarkyklė) |
| `Super + Shift + Return` arba `Super + Shift + B` | Naršyklė |
| `Super + Shift + Alt + B` | Naršyklė (privatus / inkognito režimas) |
| `Super + Shift + F` | Failų tvarkyklė |
| `Super + Shift + Alt + F` | Failų tvarkyklė terminalo cwd aplanke |
| `Super + Shift + M` | Muzika (Spotify) |
| `Super + Shift + Alt + M` | Muzika (cliamp) |
| `Super + Shift + /` | Slaptažodžių tvarkyklė (1password) |
| `Super + Shift + Q` arba `Calculator` klavišas | Skaičiuotuvas (Omacalc) |
| `Super + Shift + D` | Docker (lazydocker, kai įdiegta) |
| `Super + Shift + T` | Veikla (btop) |
| `Super + Shift + N` | Redaktorius (Plain arba jūsų pasirinktas numatytasis) |
| `Super + Shift + C` | Kalendorius ([HEY](https://hey.com/)) |
| `Super + Shift + E` | El. paštas ([HEY](https://hey.com/)) |
| `Super + Shift + Alt + E` | Naujas el. laiškas ([HEY](https://hey.com/)) |
| `Super + Shift + A` | Jūsų numatytasis agentas arba ChatGPT, kol pasirinksite kitą |
| `Super + Shift + Alt + A` | DI (Grok) |
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

Pakeiskite / pridėkite derinius faile `~/.config/hypr/bindings.lua`.

## Universali iškarpinė

| Spartusis klavišas | Funkcija |
| ----------------------- | --------------------- |
| `Super + A` | Pasirinkti viską programose, kurios palaiko `Ctrl + A` |
| `Super + C` | Kopijuoti |
| `Super + X` | Iškirpti (ne terminale) |
| `Super + V` | Įklijuoti |
| `Super + Ctrl + V` | Iškarpinės tvarkyklė |

Paprastai Linux sistemoje terminale kopijuoti ir įklijuoti reikia `Ctrl + Shift + C/V`, o visur kitur – `Ctrl + C/V`. Šie Omarchy suvienodinti iškarpinės spartieji klavišai veikia visur.

## Fiksavimas

| Spartusis klavišas | Funkcija |
| ------------------- | ------------------------------ |
| `Print Screen` | Ekrano kopija |
| `Super + Ctrl + Alt + C` | Ekrano kopija (tas pats kadras klaviatūroms be Print Screen klavišo) |
| `Super + Ctrl + C` | Fiksavimo meniu |
| `Alt + Print Screen` | Ekrano įrašymas |
| `Super + Shift + Ctrl + Alt + C` | Ekrano įrašymas be garso, praleidžiant meniu (paspauskite dar kartą, kad sustabdytumėte) |
| `Super + Print Screen` | Spalvų parinkiklis |
| `Super + Ctrl + Print Screen` | Teksto išgavimas į iškarpinę |
| `Super + Alt + [` | Sumažinti internetinės kameros perdangą įrašant |
| `Super + Alt + ]` | Padidinti internetinės kameros perdangą įrašant |
| `Alt + Shift + L` | Kopijuoti dabartinį URL iš žiniatinklio programos arba naršyklės |
| `Alt + Shift + D` | Atsisiųsti dabartinio puslapio vaizdo įrašą į `~/Videos` |
| `Alt + Space` | Pradėti / sustabdyti diktavimą (reikia _Setup > Defaults > Dictation_) |
| `Right Alt` | Laikyti norint diktuoti (reikia _Setup > Defaults > Dictation_) |

Atliekant ekrano įrašymus, spartusis klavišas pirmiausia paklausia, kokio garso norite, tada pradeda įrašyti. Paspauskite jį dar kartą, kad sustabdytumėte. Išsamesnės informacijos žr. [ekrano kopijos ir įrašymas](12-screenshots-recording.md).

Visos fiksavimo parinktys taip pat pasiekiamos Omarchy meniu (`Super + Space`) skiltyje _Trigger > Capture_.

## Pranešimai

| Spartusis klavišas | Funkcija |
| ----------------------- | --------------------- |
| `Super + ,` | Veikti pagal naujausią pranešimą: atidaryti jį arba paspausti vienintelį jo mygtuką, pasirinkti iš jo parinkčių arba atmesti jį, kai jis neturi nė vienos |
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
| `Super + Ctrl + Backspace` | Perjungti vieno lango kvadrato proporcijas |

Papildomi fono vaizdai yra `~/.config/omarchy/backgrounds/<theme name>`. Taip pat pasiekiama Omarchy meniu skiltyje _Install > Style > Background_.

Visos stiliaus parinktys taip pat pasiekiamos Omarchy meniu (`Super + Space`) skiltyje _Appearance_.

## Perjungikliai

| Spartusis klavišas | Funkcija |
| ----------------------- | --------------------- |
| `Super + Ctrl + I` | Perjungti užrakinimą esant neaktyvumui |
| `Super + Ctrl + Delete` | Perjungti nešiojamojo kompiuterio ekrano įjungimą / išjungimą |
| `Super + Ctrl + Alt + Delete` | Perjungti nešiojamojo kompiuterio ekrano veidrodinį atspindėjimą |
| `Super + Shift + Space` | Perjungti viršutinę juostą |
| `Shift + Mute` | Perjungti į kitą garso išvestį |
| `Shift + Play` | Perjungti į kitą medijos šaltinį |
| `Super + Shift + Backspace` | Perjungti langų tarpus |
| `Super + Ctrl + Alt + F` | Perjungti darbalaukį per visą ekraną (viršutinė juosta + langų tarpai) |

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
| `Super + Ctrl + Alt + W` | Perjungti orus kaip pranešimą |

## Tmux

Prefikso klavišas yra `Ctrl + Space` (taip pat veikia `Ctrl + B`). Šiuos derinius galite pakeisti faile `~/.config/tmux/tmux.conf`.

### Sritys

| Spartusis klavišas | Funkcija |
| ----------------------- | --------------------- |
| `Prefix + v` | Padalyti sritį šalia (vertikaliai) |
| `Prefix + h` | Padalyti sritį apačioje (horizontaliai) |
| `Prefix + x` | Sunaikinti sritį |
| `Prefix + z` | Perjungti srities priartinimą (per visą ekraną) |
| `Alt + Enter` | Padalyti sritį apačioje (be prefikso) |
| `Alt + Shift + Enter` | Padalyti sritį šalia (be prefikso) |
| `Alt + Escape` | Sunaikinti sritį (be prefikso) |
| `Ctrl + Alt + Arrows` | Judėti tarp sričių |
| `Ctrl + Alt + Shift + Arrows` | Keisti sričių dydį |

### Langai

| Spartusis klavišas | Funkcija |
| ----------------------- | --------------------- |
| `Prefix + c` | Naujas langas |
| `Prefix + k` | Sunaikinti langą |
| `Prefix + r` | Pervadinti langą |
| `Alt + 1-9` | Pereiti į konkretų langą |
| `Alt + Arrow Left/Right` | Judėti tarp langų |
| `Alt + Shift + Arrow Left/Right` | Perkelti langą į kairę / į dešinę |

### Seansai

| Spartusis klavišas | Funkcija |
| ----------------------- | --------------------- |
| `Prefix + C` | Naujas seansas |
| `Prefix + K` | Sunaikinti seansą |
| `Prefix + R` | Pervadinti seansą |
| `Prefix + N` | Kitas seansas |
| `Prefix + P` | Ankstesnis seansas |
| `Alt + Arrow Up/Down` | Judėti tarp seansų |
| `Prefix + s` | Išvardyti seansus |
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
| `Prefix + ?` | Rodyti Tmux klavišų derinius |
| `Prefix + :` | Komandų eilutė |

### Tmux išdėstymo funkcijos

Šios funkcijos turi būti vykdomos Tmux seanso viduje.

| Komanda | Funkcija |
| ------- | -------- |
| `tdl <ai> [<second_ai>]` | Sukurti kūrimo išdėstymą su redaktoriumi, AI ir terminalu |
| `tdlm <ai> [<second_ai>]` | Sukurti kūrimo išdėstymą kiekvienam pakatalogiui |
| `tsl <count> <command>` | Sukurti kelių sričių spiečiaus išdėstymą |

## Ghostty terminalas

Ghostty terminalas įdiegiamas naudojant _Install > Terminal_ per Omarchy meniu.

| Spartusis klavišas | Funkcija |
| ----------------------- | --------------------- |
| `Ctrl + Shift + E` | Naujas padalijimas apačioje |
| `Ctrl + Shift + O` | Naujas padalijimas šalia |
| `Ctrl + Alt + Arrows` | Judėti tarp padalijimų |
| `Super + Ctrl + Shift + Arrows` | Keisti padalijimo dydį 10 eilučių |
| `Super + Ctrl + Shift + Alt + Arrows` | Keisti padalijimo dydį 100 eilučių |
| `Ctrl + Shift + T` | Nauja kortelė |
| `Ctrl + Shift + Arrows` | Judėti tarp kortelių |
| `Alt + Numbers` | Pereiti į konkrečią kortelę |
| `Shift + Pg Up/Down` | Slinkti istoriją |
| `Ctrl + Left mouse` | Atidaryti nuorodą naršyklėje |

## Failų tvarkyklė

| Spartusis klavišas | Funkcija |
| ------------------- | ------------------------------ |
| `Ctrl + L` | Eiti į kelią |
| `Space` | Peržiūrėti failą (rodyklėmis naršoma) |
| `Alt + Up` | Eiti į pirminį aplanką |

## Neovim (su lazyvim)

### Naršymas

| Spartusis klavišas | Funkcija |
| ------------------------ | ------------------------------- |
| `Space` | Rodyti komandų parinktis |
| `Space Space` | Atidaryti failą naudojant apytikslę paiešką |
| `Space E` | Perjungti šoninę juostą |
| `Space G G` | Rodyti git valdiklius |
| `Space S G` | Ieškoti failo turinyje |
| `Ctrl + W W` | Šokinėti tarp šoninės juostos ir redaktoriaus |
| `Ctrl + Left/right arrow` | Keisti šoninės juostos dydį |
| `Shift + H` | Eiti į kairiąją failo kortelę |
| `Shift + L` | Eiti į dešiniąją failo kortelę |
| `Space B D` | Uždaryti failo kortelę |

### Esant šoninėje juostoje

| Spartusis klavišas | Funkcija |
| ------------------------ | ------------------------------- |
| `A` | Pridėti naują failą pirminiame kataloge |
| `Shift + A` | Pridėti naują pakatalogį pirminiame kataloge |
| `D` | Ištrinti pažymėtą failą / katalogą |
| `M` | Perkelti pažymėtą failą / katalogą |
| `R` | Pervadinti pažymėtą failą / katalogą |
| `?` | Rodyti visų komandų žinyną |

[Žiūrėti visus Neovim sparčiuosius klavišus, sukonfigūruotus LazyVim](https://www.lazyvim.org/keymaps).

## Greitieji jaustukai

Paspaudę `Super + Ctrl + E` galite parodyti išsamų jaustukų parinkiklį, kuris įdės pasirinkimą į iškarpinę, arba galite naudoti šias greitosios prieigos parinktis.

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
| `Shift + CapsLock M W` | 🤞 | noras |
| `Shift + CapsLock M R` | 🤘 | rokas |
| `Shift + CapsLock M K` | 😘 | bučinys |
| `Shift + CapsLock M E` | 🙄 | akių vartymas |
| `Shift + CapsLock M I` | 😉 | mirktelėjimas |
| `Shift + CapsLock M P` | 🙏 | melstis |
| `Shift + CapsLock M D` | 🤤 | seilėjimasis |
| `Shift + CapsLock M M` | 💰 | pinigai |
| `Shift + CapsLock M X` | 🎉 | xellebrate |
| `Shift + CapsLock M 1` | 💯 | 100% |
| `Shift + CapsLock M T` | 🥂 | tostas |
| `Shift + CapsLock M O` |👌 | ok |
| `Shift + CapsLock M G` |👋 | pasisveikinimas |
| `Shift + CapsLock M A` |💪 | ranka |
| `Shift + CapsLock M B` |🤯 | sprogimas |

## Greitieji užbaigimai

| Spartusis klavišas | Užbaigimas |
| ------------ |  ---------- |
| `Shift + CapsLock Space Space` | — (ilgas brūkšnys) |
| `Shift + CapsLock Space N` | Jūsų vardas (kaip įvestas nustatant) |
| `Shift + CapsLock Space E` | Jūsų el. paštas (kaip įvestas nustatant) |

Galite pridėti daugiau savų, redaguodami `~/.XCompose`, tada terminale paleidę `omarchy restart xcompose`, kad pakeitimai būtų pritaikyti.
