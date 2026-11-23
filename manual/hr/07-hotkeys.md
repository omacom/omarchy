# Tipkovničke prečice

Sve glavne tipkovničke prečice možete vidjeti sa `Super + K` (Tmux prečice sa `Super + Alt + K`, a Herdr prečice sa `Super + Ctrl + K`).

## Kako su tipkovničke prečice raspoređene

Svaka tipkovnička prečica nalazi se na jednoj ravni, određenoj svojim modifikatorima, i svaka ravan ima jedan zadatak. To sprječava da se prečice međusobno pomiješaju i znači da obično možete pogoditi gdje se nešto nalazi.

| Ravan | Što se tamo nalazi | Primjeri |
| --- | --- | --- |
| `Super + key` | Sustav: prozori, radni prostori, rasporedi i osnovni izbornici | `Super + Space` Omarchy izbornik, `Super + W` zatvaranje prozora, `Super + F` preko cijelog zaslona |
| `Super + Shift + key` | Aplikacije | `Super + Shift + B` preglednik, `Super + Shift + E` e-pošta, `Super + Shift + N` uređivač |
| `Super + Ctrl + key` | Ploče i izbornici sustava | `Super + Ctrl + A` zvuk, `Super + Ctrl + N` mreža, `Super + Ctrl + C` izbornik snimanja |
| `Super + Ctrl + Alt + key` | Brze radnje i obavijesti | `Super + Ctrl + Alt + T` prikaz vremena, `Super + Ctrl + Alt + B` baterija, `Super + Ctrl + Alt + C` snimka zaslona |

Dodavanje `Alt` tipkovničkoj prečici daje vam varijantu iste stvari, nikad nešto nepovezano:

- `Super + Shift + B` otvara preglednik; `Super + Shift + Alt + B` otvara privatni prozor
- `Super + Shift + E` otvara e-poštu; `Super + Shift + Alt + E` započinje novu
- `Super + F` ide preko cijelog zaslona; `Super + Alt + F` ide preko cijele širine
- `Super + Ctrl + C` otvara izbornik snimanja; `Super + Ctrl + Alt + C` preskače izbornik i snima snimku zaslona

Pri dodavanju tipkovničke prečice:

1. Odaberite ravan prema tome što radi, zatim odaberite tipku.
2. Nemojte premještati postojeću prečicu da biste napravili mjesta. Pronađite slobodnu tipku na pravoj ravni.
3. `Alt` koristite samo za varijantu prečice bez njega.

Nekoliko prečica krši ova pravila jer su praktične. `Shift` sa strelicom ili `Tab` premješta ili obrće umjesto da otvara aplikaciju, a `Print`, medijske tipke, `Alt + Tab` i `Ctrl + Alt + Del` rade onako kako rade posvuda drugdje. To su iznimke, a ne obrasci za kopiranje.

Ako vam zadana postavka ne odgovara (recimo da želite `Super + Shift + S` za snimke zaslona kao na Windowsu), ponovno je dodijelite u `~/.config/hypr/bindings.lua`.

## Navigacija

