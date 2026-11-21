# Tipkovnički prečaci

Sve glavne tipkovničke prečace možeš vidjeti sa `Super + K` (Tmux prečace sa `Super + Alt + K`, a Herdr prečace sa `Super + Ctrl + K`).

## Kako su organizirani tipkovnički prečaci

Svaki prečac nalazi se na jednoj ravnini, određenoj njegovim modifikatorima, i svaka ravnina ima jedan zadatak. To sprječava da se prečaci međusobno pomiješaju i znači da obično možeš pogoditi gdje se nešto nalazi.

| Ravnina | Što se tamo nalazi | Primjeri |
| --- | --- | --- |
| `Super + key` | Sustav: prozori, radni prostori, rasporedi i osnovni izbornici | `Super + Space` izbornik Omarchy, `Super + W` zatvori prozor, `Super + F` cijeli zaslon |
| `Super + Shift + key` | Aplikacije | `Super + Shift + B` preglednik, `Super + Shift + E` e-pošta, `Super + Shift + N` uređivač |
| `Super + Ctrl + key` | Ploče i izbornici sustava | `Super + Ctrl + A` zvuk, `Super + Ctrl + N` mreža, `Super + Ctrl + C` izbornik snimanja |
| `Super + Ctrl + Alt + key` | Brze radnje i obavijesti | `Super + Ctrl + Alt + T` prikaži vrijeme, `Super + Ctrl + Alt + B` baterija, `Super + Ctrl + Alt + C` snimka zaslona |

Dodavanje `Alt` prečacu daje ti varijantu iste stvari, nikad nešto nepovezano:

- `Super + Shift + B` otvara preglednik; `Super + Shift + Alt + B` otvara privatni prozor
- `Super + Shift + E` otvara e-poštu; `Super + Shift + Alt + E` započinje novu
- `Super + F` prelazi na cijeli zaslon; `Super + Alt + F` prelazi na cijelu širinu
- `Super + Ctrl + C` otvara izbornik snimanja; `Super + Ctrl + Alt + C` preskače izbornik i snima snimku zaslona

Pri dodavanju prečaca:

1. Odaberi ravninu prema tome što radi, zatim odaberi tipku.
2. Nemoj premještati postojeći prečac da bi napravio mjesta. Pronađi slobodnu tipku na pravoj ravnini.
3. Koristi `Alt` samo za varijantu prečaca bez njega.

Nekoliko prečaca krši ova pravila jer su praktični. `Shift` sa strelicom ili `Tab` premješta ili obrće umjesto da otvara aplikaciju, a `Print`, medijske tipke, `Alt + Tab` i `Ctrl + Alt + Del` rade onako kako rade svugdje drugdje. To su iznimke, a ne obrasci za kopiranje.

Ako ti zadani prečac ne odgovara (recimo da želiš `Super + Shift + S` za snimke zaslona kao na Windowsima), ponovno ga poveži u `~/.config/hypr/bindings.lua`.

## Navigacija

