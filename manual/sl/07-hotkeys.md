# Bližnjice na tipkovnici

Vse glavne bližnjice na tipkovnici lahko vidite s `Super + K` (bližnjice za Tmux s `Super + Alt + K` in bližnjice za Herdr s `Super + Ctrl + K`).

## Kako so bližnjice razporejene

Vsaka bližnjica je na svoji ravnini, ki jo določajo njene modifikacijske tipke, vsaka ravnina pa ima eno nalogo. Zaradi tega se bližnjice ne zameglijo med seboj, običajno pa lahko tudi uganete, kje kaj živi.

| Ravnina | Kaj živi tam | Primeri |
| --- | --- | --- |
| `Super + key` | Sistem: okna, delovni prostori, postavitve in glavni meniji | `Super + Space` meni Omarchy, `Super + W` zapri okno, `Super + F` cel zaslon |
| `Super + Shift + key` | Aplikacije | `Super + Shift + B` brskalnik, `Super + Shift + E` e-pošta, `Super + Shift + N` urejevalnik |
| `Super + Ctrl + key` | Plošče in sistemski meniji | `Super + Ctrl + A` zvok, `Super + Ctrl + N` omrežje, `Super + Ctrl + C` meni za zajem |
| `Super + Ctrl + Alt + key` | Hitra dejanja in obvestila | `Super + Ctrl + Alt + T` prikaži čas, `Super + Ctrl + Alt + B` baterija, `Super + Ctrl + Alt + C` posnetek zaslona |

Dodajanje tipke `Alt` bližnjici vam da različico iste stvari, nikoli nekaj nepovezanega:

- `Super + Shift + B` odpre brskalnik; `Super + Shift + Alt + B` odpre zasebno okno
- `Super + Shift + E` odpre e-pošto; `Super + Shift + Alt + E` začne novo
- `Super + F` gre na cel zaslon; `Super + Alt + F` gre na celotno širino
- `Super + Ctrl + C` odpre meni za zajem; `Super + Ctrl + Alt + C` preskoči meni in naredi posnetek zaslona

Ko dodajate bližnjico:

1. Izberite ravnino glede na to, kaj počne, nato izberite tipko.
2. Ne premikajte obstoječe bližnjice, da bi naredili prostor. Poiščite prosto tipko na pravi ravnini.
3. `Alt` uporabljajte samo za različico bližnjice brez nje.

Nekaj bližnjic krši ta pravila, ker so priročne. `Shift` s puščico ali `Tab` premika ali obrne smer namesto odpiranja aplikacije, `Print`, medijske tipke, `Alt + Tab` in `Ctrl + Alt + Del` pa delujejo tako kot povsod drugje. So izjeme, ne vzorci za posnemanje.

Če vam privzeta nastavitev ne ustreza (recimo, da želite `Super + Shift + S` za posnetke zaslona kot v sistemu Windows), jo ponovno povežite v `~/.config/hypr/bindings.lua`.

## Krmarjenje

