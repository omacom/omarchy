# Bližnjice na tipkovnici

Vse glavne bližnjice na tipkovnici si lahko ogledate s `Super + K` (bližnjice za Tmux s `Super + Alt + K` in bližnjice za Herdr s `Super + Ctrl + K`).

## Kako so bližnjice razporejene

Vsaka bližnjica je na ravni, ki jo določajo njene modifikacijske tipke, vsaka raven pa ima eno nalogo. Zato se bližnjice ne zameglijo med seboj, vi pa običajno lahko uganete, kje kaj živi.

| Raven | Kaj živi tam | Primeri |
| --- | --- | --- |
| `Super + key` | Sistem: okna, delovni prostori, postavitve in glavni meniji | `Super + Space` meni Omarchy, `Super + W` zapri okno, `Super + F` cel zaslon |
| `Super + Shift + key` | Aplikacije | `Super + Shift + B` brskalnik, `Super + Shift + E` e-pošta, `Super + Shift + N` urejevalnik |
| `Super + Ctrl + key` | Plošče in sistemski meniji | `Super + Ctrl + A` zvok, `Super + Ctrl + N` omrežje, `Super + Ctrl + C` meni za zajem |
| `Super + Ctrl + Alt + key` | Hitra dejanja in obvestila | `Super + Ctrl + Alt + T` pokaži čas, `Super + Ctrl + Alt + B` baterija, `Super + Ctrl + Alt + C` posnetek zaslona |

Če bližnjici dodate `Alt`, dobite različico iste stvari, nikoli nekaj nepovezanega:

- `Super + Shift + B` odpre brskalnik; `Super + Shift + Alt + B` odpre zasebno okno
- `Super + Shift + E` odpre e-pošto; `Super + Shift + Alt + E` začne novo
- `Super + F` gre na cel zaslon; `Super + Alt + F` gre na celotno širino
- `Super + Ctrl + C` odpre meni za zajem; `Super + Ctrl + Alt + C` preskoči meni in naredi posnetek zaslona

Ko dodajate bližnjico:

1. Najprej izberite raven glede na to, kaj počne, nato izberite tipko.
2. Ne premikajte obstoječe bližnjice, da bi naredili prostor. Poiščite prosto tipko na pravi ravni.
3. `Alt` uporabite samo za različico bližnjice brez nje.

Nekaj bližnjic krši ta pravila, ker so priročne. `Shift` s puščico ali `Tab` premakne ali obrne, namesto da bi odprl aplikacijo, `Print`, medijske tipke, `Alt + Tab` in `Ctrl + Alt + Del` pa delujejo tako kot povsod drugje. To so izjeme, ne vzorci za kopiranje.

Če vam privzeta nastavitev ne ustreza (recimo, da želite `Super + Shift + S` za posnetke zaslona kot v Windows), jo znova povežite v `~/.config/hypr/bindings.lua`.

## Krmarjenje

