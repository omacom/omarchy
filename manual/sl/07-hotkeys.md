# Bližnjice

Vse glavne povezave tipk lahko vidite s `Super + K` (povezave Tmux s `Super + Alt + K` in povezave Herdr s `Super + Ctrl + K`).

## Kako so bližnjice razporejene

Vsaka bližnjica je na ravni, ki jo določajo njene modifikacijske tipke, vsaka raven pa ima eno nalogo. Zato se bližnjice ne mešajo med seboj in običajno lahko uganete, kje je kaj.

| Raven | Kaj je tam | Primeri |
| --- | --- | --- |
| `Super + key` | Sistem: okna, delovni prostori, postavitve in glavni meniji | `Super + Space` meni Omarchy, `Super + W` zapri okno, `Super + F` celozaslonski način |
| `Super + Shift + key` | Aplikacije | `Super + Shift + B` brskalnik, `Super + Shift + E` e-pošta, `Super + Shift + N` urejevalnik |
| `Super + Ctrl + key` | Plošče in sistemski meniji | `Super + Ctrl + A` zvok, `Super + Ctrl + N` omrežje, `Super + Ctrl + C` meni za zajemanje |
| `Super + Ctrl + Alt + key` | Hitra dejanja in obvestila | `Super + Ctrl + Alt + T` prikaži čas, `Super + Ctrl + Alt + B` baterija, `Super + Ctrl + Alt + C` posnetek zaslona |

Dodajanje tipke `Alt` bližnjici da različico iste stvari, nikoli nečesa nepovezanega:

- `Super + Shift + B` odpre brskalnik; `Super + Shift + Alt + B` odpre zasebno okno
- `Super + Shift + E` odpre e-pošto; `Super + Shift + Alt + E` začne novo
- `Super + F` preide v celozaslonski način; `Super + Alt + F` preide v celotno širino
- `Super + Ctrl + C` odpre meni za zajemanje; `Super + Ctrl + Alt + C` preskoči meni in naredi posnetek zaslona

Ko dodajate bližnjico:

1. Najprej izberite raven glede na to, kaj počne, nato izberite tipko.
2. Ne premikajte obstoječe bližnjice, da bi naredili prostor. Poiščite prosto tipko na pravi ravni.
3. `Alt` uporabite le za različico bližnjice brez njega.

Nekaj bližnjic krši ta pravila, ker so priročne. `Shift` s puščico ali `Tab` premakne ali obrne smer namesto da bi odprl aplikacijo, `Print`, predstavnostne tipke, `Alt + Tab` in `Ctrl + Alt + Del` pa delujejo enako kot povsod drugje. To so izjeme, ne vzorci za posnemanje.

Če vam privzeta nastavitev ne ustreza (recimo, da želite `Super + Shift + S` za posnetke zaslona kot na Windows), jo ponovno povežite v `~/.config/hypr/bindings.lua`.

## Krmarjenje

