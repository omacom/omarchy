# Bližnjice

Vse glavne bližnjice na tipkovnici lahko vidiš s `Super + K` (bližnjice Tmux s `Super + Alt + K` in bližnjice Herdr s `Super + Ctrl + K`).

## Kako so bližnjice razporejene

Vsaka bližnjica je na eni ravni, ki jo določajo njene modifikacijske tipke, vsaka raven pa ima eno nalogo. Zato se bližnjice ne mešajo med seboj in običajno lahko uganeš, kam kaj spada.

| Raven | Kaj je tam | Primeri |
| --- | --- | --- |
| `Super + key` | Sistem: okna, delovni prostori, postavitve in glavni meniji | `Super + Space` meni Omarchy, `Super + W` zapri okno, `Super + F` cel zaslon |
| `Super + Shift + key` | Aplikacije | `Super + Shift + B` brskalnik, `Super + Shift + E` e-pošta, `Super + Shift + N` urejevalnik |
| `Super + Ctrl + key` | Podokna in sistemski meniji | `Super + Ctrl + A` zvok, `Super + Ctrl + N` omrežje, `Super + Ctrl + C` meni za zajem |
| `Super + Ctrl + Alt + key` | Hitra dejanja in obvestila | `Super + Ctrl + Alt + T` prikaži čas, `Super + Ctrl + Alt + B` baterija, `Super + Ctrl + Alt + C` posnetek zaslona |

Dodajanje tipke `Alt` bližnjici da različico iste stvari, nikoli nekaj nepovezanega:

- `Super + Shift + B` odpre brskalnik; `Super + Shift + Alt + B` odpre zasebno okno
- `Super + Shift + E` odpre e-pošto; `Super + Shift + Alt + E` začne novo
- `Super + F` preklopi na cel zaslon; `Super + Alt + F` preklopi na celo širino
- `Super + Ctrl + C` odpre meni za zajem; `Super + Ctrl + Alt + C` preskoči meni in naredi posnetek zaslona

Pri dodajanju bližnjice:

1. Najprej izberi raven glede na to, kaj počne, nato izberi tipko.
2. Ne premikaj obstoječe bližnjice, da bi naredil prostor. Najdi prosto tipko na pravi ravni.
3. `Alt` uporabljaj samo za različico bližnjice brez nje.

Nekaj bližnjic krši ta pravila, ker so priročne. `Shift` s puščico ali `Tab` premika ali obrača namesto da bi odprl aplikacijo, `Print`, medijske tipke, `Alt + Tab` in `Ctrl + Alt + Del` pa delujejo tako kot povsod drugje. To so izjeme, ne vzorci za kopiranje.

Če ti privzeta nastavitev ne ustreza (recimo da želiš `Super + Shift + S` za posnetke zaslona kot v Windows), jo ponovno veži v `~/.config/hypr/bindings.lua`.

## Navigacija

