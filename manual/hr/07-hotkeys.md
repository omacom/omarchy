# Tipkovni prečaci

Sve glavne tipkovne povezice možete vidjeti sa `Super + K` (Tmux povezice sa `Super + Alt + K` i Herdr povezice sa `Super + Ctrl + K`).

## Kako su tipkovni prečaci raspoređeni

Svaki tipkovni prečac sjedi na jednoj razini, određenoj svojim modifikatorima, i svaka razina ima jedan posao. To je ono što sprječava da se tipkovni prečaci zamute jedni u druge i znači da obično možete pogoditi gdje nešto živi.

| Razina | Što tamo živi | Primjeri |
| --- | --- | --- |
| `Super + key` | Sustav: prozori, radni prostori, rasporedi i temeljni izbornici | `Super + Space` Omarchy izbornik, `Super + W` zatvori prozor, `Super + F` cijeli zaslon |
| `Super + Shift + key` | Aplikacije | `Super + Shift + B` preglednik, `Super + Shift + E` e-pošta, `Super + Shift + N` uređivač |
| `Super + Ctrl + key` | Paneli i izbornici sustava | `Super + Ctrl + A` zvuk, `Super + Ctrl + N` mreža, `Super + Ctrl + C` izbornik za snimanje |
| `Super + Ctrl + Alt + key` | Brze radnje i napomene | `Super + Ctrl + Alt + T` prikaži vrijeme, `Super + Ctrl + Alt + B` baterija, `Super + Ctrl + Alt + C` snimka zaslona |

Dodavanje `Alt` tipkovnom prečacu daje vam varijantu iste stvari, nikad nešto nepovezano:

- `Super + Shift + B` otvara preglednik; `Super + Shift + Alt + B` otvara privatni prozor
- `Super + Shift + E` otvara e-poštu; `Super + Shift + Alt + E` započinje novu
- `Super + F` prelazi na cijeli zaslon; `Super + Alt + F` prelazi na punu širinu
- `Super + Ctrl + C` otvara izbornik za snimanje; `Super + Ctrl + Alt + C` preskače izbornik i pravi snimku zaslona

Prilikom dodavanja tipkovnog prečaca:

1. Odaberite razinu prema onome što radi, a zatim odaberite tipku.
2. Nemojte pomicati postojeći tipkovni prečac da biste napravili mjesta. Pronađite slobodnu tipku na pravoj razini.
3. Koristite `Alt` samo za varijantu tipkovnog prečaca bez njega.

Nekoliko tipkovnih prečaca krši ova pravila jer su praktični. `Shift` sa strelicom ili `Tab` pomiče ili obrće umjesto da otvara aplikaciju, a `Print`, medijske tipke, `Alt + Tab` i `Ctrl + Alt + Del` rade onako kako rade svugdje drugdje. To su iznimke, a ne obrasci za kopiranje.

Ako vam zadana postavka ne odgovara (recimo da želite `Super + Shift + S` za snimke zaslona kao na Windowsu), ponovno je povežite u `~/.config/hypr/bindings.lua`.

## Navigacija

