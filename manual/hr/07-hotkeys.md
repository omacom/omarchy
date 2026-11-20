# Tipkovnički prečaci

Sve glavne tipkovničke veze možete vidjeti sa `Super + K` (veze za Tmux sa `Super + Alt + K` i veze za Herdr sa `Super + Ctrl + K`).

## Kako su raspoređeni tipkovnički prečaci

Svaki tipkovnički prečac sjedi na jednoj ravnini, koju određuju njegovi modifikatori, a svaka ravnina ima jedan posao. To je ono što sprječava da se tipkovnički prečaci međusobno pomiješaju i znači da obično možete pogoditi gdje se nešto nalazi.

| Ravnina | Što se tamo nalazi | Primjeri |
| --- | --- | --- |
| `Super + key` | Sustav: prozori, radni prostori, rasporedi i osnovni izbornici | `Super + Space` izbornik Omarchy, `Super + W` zatvori prozor, `Super + F` cijeli zaslon |
| `Super + Shift + key` | Aplikacije | `Super + Shift + B` preglednik, `Super + Shift + E` e-pošta, `Super + Shift + N` uređivač |
| `Super + Ctrl + key` | Paneli i izbornici sustava | `Super + Ctrl + A` zvuk, `Super + Ctrl + N` mreža, `Super + Ctrl + C` izbornik snimanja |
| `Super + Ctrl + Alt + key` | Brze radnje i napomene | `Super + Ctrl + Alt + T` prikaži vrijeme, `Super + Ctrl + Alt + B` baterija, `Super + Ctrl + Alt + C` snimka zaslona |

Dodavanje `Alt` tipkovničkom prečacu daje vam varijantu iste stvari, nikad nešto nepovezano:

- `Super + Shift + B` otvara preglednik; `Super + Shift + Alt + B` otvara privatni prozor
- `Super + Shift + E` otvara e-poštu; `Super + Shift + Alt + E` započinje novu
- `Super + F` prelazi na cijeli zaslon; `Super + Alt + F` prelazi na cijelu širinu
- `Super + Ctrl + C` otvara izbornik snimanja; `Super + Ctrl + Alt + C` preskače izbornik i snima snimku zaslona

Prilikom dodavanja tipkovničkog prečaca:

1. Odaberite ravninu prema tome što radi, a zatim odaberite tipku.
2. Nemojte pomicati postojeći tipkovnički prečac da biste napravili mjesta. Pronađite slobodnu tipku na pravoj ravnini.
3. Koristite `Alt` samo za varijantu tipkovničkog prečaca bez njega.

Nekoliko tipkovničkih prečaca krši ova pravila jer su praktični. `Shift` sa strelicom ili `Tab` pomiče ili obrće umjesto da otvara aplikaciju, a `Print`, medijske tipke, `Alt + Tab` i `Ctrl + Alt + Del` rade onako kako rade posvuda drugdje. To su iznimke, a ne obrasci za kopiranje.

Ako vam zadana postavka ne odgovara (recimo da želite `Super + Shift + S` za snimke zaslona kao na Windowsu), ponovno je povežite u `~/.config/hypr/bindings.lua`.

## Navigacija