| Bližnjica | Funkcija |
| ----------------------- | --------------------- |
| `Super + Space` | Meni Omarchy (aplikacije in vse drugo) |
| `Super + Alt + Space` | Mreža aplikacij |
| `Super + Escape` | Sistemski meni (zaustavitev, ponovni zagon itd.) |
| `Super + Ctrl + L` | Zakleni računalnik |
| `Super + W` or `Super + Q` | Zapri okno |
| `Ctrl + Alt + Del` | Zapri vsa okna |
| `Super + T` | Preklopi okno med tlakovanjem in plavanjem |
| `Super + J` | Preklopi položaj okna (vodoravno/navpično) |
| `Super + O` | Preklopi okno v način sticky'n'floating |
| `Super + L` | Preklaplaj med postavitvami dwindle, drsenje in plavanje |
| `Super + Alt + L` | Preklaplaj med postavitvami v obratnem vrstnem redu |
| `Super + P` | Preklopi slog psevdookna (naravno proti raztegnjenemu) |
| `Super + F` | Pojdi na cel zaslon |
| `Super + Alt + F` | Pojdi na celo širino |
| `Super + Ctrl + F` | Pojdi na cel zaslon znotraj okna |
| `Super + 1/2/3/4` | Skoči na določen delovni prostor na monitorju v fokusu |
| `Super + Tab` | Skoči na naslednji delovni prostor na monitorju v fokusu |
| `Super + Shift + Tab` | Skoči na prejšnji delovni prostor na monitorju v fokusu |
| `Super + Ctrl + Tab` | Skoči na prejšnji delovni prostor na monitorju v fokusu |
| `Super + Shift + 1/2/3/4` | Premakni okno na delovni prostor na monitorju v fokusu |
| `Super + Shift + Alt + 1/2/3/4` | Premakni okno na delovni prostor na monitorju v fokusu, ne da bi mu sledil |
| `Super + S` | Preklopi celoten scratchpad |
| `Super + Alt + S` | Premakni okno na celoten scratchpad |
| `Super + Grave` | Preklopi konzolo Quake |
| `Super + Shift + Grave` | Premakni okno na konzolo Quake |
| `Super + Shift + Ctrl + Arrows` | Premakni okno na monitor v tisti smeri |
| `Super + Shift + Alt + Arrows` | Premakni delovni prostor na monitor v tisti smeri |
| `Super + Arrow` | Premakni fokus na okno v smeri puščice, na robu zaslona preide na monitor na tisti strani |
| `Super + Shift + Arrow` | Zamenjaj okno z drugim v smeri puščice, tudi z onim na monitorju na tisti strani |
| `Super + Minus` | Razširi okno levo |
| `Super + Equal` | Skrči okno levo |
| `Super + Shift + Minus` | Skrči okno navzgor |
| `Super + Shift + Equal` | Razširi okno navzdol |
| `Super + Alt + Minus/Equal` | Enako spreminjanje velikosti v manjših korakih |
| `Super + Ctrl + Minus/Equal` | Enako spreminjanje velikosti v večjih korakih |
| `Super + Alt + Home` | Shrani širino okna |
| `Super + Home` | Obnovi shranjeno širino okna |
| `Super + Left Mouse` | Vleci okno naokoli |
| `Super + Right Mouse` | Spremeni velikost okna |
| `Super + Scroll Wheel` | Drsi med delovnimi prostori na monitorju v fokusu |
| `Super + G` | Preklopi združevanje oken |
| `Super + Alt + G` | Premakni okno iz skupine |
| `Super + Alt + Tab` | Preklaplaj med okni v skupini |
| `Super + Alt + Shift + Tab` | Preklaplaj nazaj med okni v skupini |
| `Super + Alt + Scroll Wheel` | Preklaplaj med okni v skupini |
| `Super + Alt + 1/2/3/4/5` | Skoči na določeno okno v skupini |
| `Super + Alt + Arrow` | Premakni okno v skupino v smeri puščice, tudi na monitor na tisti strani |
| `Super + Ctrl + Left/Right` | Premikaj se med okni znotraj skupine tlakovanja |
| `Super + Ctrl + Z` | Približaj zaslon (ponovi za večjo povečavo) |
| `Super + Ctrl + Alt + Z` | Popolnoma oddalji od zaslona |
| `Super + /` | Korak naprej med možnostmi skaliranja monitorja |
| `Super + Alt + /` | Korak nazaj med možnostmi skaliranja monitorja |
| `Alt + Tab` | Preklaplaj naprej med okni na aktivnem delovnem prostoru |
| `Alt + Shift + Tab` | Preklaplaj nazaj med okni na aktivnem delovnem prostoru |
| `Ctrl + Alt + Tab` | Preklaplaj fokus naprej med monitorji |
| `Ctrl + Alt + Shift + Tab` | Preklaplaj fokus nazaj med monitorji |

Bližnjice za spreminjanje velikosti uporabljajo fizični tipki `code:20` in `code:21` (XKB `<AE11>` in `<AE12>`), ne glede na znake, natisnjene na tipkovnici. Na ameriških tipkovnicah sta ti tipki `-` in `=`; na japonskih (JIS) tipkovnicah sta `-` in `^`; na španskih tipkovnicah sta `'` in `¡`. Na JIS je `Super + ^` enako `Super + Equal`, medtem ko je `Super + Shift + -` (ki vtipka `=`) enako `Super + Shift + Minus`.