| Tipkovni prečac                  | Funkcija              |
| ----------------------- | --------------------- |
| `Super + Space`           | Omarchy izbornik (aplikacije i sve ostalo)    |
| `Super + Alt + Space` | Mreža aplikacija |
| `Super + Escape` | Izbornik sustava (obustava, ponovno pokretanje itd.)  |
| `Super + Ctrl + L` | Zaključaj računalo |
| `Super + W` or `Super + Q` | Zatvori prozor             |
| `Ctrl + Alt + Del` | Zatvori sve prozore |
| `Super + K` | Prikaži sve tipkovne prečace |
| `Super + Alt + K` | Prikaži tmux tipkovne prečace |
| `Super + Ctrl + K` | Prikaži herdr tipkovne prečace |
| `Super + M` | Minimiziraj prozor na dock |
| `Super + T`               | Prebaci prozor između popločanog i plutajućeg načina             |
| `Super + J` | Prebaci položaj prozora (vodoravno/okomito) |
| `Super + O`               | Prebaci iskakanje prozora u sticky'n'floating |
| `Super + L`               | Kruži kroz dwindle, scrolling i floating rasporede |
| `Super + Alt + L`         | Kruži kroz rasporede unatrag |
| `Super + P`               | Prebaci pseudo stil prozora (prirodan naspram rastegnutog) |
| `Super + F`                 | Prijeđi na cijeli zaslon              |
| `Super + Alt + F`                 | Prijeđi na punu širinu              |
| `Super + Ctrl + F`                 | Prijeđi na cijeli zaslon unutar prozora              |
| `Super + 1…9/0`         | Skoči na određeni radni prostor (0 je 10) na monitoru u fokusu |
| `Super + Tab` | Skoči na sljedeći radni prostor na monitoru u fokusu |
| `Super + Shift + Tab` | Skoči na prethodni radni prostor na monitoru u fokusu |
| `Super + Ctrl + Tab` | Skoči na prijašnji radni prostor na monitoru u fokusu |
| `Super + Shift + 1…9/0` | Premjesti prozor na radni prostor na monitoru u fokusu |
| `Super + Shift + Alt + 1…9/0` | Premjesti prozor na radni prostor na monitoru u fokusu bez praćenja |
| `Super + S` | Prebaci cijeli scratchpad |
| `Super + Alt + S` | Premjesti prozor na cijeli scratchpad |
| `Super + the key above Tab` (grave na američkim rasporedima) | Prebaci Quake konzolu |
| `Super + Shift + the key above Tab` (grave na američkim rasporedima) | Premjesti prozor na Quake konzolu |
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
| `Super + Left Mouse` | Vuci prozor uokolo |
| `Super + Right Mouse` | Mijenjaj veličinu prozora |
| `Super + Scroll Wheel` | Listaj kroz radne prostore na monitoru u fokusu |
| `Super + G`               | Prebaci grupiranje prozora      |
| `Super + Alt + G`               | Izvuci prozor iz grupiranja      |
| `Super + Alt + Tab`               | Kruži između prozora u grupi      |
| `Super + Alt + Shift + Tab`               | Kruži unatrag između prozora u grupi      |
| `Super + Alt + Scroll Wheel` | Kruži između prozora u grupi |
| `Super + Alt + 1/2/3/4/5`               | Skoči na određeni prozor u grupi      |
| `Super + Alt + Arrow`  | Premjesti prozor u grupu u smjeru strelice, uključujući onaj na monitoru s te strane |
| `Super + Ctrl + Left/Right`  | Kreći se između prozora unutar grupe u pločicama |
| `Super + Ctrl + Z` | Povećaj zum na zaslonu (ponovite za veći zum) |
| `Super + Ctrl + Alt + Z` | Potpuno smanji zum sa zaslona |
| `Super + /` | Korak naprijed kroz opcije skaliranja monitora |
| `Super + Alt + /` | Korak unatrag kroz opcije skaliranja monitora |
| `Alt + Tab` | Kruži naprijed kroz prozore na aktivnom radnom prostoru |
| `Alt + Shift + Tab` | Kruži unatrag kroz prozore na aktivnom radnom prostoru |
| `Ctrl + Alt + Tab`| Kruži fokus naprijed kroz monitore |
| `Ctrl + Alt + Shift + Tab`| Kruži fokus unatrag kroz monitore |
| `Super + I` | Promijeni jezik unosa (s više od jednog rasporeda ili metode unosa) |
| `Super + Shift + I` | Vrati prethodni jezik unosa |

Na dodirnoj ploči, povlačenja s tri i četiri prsta mijenjaju radne prostore, pomiču prozore te otvaraju izbornik i Quake konzolu; pogledajte [tipkovnica, miš i trackpad](34-keyboard-mouse-trackpad.md) za geste.

Prečaci za mijenjanje veličine koriste fizičke tipke `code:20` i `code:21` (XKB `<AE11>` i `<AE12>`), bez obzira na znakove otisnute na tipkovnici. Na američkim tipkovnicama te su tipke `-` i `=`; na japanskim (JIS) tipkovnicama to su `-` i `^`; na španjolskim tipkovnicama to su `'` i `¡`. Na JIS-u je `Super + ^` jednako `Super + Equal`, dok je `Super + Shift + -` (koje upisuje `=`) jednako `Super + Shift + Minus`.

## Kontrole sustava