| Bližnjica | Funkcija |
| ----------------------- | --------------------- |
| `Super + Space` | Meni Omarchy (aplikacije in vse ostalo) |
| `Super + Alt + Space` | Mreža aplikacij |
| `Super + Escape` | Sistemski meni (zaustavitev, ponovni zagon itd.) |
| `Super + Ctrl + L` | Zakleni računalnik |
| `Super + W` ali `Super + Q` | Zapri okno |
| `Ctrl + Alt + Del` | Zapri vsa okna |
| `Super + K` | Prikaži vse bližnjice |
| `Super + Alt + K` | Prikaži bližnjice tmux |
| `Super + Ctrl + K` | Prikaži bližnjice herdr |
| `Super + M` | Pomanjšaj okno v dok |
| `Super + T` | Preklopi okno med ploščičnim in plavajočim načinom |
| `Super + J` | Preklopi položaj okna (vodoravno/navpično) |
| `Super + O` | Preklopi okno v način sticky'n'floating |
| `Super + L` | Preklapljaj med postavitvami dwindle, scrolling in floating |
| `Super + Alt + L` | Preklapljaj med postavitvami v obratnem vrstnem redu |
| `Super + P` | Preklopi slog psevdookna (naravni proti raztegnjenemu) |
| `Super + F` | Celozaslonski način |
| `Super + Alt + F` | Celotna širina |
| `Super + Ctrl + F` | Celozaslonski način znotraj okna |
| `Super + 1…9/0` | Skoči na določen delovni prostor (0 je 10) na monitorju v fokusu |
| `Super + Tab` | Skoči na naslednji delovni prostor na monitorju v fokusu |
| `Super + Shift + Tab` | Skoči na prejšnji delovni prostor na monitorju v fokusu |
| `Super + Ctrl + Tab` | Skoči na prej uporabljeni delovni prostor na monitorju v fokusu |
| `Super + Shift + 1…9/0` | Premakni okno na delovni prostor na monitorju v fokusu |
| `Super + Shift + Alt + 1…9/0` | Premakni okno na delovni prostor na monitorju v fokusu brez sledenja |
| `Super + S` | Preklopi celoten scratchpad |
| `Super + Alt + S` | Premakni okno v celoten scratchpad |
| `Super + Grave` | Preklopi konzolo Quake |
| `Super + Shift + Grave` | Premakni okno v konzolo Quake |
| `Super + Shift + Ctrl + Arrows` | Premakni okno na monitor v tisti smeri |
| `Super + Shift + Alt + Arrows` | Premakni delovni prostor na monitor v tisti smeri |
| `Super + Arrow` | Premakni fokus na okno v smeri puščice, na robu zaslona preide na monitor na tisti strani |
| `Super + Shift + Arrow` | Zamenjaj okno z drugim v smeri puščice, vključno z oknom na monitorju na tisti strani |
| `Super + Minus` | Razširi okno v levo |
| `Super + Equal` | Skrči okno z leve |
| `Super + Shift + Minus` | Skrči okno navzgor |
| `Super + Shift + Equal` | Razširi okno navzdol |
| `Super + Alt + Minus/Equal` | Enako spreminjanje velikosti v manjših korakih |
| `Super + Ctrl + Minus/Equal` | Enako spreminjanje velikosti v večjih korakih |
| `Super + Alt + Home` | Shrani širino okna |
| `Super + Home` | Obnovi shranjeno širino okna |
| `Super + Left Mouse` | Vleci okno naokoli |
| `Super + Right Mouse` | Spremeni velikost okna |
| `Super + Scroll Wheel` | Pomikaj se med delovnimi prostori na monitorju v fokusu |
| `Super + G` | Preklopi združevanje oken v skupine |
| `Super + Alt + G` | Premakni okno iz skupine |
| `Super + Alt + Tab` | Preklapljaj med okni v skupini |
| `Super + Alt + Shift + Tab` | Preklapljaj nazaj med okni v skupini |
| `Super + Alt + Scroll Wheel` | Preklapljaj med okni v skupini |
| `Super + Alt + 1/2/3/4/5` | Skoči na določeno okno v skupini |
| `Super + Alt + Arrow` | Premakni okno v skupino v smeri puščice, vključno z oknom na monitorju na tisti strani |
| `Super + Ctrl + Left/Right` | Premikaj se med okni znotraj ploščične skupine |
| `Super + Ctrl + Z` | Povečaj zaslon (ponovite za večjo povečavo) |
| `Super + Ctrl + Alt + Z` | Popolnoma pomanjšaj zaslon |
| `Super + /` | Korak naprej med možnostmi skaliranja monitorja |
| `Super + Alt + /` | Korak nazaj med možnostmi skaliranja monitorja |
| `Alt + Tab` | Preklapljaj naprej med okni na aktivnem delovnem prostoru |
| `Alt + Shift + Tab` | Preklapljaj nazaj med okni na aktivnem delovnem prostoru |
| `Ctrl + Alt + Tab` | Preklapljaj fokus naprej med monitorji |
| `Ctrl + Alt + Shift + Tab` | Preklapljaj fokus nazaj med monitorji |
| `Super + I` | Preklopi jezik vnosa (pri več kot eni postavitvi ali načinu vnosa) |
| `Super + Shift + I` | Preklopi jezik vnosa nazaj |

Na sledilni ploščici poteze s tremi in štirimi prsti preklapljajo delovne prostore, premikajo okna ter odpirajo meni in konzolo Quake; poteze si oglejte v [tipkovnica, miška in sledilna ploščica](34-keyboard-mouse-trackpad.md).

Bližnjice za spreminjanje velikosti uporabljajo fizični tipki `code:20` in `code:21` (XKB `<AE11>` in `<AE12>`), ne glede na znake, natisnjene na tipkovnici. Na ameriških tipkovnicah sta ti tipki `-` in `=`; na japonskih tipkovnicah (JIS) sta `-` in `^`; na španskih tipkovnicah sta `'` in `¡`. Na JIS je `Super + ^` enako `Super + Equal`, medtem ko je `Super + Shift + -` (ki vnese `=`) enako `Super + Shift + Minus`.

## Nadzor sistema

