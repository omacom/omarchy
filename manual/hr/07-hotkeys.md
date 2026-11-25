# Tipkovničke prečice

Sve glavne tipkovničke veze možete vidjeti pomoću `Super + K` (Tmux veze pomoću `Super + Alt + K`, a Herdr veze pomoću `Super + Ctrl + K`).

## Kako su raspoređene tipkovničke prečice

Svaka prečica nalazi se na jednoj ravnini, određenoj svojim modifikatorima, a svaka ravnina ima jedan posao. To je ono što prečice drži odvojenima i znači da obično možete pogoditi gdje se nešto nalazi.

| Ravnina | Što se tamo nalazi | Primjeri |
| --- | --- | --- |
| `Super + key` | Sustav: prozori, radni prostori, rasporedi i osnovni izbornici | `Super + Space` izbornik Omarchy, `Super + W` zatvori prozor, `Super + F` cijeli zaslon |
| `Super + Shift + key` | Aplikacije | `Super + Shift + B` preglednik, `Super + Shift + E` e-pošta, `Super + Shift + N` uređivač |
| `Super + Ctrl + key` | Ploče i izbornici sustava | `Super + Ctrl + A` zvuk, `Super + Ctrl + N` mreža, `Super + Ctrl + C` izbornik snimanja |
| `Super + Ctrl + Alt + key` | Brze radnje i obavijesti | `Super + Ctrl + Alt + T` prikaži vrijeme, `Super + Ctrl + Alt + B` baterija, `Super + Ctrl + Alt + C` snimka zaslona |

Dodavanje `Alt` prečici daje vam varijantu iste stvari, nikad nešto nepovezano:

- `Super + Shift + B` otvara preglednik; `Super + Shift + Alt + B` otvara privatni prozor
- `Super + Shift + E` otvara e-poštu; `Super + Shift + Alt + E` započinje novu
- `Super + F` prelazi na cijeli zaslon; `Super + Alt + F` prelazi na punu širinu
- `Super + Ctrl + C` otvara izbornik snimanja; `Super + Ctrl + Alt + C` preskače izbornik i snima snimku zaslona

Kada dodajete prečicu:

1. Odaberite ravninu prema tome što radi, zatim odaberite tipku.
2. Nemojte pomicati postojeću prečicu da biste napravili mjesta. Pronađite slobodnu tipku na pravoj ravnini.
3. `Alt` koristite samo za varijantu prečice bez njega.

Nekoliko prečica krši ova pravila jer su praktične. `Shift` sa strelicom ili `Tab` pomiče ili obrće umjesto da otvara aplikaciju, a `Print`, medijske tipke, `Alt + Tab` i `Ctrl + Alt + Del` rade onako kako rade posvuda drugdje. To su iznimke, a ne obrasci za kopiranje.

Ako vam zadana postavka ne odgovara (recimo da želite `Super + Shift + S` za snimke zaslona kao na Windowsu), ponovno je povežite u `~/.config/hypr/bindings.lua`.

## Navigacija

