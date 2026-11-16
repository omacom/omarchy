# Tipkovnički prečaci

Sve glavne tipkovničke prečace možete vidjeti s `Super + K` (Tmux prečace s `Super + Alt + K`, a Herdr prečace s `Super + Ctrl + K`).

## Kako su prečaci raspoređeni

Svaki prečac nalazi se na jednoj ravnini, određenoj njegovim modifikatorima, a svaka ravnina ima jedan posao. To sprječava da se prečaci međusobno pomiješaju i znači da obično možete pogoditi gdje se nešto nalazi.

| Ravan | Što se tamo nalazi | Primjeri |
| --- | --- | --- |
| `Super + key` | Sustav: prozori, radni prostori, rasporedi i glavni izbornici | `Super + Space` Omarchy izbornik, `Super + W` zatvori prozor, `Super + F` cijeli zaslon |
| `Super + Shift + key` | Aplikacije | `Super + Shift + B` preglednik, `Super + Shift + E` e-pošta, `Super + Shift + N` uređivač |
| `Super + Ctrl + key` | Ploče i izbornici sustava | `Super + Ctrl + A` zvuk, `Super + Ctrl + N` mreža, `Super + Ctrl + C` izbornik hvatanja |
| `Super + Ctrl + Alt + key` | Brze radnje i obavijesti | `Super + Ctrl + Alt + T` prikaži vrijeme, `Super + Ctrl + Alt + B` baterija, `Super + Ctrl + Alt + C` snimka zaslona |

Dodavanje tipke `Alt` prečacu daje vam varijantu iste stvari, nikad nešto nepovezano:

- `Super + Shift + B` otvara preglednik; `Super + Shift + Alt + B` otvara privatni prozor
- `Super + Shift + E` otvara e-poštu; `Super + Shift + Alt + E` započinje novu
- `Super + F` prelazi na cijeli zaslon; `Super + Alt + F` prelazi na punu širinu
- `Super + Ctrl + C` otvara izbornik hvatanja; `Super + Ctrl + Alt + C` preskače izbornik i snima snimku zaslona

Prilikom dodavanja prečaca:

1. Odaberite ravninu prema tome što radi, zatim odaberite tipku.
2. Nemojte pomicati postojeći prečac da biste napravili mjesta. Pronađite slobodnu tipku na pravoj ravnini.
3. Tipku `Alt` koristite samo za varijantu prečaca bez nje.

Nekoliko prečaca krši ova pravila jer su praktični. `Shift` sa strelicom ili tipkom `Tab` pomiče ili obrće, umjesto da otvara aplikaciju, a `Print`, medijske tipke, `Alt + Tab` i `Ctrl + Alt + Del` rade kako rade posvuda drugdje. Oni su iznimke, a ne obrasci za kopiranje.

Ako vam zadana postavka ne odgovara (recimo da želite `Super + Shift + S` za snimke zaslona kao u Windowsima), ponovno je povežite u `~/.config/hypr/bindings.lua`.

## Navigacija