| Tipkovnički prečac | Funkcija |
| ----------------------- | --------------------- |
| `Super + Space` | izbornik Omarchy (aplikacije i sve ostalo) |
| `Super + Alt + Space` | Mreža aplikacija |
| `Super + Escape` | Izbornik sustava (obustavi, ponovno pokreni itd.) |
| `Super + Ctrl + L` | Zaključaj računalo |
| `Super + W` ili `Super + Q` | Zatvori prozor |
| `Ctrl + Alt + Del` | Zatvori sve prozore |
| `Super + K` | Prikaži sve tipkovničke prečace |
| `Super + Alt + K` | Prikaži tipkovničke prečace za tmux |
| `Super + Ctrl + K` | Prikaži tipkovničke prečace za herdr |
| `Super + M` | Minimiziraj prozor u dock |
| `Super + T` | Prebaci prozor između slaganja u pločice i plutanja |
| `Super + J` | Prebaci položaj prozora (vodoravno/okomito) |
| `Super + O` | Prebaci iskačući prozor u ljepljivo i plutajuće |
| `Super + L` | Kruži kroz rasporede dwindle, scrolling i floating |
| `Super + Alt + L` | Kruži kroz rasporede obrnutim redoslijedom |
| `Super + P` | Prebaci stil pseudo prozora (prirodno naspram rastegnuto) |
| `Super + F` | Prikaži na cijelom zaslonu |
| `Super + Alt + F` | Prikaži na cijeloj širini |
| `Super + Ctrl + F` | Prikaži na cijelom zaslonu unutar prozora |
| `Super + 1…9/0` | Skoči na određeni radni prostor (0 je 10) na monitoru u fokusu |
| `Super + Tab` | Skoči na sljedeći radni prostor na monitoru u fokusu |
| `Super + Shift + Tab` | Skoči na prethodni radni prostor na monitoru u fokusu |
| `Super + Ctrl + Tab` | Skoči na prijašnji radni prostor na monitoru u fokusu |
| `Super + Shift + 1…9/0` | Premjesti prozor na radni prostor na monitoru u fokusu |
| `Super + Shift + Alt + 1…9/0` | Premjesti prozor na radni prostor na monitoru u fokusu bez praćenja |
| `Super + S` | Uključi/isključi puni scratchpad |
| `Super + Alt + S` | Premjesti prozor na puni scratchpad |
| `Super + Grave` | Uključi/isključi Quake konzolu |
| `Super + Shift + Grave` | Premjesti prozor na Quake konzolu |
| `Super + Shift + Ctrl + Arrows` | Premjesti prozor na monitor u tom smjeru |
| `Super + Shift + Alt + Arrows` | Premjesti radni prostor na monitor u tom smjeru |
| `Super + Arrow` | Premjesti fokus na prozor u smjeru strelice, prelazeći na monitor s te strane na rubu zaslona |
| `Super + Shift + Arrow` | Zamijeni prozor s drugim u smjeru strelice, uključujući onaj na monitoru s te strane |
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
| `Super + Scroll Wheel` | Pomiči se kroz radne prostore na monitoru u fokusu |
| `Super + G` | Uključi/isključi grupiranje prozora |
| `Super + Alt + G` | Premjesti prozor izvan grupiranja |
| `Super + Alt + Tab` | Kruži između prozora u grupi |
| `Super + Alt + Shift + Tab` | Kruži unatrag između prozora u grupi |
| `Super + Alt + Scroll Wheel` | Kruži između prozora u grupi |
| `Super + Alt + 1/2/3/4/5` | Skoči na određeni prozor u grupi |
| `Super + Alt + Arrow` | Premjesti prozor u grupu u smjeru strelice, uključujući onaj na monitoru s te strane |
| `Super + Ctrl + Left/Right` | Kreći se između prozora unutar grupe za slaganje u pločice |
| `Super + Ctrl + Z` | Povećaj prikaz na zaslonu (ponovite za veće povećanje) |
| `Super + Ctrl + Alt + Z` | Potpuno smanji prikaz zaslona |
| `Super + /` | Korak naprijed kroz mogućnosti skaliranja monitora |
| `Super + Alt + /` | Korak unatrag kroz mogućnosti skaliranja monitora |
| `Alt + Tab` | Kruži naprijed kroz prozore na aktivnom radnom prostoru |
| `Alt + Shift + Tab` | Kruži unatrag kroz prozore na aktivnom radnom prostoru |
| `Ctrl + Alt + Tab` | Kruži fokus naprijed kroz monitore |
| `Ctrl + Alt + Shift + Tab` | Kruži fokus unatrag kroz monitore |
| `Super + I` | Promijeni jezik unosa (s više od jednog rasporeda ili načina unosa) |
| `Super + Shift + I` | Promijeni jezik unosa natrag |

Na dodirnoj pločici, povlačenja s tri i četiri prsta mijenjaju radne prostore, premještaju prozore i otvaraju izbornik i Quake konzolu; pogledajte [tipkovnica, miš i dodirna pločica](34-keyboard-mouse-trackpad.md) za geste.

Prečaci za mijenjanje veličine koriste fizičke tipke `code:20` i `code:21` (XKB `<AE11>` i `<AE12>`), bez obzira na znakove otisnute na tipkovnici. Na američkim tipkovnicama te su tipke `-` i `=`; na japanskim (JIS) tipkovnicama one su `-` i `^`; na španjolskim tipkovnicama one su `'` i `¡`. Na JIS-u, `Super + ^` je `Super + Equal`, dok je `Super + Shift + -` (koji upisuje `=`) `Super + Shift + Minus`.

## Kontrole sustava