## Sistemski kontrolniki

| Bližnjica | Funkcija |
| ----------------------- | --------------------- |
| `Super + Ctrl + A` | Zvočno podokno |
| `Super + Ctrl + B` | Podokno Bluetooth |
| `Super + Ctrl + N` | Podokno Wifi/omrežje |
| `Super + Ctrl + D` | Podokno zaslona |
| `Super + Ctrl + P` | Podokno napajanja |
| `Super + Ctrl + X` | Podokno agentov |
| `Super + Ctrl + Alt + D` | Podokno koledarja |
| `Super + Ctrl + Alt + E` | Podokno svetovnega časa |
| `Super + Ctrl + 1-9` | Preklopi podokno vrstice po položaju |
| `Super + Ctrl + S` | Meni za deljenje (prek LocalSend) |
| `Super + Ctrl + C` | Kontrolniki za zajem (posnetek zaslona/snemanje/izbirnik) |
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
| `Keyboard Backlight` | Preklaplaj med ravnmi osvetlitve tipkovnice |
| `Alt + Play` | Naslednja skladba |
| `Alt + Shift + Play` | Prejšnja skladba |

## Zagon aplikacij

| Bližnjica | Funkcija |
| ----------------------- | --------------------- |
| `Super + Return` | Terminal |
| `Super + Alt + Return` | Terminal Tmux |
| `Super + Ctrl + Return` | Herdr (upravitelj agentov) |
| `Super + Shift + Return` | Brskalnik |
| `Super + Shift + Alt + B` | Brskalnik (zasebno/incognito) |
| `Super + Shift + F` | Upravitelj datotek |
| `Super + Shift + Alt + F` | Upravitelj datotek v cwd terminala |
| `Super + Shift + M` | Glasba (Spotify) |
| `Super + Shift + Alt + M` | Glasba (cliamp) |
| `Super + Shift + /` | Upravitelj gesel (1password) |
| `Super + Shift + Q` | Kalkulator (Omacalc) |
| `Super + Shift + T` | Aktivnost (btop) |
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

Vezave spremeni/dodaj v `~/.config/hypr/bindings.lua`.

## Univerzalno odložišče

| Bližnjica | Funkcija |
| ----------------------- | --------------------- |
| `Super + A` | Izberi vse v aplikacijah, ki podpirajo `Ctrl + A` |
| `Super + C` | Kopiraj |
| `Super + X` | Izreži (ne v terminalu) |
| `Super + V` | Prilepi |
| `Super + Ctrl + V` | Upravitelj odložišča |

Običajno v Linuxu potrebuješ `Ctrl + Shift + C/V` za kopiranje in lepljenje v terminalu in `Ctrl + C/V`, da to počneš povsod drugje. Te poenotene bližnjice Omarchy za odložišče delujejo povsod.

## Zajem

| Bližnjica | Funkcija |
| ------------------- | ------------------------------ |
| `Print Screen` | Posnetek zaslona |
| `Super + Ctrl + Alt + C` | Posnetek zaslona (isti posnetek, za tipkovnice brez tipke Print Screen) |
| `Super + Ctrl + C` | Meni za zajem |
| `Alt + Print Screen` | Snemanje zaslona |
| `Super + Print Screen` | Izbirnik barv |
| `Super + Ctrl + Print Screen` | Izvlečenje besedila v odložišče |
| `Super + Alt + [` | Pomanjšaj prekrivanje spletne kamere med snemanjem |
| `Super + Alt + ]` | Povečaj prekrivanje spletne kamere med snemanjem |
| `Alt + Shift + L` | Kopiraj trenutni URL iz spletne aplikacije ali brskalnika |
| `Alt + Shift + D` | Prenesi video na trenutni strani v `~/Videos` |
| `Alt + Space` | Zaženi/ustavi diktiranje (zahteva _Setup > Defaults > Dictation_) |
| `Right Alt` | Drži za diktiranje (zahteva _Setup > Defaults > Dictation_) |