| Prečica                  | Funkcija              |
| ----------------------- | --------------------- |
| `Super + Space`           | Izbornik Omarchy (aplikacije i sve ostalo)    |
| `Super + Alt + Space` | Mreža aplikacija |
| `Super + Escape` | Izbornik sustava (obustava, ponovno pokretanje itd.)  |
| `Super + Ctrl + L` | Zaključaj računalo |
| `Super + W` or `Super + Q` | Zatvori prozor             |
| `Ctrl + Alt + Del` | Zatvori sve prozore |
| `Super + K` | Prikaži sve prečice |
| `Super + Alt + K` | Prikaži tmux prečice |
| `Super + Ctrl + K` | Prikaži herdr prečice |
| `Super + M` | Minimiziraj prozor na dock |
| `Super + T`               | Prebaci prozor između popločanog/plutajućeg načina             |
| `Super + J` | Prebaci položaj prozora (vodoravno/okomito) |
| `Super + O`               | Prebaci iskačući prozor u sticky'n'floating |
| `Super + L`               | Kruži kroz rasporede dwindle, scrolling i floating |
| `Super + Alt + L`         | Kruži kroz rasporede unatrag |
| `Super + P`               | Prebaci pseudo stil prozora (prirodno naspram rastegnuto) |
| `Super + F`                 | Prijeđi na cijeli zaslon              |
| `Super + Alt + F`                 | Prijeđi na punu širinu              |
| `Super + Ctrl + F`                 | Prijeđi na cijeli zaslon unutar prozora              |
| `Super + 1…9/0`         | Skoči na određeni radni prostor (0 je 10) na monitoru u fokusu |
| `Super + Tab` | Skoči na sljedeći radni prostor na monitoru u fokusu |
| `Super + Shift + Tab` | Skoči na prethodni radni prostor na monitoru u fokusu |
| `Super + Ctrl + Tab` | Skoči na prijašnji radni prostor na monitoru u fokusu |
| `Super + Shift + 1…9/0` | Premjesti prozor na radni prostor na monitoru u fokusu |
| `Super + Shift + Alt + 1…9/0` | Premjesti prozor na radni prostor na monitoru u fokusu bez praćenja |
| `Super + S` | Prebaci puni scratchpad |
| `Super + Alt + S` | Premjesti prozor na puni scratchpad |
| `Super + the key above Tab` (grave on US layouts) | Prebaci Quake konzolu |
| `Super + Shift + the key above Tab` (grave on US layouts) | Premjesti prozor na Quake konzolu |
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
| `Super + Scroll Wheel` | Listaj kroz radne prostore na monitoru u fokusu |
| `Super + G`               | Prebaci grupiranje prozora      |
| `Super + Alt + G`               | Izvuci prozor iz grupe      |
| `Super + Alt + Tab`               | Kruži između prozora u grupi      |
| `Super + Alt + Shift + Tab`               | Kruži unatrag između prozora u grupi      |
| `Super + Alt + Scroll Wheel` | Kruži između prozora u grupi |
| `Super + Alt + 1/2/3/4/5`               | Skoči na određeni prozor u grupi      |
| `Super + Alt + Arrow`  | Premjesti prozor u grupu u smjeru strelice, uključujući onaj na monitoru s te strane |
| `Super + Ctrl + Left/Right`  | Kreći se između prozora unutar popločane grupe |
| `Super + Ctrl + Z` | Povećaj prikaz na zaslonu (ponovite za veće povećanje) |
| `Super + Ctrl + Alt + Z` | Potpuno smanji prikaz zaslona |
| `Super + /` | Korak naprijed kroz opcije skaliranja monitora |
| `Super + Alt + /` | Korak natrag kroz opcije skaliranja monitora |
| `Alt + Tab` | Kruži naprijed kroz prozore na aktivnom radnom prostoru |
| `Alt + Shift + Tab` | Kruži unatrag kroz prozore na aktivnom radnom prostoru |
| `Ctrl + Alt + Tab`| Kruži fokus naprijed kroz monitore |
| `Ctrl + Alt + Shift + Tab`| Kruži fokus unatrag kroz monitore |
| `Super + I` | Promijeni jezik unosa (s više od jednog rasporeda ili metode unosa) |
| `Super + Shift + I` | Vrati prethodni jezik unosa |

Na dodirnoj pločici povlačenja s tri i četiri prsta mijenjaju radne prostore, pomiču prozore te otvaraju izbornik i Quake konzolu; geste pogledajte u [tipkovnica, miš i dodirna pločica](34-keyboard-mouse-trackpad.md).