| Tipkovnički prečac | Funkcija |
| ----------------------- | --------------------- |
| `Super + Ctrl + A` | Panel za zvuk |
| `Super + Ctrl + B` | Panel za Bluetooth |
| `Super + Ctrl + N` | Panel za Wi-Fi/mrežu |
| `Super + Ctrl + D` | Panel za zaslon |
| `Super + Ctrl + P` | Panel za napajanje |
| `Super + Ctrl + X` | Panel za agente |
| `Super + Ctrl + Alt + D` | Panel za kalendar |
| `Super + Ctrl + Alt + E` | Panel za svjetski sat |
| `Super + Ctrl + 1-9` | Uključi/isključi panel trake prema položaju |
| `Super + Ctrl + S` | Izbornik za dijeljenje (putem LocalSend) |
| `Super + Ctrl + C` | Kontrole snimanja (snimka zaslona/-snimanje/birač) |
| `Super + Ctrl + O` | Izbornik za prebacivanje |
| `Super + Ctrl + H` | Izbornik hardvera |
| `Super + Ctrl + E` | Birač emojija |
| `Super + Ctrl + .` | Transkodiraj medije |
| `Super + Shift + Ctrl + A` | Odaberi AI agenta |
| `Power` tipka | Izbornik sustava |
| `Super + Shift + Copilot` tipka | izbornik Omarchy |

## Prilagodbe

| Tipkovnički prečac | Funkcija |
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
| `Touchpad Toggle` | Uključi ili isključi dodirnu pločicu |
| `Display` tipka | Kruži kroz raspored radnog prostora |
| `Alt + Play` | Sljedeća skladba |
| `Alt + Shift + Play` | Prethodna skladba |

## Pokretanje aplikacija

