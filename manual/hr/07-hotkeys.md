# Tipkovnički prečaci

Glavne tipkovničke kombinacije možeš vidjeti uz `Super + K` (kombinacije za Tmux uz `Super + Alt + K`, a kombinacije za Herdr uz `Super + Ctrl + K`).

## Kako su raspoređeni tipkovnički prečaci

Svaki tipkovnički prečac nalazi se na jednoj razini, određenoj njegovim modifikatorima, i svaka razina ima jedan posao. To sprječava da se tipkovnički prečaci međusobno pomiješaju i znači da obično možeš pogoditi gdje se nešto nalazi.

| Razina | Što se tamo nalazi | Primjeri |
| --- | --- | --- |
| `Super + key` | Sustav: prozori, radni prostori, rasporedi i glavni izbornici | `Super + Space` izbornik Omarchy, `Super + W` zatvori prozor, `Super + F` cijeli zaslon |
| `Super + Shift + key` | Aplikacije | `Super + Shift + B` preglednik, `Super + Shift + E` e-pošta, `Super + Shift + N` uređivač |
| `Super + Ctrl + key` | Ploče i izbornici sustava | `Super + Ctrl + A` zvuk, `Super + Ctrl + N` mreža, `Super + Ctrl + C` izbornik snimanja |
| `Super + Ctrl + Alt + key` | Brze radnje i obavijesti | `Super + Ctrl + Alt + T` prikaži vrijeme, `Super + Ctrl + Alt + B` baterija, `Super + Ctrl + Alt + C` snimka zaslona |

Dodavanje tipke `Alt` tipkovničkom prečacu daje ti varijantu iste stvari, nikada nešto nepovezano:

- `Super + Shift + B` otvara preglednik; `Super + Shift + Alt + B` otvara privatni prozor
- `Super + Shift + E` otvara e-poštu; `Super + Shift + Alt + E` započinje novu
- `Super + F` prelazi na cijeli zaslon; `Super + Alt + F` prelazi na punu širinu
- `Super + Ctrl + C` otvara izbornik snimanja; `Super + Ctrl + Alt + C` preskače izbornik i snima snimku zaslona

Kada dodaješ tipkovnički prečac:

1. Odaberi razinu prema tome što radi, a zatim odaberi tipku.
2. Ne premještaj postojeći tipkovnički prečac da bi napravio mjesta. Pronađi slobodnu tipku na pravoj razini.
3. Koristi `Alt` samo za varijantu tipkovničkog prečaca bez njega.

Nekoliko tipkovničkih prečaca krši ova pravila jer je tako praktično. `Shift` sa strelicom ili tipkom `Tab` premješta ili obrće umjesto da otvara aplikaciju, a `Print`, medijske tipke, `Alt + Tab` i `Ctrl + Alt + Del` rade onako kako rade svugdje drugdje. To su iznimke, a ne obrasci za kopiranje.

Ako ti zadani ne odgovara (recimo želiš `Super + Shift + S` za snimke zaslona kao na Windowsu), ponovno ga poveži u `~/.config/hypr/bindings.lua`.

## Navigacija

