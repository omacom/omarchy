# Bližnjice na tipkovnici

Vse glavne bližnjice na tipkovnici si lahko ogledate z `Super + K` (bližnjice za Tmux z `Super + Alt + K` in bližnjice za Herdr z `Super + Ctrl + K`).

## Kako so bližnjice razporejene

Vsaka bližnjica je na ravni, ki jo določajo njene modifikacijske tipke, in vsaka raven ima eno nalogo. Zato se bližnjice ne zamešajo med seboj in običajno lahko uganete, kje kaj najdete.

| Raven | Kaj je na njej | Primeri |
| --- | --- | --- |
| `Super + key` | Sistem: okna, delovni prostori, postavitve in glavni meniji | `Super + Space` meni Omarchy, `Super + W` zapri okno, `Super + F` cel zaslon |
| `Super + Shift + key` | Programi | `Super + Shift + B` brskalnik, `Super + Shift + E` e-pošta, `Super + Shift + N` urejevalnik |
| `Super + Ctrl + key` | Panoji in sistemski meniji | `Super + Ctrl + A` zvok, `Super + Ctrl + N` omrežje, `Super + Ctrl + C` meni za zajem |
| `Super + Ctrl + Alt + key` | Hitra dejanja in obvestila | `Super + Ctrl + Alt + T` prikaži čas, `Super + Ctrl + Alt + B` baterija, `Super + Ctrl + Alt + C` posnetek zaslona |

Dodajanje tipke `Alt` bližnjici da različico iste stvari, nikoli kaj nepovezanega:

- `Super + Shift + B` odpre brskalnik; `Super + Shift + Alt + B` odpre zasebno okno
- `Super + Shift + E` odpre e-pošto; `Super + Shift + Alt + E` začne novo
- `Super + F` preklopi na cel zaslon; `Super + Alt + F` preklopi na celo širino
- `Super + Ctrl + C` odpre meni za zajem; `Super + Ctrl + Alt + C` preskoči meni in naredi posnetek zaslona

Pri dodajanju bližnjice:

1. Najprej izberite raven glede na to, kaj počne, nato izberite tipko.
2. Ne premikajte obstoječe bližnjice, da bi naredili prostor. Poiščite prosto tipko na pravi ravni.
3. `Alt` uporabljajte samo za različico bližnjice brez nje.

Nekaj bližnjic krši ta pravila, ker so priročne. `Shift` s puščico ali `Tab` premakne ali obrne smer namesto da bi odprl program, `Print`, medijske tipke, `Alt + Tab` in `Ctrl + Alt + Del` pa delujejo tako kot povsod drugje. To so izjeme, ne vzorci za kopiranje.

Če vam privzeta nastavitev ne ustreza (recimo, da želite `Super + Shift + S` za posnetke zaslona kot v Windows), jo ponovno povežite v `~/.config/hypr/bindings.lua`.

## Krmarjenje

