# Tipkovnički prečaci

Sve glavne tipkovničke prečace možete vidjeti sa `Super + K` (Tmux prečace sa `Super + Alt + K` i Herdr prečace sa `Super + Ctrl + K`).

## Kako su tipkovnički prečaci organizirani

Svaki tipkovnički prečac nalazi se na jednoj ravnini, određenoj svojim modifikatorima, a svaka ravnina ima jedan posao. To sprječava da se prečaci međusobno pomiješaju i znači da obično možete pogoditi gdje se nešto nalazi.

| Ravnina | Što se tamo nalazi | Primjeri |
| --- | --- | --- |
| `Super + key` | Sustav: prozori, radni prostori, rasporedi i osnovni izbornici | `Super + Space` Omarchy izbornik, `Super + W` zatvori prozor, `Super + F` cijeli zaslon |
| `Super + Shift + key` | Aplikacije | `Super + Shift + B` preglednik, `Super + Shift + E` e-pošta, `Super + Shift + N` uređivač |
| `Super + Ctrl + key` | Ploče i izbornici sustava | `Super + Ctrl + A` zvuk, `Super + Ctrl + N` mreža, `Super + Ctrl + C` izbornik snimanja |
| `Super + Ctrl + Alt + key` | Brze akcije i obavijesti | `Super + Ctrl + Alt + T` prikaži vrijeme, `Super + Ctrl + Alt + B` baterija, `Super + Ctrl + Alt + C` snimka zaslona |

Dodavanje `Alt` tipkovničkom prečacu daje vam varijantu iste stvari, nikada nešto nepovezano:

- `Super + Shift + B` otvara preglednik; `Super + Shift + Alt + B` otvara privatni prozor
- `Super + Shift + E` otvara e-poštu; `Super + Shift + Alt + E` započinje novu
- `Super + F` ide na cijeli zaslon; `Super + Alt + F` ide na punu širinu
- `Super + Ctrl + C` otvara izbornik snimanja; `Super + Ctrl + Alt + C` preskače izbornik i snima snimku zaslona

Prilikom dodavanja tipkovničkog prečaca:

1. Odaberite ravninu prema tome što radi, zatim odaberite tipku.
2. Nemojte pomicati postojeći prečac da biste napravili mjesta. Pronađite slobodnu tipku na pravoj ravnini.
3. `Alt` koristite samo za varijantu prečaca bez njega.

Nekoliko prečaca krši ova pravila jer su praktični. `Shift` sa strelicom ili `Tab` pomiče ili obrće umjesto da otvara aplikaciju, a `Print`, medijske tipke, `Alt + Tab` i `Ctrl + Alt + Del` rade kao i svugdje drugdje. To su iznimke, a ne obrasci za kopiranje.

Ako vam zadana postavka ne odgovara (recimo da želite `Super + Shift + S` za snimke zaslona kao na Windows), ponovno je povežite u `~/.config/hypr/bindings.lua`.

## Navigacija

