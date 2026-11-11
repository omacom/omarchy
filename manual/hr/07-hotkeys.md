# Tipkovničke prečice

Sve glavne tipkovničke prečice možete vidjeti s `Super + K` (prečice za Tmux s `Super + Alt + K` i prečice za Herdr s `Super + Ctrl + K`).

## Kako su tipkovničke prečice raspoređene

Svaka tipkovnička prečica nalazi se na ravnini, određenoj njezinim modifikatorima, a svaka ravnina ima jedan posao. To sprječava da se tipkovničke prečice međusobno pomiješaju i znači da obično možete pogoditi gdje se nešto nalazi.

| Ravnina | Što se tamo nalazi | Primjeri |
| --- | --- | --- |
| `Super + key` | Sustav: prozori, radni prostori, rasporedi i osnovni izbornici | `Super + Space` izbornik Omarchy, `Super + W` zatvori prozor, `Super + F` cijeli zaslon |
| `Super + Shift + key` | Aplikacije | `Super + Shift + B` preglednik, `Super + Shift + E` e-pošta, `Super + Shift + N` uređivač |
| `Super + Ctrl + key` | Ploče i izbornici sustava | `Super + Ctrl + A` zvuk, `Super + Ctrl + N` mreža, `Super + Ctrl + C` izbornik za snimanje |
| `Super + Ctrl + Alt + key` | Brze radnje i obavijesti | `Super + Ctrl + Alt + T` prikaži vrijeme, `Super + Ctrl + Alt + B` baterija, `Super + Ctrl + Alt + C` snimka zaslona |

Dodavanje tipke `Alt` tipkovničkoj prečici daje vam varijantu iste stvari, nikada nešto nepovezano:

- `Super + Shift + B` otvara preglednik; `Super + Shift + Alt + B` otvara privatni prozor
- `Super + Shift + E` otvara e-poštu; `Super + Shift + Alt + E` započinje novu
- `Super + F` prikazuje na cijelom zaslonu; `Super + Alt + F` prikazuje na cijeloj širini
- `Super + Ctrl + C` otvara izbornik za snimanje; `Super + Ctrl + Alt + C` preskače izbornik i snima snimku zaslona

Pri dodavanju tipkovničke prečice:

1. Odaberite ravninu prema tome što radi, zatim odaberite tipku.
2. Nemojte pomicati postojeću tipkovničku prečicu da biste napravili mjesta. Pronađite slobodnu tipku na pravoj ravnini.
3. Koristite `Alt` samo za varijantu tipkovničke prečice bez nje.

Nekoliko tipkovničkih prečica krši ova pravila jer su praktične. `Shift` sa strelicom ili `Tab` pomiče ili obrće umjesto da otvara aplikaciju, a `Print`, medijske tipke, `Alt + Tab` i `Ctrl + Alt + Del` rade onako kako rade posvuda drugdje. To su iznimke, a ne obrasci za kopiranje.

Ako vam zadana postavka ne odgovara (recimo da želite `Super + Shift + S` za snimke zaslona kao na Windowsu), ponovno je povežite u `~/.config/hypr/bindings.lua`.

## Navigacija