| Prečac                  | Funkcija              |
| ----------------------- | --------------------- |
| `Super + Space`           | Omarchy izbornik (aplikacije i sve ostalo)    |
| `Super + Alt + Space` | Mreža aplikacija |
| `Super + Escape` | Izbornik sustava (obustava, ponovno pokretanje itd.)  |
| `Super + Ctrl + L` | Zaključaj računalo |
| `Super + W` ili `Super + Q` | Zatvori prozor             |
| `Ctrl + Alt + Del` | Zatvori sve prozore |
| `Super + T`               | Prebaci prozor između popločanog/plutajućeg načina             |
| `Super + J` | Prebaci položaj prozora (vodoravno/okomito) |
| `Super + O`               | Prebaci prozor u ljepljivi plutajući način |
| `Super + L`               | Kruži kroz rasporede dwindle, scrolling i floating |
| `Super + Alt + L`         | Kruži kroz rasporede obrnutim redoslijedom |
| `Super + P`               | Prebaci stil pseudo prozora (prirodno naspram rastegnuto) |
| `Super + F`                 | Pređi na cijeli zaslon              |
| `Super + Alt + F`                 | Pređi na punu širinu              |
| `Super + Ctrl + F`                 | Pređi na cijeli zaslon unutar prozora              |
| `Super + 1/2/3/4`         | Skoči na određeni radni prostor na monitoru u fokusu |
| `Super + Tab` | Skoči na sljedeći radni prostor na monitoru u fokusu |
| `Super + Shift + Tab` | Skoči na prethodni radni prostor na monitoru u fokusu |
| `Super + Ctrl + Tab` | Skoči na prijašnji radni prostor na monitoru u fokusu |
| `Super + Shift + 1/2/3/4` | Premjesti prozor na radni prostor na monitoru u fokusu |
| `Super + Shift + Alt + 1/2/3/4` | Premjesti prozor na radni prostor na monitoru u fokusu bez praćenja |
| `Super + S` | Uklj./isklj. cijeli scratchpad |
| `Super + Alt + S` | Premjesti prozor na cijeli scratchpad |
| `Super + Grave` | Uklj./isklj. Quake konzolu |
| `Super + Shift + Grave` | Premjesti prozor na Quake konzolu |
| `Super + Shift + Ctrl + Arrows` | Premjesti prozor na monitor u tom smjeru |
| `Super + Shift + Alt + Arrows` | Premjesti radni prostor na monitor u tom smjeru |
| `Super + Arrow`  | Pomakni fokus na prozor u smjeru strelice, prelazeći na monitor s te strane na rubu zaslona |
| `Super + Shift + Arrow`  | Zamijeni prozor s drugim u smjeru strelice, uključujući onaj na monitoru s te strane |
| `Super + Minus` | Proširi prozor ulijevo |
| `Super + Equal` | Smanji prozor ulijevo |
| `Super + Shift + Minus` | Smanji prozor prema gore |
| `Super + Shift + Equal` | Proširi prozor prema dolje |
| `Super + Alt + Minus/Equal` | Isto mijenjanje veličine u manjim koracima |
| `Super + Ctrl + Minus/Equal` | Isto mijenjanje veličine u većim koracima |
| `Super + Alt + Home` | Spremi širinu prozora |
| `Super + Home` | Vrati spremljenu širinu prozora |
| `Super + Left Mouse` | Povuci prozor |
| `Super + Right Mouse` | Promijeni veličinu prozora |
| `Super + Scroll Wheel` | Listaj kroz radne prostore na monitoru u fokusu |
| `Super + G`               | Uklj./isklj. grupiranje prozora      |
| `Super + Alt + G`               | Izvuci prozor iz grupe      |
| `Super + Alt + Tab`               | Kruži između prozora u grupi      |
| `Super + Alt + Shift + Tab`               | Kruži unatrag između prozora u grupi      |
| `Super + Alt + Scroll Wheel` | Kruži između prozora u grupi |
| `Super + Alt + 1/2/3/4/5`               | Skoči na određeni prozor u grupi      |
| `Super + Alt + Arrow`  | Premjesti prozor u grupu u smjeru strelice, uključujući onaj na monitoru s te strane |
| `Super + Ctrl + Left/Right`  | Kreći se između prozora unutar popločane grupe |
| `Super + Ctrl + Z` | Povećaj prikaz zaslona (ponovite za još veće povećanje) |
| `Super + Ctrl + Alt + Z` | Smanji prikaz zaslona do kraja |
| `Super + /` | Korak naprijed kroz mogućnosti skaliranja monitora |
| `Super + Alt + /` | Korak unatrag kroz mogućnosti skaliranja monitora |
| `Alt + Tab` | Kruži naprijed kroz prozore na aktivnom radnom prostoru |
| `Alt + Shift + Tab` | Kruži unatrag kroz prozore na aktivnom radnom prostoru |
| `Ctrl + Alt + Tab`| Kruži fokus naprijed kroz monitore |
| `Ctrl + Alt + Shift + Tab`| Kruži fokus unatrag kroz monitore |

Prečaci za promjenu veličine koriste fizičke tipke `code:20` i `code:21` (XKB `<AE11>` i `<AE12>`), bez obzira na znakove otisnute na tipkovnici. Na američkim tipkovnicama te su tipke `-` i `=`; na japanskim (JIS) tipkovnicama to su `-` i `^`; na španjolskim tipkovnicama to su `'` i `¡`. Na JIS-u je `Super + ^` jednako `Super + Equal`, dok je `Super + Shift + -` (koje upisuje `=`) jednako `Super + Shift + Minus`.