Mijenjanje veličine koristi dvije tipke desno od 0, što god vaša tipkovnica na njima ispisuje: `-` i `=` na američkim tipkovnicama, `+` i `´` na danskim i švedskim, `+` i `\` na norveškim, `ß` i `´` na njemačkim, `'` i `¡` na španjolskim te `-` i `^` na japanskim (JIS). `Super + K` ih navodi onako kako ih vaša tipkovnica ispisuje. Na JIS-u je `Super + ^` isto što i `Super + Equal`, dok je `Super + Shift + -` (koje upisuje `=`) isto što i `Super + Shift + Minus`. Skaliranje monitora i upravitelj lozinki koriste `/`; na rasporedima koji `/` upisuju samo uz Shift, kao što to čini većina europskih, umjesto toga koriste tipku lijevo od desnog Shifta (`-` na danskom i njemačkom).

## Kontrole sustava

| Prečica                  | Funkcija              |
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
| `Super + Ctrl + C` | Kontrole snimanja (snimka zaslona/-snimanje/birač) |
| `Super + Ctrl + O` | Prebaci izbornik |
| `Super + Ctrl + H` | Izbornik hardvera |
| `Super + Ctrl + E` | Birač emojija |
| `Super + Ctrl + .` | Transkodiraj medije |
| `Super + Shift + Ctrl + A` | Pokreni svog zadanog agenta |
| `Power` key | Izbornik sustava |
| `Super + Shift + Copilot` key | Izbornik Omarchy |

## Prilagodbe

| Prečica                  | Funkcija              |
| ----------------------- | --------------------- |
| `Shift + Brightness Up` | Maksimalna svjetlina zaslona |
| `Shift + Brightness Down` | Minimalna svjetlina zaslona |
| `Alt + Brightness Up/Down` | Precizne promjene svjetline od 1% |
| `Alt + Volume Up/Down` | Precizne promjene glasnoće od 1% |
| `Keyboard Brightness Up/Down` | Pozadinsko osvjetljenje tipkovnice jače/slabije |
| `Keyboard Backlight` | Kruži kroz razine pozadinskog osvjetljenja tipkovnice |
| `Ctrl + Brightness Up/Down` | Pozadinsko osvjetljenje tipkovnice jače/slabije, na tipkovnicama bez vlastitih tipki |
| `Mic Mute` | Utišaj mikrofon |
| `Shift + Mute` | Promijeni izlaz zvuka |
| `Touchpad Toggle` | Uključi ili isključi dodirnu pločicu |
| `Display` key | Kruži kroz raspored radnog prostora |
| `Alt + Play` | Sljedeća skladba |
| `Alt + Shift + Play` | Prethodna skladba |

## Pokretanje aplikacija

| Prečica                  | Funkcija              |
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

Promijenite/dodajte veze u `~/.config/hypr/bindings.lua`.

## Univerzalni međuspremnik

| Prečica                  | Funkcija              |
| ----------------------- | --------------------- |
| `Super + A`           | Odaberi sve u aplikacijama koje podržavaju `Ctrl + A`    |
| `Super + C`           | Kopiraj    |
| `Super + X`           | Izreži (ne u terminalu)    |
| `Super + V`           | Zalijepi    |
| `Super + Ctrl + V`           | Upravitelj međuspremnika    |

Obično na Linuxu trebate `Ctrl + Shift + C/V` za kopiranje i lijepljenje u terminalu i `Ctrl + C/V` da to učinite svugdje drugdje. Ove ujedinjene prečice međuspremnika u Omarchyju rade svugdje.

## Snimanje