| Bližnjica | Funkcija |
| ----------------------- | --------------------- |
| `Super + Space` | Meni Omarchy (aplikacije in vse ostalo) |
| `Super + Alt + Space` | Mreža aplikacij |
| `Super + Escape` | Sistemski meni (zaustavitev, ponovni zagon itd.) |
| `Super + Ctrl + L` | Zakleni računalnik |
| `Super + W` ali `Super + Q` | Zapri okno |
| `Ctrl + Alt + Del` | Zapri vsa okna |
| `Super + T` | Preklopi okno med ploščicami in plavajočim načinom |
| `Super + J` | Preklopi položaj okna (vodoravno/navpično) |
| `Super + O` | Preklopi okno v pripeto plavajoče stanje |
| `Super + L` | Kroži med postavitvami dwindle, scrolling in floating |
| `Super + Alt + L` | Kroži med postavitvami v obratnem vrstnem redu |
| `Super + P` | Preklopi slog pseudo okna (naravno proti raztegnjenemu) |
| `Super + F` | Pojdi na cel zaslon |
| `Super + Alt + F` | Pojdi na celotno širino |
| `Super + Ctrl + F` | Pojdi na cel zaslon znotraj okna |
| `Super + 1/2/3/4` | Skoči na določen delovni prostor na monitorju v fokusu |
| `Super + Tab` | Skoči na naslednji delovni prostor na monitorju v fokusu |
| `Super + Shift + Tab` | Skoči na prejšnji delovni prostor na monitorju v fokusu |
| `Super + Ctrl + Tab` | Skoči na nekdanji delovni prostor na monitorju v fokusu |
| `Super + Shift + 1/2/3/4` | Premakni okno na delovni prostor na monitorju v fokusu |
| `Super + Shift + Alt + 1/2/3/4` | Premakni okno na delovni prostor na monitorju v fokusu, ne da bi mu sledil |
| `Super + S` | Preklopi celotni scratchpad |
| `Super + Alt + S` | Premakni okno na celotni scratchpad |
| `Super + Grave` | Preklopi konzolo Quake |
| `Super + Shift + Grave` | Premakni okno na konzolo Quake |
| `Super + Shift + Ctrl + Arrows` | Premakni okno na monitor v tisti smeri |
| `Super + Shift + Alt + Arrows` | Premakni delovni prostor na monitor v tisti smeri |
| `Super + Arrow` | Premakni fokus na okno v smeri puščice, ob robu zaslona preidi na monitor na tisti strani |
| `Super + Shift + Arrow` | Zamenjaj okno z drugim v smeri puščice, tudi z onim na monitorju na tisti strani |
| `Super + Minus` | Razširi okno v levo |
| `Super + Equal` | Skrči okno v levo |
| `Super + Shift + Minus` | Skrči okno navzgor |
| `Super + Shift + Equal` | Razširi okno navzdol |
| `Super + Alt + Minus/Equal` | Enako spreminjanje velikosti v manjših korakih |
| `Super + Ctrl + Minus/Equal` | Enako spreminjanje velikosti v večjih korakih |
| `Super + Alt + Home` | Shrani širino okna |
| `Super + Home` | Obnovi shranjeno širino okna |
| `Super + Left Mouse` | Vleci okno naokrog |
| `Super + Right Mouse` | Spremeni velikost okna |
| `Super + Scroll Wheel` | Pomikaj se med delovnimi prostori na monitorju v fokusu |
| `Super + G` | Preklopi združevanje oken v skupine |
| `Super + Alt + G` | Premakni okno iz skupine |
| `Super + Alt + Tab` | Kroži med okni v skupini |
| `Super + Alt + Shift + Tab` | Kroži nazaj med okni v skupini |
| `Super + Alt + Scroll Wheel` | Kroži med okni v skupini |
| `Super + Alt + 1/2/3/4/5` | Skoči na določeno okno v skupini |
| `Super + Alt + Arrow` | Premakni okno v skupino v smeri puščice, tudi tisto na monitorju na tisti strani |
| `Super + Ctrl + Left/Right` | Premikaj se med okni znotraj skupine s ploščicami |
| `Super + Ctrl + Z` | Povečaj zaslon (ponovi za večjo povečavo) |
| `Super + Ctrl + Alt + Z` | Popolnoma pomanjšaj zaslon |
| `Super + /` | Pomikaj se naprej med možnostmi skaliranja monitorja |
| `Super + Alt + /` | Pomikaj se nazaj med možnostmi skaliranja monitorja |
| `Alt + Tab` | Kroži naprej med okni na aktivnem delovnem prostoru |
| `Alt + Shift + Tab` | Kroži nazaj med okni na aktivnem delovnem prostoru |
| `Ctrl + Alt + Tab` | Kroži fokus naprej med monitorji |
| `Ctrl + Alt + Shift + Tab` | Kroži fokus nazaj med monitorji |

Bližnjice za spreminjanje velikosti uporabljajo fizični tipki `code:20` in `code:21` (XKB `<AE11>` in `<AE12>`), ne glede na znake, natisnjene na tipkovnici. Na tipkovnicah US sta ti tipki `-` in `=`; na japonskih (JIS) tipkovnicah sta `-` in `^`; na španskih tipkovnicah sta `'` in `¡`. Na JIS je `Super + ^` pravzaprav `Super + Equal`, medtem ko je `Super + Shift + -` (ki vtipka `=`) pravzaprav `Super + Shift + Minus`.

## Sistemski nadzor

| Bližnjica | Funkcija |
| ----------------------- | --------------------- |
| `Super + Ctrl + A` | Plošča za zvok |
| `Super + Ctrl + B` | Plošča Bluetooth |
| `Super + Ctrl + N` | Plošča za Wi-Fi/omrežje |
| `Super + Ctrl + D` | Plošča za zaslon |
| `Super + Ctrl + P` | Plošča za napajanje |
| `Super + Ctrl + Alt + D` | Plošča s koledarjem |
| `Super + Ctrl + Alt + E` | Plošča s svetovno uro |
| `Super + Ctrl + 1-9` | Preklopi ploščo v vrstici po položaju |
| `Super + Ctrl + S` | Meni za deljenje (prek LocalSend) |
| `Super + Ctrl + C` | Nadzor zajema (posnetek zaslona/snemanje/izbirnik) |
| `Super + Ctrl + O` | Preklopi meni |
| `Super + Ctrl + H` | Meni strojne opreme |
| `Super + Ctrl + E` | Izbirnik emojijev |
| `Super + Ctrl + .` | Prekodiraj medije |
| `Super + Shift + Ctrl + A` | Izberi agenta AI |