## Kontrole sustava

| Prečac                  | Funkcija              |
| ----------------------- | --------------------- |
| `Super + Ctrl + A`           | Ploča za zvuk    |
| `Super + Ctrl + B`           | Bluetooth ploča    |
| `Super + Ctrl + N`           | Wi-Fi/mrežna ploča    |
| `Super + Ctrl + D`           | Ploča za zaslon    |
| `Super + Ctrl + P`           | Ploča za napajanje    |
| `Super + Ctrl + X`           | Ploča za agente    |
| `Super + Ctrl + Alt + D`           | Ploča kalendara    |
| `Super + Ctrl + Alt + E`           | Ploča svjetskog sata    |
| `Super + Ctrl + 1-9`           | Uklj./isklj. ploču trake prema položaju    |
| `Super + Ctrl + S` | Izbornik za dijeljenje (putem LocalSend) |
| `Super + Ctrl + C` | Kontrole hvatanja (snimka zaslona/-snimanje/birač) |
| `Super + Ctrl + O` | Izbornik prebacivanja |
| `Super + Ctrl + H` | Izbornik hardvera |
| `Super + Ctrl + E` | Birač emojija |
| `Super + Ctrl + .` | Transkodiraj medije |
| `Super + Shift + Ctrl + A` | Odaberi AI agenta |

## Prilagodbe

| Prečac                  | Funkcija              |
| ----------------------- | --------------------- |
| `Shift + Brightness Up` | Maksimalna svjetlina zaslona |
| `Shift + Brightness Down` | Minimalna svjetlina zaslona |
| `Alt + Brightness Up/Down` | Precizne promjene svjetline od 1% |
| `Alt + Volume Up/Down` | Precizne promjene glasnoće od 1% |
| `Keyboard Brightness Up/Down` | Pozadinsko osvjetljenje tipkovnice jače/slabije |
| `Keyboard Backlight` | Kruži kroz razine pozadinskog osvjetljenja tipkovnice |
| `Alt + Play` | Sljedeća skladba |
| `Alt + Shift + Play` | Prethodna skladba |

## Pokretanje aplikacija

| Prečac                  | Funkcija              |
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
| `Super + Shift + G`           | Aplikacija za poruke (Signal)  |
| `Super + Shift + P`           | Google Photos  |
| `Super + Shift + S`           | Google Maps  |
| `Super + Shift + Alt + G`           | Aplikacija za poruke (WhatsApp)  |
| `Super + Shift + Ctrl + G`           | Aplikacija za poruke (Google)  |
| `Super + Shift + O`           | Obsidian  |
| `Super + Shift + W`           | Pisanje (Omawrite)  |
| `Super + Shift + X`           | X |
| `Super + Shift + Alt + X`           | X Compose |
| `Super + Shift + Y`           | YouTube |

Promijenite/dodajte poveznice u `~/.config/hypr/bindings.lua`.

## Univerzalni međuspremnik

| Prečac                  | Funkcija              |
| ----------------------- | --------------------- |
| `Super + A`           | Odaberi sve u aplikacijama koje podržavaju `Ctrl + A`    |
| `Super + C`           | Kopiraj    |
| `Super + X`           | Izreži (nije u terminalu)    |
| `Super + V`           | Zalijepi    |
| `Super + Ctrl + V`           | Upravitelj međuspremnika    |

Obično na Linuxu trebate `Ctrl + Shift + C/V` za kopiranje i lijepljenje u terminalu i `Ctrl + C/V` da biste to radili posvuda drugdje. Ovi Omarchyjevi ujedinjeni prečaci međuspremnika rade posvuda.

## Hvatanje

