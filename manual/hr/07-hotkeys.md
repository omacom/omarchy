# Tipkovničke prečice

Sve glavne tipkovničke prečice možete vidjeti pomoću `Super + K` (Tmux prečice pomoću `Super + Alt + K`, a Herdr prečice pomoću `Super + Ctrl + K`).

## Kako su prečice raspoređene

Svaka prečica sjedi na ravnini koju određuju njezini modifikatori, a svaka ravnina ima jedan posao. To sprječava da se prečice međusobno zamute i znači da obično možete pogoditi gdje nešto živi.

| Ravnina | Što tamo živi | Primjeri |
| --- | --- | --- |
| `Super + key` | Sustav: prozori, radni prostori, rasporedi i osnovni izbornici | `Super + Space` Omarchy izbornik, `Super + W` zatvori prozor, `Super + F` cijeli zaslon |
| `Super + Shift + key` | Aplikacije | `Super + Shift + B` preglednik, `Super + Shift + E` e-pošta, `Super + Shift + N` uređivač |
| `Super + Ctrl + key` | Ploče i izbornici sustava | `Super + Ctrl + A` zvuk, `Super + Ctrl + N` mreža, `Super + Ctrl + C` izbornik za snimanje |
| `Super + Ctrl + Alt + key` | Brze radnje i obavijesti | `Super + Ctrl + Alt + T` prikaži vrijeme, `Super + Ctrl + Alt + B` baterija, `Super + Ctrl + Alt + C` snimka zaslona |

Dodavanje `Alt` prečici daje vam varijantu iste stvari, nikad nešto nepovezano:

- `Super + Shift + B` otvara preglednik; `Super + Shift + Alt + B` otvara privatni prozor
- `Super + Shift + E` otvara e-poštu; `Super + Shift + Alt + E` započinje novu
- `Super + F` prikazuje na cijelom zaslonu; `Super + Alt + F` prikazuje na cijeloj širini
- `Super + Ctrl + C` otvara izbornik za snimanje; `Super + Ctrl + Alt + C` preskače izbornik i snima snimku zaslona

Pri dodavanju prečice:

1. Odaberite ravninu prema tome što radi, zatim odaberite tipku.
2. Nemojte pomicati postojeću prečicu da biste napravili mjesta. Pronađite slobodnu tipku na pravoj ravnini.
3. Koristite `Alt` samo za varijantu prečice bez njega.

Nekoliko prečica krši ova pravila jer su praktične. `Shift` sa strelicom ili `Tab` pomiče ili obrće umjesto da otvara aplikaciju, a `Print`, medijske tipke, `Alt + Tab` i `Ctrl + Alt + Del` rade onako kako rade posvuda drugdje. To su iznimke, a ne obrasci za kopiranje.

Ako vam zadana postavka ne odgovara (recimo da želite `Super + Shift + S` za snimke zaslona kao na Windowsu), ponovno je povežite u `~/.config/hypr/bindings.lua`.

## Navigacija