| Tipkovni prečac                  | Funkcija              |
| ----------------------- | --------------------- |
| `Super + Ctrl + A`           | Panel za zvuk    |
| `Super + Ctrl + B`           | Bluetooth panel    |
| `Super + Ctrl + N`           | Wi-Fi/mrežni panel    |
| `Super + Ctrl + D`           | Panel za zaslon    |
| `Super + Ctrl + P`           | Panel za napajanje    |
| `Super + Ctrl + X`           | Panel za agente    |
| `Super + Ctrl + Alt + X`           | Panel za lokalne modele    |
| `Super + Ctrl + Alt + D`           | Panel za kalendar    |
| `Super + Ctrl + Alt + E`           | Panel za svjetski sat    |
| `Super + Ctrl + 1-9`           | Prebaci panel trake prema položaju    |
| `Super + Ctrl + S` | Izbornik za dijeljenje (putem LocalSend) |
| `Super + Ctrl + C` | Kontrole za snimanje (snimka zaslona/sn​imanje/birač) |
| `Super + Ctrl + O` | Prebaci izbornik |
| `Super + Ctrl + H` | Izbornik hardvera |
| `Super + Ctrl + E` | Birač emojija |
| `Super + Ctrl + .` | Transkodiraj medije |
| `Super + Shift + Ctrl + A` | Pokreni svog zadanog agenta |
| `Power` key | Izbornik sustava |
| `Super + Shift + Copilot` key | Omarchy izbornik |

## Prilagodbe

| Tipkovni prečac                  | Funkcija              |
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
| `Display` key | Kruži kroz raspored radnog prostora |
| `Alt + Play` | Sljedeća skladba |
| `Alt + Shift + Play` | Prethodna skladba |

## Pokretanje aplikacija