| Prečac              | Funkcija                       |
| ------------------- | ------------------------------ |
| `Print Screen`            | Snimka zaslona                      |
| `Super + Ctrl + Alt + C`            | Snimka zaslona (ista snimka, za tipkovnice bez tipke Print Screen) |
| `Super + Ctrl + C` | Izbornik hvatanja |
| `Alt + Print Screen`            | Snimanje zaslona                     |
| `Super + Print Screen` | Birač boja |
| `Super + Ctrl + Print Screen` | Izdvajanje teksta u međuspremnik |
| `Super + Alt + [` | Smanji preklapanje web-kamere tijekom snimanja |
| `Super + Alt + ]` | Povećaj preklapanje web-kamere tijekom snimanja |
| `Alt + Shift + L` | Kopiraj trenutni URL iz web-aplikacije ili preglednika |
| `Alt + Shift + D` | Preuzmi videozapis s trenutne stranice u `~/Videos` |
| `Alt + Space` | Pokreni/zaustavi diktiranje (zahtijeva _Setup > Defaults > Dictation_) |
| `Right Alt` | Drži za diktiranje (zahtijeva _Setup > Defaults > Dictation_) |

Kod snimanja zaslona, prečac prvo pita koji zvuk želite, a zatim započinje snimanje. Pritisnite ga ponovno za zaustavljanje. Pogledajte [snimke zaslona i snimanje](12-screenshots-recording.md) za pojedinosti.

Sve mogućnosti hvatanja dostupne su i pod _Trigger > Capture_ u Omarchy izborniku (`Super + Space`).

## Obavijesti

| Prečac                  | Funkcija              |
| ----------------------- | --------------------- |
| `Super + ,` | Djeluj na najnoviju obavijest: otvori je ili pritisni njezinu jedinu tipku, odaberi među njezinim izborima ili je odbaci kada nema nijednu  |
| `Super + Shift + ,` | Odbaci sve obavijesti |
| `Super + Ctrl + ,` | Upravljaj obavijestima tipkovnicom  |
| `Super + Alt + ,` | Odbaci najnoviju obavijest  |
| `Super + Shift + Alt + ,` | Otvori povijest obavijesti  |
| `Super + Ctrl + Alt + ,` | Uklj./isklj. utišavanje obavijesti  |

## Stil

| Prečac                  | Funkcija              |
| ----------------------- | --------------------- |
| `Super + Ctrl + T` | Odaberi novu temu (također `Super + Ctrl + Shift + Space`) |
| `Super + Ctrl + W` | Odaberi pozadinu teme (također `Super + Ctrl + Space`) |
| `Super + Backspace` | Uklj./isklj. prozirnost prozora |
| `Super + Ctrl + Backspace` | Uklj./isklj. kvadratni omjer jednog prozora |

Dodatne pozadinske slike nalaze se u `~/.config/omarchy/backgrounds/<theme name>`. Dostupno i putem _Install > Style > Background_ u Omarchy izborniku.

Sve mogućnosti stila dostupne su i pod _Style_ u Omarchy izborniku (`Super + Space`).

## Prekidači

| Prečac                  | Funkcija              |
| ----------------------- | --------------------- |
| `Super + Ctrl + I` | Uklj./isklj. zaključavanje pri mirovanju |
| `Super + Ctrl + Delete` | Uklj./isklj. zaslon prijenosnog računala |
| `Super + Ctrl + Alt + Delete` | Uklj./isklj. zrcaljenje zaslona prijenosnog računala |
| `Super + Shift + Space` | Uklj./isklj. gornju traku  |
| `Shift + Mute` | Pređi na sljedeći audioizlaz |
| `Shift + Play` | Pređi na sljedeći izvor medija |
| `Super + Shift + Backspace` | Uklj./isklj. razmake prozora |
| `Super + Ctrl + Alt + F` | Uklj./isklj. radnu površinu preko cijelog zaslona (gornja traka + razmaci prozora) |

## Podsjetnici

| Prečac                  | Funkcija              |
| ----------------------- | --------------------- |
| `Super + Ctrl + R` | Postavi podsjetnik  |
| `Super + Ctrl + Alt + R` | Pogledaj sve podsjetnike  |
| `Super + Ctrl + Shift + R` | Izbriši sve podsjetnike  |

## Napomene

| Prečac                  | Funkcija              |
| ----------------------- | --------------------- |
| `Super + Ctrl + Alt + T` | Prikaži vrijeme kao obavijest  |
| `Super + Ctrl + Alt + B` | Prikaži bateriju kao obavijest  |
| `Super + Ctrl + Alt + W` | Uklj./isklj. prikaz vremena kao obavijest  |