| Tipkovnički prečac                  | Funkcija              |
| ----------------------- | --------------------- |
| `Super + Space`           | Izbornik Omarchy (aplikacije i sve ostalo)    |
| `Super + Alt + Space` | Mreža aplikacija |
| `Super + Escape` | Izbornik sustava (obustavi, ponovno pokreni itd.)  |
| `Super + Ctrl + L` | Zaključaj računalo |
| `Super + W` ili `Super + Q` | Zatvori prozor             |
| `Ctrl + Alt + Del` | Zatvori sve prozore |
| `Super + T`               | Prebaci prozor između popločanog i plutajućeg načina             |
| `Super + J` | Prebaci položaj prozora (vodoravno/okomito) |
| `Super + O`               | Uključi/isključi pretvaranje prozora u ljepljivi plutajući prozor |
| `Super + L`               | Kruži kroz rasporede dwindle, scrolling i floating |
| `Super + Alt + L`         | Kruži kroz rasporede unatrag |
| `Super + P`               | Prebaci stil pseudo prozora (prirodno naspram razvlačenja) |
| `Super + F`                 | Pređi na cijeli zaslon              |
| `Super + Alt + F`                 | Pređi na punu širinu              |
| `Super + Ctrl + F`                 | Pređi na cijeli zaslon unutar prozora              |
| `Super + 1/2/3/4`         | Skoči na određeni radni prostor na monitoru u fokusu |
| `Super + Tab` | Skoči na sljedeći radni prostor na monitoru u fokusu |
| `Super + Shift + Tab` | Skoči na prethodni radni prostor na monitoru u fokusu |
| `Super + Ctrl + Tab` | Skoči na prijašnji radni prostor na monitoru u fokusu |
| `Super + Shift + 1/2/3/4` | Premjesti prozor na radni prostor na monitoru u fokusu |
| `Super + Shift + Alt + 1/2/3/4` | Premjesti prozor na radni prostor na monitoru u fokusu bez praćenja |
| `Super + S` | Uključi/isključi puni scratchpad |
| `Super + Alt + S` | Premjesti prozor u puni scratchpad |
| `Super + Grave` | Uključi/isključi konzolu Quake |
| `Super + Shift + Grave` | Premjesti prozor u konzolu Quake |
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
| `Super + Left Mouse` | Povuci prozor unaokolo |
| `Super + Right Mouse` | Promijeni veličinu prozora |
| `Super + Scroll Wheel` | Skrolaj kroz radne prostore na monitoru u fokusu |
| `Super + G`               | Uključi/isključi grupiranje prozora      |
| `Super + Alt + G`               | Izvuci prozor iz grupiranja      |
| `Super + Alt + Tab`               | Kruži između prozora u grupiranju      |
| `Super + Alt + Shift + Tab`               | Kruži unatrag između prozora u grupiranju      |
| `Super + Alt + Scroll Wheel` | Kruži između prozora u grupiranju |
| `Super + Alt + 1/2/3/4/5`               | Skoči na određeni prozor u grupiranju      |
| `Super + Alt + Arrow`  | Premjesti prozor u grupiranje u smjeru strelice, uključujući onaj na monitoru s te strane |
| `Super + Ctrl + Left/Right`  | Kreći se između prozora unutar grupe popločavanja |
| `Super + Ctrl + Z` | Zumiraj zaslon (ponovi za veće zumiranje) |
| `Super + Ctrl + Alt + Z` | Potpuno odzumiraj zaslon |
| `Super + /` | Kreći se naprijed kroz opcije skaliranja monitora |
| `Super + Alt + /` | Kreći se unatrag kroz opcije skaliranja monitora |
| `Alt + Tab` | Kruži naprijed kroz prozore na aktivnom radnom prostoru |
| `Alt + Shift + Tab` | Kruži unatrag kroz prozore na aktivnom radnom prostoru |
| `Ctrl + Alt + Tab`| Kruži fokus naprijed kroz monitore |
| `Ctrl + Alt + Shift + Tab`| Kruži fokus unatrag kroz monitore |

Prečaci za mijenjanje veličine koriste fizičke tipke `code:20` i `code:21` (XKB `<AE11>` i `<AE12>`), bez obzira na znakove otisnute na tipkovnici. Na američkim tipkovnicama te su tipke `-` i `=`; na japanskim (JIS) tipkovnicama to su `-` i `^`; na španjolskim tipkovnicama to su `'` i `¡`. Na JIS-u, `Super + ^` je `Super + Equal`, dok je `Super + Shift + -` (koja upisuje `=`) `Super + Shift + Minus`.

## Kontrole sustava

| Tipkovnički prečac                  | Funkcija              |
| ----------------------- | --------------------- |
| `Super + Ctrl + A`           | Ploča za zvuk    |
| `Super + Ctrl + B`           | Ploča za Bluetooth    |
| `Super + Ctrl + N`           | Ploča za Wi-Fi/mrežu    |
| `Super + Ctrl + D`           | Ploča za zaslon    |
| `Super + Ctrl + P`           | Ploča za napajanje    |
| `Super + Ctrl + X`           | Ploča za agente    |
| `Super + Ctrl + Alt + D`           | Ploča za kalendar    |
| `Super + Ctrl + Alt + E`           | Ploča za svjetski sat    |
| `Super + Ctrl + 1-9`           | Uključi/isključi ploču trake prema položaju    |
| `Super + Ctrl + S` | Izbornik za dijeljenje (putem LocalSenda) |
| `Super + Ctrl + C` | Kontrole snimanja (snimka zaslona/-snimanje/picker) |
| `Super + Ctrl + O` | Izbornik za prebacivanje |
| `Super + Ctrl + H` | Izbornik hardvera |
| `Super + Ctrl + E` | Birač emojija |
| `Super + Ctrl + .` | Transkodiraj medije |
| `Super + Shift + Ctrl + A` | Odaberi AI agenta |