| Tipkovni prečac                  | Funkcija              |
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
| `Super + Shift + /`           | Upravitelj lozinki (1password)    |
| `Super + Shift + Q` or `Calculator` key  | Kalkulator (Omacalc)    |
| `Super + Shift + D`           | Docker (lazydocker, nakon instalacije)    |
| `Super + Shift + T`           | Aktivnost (btop)    |
| `Super + Shift + N`           | Uređivač (Plain ili vaš odabrani zadani)  |
| `Super + Shift + C`           | Kalendar ([HEY](https://hey.com/))  |
| `Super + Shift + E`           | E-pošta ([HEY](https://hey.com/))  |
| `Super + Shift + Alt + E`           | Nova e-pošta ([HEY](https://hey.com/))  |
| `Super + Shift + A`           | Vaš zadani agent ili ChatGPT dok ne odaberete jednoga |
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

| Tipkovni prečac                  | Funkcija              |
| ----------------------- | --------------------- |
| `Super + A`           | Odaberi sve u aplikacijama koje podržavaju `Ctrl + A`    |
| `Super + C`           | Kopiraj    |
| `Super + X`           | Izreži (ne u terminalu)    |
| `Super + V`           | Zalijepi    |
| `Super + Ctrl + V`           | Upravitelj međuspremnika    |

Obično na Linuxu trebate `Ctrl + Shift + C/V` da biste kopirali i lijepili u terminalu i `Ctrl + C/V` da biste to radili svugdje drugdje. Ovi ujedinjeni tipkovni prečaci Omarchyja za međuspremnik rade svugdje.

## Snimanje

| Tipkovni prečac              | Funkcija                       |
| ------------------- | ------------------------------ |
| `Print Screen`            | Snimka zaslona                      |
| `Super + Ctrl + Alt + C`            | Snimka zaslona (ista snimka, za tipkovnice bez tipke Print Screen) |
| `Super + Ctrl + C` | Izbornik za snimanje |
| `Alt + Print Screen`            | Snimanje zaslona                     |
| `Super + Shift + Ctrl + Alt + C` | Snimanje zaslona bez zvuka, uz preskakanje izbornika (pritisnite ponovno za zaustavljanje) |
| `Super + Print Screen` | Birač boja |
| `Super + Ctrl + Print Screen` | Izdvajanje teksta u međuspremnik |
| `Super + Alt + [` | Smanji preklapanje web-kamere tijekom snimanja |
| `Super + Alt + ]` | Povećaj preklapanje web-kamere tijekom snimanja |
| `Alt + Shift + L` | Kopiraj trenutni URL iz web-aplikacije ili preglednika |
| `Alt + Shift + D` | Preuzmi video na trenutnoj stranici u `~/Videos` |
| `Alt + Space` | Pokreni/zaustavi diktiranje (zahtijeva _Setup > Defaults > Dictation_) |
| `Right Alt` | Drži za diktiranje (zahtijeva _Setup > Defaults > Dictation_) |

Kod snimanja zaslona tipkovni prečac prvo pita koji zvuk želite, a zatim započinje snimanje. Pritisnite ga ponovno za zaustavljanje. Pogledajte [snimke zaslona i snimanje](12-screenshots-recording.md) za pojedinosti.

Sve opcije snimanja dostupne su i pod _Trigger > Capture_ u Omarchy izborniku (`Super + Space`).

## Obavijesti

| Tipkovni prečac                  | Funkcija              |
| ----------------------- | --------------------- |
| `Super + ,` | Djeluj na najnoviju obavijest: otvori je ili pritisni njezinu jedinu tipku, odaberi među njezinim izborima ili je odbaci kad nema nijednoga  |
| `Super + Shift + ,` | Odbaci sve obavijesti |
| `Super + Ctrl + ,` | Upravljaj obavijestima tipkovnicom  |
| `Super + Alt + ,` | Odbaci najnoviju obavijest  |
| `Super + Shift + Alt + ,` | Otvori povijest obavijesti  |
| `Super + Ctrl + Alt + ,` | Prebaci utišavanje obavijesti  |

## Stil

| Tipkovni prečac                  | Funkcija              |
| ----------------------- | --------------------- |
| `Super + Ctrl + T` | Odaberi novu temu (također `Super + Ctrl + Shift + Space`) |
| `Super + Ctrl + W` | Odaberi pozadinu teme (također `Super + Ctrl + Space`) |
| `Super + Backspace` | Prebaci prozirnost na prozoru |
| `Super + Ctrl + Backspace` | Prebaci kvadratni omjer jednog prozora |

Dodatne pozadinske slike nalaze se u `~/.config/omarchy/backgrounds/<theme name>`. Dostupno i putem _Install > Style > Background_ u Omarchy izborniku.

Sve opcije stila dostupne su i pod _Appearance_ u Omarchy izborniku (`Super + Space`).

## Prebacivanja

| Tipkovni prečac                  | Funkcija              |
| ----------------------- | --------------------- |
| `Super + Ctrl + I` | Prebaci zaključavanje pri mirovanju |
| `Super + Ctrl + Delete` | Uključi/isključi zaslon prijenosnog računala |
| `Super + Ctrl + Alt + Delete` | Prebaci zrcaljenje zaslona prijenosnog računala |
| `Super + Shift + Space` | Prebaci gornju traku  |
| `Shift + Mute` | Prebaci na sljedeći izlaz zvuka |
| `Shift + Play` | Prebaci na sljedeći izvor medija |
| `Super + Shift + Backspace` | Prebaci razmake između prozora |
| `Super + Ctrl + Alt + F` | Prebaci radnu površinu na cijelom zaslonu (gornja traka + razmaci između prozora) |

## Podsjetnici

| Tipkovni prečac                  | Funkcija              |
| ----------------------- | --------------------- |
| `Super + Ctrl + R` | Postavi podsjetnik  |
| `Super + Ctrl + Alt + R` | Pogledaj sve podsjetnike  |
| `Super + Ctrl + Shift + R` | Obriši sve podsjetnike  |

## Kratke obavijesti

| Tipkovni prečac                  | Funkcija              |
| ----------------------- | --------------------- |
| `Super + Ctrl + Alt + T` | Prikaži vrijeme kao obavijest  |
| `Super + Ctrl + Alt + B` | Prikaži bateriju kao obavijest  |
| `Super + Ctrl + Alt + W` | Prebaci prikaz vremenskih prilika kao obavijesti  |

## Tmux

Tipka prefiksa je `Ctrl + Space` (`Ctrl + B` također radi). Ova povezivanja možete promijeniti u `~/.config/tmux/tmux.conf`.

### Okna

| Tipkovni prečac                  | Funkcija              |
| ----------------------- | --------------------- |
| `Prefix + v` | Podijeli okno pokraj (okomito) |
| `Prefix + h` | Podijeli okno ispod (vodoravno) |
| `Prefix + x` | Zatvori okno |
| `Prefix + z` | Prebaci zum okna (cijeli zaslon) |
| `Alt + Enter` | Podijeli okno ispod (bez prefiksa) |
| `Alt + Shift + Enter` | Podijeli okno pokraj (bez prefiksa) |
| `Alt + Escape` | Zatvori okno (bez prefiksa) |
| `Ctrl + Alt + Arrows` | Kreći se između okna |
| `Ctrl + Alt + Shift + Arrows` | Mijenjaj veličinu okna |

### Prozori

| Tipkovni prečac                  | Funkcija              |
| ----------------------- | --------------------- |
| `Prefix + c` | Novi prozor |
| `Prefix + k` | Zatvori prozor |
| `Prefix + r` | Preimenuj prozor |
| `Alt + 1-9` | Idi na određeni prozor |
| `Alt + Arrow Left/Right` | Kreći se između prozora |
| `Alt + Shift + Arrow Left/Right` | Premjesti prozor ulijevo/udesno |

### Sesije

| Tipkovni prečac                  | Funkcija              |
| ----------------------- | --------------------- |
| `Prefix + C` | Nova sesija |
| `Prefix + K` | Zatvori sesiju |
| `Prefix + R` | Preimenuj sesiju |
| `Prefix + N` | Sljedeća sesija |
| `Prefix + P` | Prethodna sesija |
| `Alt + Arrow Up/Down` | Kreći se između sesija |
| `Prefix + s` | Popiši sesije |
| `Prefix + d` | Odvoji se od sesije |

### Način kopiranja (vi-stil)

| Tipkovni prečac                  | Funkcija              |
| ----------------------- | --------------------- |
| `Prefix + [` | Uđi u način kopiranja |
| `v` | Započni odabir (u načinu kopiranja) |
| `y` | Kopiraj odabir (u načinu kopiranja) |

### Općenito

| Tipkovni prečac                  | Funkcija              |
| ----------------------- | --------------------- |
| `Prefix + q` | Ponovno učitaj konfiguraciju |
| `Prefix + ?` | Prikaži Tmux povezivanja tipki |
| `Prefix + :` | Naredbeni upit |

### Tmux funkcije rasporeda

Te se funkcije moraju pokrenuti unutar Tmux sesije.

| Naredba | Funkcija |
| ------- | -------- |
| `tdl <ai> [<second_ai>]` | Izradi razvojni raspored s uređivačem, AI-jem i terminalom |
| `tdlm <ai> [<second_ai>]` | Izradi razvojni raspored za svaki poddirektorij |
| `tsl <count> <command>` | Izradi swarm raspored s više okna |

## Ghostty terminal

Ghostty terminal instalira se pomoću _Install > Terminal_ putem Omarchy izbornika.

| Tipkovni prečac                  | Funkcija              |
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

| Tipkovni prečac              | Funkcija                       |
| ------------------- | ------------------------------ |
| `Ctrl + L`            | Idi na putanju                     |
| `Space`               | Pregledaj datoteku (strelice služe za navigaciju) |
| `Alt + Up`       | Idi gore u nadređenu mapu        |

## Neovim (s lazyvimom)

### Navigacija

| Tipkovni prečac                   | Funkcija                        |
| ------------------------ | ------------------------------- |
| `Space`                    | Prikaži opcije naredbi            |
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

| Tipkovni prečac                   | Funkcija                        |
| ------------------------ | ------------------------------- |
| `A`                        | Dodaj novu datoteku u nadređeni direktorij      |
| `Shift + A`                | Dodaj novi poddirektorij u nadređeni direktorij    |
| `D`                        | Izbriši označenu datoteku/direktorij     |
| `M`                        | Premjesti označenu datoteku/direktorij       |
| `R`                        | Preimenuj označenu datoteku/direktorij     |
| `?`                        | Prikaži pomoć za sve naredbe      |

[Pogledajte sve Neovim tipkovne prečace koje konfigurira LazyVim](https://www.lazyvim.org/keymaps).

## Brzi emojiji

Možete koristiti `Super + Ctrl + E` za prikaz potpunog birača emojija koji će odabir staviti u međuspremnik ili možete koristiti ove opcije za brzi pristup.

| Tipkovni prečac       | EM | Trag       |
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
| `Shift + CapsLock M I` | 😉 | mig       |
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

## Brza dovršavanja

| Tipkovni prečac       | Dovršavanje       |
| ------------ |  ---------- |
| `Shift + CapsLock Space Space` | — (duga crtica)   |
| `Shift + CapsLock Space N` | Vaše ime (kako je uneseno pri postavljanju)  |
| `Shift + CapsLock Space E` | Vaša e-pošta (kako je unesena pri postavljanju)  |

Možete dodati još vlastitih uređivanjem `~/.XCompose`, a zatim pokretanjem `omarchy restart xcompose` u terminalu kako bi se promjene preuzele.