| Bližnjica                  | Funkcija              |
| ----------------------- | --------------------- |
| `Super + Space`           | Meni Omarchy (aplikacije in vse ostalo)    |
| `Super + Alt + Space` | Mreža aplikacij |
| `Super + Escape` | Sistemski meni (zaustavitev v spanje, ponovni zagon itd.)  |
| `Super + Ctrl + L` | Zakleni računalnik |
| `Super + W` or `Super + Q` | Zapri okno             |
| `Ctrl + Alt + Del` | Zapri vsa okna |
| `Super + K` | Prikaži vse bližnjice |
| `Super + Alt + K` | Prikaži bližnjice za tmux |
| `Super + Ctrl + K` | Prikaži bližnjice za herdr |
| `Super + M` | Pomanjšaj okno v dok |
| `Super + T`               | Preklopi okno med tlakovanjem in lebdenjem             |
| `Super + J` | Preklopi položaj okna (vodoravno/navpično) |
| `Super + O`               | Preklopi okno v lepljivi in lebdeči način |
| `Super + L`               | Kroži med postavitvami dwindle, scrolling in floating |
| `Super + Alt + L`         | Kroži med postavitvami v obratni smeri |
| `Super + P`               | Preklopi slog psevdo okna (naravno proti raztegnjenemu) |
| `Super + F`                 | Cel zaslon              |
| `Super + Alt + F`                 | Celotna širina              |
| `Super + Ctrl + F`                 | Cel zaslon znotraj okna              |
| `Super + 1…9/0`         | Skoči na določen delovni prostor (0 je 10) na monitorju v fokusu |
| `Super + Tab` | Skoči na naslednji delovni prostor na monitorju v fokusu |
| `Super + Shift + Tab` | Skoči na prejšnji delovni prostor na monitorju v fokusu |
| `Super + Ctrl + Tab` | Skoči na nekdanji delovni prostor na monitorju v fokusu |
| `Super + Shift + 1…9/0` | Premakni okno v delovni prostor na monitorju v fokusu |
| `Super + Shift + Alt + 1…9/0` | Premakni okno v delovni prostor na monitorju v fokusu brez sledenja |
| `Super + S` | Preklopi celotni scratchpad |
| `Super + Alt + S` | Premakni okno v celotni scratchpad |
| `Super + the key above Tab` (grave on US layouts) | Preklopi konzolo Quake |
| `Super + Shift + the key above Tab` (grave on US layouts) | Premakni okno v konzolo Quake |
| `Super + Shift + Ctrl + Arrows` | Premakni okno na monitor v tisti smeri |
| `Super + Shift + Alt + Arrows` | Premakni delovni prostor na monitor v tisti smeri |
| `Super + Arrow`  | Premakni fokus na okno v smeri puščice, na robu zaslona preide na monitor na tisti strani |
| `Super + Shift + Arrow`  | Zamenjaj okno z drugim v smeri puščice, vključno z oknom na monitorju na tisti strani |
| `Super + Minus` | Razširi okno v levo |
| `Super + Equal` | Skrči okno v levo |
| `Super + Shift + Minus` | Skrči okno navzgor |
| `Super + Shift + Equal` | Razširi okno navzdol |
| `Super + Alt + Minus/Equal` | Isto spreminjanje velikosti v manjših korakih |
| `Super + Ctrl + Minus/Equal` | Isto spreminjanje velikosti v večjih korakih |
| `Super + Alt + Home` | Shrani širino okna |
| `Super + Home` | Obnovi shranjeno širino okna |
| `Super + Left Mouse` | Vleci okno naokoli |
| `Super + Right Mouse` | Spremeni velikost okna |
| `Super + Scroll Wheel` | Pomikaj se med delovnimi prostori na monitorju v fokusu |
| `Super + G`               | Preklopi združevanje oken      |
| `Super + Alt + G`               | Premakni okno iz skupine      |
| `Super + Alt + Tab`               | Kroži med okni v skupini      |
| `Super + Alt + Shift + Tab`               | Kroži nazaj med okni v skupini      |
| `Super + Alt + Scroll Wheel` | Kroži med okni v skupini |
| `Super + Alt + 1/2/3/4/5`               | Skoči na določeno okno v skupini      |
| `Super + Alt + Arrow`  | Premakni okno v skupino v smeri puščice, vključno z oknom na monitorju na tisti strani |
| `Super + Ctrl + Left/Right`  | Premikaj se med okni znotraj tlakovane skupine |
| `Super + Ctrl + Z` | Povečaj zaslon (ponovite za večjo povečavo) |
| `Super + Ctrl + Alt + Z` | Popolnoma pomanjšaj zaslon |
| `Super + /` | Stopi naprej med možnostmi skaliranja monitorja |
| `Super + Alt + /` | Stopi nazaj med možnostmi skaliranja monitorja |
| `Alt + Tab` | Kroži naprej med okni na aktivnem delovnem prostoru |
| `Alt + Shift + Tab` | Kroži nazaj med okni na aktivnem delovnem prostoru |
| `Ctrl + Alt + Tab`| Kroži fokus naprej med monitorji |
| `Ctrl + Alt + Shift + Tab`| Kroži fokus nazaj med monitorji |
| `Super + I` | Preklopi jezik vnosa (pri več kot eni postavitvi ali načinu vnosa) |
| `Super + Shift + I` | Preklopi jezik vnosa nazaj |