| Bližnjica | Funkcija |
| ----------------------- | --------------------- |
| `Super + Ctrl + A` | Zvočna plošča |
| `Super + Ctrl + B` | Plošča Bluetooth |
| `Super + Ctrl + N` | Plošča Wi-Fi/omrežja |
| `Super + Ctrl + D` | Plošča za zaslon |
| `Super + Ctrl + P` | Plošča za napajanje |
| `Super + Ctrl + X` | Plošča agentov |
| `Super + Ctrl + Alt + D` | Plošča koledarja |
| `Super + Ctrl + Alt + E` | Plošča svetovne ure |
| `Super + Ctrl + 1-9` | Preklopi ploščo vrstice po položaju |
| `Super + Ctrl + S` | Meni za deljenje (prek LocalSend) |
| `Super + Ctrl + C` | Upravljanje zajemanja (posnetek zaslona/snemanje/izbirnik) |
| `Super + Ctrl + O` | Preklopi meni |
| `Super + Ctrl + H` | Meni strojne opreme |
| `Super + Ctrl + E` | Izbirnik emojijev |
| `Super + Ctrl + .` | Pretvori predstavnost |
| `Super + Shift + Ctrl + A` | Izberite agenta AI |
| `Power` key | Sistemski meni |
| `Super + Shift + Copilot` key | Meni Omarchy |

## Prilagoditve

| Bližnjica | Funkcija |
| ----------------------- | --------------------- |
| `Shift + Brightness Up` | Največja svetlost zaslona |
| `Shift + Brightness Down` | Najmanjša svetlost zaslona |
| `Alt + Brightness Up/Down` | Natančne spremembe svetlosti za 1 % |
| `Alt + Volume Up/Down` | Natančne spremembe glasnosti za 1 % |
| `Keyboard Brightness Up/Down` | Svetlejša/temnejša osvetlitev tipkovnice |
| `Keyboard Backlight` | Preklapljaj med stopnjami osvetlitve tipkovnice |
| `Ctrl + Brightness Up/Down` | Svetlejša/temnejša osvetlitev tipkovnice na tipkovnicah brez lastnih tipk za to |
| `Mic Mute` | Utišaj mikrofon |
| `Shift + Mute` | Preklopi zvočni izhod |
| `Touchpad Toggle` | Vklopi ali izklopi sledilno ploščico |
| `Display` key | Preklapljaj med postavitvami delovnega prostora |
| `Alt + Play` | Naslednja skladba |
| `Alt + Shift + Play` | Prejšnja skladba |

## Zagon aplikacij