## Tmux

Prefiksna tipka je `Ctrl + Space` (`Ctrl + B` također radi). Ove poveznice možete promijeniti u `~/.config/tmux/tmux.conf`.

### Okna

| Prečac                  | Funkcija              |
| ----------------------- | --------------------- |
| `Prefix + v` | Podijeli okno bočno (okomito) |
| `Prefix + h` | Podijeli okno ispod (vodoravno) |
| `Prefix + x` | Zatvori okno |
| `Prefix + z` | Uklj./isklj. zumiranje okna (cijeli zaslon) |
| `Alt + Enter` | Podijeli okno ispod (bez prefiksa) |
| `Alt + Shift + Enter` | Podijeli okno bočno (bez prefiksa) |
| `Alt + Escape` | Zatvori okno (bez prefiksa) |
| `Ctrl + Alt + Arrows` | Kreći se između okna |
| `Ctrl + Alt + Shift + Arrows` | Mijenjaj veličinu okna |

### Prozori

| Prečac                  | Funkcija              |
| ----------------------- | --------------------- |
| `Prefix + c` | Novi prozor |
| `Prefix + k` | Zatvori prozor |
| `Prefix + r` | Preimenuj prozor |
| `Alt + 1-9` | Idi na određeni prozor |
| `Alt + Arrow Left/Right` | Kreći se između prozora |
| `Alt + Shift + Arrow Left/Right` | Premjesti prozor ulijevo/udesno |

### Sesije

| Prečac                  | Funkcija              |
| ----------------------- | --------------------- |
| `Prefix + C` | Nova sesija |
| `Prefix + K` | Zatvori sesiju |
| `Prefix + R` | Preimenuj sesiju |
| `Prefix + N` | Sljedeća sesija |
| `Prefix + P` | Prethodna sesija |
| `Alt + Arrow Up/Down` | Kreći se između sesija |
| `Prefix + s` | Popis sesija |
| `Prefix + d` | Odvoji se od sesije |

### Način kopiranja (vi-stil)

| Prečac                  | Funkcija              |
| ----------------------- | --------------------- |
| `Prefix + [` | Uđi u način kopiranja |
| `v` | Započni odabir (u načinu kopiranja) |
| `y` | Kopiraj odabir (u načinu kopiranja) |

### Općenito

| Prečac                  | Funkcija              |
| ----------------------- | --------------------- |
| `Prefix + q` | Ponovno učitaj konfiguraciju |
| `Prefix + ?` | Prikaži Tmux tipkovničke prečace |
| `Prefix + :` | Naredbeni redak |

### Funkcije rasporeda u Tmuxu

Te se funkcije moraju pokrenuti unutar Tmux sesije.

| Naredba | Funkcija |
| ------- | -------- |
| `tdl <ai> [<second_ai>]` | Stvori razvojni raspored s uređivačem, AI-jem i terminalom |
| `tdlm <ai> [<second_ai>]` | Stvori razvojni raspored po poddirektoriju |
| `tsl <count> <command>` | Stvori raspored roja s više okna |

## Ghostty terminal

Ghostty terminal instalira se pomoću _Install > Terminal_ putem Omarchy izbornika.

| Prečac                  | Funkcija              |
| ----------------------- | --------------------- |
| `Ctrl + Shift + E` | Nova podjela ispod |
| `Ctrl + Shift + O` | Nova podjela bočno |
| `Ctrl + Alt + Arrows` | Kreći se između podjela |
| `Super + Ctrl + Shift + Arrows` | Promijeni veličinu podjele za 10 redaka |
| `Super + Ctrl + Shift + Alt + Arrows` | Promijeni veličinu podjele za 100 redaka |
| `Ctrl + Shift + T` | Nova kartica  |
| `Ctrl + Shift + Arrows` | Kreći se između kartica |
| `Alt + Numbers` | Idi na određenu karticu |
| `Shift + Pg Up/Down` | Listaj povijest |
| `Ctrl + Left mouse` | Otvori poveznicu u pregledniku |

## Upravitelj datoteka