| Prečica                  | Funkcija              |
| ----------------------- | --------------------- |
| `Super + Space`           | Omarchy izbornik (aplikacije i sve ostalo)    |
| `Super + Alt + Space` | Mreža aplikacija |
| `Super + Escape` | Izbornik sustava (obustava, ponovno pokretanje itd.)  |
| `Super + Ctrl + L` | Zaključaj računalo |
| `Super + W` ili `Super + Q` | Zatvori prozor             |
| `Ctrl + Alt + Del` | Zatvori sve prozore |
| `Super + T`               | Prebaci prozor između slaganja u pločice i plutanja             |
| `Super + J` | Prebaci položaj prozora (vodoravno/okomito) |
| `Super + O`               | Uključi/isključi prebacivanje prozora koji iskače u sticky'n'floating način |
| `Super + L`               | Prođi kroz rasporede dwindle, scrolling i floating |
| `Super + Alt + L`         | Prođi kroz rasporede obrnutim redoslijedom |
| `Super + P`               | Prebaci pseudo stil prozora (prirodno naspram rastegnuto) |
| `Super + F`                 | Prikaži na cijelom zaslonu              |
| `Super + Alt + F`                 | Prikaži na cijeloj širini              |
| `Super + Ctrl + F`                 | Prikaži na cijelom zaslonu unutar prozora              |
| `Super + 1/2/3/4`         | Skoči na određeni radni prostor na fokusiranom monitoru |
| `Super + Tab` | Skoči na sljedeći radni prostor na fokusiranom monitoru |
| `Super + Shift + Tab` | Skoči na prethodni radni prostor na fokusiranom monitoru |
| `Super + Ctrl + Tab` | Skoči na prijašnji radni prostor na fokusiranom monitoru |
| `Super + Shift + 1/2/3/4` | Premjesti prozor na radni prostor na fokusiranom monitoru |
| `Super + Shift + Alt + 1/2/3/4` | Premjesti prozor na radni prostor na fokusiranom monitoru bez praćenja |
| `Super + S` | Uključi/isključi puni scratchpad |
| `Super + Alt + S` | Premjesti prozor na puni scratchpad |
| `Super + Grave` | Uključi/isključi Quake konzolu |
| `Super + Shift + Grave` | Premjesti prozor na Quake konzolu |
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
| `Super + Scroll Wheel` | Listaj kroz radne prostore na fokusiranom monitoru |
| `Super + G`               | Uključi/isključi grupiranje prozora      |
| `Super + Alt + G`               | Premjesti prozor izvan grupiranja      |
| `Super + Alt + Tab`               | Prođi kroz prozore u grupi      |
| `Super + Alt + Shift + Tab`               | Prođi unatrag kroz prozore u grupi      |
| `Super + Alt + Scroll Wheel` | Prođi kroz prozore u grupi |
| `Super + Alt + 1/2/3/4/5`               | Skoči na određeni prozor u grupi      |
| `Super + Alt + Arrow`  | Premjesti prozor u grupu u smjeru strelice, uključujući onaj na monitoru s te strane |
| `Super + Ctrl + Left/Right`  | Kreći se između prozora unutar grupe za slaganje u pločice |
| `Super + Ctrl + Z` | Zumiraj zaslon (ponovi za veće zumiranje) |
| `Super + Ctrl + Alt + Z` | Potpuno odzumiraj zaslon |
| `Super + /` | Korak naprijed kroz mogućnosti skaliranja monitora |
| `Super + Alt + /` | Korak unatrag kroz mogućnosti skaliranja monitora |
| `Alt + Tab` | Prođi naprijed kroz prozore na aktivnom radnom prostoru |
| `Alt + Shift + Tab` | Prođi unatrag kroz prozore na aktivnom radnom prostoru |
| `Ctrl + Alt + Tab`| Prođi fokus naprijed kroz monitore |
| `Ctrl + Alt + Shift + Tab`| Prođi fokus unatrag kroz monitore |

Prečice za mijenjanje veličine koriste fizičke tipke `code:20` i `code:21` (XKB `<AE11>` i `<AE12>`), bez obzira na znakove otisnute na tipkovnici. Na američkim tipkovnicama te su tipke `-` i `=`; na japanskim (JIS) tipkovnicama to su `-` i `^`; na španjolskim tipkovnicama to su `'` i `¡`. Na JIS-u je `Super + ^` jednako `Super + Equal`, dok je `Super + Shift + -` (koje upisuje `=`) jednako `Super + Shift + Minus`.

## Kontrole sustava

| Prečica                  | Funkcija              |
| ----------------------- | --------------------- |
| `Super + Ctrl + A`           | Ploča za zvuk    |
| `Super + Ctrl + B`           | Ploča za Bluetooth    |
| `Super + Ctrl + N`           | Ploča za Wi-Fi/mrežu    |
| `Super + Ctrl + D`           | Ploča za zaslon    |
| `Super + Ctrl + P`           | Ploča za napajanje    |
| `Super + Ctrl + Alt + D`           | Ploča za kalendar    |
| `Super + Ctrl + Alt + E`           | Ploča za svjetski sat    |
| `Super + Ctrl + 1-9`           | Uključi/isključi ploču trake prema položaju    |
| `Super + Ctrl + S` | Izbornik za dijeljenje (putem LocalSend) |
| `Super + Ctrl + C` | Kontrole za snimanje (snimka zaslona/-snimanje/birač) |
| `Super + Ctrl + O` | Izbornik prekidača |
| `Super + Ctrl + H` | Izbornik hardvera |
| `Super + Ctrl + E` | Birač emojija |
| `Super + Ctrl + .` | Transkodiraj medije |
| `Super + Shift + Ctrl + A` | Odaberi AI agenta |

## Prilagodbe

| Prečica                  | Funkcija              |
| ----------------------- | --------------------- |
| `Shift + Brightness Up` | Maksimalna svjetlina zaslona |
| `Shift + Brightness Down` | Minimalna svjetlina zaslona |
| `Alt + Brightness Up/Down` | Precizne promjene svjetline od 1% |
| `Alt + Volume Up/Down` | Precizne promjene glasnoće od 1% |
| `Keyboard Brightness Up/Down` | Pozadinsko osvjetljenje tipkovnice svjetlije/tamnije |
| `Keyboard Backlight` | Prođi kroz razine pozadinskog osvjetljenja tipkovnice |
| `Alt + Play` | Sljedeća pjesma |
| `Alt + Shift + Play` | Prethodna pjesma |