| Prečac                  | Funkcija              |
| ----------------------- | --------------------- |
| `Super + Space`           | Izbornik Omarchy (aplikacije i sve ostalo)    |
| `Super + Alt + Space` | Mreža aplikacija |
| `Super + Escape` | Izbornik sustava (obustava, ponovno pokretanje itd.)  |
| `Super + Ctrl + L` | Zaključaj računalo |
| `Super + W` or `Super + Q` | Zatvori prozor             |
| `Ctrl + Alt + Del` | Zatvori sve prozore |
| `Super + K` | Prikaži sve prečace |
| `Super + Alt + K` | Prikaži tmux prečace |
| `Super + Ctrl + K` | Prikaži herdr prečace |
| `Super + M` | Minimiziraj prozor na dock |
| `Super + T`               | Prebaci prozor između popločanog/plutajućeg načina             |
| `Super + J` | Prebaci položaj prozora (vodoravno/okomito) |
| `Super + O`               | Prebaci iskačući prozor u sticky'n'floating |
| `Super + L`               | Kruži kroz rasporede dwindle, scrolling i floating |
| `Super + Alt + L`         | Kruži kroz rasporede unatrag |
| `Super + P`               | Prebaci pseudo stil prozora (prirodni naspram rastegnutog) |
| `Super + F`                 | Prikaži preko cijelog zaslona              |
| `Super + Alt + F`                 | Prikaži preko cijele širine              |
| `Super + Ctrl + F`                 | Prikaži preko cijelog zaslona unutar prozora              |
| `Super + 1…9/0`         | Skoči na određeni radni prostor (0 je 10) na fokusiranom monitoru |
| `Super + Tab` | Skoči na sljedeći radni prostor na fokusiranom monitoru |
| `Super + Shift + Tab` | Skoči na prethodni radni prostor na fokusiranom monitoru |
| `Super + Ctrl + Tab` | Skoči na prijašnji radni prostor na fokusiranom monitoru |
| `Super + Shift + 1…9/0` | Premjesti prozor na radni prostor na fokusiranom monitoru |
| `Super + Shift + Alt + 1…9/0` | Premjesti prozor na radni prostor na fokusiranom monitoru bez praćenja |
| `Super + S` | Prebaci cijeli scratchpad |
| `Super + Alt + S` | Premjesti prozor na cijeli scratchpad |
| `Super + Grave` | Prebaci Quake konzolu |
| `Super + Shift + Grave` | Premjesti prozor na Quake konzolu |
| `Super + Shift + Ctrl + Arrows` | Premjesti prozor na monitor u tom smjeru |
| `Super + Shift + Alt + Arrows` | Premjesti radni prostor na monitor u tom smjeru |
| `Super + Arrow`  | Premjesti fokus na prozor u smjeru strelice, prelazeći na monitor na toj strani na rubu zaslona |
| `Super + Shift + Arrow`  | Zamijeni prozor s drugim u smjeru strelice, uključujući onaj na monitoru na toj strani |
| `Super + Minus` | Proširi prozor ulijevo |
| `Super + Equal` | Smanji prozor ulijevo |
| `Super + Shift + Minus` | Smanji prozor prema gore |
| `Super + Shift + Equal` | Proširi prozor prema dolje |
| `Super + Alt + Minus/Equal` | Isto mijenjanje veličine u manjim koracima |
| `Super + Ctrl + Minus/Equal` | Isto mijenjanje veličine u većim koracima |
| `Super + Alt + Home` | Spremi širinu prozora |
| `Super + Home` | Vrati spremljenu širinu prozora |
| `Super + Left Mouse` | Vuci prozor uokolo |
| `Super + Right Mouse` | Mijenjaj veličinu prozora |
| `Super + Scroll Wheel` | Listaj kroz radne prostore na fokusiranom monitoru |
| `Super + G`               | Prebaci grupiranje prozora      |
| `Super + Alt + G`               | Izvuci prozor iz grupiranja      |
| `Super + Alt + Tab`               | Kruži između prozora u grupi      |
| `Super + Alt + Shift + Tab`               | Kruži unatrag između prozora u grupi      |
| `Super + Alt + Scroll Wheel` | Kruži između prozora u grupi |
| `Super + Alt + 1/2/3/4/5`               | Skoči na određeni prozor u grupi      |
| `Super + Alt + Arrow`  | Premjesti prozor u grupu u smjeru strelice, uključujući onaj na monitoru na toj strani |
| `Super + Ctrl + Left/Right`  | Kreći se između prozora unutar popločane grupe |
| `Super + Ctrl + Z` | Povećaj prikaz na zaslonu (ponovi za veće povećanje) |
| `Super + Ctrl + Alt + Z` | Potpuno smanji prikaz zaslona |
| `Super + /` | Korak naprijed kroz mogućnosti skaliranja monitora |
| `Super + Alt + /` | Korak unatrag kroz mogućnosti skaliranja monitora |
| `Alt + Tab` | Kruži naprijed kroz prozore na aktivnom radnom prostoru |
| `Alt + Shift + Tab` | Kruži unatrag kroz prozore na aktivnom radnom prostoru |
| `Ctrl + Alt + Tab`| Kruži fokus naprijed kroz monitore |
| `Ctrl + Alt + Shift + Tab`| Kruži fokus unatrag kroz monitore |
| `Super + I` | Prebaci jezik unosa (s više od jednog rasporeda ili načina unosa) |
| `Super + Shift + I` | Prebaci jezik unosa natrag |