| Bližnjica | Funkcija |
| ----------------------- | --------------------- |
| `Super + Space` | Meni Omarchy (programi in vse ostalo) |
| `Super + Alt + Space` | Mreža programov |
| `Super + Escape` | Sistemski meni (zaustavitev, ponovni zagon itd.) |
| `Super + Ctrl + L` | Zakleni računalnik |
| `Super + W` or `Super + Q` | Zapri okno |
| `Ctrl + Alt + Del` | Zapri vsa okna |
| `Super + K` | Prikaži vse bližnjice |
| `Super + Alt + K` | Prikaži bližnjice za tmux |
| `Super + Ctrl + K` | Prikaži bližnjice za herdr |
| `Super + M` | Pomanjšaj okno v dok |
| `Super + T` | Preklopi okno med postavitvijo v ploščice in lebdenjem |
| `Super + J` | Preklopi položaj okna (vodoravno/navpično) |
| `Super + O` | Preklopi okno v lepljivo lebdeče okno |
| `Super + L` | Kroži med postavitvami dwindle, scrolling in floating |
| `Super + Alt + L` | Kroži med postavitvami v obratni smeri |
| `Super + P` | Preklopi slog psevdookna (naravno proti raztegnjenemu) |
| `Super + F` | Pojdi na cel zaslon |
| `Super + Alt + F` | Pojdi na celo širino |
| `Super + Ctrl + F` | Pojdi na cel zaslon znotraj okna |
| `Super + 1…9/0` | Skoči na določen delovni prostor (0 je 10) na monitorju v fokusu |
| `Super + Tab` | Skoči na naslednji delovni prostor na monitorju v fokusu |
| `Super + Shift + Tab` | Skoči na prejšnji delovni prostor na monitorju v fokusu |
| `Super + Ctrl + Tab` | Skoči na nekdanji delovni prostor na monitorju v fokusu |
| `Super + Shift + 1…9/0` | Premakni okno v delovni prostor na monitorju v fokusu |
| `Super + Shift + Alt + 1…9/0` | Premakni okno v delovni prostor na monitorju v fokusu brez sledenja |
| `Super + S` | Preklopi celoten scratchpad |
| `Super + Alt + S` | Premakni okno v celoten scratchpad |
| `Super + the key above Tab` (grave na ameriških postavitvah) | Preklopi konzolo Quake |
| `Super + Shift + the key above Tab` (grave na ameriških postavitvah) | Premakni okno v konzolo Quake |
| `Super + Shift + Ctrl + Arrows` | Premakni okno na monitor v tisti smeri |
| `Super + Shift + Alt + Arrows` | Premakni delovni prostor na monitor v tisti smeri |
| `Super + Arrow` | Premakni fokus na okno v smeri puščice, na robu zaslona preide na monitor na tisti strani |
| `Super + Shift + Arrow` | Zamenjaj okno z drugim v smeri puščice, vključno z oknom na monitorju na tisti strani |
| `Super + Minus` | Razširi okno v levo |
| `Super + Equal` | Skrči okno v levo |
| `Super + Shift + Minus` | Skrči okno navzgor |
| `Super + Shift + Equal` | Razširi okno navzdol |
| `Super + Alt + Minus/Equal` | Isto spreminjanje velikosti v manjših korakih |
| `Super + Ctrl + Minus/Equal` | Isto spreminjanje velikosti v večjih korakih |
| `Super + Alt + Home` | Shrani širino okna |
| `Super + Home` | Obnovi shranjeno širino okna |
| `Super + Left Mouse` | Vleci okno naokrog |
| `Super + Right Mouse` | Spremeni velikost okna |
| `Super + Scroll Wheel` | Drsaj med delovnimi prostori na monitorju v fokusu |
| `Super + G` | Preklopi združevanje oken |
| `Super + Alt + G` | Premakni okno iz skupine |
| `Super + Alt + Tab` | Kroži med okni v skupini |
| `Super + Alt + Shift + Tab` | Kroži nazaj med okni v skupini |
| `Super + Alt + Scroll Wheel` | Kroži med okni v skupini |
| `Super + Alt + 1/2/3/4/5` | Skoči na določeno okno v skupini |
| `Super + Alt + Arrow` | Premakni okno v skupino v smeri puščice, vključno z oknom na monitorju na tisti strani |
| `Super + Ctrl + Left/Right` | Premikaj se med okni znotraj skupine ploščic |
| `Super + Ctrl + Z` | Povečaj zaslon (ponovite za večjo povečavo) |
| `Super + Ctrl + Alt + Z` | Popolnoma pomanjšaj zaslon |
| `Super + /` | Korak naprej med možnostmi skaliranja monitorja |
| `Super + Alt + /` | Korak nazaj med možnostmi skaliranja monitorja |
| `Alt + Tab` | Kroži naprej med okni na aktivnem delovnem prostoru |
| `Alt + Shift + Tab` | Kroži nazaj med okni na aktivnem delovnem prostoru |
| `Ctrl + Alt + Tab` | Kroži fokus naprej med monitorji |
| `Ctrl + Alt + Shift + Tab` | Kroži fokus nazaj med monitorji |
| `Super + I` | Preklopi jezik vnosa (pri več kot eni postavitvi ali načinu vnosa) |
| `Super + Shift + I` | Preklopi jezik vnosa nazaj |

Na sledilni ploščici poteze s tremi in štirimi prsti preklapljajo delovne prostore, premikajo okna ter odpirajo meni in konzolo Quake; geste si oglejte v [tipkovnica, miška in sledilna ploščica](34-keyboard-mouse-trackpad.md).