Na sledilni ploščici potege s tremi in štirimi prsti preklapljajo delovne prostore, premikajo okna ter odpirajo meni in konzolo Quake; za potege glejte [tipkovnica, miška in sledilna ploščica](34-keyboard-mouse-trackpad.md).

Spreminjanje velikosti uporablja dve tipki desno od 0, kar koli že vaša tipkovnica natisne nanju: `-` in `=` na ameriških tipkovnicah, `+` in `´` na danskih in švedskih, `+` in `\` na norveških, `ß` in `´` na nemških, `'` in `¡` na španskih ter `-` in `^` na japonskih (JIS). `Super + K` jih navede tako, kot jih natisne vaša tipkovnica. Na JIS je `Super + ^` enako `Super + Equal`, medtem ko je `Super + Shift + -` (ki vnese `=`) enako `Super + Shift + Minus`. Skaliranje monitorja in upravitelj gesel uporabljata `/`; na postavitvah, ki `/` vnesejo samo s Shift, kot večina evropskih, namesto tega uporabljata tipko levo od desnega Shifta (`-` na danskih in nemških).

## Sistemski nadzor

| Bližnjica                  | Funkcija              |
| ----------------------- | --------------------- |
| `Super + Ctrl + A`           | Zvočna plošča    |
| `Super + Ctrl + B`           | Plošča Bluetooth    |
| `Super + Ctrl + N`           | Plošča Wi-Fi/omrežje    |
| `Super + Ctrl + D`           | Plošča za zaslon    |
| `Super + Ctrl + P`           | Plošča za napajanje    |
| `Super + Ctrl + X`           | Plošča agentov    |
| `Super + Ctrl + Alt + X`           | Plošča lokalnih modelov    |
| `Super + Ctrl + Alt + D`           | Plošča koledarja    |
| `Super + Ctrl + Alt + E`           | Plošča svetovne ure    |
| `Super + Ctrl + 1-9`           | Preklopi ploščo vrstice glede na položaj    |
| `Super + Ctrl + S` | Meni za deljenje (prek LocalSend) |
| `Super + Ctrl + C` | Nadzor zajema (posnetek zaslona/snemanje/izbirnik) |
| `Super + Ctrl + O` | Preklopi meni |
| `Super + Ctrl + H` | Meni strojne opreme |
| `Super + Ctrl + E` | Izbirnik emojijev |
| `Super + Ctrl + .` | Prekodiraj medije |
| `Super + Shift + Ctrl + A` | Zaženi privzetega agenta |
| `Power` key | Sistemski meni |
| `Super + Shift + Copilot` key | Meni Omarchy |

## Prilagoditve

| Bližnjica                  | Funkcija              |
| ----------------------- | --------------------- |
| `Shift + Brightness Up` | Največja svetlost zaslona |
| `Shift + Brightness Down` | Najmanjša svetlost zaslona |
| `Alt + Brightness Up/Down` | Natančne spremembe svetlosti za 1 % |
| `Alt + Volume Up/Down` | Natančne spremembe glasnosti za 1 % |
| `Keyboard Brightness Up/Down` | Osvetlitev tipkovnice svetlejša/temnejša |
| `Keyboard Backlight` | Kroži med ravnmi osvetlitve tipkovnice |
| `Ctrl + Brightness Up/Down` | Osvetlitev tipkovnice svetlejša/temnejša, na tipkovnicah brez lastnih tipk |
| `Mic Mute` | Utišaj mikrofon |
| `Shift + Mute` | Preklopi zvočni izhod |
| `Touchpad Toggle` | Vklopi ali izklopi sledilno ploščico |
| `Display` key | Kroži med postavitvami delovnega prostora |
| `Alt + Play` | Naslednja skladba |
| `Alt + Shift + Play` | Prejšnja skladba |