## Prilagodbe

| Tipkovnički prečac                  | Funkcija              |
| ----------------------- | --------------------- |
| `Shift + Brightness Up` | Maksimalna svjetlina zaslona |
| `Shift + Brightness Down` | Minimalna svjetlina zaslona |
| `Alt + Brightness Up/Down` | Precizne promjene svjetline od 1% |
| `Alt + Volume Up/Down` | Precizne promjene glasnoće od 1% |
| `Keyboard Brightness Up/Down` | Pozadinsko osvjetljenje tipkovnice jače/slabije |
| `Keyboard Backlight` | Kruži kroz razine pozadinskog osvjetljenja tipkovnice |
| `Alt + Play` | Sljedeća pjesma |
| `Alt + Shift + Play` | Prethodna pjesma |

## Pokretanje aplikacija

| Tipkovnički prečac                  | Funkcija              |
| ----------------------- | --------------------- |
| `Super + Return`           | Terminal    |
| `Super + Alt + Return` | Terminal Tmux |
| `Super + Ctrl + Return` | Herdr (upravitelj agenata) |
| `Super + Shift + Return`           | Preglednik    |
| `Super + Shift + Alt + B`           | Preglednik (privatno/anonimno)    |
| `Super + Shift + F`           | Upravitelj datoteka    |
| `Super + Shift + Alt + F`           | Upravitelj datoteka u trenutnom radnom direktoriju terminala    |
| `Super + Shift + M`           | Glazba (Spotify)    |
| `Super + Shift + Alt + M`           | Glazba (cliamp)    |
| `Super + Shift + /`           | Upravitelj zaporki (1password)    |
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
| `Super + Shift + Alt + X`           | Sastavi objavu na X-u |
| `Super + Shift + Y`           | YouTube |

Promijeni/dodaj povezivanja u `~/.config/hypr/bindings.lua`.

## Univerzalni međuspremnik

| Tipkovnički prečac                  | Funkcija              |
| ----------------------- | --------------------- |
| `Super + A`           | Odaberi sve u aplikacijama koje podržavaju `Ctrl + A`    |
| `Super + C`           | Kopiraj    |
| `Super + X`           | Izreži (ne u terminalu)    |
| `Super + V`           | Zalijepi    |
| `Super + Ctrl + V`           | Upravitelj međuspremnika    |

Obično na Linuxu trebaš `Ctrl + Shift + C/V` za kopiranje i lijepljenje u terminalu i `Ctrl + C/V` za to svugdje drugdje. Ovi Omarchyjevi objedinjeni tipkovnički prečaci za međuspremnik rade svugdje.

## Snimanje

| Tipkovnički prečac              | Funkcija                       |
| ------------------- | ------------------------------ |
| `Print Screen`            | Snimka zaslona                      |
| `Super + Ctrl + Alt + C`            | Snimka zaslona (isti snimak, za tipkovnice bez tipke Print Screen) |
| `Super + Ctrl + C` | Izbornik snimanja |
| `Alt + Print Screen`            | Snimanje zaslona                     |
| `Super + Shift + Ctrl + Alt + C` | Snimanje zaslona bez zvuka, uz preskakanje izbornika (pritisni ponovno za zaustavljanje) |
| `Super + Print Screen` | Birač boja |
| `Super + Ctrl + Print Screen` | Izdvajanje teksta u međuspremnik |
| `Super + Alt + [` | Smanji preklapanje web-kamere tijekom snimanja |
| `Super + Alt + ]` | Povećaj preklapanje web-kamere tijekom snimanja |
| `Alt + Shift + L` | Kopiraj trenutni URL iz web-aplikacije ili preglednika |
| `Alt + Shift + D` | Preuzmi videozapis s trenutne stranice u `~/Videos` |
| `Alt + Space` | Pokreni/zaustavi diktiranje (zahtijeva _Postavljanje > Zadane postavke > Diktiranje_) |
| `Right Alt` | Drži za diktiranje (zahtijeva _Postavljanje > Zadane postavke > Diktiranje_) |