| Tipkovnička prečica                  | Funkcija              |
| ----------------------- | --------------------- |
| `Super + Space`           | Omarchy izbornik (aplikacije i sve ostalo)    |
| `Super + Alt + Space` | Mreža aplikacija |
| `Super + Escape` | Izbornik sustava (obustava, ponovno pokretanje itd.)  |
| `Super + Ctrl + L` | Zaključavanje računala |
| `Super + W` ili `Super + Q` | Zatvaranje prozora             |
| `Ctrl + Alt + Del` | Zatvaranje svih prozora |
| `Super + K` | Prikaz svih tipkovničkih prečica |
| `Super + Alt + K` | Prikaz tmux tipkovničkih prečica |
| `Super + Ctrl + K` | Prikaz herdr tipkovničkih prečica |
| `Super + M` | Minimiziranje prozora na dock |
| `Super + T`               | Prebacivanje prozora između popločanog/plutajućeg             |
| `Super + J` | Prebacivanje položaja prozora (vodoravno/okomito) |
| `Super + O`               | Prebacivanje prozora koji iskače u sticky'n'floating |
| `Super + L`               | Kruženje kroz rasporede dwindle, scrolling i floating |
| `Super + Alt + L`         | Kruženje kroz rasporede obrnutim redoslijedom |
| `Super + P`               | Prebacivanje stila pseudo prozora (prirodno naspram rastegnuto) |
| `Super + F`                 | Preko cijelog zaslona              |
| `Super + Alt + F`                 | Preko cijele širine              |
| `Super + Ctrl + F`                 | Preko cijelog zaslona unutar prozora              |
| `Super + 1…9/0`         | Skok na određeni radni prostor (0 je 10) na monitoru u fokusu |
| `Super + Tab` | Skok na sljedeći radni prostor na monitoru u fokusu |
| `Super + Shift + Tab` | Skok na prethodni radni prostor na monitoru u fokusu |
| `Super + Ctrl + Tab` | Skok na prijašnji radni prostor na monitoru u fokusu |
| `Super + Shift + 1…9/0` | Premještanje prozora na radni prostor na monitoru u fokusu |
| `Super + Shift + Alt + 1…9/0` | Premještanje prozora na radni prostor na monitoru u fokusu bez praćenja |
| `Super + S` | Prebacivanje punog scratchpada |
| `Super + Alt + S` | Premještanje prozora na puni scratchpad |
| `Super + the key above Tab` (grave na američkim rasporedima) | Prebacivanje Quake konzole |
| `Super + Shift + the key above Tab` (grave na američkim rasporedima) | Premještanje prozora na Quake konzolu |
| `Super + Shift + Ctrl + Arrows` | Premještanje prozora na monitor u tom smjeru |
| `Super + Shift + Alt + Arrows` | Premještanje radnog prostora na monitor u tom smjeru |
| `Super + Arrow`  | Pomicanje fokusa na prozor u smjeru strelice, uz prelazak na monitor s te strane na rubu zaslona |
| `Super + Shift + Arrow`  | Zamjena prozora s drugim u smjeru strelice, uključujući onaj na monitoru s te strane |
| `Super + Minus` | Proširivanje prozora ulijevo |
| `Super + Equal` | Smanjivanje prozora ulijevo |
| `Super + Shift + Minus` | Smanjivanje prozora prema gore |
| `Super + Shift + Equal` | Proširivanje prozora prema dolje |
| `Super + Alt + Minus/Equal` | Isto mijenjanje veličine u manjim koracima |
| `Super + Ctrl + Minus/Equal` | Isto mijenjanje veličine u većim koracima |
| `Super + Alt + Home` | Spremanje širine prozora |
| `Super + Home` | Vraćanje spremljene širine prozora |
| `Super + Left Mouse` | Povlačenje prozora uokolo |
| `Super + Right Mouse` | Mijenjanje veličine prozora |
| `Super + Scroll Wheel` | Listanje kroz radne prostore na monitoru u fokusu |
| `Super + G`               | Prebacivanje grupiranja prozora      |
| `Super + Alt + G`               | Premještanje prozora izvan grupiranja      |
| `Super + Alt + Tab`               | Kruženje između prozora u grupi      |
| `Super + Alt + Shift + Tab`               | Kruženje unatrag između prozora u grupi      |
| `Super + Alt + Scroll Wheel` | Kruženje između prozora u grupi |
| `Super + Alt + 1/2/3/4/5`               | Skok na određeni prozor u grupi      |
| `Super + Alt + Arrow`  | Premještanje prozora u grupu u smjeru strelice, uključujući onaj na monitoru s te strane |
| `Super + Ctrl + Left/Right`  | Kretanje između prozora unutar popločane grupe |
| `Super + Ctrl + Z` | Zumiranje zaslona (ponovite za veće zumiranje) |
| `Super + Ctrl + Alt + Z` | Potpuno odzumiranje zaslona |
| `Super + /` | Korak naprijed kroz opcije skaliranja monitora |
| `Super + Alt + /` | Korak natrag kroz opcije skaliranja monitora |
| `Alt + Tab` | Kruženje naprijed kroz prozore na aktivnom radnom prostoru |
| `Alt + Shift + Tab` | Kruženje natrag kroz prozore na aktivnom radnom prostoru |
| `Ctrl + Alt + Tab`| Kruženje fokusa naprijed kroz monitore |
| `Ctrl + Alt + Shift + Tab`| Kruženje fokusa unatrag kroz monitore |
| `Super + I` | Promjena jezika unosa (s više od jednog rasporeda ili načina unosa) |
| `Super + Shift + I` | Vraćanje jezika unosa |