Za spreminjanje velikosti se uporabljata tipki desno od 0, karkoli že vaša tipkovnica nanju natisne: `-` in `=` na ameriških tipkovnicah, `+` in `´` na danskih in švedskih, `+` in `\` na norveških, `ß` in `´` na nemških, `'` in `¡` na španskih ter `-` in `^` na japonskih (JIS). `Super + K` jih navede tako, kot jih natisne vaša tipkovnica. Na JIS je `Super + ^` enako `Super + Equal`, medtem ko je `Super + Shift + -` (ki vnese `=`) enako `Super + Shift + Minus`. Skaliranje monitorja in upravitelj gesel uporabljata `/`; na postavitvah, ki `/` vnesejo samo s Shift, kot večina evropskih, namesto tega uporabita tipko levo od desnega Shifta (`-` na danskih in nemških).

## Sistemski nadzor

| Bližnjica | Funkcija |
| ----------------------- | --------------------- |
| `Super + Ctrl + A` | Pano za zvok |
| `Super + Ctrl + B` | Pano za Bluetooth |
| `Super + Ctrl + N` | Pano za Wifi/omrežje |
| `Super + Ctrl + D` | Pano za zaslon |
| `Super + Ctrl + P` | Pano za napajanje |
| `Super + Ctrl + X` | Pano za agente |
| `Super + Ctrl + Alt + D` | Pano za koledar |
| `Super + Ctrl + Alt + E` | Pano za svetovno uro |
| `Super + Ctrl + 1-9` | Preklopi pano v vrstici po položaju |
| `Super + Ctrl + S` | Meni za deljenje (prek LocalSend) |
| `Super + Ctrl + C` | Nadzor zajema (posnetek zaslona/snemanje/izbirnik) |
| `Super + Ctrl + O` | Preklopi meni |
| `Super + Ctrl + H` | Meni za strojno opremo |
| `Super + Ctrl + E` | Izbirnik emojijev |
| `Super + Ctrl + .` | Prekodiraj medije |
| `Super + Shift + Ctrl + A` | Zaženi privzetega agenta |
| `Power` key | Sistemski meni |
| `Super + Shift + Copilot` key | Meni Omarchy |

## Prilagoditve

| Bližnjica | Funkcija |
| ----------------------- | --------------------- |
| `Shift + Brightness Up` | Največja svetlost zaslona |
| `Shift + Brightness Down` | Najmanjša svetlost zaslona |
| `Alt + Brightness Up/Down` | Natančne spremembe svetlosti za 1% |
| `Alt + Volume Up/Down` | Natančne spremembe glasnosti za 1% |
| `Keyboard Brightness Up/Down` | Osvetlitev tipkovnice svetlejša/temnejša |
| `Keyboard Backlight` | Kroži med ravnmi osvetlitve tipkovnice |
| `Ctrl + Brightness Up/Down` | Osvetlitev tipkovnice svetlejša/temnejša, na tipkovnicah brez lastnih tipk |
| `Mic Mute` | Utišaj mikrofon |
| `Shift + Mute` | Preklopi izhod zvoka |
| `Touchpad Toggle` | Vklopi ali izklopi sledilno ploščico |
| `Display` key | Kroži med postavitvami delovnega prostora |
| `Alt + Play` | Naslednja skladba |
| `Alt + Shift + Play` | Prejšnja skladba |

## Zagon programov

