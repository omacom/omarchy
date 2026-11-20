# TUIs

## Lazygit

[Lazygit](https://github.com/jesseduffield/lazygit) je sjajna alternativa nečemu poput aplikacije GitHub Desktop, a radi unutar terminala.

Možete ga pokrenuti izravno tako da odete u bilo koji direktorij kojim upravlja git i pokrenete `lazygit`. Ili ga možete pokrenuti unutar Neovima, gdje ga možete pokrenuti tipkama `Space G G`.

Između različitih okana prebacujete se tipkom `Tab`. U oknu Files datoteke za pripremu odabirete tipkom `Space`, a zatim možete stvoriti novi commit tipkom `c`. Sve dostupne naredbe možete vidjeti tipkom `?`.

## Btop

[Btop](https://github.com/aristocratos/btop) je prekrasan upravitelj resursa koji prikazuje potrošnju memorije, CPU-a, diska i mreže. Također popisuje sve aktivne procese i omogućuje vam upravljanje njima.

Omarchy ga naziva Activity Monitor, a pokrećete ga iz pokretača aplikacija ili pritiskom na `Super + Shift + T`. Otvara se kao plutajući prozor, koji možete popločati tipkama `Super + T`.

## Herdr

[Herdr](https://github.com/omacom-io/herdr) je upravitelj radnih prostora za terminal koji vam daje radne prostore, kartice i okna te ih sve održava pokrenutima u trajnoj sesiji iz koje se možete odvojiti i kojoj se kasnije možete vratiti.

Pokrećete ga (ili se ponovno povezujete na vašu postojeću sesiju) iz pokretača aplikacija ili tipkama `Super + Ctrl + Return`. Omarchy isporučuje konfiguraciju za Herdr koja odražava njegovu Tmux konfiguraciju, pa je prefiksna tipka i ovdje `Ctrl + Space`. Sve kombinacije tipki možete pregledati tipkama `Super + Ctrl + K`.

## Fastfetch

[Fastfetch](https://github.com/fastfetch-cli/fastfetch) prikazuje informacije o sustavu, poput verzije kernela, vremena rada, teme, CPU-a, memorije i još mnogo toga. Nasljednik je popularnog alata neofetch.

Omarchy ga je zapakirao kao _System > About_ u izborniku Omarchy (`Super + Space`).

## Cliamp

[Cliamp](https://www.cliamp.stream/) je retro glazbeni reproduktor za terminal nadahnut Winampom 2.x, upotpunjen ugrađenim radijskim postajama za lo-fi ritmove. Pokrenite ga tipkama `Super + Shift + Alt + M` ili iz izbornika Omarchy pod _Apps_. Pritisnite `?` za potpuni popis kombinacija tipki.

## Što je s Wi-Fi-jem i Bluetoothom?

Nećete pronaći TUI-ove za Wi-Fi i Bluetooth — ti poslovi pripadaju ljusci Omarchyja. Kliknite ikonu Wi-Fi-ja u gornjoj traci (ili pritisnite `Super + Ctrl + N`) kako biste vidjeli mreže i povezali se, a kliknite ikonu Bluetootha (ili pritisnite `Super + Ctrl + B`) za uparivanje i povezivanje uređaja. Pogledajte [umrežavanje](35-networking.md) za cijelu priču.

## Dodavanje vlastitih

Svaki terminalski program može dobiti potpuni tretman aplikacije. Otvorite _Install > TUI_ u izborniku Omarchy (`Super + Space`), dajte mu naziv, naredbu za pokretanje, stil prozora i ikonu i pojavit će se u pokretaču aplikacija kao i svaka druga aplikacija. Možete ga ponovno ukloniti pod _Remove > TUI_.