| Tipkovnička prečica                  | Funkcija              |
| ----------------------- | --------------------- |
| `Super + Space`           | Izbornik Omarchy (aplikacije i sve ostalo)    |
| `Super + Alt + Space` | Mreža aplikacija |
| `Super + Escape` | Izbornik sustava (obustava, ponovno pokretanje itd.)  |
| `Super + Ctrl + L` | Zaključaj računalo |
| `Super + W` or `Super + Q` | Zatvori prozor             |
| `Ctrl + Alt + Del` | Zatvori sve prozore |
| `Super + T`               | Prebaci prozor između popločanog/plutajućeg načina             |
| `Super + J` | Prebaci položaj prozora (vodoravno/okomito) |
| `Super + O`               | Prebaci prozor u način sticky'n'floating |
| `Super + L`               | Kružite kroz rasporede dwindle, scrolling i floating |
| `Super + Alt + L`         | Kružite kroz rasporede obrnutim redoslijedom |
| `Super + P`               | Prebaci stil pseudo prozora (prirodno naspram rastegnutog) |
| `Super + F`                 | Prikaži na cijelom zaslonu              |
| `Super + Alt + F`                 | Prikaži na cijeloj širini              |
| `Super + Ctrl + F`                 | Prikaži na cijelom zaslonu unutar prozora              |
| `Super + 1/2/3/4`         | Skoči na određeni radni prostor na fokusiranom monitoru |
| `Super + Tab` | Skoči na sljedeći radni prostor na fokusiranom monitoru |
| `Super + Shift + Tab` | Skoči na prethodni radni prostor na fokusiranom monitoru |
| `Super + Ctrl + Tab` | Skoči na prijašnji radni prostor na fokusiranom monitoru |
| `Super + Shift + 1/2/3/4` | Premjesti prozor na radni prostor na fokusiranom monitoru |
| `Super + Shift + Alt + 1/2/3/4` | Premjesti prozor na radni prostor na fokusiranom monitoru bez praćenja |
| `Super + S` | Prebaci cijeli scratchpad |
| `Super + Alt + S` | Premjesti prozor na cijeli scratchpad |
| `Super + Grave` | Prebaci konzolu Quake |
| `Super + Shift + Grave` | Premjesti prozor na konzolu Quake |
| `Super + Shift + Ctrl + Arrows` | Premjesti prozor na monitor u tom smjeru |
| `Super + Shift + Alt + Arrows` | Premjesti radni prostor na monitor u tom smjeru |
| `Super + Arrow`  | Premjesti fokus na prozor u smjeru strelice, prelazeći na monitor s te strane na rubu zaslona |
| `Super + Shift + Arrow`  | Zamijeni prozor s drugim u smjeru strelice, uključujući onaj na monitoru s te strane |
| `Super + Minus` | Proširi prozor ulijevo |
| `Super + Equal` | Smanji prozor ulijevo |
| `Super + Shift + Minus` | Smanji prozor prema gore |
| `Super + Shift + Equal` | Proširi prozor prema dolje |
| `Super + Alt + Minus/Equal` | Isto mijenjanje veličine u manjim koracima |
| `Super + Ctrl + Minus/Equal` | Isto mijenjanje veličine u većim koracima |
| `Super + Alt + Home` | Spremi širinu prozora |
| `Super + Home` | Vrati spremljenu širinu prozora |
| `Super + Left Mouse` | Povuci prozor okolo |
| `Super + Right Mouse` | Promijeni veličinu prozora |
| `Super + Scroll Wheel` | Listaj kroz radne prostore na fokusiranom monitoru |
| `Super + G`               | Prebaci grupiranje prozora      |
| `Super + Alt + G`               | Izbaci prozor iz grupiranja      |
| `Super + Alt + Tab`               | Kružite između prozora u grupiranju      |
| `Super + Alt + Shift + Tab`               | Kružite unatrag između prozora u grupiranju      |
| `Super + Alt + Scroll Wheel` | Kružite između prozora u grupiranju |
| `Super + Alt + 1/2/3/4/5`               | Skoči na određeni prozor u grupiranju      |
| `Super + Alt + Arrow`  | Premjesti prozor u grupiranje u smjeru strelice, uključujući onaj na monitoru s te strane |
| `Super + Ctrl + Left/Right`  | Kreći se između prozora unutar grupe popločavanja |
| `Super + Ctrl + Z` | Povećaj prikaz zaslona (ponovite za veće povećanje) |
| `Super + Ctrl + Alt + Z` | Potpuno smanji prikaz zaslona |
| `Super + /` | Korak naprijed kroz mogućnosti skaliranja monitora |
| `Super + Alt + /` | Korak unatrag kroz mogućnosti skaliranja monitora |
| `Alt + Tab` | Kružite naprijed kroz prozore na aktivnom radnom prostoru |
| `Alt + Shift + Tab` | Kružite unatrag kroz prozore na aktivnom radnom prostoru |
| `Ctrl + Alt + Tab`| Kružite fokus naprijed kroz monitore |
| `Ctrl + Alt + Shift + Tab`| Kružite fokus unatrag kroz monitore |

Prečice za mijenjanje veličine koriste fizičke tipke `code:20` i `code:21` (XKB `<AE11>` i `<AE12>`), bez obzira na znakove otisnute na tipkovnici. Na američkim tipkovnicama te tipke su `-` i `=`; na japanskim (JIS) tipkovnicama su `-` i `^`; na španjolskim tipkovnicama su `'` i `¡`. Na JIS tipkovnici `Super + ^` je `Super + Equal`, dok je `Super + Shift + -` (čime se upisuje `=`) zapravo `Super + Shift + Minus`.

## Kontrole sustava