| Prečica              | Funkcija                       |
| ------------------- | ------------------------------ |
| `Print Screen`            | Snimka zaslona                      |
| `Super + Ctrl + Alt + C`            | Snimka zaslona (ista snimka, za tipkovnice bez tipke Print Screen) |
| `Super + Ctrl + C` | Izbornik snimanja |
| `Alt + Print Screen`            | Snimanje zaslona                     |
| `Super + Shift + Ctrl + Alt + C` | Snimanje zaslona bez zvuka, uz preskakanje izbornika (pritisnite ponovno za zaustavljanje) |
| `Super + Print Screen` | Birač boja |
| `Super + Ctrl + Print Screen` | Izdvajanje teksta u međuspremnik |
| `Super + Alt + [` | Smanji preklapanje web-kamere tijekom snimanja |
| `Super + Alt + ]` | Povećaj preklapanje web-kamere tijekom snimanja |
| `Alt + Shift + L` | Kopiraj trenutni URL iz web-aplikacije ili preglednika |
| `Alt + Shift + D` | Preuzmi videozapis s trenutne stranice u `~/Videos` |
| `Alt + Space` | Pokreni/zaustavi diktiranje (zahtijeva _Setup > Defaults > Dictation_) |
| `Right Alt` | Drži za diktiranje (zahtijeva _Setup > Defaults > Dictation_) |

Kod snimanja zaslona prečica prvo pita koji zvuk želite, zatim započinje snimanje. Pritisnite je ponovno za zaustavljanje. Pojedinosti pogledajte u [snimke zaslona i snimanje](12-screenshots-recording.md).

Svim opcijama snimanja može se pristupiti i pod _Trigger > Capture_ u izborniku Omarchy (`Super + Space`).

## Obavijesti

| Prečica                  | Funkcija              |
| ----------------------- | --------------------- |
| `Super + ,` | Djeluj na najnoviju obavijest: otvori je ili pritisni njezinu jedinu tipku, odaberi među njezinim izborima ili je odbaci kada ih nema  |
| `Super + Shift + ,` | Odbaci sve obavijesti |
| `Super + Ctrl + ,` | Upravljaj obavijestima tipkovnicom  |
| `Super + Alt + ,` | Odbaci najnoviju obavijest  |
| `Super + Shift + Alt + ,` | Otvori povijest obavijesti  |
| `Super + Ctrl + Alt + ,` | Prebaci utišavanje obavijesti  |

## Stil

| Prečica                  | Funkcija              |
| ----------------------- | --------------------- |
| `Super + Ctrl + T` | Odaberi novu temu (također `Super + Ctrl + Shift + Space`) |
| `Super + Ctrl + W` | Odaberi pozadinu teme (također `Super + Ctrl + Space`) |
| `Super + Backspace` | Prebaci prozirnost na prozoru |
| `Super + Ctrl + Backspace` | Prebaci kvadratni omjer jednog prozora |

Dodatne pozadinske slike nalaze se u `~/.config/omarchy/backgrounds/<theme name>`. Dostupno i putem _Install > Style > Background_ u izborniku Omarchy.

Svim opcijama stila može se pristupiti i pod _Appearance_ u izborniku Omarchy (`Super + Space`).

## Prebacivanje

| Prečica                  | Funkcija              |
| ----------------------- | --------------------- |
| `Super + Ctrl + I` | Prebaci zaključavanje u mirovanju |
| `Super + Ctrl + Delete` | Uključi/isključi zaslon prijenosnog računala |
| `Super + Ctrl + Alt + Delete` | Prebaci zrcaljenje zaslona prijenosnog računala |
| `Super + Shift + Space` | Prebaci gornju traku  |
| `Shift + Mute` | Prebaci na sljedeći izlaz zvuka |
| `Shift + Play` | Prebaci na sljedeći izvor medija |
| `Super + Shift + Backspace` | Prebaci razmake među prozorima |
| `Super + Ctrl + Alt + F` | Prebaci radnu površinu preko cijelog zaslona (gornja traka + razmaci među prozorima) |

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
| `Super + Ctrl + Alt + W` | Prebaci vremensku prognozu kao obavijest  |

## Tmux

Tipka prefiksa je `Ctrl + Space` (`Ctrl + B` također radi). Ove veze možete promijeniti u `~/.config/tmux/tmux.conf`.

### Okna