## Zaganjanje aplikacij

| Bližnjica                  | Funkcija              |
| ----------------------- | --------------------- |
| `Super + Return`           | Terminal    |
| `Super + Alt + Return` | Terminal Tmux |
| `Super + Ctrl + Return` | Herdr (upravitelj agentov) |
| `Super + Shift + Return` or `Super + Shift + B`  | Brskalnik    |
| `Super + Shift + Alt + B`           | Brskalnik (zasebno/anonimno)    |
| `Super + Shift + F`           | Upravitelj datotek    |
| `Super + Shift + Alt + F`           | Upravitelj datotek v cwd terminala    |
| `Super + Shift + M`           | Glasba (Spotify)    |
| `Super + Shift + Alt + M`           | Glasba (cliamp)    |
| `Super + Shift + /`           | Upravitelj gesel (1password)    |
| `Super + Shift + Q` or `Calculator` key  | Kalkulator (Omacalc)    |
| `Super + Shift + D`           | Docker (lazydocker, ko je nameščen)    |
| `Super + Shift + T`           | Dejavnost (btop)    |
| `Super + Shift + N`           | Urejevalnik (Plain ali vaš izbrani privzeti)  |
| `Super + Shift + C`           | Koledar ([HEY](https://hey.com/))  |
| `Super + Shift + E`           | E-pošta ([HEY](https://hey.com/))  |
| `Super + Shift + Alt + E`           | Nova e-pošta ([HEY](https://hey.com/))  |
| `Super + Shift + A`           | Vaš privzeti agent ali ChatGPT, dokler ne izberete svojega |
| `Super + Shift + Alt + A`           | AI (Grok)  |
| `Super + Shift + G`           | Sporočilnik (Signal)  |
| `Super + Shift + P`           | Google Photos  |
| `Super + Shift + S`           | Google Maps  |
| `Super + Shift + Alt + G`           | Sporočilnik (WhatsApp)  |
| `Super + Shift + Ctrl + G`           | Sporočilnik (Google)  |
| `Super + Shift + O`           | Obsidian  |
| `Super + Shift + W`           | Pisanje (Omawrite)  |
| `Super + Shift + X`           | X |
| `Super + Shift + Alt + X`           | X (nova objava) |
| `Super + Shift + Y`           | YouTube |

Bližnjice spremenite/dodajte v `~/.config/hypr/bindings.lua`.

## Univerzalno odložišče

| Bližnjica                  | Funkcija              |
| ----------------------- | --------------------- |
| `Super + A`           | Izberi vse v aplikacijah, ki podpirajo `Ctrl + A`    |
| `Super + C`           | Kopiraj    |
| `Super + X`           | Izreži (ne v terminalu)    |
| `Super + V`           | Prilepi    |
| `Super + Ctrl + V`           | Upravitelj odložišča    |

Običajno v Linuxu potrebujete `Ctrl + Shift + C/V` za kopiranje in lepljenje v terminalu ter `Ctrl + C/V` za to povsod drugje. Te poenotene bližnjice za odložišče v Omarchy delujejo povsod.

## Zajem

| Bližnjica              | Funkcija                       |
| ------------------- | ------------------------------ |
| `Print Screen`            | Posnetek zaslona                      |
| `Super + Ctrl + Alt + C`            | Posnetek zaslona (isti posnetek, za tipkovnice brez tipke Print Screen) |
| `Super + Ctrl + C` | Meni za zajem |
| `Alt + Print Screen`            | Snemanje zaslona                     |
| `Super + Shift + Ctrl + Alt + C` | Snemanje zaslona brez zvoka, brez menija (ponovno pritisnite za zaustavitev) |
| `Super + Print Screen` | Izbirnik barv |
| `Super + Ctrl + Print Screen` | Izvlečenje besedila v odložišče |
| `Super + Alt + [` | Pomanjšaj prekrivanje spletne kamere med snemanjem |
| `Super + Alt + ]` | Povečaj prekrivanje spletne kamere med snemanjem |
| `Alt + Shift + L` | Kopiraj trenutni URL iz spletne aplikacije ali brskalnika |
| `Alt + Shift + D` | Prenesi videoposnetek na trenutni strani v `~/Videos` |
| `Alt + Space` | Začni/ustavi narekovanje (zahteva _Setup > Defaults > Dictation_) |
| `Right Alt` | Drži za narekovanje (zahteva _Setup > Defaults > Dictation_) |

Pri snemanju zaslona bližnjica najprej vpraša, kateri zvok želite, nato začne snemati. Ponovno jo pritisnite za zaustavitev. Za podrobnosti glejte [posnetki zaslona in snemanje](12-screenshots-recording.md).

Vse možnosti zajema so dostopne tudi pod _Trigger > Capture_ v meniju Omarchy (`Super + Space`).

## Obvestila

| Bližnjica                  | Funkcija              |
| ----------------------- | --------------------- |
| `Super + ,` | Ukrepaj ob zadnjem obvestilu: odpri ga ali pritisni njegov edini gumb, izberi med njegovimi možnostmi ali ga opusti, kadar nima nobene  |
| `Super + Shift + ,` | Opusti vsa obvestila |
| `Super + Ctrl + ,` | Nadzoruj obvestila s tipkovnico  |
| `Super + Alt + ,` | Opusti zadnje obvestilo  |
| `Super + Shift + Alt + ,` | Odpri zgodovino obvestil  |
| `Super + Ctrl + Alt + ,` | Preklopi utišanje obvestil  |

## Slog

| Bližnjica                  | Funkcija              |
| ----------------------- | --------------------- |
| `Super + Ctrl + T` | Izberi novo temo (tudi `Super + Ctrl + Shift + Space`) |
| `Super + Ctrl + W` | Izberi ozadje teme (tudi `Super + Ctrl + Space`) |
| `Super + Backspace` | Preklopi prosojnost okna |
| `Super + Ctrl + Backspace` | Preklopi kvadratno razmerje stranic enega okna |

Dodatne slike ozadja so v `~/.config/omarchy/backgrounds/<theme name>`. Na voljo tudi prek _Install > Style > Background_ v meniju Omarchy.

Vse možnosti sloga so dostopne tudi pod _Appearance_ v meniju Omarchy (`Super + Space`).

## Preklopi

| Bližnjica                  | Funkcija              |
| ----------------------- | --------------------- |
| `Super + Ctrl + I` | Preklopi zaklepanje med nedejavnostjo |
| `Super + Ctrl + Delete` | Vklopi/izklopi zaslon prenosnika |
| `Super + Ctrl + Alt + Delete` | Preklopi zrcaljenje zaslona prenosnika |
| `Super + Shift + Space` | Preklopi zgornjo vrstico  |
| `Shift + Mute` | Preklopi na naslednji zvočni izhod |
| `Shift + Play` | Preklopi na naslednji vir medijev |
| `Super + Shift + Backspace` | Preklopi vrzeli med okni |
| `Super + Ctrl + Alt + F` | Preklopi namizje na cel zaslon (zgornja vrstica + vrzeli med okni) |

## Opomniki

| Bližnjica                  | Funkcija              |
| ----------------------- | --------------------- |
| `Super + Ctrl + R` | Nastavi opomnik  |
| `Super + Ctrl + Alt + R` | Poglej vse opomnike  |
| `Super + Ctrl + Shift + R` | Počisti vse opomnike  |

## Hitra obvestila

| Bližnjica                  | Funkcija              |
| ----------------------- | --------------------- |
| `Super + Ctrl + Alt + T` | Prikaži čas kot obvestilo  |
| `Super + Ctrl + Alt + B` | Prikaži baterijo kot obvestilo  |
| `Super + Ctrl + Alt + W` | Preklopi vreme kot obvestilo  |

## Tmux

Predpona je `Ctrl + Space` (`Ctrl + B` prav tako deluje). Te bližnjice lahko spremenite v `~/.config/tmux/tmux.conf`.

### Podokna

| Bližnjica                  | Funkcija              |
| ----------------------- | --------------------- |
| `Prefix + v` | Razdeli podokno ob strani (navpično) |
| `Prefix + h` | Razdeli podokno spodaj (vodoravno) |
| `Prefix + x` | Uniči podokno |
| `Prefix + z` | Preklopi povečavo podokna (cel zaslon) |
| `Alt + Enter` | Razdeli podokno spodaj (brez predpone) |
| `Alt + Shift + Enter` | Razdeli podokno ob strani (brez predpone) |
| `Alt + Escape` | Uniči podokno (brez predpone) |
| `Ctrl + Alt + Arrows` | Premikaj se med podokni |
| `Ctrl + Alt + Shift + Arrows` | Spremeni velikost podoken |

### Okna

| Bližnjica                  | Funkcija              |
| ----------------------- | --------------------- |
| `Prefix + c` | Novo okno |
| `Prefix + k` | Uniči okno |
| `Prefix + r` | Preimenuj okno |
| `Alt + 1-9` | Pojdi na določeno okno |
| `Alt + Arrow Left/Right` | Premikaj se med okni |
| `Alt + Shift + Arrow Left/Right` | Premakni okno levo/desno |

### Seje

| Bližnjica                  | Funkcija              |
| ----------------------- | --------------------- |
| `Prefix + C` | Nova seja |
| `Prefix + K` | Uniči sejo |
| `Prefix + R` | Preimenuj sejo |
| `Prefix + N` | Naslednja seja |
| `Prefix + P` | Prejšnja seja |
| `Alt + Arrow Up/Down` | Premikaj se med sejami |
| `Prefix + s` | Seznam sej |
| `Prefix + d` | Odklopi se od seje |

### Način kopiranja (v slogu vi)

| Bližnjica                  | Funkcija              |
| ----------------------- | --------------------- |
| `Prefix + [` | Vstopi v način kopiranja |
| `v` | Začni izbiro (v načinu kopiranja) |
| `y` | Kopiraj izbiro (v načinu kopiranja) |

### Splošno

| Bližnjica                  | Funkcija              |
| ----------------------- | --------------------- |
| `Prefix + q` | Ponovno naloži konfiguracijo |
| `Prefix + ?` | Prikaži bližnjice za Tmux |
| `Prefix + :` | Ukazni poziv |

### Funkcije postavitve Tmux

Te funkcije je treba zagnati znotraj seje Tmux.

| Ukaz | Funkcija |
| ------- | -------- |
| `tdl <ai> [<second_ai>]` | Ustvari razvojno postavitev z urejevalnikom, AI in terminalom |
| `tdlm <ai> [<second_ai>]` | Ustvari razvojno postavitev za vsak podimenik |
| `tsl <count> <command>` | Ustvari postavitev roja z več podokni |

## Terminal Ghostty

Terminal Ghostty namestite z _Install > Terminal_ prek menija Omarchy.

| Bližnjica                  | Funkcija              |
| ----------------------- | --------------------- |
| `Ctrl + Shift + E` | Nova razdelitev spodaj |
| `Ctrl + Shift + O` | Nova razdelitev ob strani |
| `Ctrl + Alt + Arrows` | Premikaj se med razdelitvami |
| `Super + Ctrl + Shift + Arrows` | Spremeni velikost razdelitve za 10 vrstic |
| `Super + Ctrl + Shift + Alt + Arrows` | Spremeni velikost razdelitve za 100 vrstic |
| `Ctrl + Shift + T` | Nov zavihek  |
| `Ctrl + Shift + Arrows` | Premikaj se med zavihki |
| `Alt + Numbers` | Pojdi na določen zavihek |
| `Shift + Pg Up/Down` | Pomikaj se po zgodovini |
| `Ctrl + Left mouse` | Odpri povezavo v brskalniku |

## Upravitelj datotek

| Bližnjica              | Funkcija                       |
| ------------------- | ------------------------------ |
| `Ctrl + L`            | Pojdi na pot                     |
| `Space`               | Predogled datoteke (krmarjenje s puščicami) |
| `Alt + Up`       | Pojdi gor v nadrejeno mapo        |

## Neovim (z lazyvim)

### Krmarjenje

| Bližnjica                   | Funkcija                        |
| ------------------------ | ------------------------------- |
| `Space`                    | Prikaži možnosti ukazov            |
| `Space Space`              | Odpri datoteko z mehkim iskanjem      |
| `Space E`                  | Preklopi stransko vrstico                  |
| `Space G G`                | Prikaži kontrole git               |
| `Space S G`                | Išči po vsebini datoteke             |
| `Ctrl + W W`               | Skači med stransko vrstico in urejevalnikom |
| `Ctrl + Left/right arrow`  | Spremeni velikost stranske vrstice          |
| `Shift + H`                      | Pojdi na levi zavihek datoteke             |
| `Shift + L`                      | Pojdi na desni zavihek datoteke            |
| `Space B D`                | Zapri zavihek datoteke                  |

### V stranski vrstici

| Bližnjica                   | Funkcija                        |
| ------------------------ | ------------------------------- |
| `A`                        | Dodaj novo datoteko v nadrejeni imenik      |
| `Shift + A`                | Dodaj nov podimenik v nadrejeni imenik    |
| `D`                        | Izbriši označeno datoteko/imenik     |
| `M`                        | Premakni označeno datoteko/imenik       |
| `R`                        | Preimenuj označeno datoteko/imenik     |
| `?`                        | Prikaži pomoč za vse ukaze      |

[Oglejte si vse bližnjice za Neovim, ki jih konfigurira LazyVim](https://www.lazyvim.org/keymaps).

## Hitri emojiji

Z `Super + Ctrl + E` lahko prikažete celoten izbirnik emojijev, ki bo izbiro dal v odložišče, ali pa uporabite te možnosti za hiter dostop.

| Bližnjica       | EM | Namig       |
| ------------ | -- | ---------- |
| `Shift + CapsLock M S` | 😄 | nasmeh      |
| `Shift + CapsLock M C` | 😂 | jok        |
| `Shift + CapsLock M L` | 😍 | ljubezen       |
| `Shift + CapsLock M V` | ✌️ | zmaga    |
| `Shift + CapsLock M H` | ❤️ | srce      |
| `Shift + CapsLock M Y` | 👍 | da        |
| `Shift + CapsLock M N` | 👎 | ne         |
| `Shift + CapsLock M F` | 🖕 | fuck       |
| `Shift + CapsLock M W` | 🤞 | želja       |
| `Shift + CapsLock M R` | 🤘 | rock       |
| `Shift + CapsLock M K` | 😘 | poljub       |
| `Shift + CapsLock M E` | 🙄 | obračanje oči    |
| `Shift + CapsLock M I` | 😉 | mežik       |
| `Shift + CapsLock M P` | 🙏 | molitev |
| `Shift + CapsLock M D` | 🤤 | slinjenje      |
| `Shift + CapsLock M M` | 💰 | denar      |
| `Shift + CapsLock M X` | 🎉 | xellebrate |
| `Shift + CapsLock M 1` | 💯 | 100%       |
| `Shift + CapsLock M T` | 🥂 | nazdravljanje      |
| `Shift + CapsLock M O` |👌 | ok |
| `Shift + CapsLock M G` |👋 | pozdrav |
| `Shift + CapsLock M A` |💪 | roka |
| `Shift + CapsLock M B` |🤯 | razneslo |

## Hitra dopolnjevanja

| Bližnjica       | Dopolnitev       |
| ------------ |  ---------- |
| `Shift + CapsLock Space Space` | — (dolgi pomišljaj)   |
| `Shift + CapsLock Space N` | Vaše ime (kot ste ga vnesli ob nastavitvi)  |
| `Shift + CapsLock Space E` | Vaša e-pošta (kot ste jo vnesli ob nastavitvi)  |

Več svojih lahko dodate z urejanjem `~/.XCompose`, nato pa v terminalu zaženete `omarchy restart xcompose`, da se spremembe uveljavijo.