| Prečac                  | Funkcija              |
| ----------------------- | --------------------- |
| `Super + Space`           | Omarchy izbornik (aplikacije i sve ostalo)    |
| `Super + Alt + Space` | Mreža aplikacija |
| `Super + Escape` | Izbornik sustava (mirovanje, ponovno pokretanje itd.)  |
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
| `Super + L`               | Prođite kroz dwindle, scrolling i floating rasporede |
| `Super + Alt + L`         | Prođite kroz rasporede obrnutim redoslijedom |
| `Super + P`               | Prebaci pseudo stil prozora (prirodno naspram rastegnuto) |
| `Super + F`                 | Idi na cijeli zaslon              |
| `Super + Alt + F`                 | Idi na punu širinu              |
| `Super + Ctrl + F`                 | Idi na cijeli zaslon unutar prozora              |
| `Super + 1…9/0`         | Skoči na određeni radni prostor (0 je 10) na fokusiranom monitoru |
| `Super + Tab` | Skoči na sljedeći radni prostor na fokusiranom monitoru |
| `Super + Shift + Tab` | Skoči na prethodni radni prostor na fokusiranom monitoru |
| `Super + Ctrl + Tab` | Skoči na prijašnji radni prostor na fokusiranom monitoru |
| `Super + Shift + 1…9/0` | Premjesti prozor na radni prostor na fokusiranom monitoru |
| `Super + Shift + Alt + 1…9/0` | Premjesti prozor na radni prostor na fokusiranom monitoru bez praćenja |
| `Super + S` | Prebaci puni scratchpad |
| `Super + Alt + S` | Premjesti prozor na puni scratchpad |
| `Super + the key above Tab` (grave na američkim rasporedima) | Prebaci Quake konzolu |
| `Super + Shift + the key above Tab` (grave na američkim rasporedima) | Premjesti prozor na Quake konzolu |
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
| `Super + Left Mouse` | Povuci prozor okolo |
| `Super + Right Mouse` | Promijeni veličinu prozora |
| `Super + Scroll Wheel` | Pomičite se kroz radne prostore na fokusiranom monitoru |
| `Super + G`               | Prebaci grupiranje prozora      |
| `Super + Alt + G`               | Izvuci prozor iz grupiranja      |
| `Super + Alt + Tab`               | Kružite između prozora u grupiranju      |
| `Super + Alt + Shift + Tab`               | Kružite unatrag između prozora u grupiranju      |
| `Super + Alt + Scroll Wheel` | Kružite između prozora u grupiranju |
| `Super + Alt + 1/2/3/4/5`               | Skoči na određeni prozor u grupiranju      |
| `Super + Alt + Arrow`  | Pomakni prozor u grupiranje u smjeru strelice, uključujući onaj na monitoru s te strane |
| `Super + Ctrl + Left/Right`  | Krećite se između prozora unutar grupe popločavanja |
| `Super + Ctrl + Z` | Povećaj zaslon (ponovite za veće povećanje) |
| `Super + Ctrl + Alt + Z` | Potpuno smanji prikaz zaslona |
| `Super + /` | Korak naprijed kroz opcije skaliranja monitora |
| `Super + Alt + /` | Korak unatrag kroz opcije skaliranja monitora |
| `Alt + Tab` | Kružite naprijed kroz prozore na aktivnom radnom prostoru |
| `Alt + Shift + Tab` | Kružite unatrag kroz prozore na aktivnom radnom prostoru |
| `Ctrl + Alt + Tab`| Kružite fokus naprijed kroz monitore |
| `Ctrl + Alt + Shift + Tab`| Kružite fokus unatrag kroz monitore |
| `Super + I` | Prebaci jezik unosa (s više od jednog rasporeda ili načina unosa) |
| `Super + Shift + I` | Prebaci jezik unosa natrag |

Na dodirnoj plohi, povlačenja s tri i četiri prsta prebacuju radne prostore, pomiču prozore i otvaraju izbornik i Quake konzolu; pogledajte [tipkovnica, miš i trackpad](34-keyboard-mouse-trackpad.md) za geste.

Promjena veličine koristi dvije tipke desno od 0, što god vaša tipkovnica na njima ispisuje: `-` i `=` na američkim tipkovnicama, `+` i `´` na danskim i švedskim, `+` i `\` na norveškim, `ß` i `´` na njemačkim, `'` i `¡` na španjolskim, i `-` i `^` na japanskim (JIS). `Super + K` ih navodi kako ih vaša tipkovnica ispisuje. Na JIS-u, `Super + ^` je `Super + Equal`, dok je `Super + Shift + -` (koji upisuje `=`) `Super + Shift + Minus`. Skaliranje monitora i upravitelj lozinki koriste `/`; na rasporedima koji `/` upisuju samo sa Shift, kao većina europskih, umjesto toga koriste tipku lijevo od desnog Shift (`-` na danskim i njemačkim).

## Kontrole sustava