| Bližnjica | Funkcija |
| ----------------------- | --------------------- |
| `Super + Return` | Terminal |
| `Super + Alt + Return` | Terminal Tmux |
| `Super + Ctrl + Return` | Herdr (upravitelj agentov) |
| `Super + Shift + Return` ali `Super + Shift + B` | Brskalnik |
| `Super + Shift + Alt + B` | Brskalnik (zasebno/inkognito) |
| `Super + Shift + F` | Upravitelj datotek |
| `Super + Shift + Alt + F` | Upravitelj datotek v cwd terminala |
| `Super + Shift + M` | Glasba (Spotify) |
| `Super + Shift + Alt + M` | Glasba (cliamp) |
| `Super + Shift + /` | Upravitelj gesel (1password) |
| `Super + Shift + Q` ali `Calculator` key | Kalkulator (Omacalc) |
| `Super + Shift + D` | Docker (lazydocker, ko je nameščen) |
| `Super + Shift + T` | Dejavnost (btop) |
| `Super + Shift + N` | Urejevalnik (Plain ali vaš izbrani privzeti) |
| `Super + Shift + C` | Koledar ([HEY](https://hey.com/)) |
| `Super + Shift + E` | E-pošta ([HEY](https://hey.com/)) |
| `Super + Shift + Alt + E` | Nova e-pošta ([HEY](https://hey.com/)) |
| `Super + Shift + A` | AI (ChatGPT) |
| `Super + Shift + Alt + A` | AI (Grok) |
| `Super + Shift + G` | Sporočanje (Signal) |
| `Super + Shift + P` | Google Photos |
| `Super + Shift + S` | Google Maps |
| `Super + Shift + Alt + G` | Sporočanje (WhatsApp) |
| `Super + Shift + Ctrl + G` | Sporočanje (Google) |
| `Super + Shift + O` | Obsidian |
| `Super + Shift + W` | Pisanje (Omawrite) |
| `Super + Shift + X` | X |
| `Super + Shift + Alt + X` | X (nova objava) |
| `Super + Shift + Y` | YouTube |

Spremenite/dodajte povezave v `~/.config/hypr/bindings.lua`.

## Univerzalno odložišče

| Bližnjica | Funkcija |
| ----------------------- | --------------------- |
| `Super + A` | Izberite vse v aplikacijah, ki podpirajo `Ctrl + A` |
| `Super + C` | Kopiraj |
| `Super + X` | Izreži (ne v terminalu) |
| `Super + V` | Prilepi |
| `Super + Ctrl + V` | Upravitelj odložišča |

Običajno v Linuxu potrebujete `Ctrl + Shift + C/V` za kopiranje in lepljenje v terminalu in `Ctrl + C/V` za to povsod drugje. Te poenotene bližnjice odložišča v Omarchy delujejo povsod.

## Zajemanje

| Bližnjica | Funkcija |
| ------------------- | ------------------------------ |
| `Print Screen` | Posnetek zaslona |
| `Super + Ctrl + Alt + C` | Posnetek zaslona (isti posnetek, za tipkovnice brez tipke Print Screen) |
| `Super + Ctrl + C` | Meni za zajemanje |
| `Alt + Print Screen` | Snemanje zaslona |
| `Super + Shift + Ctrl + Alt + C` | Snemanje zaslona brez zvoka, brez menija (pritisnite znova za ustavitev) |
| `Super + Print Screen` | Izbirnik barv |
| `Super + Ctrl + Print Screen` | Izluščenje besedila v odložišče |
| `Super + Alt + [` | Pomanjšajte prekrivanje spletne kamere med snemanjem |
| `Super + Alt + ]` | Povečajte prekrivanje spletne kamere med snemanjem |
| `Alt + Shift + L` | Kopirajte trenutni URL iz spletne aplikacije ali brskalnika |
| `Alt + Shift + D` | Prenesite videoposnetek na trenutni strani v `~/Videos` |
| `Alt + Space` | Začnite/ustavite narekovanje (zahteva _Nastavitve > Privzeto > Narekovanje_) |
| `Right Alt` | Držite za narekovanje (zahteva _Nastavitve > Privzeto > Narekovanje_) |

Pri snemanju zaslona bližnjica najprej vpraša, kateri zvok želite, nato začne snemati. Pritisnite jo znova, da ustavite. Podrobnosti najdete v [posnetki zaslona in snemanje](12-screenshots-recording.md).

Vse možnosti zajemanja so dostopne tudi pod _Sprožilec > Zajemanje_ v meniju Omarchy (`Super + Space`).

## Obvestila

| Bližnjica | Funkcija |
| ----------------------- | --------------------- |
| `Super + ,` | Ukrepajte ob zadnjem obvestilu: odprite ga ali pritisnite njegov edini gumb, izberite med njegovimi možnostmi ali ga zavrnite, kadar nima nobene |
| `Super + Shift + ,` | Zavrnite vsa obvestila |
| `Super + Ctrl + ,` | Upravljajte obvestila s tipkovnico |
| `Super + Alt + ,` | Zavrnite zadnje obvestilo |
| `Super + Shift + Alt + ,` | Odprite zgodovino obvestil |
| `Super + Ctrl + Alt + ,` | Preklopite utišanje obvestil |

## Slog

| Bližnjica | Funkcija |
| ----------------------- | --------------------- |
| `Super + Ctrl + T` | Izberite novo temo (tudi `Super + Ctrl + Shift + Space`) |
| `Super + Ctrl + W` | Izberite ozadje teme (tudi `Super + Ctrl + Space`) |
| `Super + Backspace` | Preklopite prosojnost okna |
| `Super + Ctrl + Backspace` | Preklopite kvadratno razmerje za eno okno |

Dodatne slike ozadja so v `~/.config/omarchy/backgrounds/<theme name>`. Na voljo tudi prek _Namesti > Slog > Ozadje_ v meniju Omarchy.

Vse možnosti sloga so dostopne tudi pod _Videz_ v meniju Omarchy (`Super + Space`).

## Preklopi

| Bližnjica | Funkcija |
| ----------------------- | --------------------- |
| `Super + Ctrl + I` | Preklopi zaklepanje ob nedejavnosti |
| `Super + Ctrl + Delete` | Preklopi zaslon prenosnika vklop/izklop |
| `Super + Ctrl + Alt + Delete` | Preklopi zrcaljenje zaslona prenosnika |
| `Super + Shift + Space` | Preklopi zgornjo vrstico |
| `Shift + Mute` | Preklopi na naslednji zvočni izhod |
| `Shift + Play` | Preklopi na naslednji vir predstavnosti |
| `Super + Shift + Backspace` | Preklopi razmike med okni |
| `Super + Ctrl + Alt + F` | Preklopi celozaslonsko namizje (zgornja vrstica + razmiki med okni) |

## Opomniki

| Bližnjica | Funkcija |
| ----------------------- | --------------------- |
| `Super + Ctrl + R` | Nastavite opomnik |
| `Super + Ctrl + Alt + R` | Oglejte si vse opomnike |
| `Super + Ctrl + Shift + R` | Počistite vse opomnike |

## Prikaz stanja

| Bližnjica | Funkcija |
| ----------------------- | --------------------- |
| `Super + Ctrl + Alt + T` | Prikaži čas kot obvestilo |
| `Super + Ctrl + Alt + B` | Prikaži baterijo kot obvestilo |
| `Super + Ctrl + Alt + W` | Preklopi vreme kot obvestilo |

## Tmux

Tipka predpone je `Ctrl + Space` (deluje tudi `Ctrl + B`). Te povezave lahko spremenite v `~/.config/tmux/tmux.conf`.

### Podokna

| Bližnjica | Funkcija |
| ----------------------- | --------------------- |
| `Prefix + v` | Razdeli podokno ob strani (navpično) |
| `Prefix + h` | Razdeli podokno spodaj (vodoravno) |
| `Prefix + x` | Uniči podokno |
| `Prefix + z` | Preklopi povečavo podokna (celozaslonsko) |
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
| `Prefix + s` | Prikaži seznam sej |
| `Prefix + d` | Odklopi se od seje |

### Način kopiranja (v slogu vi)

| Bližnjica | Funkcija |
| ----------------------- | --------------------- |
| `Prefix + [` | Vstopi v način kopiranja |
| `v` | Začni izbiranje (v načinu kopiranja) |
| `y` | Kopiraj izbiro (v načinu kopiranja) |

### Splošno

| Bližnjica | Funkcija |
| ----------------------- | --------------------- |
| `Prefix + q` | Ponovno naloži konfiguracijo |
| `Prefix + ?` | Prikaži povezave tipk Tmux |
| `Prefix + :` | Ukazni poziv |

### Funkcije postavitve Tmux

Te funkcije je treba zagnati znotraj seje Tmux.

| Ukaz | Funkcija |
| ------- | -------- |
| `tdl <ai> [<second_ai>]` | Ustvari razvojno postavitev z urejevalnikom, AI in terminalom |
| `tdlm <ai> [<second_ai>]` | Ustvari razvojno postavitev za vsak podimenik |
| `tsl <count> <command>` | Ustvari postavitev roja z več podokni |

## Terminal Ghostty

Terminal Ghostty namestite z _Namesti > Terminal_ v meniju Omarchy.

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
| `Space` | Predogled datoteke (krmarjenje s puščicami) |
| `Alt + Up` | Pojdi gor v nadrejeno mapo |

## Neovim (z lazyvim)

### Krmarjenje

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

### V stranski vrstici

| Bližnjica | Funkcija |
| ------------------------ | ------------------------------- |
| `A` | Dodaj novo datoteko v nadrejeni imenik |
| `Shift + A` | Dodaj nov podimenik v nadrejeni imenik |
| `D` | Izbriši označeno datoteko/imenik |
| `M` | Premakni označeno datoteko/imenik |
| `R` | Preimenuj označeno datoteko/imenik |
| `?` | Prikaži pomoč za vse ukaze |

[Oglejte si vse bližnjice Neovim, ki jih nastavi LazyVim](https://www.lazyvim.org/keymaps).

## Hitri emojiji

Z `Super + Ctrl + E` lahko prikažete celoten izbirnik emojijev, ki izbiro odloži v odložišče, ali pa uporabite te možnosti za hiter dostop.

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
| `Shift + CapsLock M X` | 🎉 | xellebrate |
| `Shift + CapsLock M 1` | 💯 | 100% |
| `Shift + CapsLock M T` | 🥂 | zdravica |
| `Shift + CapsLock M O` |👌 | ok |
| `Shift + CapsLock M G` |👋 | pozdrav |
| `Shift + CapsLock M A` |💪 | roka |
| `Shift + CapsLock M B` |🤯 | raznesena glava |

## Hitre dopolnitve

| Bližnjica | Dopolnitev |
| ------------ | ---------- |
| `Shift + CapsLock Space Space` | — (dolgi pomišljaj) |
| `Shift + CapsLock Space N` | Vaše ime (kot ste ga vnesli ob nastavitvi) |
| `Shift + CapsLock Space E` | Vaš e-poštni naslov (kot ste ga vnesli ob nastavitvi) |

Več svojih lahko dodate tako, da uredite `~/.XCompose` in nato v terminalu zaženete `omarchy restart xcompose`, da spremembe začnejo veljati.