## Prilagoditve

| Bližnjica | Funkcija |
| ----------------------- | --------------------- |
| `Shift + Brightness Up` | Največja svetlost zaslona |
| `Shift + Brightness Down` | Najmanjša svetlost zaslona |
| `Alt + Brightness Up/Down` | Natančne spremembe svetlosti za 1 % |
| `Alt + Volume Up/Down` | Natančne spremembe glasnosti za 1 % |
| `Keyboard Brightness Up/Down` | Osvetlitev tipkovnice svetlejša/temnejša |
| `Keyboard Backlight` | Kroži med ravnmi osvetlitve tipkovnice |
| `Alt + Play` | Naslednja skladba |
| `Alt + Shift + Play` | Prejšnja skladba |

## Zaganjanje aplikacij

| Bližnjica | Funkcija |
| ----------------------- | --------------------- |
| `Super + Return` | Terminal |
| `Super + Alt + Return` | Terminal Tmux |
| `Super + Ctrl + Return` | Herdr (upravitelj agentov) |
| `Super + Shift + Return` | Brskalnik |
| `Super + Shift + Alt + B` | Brskalnik (zasebno/inkognito) |
| `Super + Shift + F` | Upravitelj datotek |
| `Super + Shift + Alt + F` | Upravitelj datotek v cwd terminala |
| `Super + Shift + M` | Glasba (Spotify) |
| `Super + Shift + Alt + M` | Glasba (cliamp) |
| `Super + Shift + /` | Upravitelj gesel (1password) |
| `Super + Shift + Q` | Kalkulator (Omacalc) |
| `Super + Shift + T` | Dejavnost (btop) |
| `Super + Shift + N` | Urejevalnik (Neovim) |
| `Super + Shift + C` | Koledar ([HEY](https://hey.com/)) |
| `Super + Shift + E` | E-pošta ([HEY](https://hey.com/)) |
| `Super + Shift + Alt + E` | Nova e-pošta ([HEY](https://hey.com/)) |
| `Super + Shift + A` | AI (ChatGPT) |
| `Super + Shift + Alt + A` | AI (Grok) |
| `Super + Shift + G` | Sporočilnik (Signal) |
| `Super + Shift + P` | Google Photos |
| `Super + Shift + S` | Google Maps |
| `Super + Shift + Alt + G` | Sporočilnik (WhatsApp) |
| `Super + Shift + Ctrl + G` | Sporočilnik (Google) |
| `Super + Shift + O` | Obsidian |
| `Super + Shift + W` | Pisanje (Omawrite) |
| `Super + Shift + X` | X |
| `Super + Shift + Alt + X` | X Compose |
| `Super + Shift + Y` | YouTube |

Spremenite/dodajte vezave v `~/.config/hypr/bindings.lua`.

## Univerzalno odložišče

| Bližnjica | Funkcija |
| ----------------------- | --------------------- |
| `Super + A` | Izberi vse v aplikacijah, ki podpirajo `Ctrl + A` |
| `Super + C` | Kopiraj |
| `Super + X` | Izreži (ne v terminalu) |
| `Super + V` | Prilepi |
| `Super + Ctrl + V` | Upravitelj odložišča |

Običajno v Linuxu potrebujete `Ctrl + Shift + C/V`, da kopirate in prilepite v terminalu, in `Ctrl + C/V`, da to naredite povsod drugje. Te poenotene bližnjice odložišča v Omarchy delujejo povsod.

## Zajem

| Bližnjica | Funkcija |
| ------------------- | ------------------------------ |
| `Print Screen` | Posnetek zaslona |
| `Super + Ctrl + Alt + C` | Posnetek zaslona (isti posnetek, za tipkovnice brez tipke Print Screen) |
| `Super + Ctrl + C` | Meni za zajem |
| `Alt + Print Screen` | Snemanje zaslona |
| `Super + Print Screen` | Izbirnik barv |
| `Super + Ctrl + Print Screen` | Izvlečenje besedila v odložišče |
| `Super + Alt + [` | Med snemanjem pomanjšaj prekrivanje spletne kamere |
| `Super + Alt + ]` | Med snemanjem povečaj prekrivanje spletne kamere |
| `Alt + Shift + L` | Kopiraj trenutni URL iz spletne aplikacije ali Chromium |
| `Alt + Shift + D` | Prenesi videoposnetek na trenutni strani v `~/Videos` |
| `Alt + Space` | Začni/ustavi narekovanje (zahteva _Nastavitev > Privzeto > Narekovanje_) |
| `Right Alt` | Drži za narekovanje (zahteva _Nastavitev > Privzeto > Narekovanje_) |

Pri snemanju zaslona vas bližnjica najprej vpraša, kateri zvok želite, nato začne snemati. Pritisnite jo znova, da ustavite. Za podrobnosti glejte [posnetki zaslona in snemanje](12-screenshots-recording.md).

Vse možnosti zajema so dostopne tudi pod _Sproži > Zajem_ v meniju Omarchy (`Super + Space`).

## Obvestila

| Bližnjica | Funkcija |
| ----------------------- | --------------------- |
| `Super + ,` | Ukrepaj ob najnovejšem obvestilu: odpri ga ali pritisni njegov edini gumb, izberi med njegovimi možnostmi ali ga opusti, kadar nima nobene |
| `Super + Shift + ,` | Opusti vsa obvestila |
| `Super + Ctrl + ,` | Nadzoruj obvestila s tipkovnico |
| `Super + Alt + ,` | Opusti najnovejše obvestilo |
| `Super + Shift + Alt + ,` | Odpri zgodovino obvestil |
| `Super + Ctrl + Alt + ,` | Preklopi utišanje obvestil |

## Slog

| Bližnjica | Funkcija |
| ----------------------- | --------------------- |
| `Super + Ctrl + T` | Izberi novo temo (tudi `Super + Ctrl + Shift + Space`) |
| `Super + Ctrl + W` | Izberi ozadje teme (tudi `Super + Ctrl + Space`) |
| `Super + Backspace` | Preklopi prosojnost okna |
| `Super + Ctrl + Backspace` | Preklopi kvadratno razmerje za eno okno |

Dodatne slike ozadja so v `~/.config/omarchy/backgrounds/<theme name>`. Na voljo tudi prek _Namesti > Slog > Ozadje_ v meniju Omarchy.

Vse možnosti sloga so dostopne tudi pod _Slog_ v meniju Omarchy (`Super + Space`).

## Preklopi

| Bližnjica | Funkcija |
| ----------------------- | --------------------- |
| `Super + Ctrl + I` | Preklopi zaklepanje med nedejavnostjo |
| `Super + Ctrl + Delete` | Preklopi zaslon prenosnika vklop/izklop |
| `Super + Ctrl + Alt + Delete` | Preklopi zrcaljenje zaslona prenosnika |
| `Super + Shift + Space` | Preklopi zgornjo vrstico |
| `Shift + Mute` | Preklopi na naslednji zvočni izhod |
| `Shift + Play` | Preklopi na naslednji vir medijev |
| `Super + Shift + Backspace` | Preklopi vrzeli med okni |
| `Super + Ctrl + Alt + F` | Preklopi celozaslonsko namizje (zgornja vrstica + vrzeli med okni) |

## Opomniki

| Bližnjica | Funkcija |
| ----------------------- | --------------------- |
| `Super + Ctrl + R` | Nastavi opomnik |
| `Super + Ctrl + Alt + R` | Poglej vse opomnike |
| `Super + Ctrl + Shift + R` | Počisti vse opomnike |

## Opozorila

| Bližnjica | Funkcija |
| ----------------------- | --------------------- |
| `Super + Ctrl + Alt + T` | Pokaži čas kot obvestilo |
| `Super + Ctrl + Alt + B` | Pokaži baterijo kot obvestilo |
| `Super + Ctrl + Alt + W` | Preklopi vreme kot obvestilo |

## Tmux

Predponska tipka je `Ctrl + Space` (deluje tudi `Ctrl + B`). Te vezave lahko spremenite v `~/.config/tmux/tmux.conf`.

### Podokna

| Bližnjica | Funkcija |
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

| Bližnjica | Funkcija |
| ----------------------- | --------------------- |
| `Prefix + c` | Novo okno |
| `Prefix + k` | Uniči okno |
| `Prefix + r` | Preimenuj okno |
| `Alt + 1-9` | Pojdi na določeno okno |
| `Alt + Arrow Left/Right` | Premikaj se med okni |
| `Alt + Shift + Arrow Left/Right` | Premakni okno levo/desno |

### Seje

| Bližnjica | Funkcija |
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

| Bližnjica | Funkcija |
| ----------------------- | --------------------- |
| `Prefix + [` | Vstopi v način kopiranja |
| `v` | Začni izbiro (v načinu kopiranja) |
| `y` | Kopiraj izbiro (v načinu kopiranja) |

### Splošno

| Bližnjica | Funkcija |
| ----------------------- | --------------------- |
| `Prefix + q` | Znova naloži konfiguracijo |
| `Prefix + ?` | Pokaži bližnjice Tmux |
| `Prefix + :` | Ukazni poziv |

### Funkcije postavitve Tmux

Te funkcije je treba zagnati znotraj seje Tmux.

| Ukaz | Funkcija |
| ------- | -------- |
| `tdl <ai> [<second_ai>]` | Ustvari razvojno postavitev z urejevalnikom, AI in terminalom |
| `tdlm <ai> [<second_ai>]` | Ustvari razvojno postavitev za vsak podimenik |
| `tsl <count> <command>` | Ustvari postavitev roja z več podokni |

## Terminal Ghostty

Terminal Ghostty namestite z _Namesti > Terminal_ prek menija Omarchy.

| Bližnjica | Funkcija |
| ----------------------- | --------------------- |
| `Ctrl + Shift + E` | Nova delitev spodaj |
| `Ctrl + Shift + O` | Nova delitev ob strani |
| `Ctrl + Alt + Arrows` | Premikaj se med delitvami |
| `Super + Ctrl + Shift + Arrows` | Spremeni velikost delitve za 10 vrstic |
| `Super + Ctrl + Shift + Alt + Arrows` | Spremeni velikost delitve za 100 vrstic |
| `Ctrl + Shift + T` | Nov zavihek |
| `Ctrl + Shift + Arrows` | Premikaj se med zavihki |
| `Alt + Numbers` | Pojdi na določen zavihek |
| `Shift + Pg Up/Down` | Pomikaj se po zgodovini |
| `Ctrl + Left mouse` | Odpri povezavo v brskalniku |

## Upravitelj datotek

| Bližnjica | Funkcija |
| ------------------- | ------------------------------ |
| `Ctrl + L` | Pojdi na pot |
| `Space` | Predogled datoteke (puščice za krmarjenje) |
| `Alt + Up` | Pojdi gor v nadrejeno mapo |

## Neovim (z lazyvim)

### Krmarjenje

| Bližnjica | Funkcija |
| ------------------------ | ------------------------------- |
| `Space` | Pokaži možnosti ukazov |
| `Space Space` | Odpri datoteko z mehkim iskanjem |
| `Space E` | Preklopi stransko vrstico |
| `Space G G` | Pokaži kontrole git |
| `Space S G` | Išči po vsebini datotek |
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
| `?` | Pokaži pomoč za vse ukaze |

[Oglejte si vse bližnjice Neovim, ki jih nastavi LazyVim](https://www.lazyvim.org/keymaps).

## Hitri emojiji

Z `Super + Ctrl + E` lahko prikažete celoten izbirnik emojijev, ki bo izbiro dal v odložišče, ali pa uporabite te možnosti za hiter dostop.

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
| `Shift + CapsLock M P` | 🙏 | moli |
| `Shift + CapsLock M D` | 🤤 | slinjenje |
| `Shift + CapsLock M M` | 💰 | denar |
| `Shift + CapsLock M X` | 🎉 | xellebrate |
| `Shift + CapsLock M 1` | 💯 | 100% |
| `Shift + CapsLock M T` | 🥂 | zdravica |
| `Shift + CapsLock M O` | 👌 | ok |
| `Shift + CapsLock M G` | 👋 | pozdrav |
| `Shift + CapsLock M A` | 💪 | roka |
| `Shift + CapsLock M B` | 🤯 | pihanje |

## Hitra dopolnjevanja

| Bližnjica | Dopolnitev |
| ------------ | ---------- |
| `Shift + CapsLock Space Space` | — (dolgi pomišljaj) |
| `Shift + CapsLock Space N` | Vaše ime (kot ste ga vnesli pri nastavitvi) |
| `Shift + CapsLock Space E` | Vaš e-poštni naslov (kot ste ga vnesli pri nastavitvi) |

Več svojih lahko dodate z urejanjem `~/.XCompose`, nato pa v terminalu zaženete `omarchy-restart-xcompose`, da se spremembe uveljavijo.