| Prečac                  | Funkcija              |
| ----------------------- | --------------------- |
| `Super + Ctrl + A`           | Ploča zvuka    |
| `Super + Ctrl + B`           | Bluetooth ploča    |
| `Super + Ctrl + N`           | Wifi/mrežna ploča    |
| `Super + Ctrl + D`           | Ploča zaslona    |
| `Super + Ctrl + P`           | Ploča napajanja    |
| `Super + Ctrl + X`           | Ploča agenata    |
| `Super + Ctrl + Alt + D`           | Ploča kalendara    |
| `Super + Ctrl + Alt + E`           | Ploča svjetskog sata    |
| `Super + Ctrl + 1-9`           | Prebaci ploču trake po položaju    |
| `Super + Ctrl + S` | Izbornik dijeljenja (putem LocalSend) |
| `Super + Ctrl + C` | Kontrole snimanja (snimka zaslona/-snimanje/birač) |
| `Super + Ctrl + O` | Prebaci izbornik |
| `Super + Ctrl + H` | Izbornik hardvera |
| `Super + Ctrl + E` | Birač emojija |
| `Super + Ctrl + .` | Transkodiraj medije |
| `Super + Shift + Ctrl + A` | Pokreni svog zadanog agenta |
| `Power` key | Izbornik sustava |
| `Super + Shift + Copilot` key | Omarchy izbornik |

## Prilagodbe

| Prečac                  | Funkcija              |
| ----------------------- | --------------------- |
| `Shift + Brightness Up` | Maksimalna svjetlina zaslona |
| `Shift + Brightness Down` | Minimalna svjetlina zaslona |
| `Alt + Brightness Up/Down` | Precizne promjene svjetline od 1% |
| `Alt + Volume Up/Down` | Precizne promjene glasnoće od 1% |
| `Keyboard Brightness Up/Down` | Pozadinsko osvjetljenje tipkovnice svjetlije/tamnije |
| `Keyboard Backlight` | Kružite kroz razine pozadinskog osvjetljenja tipkovnice |
| `Ctrl + Brightness Up/Down` | Pozadinsko osvjetljenje tipkovnice svjetlije/tamnije, na tipkovnicama bez vlastitih tipki |
| `Mic Mute` | Utišaj mikrofon |
| `Shift + Mute` | Prebaci izlaz zvuka |
| `Touchpad Toggle` | Uključi ili isključi dodirnu plohu |
| `Display` key | Kružite kroz raspored radnog prostora |
| `Alt + Play` | Sljedeća skladba |
| `Alt + Shift + Play` | Prethodna skladba |

## Pokretanje aplikacija