Na dodirnoj pločici povlačenja s tri i četiri prsta mijenjaju radne prostore, premještaju prozore te otvaraju izbornik i Quake konzolu; geste pogledajte u [tipkovnica, miš i dodirna pločica](34-keyboard-mouse-trackpad.md).

Mijenjanje veličine koristi dvije tipke desno od 0, što god vaša tipkovnica na njima ispisuje: `-` i `=` na američkim tipkovnicama, `+` i `´` na danskim i švedskim, `+` i `\` na norveškim, `ß` i `´` na njemačkim, `'` i `¡` na španjolskim te `-` i `^` na japanskim (JIS). `Super + K` ih navodi onako kako ih vaša tipkovnica ispisuje. Na JIS-u je `Super + ^` jednako `Super + Equal`, dok je `Super + Shift + -` (koje upisuje `=`) jednako `Super + Shift + Minus`. Skaliranje monitora i upravitelj lozinki koriste `/`; na rasporedima koji `/` upisuju samo sa Shift, kao što to čini većina europskih, umjesto toga koriste tipku lijevo od desnog Shifta (`-` na danskim i njemačkim).

## Kontrole sustava

| Tipkovnička prečica                  | Funkcija              |
| ----------------------- | --------------------- |
| `Super + Ctrl + A`           | Zvučna ploča    |
| `Super + Ctrl + B`           | Bluetooth ploča    |
| `Super + Ctrl + N`           | Wi-Fi/mrežna ploča    |
| `Super + Ctrl + D`           | Ploča zaslona    |
| `Super + Ctrl + P`           | Ploča napajanja    |
| `Super + Ctrl + X`           | Ploča agenata    |
| `Super + Ctrl + Alt + X`           | Ploča lokalnih modela    |
| `Super + Ctrl + Alt + D`           | Ploča kalendara    |
| `Super + Ctrl + Alt + E`           | Ploča svjetskog sata    |
| `Super + Ctrl + 1-9`           | Prebacivanje ploče trake prema položaju    |
| `Super + Ctrl + S` | Izbornik dijeljenja (putem LocalSenda) |
| `Super + Ctrl + C` | Kontrole snimanja (snimka zaslona/-snimanje/birač) |
| `Super + Ctrl + O` | Prebacivanje izbornika |
| `Super + Ctrl + H` | Izbornik hardvera |
| `Super + Ctrl + E` | Birač emojija |
| `Super + Ctrl + .` | Transkodiranje medija |
| `Super + Shift + Ctrl + A` | Pokretanje vašeg zadanog agenta |
| `Power` tipka | Izbornik sustava |
| `Super + Shift + Copilot` tipka | Omarchy izbornik |

## Prilagodbe

| Tipkovnička prečica                  | Funkcija              |
| ----------------------- | --------------------- |
| `Shift + Brightness Up` | Maksimalna svjetlina zaslona |
| `Shift + Brightness Down` | Minimalna svjetlina zaslona |
| `Alt + Brightness Up/Down` | Precizne promjene svjetline od 1% |
| `Alt + Volume Up/Down` | Precizne promjene glasnoće od 1% |
| `Keyboard Brightness Up/Down` | Pozadinsko osvjetljenje tipkovnice svjetlije/tamnije |
| `Keyboard Backlight` | Kruženje kroz razine pozadinskog osvjetljenja tipkovnice |
| `Ctrl + Brightness Up/Down` | Pozadinsko osvjetljenje tipkovnice svjetlije/tamnije, na tipkovnicama bez vlastitih tipki |
| `Mic Mute` | Isključivanje zvuka mikrofona |
| `Shift + Mute` | Promjena audioizlaza |
| `Touchpad Toggle` | Uključivanje ili isključivanje dodirne pločice |
| `Display` tipka | Kruženje kroz raspored radnog prostora |
| `Alt + Play` | Sljedeća skladba |
| `Alt + Shift + Play` | Prethodna skladba |