| Prečica                  | Funkcija              |
| ----------------------- | --------------------- |
| `Prefix + v` | Podijeli okno bočno (okomito) |
| `Prefix + h` | Podijeli okno ispod (vodoravno) |
| `Prefix + x` | Ubij okno |
| `Prefix + z` | Prebaci zumiranje okna (cijeli zaslon) |
| `Alt + Enter` | Podijeli okno ispod (bez prefiksa) |
| `Alt + Shift + Enter` | Podijeli okno bočno (bez prefiksa) |
| `Alt + Escape` | Ubij okno (bez prefiksa) |
| `Ctrl + Alt + Arrows` | Kreći se između okna |
| `Ctrl + Alt + Shift + Arrows` | Promijeni veličinu okna |

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
| `Prefix + s` | Navedi sesije |
| `Prefix + d` | Odvoji se od sesije |

### Način kopiranja (vi-stil)

| Prečica                  | Funkcija              |
| ----------------------- | --------------------- |
| `Prefix + [` | Uđi u način kopiranja |
| `v` | Započni odabir (u načinu kopiranja) |
| `y` | Kopiraj odabir (u načinu kopiranja) |

### Općenito

| Prečica                  | Funkcija              |
| ----------------------- | --------------------- |
| `Prefix + q` | Ponovno učitaj konfiguraciju |
| `Prefix + ?` | Prikaži Tmux tipkovničke veze |
| `Prefix + :` | Naredbeni upit |

### Funkcije rasporeda u Tmuxu

Ove funkcije moraju se pokrenuti unutar Tmux sesije.

| Naredba | Funkcija |
| ------- | -------- |
| `tdl <ai> [<second_ai>]` | Izradi razvojni raspored s uređivačem, AI-jem i terminalom |
| `tdlm <ai> [<second_ai>]` | Izradi razvojni raspored po poddirektoriju |
| `tsl <count> <command>` | Izradi swarm raspored s više okna |

## Ghostty Terminal

Ghostty terminal instalira se pomoću _Install > Terminal_ putem izbornika Omarchy.

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
| `Shift + Pg Up/Down` | Listaj povijest |
| `Ctrl + Left mouse` | Otvori poveznicu u pregledniku |

## Upravitelj datoteka

| Prečica              | Funkcija                       |
| ------------------- | ------------------------------ |
| `Ctrl + L`            | Idi na putanju                     |
| `Space`               | Pretpregled datoteke (strelice navigiraju) |
| `Alt + Up`       | Idi gore u nadređenu mapu        |

## Neovim (s lazyvim)

### Navigacija

| Prečica                   | Funkcija                        |
| ------------------------ | ------------------------------- |
| `Space`                    | Prikaži opcije naredbi            |
| `Space Space`              | Otvori datoteku fuzzy pretraživanjem      |
| `Space E`                  | Prebaci bočnu traku                  |
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
| `D`                        | Izbriši istaknutu datoteku/direktorij     |
| `M`                        | Premjesti istaknutu datoteku/direktorij       |
| `R`                        | Preimenuj istaknutu datoteku/direktorij     |
| `?`                        | Prikaži pomoć za sve naredbe      |

[Pogledajte sve Neovim prečice koje konfigurira LazyVim](https://www.lazyvim.org/keymaps).

## Brzi emojiji

Možete koristiti `Super + Ctrl + E` za prikaz potpunog birača emojija koji će odabir staviti u međuspremnik ili možete koristiti ove opcije brzog pristupa.

| Prečica       | EM | Trag       |
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
| `Shift + CapsLock M B` |🤯 | raspamećivanje |

## Brze dopune

| Prečica       | Dopuna       |
| ------------ |  ---------- |
| `Shift + CapsLock Space Space` | — (mdash)   |
| `Shift + CapsLock Space N` | Vaše ime (kako je uneseno pri postavljanju)  |
| `Shift + CapsLock Space E` | Vaša e-pošta (kako je unesena pri postavljanju)  |

Možete dodati još vlastitih uređivanjem `~/.XCompose`, zatim pokretanjem `omarchy restart xcompose` u terminalu kako bi se promjene preuzele.