| Prečac                  | Funkcija              |
| ----------------------- | --------------------- |
| `Super + Return`           | Terminal    |
| `Super + Alt + Return` | Tmux terminal |
| `Super + Ctrl + Return` | Herdr (upravitelj agenata) |
| `Super + Shift + Return` or `Super + Shift + B`  | Preglednik    |
| `Super + Shift + Alt + B`           | Preglednik (privatno/incognito)    |
| `Super + Shift + F`           | Upravitelj datoteka    |
| `Super + Shift + Alt + F`           | Upravitelj datoteka u cwd terminala    |
| `Super + Shift + M`           | Glazba (Spotify)    |
| `Super + Shift + Alt + M`           | Glazba (cliamp)    |
| `Super + Shift + /`           | Upravitelj lozinki (1password)    |
| `Super + Shift + Q` or `Calculator` key  | Kalkulator (Omacalc)    |
| `Super + Shift + D`           | Docker (lazydocker, nakon instalacije)    |
| `Super + Shift + T`           | Aktivnost (btop)    |
| `Super + Shift + N`           | Uređivač (Plain, ili vaš odabrani zadani)  |
| `Super + Shift + C`           | Kalendar ([HEY](https://hey.com/))  |
| `Super + Shift + E`           | E-pošta ([HEY](https://hey.com/))  |
| `Super + Shift + Alt + E`           | Nova e-pošta ([HEY](https://hey.com/))  |
| `Super + Shift + A`           | Vaš zadani agent, ili ChatGPT dok ne odaberete jednog |
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

Promijenite/dodajte povezivanja u `~/.config/hypr/bindings.lua`.

## Univerzalni međuspremnik

| Prečac                  | Funkcija              |
| ----------------------- | --------------------- |
| `Super + A`           | Odaberi sve u aplikacijama koje podržavaju `Ctrl + A`    |
| `Super + C`           | Kopiraj    |
| `Super + X`           | Izreži (ne u terminalu)    |
| `Super + V`           | Zalijepi    |
| `Super + Ctrl + V`           | Upravitelj međuspremnika    |

Obično na Linuxu trebate `Ctrl + Shift + C/V` za kopiranje i lijepljenje u terminalu i `Ctrl + C/V` za to svugdje drugdje. Ovi Omarchy ujedinjeni prečaci međuspremnika rade svugdje.

## Snimanje

| Prečac              | Funkcija                       |
| ------------------- | ------------------------------ |
| `Print Screen`            | Snimka zaslona                      |
| `Super + Ctrl + Alt + C`            | Snimka zaslona (isti snimak, za tipkovnice bez tipke Print Screen) |
| `Super + Ctrl + C` | Izbornik snimanja |
| `Alt + Print Screen`            | Snimanje zaslona                     |
| `Super + Shift + Ctrl + Alt + C` | Snimanje zaslona bez zvuka, preskačući izbornik (pritisnite ponovno za zaustavljanje) |
| `Super + Print Screen` | Birač boja |
| `Super + Ctrl + Print Screen` | Izdvajanje teksta u međuspremnik |
| `Super + Alt + [` | Smanji preklapanje web-kamere tijekom snimanja |
| `Super + Alt + ]` | Povećaj preklapanje web-kamere tijekom snimanja |
| `Alt + Shift + L` | Kopiraj trenutni URL iz web-aplikacije ili preglednika |
| `Alt + Shift + D` | Preuzmi video na trenutnoj stranici u `~/Videos` |
| `Alt + Space` | Pokreni/zaustavi diktiranje (zahtijeva _Postavljanje > Zadane postavke > Diktiranje_) |
| `Right Alt` | Drži za diktiranje (zahtijeva _Postavljanje > Zadane postavke > Diktiranje_) |

Kod snimanja zaslona, prečac prvo pita koji zvuk želite, zatim započinje snimanje. Pritisnite ga ponovno za zaustavljanje. Pogledajte [snimke zaslona i snimanje](12-screenshots-recording.md) za detalje.

Sve opcije snimanja također su dostupne pod _Okidač > Snimanje_ u Omarchy izborniku (`Super + Space`).

## Obavijesti

| Prečac                  | Funkcija              |
| ----------------------- | --------------------- |
| `Super + ,` | Djeluj na najnoviju obavijest: otvori je ili pritisni njezinu jedinu tipku, odaberi iz njezinih opcija, ili je odbaci kada nema nijedne  |
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

Dodatne pozadinske slike nalaze se u `~/.config/omarchy/backgrounds/<theme name>`. Također dostupno putem _Instalacija > Stil > Pozadina_ u Omarchy izborniku.

Sve opcije stila također su dostupne pod _Izgled_ u Omarchy izborniku (`Super + Space`).

## Prebacivanja

| Prečac                  | Funkcija              |
| ----------------------- | --------------------- |
| `Super + Ctrl + I` | Prebaci zaključavanje pri mirovanju |
| `Super + Ctrl + Delete` | Prebaci zaslon prijenosnog računala uključen/isključen |
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
| `Super + Ctrl + Alt + R` | Pogledaj sve podsjetnike  |
| `Super + Ctrl + Shift + R` | Izbriši sve podsjetnike  |

## Prikazi

| Prečac                  | Funkcija              |
| ----------------------- | --------------------- |
| `Super + Ctrl + Alt + T` | Prikaži vrijeme kao obavijest  |
| `Super + Ctrl + Alt + B` | Prikaži bateriju kao obavijest  |
| `Super + Ctrl + Alt + W` | Prebaci vremenske prilike kao obavijest  |

## Tmux

Prefiksna tipka je `Ctrl + Space` (`Ctrl + B` također radi). Ova povezivanja možete promijeniti u `~/.config/tmux/tmux.conf`.

### Okna

| Prečac                  | Funkcija              |
| ----------------------- | --------------------- |
| `Prefix + v` | Podijeli okno pokraj (okomito) |
| `Prefix + h` | Podijeli okno ispod (vodoravno) |
| `Prefix + x` | Zatvori okno |
| `Prefix + z` | Prebaci zumiranje okna (cijeli zaslon) |
| `Alt + Enter` | Podijeli okno ispod (bez prefiksa) |
| `Alt + Shift + Enter` | Podijeli okno pokraj (bez prefiksa) |
| `Alt + Escape` | Zatvori okno (bez prefiksa) |
| `Ctrl + Alt + Arrows` | Krećite se između okna |
| `Ctrl + Alt + Shift + Arrows` | Promijeni veličinu okna |

### Prozori

| Prečac                  | Funkcija              |
| ----------------------- | --------------------- |
| `Prefix + c` | Novi prozor |
| `Prefix + k` | Zatvori prozor |
| `Prefix + r` | Preimenuj prozor |
| `Alt + 1-9` | Idi na određeni prozor |
| `Alt + Arrow Left/Right` | Krećite se između prozora |
| `Alt + Shift + Arrow Left/Right` | Pomakni prozor lijevo/desno |

### Sesije

| Prečac                  | Funkcija              |
| ----------------------- | --------------------- |
| `Prefix + C` | Nova sesija |
| `Prefix + K` | Zatvori sesiju |
| `Prefix + R` | Preimenuj sesiju |
| `Prefix + N` | Sljedeća sesija |
| `Prefix + P` | Prethodna sesija |
| `Alt + Arrow Up/Down` | Krećite se između sesija |
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
| `Prefix + :` | Naredbeni upit |

### Tmux funkcije rasporeda

Ove funkcije moraju se pokrenuti unutar Tmux sesije.

| Naredba | Funkcija |
| ------- | -------- |
| `tdl <ai> [<second_ai>]` | Stvori razvojni raspored s uređivačem, AI-jem i terminalom |
| `tdlm <ai> [<second_ai>]` | Stvori razvojni raspored po poddirektoriju |
| `tsl <count> <command>` | Stvori swarm raspored s više okna |

## Ghostty Terminal

Ghostty terminal instalira se pomoću _Instalacija > Terminal_ putem Omarchy izbornika.

| Prečac                  | Funkcija              |
| ----------------------- | --------------------- |
| `Ctrl + Shift + E` | Nova podjela ispod |
| `Ctrl + Shift + O` | Nova podjela pokraj |
| `Ctrl + Alt + Arrows` | Krećite se između podjela |
| `Super + Ctrl + Shift + Arrows` | Promijeni veličinu podjele za 10 redaka |
| `Super + Ctrl + Shift + Alt + Arrows` | Promijeni veličinu podjele za 100 redaka |
| `Ctrl + Shift + T` | Nova kartica  |
| `Ctrl + Shift + Arrows` | Krećite se između kartica |
| `Alt + Numbers` | Idi na određenu karticu |
| `Shift + Pg Up/Down` | Pomičite se kroz povijest |
| `Ctrl + Left mouse` | Otvori poveznicu u pregledniku |

## Upravitelj datoteka

| Prečac              | Funkcija                       |
| ------------------- | ------------------------------ |
| `Ctrl + L`            | Idi na putanju                     |
| `Space`               | Pregledaj datoteku (strelice navigiraju) |
| `Alt + Up`       | Idi gore u nadređenu mapu        |

## Neovim (s lazyvim)

### Navigacija

| Prečac                   | Funkcija                        |
| ------------------------ | ------------------------------- |
| `Space`                    | Prikaži opcije naredbi            |
| `Space Space`              | Otvori datoteku putem fuzzy pretraživanja      |
| `Space E`                  | Prebaci bočnu traku                  |
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
| `D`                        | Izbriši istaknutu datoteku/direktorij     |
| `M`                        | Premjesti istaknutu datoteku/direktorij       |
| `R`                        | Preimenuj istaknutu datoteku/direktorij     |
| `?`                        | Prikaži pomoć za sve naredbe      |

[Pogledajte sve Neovim prečace koje konfigurira LazyVim](https://www.lazyvim.org/keymaps).

## Brzi emojiji

Možete koristiti `Super + Ctrl + E` za prikaz potpunog birača emojija koji će odabir staviti u međuspremnik ili možete koristiti ove opcije brzog pristupa.

| Prečac       | EM | Trag       |
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
| `Shift + CapsLock M B` |🤯 | zapanjen |

## Brza dovršavanja

| Prečac       | Dovršavanje       |
| ------------ |  ---------- |
| `Shift + CapsLock Space Space` | — (mdash)   |
| `Shift + CapsLock Space N` | Vaše ime (kako je uneseno pri postavljanju)  |
| `Shift + CapsLock Space E` | Vaša e-pošta (kako je unesena pri postavljanju)  |

Možete dodati još svojih uređivanjem `~/.XCompose`, zatim pokretanjem `omarchy restart xcompose` u terminalu da se promjene preuzmu.