Pri snemanju zaslona bližnjica najprej vpraša, kateri zvok želiš, nato začne snemati. Pritisni jo znova, da ustaviš. Za podrobnosti glej [posnetki zaslona in snemanje](12-screenshots-recording.md).

Vse možnosti zajema so na voljo tudi pod _Trigger > Capture_ v meniju Omarchy (`Super + Space`).

## Obvestila

| Bližnjica | Funkcija |
| ----------------------- | --------------------- |
| `Super + ,` | Ukrepaj ob zadnjem obvestilu: odpri ga ali pritisni njegov edini gumb, izberi med njegovimi možnostmi ali ga zavrzi, če jih nima |
| `Super + Shift + ,` | Zavrzi vsa obvestila |
| `Super + Ctrl + ,` | Upravljaj obvestila s tipkovnico |
| `Super + Alt + ,` | Zavrzi zadnje obvestilo |
| `Super + Shift + Alt + ,` | Odpri zgodovino obvestil |
| `Super + Ctrl + Alt + ,` | Preklopi utišanje obvestil |

## Slog

| Bližnjica | Funkcija |
| ----------------------- | --------------------- |
| `Super + Ctrl + T` | Izberi novo temo (tudi `Super + Ctrl + Shift + Space`) |
| `Super + Ctrl + W` | Izberi ozadje teme (tudi `Super + Ctrl + Space`) |
| `Super + Backspace` | Preklopi prosojnost okna |
| `Super + Ctrl + Backspace` | Preklopi kvadratno razmerje stranic enega okna |

Dodatne slike ozadja so v `~/.config/omarchy/backgrounds/<theme name>`. Na voljo tudi prek _Install > Style > Background_ v meniju Omarchy.

Vse možnosti sloga so na voljo tudi pod _Style_ v meniju Omarchy (`Super + Space`).

## Preklopi

| Bližnjica | Funkcija |
| ----------------------- | --------------------- |
| `Super + Ctrl + I` | Preklopi zaklepanje ob nedejavnosti |
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
| `Super + Ctrl + Alt + R` | Oglej si vse opomnike |
| `Super + Ctrl + Shift + R` | Počisti vse opomnike |

## Obvestila

| Bližnjica | Funkcija |
| ----------------------- | --------------------- |
| `Super + Ctrl + Alt + T` | Prikaži čas kot obvestilo |
| `Super + Ctrl + Alt + B` | Prikaži baterijo kot obvestilo |
| `Super + Ctrl + Alt + W` | Preklopi vreme kot obvestilo |

## Tmux

Predpona je `Ctrl + Space` (deluje tudi `Ctrl + B`). Te vezave lahko spremeniš v `~/.config/tmux/tmux.conf`.

### Podokna

| Bližnjica | Funkcija |
| ----------------------- | --------------------- |
| `Prefix + v` | Razdeli podokno ob strani (navpično) |
| `Prefix + h` | Razdeli podokno spodaj (vodoravno) |
| `Prefix + x` | Zapri podokno |
| `Prefix + z` | Preklopi povečavo podokna (cel zaslon) |
| `Alt + Enter` | Razdeli podokno spodaj (brez predpone) |
| `Alt + Shift + Enter` | Razdeli podokno ob strani (brez predpone) |
| `Alt + Escape` | Zapri podokno (brez predpone) |
| `Ctrl + Alt + Arrows` | Premikaj se med podokni |
| `Ctrl + Alt + Shift + Arrows` | Spremeni velikost podoken |

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
| `Prefix + K` | Končaj sejo |
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
| `Prefix + ?` | Prikaži bližnjice Tmux |
| `Prefix + :` | Ukazni poziv |

### Funkcije postavitev Tmux

Te funkcije moraš zagnati znotraj seje Tmux.

| Ukaz | Funkcija |
| ------- | -------- |
| `tdl <ai> [<second_ai>]` | Ustvari razvojno postavitev z urejevalnikom, AI in terminalom |
| `tdlm <ai> [<second_ai>]` | Ustvari razvojno postavitev na podmapo |
| `tsl <count> <command>` | Ustvari postavitev roja z več podokni |

## Terminal Ghostty

Terminal Ghostty namestiš z _Install > Terminal_ prek menija Omarchy.