Kod snimanja zaslona tipkovnički prečac prvo pita koji zvuk želiš, a zatim počinje snimati. Pritisni ga ponovno za zaustavljanje. Pogledaj [snimke zaslona i snimanje](12-screenshots-recording.md) za detalje.

Sve opcije snimanja dostupne su i pod _Okidač > Snimanje_ u izborniku Omarchy (`Super + Space`).

## Obavijesti

| Tipkovnički prečac                  | Funkcija              |
| ----------------------- | --------------------- |
| `Super + ,` | Djeluj na najnoviju obavijest: otvori je ili pritisni njezinu jedinu tipku, odaberi između njezinih opcija ili je odbaci kada ih nema  |
| `Super + Shift + ,` | Odbaci sve obavijesti |
| `Super + Ctrl + ,` | Upravljaj obavijestima tipkovnicom  |
| `Super + Alt + ,` | Odbaci najnoviju obavijest  |
| `Super + Shift + Alt + ,` | Otvori povijest obavijesti  |
| `Super + Ctrl + Alt + ,` | Uključi/isključi utišavanje obavijesti  |

## Stil

| Tipkovnički prečac                  | Funkcija              |
| ----------------------- | --------------------- |
| `Super + Ctrl + T` | Odaberi novu temu (također `Super + Ctrl + Shift + Space`) |
| `Super + Ctrl + W` | Odaberi pozadinu teme (također `Super + Ctrl + Space`) |
| `Super + Backspace` | Uključi/isključi prozirnost prozora |
| `Super + Ctrl + Backspace` | Uključi/isključi kvadratni omjer jednog prozora |

Dodatne pozadinske slike nalaze se u `~/.config/omarchy/backgrounds/<theme name>`. Također dostupno putem _Instaliraj > Stil > Pozadina_ u izborniku Omarchy.

Sve opcije stila dostupne su i pod _Stil_ u izborniku Omarchy (`Super + Space`).

## Prekidači

| Tipkovnički prečac                  | Funkcija              |
| ----------------------- | --------------------- |
| `Super + Ctrl + I` | Uključi/isključi zaključavanje u mirovanju |
| `Super + Ctrl + Delete` | Uključi/isključi zaslon prijenosnog računala |
| `Super + Ctrl + Alt + Delete` | Uključi/isključi zrcaljenje zaslona prijenosnog računala |
| `Super + Shift + Space` | Uključi/isključi gornju traku  |
| `Shift + Mute` | Prebaci na sljedeći audioizlaz |
| `Shift + Play` | Prebaci na sljedeći izvor medija |
| `Super + Shift + Backspace` | Uključi/isključi razmake između prozora |
| `Super + Ctrl + Alt + F` | Uključi/isključi radnu površinu preko cijelog zaslona (gornja traka + razmaci između prozora) |

## Podsjetnici

| Tipkovnički prečac                  | Funkcija              |
| ----------------------- | --------------------- |
| `Super + Ctrl + R` | Postavi podsjetnik  |
| `Super + Ctrl + Alt + R` | Pogledaj sve podsjetnike  |
| `Super + Ctrl + Shift + R` | Obriši sve podsjetnike  |

## Kratke obavijesti

| Tipkovnički prečac                  | Funkcija              |
| ----------------------- | --------------------- |
| `Super + Ctrl + Alt + T` | Prikaži vrijeme kao obavijest  |
| `Super + Ctrl + Alt + B` | Prikaži bateriju kao obavijest  |
| `Super + Ctrl + Alt + W` | Uključi/isključi prikaz vremenskih prilika kao obavijesti  |

## Tmux

Prefiksna tipka je `Ctrl + Space` (`Ctrl + B` također radi). Ova povezivanja možeš promijeniti u `~/.config/tmux/tmux.conf`.