## Pokretanje aplikacija

| Tipkovnička prečica                  | Funkcija              |
| ----------------------- | --------------------- |
| `Super + Return`           | Terminal    |
| `Super + Alt + Return` | Tmux terminal |
| `Super + Ctrl + Return` | Herdr (upravitelj agenata) |
| `Super + Shift + Return` ili `Super + Shift + B`  | Preglednik    |
| `Super + Shift + Alt + B`           | Preglednik (privatno/inkognito)    |
| `Super + Shift + F`           | Upravitelj datoteka    |
| `Super + Shift + Alt + F`           | Upravitelj datoteka u cwd-u terminala    |
| `Super + Shift + M`           | Glazba (Spotify)    |
| `Super + Shift + Alt + M`           | Glazba (cliamp)    |
| `Super + Shift + /`           | Upravitelj lozinki (1password)    |
| `Super + Shift + Q` ili `Calculator` tipka  | Kalkulator (Omacalc)    |
| `Super + Shift + D`           | Docker (lazydocker, nakon instalacije)    |
| `Super + Shift + T`           | Aktivnost (btop)    |
| `Super + Shift + N`           | Uređivač (Plain ili vaš odabrani zadani)  |
| `Super + Shift + C`           | Kalendar ([HEY](https://hey.com/))  |
| `Super + Shift + E`           | E-pošta ([HEY](https://hey.com/))  |
| `Super + Shift + Alt + E`           | Nova e-pošta ([HEY](https://hey.com/))  |
| `Super + Shift + A`           | Vaš zadani agent ili ChatGPT dok ne odaberete jednoga |
| `Super + Shift + Alt + A`           | AI (Grok)  |
| `Super + Shift + G`           | Messenger (Signal)  |
| `Super + Shift + P`           | Google Photos  |
| `Super + Shift + S`           | Google Maps  |
| `Super + Shift + Alt + G`           | Messenger (WhatsApp)  |
| `Super + Shift + Ctrl + G`           | Messenger (Google)  |
| `Super + Shift + O`           | Obsidian  |
| `Super + Shift + W`           | Pisanje (Omawrite)  |
| `Super + Shift + X`           | X |
| `Super + Shift + Alt + X`           | X (nova objava) |
| `Super + Shift + Y`           | YouTube |

Promijenite/dodajte prečice u `~/.config/hypr/bindings.lua`.

## Univerzalni međuspremnik

| Tipkovnička prečica                  | Funkcija              |
| ----------------------- | --------------------- |
| `Super + A`           | Odabir svega u aplikacijama koje podržavaju `Ctrl + A`    |
| `Super + C`           | Kopiranje    |
| `Super + X`           | Izrezivanje (ne u terminalu)    |
| `Super + V`           | Lijepljenje    |
| `Super + Ctrl + V`           | Upravitelj međuspremnika    |

Obično na Linuxu trebate `Ctrl + Shift + C/V` za kopiranje i lijepljenje u terminalu i `Ctrl + C/V` da to učinite posvuda drugdje. Ove ujedinjene tipkovničke prečice međuspremnika u Omarchyju rade posvuda.

## Snimanje

| Tipkovnička prečica              | Funkcija                       |
| ------------------- | ------------------------------ |
| `Print Screen`            | Snimka zaslona                      |
| `Super + Ctrl + Alt + C`            | Snimka zaslona (ista snimka, za tipkovnice bez tipke Print Screen) |
| `Super + Ctrl + C` | Izbornik snimanja |
| `Alt + Print Screen`            | Snimanje zaslona                     |
| `Super + Shift + Ctrl + Alt + C` | Snimanje zaslona bez zvuka, uz preskakanje izbornika (pritisnite ponovno za zaustavljanje) |
| `Super + Print Screen` | Birač boja |
| `Super + Ctrl + Print Screen` | Izdvajanje teksta u međuspremnik |
| `Super + Alt + [` | Smanjivanje preklapanja web-kamere tijekom snimanja |
| `Super + Alt + ]` | Povećavanje preklapanja web-kamere tijekom snimanja |
| `Alt + Shift + L` | Kopiranje trenutnog URL-a iz web-aplikacije ili preglednika |
| `Alt + Shift + D` | Preuzimanje videa na trenutnoj stranici u `~/Videos` |
| `Alt + Space` | Pokretanje/zaustavljanje diktiranja (zahtijeva _Setup > Defaults > Dictation_) |
| `Right Alt` | Držanje za diktiranje (zahtijeva _Setup > Defaults > Dictation_) |

Kod snimanja zaslona tipkovnička prečica prvo pita koji zvuk želite, zatim započinje snimanje. Pritisnite je ponovno za zaustavljanje. Pojedinosti pogledajte u [snimke zaslona i snimanje](12-screenshots-recording.md).

Sve opcije snimanja dostupne su i pod _Trigger > Capture_ u Omarchy izborniku (`Super + Space`).

## Obavijesti

| Tipkovnička prečica                  | Funkcija              |
| ----------------------- | --------------------- |
| `Super + ,` | Djelovanje na najnoviju obavijest: otvorite je ili pritisnite njezin jedini gumb, odaberite među njezinim izborima ili je odbacite kad ih nema  |
| `Super + Shift + ,` | Odbacivanje svih obavijesti |
| `Super + Ctrl + ,` | Upravljanje obavijestima tipkovnicom  |
| `Super + Alt + ,` | Odbacivanje najnovije obavijesti  |
| `Super + Shift + Alt + ,` | Otvaranje povijesti obavijesti  |
| `Super + Ctrl + Alt + ,` | Uključivanje/isključivanje utišavanja obavijesti  |

## Stil

| Tipkovnička prečica                  | Funkcija              |
| ----------------------- | --------------------- |
| `Super + Ctrl + T` | Odabir nove teme (također `Super + Ctrl + Shift + Space`) |
| `Super + Ctrl + W` | Odabir pozadine teme (također `Super + Ctrl + Space`) |
| `Super + Backspace` | Prebacivanje prozirnosti prozora |
| `Super + Ctrl + Backspace` | Prebacivanje kvadratnog omjera pojedinačnog prozora |

Dodatne pozadinske slike nalaze se u `~/.config/omarchy/backgrounds/<theme name>`. Dostupno i putem _Install > Style > Background_ u Omarchy izborniku.

Sve opcije stila dostupne su i pod _Appearance_ u Omarchy izborniku (`Super + Space`).

## Uključivanje i isključivanje

| Tipkovnička prečica                  | Funkcija              |
| ----------------------- | --------------------- |
| `Super + Ctrl + I` | Prebacivanje zaključavanja pri mirovanju |
| `Super + Ctrl + Delete` | Uključivanje/isključivanje zaslona prijenosnog računala |
| `Super + Ctrl + Alt + Delete` | Prebacivanje zrcaljenja zaslona prijenosnog računala |
| `Super + Shift + Space` | Prebacivanje gornje trake  |
| `Shift + Mute` | Prebacivanje na sljedeći audioizlaz |
| `Shift + Play` | Prebacivanje na sljedeći medijski izvor |
| `Super + Shift + Backspace` | Prebacivanje razmaka među prozorima |
| `Super + Ctrl + Alt + F` | Prebacivanje radne površine preko cijelog zaslona (gornja traka + razmaci među prozorima) |

## Podsjetnici

| Tipkovnička prečica                  | Funkcija              |
| ----------------------- | --------------------- |
| `Super + Ctrl + R` | Postavljanje podsjetnika  |
| `Super + Ctrl + Alt + R` | Pregled svih podsjetnika  |
| `Super + Ctrl + Shift + R` | Brisanje svih podsjetnika  |

## Kratke obavijesti

| Tipkovnička prečica                  | Funkcija              |
| ----------------------- | --------------------- |
| `Super + Ctrl + Alt + T` | Prikaz vremena kao obavijesti  |
| `Super + Ctrl + Alt + B` | Prikaz baterije kao obavijesti  |
| `Super + Ctrl + Alt + W` | Prebacivanje vremenske prognoze kao obavijesti  |

## Tmux

Prefiksna tipka je `Ctrl + Space` (`Ctrl + B` također radi). Ove prečice možete promijeniti u `~/.config/tmux/tmux.conf`.

### Okna

| Tipkovnička prečica                  | Funkcija              |
| ----------------------- | --------------------- |
| `Prefix + v` | Dijeljenje okna sa strane (okomito) |
| `Prefix + h` | Dijeljenje okna ispod (vodoravno) |
| `Prefix + x` | Zatvaranje okna |
| `Prefix + z` | Prebacivanje zumiranja okna (preko cijelog zaslona) |
| `Alt + Enter` | Dijeljenje okna ispod (bez prefiksa) |
| `Alt + Shift + Enter` | Dijeljenje okna sa strane (bez prefiksa) |
| `Alt + Escape` | Zatvaranje okna (bez prefiksa) |
| `Ctrl + Alt + Arrows` | Kretanje između okna |
| `Ctrl + Alt + Shift + Arrows` | Mijenjanje veličine okna |

### Prozori

| Tipkovnička prečica                  | Funkcija              |
| ----------------------- | --------------------- |
| `Prefix + c` | Novi prozor |
| `Prefix + k` | Zatvaranje prozora |
| `Prefix + r` | Preimenovanje prozora |
| `Alt + 1-9` | Odlazak na određeni prozor |
| `Alt + Arrow Left/Right` | Kretanje između prozora |
| `Alt + Shift + Arrow Left/Right` | Premještanje prozora ulijevo/udesno |

### Sesije

| Tipkovnička prečica                  | Funkcija              |
| ----------------------- | --------------------- |
| `Prefix + C` | Nova sesija |
| `Prefix + K` | Zatvaranje sesije |
| `Prefix + R` | Preimenovanje sesije |
| `Prefix + N` | Sljedeća sesija |
| `Prefix + P` | Prethodna sesija |
| `Alt + Arrow Up/Down` | Kretanje između sesija |
| `Prefix + s` | Popis sesija |
| `Prefix + d` | Odvajanje od sesije |

### Način kopiranja (vi-stil)

| Tipkovnička prečica                  | Funkcija              |
| ----------------------- | --------------------- |
| `Prefix + [` | Ulazak u način kopiranja |
| `v` | Početak odabira (u načinu kopiranja) |
| `y` | Kopiranje odabira (u načinu kopiranja) |

### Općenito

| Tipkovnička prečica                  | Funkcija              |
| ----------------------- | --------------------- |
| `Prefix + q` | Ponovno učitavanje konfiguracije |
| `Prefix + ?` | Prikaz Tmux tipkovničkih prečica |
| `Prefix + :` | Naredbeni redak |

### Funkcije Tmux rasporeda

Ove se funkcije moraju pokrenuti unutar Tmux sesije.

| Naredba | Funkcija |
| ------- | -------- |
| `tdl <ai> [<second_ai>]` | Izrada razvojnog rasporeda s uređivačem, AI-jem i terminalom |
| `tdlm <ai> [<second_ai>]` | Izrada razvojnog rasporeda po poddirektoriju |
| `tsl <count> <command>` | Izrada rasporeda roja s više okna |

## Ghostty Terminal

Ghostty terminal instalira se pomoću _Install > Terminal_ putem Omarchy izbornika.

| Tipkovnička prečica                  | Funkcija              |
| ----------------------- | --------------------- |
| `Ctrl + Shift + E` | Novo dijeljenje ispod |
| `Ctrl + Shift + O` | Novo dijeljenje sa strane |
| `Ctrl + Alt + Arrows` | Kretanje između podjela |
| `Super + Ctrl + Shift + Arrows` | Mijenjanje veličine podjele za 10 redaka |
| `Super + Ctrl + Shift + Alt + Arrows` | Mijenjanje veličine podjele za 100 redaka |
| `Ctrl + Shift + T` | Nova kartica  |
| `Ctrl + Shift + Arrows` | Kretanje između kartica |
| `Alt + Numbers` | Odlazak na određenu karticu |
| `Shift + Pg Up/Down` | Listanje povijesti |
| `Ctrl + Left mouse` | Otvaranje poveznice u pregledniku |

## Upravitelj datoteka

| Tipkovnička prečica              | Funkcija                       |
| ------------------- | ------------------------------ |
| `Ctrl + L`            | Odlazak na putanju                     |
| `Space`               | Pregled datoteke (strelice navigiraju) |
| `Alt + Up`       | Odlazak gore u nadređenu mapu        |

## Neovim (w/ lazyvim)

### Navigacija

| Tipkovnička prečica                   | Funkcija                        |
| ------------------------ | ------------------------------- |
| `Space`                    | Prikaz opcija naredbi            |
| `Space Space`              | Otvaranje datoteke putem fuzzy pretraživanja      |
| `Space E`                  | Prebacivanje bočne trake                  |
| `Space G G`                | Prikaz git kontrola               |
| `Space S G`                | Pretraživanje sadržaja datoteke             |
| `Ctrl + W W`               | Skok između bočne trake i uređivača |
| `Ctrl + Left/right arrow`  | Promjena veličine bočne trake          |
| `Shift + H`                      | Odlazak na lijevu karticu datoteke             |
| `Shift + L`                      | Odlazak na desnu karticu datoteke            |
| `Space B D`                | Zatvaranje kartice datoteke                  |

### Dok ste u bočnoj traci

| Tipkovnička prečica                   | Funkcija                        |
| ------------------------ | ------------------------------- |
| `A`                        | Dodavanje nove datoteke u nadređeni direktorij      |
| `Shift + A`                | Dodavanje novog poddirektorija u nadređeni direktorij    |
| `D`                        | Brisanje istaknute datoteke/direktorija     |
| `M`                        | Premještanje istaknute datoteke/direktorija       |
| `R`                        | Preimenovanje istaknute datoteke/direktorija     |
| `?`                        | Prikaz pomoći za sve naredbe      |

[Pogledajte sve Neovim tipkovničke prečice koje je konfigurirao LazyVim](https://www.lazyvim.org/keymaps).

## Brzi emojiji

Možete koristiti `Super + Ctrl + E` za prikaz potpunog birača emojija koji će odabir staviti u međuspremnik ili možete koristiti ove opcije brzog pristupa.

| Tipkovnička prečica       | EM | Trag       |
| ------------ | -- | ---------- |
| `Shift + CapsLock M S` | 😄 | osmijeh      |
| `Shift + CapsLock M C` | 😂 | plač        |
| `Shift + CapsLock M L` | 😍 | ljubav       |
| `Shift + CapsLock M V` | ✌️ | pobjeda    |
| `Shift + CapsLock M H` | ❤️ | srce      |
| `Shift + CapsLock M Y` | 👍 | da        |
| `Shift + CapsLock M N` | 👎 | ne         |
| `Shift + CapsLock M F` | 🖕 | jebote       |
| `Shift + CapsLock M W` | 🤞 | želja       |
| `Shift + CapsLock M R` | 🤘 | rock       |
| `Shift + CapsLock M K` | 😘 | poljubac       |
| `Shift + CapsLock M E` | 🙄 | kolutanje očima    |
| `Shift + CapsLock M I` | 😉 | namigivanje       |
| `Shift + CapsLock M P` | 🙏 | molitva |
| `Shift + CapsLock M D` | 🤤 | slinjenje      |
| `Shift + CapsLock M M` | 💰 | novac      |
| `Shift + CapsLock M X` | 🎉 | xellebrate |
| `Shift + CapsLock M 1` | 💯 | 100%       |
| `Shift + CapsLock M T` | 🥂 | zdravica      |
| `Shift + CapsLock M O` |👌 | ok |
| `Shift + CapsLock M G` |👋 | pozdrav |
| `Shift + CapsLock M A` |💪 | ruka |
| `Shift + CapsLock M B` |🤯 | puhanje |

## Brze dopune

| Tipkovnička prečica       | Dopuna       |
| ------------ |  ---------- |
| `Shift + CapsLock Space Space` | — (mdash)   |
| `Shift + CapsLock Space N` | Vaše ime (kako je uneseno pri postavljanju)  |
| `Shift + CapsLock Space E` | Vaša e-pošta (kako je unesena pri postavljanju)  |

Više vlastitih možete dodati uređivanjem `~/.XCompose`, zatim pokretanjem `omarchy restart xcompose` u terminalu kako bi se promjene preuzele.