| Tipkovnička prečica                  | Funkcija              |
| ----------------------- | --------------------- |
| `Super + Ctrl + A`           | Ploča za zvuk    |
| `Super + Ctrl + B`           | Ploča za Bluetooth    |
| `Super + Ctrl + N`           | Ploča za Wi-Fi/mrežu    |
| `Super + Ctrl + D`           | Ploča za zaslon    |
| `Super + Ctrl + P`           | Ploča za napajanje    |
| `Super + Ctrl + X`           | Ploča za agente    |
| `Super + Ctrl + Alt + D`           | Ploča za kalendar    |
| `Super + Ctrl + Alt + E`           | Ploča za svjetski sat    |
| `Super + Ctrl + 1-9`           | Prebaci ploču trake prema položaju    |
| `Super + Ctrl + S` | Izbornik za dijeljenje (putem LocalSend) |
| `Super + Ctrl + C` | Kontrole snimanja (snimka zaslona/snimač zaslona/birač) |
| `Super + Ctrl + O` | Prebaci izbornik |
| `Super + Ctrl + H` | Izbornik hardvera |
| `Super + Ctrl + E` | Birač emojija |
| `Super + Ctrl + .` | Transkodiraj medije |
| `Super + Shift + Ctrl + A` | Odaberi AI agenta |

## Podešavanja

| Tipkovnička prečica                  | Funkcija              |
| ----------------------- | --------------------- |
| `Shift + Brightness Up` | Maksimalna svjetlina zaslona |
| `Shift + Brightness Down` | Minimalna svjetlina zaslona |
| `Alt + Brightness Up/Down` | Precizne promjene svjetline od 1% |
| `Alt + Volume Up/Down` | Precizne promjene glasnoće od 1% |
| `Keyboard Brightness Up/Down` | Pozadinsko osvjetljenje tipkovnice jače/slabije |
| `Keyboard Backlight` | Kružite kroz razine pozadinskog osvjetljenja tipkovnice |
| `Alt + Play` | Sljedeća skladba |
| `Alt + Shift + Play` | Prethodna skladba |

## Pokretanje aplikacija