### Okna

| Tipkovnički prečac                  | Funkcija              |
| ----------------------- | --------------------- |
| `Prefix + v` | Podijeli okno bočno (okomito) |
| `Prefix + h` | Podijeli okno ispod (vodoravno) |
| `Prefix + x` | Zatvori okno |
| `Prefix + z` | Uključi/isključi zumiranje okna (cijeli zaslon) |
| `Alt + Enter` | Podijeli okno ispod (bez prefiksa) |
| `Alt + Shift + Enter` | Podijeli okno bočno (bez prefiksa) |
| `Alt + Escape` | Zatvori okno (bez prefiksa) |
| `Ctrl + Alt + Arrows` | Kreći se između okana |
| `Ctrl + Alt + Shift + Arrows` | Mijenjaj veličinu okana |

### Prozori

| Tipkovnički prečac                  | Funkcija              |
| ----------------------- | --------------------- |
| `Prefix + c` | Novi prozor |
| `Prefix + k` | Zatvori prozor |
| `Prefix + r` | Preimenuj prozor |
| `Alt + 1-9` | Idi na određeni prozor |
| `Alt + Arrow Left/Right` | Kreći se između prozora |
| `Alt + Shift + Arrow Left/Right` | Premjesti prozor ulijevo/udesno |

### Sesije

| Tipkovnički prečac                  | Funkcija              |
| ----------------------- | --------------------- |
| `Prefix + C` | Nova sesija |
| `Prefix + K` | Zatvori sesiju |
| `Prefix + R` | Preimenuj sesiju |
| `Prefix + N` | Sljedeća sesija |
| `Prefix + P` | Prethodna sesija |
| `Alt + Arrow Up/Down` | Kreći se između sesija |
| `Prefix + s` | Prikaži popis sesija |
| `Prefix + d` | Odvoji se od sesije |

### Način kopiranja (vi-stil)

| Tipkovnički prečac                  | Funkcija              |
| ----------------------- | --------------------- |
| `Prefix + [` | Uđi u način kopiranja |
| `v` | Započni odabir (u načinu kopiranja) |
| `y` | Kopiraj odabir (u načinu kopiranja) |

### Općenito

| Tipkovnički prečac                  | Funkcija              |
| ----------------------- | --------------------- |
| `Prefix + q` | Ponovno učitaj konfiguraciju |
| `Prefix + ?` | Prikaži tipkovnička povezivanja za Tmux |
| `Prefix + :` | Naredbeni upit |

### Funkcije rasporeda u Tmuxu

Te se funkcije moraju pokrenuti unutar sesije Tmuxa.

| Naredba | Funkcija |
| ------- | -------- |
| `tdl <ai> [<second_ai>]` | Izradi razvojni raspored s uređivačem, AI-jem i terminalom |
| `tdlm <ai> [<second_ai>]` | Izradi razvojni raspored za svaki poddirektorij |
| `tsl <count> <command>` | Izradi raspored roja s više okana |

## Terminal Ghostty

Terminal Ghostty instalira se pomoću _Instaliraj > Terminal_ putem izbornika Omarchy.

| Tipkovnički prečac                  | Funkcija              |
| ----------------------- | --------------------- |
| `Ctrl + Shift + E` | Novi razdjeljak ispod |
| `Ctrl + Shift + O` | Novi razdjeljak bočno |
| `Ctrl + Alt + Arrows` | Kreći se između razdjeljaka |
| `Super + Ctrl + Shift + Arrows` | Promijeni veličinu razdjeljka za 10 redaka |
| `Super + Ctrl + Shift + Alt + Arrows` | Promijeni veličinu razdjeljka za 100 redaka |
| `Ctrl + Shift + T` | Nova kartica  |
| `Ctrl + Shift + Arrows` | Kreći se između kartica |
| `Alt + Numbers` | Idi na određenu karticu |
| `Shift + Pg Up/Down` | Skrolaj kroz povijest |
| `Ctrl + Left mouse` | Otvori poveznicu u pregledniku |

## Upravitelj datoteka