| Bližnjica | Funkcija |
| ----------------------- | --------------------- |
| `Ctrl + Shift + E` | Nov deljeni pogled spodaj |
| `Ctrl + Shift + O` | Nov deljeni pogled ob strani |
| `Ctrl + Alt + Arrows` | Premikaj se med deljenimi pogledi |
| `Super + Ctrl + Shift + Arrows` | Spremeni velikost deljenega pogleda za 10 vrstic |
| `Super + Ctrl + Shift + Alt + Arrows` | Spremeni velikost deljenega pogleda za 100 vrstic |
| `Ctrl + Shift + T` | Nov zavihek |
| `Ctrl + Shift + Arrows` | Premikaj se med zavihki |
| `Alt + Numbers` | Pojdi na določen zavihek |
| `Shift + Pg Up/Down` | Drsi po zgodovini |
| `Ctrl + Left mouse` | Odpri povezavo v brskalniku |

## Upravitelj datotek

| Bližnjica | Funkcija |
| ------------------- | ------------------------------ |
| `Ctrl + L` | Pojdi na pot |
| `Space` | Predogled datoteke (puščice za navigacijo) |
| `Alt + Up` | Pojdi gor v nadrejeno mapo |

## Neovim (w/ lazyvim)

### Navigacija

| Bližnjica | Funkcija |
| ------------------------ | ------------------------------- |
| `Space` | Prikaži možnosti ukazov |
| `Space Space` | Odpri datoteko z mehkim iskanjem |
| `Space E` | Preklopi stransko vrstico |
| `Space G G` | Prikaži kontrolnike git |
| `Space S G` | Išči po vsebini datoteke |
| `Ctrl + W W` | Skoči med stransko vrstico in urejevalnikom |
| `Ctrl + Left/right arrow` | Spremeni velikost stranske vrstice |
| `Shift + H` | Pojdi na levi zavihek datoteke |
| `Shift + L` | Pojdi na desni zavihek datoteke |
| `Space B D` | Zapri zavihek datoteke |

### Medtem ko si v stranski vrstici

| Bližnjica | Funkcija |
| ------------------------ | ------------------------------- |
| `A` | Dodaj novo datoteko v nadrejeni mapi |
| `Shift + A` | Dodaj novo podmapo v nadrejeni mapi |
| `D` | Izbriši označeno datoteko/mapo |
| `M` | Premakni označeno datoteko/mapo |
| `R` | Preimenuj označeno datoteko/mapo |
| `?` | Prikaži pomoč za vse ukaze |

[Oglej si vse bližnjice Neovim, ki jih nastavi LazyVim](https://www.lazyvim.org/keymaps).

## Hitri emojiji

Z `Super + Ctrl + E` lahko prikažeš celoten izbirnik emojijev, ki bo izbiro dal v odložišče, ali pa uporabiš te možnosti hitrega dostopa.

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
| `Shift + CapsLock M I` | 😉 | pomežik |
| `Shift + CapsLock M P` | 🙏 | molitev |
| `Shift + CapsLock M D` | 🤤 | slinjenje |
| `Shift + CapsLock M M` | 💰 | denar |
| `Shift + CapsLock M X` | 🎉 | praznovanje |
| `Shift + CapsLock M 1` | 💯 | 100% |
| `Shift + CapsLock M T` | 🥂 | nazdravljanje |
| `Shift + CapsLock M O` |👌 | ok |
| `Shift + CapsLock M G` |👋 | pozdrav |
| `Shift + CapsLock M A` |💪 | roka |
| `Shift + CapsLock M B` |🤯 | razneslo |

## Hitra dokončanja

| Bližnjica | Dokončanje |
| ------------ | ---------- |
| `Shift + CapsLock Space Space` | — (mdash) |
| `Shift + CapsLock Space N` | Tvoje ime (kot je bilo vneseno ob namestitvi) |
| `Shift + CapsLock Space E` | Tvoja e-pošta (kot je bila vnesena ob namestitvi) |

Svoje lahko dodaš z urejanjem `~/.XCompose`, nato v terminalu zaženeš `omarchy-restart-xcompose`, da se spremembe uveljavijo.