## Pokretanje aplikacija

| Prečica                  | Funkcija              |
| ----------------------- | --------------------- |
| `Super + Return`           | Terminal    |
| `Super + Alt + Return` | Tmux terminal |
| `Super + Ctrl + Return` | Herdr (upravitelj agenata) |
| `Super + Shift + Return`           | Preglednik    |
| `Super + Shift + Alt + B`           | Preglednik (privatno/anonimno)    |
| `Super + Shift + F`           | Upravitelj datoteka    |
| `Super + Shift + Alt + F`           | Upravitelj datoteka u cwd terminala    |
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
| `Super + Shift + G`           | Aplikacija za razmjenu poruka (Signal)  |
| `Super + Shift + P`           | Google Photos  |
| `Super + Shift + S`           | Google Maps  |
| `Super + Shift + Alt + G`           | Aplikacija za razmjenu poruka (WhatsApp)  |
| `Super + Shift + Ctrl + G`           | Aplikacija za razmjenu poruka (Google)  |
| `Super + Shift + O`           | Obsidian  |
| `Super + Shift + W`           | Pisanje (Omawrite)  |
| `Super + Shift + X`           | X |
| `Super + Shift + Alt + X`           | X Compose |
| `Super + Shift + Y`           | YouTube |

Promijenite/dodajte povezivanja u `~/.config/hypr/bindings.lua`.

## Univerzalni međuspremnik

| Prečica                  | Funkcija              |
| ----------------------- | --------------------- |
| `Super + A`           | Odaberi sve u aplikacijama koje podržavaju `Ctrl + A`    |
| `Super + C`           | Kopiraj    |
| `Super + X`           | Izreži (ne u terminalu)    |
| `Super + V`           | Zalijepi    |
| `Super + Ctrl + V`           | Upravitelj međuspremnika    |

Obično na Linuxu trebate `Ctrl + Shift + C/V` za kopiranje i lijepljenje u terminalu i `Ctrl + C/V` da to radite svugdje drugdje. Ove ujedinjene Omarchy prečice za međuspremnik rade svugdje.

## Snimanje

| Prečica              | Funkcija                       |
| ------------------- | ------------------------------ |
| `Print Screen`            | Snimka zaslona                      |
| `Super + Ctrl + Alt + C`            | Snimka zaslona (ista snimka, za tipkovnice bez tipke Print Screen) |
| `Super + Ctrl + C` | Izbornik za snimanje |
| `Alt + Print Screen`            | Snimanje zaslona                     |
| `Super + Print Screen` | Birač boja |
| `Super + Ctrl + Print Screen` | Izdvajanje teksta u međuspremnik |
| `Super + Alt + [` | Smanji preklapanje web-kamere tijekom snimanja |
| `Super + Alt + ]` | Povećaj preklapanje web-kamere tijekom snimanja |
| `Alt + Shift + L` | Kopiraj trenutni URL iz web-aplikacije ili Chromium |
| `Alt + Shift + D` | Preuzmi videozapis na trenutnoj stranici u `~/Videos` |
| `Alt + Space` | Pokreni/zaustavi diktiranje (zahtijeva _Postavljanje > Zadane postavke > Diktiranje_) |
| `Right Alt` | Drži za diktiranje (zahtijeva _Postavljanje > Zadane postavke > Diktiranje_) |

Kod snimanja zaslona prečica prvo pita koji zvuk želite, a zatim započinje snimanje. Pritisnite je ponovno za zaustavljanje. Pogledajte [snimke zaslona i snimanje](12-screenshots-recording.md) za detalje.

Svim mogućnostima snimanja možete pristupiti i pod _Okidač > Snimanje_ u Omarchy izborniku (`Super + Space`).

## Obavijesti

| Prečica                  | Funkcija              |
| ----------------------- | --------------------- |
| `Super + ,` | Djeluj na najnoviju obavijest: otvori je ili pritisni njezinu jedinu tipku, odaberi među njezinim izborima ili je odbaci kada nema nijedan  |
| `Super + Shift + ,` | Odbaci sve obavijesti |
| `Super + Ctrl + ,` | Upravljaj obavijestima tipkovnicom  |
| `Super + Alt + ,` | Odbaci najnoviju obavijest  |
| `Super + Shift + Alt + ,` | Otvori povijest obavijesti  |
| `Super + Ctrl + Alt + ,` | Uključi/isključi utišavanje obavijesti  |