| Tipkovnička prečica                  | Funkcija              |
| ----------------------- | --------------------- |
| `Super + Return`           | Terminal    |
| `Super + Alt + Return` | Tmux terminal |
| `Super + Ctrl + Return` | Herdr (upravitelj agenata) |
| `Super + Shift + Return`           | Preglednik    |
| `Super + Shift + Alt + B`           | Preglednik (privatno/anonimno)    |
| `Super + Shift + F`           | Upravitelj datoteka    |
| `Super + Shift + Alt + F`           | Upravitelj datoteka u cwd-u terminala    |
| `Super + Shift + M`           | Glazba (Spotify)    |
| `Super + Shift + Alt + M`           | Glazba (cliamp)    |
| `Super + Shift + /`           | Upravitelj lozinki (1password)    |
| `Super + Shift + Q`           | Kalkulator (Omacalc)    |
| `Super + Shift + T`           | Aktivnost (btop)    |
| `Super + Shift + N`           | Uređivač (Neovim)  |
| `Super + Shift + C`           | Kalendar ([HEY](https://hey.com/))  |
| `Super + Shift + E`           | E-pošta ([HEY](https://hey.com/))  |
| `Super + Shift + Alt + E`           | Nova e-pošta ([HEY](https://hey.com/))  |
| `Super + Shift + A`           | AI (ChatGPT)  |
| `Super + Shift + Alt + A`           | AI (Grok)  |
| `Super + Shift + G`           | Poruke (Signal)  |
| `Super + Shift + P`           | Google Photos  |
| `Super + Shift + S`           | Google Maps  |
| `Super + Shift + Alt + G`           | Poruke (WhatsApp)  |
| `Super + Shift + Ctrl + G`           | Poruke (Google)  |
| `Super + Shift + O`           | Obsidian  |
| `Super + Shift + W`           | Pisanje (Omawrite)  |
| `Super + Shift + X`           | X |
| `Super + Shift + Alt + X`           | X Compose |
| `Super + Shift + Y`           | YouTube |

Promijenite/dodajte povezivanja u `~/.config/hypr/bindings.lua`.

## Univerzalni međuspremnik

| Tipkovnička prečica                  | Funkcija              |
| ----------------------- | --------------------- |
| `Super + A`           | Odaberi sve u aplikacijama koje podržavaju `Ctrl + A`    |
| `Super + C`           | Kopiraj    |
| `Super + X`           | Izreži (ne u terminalu)    |
| `Super + V`           | Zalijepi    |
| `Super + Ctrl + V`           | Upravitelj međuspremnika    |

Obično na Linuxu trebate `Ctrl + Shift + C/V` za kopiranje i lijepljenje u terminalu i `Ctrl + C/V` da to učinite svugdje drugdje. Ove objedinjene tipkovničke prečice za međuspremnik u sustavu Omarchy rade svugdje.

## Snimanje

| Tipkovnička prečica              | Funkcija                       |
| ------------------- | ------------------------------ |
| `Print Screen`            | Snimka zaslona                      |
| `Super + Ctrl + Alt + C`            | Snimka zaslona (ista snimka, za tipkovnice bez tipke Print Screen) |
| `Super + Ctrl + C` | Izbornik za snimanje |
| `Alt + Print Screen`            | Snimanje zaslona                     |
| `Super + Print Screen` | Birač boja |
| `Super + Ctrl + Print Screen` | Izdvajanje teksta u međuspremnik |
| `Super + Alt + [` | Smanji preklapanje web-kamere tijekom snimanja |
| `Super + Alt + ]` | Povećaj preklapanje web-kamere tijekom snimanja |
| `Alt + Shift + L` | Kopiraj trenutni URL iz web-aplikacije ili Chromiuma |
| `Alt + Shift + D` | Preuzmi videozapis s trenutne stranice u `~/Videos` |
| `Alt + Space` | Pokreni/zaustavi diktiranje (zahtijeva _Setup > Defaults > Dictation_) |
| `Right Alt` | Drži za diktiranje (zahtijeva _Setup > Defaults > Dictation_) |

Kod snimanja zaslona, tipkovnička prečica najprije pita koji zvuk želite, zatim započinje snimanje. Pritisnite je ponovno za zaustavljanje. Pojedinosti potražite u [snimke zaslona i snimanje](12-screenshots-recording.md).

Svim mogućnostima snimanja može se pristupiti i pod _Trigger > Capture_ u izborniku Omarchy (`Super + Space`).

## Obavijesti

| Tipkovnička prečica                  | Funkcija              |
| ----------------------- | --------------------- |
| `Super + ,` | Djeluj na najnoviju obavijest: otvori je ili pritisni njezinu jedinu tipku, odaberi među njezinim mogućnostima ili je odbaci kada ih nema  |
| `Super + Shift + ,` | Odbaci sve obavijesti |
| `Super + Ctrl + ,` | Upravljaj obavijestima tipkovnicom  |
| `Super + Alt + ,` | Odbaci najnoviju obavijest  |
| `Super + Shift + Alt + ,` | Otvori povijest obavijesti  |
| `Super + Ctrl + Alt + ,` | Prebaci utišavanje obavijesti  |

## Stil

| Tipkovnička prečica                  | Funkcija              |
| ----------------------- | --------------------- |
| `Super + Ctrl + T` | Odaberi novu temu (također `Super + Ctrl + Shift + Space`) |
| `Super + Ctrl + W` | Odaberi pozadinu teme (također `Super + Ctrl + Space`) |
| `Super + Backspace` | Prebaci prozirnost prozora |
| `Super + Ctrl + Backspace` | Prebaci kvadratni omjer za jedan prozor |

Dodatne pozadinske slike nalaze se u `~/.config/omarchy/backgrounds/<theme name>`. Dostupno i putem _Install > Style > Background_ u izborniku Omarchy.

Svim mogućnostima stila može se pristupiti i pod _Style_ u izborniku Omarchy (`Super + Space`).

## Uključivanje/isključivanje

| Tipkovnička prečica                  | Funkcija              |
| ----------------------- | --------------------- |
| `Super + Ctrl + I` | Prebaci zaključavanje pri neaktivnosti |
| `Super + Ctrl + Delete` | Uključi/isključi zaslon prijenosnog računala |
| `Super + Ctrl + Alt + Delete` | Prebaci zrcaljenje zaslona prijenosnog računala |
| `Super + Shift + Space` | Prebaci gornju traku  |
| `Shift + Mute` | Prebaci na sljedeći audioizlaz |
| `Shift + Play` | Prebaci na sljedeći izvor medija |
| `Super + Shift + Backspace` | Prebaci razmake među prozorima |
| `Super + Ctrl + Alt + F` | Prebaci radnu površinu na cijelom zaslonu (gornja traka + razmaci među prozorima) |

## Podsjetnici

| Tipkovnička prečica                  | Funkcija              |
| ----------------------- | --------------------- |
| `Super + Ctrl + R` | Postavi podsjetnik  |
| `Super + Ctrl + Alt + R` | Prikaži sve podsjetnike  |
| `Super + Ctrl + Shift + R` | Izbriši sve podsjetnike  |

## Kratke obavijesti

| Tipkovnička prečica                  | Funkcija              |
| ----------------------- | --------------------- |
| `Super + Ctrl + Alt + T` | Prikaži vrijeme kao obavijest  |
| `Super + Ctrl + Alt + B` | Prikaži bateriju kao obavijest  |
| `Super + Ctrl + Alt + W` | Prebaci vremensku prognozu kao obavijest  |

## Tmux

Prefiksna tipka je `Ctrl + Space` (`Ctrl + B` također radi). Ova povezivanja možete promijeniti u `~/.config/tmux/tmux.conf`.

### Okna

| Tipkovnička prečica                  | Funkcija              |
| ----------------------- | --------------------- |
| `Prefix + v` | Podijeli okno bočno (okomito) |
| `Prefix + h` | Podijeli okno ispod (vodoravno) |
| `Prefix + x` | Zatvori okno |
| `Prefix + z` | Prebaci zumiranje okna (cijeli zaslon) |
| `Alt + Enter` | Podijeli okno ispod (bez prefiksa) |
| `Alt + Shift + Enter` | Podijeli okno bočno (bez prefiksa) |
| `Alt + Escape` | Zatvori okno (bez prefiksa) |
| `Ctrl + Alt + Arrows` | Kreći se između okna |
| `Ctrl + Alt + Shift + Arrows` | Promijeni veličinu okna |

### Prozori

| Tipkovnička prečica                  | Funkcija              |
| ----------------------- | --------------------- |
| `Prefix + c` | Novi prozor |
| `Prefix + k` | Zatvori prozor |
| `Prefix + r` | Preimenuj prozor |
| `Alt + 1-9` | Idi na određeni prozor |
| `Alt + Arrow Left/Right` | Kreći se između prozora |
| `Alt + Shift + Arrow Left/Right` | Premjesti prozor ulijevo/udesno |

### Sesije

| Tipkovnička prečica                  | Funkcija              |
| ----------------------- | --------------------- |
| `Prefix + C` | Nova sesija |
| `Prefix + K` | Zatvori sesiju |
| `Prefix + R` | Preimenuj sesiju |
| `Prefix + N` | Sljedeća sesija |
| `Prefix + P` | Prethodna sesija |
| `Alt + Arrow Up/Down` | Kreći se između sesija |
| `Prefix + s` | Prikaži popis sesija |
| `Prefix + d` | Odvoji se od sesije |

### Način kopiranja (vi-style)

| Tipkovnička prečica                  | Funkcija              |
| ----------------------- | --------------------- |
| `Prefix + [` | Uđi u način kopiranja |
| `v` | Započni odabir (u načinu kopiranja) |
| `y` | Kopiraj odabir (u načinu kopiranja) |

### Općenito

| Tipkovnička prečica                  | Funkcija              |
| ----------------------- | --------------------- |
| `Prefix + q` | Ponovno učitaj konfiguraciju |
| `Prefix + ?` | Prikaži tipkovničke prečice za Tmux |
| `Prefix + :` | Naredbeni redak |

### Funkcije rasporeda za Tmux

Ove funkcije moraju se pokrenuti unutar Tmux sesije.

| Naredba | Funkcija |
| ------- | -------- |
| `tdl <ai> [<second_ai>]` | Stvori razvojni raspored s uređivačem, AI-jem i terminalom |
| `tdlm <ai> [<second_ai>]` | Stvori razvojni raspored za svaki poddirektorij |
| `tsl <count> <command>` | Stvori raspored roja s više okna |

## Terminal Ghostty

Terminal Ghostty instalira se pomoću _Install > Terminal_ putem izbornika Omarchy.

| Tipkovnička prečica                  | Funkcija              |
| ----------------------- | --------------------- |
| `Ctrl + Shift + E` | Nova podjela ispod |
| `Ctrl + Shift + O` | Nova podjela bočno |
| `Ctrl + Alt + Arrows` | Kreći se između podjela |
| `Super + Ctrl + Shift + Arrows` | Promijeni veličinu podjele za 10 redaka |
| `Super + Ctrl + Shift + Alt + Arrows` | Promijeni veličinu podjele za 100 redaka |
| `Ctrl + Shift + T` | Nova kartica  |
| `Ctrl + Shift + Arrows` | Kreći se između kartica |
| `Alt + Numbers` | Idi na određenu karticu |
| `Shift + Pg Up/Down` | Listaj kroz povijest |
| `Ctrl + Left mouse` | Otvori poveznicu u pregledniku |

## Upravitelj datoteka

| Tipkovnička prečica              | Funkcija                       |
| ------------------- | ------------------------------ |
| `Ctrl + L`            | Idi na putanju                     |
| `Space`               | Pretpregled datoteke (strelice za navigaciju) |
| `Alt + Up`       | Idi gore u nadređenu mapu        |

## Neovim (s lazyvim)

### Navigacija

| Tipkovnička prečica                   | Funkcija                        |
| ------------------------ | ------------------------------- |
| `Space`                    | Prikaži mogućnosti naredbi            |
| `Space Space`              | Otvori datoteku putem neizrazitog pretraživanja      |
| `Space E`                  | Prebaci bočnu traku                  |
| `Space G G`                | Prikaži git kontrole               |
| `Space S G`                | Pretraži sadržaj datoteke             |
| `Ctrl + W W`               | Skači između bočne trake i uređivača |
| `Ctrl + Left/right arrow`  | Promijeni veličinu bočne trake          |
| `Shift + H`                      | Idi na lijevu karticu datoteke             |
| `Shift + L`                      | Idi na desnu karticu datoteke            |
| `Space B D`                | Zatvori karticu datoteke                  |

### Dok ste u bočnoj traci

| Tipkovnička prečica                   | Funkcija                        |
| ------------------------ | ------------------------------- |
| `A`                        | Dodaj novu datoteku u nadređeni direktorij      |
| `Shift + A`                | Dodaj novi poddirektorij u nadređeni direktorij    |
| `D`                        | Izbriši označenu datoteku/direktorij     |
| `M`                        | Premjesti označenu datoteku/direktorij       |
| `R`                        | Preimenuj označenu datoteku/direktorij     |
| `?`                        | Prikaži pomoć za sve naredbe      |

[Pogledajte sve tipkovničke prečice za Neovim koje konfigurira LazyVim](https://www.lazyvim.org/keymaps).

## Brzi emojiji

Možete koristiti `Super + Ctrl + E` za prikaz potpunog birača emojija koji će odabir staviti u međuspremnik ili možete koristiti ove mogućnosti brzog pristupa.

| Tipkovnička prečica       | EM | Trag       |
| ------------ | -- | ---------- |
| `Shift + CapsLock M S` | 😄 | osmijeh      |
| `Shift + CapsLock M C` | 😂 | plač        |
| `Shift + CapsLock M L` | 😍 | ljubav       |
| `Shift + CapsLock M V` | ✌️ | pobjeda    |
| `Shift + CapsLock M H` | ❤️ | srce      |
| `Shift + CapsLock M Y` | 👍 | da        |
| `Shift + CapsLock M N` | 👎 | ne         |
| `Shift + CapsLock M F` | 🖕 | jebi se       |
| `Shift + CapsLock M W` | 🤞 | želja       |
| `Shift + CapsLock M R` | 🤘 | rock       |
| `Shift + CapsLock M K` | 😘 | poljubac       |
| `Shift + CapsLock M E` | 🙄 | kolutanje očima    |
| `Shift + CapsLock M I` | 😉 | namigivanje       |
| `Shift + CapsLock M P` | 🙏 | moli |
| `Shift + CapsLock M D` | 🤤 | slinjenje      |
| `Shift + CapsLock M M` | 💰 | novac      |
| `Shift + CapsLock M X` | 🎉 | proslava |
| `Shift + CapsLock M 1` | 💯 | 100%       |
| `Shift + CapsLock M T` | 🥂 | zdravica      |
| `Shift + CapsLock M O` |👌 | ok |
| `Shift + CapsLock M G` |👋 | pozdrav |
| `Shift + CapsLock M A` |💪 | ruka |
| `Shift + CapsLock M B` |🤯 | raspametiće |

## Brza dovršavanja

| Tipkovnička prečica       | Dovršavanje       |
| ------------ |  ---------- |
| `Shift + CapsLock Space Space` | — (mdash)   |
| `Shift + CapsLock Space N` | Vaše ime (kako je uneseno pri postavljanju)  |
| `Shift + CapsLock Space E` | Vaša e-pošta (kako je unesena pri postavljanju)  |

Možete dodati još svojih uređivanjem `~/.XCompose`, zatim pokretanjem `omarchy-restart-xcompose` u terminalu kako bi se promjene preuzele.