Na dodirnoj ploči povlačenja s tri i četiri prsta prebacuju radne prostore, premještaju prozore te otvaraju izbornik i Quake konzolu; geste potraži u [tipkovnica, miš i dodirna ploča](34-keyboard-mouse-trackpad.md).

Prečaci za mijenjanje veličine koriste fizičke tipke `code:20` i `code:21` (XKB `<AE11>` i `<AE12>`), bez obzira na znakove otisnute na tipkovnici. Na američkim tipkovnicama te su tipke `-` i `=`; na japanskim (JIS) tipkovnicama to su `-` i `^`; na španjolskim tipkovnicama to su `'` i `¡`. Na JIS tipkovnici `Super + ^` je `Super + Equal`, dok je `Super + Shift + -` (koji upisuje `=`) `Super + Shift + Minus`.

## Kontrole sustava

| Prečac                  | Funkcija              |
| ----------------------- | --------------------- |
| `Super + Ctrl + A`           | Ploča za zvuk    |
| `Super + Ctrl + B`           | Ploča za Bluetooth    |
| `Super + Ctrl + N`           | Ploča za Wi-Fi/mrežu    |
| `Super + Ctrl + D`           | Ploča za zaslon    |
| `Super + Ctrl + P`           | Ploča za napajanje    |
| `Super + Ctrl + X`           | Ploča za agente    |
| `Super + Ctrl + Shift + X`           | Ploča za lokalne modele    |
| `Super + Ctrl + Alt + D`           | Ploča za kalendar    |
| `Super + Ctrl + Alt + E`           | Ploča za svjetski sat    |
| `Super + Ctrl + 1-9`           | Prebaci ploču trake prema položaju    |
| `Super + Ctrl + S` | Izbornik za dijeljenje (putem LocalSend) |
| `Super + Ctrl + C` | Kontrole snimanja (snimka zaslona / snimanje / birač) |
| `Super + Ctrl + O` | Prebaci izbornik |
| `Super + Ctrl + H` | Izbornik hardvera |
| `Super + Ctrl + E` | Birač emojija |
| `Super + Ctrl + .` | Transkodiraj medije |
| `Super + Shift + Ctrl + A` | Odaberi AI agenta |
| `Power` tipka | Izbornik sustava |
| `Super + Shift + Copilot` tipka | Izbornik Omarchy |

## Prilagodbe

| Prečac                  | Funkcija              |
| ----------------------- | --------------------- |
| `Shift + Brightness Up` | Maksimalna svjetlina zaslona |
| `Shift + Brightness Down` | Minimalna svjetlina zaslona |
| `Alt + Brightness Up/Down` | Precizne promjene svjetline od 1% |
| `Alt + Volume Up/Down` | Precizne promjene glasnoće od 1% |
| `Keyboard Brightness Up/Down` | Pozadinsko osvjetljenje tipkovnice jače/slabije |
| `Keyboard Backlight` | Kruži kroz razine pozadinskog osvjetljenja tipkovnice |
| `Ctrl + Brightness Up/Down` | Pozadinsko osvjetljenje tipkovnice jače/slabije, na tipkovnicama bez vlastitih tipki |
| `Mic Mute` | Utišaj mikrofon |
| `Shift + Mute` | Prebaci izlaz zvuka |
| `Touchpad Toggle` | Uključi ili isključi dodirnu ploču |
| `Display` tipka | Kruži kroz raspored radnog prostora |
| `Alt + Play` | Sljedeća pjesma |
| `Alt + Shift + Play` | Prethodna pjesma |

## Pokretanje aplikacija