| Bližnjica | Funkcija |
| ----------------------- | --------------------- |
| `Super + Return` | Terminal |
| `Super + Alt + Return` | Terminal Tmux |
| `Super + Ctrl + Return` | Herdr (upravitelj agentov) |
| `Super + Shift + Return` or `Super + Shift + B` | Brskalnik |
| `Super + Shift + Alt + B` | Brskalnik (zasebno/inkognito) |
| `Super + Shift + F` | Upravitelj datotek |
| `Super + Shift + Alt + F` | Upravitelj datotek v cwd terminala |
| `Super + Shift + M` | Glasba (Spotify) |
| `Super + Shift + Alt + M` | Glasba (cliamp) |
| `Super + Shift + /` | Upravitelj gesel (1password) |
| `Super + Shift + Q` or `Calculator` key | Kalkulator (Omacalc) |
| `Super + Shift + D` | Docker (lazydocker, ko je nameščen) |
| `Super + Shift + T` | Dejavnost (btop) |
| `Super + Shift + N` | Urejevalnik (Plain ali vaš izbrani privzeti) |
| `Super + Shift + C` | Koledar ([HEY](https://hey.com/)) |
| `Super + Shift + E` | E-pošta ([HEY](https://hey.com/)) |
| `Super + Shift + Alt + E` | Nova e-pošta ([HEY](https://hey.com/)) |
| `Super + Shift + A` | Vaš privzeti agent ali ChatGPT, dokler ne izberete svojega |
| `Super + Shift + Alt + A` | AI (Grok) |
| `Super + Shift + G` | Sporočilnik (Signal) |
| `Super + Shift + P` | Google Photos |
| `Super + Shift + S` | Google Maps |
| `Super + Shift + Alt + G` | Sporočilnik (WhatsApp) |
| `Super + Shift + Ctrl + G` | Sporočilnik (Google) |
| `Super + Shift + O` | Obsidian |
| `Super + Shift + W` | Pisanje (Omawrite) |
| `Super + Shift + X` | X |
| `Super + Shift + Alt + X` | X (nova objava) |
| `Super + Shift + Y` | YouTube |

Bližnjice spremenite/dodajte v `~/.config/hypr/bindings.lua`.

## Univerzalno odložišče

| Bližnjica | Funkcija |
| ----------------------- | --------------------- |
| `Super + A` | Izberi vse v programih, ki podpirajo `Ctrl + A` |
| `Super + C` | Kopiraj |
| `Super + X` | Izreži (ne v terminalu) |
| `Super + V` | Prilepi |
| `Super + Ctrl + V` | Upravitelj odložišča |

Običajno v Linuxu potrebujete `Ctrl + Shift + C/V` za kopiranje in lepljenje v terminalu ter `Ctrl + C/V`, da to počnete povsod drugje. Te poenotene bližnjice za odložišče v Omarchy delujejo povsod.

## Zajem

| Bližnjica | Funkcija |
| ------------------- | ------------------------------ |
| `Print Screen` | Posnetek zaslona |
| `Super + Ctrl + Alt + C` | Posnetek zaslona (isti posnetek, za tipkovnice brez tipke Print Screen) |
| `Super + Ctrl + C` | Meni za zajem |
| `Alt + Print Screen` | Snemanje zaslona |
| `Super + Shift + Ctrl + Alt + C` | Snemanje zaslona brez zvoka, brez menija (pritisnite znova za ustavitev) |
| `Super + Print Screen` | Izbirnik barv |
| `Super + Ctrl + Print Screen` | Izluščenje besedila v odložišče |
| `Super + Alt + [` | Pomanjšaj prekrivanje spletne kamere med snemanjem |
| `Super + Alt + ]` | Povečaj prekrivanje spletne kamere med snemanjem |
| `Alt + Shift + L` | Kopiraj trenutni URL iz spletnega programa ali brskalnika |
| `Alt + Shift + D` | Prenesi videoposnetek na trenutni strani v `~/Videos` |
| `Alt + Space` | Začni/ustavi narekovanje (zahteva _Setup > Defaults > Dictation_) |
| `Right Alt` | Drži za narekovanje (zahteva _Setup > Defaults > Dictation_) |

Pri snemanju zaslona bližnjica najprej vpraša, kateri zvok želite, nato začne snemati. Pritisnite jo znova, da ustavite. Podrobnosti najdete v [posnetki zaslona in snemanje](12-screenshots-recording.md).

Vse možnosti zajema so na voljo tudi pod _Trigger > Capture_ v meniju Omarchy (`Super + Space`).

## Obvestila

| Bližnjica | Funkcija |
| ----------------------- | --------------------- |
| `Super + ,` | Ukrepaj ob zadnjem obvestilu: odpri ga ali pritisni njegov edini gumb, izberi med njegovimi možnostmi ali ga zavrni, ko jih nima |
| `Super + Shift + ,` | Zavrni vsa obvestila |
| `Super + Ctrl + ,` | Nadzoruj obvestila s tipkovnico |
| `Super + Alt + ,` | Zavrni zadnje obvestilo |
| `Super + Shift + Alt + ,` | Odpri zgodovino obvestil |
| `Super + Ctrl + Alt + ,` | Preklopi utišanje obvestil |

## Slog

| Bližnjica | Funkcija |
| ----------------------- | --------------------- |
| `Super + Ctrl + T` | Izberi novo temo (tudi `Super + Ctrl + Shift + Space`) |
| `Super + Ctrl + W` | Izberi ozadje teme (tudi `Super + Ctrl + Space`) |
| `Super + Backspace` | Preklopi prosojnost okna |
| `Super + Ctrl + Backspace` | Preklopi kvadratno razmerje za eno okno |

Dodatne slike za ozadje so v `~/.config/omarchy/backgrounds/<theme name>`. Na voljo tudi prek _Install > Style > Background_ v meniju Omarchy.

Vse možnosti sloga so na voljo tudi pod _Appearance_ v meniju Omarchy (`Super + Space`).

## Preklopi

| Bližnjica | Funkcija |
| ----------------------- | --------------------- |
| `Super + Ctrl + I` | Preklopi zaklepanje med nedejavnostjo |
| `Super + Ctrl + Delete` | Preklopi zaslon prenosnika vklop/izklop |
| `Super + Ctrl + Alt + Delete` | Preklopi zrcaljenje zaslona prenosnika |
| `Super + Shift + Space` | Preklopi zgornjo vrstico |
| `Shift + Mute` | Preklopi na naslednji izhod zvoka |
| `Shift + Play` | Preklopi na naslednji vir medijev |
| `Super + Shift + Backspace` | Preklopi razmike med okni |
| `Super + Ctrl + Alt + F` | Preklopi celozaslonsko namizje (zgornja vrstica + razmiki med okni) |

## Opomniki

| Bližnjica | Funkcija |
| ----------------------- | --------------------- |
| `Super + Ctrl + R` | Nastavi opomnik |
| `Super + Ctrl + Alt + R` | Poglej vse opomnike |
| `Super + Ctrl + Shift + R` | Počisti vse opomnike |

## Opozorila

| Bližnjica | Funkcija |
| ----------------------- | --------------------- |
| `Super + Ctrl + Alt + T` | Prikaži čas kot obvestilo |
| `Super + Ctrl + Alt + B` | Prikaži baterijo kot obvestilo |
| `Super + Ctrl + Alt + W` | Preklopi vreme kot obvestilo |

## Tmux

Predpona je `Ctrl + Space` (deluje tudi `Ctrl + B`). Te bližnjice lahko spremenite v `~/.config/tmux/tmux.conf`.

### Panoji

| Bližnjica | Funkcija |
| ----------------------- | --------------------- |
| `Prefix + v` | Razdeli pano ob strani (navpično) |
| `Prefix + h` | Razdeli pano spodaj (vodoravno) |
| `Prefix + x` | Zapri pano |
| `Prefix + z` | Preklopi povečavo panoja (cel zaslon) |
| `Alt + Enter` | Razdeli pano spodaj (brez predpone) |
| `Alt + Shift + Enter` | Razdeli pano ob strani (brez predpone) |
| `Alt + Escape` | Zapri pano (brez predpone) |
| `Ctrl + Alt + Arrows` | Premikaj se med panoji |
| `Ctrl + Alt + Shift + Arrows` | Spremeni velikost panojev |

### Okna

| Bližnjica | Funkcija |
| ----------------------- | --------------------- |
| `Prefix + c` | Novo okno |
| `Prefix + k` | Zapri okno |
| `Prefix + r` | Preimenuj okno |
| `Alt + 1-9` | Pojdi na določeno okno |
| `Alt + Arrow Left/Right` | Premikaj se med okni |
| `Alt + Shift + Arrow Left/Right` | Premakni okno levo/desno |

### Seje

| Bližnjica | Funkcija |
| ----------------------- | --------------------- |
| `Prefix + C` | Nova seja |
| `Prefix + K` | Zapri sejo |
| `Prefix + R` | Preimenuj sejo |
| `Prefix + N` | Naslednja seja |
| `Prefix + P` | Prejšnja seja |
| `Alt + Arrow Up/Down` | Premikaj se med sejami |
| `Prefix + s` | Seznam sej |
| `Prefix + d` | Odklopi se od seje |

### Način kopiranja (slog vi)

| Bližnjica | Funkcija |
| ----------------------- | --------------------- |
| `Prefix + [` | Vstopi v način kopiranja |
| `v` | Začni izbiro (v načinu kopiranja) |
| `y` | Kopiraj izbiro (v načinu kopiranja) |

### Splošno

| Bližnjica | Funkcija |
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
| `tsl <count> <command>` | Ustvari postavitev roja z več panoji |

## Terminal Ghostty

Terminal Ghostty namestite z _Install > Terminal_ prek menija Omarchy.

| Bližnjica | Funkcija |
| ----------------------- | --------------------- |
| `Ctrl + Shift + E` | Nova razdelitev spodaj |
| `Ctrl + Shift + O` | Nova razdelitev ob strani |
| `Ctrl + Alt + Arrows` | Premikaj se med razdelitvami |
| `Super + Ctrl + Shift + Arrows` | Spremeni velikost razdelitve za 10 vrstic |
| `Super + Ctrl + Shift + Alt + Arrows` | Spremeni velikost razdelitve za 100 vrstic |
| `Ctrl + Shift + T` | Nov zavihek |
| `Ctrl + Shift + Arrows` | Premikaj se med zavihki |
| `Alt + Numbers` | Pojdi na določen zavihek |
| `Shift + Pg Up/Down` | Drsaj po zgodovini |
| `Ctrl + Left mouse` | Odpri povezavo v brskalniku |

## Upravitelj datotek

| Bližnjica | Funkcija |
| ------------------- | ------------------------------ |
| `Ctrl + L` | Pojdi na pot |
| `Space` | Predogled datoteke (krmarjenje s puščicami) |
| `Alt + Up` | Pojdi gor v nadrejeno mapo |

## Neovim (z lazyvim)

### Krmarjenje

| Bližnjica | Funkcija |
| ------------------------ | ------------------------------- |
| `Space` | Prikaži možnosti ukazov |
| `Space Space` | Odpri datoteko z mehkim iskanjem |
| `Space E` | Preklopi stransko vrstico |
| `Space G G` | Prikaži kontrole git |
| `Space S G` | Išči vsebino datoteke |
| `Ctrl + W W` | Skoči med stransko vrstico in urejevalnikom |
| `Ctrl + Left/right arrow` | Spremeni velikost stranske vrstice |
| `Shift + H` | Pojdi na levi zavihek datoteke |
| `Shift + L` | Pojdi na desni zavihek datoteke |
| `Space B D` | Zapri zavihek datoteke |

### V stranski vrstici

| Bližnjica | Funkcija |
| ------------------------ | ------------------------------- |
| `A` | Dodaj novo datoteko v nadrejeni imenik |
| `Shift + A` | Dodaj nov podimenik v nadrejeni imenik |
| `D` | Izbriši označeno datoteko/imenik |
| `M` | Premakni označeno datoteko/imenik |
| `R` | Preimenuj označeno datoteko/imenik |
| `?` | Prikaži pomoč za vse ukaze |

[Oglejte si vse bližnjice za Neovim, ki jih nastavi LazyVim](https://www.lazyvim.org/keymaps).

## Hitri emojiji

Z `Super + Ctrl + E` lahko prikažete celoten izbirnik emojijev, ki bo izbiro dal v odložišče, ali pa uporabite te možnosti za hitri dostop.

| Bližnjica | EM | Namig |
| ------------ | -- | ---------- |
| `Shift + CapsLock M S` | 😄 | nasmeh |
| `Shift + CapsLock M C` | 😂 | jok |
| `Shift + CapsLock M L` | 😍 | ljubezen |
| `Shift + CapsLock M V` | ✌️ | zmaga |
| `Shift + CapsLock M H` | ❤️ | srce |
| `Shift + CapsLock M Y` | 👍 | da |
| `Shift + CapsLock M N` | 👎 | ne |
| `Shift + CapsLock M F` | 🖕 | fuck |
| `Shift + CapsLock M W` | 🤞 | želja |
| `Shift + CapsLock M R` | 🤘 | rock |
| `Shift + CapsLock M K` | 😘 | poljub |
| `Shift + CapsLock M E` | 🙄 | zavijanje z očmi |
| `Shift + CapsLock M I` | 😉 | mežik |
| `Shift + CapsLock M P` | 🙏 | molitev |
| `Shift + CapsLock M D` | 🤤 | slinjenje |
| `Shift + CapsLock M M` | 💰 | denar |
| `Shift + CapsLock M X` | 🎉 | praznovanje |
| `Shift + CapsLock M 1` | 💯 | 100% |
| `Shift + CapsLock M T` | 🥂 | zdravica |
| `Shift + CapsLock M O` | 👌 | ok |
| `Shift + CapsLock M G` | 👋 | pozdrav |
| `Shift + CapsLock M A` | 💪 | roka |
| `Shift + CapsLock M B` | 🤯 | razneseno |

## Hitra dopolnjevanja

| Bližnjica | Dopolnitev |
| ------------ | ---------- |
| `Shift + CapsLock Space Space` | — (dolgi pomišljaj) |
| `Shift + CapsLock Space N` | Vaše ime (kot ste ga vnesli pri namestitvi) |
| `Shift + CapsLock Space E` | Vaš e-poštni naslov (kot ste ga vnesli pri namestitvi) |

Več jih lahko dodate tako, da uredite `~/.XCompose`, nato v terminalu zaženete `omarchy restart xcompose`, da se spremembe uveljavijo.