| Tipkovnički prečac              | Funkcija                       |
| ------------------- | ------------------------------ |
| `Ctrl + L`            | Idi na putanju                     |
| `Space`               | Pregledaj datoteku (strelice služe za navigaciju) |
| `Alt + Up`       | Idi gore u nadređenu mapu        |

## Neovim (s lazyvimom)

### Navigacija

| Tipkovnički prečac                   | Funkcija                        |
| ------------------------ | ------------------------------- |
| `Space`                    | Prikaži opcije naredbi            |
| `Space Space`              | Otvori datoteku putem neizrazitog pretraživanja      |
| `Space E`                  | Uključi/isključi bočnu traku                  |
| `Space G G`                | Prikaži git kontrole               |
| `Space S G`                | Pretraži sadržaj datoteke             |
| `Ctrl + W W`               | Skači između bočne trake i uređivača |
| `Ctrl + Left/right arrow`  | Promijeni veličinu bočne trake          |
| `Shift + H`                      | Idi na karticu datoteke ulijevo             |
| `Shift + L`                      | Idi na karticu datoteke udesno            |
| `Space B D`                | Zatvori karticu datoteke                  |

### Dok si u bočnoj traci

| Tipkovnički prečac                   | Funkcija                        |
| ------------------------ | ------------------------------- |
| `A`                        | Dodaj novu datoteku u nadređeni direktorij      |
| `Shift + A`                | Dodaj novi poddirektorij u nadređeni direktorij    |
| `D`                        | Obriši istaknutu datoteku/direktorij     |
| `M`                        | Premjesti istaknutu datoteku/direktorij       |
| `R`                        | Preimenuj istaknutu datoteku/direktorij     |
| `?`                        | Prikaži pomoć za sve naredbe      |

[Pogledaj sve tipkovničke prečace za Neovim koje konfigurira LazyVim](https://www.lazyvim.org/keymaps).

## Brzi emojiji

Možeš koristiti `Super + Ctrl + E` za prikaz potpunog birača emojija koji će odabir staviti u međuspremnik ili možeš koristiti ove opcije za brzi pristup.

| Tipkovnički prečac       | EM | Opis       |
| ------------ | -- | ---------- |
| `Shift + CapsLock M S` | 😄 | osmijeh      |
| `Shift + CapsLock M C` | 😂 | plač        |
| `Shift + CapsLock M L` | 😍 | ljubav       |
| `Shift + CapsLock M V` | ✌️ | pobjeda    |
| `Shift + CapsLock M H` | ❤️ | srce      |
| `Shift + CapsLock M Y` | 👍 | da        |
| `Shift + CapsLock M N` | 👎 | ne         |
| `Shift + CapsLock M F` | 🖕 | srednji prst       |
| `Shift + CapsLock M W` | 🤞 | želja       |
| `Shift + CapsLock M R` | 🤘 | rock       |
| `Shift + CapsLock M K` | 😘 | poljubac       |
| `Shift + CapsLock M E` | 🙄 | kolutanje očima    |
| `Shift + CapsLock M I` | 😉 | namigivanje       |
| `Shift + CapsLock M P` | 🙏 | molitva |
| `Shift + CapsLock M D` | 🤤 | slinjenje      |
| `Shift + CapsLock M M` | 💰 | novac      |
| `Shift + CapsLock M X` | 🎉 | proslava |
| `Shift + CapsLock M 1` | 💯 | 100%       |
| `Shift + CapsLock M T` | 🥂 | zdravica      |
| `Shift + CapsLock M O` |👌 | ok |
| `Shift + CapsLock M G` |👋 | pozdrav |
| `Shift + CapsLock M A` |💪 | ruka |
| `Shift + CapsLock M B` |🤯 | šok |

## Brza dovršavanja

| Tipkovnički prečac       | Dovršavanje       |
| ------------ |  ---------- |
| `Shift + CapsLock Space Space` | — (duga crtica)   |
| `Shift + CapsLock Space N` | Tvoje ime (kako je uneseno prilikom postavljanja)  |
| `Shift + CapsLock Space E` | Tvoja e-pošta (kako je unesena prilikom postavljanja)  |

Možeš dodati još svojih uređivanjem `~/.XCompose`, a zatim pokretanjem `omarchy-restart-xcompose` u terminalu kako bi se promjene preuzele.