| Prečac                  | Funkcija              |
| ----------------------- | --------------------- |
| `Super + Return`           | Terminal    |
| `Super + Alt + Return` | Tmux terminal |
| `Super + Ctrl + Return` | Herdr (upravitelj agenata) |
| `Super + Shift + Return` or `Super + Shift + B`  | Preglednik    |
| `Super + Shift + Alt + B`           | Preglednik (privatno/anonimno)    |
| `Super + Shift + F`           | Upravitelj datoteka    |
| `Super + Shift + Alt + F`           | Upravitelj datoteka u cwd-u terminala    |
| `Super + Shift + M`           | Glazba (Spotify)    |
| `Super + Shift + Alt + M`           | Glazba (cliamp)    |
| `Super + Shift + /`           | Upravitelj zaporki (1password)    |
| `Super + Shift + Q` or `Calculator` tipka  | Kalkulator (Omacalc)    |
| `Super + Shift + D`           | Docker (lazydocker, nakon instalacije)    |
| `Super + Shift + T`           | Aktivnost (btop)    |
| `Super + Shift + N`           | Uređivač (Plain ili tvoj odabrani zadani)  |
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
| `Super + Shift + Alt + X`           | X (nova objava) |
| `Super + Shift + Y`           | YouTube |

Promijeni/dodaj povezivanja u `~/.config/hypr/bindings.lua`.

## Univerzalni međuspremnik

| Prečac                  | Funkcija              |
| ----------------------- | --------------------- |
| `Super + A`           | Odaberi sve u aplikacijama koje podržavaju `Ctrl + A`    |
| `Super + C`           | Kopiraj    |
| `Super + X`           | Izreži (ne u terminalu)    |
| `Super + V`           | Zalijepi    |
| `Super + Ctrl + V`           | Upravitelj međuspremnika    |

Obično na Linuxu trebaš `Ctrl + Shift + C/V` za kopiranje i lijepljenje u terminalu i `Ctrl + C/V` da to radiš svugdje drugdje. Ovi ujedinjeni prečaci međuspremnika u Omarchyju rade svugdje.

## Snimanje

| Prečac              | Funkcija                       |
| ------------------- | ------------------------------ |
| `Print Screen`            | Snimka zaslona                      |
| `Super + Ctrl + Alt + C`            | Snimka zaslona (ista snimka, za tipkovnice bez tipke Print Screen) |
| `Super + Ctrl + C` | Izbornik snimanja |
| `Alt + Print Screen`            | Snimanje zaslona                     |
| `Super + Shift + Ctrl + Alt + C` | Snimanje zaslona bez zvuka, uz preskakanje izbornika (pritisni ponovno za zaustavljanje) |
| `Super + Print Screen` | Birač boja |
| `Super + Ctrl + Print Screen` | Izdvajanje teksta u međuspremnik |
| `Super + Alt + [` | Smanji preklapanje web-kamere tijekom snimanja |
| `Super + Alt + ]` | Povećaj preklapanje web-kamere tijekom snimanja |
| `Alt + Shift + L` | Kopiraj trenutni URL iz web-aplikacije ili preglednika |
| `Alt + Shift + D` | Preuzmi videozapis na trenutnoj stranici u `~/Videos` |
| `Alt + Space` | Pokreni/zaustavi diktiranje (zahtijeva _Postavljanje > Zadane postavke > Diktiranje_) |
| `Right Alt` | Drži za diktiranje (zahtijeva _Postavljanje > Zadane postavke > Diktiranje_) |

Kod snimanja zaslona prečac najprije pita koji zvuk želiš, a zatim započinje snimanje. Pritisni ga ponovno za zaustavljanje. Pojedinosti potraži u [snimke zaslona i snimanje](12-screenshots-recording.md).

Sve mogućnosti snimanja dostupne su i pod _Okidač > Snimanje_ u izborniku Omarchy (`Super + Space`).

## Obavijesti