| Tipkovnički prečac | Funkcija |
| ----------------------- | --------------------- |
| `Super + Return` | Terminal |
| `Super + Alt + Return` | Tmux terminal |
| `Super + Ctrl + Return` | Herdr (upravitelj agenata) |
| `Super + Shift + Return` ili `Super + Shift + B` | Preglednik |
| `Super + Shift + Alt + B` | Preglednik (privatno/anonimno) |
| `Super + Shift + F` | Upravitelj datoteka |
| `Super + Shift + Alt + F` | Upravitelj datoteka u cwd-u terminala |
| `Super + Shift + M` | Glazba (Spotify) |
| `Super + Shift + Alt + M` | Glazba (cliamp) |
| `Super + Shift + /` | Upravitelj lozinki (1password) |
| `Super + Shift + Q` ili tipka `Calculator` | Kalkulator (Omacalc) |
| `Super + Shift + D` | Docker (lazydocker, nakon instalacije) |
| `Super + Shift + T` | Aktivnost (btop) |
| `Super + Shift + N` | Uređivač (Plain ili vaš odabrani zadani) |
| `Super + Shift + C` | Kalendar ([HEY](https://hey.com/)) |
| `Super + Shift + E` | E-pošta ([HEY](https://hey.com/)) |
| `Super + Shift + Alt + E` | Nova e-pošta ([HEY](https://hey.com/)) |
| `Super + Shift + A` | AI (ChatGPT) |
| `Super + Shift + Alt + A` | AI (Grok) |
| `Super + Shift + G` | Poruke (Signal) |
| `Super + Shift + P` | Google Photos |
| `Super + Shift + S` | Google Maps |
| `Super + Shift + Alt + G` | Poruke (WhatsApp) |
| `Super + Shift + Ctrl + G` | Poruke (Google) |
| `Super + Shift + O` | Obsidian |
| `Super + Shift + W` | Pisanje (Omawrite) |
| `Super + Shift + X` | X |
| `Super + Shift + Alt + X` | X (nova objava) |
| `Super + Shift + Y` | YouTube |

Promijenite/dodajte veze u `~/.config/hypr/bindings.lua`.

## Univerzalni međuspremnik

| Tipkovnički prečac | Funkcija |
| ----------------------- | --------------------- |
| `Super + A` | Odaberi sve u aplikacijama koje podržavaju `Ctrl + A` |
| `Super + C` | Kopiraj |
| `Super + X` | Izreži (ne u terminalu) |
| `Super + V` | Zalijepi |
| `Super + Ctrl + V` | Upravitelj međuspremnika |

Obično na Linuxu trebate `Ctrl + Shift + C/V` za kopiranje i lijepljenje u terminalu i `Ctrl + C/V` da biste to radili posvuda drugdje. Ovi ujedinjeni tipkovnički prečaci za međuspremnik u Omarchyju rade posvuda.

## Snimanje

| Tipkovnički prečac | Funkcija |
| ------------------- | ------------------------------ |
| `Print Screen` | Snimka zaslona |
| `Super + Ctrl + Alt + C` | Snimka zaslona (ista snimka, za tipkovnice bez tipke Print Screen) |
| `Super + Ctrl + C` | Izbornik snimanja |
| `Alt + Print Screen` | Snimanje zaslona |
| `Super + Shift + Ctrl + Alt + C` | Snimanje zaslona bez zvuka, uz preskakanje izbornika (pritisnite ponovno za zaustavljanje) |
| `Super + Print Screen` | Birač boja |
| `Super + Ctrl + Print Screen` | Izdvajanje teksta u međuspremnik |
| `Super + Alt + [` | Smanji preklapanje web-kamere tijekom snimanja |
| `Super + Alt + ]` | Povećaj preklapanje web-kamere tijekom snimanja |
| `Alt + Shift + L` | Kopiraj trenutni URL iz web-aplikacije ili preglednika |
| `Alt + Shift + D` | Preuzmi videozapis s trenutne stranice u `~/Videos` |
| `Alt + Space` | Pokreni/zaustavi diktiranje (zahtijeva _Postavljanje > Zadane postavke > Diktiranje_) |
| `Right Alt` | Drži za diktiranje (zahtijeva _Postavljanje > Zadane postavke > Diktiranje_) |

Kod snimanja zaslona, tipkovnički prečac prvo pita koji zvuk želite, a zatim započinje snimanje. Pritisnite ga ponovno za zaustavljanje. Pogledajte [snimke zaslona i snimanje](12-screenshots-recording.md) za detalje.

Sve mogućnosti snimanja dostupne su i pod _Okidač > Snimanje_ u izborniku Omarchy (`Super + Space`).

## Obavijesti

| Tipkovnički prečac | Funkcija |
| ----------------------- | --------------------- |
| `Super + ,` | Djeluj na najnoviju obavijest: otvori je ili pritisni njezinu jedinu tipku, odaberi iz njezinih mogućnosti ili je odbaci kada ih nema |
| `Super + Shift + ,` | Odbaci sve obavijesti |
| `Super + Ctrl + ,` | Upravljaj obavijestima tipkovnicom |
| `Super + Alt + ,` | Odbaci najnoviju obavijest |
| `Super + Shift + Alt + ,` | Otvori povijest obavijesti |
| `Super + Ctrl + Alt + ,` | Uključi/isključi utišavanje obavijesti |

## Stil

| Tipkovnički prečac | Funkcija |
| ----------------------- | --------------------- |
| `Super + Ctrl + T` | Odaberi novu temu (također `Super + Ctrl + Shift + Space`) |
| `Super + Ctrl + W` | Odaberi pozadinu teme (također `Super + Ctrl + Space`) |
| `Super + Backspace` | Uključi/isključi prozirnost na prozoru |
| `Super + Ctrl + Backspace` | Uključi/isključi kvadratni omjer za jedan prozor |

Dodatne pozadinske slike nalaze se u `~/.config/omarchy/backgrounds/<theme name>`. Također dostupno putem _Instaliraj > Stil > Pozadina_ u izborniku Omarchy.

Sve mogućnosti stila dostupne su i pod _Izgled_ u izborniku Omarchy (`Super + Space`).

## Prekidači

| Tipkovnički prečac | Funkcija |
| ----------------------- | --------------------- |
| `Super + Ctrl + I` | Uključi/isključi zaključavanje pri mirovanju |
| `Super + Ctrl + Delete` | Uključi/isključi zaslon prijenosnog računala |
| `Super + Ctrl + Alt + Delete` | Uključi/isključi zrcaljenje zaslona prijenosnog računala |
| `Super + Shift + Space` | Uključi/isključi gornju traku |
| `Shift + Mute` | Prebaci na sljedeći izlaz zvuka |
| `Shift + Play` | Prebaci na sljedeći izvor medija |
| `Super + Shift + Backspace` | Uključi/isključi razmake između prozora |
| `Super + Ctrl + Alt + F` | Uključi/isključi radnu površinu na cijelom zaslonu (gornja traka + razmaci između prozora) |

## Podsjetnici

| Tipkovnički prečac | Funkcija |
| ----------------------- | --------------------- |
| `Super + Ctrl + R` | Postavi podsjetnik |
| `Super + Ctrl + Alt + R` | Pogledaj sve podsjetnike |
| `Super + Ctrl + Shift + R` | Obriši sve podsjetnike |

## Kratke obavijesti

| Tipkovnički prečac | Funkcija |
| ----------------------- | --------------------- |
| `Super + Ctrl + Alt + T` | Prikaži vrijeme kao obavijest |
| `Super + Ctrl + Alt + B` | Prikaži bateriju kao obavijest |
| `Super + Ctrl + Alt + W` | Uključi/isključi vremenske prilike kao obavijest |

## Tmux

Tipka prefiksa je `Ctrl + Space` (`Ctrl + B` također radi). Ove veze možete promijeniti u `~/.config/tmux/tmux.conf`.

### Okna

| Tipkovnički prečac | Funkcija |
| ----------------------- | --------------------- |
| `Prefix + v` | Podijeli okno bočno (okomito) |
| `Prefix + h` | Podijeli okno dolje (vodoravno) |
| `Prefix + x` | Ubi okno |
| `Prefix + z` | Uključi/isključi zumiranje okna (cijeli zaslon) |
| `Alt + Enter` | Podijeli okno dolje (bez prefiksa) |
| `Alt + Shift + Enter` | Podijeli okno bočno (bez prefiksa) |
| `Alt + Escape` | Ubi okno (bez prefiksa) |
| `Ctrl + Alt + Arrows` | Kreći se između okna |
| `Ctrl + Alt + Shift + Arrows` | Mijenjaj veličinu okna |

### Prozori

| Tipkovnički prečac | Funkcija |
| ----------------------- | --------------------- |
| `Prefix + c` | Novi prozor |
| `Prefix + k` | Ubi prozor |
| `Prefix + r` | Preimenuj prozor |
| `Alt + 1-9` | Idi na određeni prozor |
| `Alt + Arrow Left/Right` | Kreći se između prozora |
| `Alt + Shift + Arrow Left/Right` | Premjesti prozor ulijevo/udesno |

### Sesije

| Tipkovnički prečac | Funkcija |
| ----------------------- | --------------------- |
| `Prefix + C` | Nova sesija |
| `Prefix + K` | Ubi sesiju |
| `Prefix + R` | Preimenuj sesiju |
| `Prefix + N` | Sljedeća sesija |
| `Prefix + P` | Prethodna sesija |
| `Alt + Arrow Up/Down` | Kreći se između sesija |
| `Prefix + s` | Popiši sesije |
| `Prefix + d` | Odvoji se od sesije |

### Način kopiranja (vi-stil)

| Tipkovnički prečac | Funkcija |
| ----------------------- | --------------------- |
| `Prefix + [` | Uđi u način kopiranja |
| `v` | Započni odabir (u načinu kopiranja) |
| `y` | Kopiraj odabir (u načinu kopiranja) |

### Općenito

| Tipkovnički prečac | Funkcija |
| ----------------------- | --------------------- |
| `Prefix + q` | Ponovno učitaj konfiguraciju |
| `Prefix + ?` | Prikaži tipkovničke veze za Tmux |
| `Prefix + :` | Naredbeni upit |

### Funkcije rasporeda u Tmuxu

Te se funkcije moraju pokrenuti unutar sesije Tmux.

| Naredba | Funkcija |
| ------- | -------- |
| `tdl <ai> [<second_ai>]` | Stvori razvojni raspored s uređivačem, AI-jem i terminalom |
| `tdlm <ai> [<second_ai>]` | Stvori razvojni raspored po poddirektoriju |
| `tsl <count> <command>` | Stvori raspored roja s više okna |

## Ghostty Terminal

Ghostty terminal instalira se pomoću _Instaliraj > Terminal_ putem izbornika Omarchy.

| Tipkovnički prečac | Funkcija |
| ----------------------- | --------------------- |
| `Ctrl + Shift + E` | Nova podjela dolje |
| `Ctrl + Shift + O` | Nova podjela bočno |
| `Ctrl + Alt + Arrows` | Kreći se između podjela |
| `Super + Ctrl + Shift + Arrows` | Promijeni veličinu podjele za 10 redaka |
| `Super + Ctrl + Shift + Alt + Arrows` | Promijeni veličinu podjele za 100 redaka |
| `Ctrl + Shift + T` | Nova kartica |
| `Ctrl + Shift + Arrows` | Kreći se između kartica |
| `Alt + Numbers` | Idi na određenu karticu |
| `Shift + Pg Up/Down` | Pomiči se kroz povijest |
| `Ctrl + Left mouse` | Otvori poveznicu u pregledniku |

## Upravitelj datoteka

| Tipkovnički prečac | Funkcija |
| ------------------- | ------------------------------ |
| `Ctrl + L` | Idi na putanju |
| `Space` | Pregledaj datoteku (strelice za navigaciju) |
| `Alt + Up` | Idi gore u nadređenu mapu |

## Neovim (s lazyvim)

### Navigacija

| Tipkovnički prečac | Funkcija |
| ------------------------ | ------------------------------- |
| `Space` | Prikaži mogućnosti naredbi |
| `Space Space` | Otvori datoteku putem neizrazitog pretraživanja |
| `Space E` | Uključi/isključi bočnu traku |
| `Space G G` | Prikaži git kontrole |
| `Space S G` | Pretraži sadržaj datoteke |
| `Ctrl + W W` | Skači između bočne trake i uređivača |
| `Ctrl + Left/right arrow` | Promijeni veličinu bočne trake |
| `Shift + H` | Idi na lijevu karticu datoteke |
| `Shift + L` | Idi na desnu karticu datoteke |
| `Space B D` | Zatvori karticu datoteke |

### Dok ste u bočnoj traci

| Tipkovnički prečac | Funkcija |
| ------------------------ | ------------------------------- |
| `A` | Dodaj novu datoteku u nadređeni direktorij |
| `Shift + A` | Dodaj novi poddirektorij u nadređeni direktorij |
| `D` | Izbriši istaknutu datoteku/direktorij |
| `M` | Premjesti istaknutu datoteku/direktorij |
| `R` | Preimenuj istaknutu datoteku/direktorij |
| `?` | Prikaži pomoć za sve naredbe |

[Pogledajte sve tipkovničke prečace za Neovim koje konfigurira LazyVim](https://www.lazyvim.org/keymaps).

## Brzi emojiji

Možete koristiti `Super + Ctrl + E` za prikaz potpunog birača emojija koji će odabir staviti u međuspremnik ili možete koristiti ove mogućnosti brzog pristupa.

| Tipkovnički prečac | EM | Trag |
| ------------ | -- | ---------- |
| `Shift + CapsLock M S` | 😄 | osmijeh |
| `Shift + CapsLock M C` | 😂 | plač |
| `Shift + CapsLock M L` | 😍 | ljubav |
| `Shift + CapsLock M V` | ✌️ | pobjeda |
| `Shift + CapsLock M H` | ❤️ | srce |
| `Shift + CapsLock M Y` | 👍 | da |
| `Shift + CapsLock M N` | 👎 | ne |
| `Shift + CapsLock M F` | 🖕 | jebote |
| `Shift + CapsLock M W` | 🤞 | želja |
| `Shift + CapsLock M R` | 🤘 | rock |
| `Shift + CapsLock M K` | 😘 | poljubac |
| `Shift + CapsLock M E` | 🙄 | kolutanje očima |
| `Shift + CapsLock M I` | 😉 | namigivanje |
| `Shift + CapsLock M P` | 🙏 | moli |
| `Shift + CapsLock M D` | 🤤 | slinjenje |
| `Shift + CapsLock M M` | 💰 | novac |
| `Shift + CapsLock M X` | 🎉 | slavlje |
| `Shift + CapsLock M 1` | 💯 | 100% |
| `Shift + CapsLock M T` | 🥂 | zdravica |
| `Shift + CapsLock M O` |👌 | ok |
| `Shift + CapsLock M G` |👋 | pozdrav |
| `Shift + CapsLock M A` |💪 | ruka |
| `Shift + CapsLock M B` |🤯 | puhanje |

## Brza dovršavanja

| Tipkovnički prečac | Dovršavanje |
| ------------ |  ---------- |
| `Shift + CapsLock Space Space` | — (duga crtica) |
| `Shift + CapsLock Space N` | Vaše ime (kako je uneseno prilikom postavljanja) |
| `Shift + CapsLock Space E` | Vaša e-pošta (kako je unesena prilikom postavljanja) |

Možete dodati još svojih uređivanjem `~/.XCompose`, a zatim pokretanjem `omarchy restart xcompose` u terminalu kako bi se promjene preuzele.