## Stil

| Prečica                  | Funkcija              |
| ----------------------- | --------------------- |
| `Super + Ctrl + T` | Odaberi novu temu (također `Super + Ctrl + Shift + Space`) |
| `Super + Ctrl + W` | Odaberi pozadinu teme (također `Super + Ctrl + Space`) |
| `Super + Backspace` | Uključi/isključi prozirnost na prozoru |
| `Super + Ctrl + Backspace` | Uključi/isključi kvadratni omjer za jedan prozor |

Dodatne pozadinske slike nalaze se u `~/.config/omarchy/backgrounds/<theme name>`. Dostupno i putem _Instalacija > Stil > Pozadina_ u Omarchy izborniku.

Svim mogućnostima stila možete pristupiti i pod _Stil_ u Omarchy izborniku (`Super + Space`).

## Prekidači

| Prečica                  | Funkcija              |
| ----------------------- | --------------------- |
| `Super + Ctrl + I` | Uključi/isključi zaključavanje u mirovanju |
| `Super + Ctrl + Delete` | Uključi/isključi zaslon prijenosnog računala |
| `Super + Ctrl + Alt + Delete` | Uključi/isključi zrcaljenje zaslona prijenosnog računala |
| `Super + Shift + Space` | Uključi/isključi gornju traku  |
| `Shift + Mute` | Prebaci na sljedeći zvučni izlaz |
| `Shift + Play` | Prebaci na sljedeći izvor medija |
| `Super + Shift + Backspace` | Uključi/isključi razmake među prozorima |
| `Super + Ctrl + Alt + F` | Uključi/isključi radnu površinu na cijelom zaslonu (gornja traka + razmaci među prozorima) |

## Podsjetnici

| Prečica                  | Funkcija              |
| ----------------------- | --------------------- |
| `Super + Ctrl + R` | Postavi podsjetnik  |
| `Super + Ctrl + Alt + R` | Pogledaj sve podsjetnike  |
| `Super + Ctrl + Shift + R` | Obriši sve podsjetnike  |

## Kratke obavijesti

| Prečica                  | Funkcija              |
| ----------------------- | --------------------- |
| `Super + Ctrl + Alt + T` | Prikaži vrijeme kao obavijest  |
| `Super + Ctrl + Alt + B` | Prikaži bateriju kao obavijest  |
| `Super + Ctrl + Alt + W` | Uključi/isključi vremensku prognozu kao obavijest  |

## Tmux

Prefiksna tipka je `Ctrl + Space` (`Ctrl + B` također radi). Ta povezivanja možete promijeniti u `~/.config/tmux/tmux.conf`.

### Okna

| Prečica                  | Funkcija              |
| ----------------------- | --------------------- |
| `Prefix + v` | Podijeli okno bočno (okomito) |
| `Prefix + h` | Podijeli okno ispod (vodoravno) |
| `Prefix + x` | Ubij okno |
| `Prefix + z` | Uključi/isključi zumiranje okna (cijeli zaslon) |
| `Alt + Enter` | Podijeli okno ispod (bez prefiksa) |
| `Alt + Shift + Enter` | Podijeli okno bočno (bez prefiksa) |
| `Alt + Escape` | Ubij okno (bez prefiksa) |
| `Ctrl + Alt + Arrows` | Kreći se između okana |
| `Ctrl + Alt + Shift + Arrows` | Promijeni veličinu okana |

### Prozori

| Prečica                  | Funkcija              |
| ----------------------- | --------------------- |
| `Prefix + c` | Novi prozor |
| `Prefix + k` | Ubij prozor |
| `Prefix + r` | Preimenuj prozor |
| `Alt + 1-9` | Idi na određeni prozor |
| `Alt + Arrow Left/Right` | Kreći se između prozora |
| `Alt + Shift + Arrow Left/Right` | Premjesti prozor lijevo/desno |

### Sesije

| Prečica                  | Funkcija              |
| ----------------------- | --------------------- |
| `Prefix + C` | Nova sesija |
| `Prefix + K` | Ubij sesiju |
| `Prefix + R` | Preimenuj sesiju |
| `Prefix + N` | Sljedeća sesija |
| `Prefix + P` | Prethodna sesija |
| `Alt + Arrow Up/Down` | Kreći se između sesija |
| `Prefix + s` | Prikaži popis sesija |
| `Prefix + d` | Odvoji se od sesije |