| Prečac                  | Funkcija              |
| ----------------------- | --------------------- |
| `Super + ,` | Djeluj na najnoviju obavijest: otvori je ili pritisni njezinu jedinu tipku, odaberi iz njezinih mogućnosti ili je odbaci kad ih nema  |
| `Super + Shift + ,` | Odbaci sve obavijesti |
| `Super + Ctrl + ,` | Upravljaj obavijestima tipkovnicom  |
| `Super + Alt + ,` | Odbaci najnoviju obavijest  |
| `Super + Shift + Alt + ,` | Otvori povijest obavijesti  |
| `Super + Ctrl + Alt + ,` | Prebaci utišavanje obavijesti  |

## Stil

| Prečac                  | Funkcija              |
| ----------------------- | --------------------- |
| `Super + Ctrl + T` | Odaberi novu temu (također `Super + Ctrl + Shift + Space`) |
| `Super + Ctrl + W` | Odaberi pozadinu teme (također `Super + Ctrl + Space`) |
| `Super + Backspace` | Prebaci prozirnost na prozoru |
| `Super + Ctrl + Backspace` | Prebaci kvadratni omjer jednog prozora |

Dodatne pozadinske slike nalaze se u `~/.config/omarchy/backgrounds/<theme name>`. Dostupno i putem _Instaliraj > Stil > Pozadina_ u izborniku Omarchy.

Sve mogućnosti stila dostupne su i pod _Izgled_ u izborniku Omarchy (`Super + Space`).

## Prebacivanja

| Prečac                  | Funkcija              |
| ----------------------- | --------------------- |
| `Super + Ctrl + I` | Prebaci zaključavanje u mirovanju |
| `Super + Ctrl + Delete` | Uključi/isključi zaslon prijenosnog računala |
| `Super + Ctrl + Alt + Delete` | Prebaci zrcaljenje zaslona prijenosnog računala |
| `Super + Shift + Space` | Prebaci gornju traku  |
| `Shift + Mute` | Prebaci na sljedeći izlaz zvuka |
| `Shift + Play` | Prebaci na sljedeći izvor medija |
| `Super + Shift + Backspace` | Prebaci razmake prozora |
| `Super + Ctrl + Alt + F` | Prebaci radnu površinu preko cijelog zaslona (gornja traka + razmaci prozora) |

## Podsjetnici

| Prečac                  | Funkcija              |
| ----------------------- | --------------------- |
| `Super + Ctrl + R` | Postavi podsjetnik  |
| `Super + Ctrl + Alt + R` | Prikaži sve podsjetnike  |
| `Super + Ctrl + Shift + R` | Obriši sve podsjetnike  |

## Napomene

| Prečac                  | Funkcija              |
| ----------------------- | --------------------- |
| `Super + Ctrl + Alt + T` | Prikaži vrijeme kao obavijest  |
| `Super + Ctrl + Alt + B` | Prikaži bateriju kao obavijest  |
| `Super + Ctrl + Alt + W` | Uključi/isključi vrijeme kao obavijest  |

## Tmux

Prefiksna tipka je `Ctrl + Space` (`Ctrl + B` također radi). Ta povezivanja možeš promijeniti u `~/.config/tmux/tmux.conf`.

### Okna

| Prečac                  | Funkcija              |
| ----------------------- | --------------------- |
| `Prefix + v` | Podijeli okno pokraj (okomito) |
| `Prefix + h` | Podijeli okno ispod (vodoravno) |
| `Prefix + x` | Ubij okno |
| `Prefix + z` | Prebaci zumiranje okna (cijeli zaslon) |
| `Alt + Enter` | Podijeli okno ispod (bez prefiksa) |
| `Alt + Shift + Enter` | Podijeli okno pokraj (bez prefiksa) |
| `Alt + Escape` | Ubij okno (bez prefiksa) |
| `Ctrl + Alt + Arrows` | Kreći se između okna |
| `Ctrl + Alt + Shift + Arrows` | Mijenjaj veličinu okna |

### Prozori

| Prečac                  | Funkcija              |
| ----------------------- | --------------------- |
| `Prefix + c` | Novi prozor |
| `Prefix + k` | Ubij prozor |
| `Prefix + r` | Preimenuj prozor |
| `Alt + 1-9` | Idi na određeni prozor |
| `Alt + Arrow Left/Right` | Kreći se između prozora |
| `Alt + Shift + Arrow Left/Right` | Premjesti prozor ulijevo/udesno |