| Prečac              | Funkcija                       |
| ------------------- | ------------------------------ |
| `Ctrl + L`            | Idi na putanju                     |
| `Space`               | Pregledaj datoteku (strelice navigiraju) |
| `Alt + Up`       | Idi gore u nadređenu mapu        |

## Neovim (s lazyvimom)

### Navigacija

| Prečac                   | Funkcija                        |
| ------------------------ | ------------------------------- |
| `Space`                    | Prikaži mogućnosti naredbi            |
| `Space Space`              | Otvori datoteku putem neizrazitog pretraživanja      |
| `Space E`                  | Uklj./isklj. bočnu traku                  |
| `Space G G`                | Prikaži git kontrole               |
| `Space S G`                | Pretraži sadržaj datoteke             |
| `Ctrl + W W`               | Skači između bočne trake i uređivača |
| `Ctrl + Left/right arrow`  | Promijeni veličinu bočne trake          |
| `Shift + H`                      | Idi na lijevu karticu datoteke             |
| `Shift + L`                      | Idi na desnu karticu datoteke            |
| `Space B D`                | Zatvori karticu datoteke                  |

### Dok ste u bočnoj traci

| Prečac                   | Funkcija                        |
| ------------------------ | ------------------------------- |
| `A`                        | Dodaj novu datoteku u nadređeni direktorij      |
| `Shift + A`                | Dodaj novi poddirektorij u nadređeni direktorij    |
| `D`                        | Izbriši označenu datoteku/direktorij     |
| `M`                        | Premjesti označenu datoteku/direktorij       |
| `R`                        | Preimenuj označenu datoteku/direktorij     |
| `?`                        | Prikaži pomoć za sve naredbe      |

[Pogledajte sve Neovim prečace koje konfigurira LazyVim](https://www.lazyvim.org/keymaps).

## Brzi emojiji

Možete koristiti `Super + Ctrl + E` za prikaz potpunog birača emojija koji će odabir staviti u međuspremnik ili možete koristiti ove mogućnosti brzog pristupa.

| Prečac       | EM | Naznaka       |
| ------------ | -- | ---------- |
| `Shift + CapsLock M S` | 😄 | osmijeh      |
| `Shift + CapsLock M C` | 😂 | plač        |
| `Shift + CapsLock M L` | 😍 | ljubav       |
| `Shift + CapsLock M V` | ✌️ | pobjeda    |
| `Shift + CapsLock M H` | ❤️ | srce      |
| `Shift + CapsLock M Y` | 👍 | da        |
| `Shift + CapsLock M N` | 👎 | ne         |
| `Shift + CapsLock M F` | 🖕 | fuck       |
| `Shift + CapsLock M W` | 🤞 | želja       |
| `Shift + CapsLock M R` | 🤘 | rock       |
| `Shift + CapsLock M K` | 😘 | poljubac       |
| `Shift + CapsLock M E` | 🙄 | kolutanje očima    |
| `Shift + CapsLock M I` | 😉 | namig       |
| `Shift + CapsLock M P` | 🙏 | molitva |
| `Shift + CapsLock M D` | 🤤 | slinjenje      |
| `Shift + CapsLock M M` | 💰 | novac      |
| `Shift + CapsLock M X` | 🎉 | xellebrate |
| `Shift + CapsLock M 1` | 💯 | 100%       |
| `Shift + CapsLock M T` | 🥂 | zdravica      |
| `Shift + CapsLock M O` |👌 | ok |
| `Shift + CapsLock M G` |👋 | pozdrav |
| `Shift + CapsLock M A` |💪 | ruka |
| `Shift + CapsLock M B` |🤯 | oduševljenje |

## Brza dovršavanja

| Prečac       | Dovršavanje       |
| ------------ |  ---------- |
| `Shift + CapsLock Space Space` | — (duga crtica)   |
| `Shift + CapsLock Space N` | Vaše ime (kako je uneseno pri postavljanju)  |
| `Shift + CapsLock Space E` | Vaša e-pošta (kako je unesena pri postavljanju)  |

Možete dodati još svojih uređivanjem `~/.XCompose`, a zatim pokretanjem `omarchy-restart-xcompose` u terminalu kako bi se promjene preuzele.