### Način kopiranja (u stilu vi)

| Prečica                  | Funkcija              |
| ----------------------- | --------------------- |
| `Prefix + [` | Uđi u način kopiranja |
| `v` | Započni odabir (u načinu kopiranja) |
| `y` | Kopiraj odabir (u načinu kopiranja) |

### Općenito

| Prečica                  | Funkcija              |
| ----------------------- | --------------------- |
| `Prefix + q` | Ponovno učitaj konfiguraciju |
| `Prefix + ?` | Prikaži Tmux povezivanja tipki |
| `Prefix + :` | Naredbeni redak |

### Funkcije Tmux rasporeda

Te se funkcije moraju pokrenuti unutar Tmux sesije.

| Naredba | Funkcija |
| ------- | -------- |
| `tdl <ai> [<second_ai>]` | Stvori razvojni raspored s uređivačem, AI i terminalom |
| `tdlm <ai> [<second_ai>]` | Stvori razvojni raspored po poddirektoriju |
| `tsl <count> <command>` | Stvori raspored roja s više okana |

## Ghostty terminal

Ghostty terminal instalirate pomoću _Instalacija > Terminal_ u Omarchy izborniku.

| Prečica                  | Funkcija              |
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

| Prečica              | Funkcija                       |
| ------------------- | ------------------------------ |
| `Ctrl + L`            | Idi na putanju                     |
| `Space`               | Pregledaj datoteku (strelice za navigaciju) |
| `Alt + Up`       | Idi gore u nadređenu mapu        |

## Neovim (s lazyvim)

### Navigacija

| Prečica                   | Funkcija                        |
| ------------------------ | ------------------------------- |
| `Space`                    | Prikaži mogućnosti naredbi            |
| `Space Space`              | Otvori datoteku putem neizrazitog pretraživanja      |
| `Space E`                  | Uključi/isključi bočnu traku                  |
| `Space G G`                | Prikaži git kontrole               |
| `Space S G`                | Pretraži sadržaj datoteke             |
| `Ctrl + W W`               | Skači između bočne trake i uređivača |
| `Ctrl + Left/right arrow`  | Promijeni veličinu bočne trake          |
| `Shift + H`                      | Idi na lijevu karticu datoteke             |
| `Shift + L`                      | Idi na desnu karticu datoteke            |
| `Space B D`                | Zatvori karticu datoteke                  |

### Dok ste u bočnoj traci

| Prečica                   | Funkcija                        |
| ------------------------ | ------------------------------- |
| `A`                        | Dodaj novu datoteku u nadređeni direktorij      |
| `Shift + A`                | Dodaj novi poddirektorij u nadređeni direktorij    |
| `D`                        | Izbriši označenu datoteku/direktorij     |
| `M`                        | Premjesti označenu datoteku/direktorij       |
| `R`                        | Preimenuj označenu datoteku/direktorij     |
| `?`                        | Prikaži pomoć za sve naredbe      |

[Pogledajte sve prečice za Neovim koje je konfigurirao LazyVim](https://www.lazyvim.org/keymaps).

## Brzi emojiji

Možete koristiti `Super + Ctrl + E` za prikaz potpunog birača emojija koji će odabir staviti u međuspremnik ili možete koristiti ove mogućnosti brzog pristupa.

| Prečica       | EM | Trag       |
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
| `Shift + CapsLock M P` | 🙏 | molitva |
| `Shift + CapsLock M D` | 🤤 | slinjenje      |
| `Shift + CapsLock M M` | 💰 | novac      |
| `Shift + CapsLock M X` | 🎉 | x-proslava |
| `Shift + CapsLock M 1` | 💯 | 100%       |
| `Shift + CapsLock M T` | 🥂 | zdravica      |
| `Shift + CapsLock M O` |👌 | ok |
| `Shift + CapsLock M G` |👋 | pozdrav |
| `Shift + CapsLock M A` |💪 | ruka |
| `Shift + CapsLock M B` |🤯 | šok |

## Brza dovršavanja

| Prečica       | Dovršavanje       |
| ------------ |  ---------- |
| `Shift + CapsLock Space Space` | — (duga crtica)   |
| `Shift + CapsLock Space N` | Vaše ime (kako je uneseno pri postavljanju)  |
| `Shift + CapsLock Space E` | Vaša e-pošta (kako je unesena pri postavljanju)  |

Možete dodati još vlastitih uređivanjem `~/.XCompose`, zatim pokretanjem `omarchy-restart-xcompose` u terminalu kako bi se promjene preuzele.