### Sesije

| Prečac                  | Funkcija              |
| ----------------------- | --------------------- |
| `Prefix + C` | Nova sesija |
| `Prefix + K` | Ubij sesiju |
| `Prefix + R` | Preimenuj sesiju |
| `Prefix + N` | Sljedeća sesija |
| `Prefix + P` | Prethodna sesija |
| `Alt + Arrow Up/Down` | Kreći se između sesija |
| `Prefix + s` | Prikaži popis sesija |
| `Prefix + d` | Odvoji se od sesije |

### Način kopiranja (vi stil)

| Prečac                  | Funkcija              |
| ----------------------- | --------------------- |
| `Prefix + [` | Uđi u način kopiranja |
| `v` | Započni odabir (u načinu kopiranja) |
| `y` | Kopiraj odabir (u načinu kopiranja) |

### Općenito

| Prečac                  | Funkcija              |
| ----------------------- | --------------------- |
| `Prefix + q` | Ponovno učitaj konfiguraciju |
| `Prefix + ?` | Prikaži Tmux prečace na tipkovnici |
| `Prefix + :` | Naredbeni upit |

### Funkcije rasporeda za Tmux

Te se funkcije moraju pokrenuti unutar Tmux sesije.

| Naredba | Funkcija |
| ------- | -------- |
| `tdl <ai> [<second_ai>]` | Izradi razvojni raspored s uređivačem, AI-jem i terminalom |
| `tdlm <ai> [<second_ai>]` | Izradi razvojni raspored po poddirektoriju |
| `tsl <count> <command>` | Izradi raspored roja s više okna |

## Ghostty Terminal

Ghostty terminal instalira se pomoću _Instaliraj > Terminal_ putem izbornika Omarchy.

| Prečac                  | Funkcija              |
| ----------------------- | --------------------- |
| `Ctrl + Shift + E` | Nova podjela ispod |
| `Ctrl + Shift + O` | Nova podjela pokraj |
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
| `Space`               | Pregledaj datoteku (strelice za navigaciju) |
| `Alt + Up`       | Idi gore u nadređenu mapu        |

## Neovim (w/ lazyvim)

### Navigacija

| Prečac                   | Funkcija                        |
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

### Dok si u bočnoj traci

| Prečac                   | Funkcija                        |
| ------------------------ | ------------------------------- |
| `A`                        | Dodaj novu datoteku u nadređeni direktorij      |
| `Shift + A`                | Dodaj novi poddirektorij u nadređeni direktorij    |
| `D`                        | Izbriši označenu datoteku/direktorij     |
| `M`                        | Premjesti označenu datoteku/direktorij       |
| `R`                        | Preimenuj označenu datoteku/direktorij     |
| `?`                        | Prikaži pomoć za sve naredbe      |

[Pogledaj sve Neovim prečace koje konfigurira LazyVim](https://www.lazyvim.org/keymaps).

## Brzi emojiji

Možeš koristiti `Super + Ctrl + E` za prikaz potpunog birača emojija koji će odabir staviti u međuspremnik ili možeš koristiti ove mogućnosti brzog pristupa.

| Prečac       | EM | Trag       |
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
| `Shift + CapsLock M O` |👌 | u redu |
| `Shift + CapsLock M G` |👋 | pozdrav |
| `Shift + CapsLock M A` |💪 | ruka |
| `Shift + CapsLock M B` |🤯 | puhanje |

## Brza dovršavanja

| Prečac       | Dovršavanje       |
| ------------ |  ---------- |
| `Shift + CapsLock Space Space` | — (duga crtica)   |
| `Shift + CapsLock Space N` | Tvoje ime (kako je uneseno pri postavljanju)  |
| `Shift + CapsLock Space E` | Tvoja e-pošta (kako je unesena pri postavljanju)  |

Možeš dodati još svojih uređivanjem `~/.XCompose`, a zatim pokretanjem `omarchy restart xcompose` u terminalu kako bi promjene bile preuzete.
