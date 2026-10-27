# TUIs

## Lazygit

[Lazygit](https://github.com/jesseduffield/lazygit) je sjajna alternativa nečemu poput aplikacije GitHub Desktop, a radi unutar terminala.

Možete ga pokrenuti izravno, tako da odete u bilo koji direktorij kojim upravlja git i pokrenete `lazygit`. Ili ga možete pokrenuti unutar Neovima, gdje se pokreće pomoću `Space G G`.

Između različitih okana prebacujete se pomoću `Tab`. U oknu Files datoteke za staging odabirete pomoću `Space`, a zatim možete stvoriti novi commit pomoću `c`. Sve dostupne naredbe možete vidjeti pomoću `?`.

## Btop

[Btop](https://github.com/aristocratos/btop) je prekrasan upravitelj resursa koji prikazuje potrošnju memorije, CPU-a, diska i mreže. Također navodi sve aktivne procese i omogućuje vam upravljanje njima.

Omarchy ga naziva Activity, a pokrećete ga pritiskom na `Super + Shift + T`. Otvara se kao plutajući prozor, koji možete popločati pomoću `Super + T`.

## Herdr

[Herdr](https://github.com/omacom-io/herdr) je upravitelj radnih prostora za terminal koji vam daje radne prostore, kartice i okna te ih sve drži pokrenutima u trajnoj sesiji iz koje se možete odvojiti i kojoj se možete kasnije vratiti.

Pokrećete ga (ili se ponovno povezujete na postojeću sesiju) pomoću `Super + Ctrl + Return`. Omarchy isporučuje Herdr konfiguraciju koja preslikava njegovu Tmux konfiguraciju, pa je tipka prefiksa i ovdje `Ctrl + Space`. Sve tipkovničke prečace možete pregledati pomoću `Super + Ctrl + K`.

## Fastfetch

[Fastfetch](https://github.com/fastfetch-cli/fastfetch) prikazuje informacije o sustavu, poput verzije kernela, vremena rada, teme, CPU-a, memorije i još mnogo toga. Nasljednik je popularnog alata neofetch.

Omarchy ga je zapakirao kao _About_ u Omarchy izborniku (`Super + Space`).

## Cliamp

[Cliamp](https://www.cliamp.stream/) je retro terminalski glazbeni reproduktor inspiriran Winampom 2.x, upotpunjen ugrađenim radijskim postajama za lo-fi beatove. Pokrenite ga pomoću `Super + Shift + Alt + M` ili iz Omarchy izbornika pod _Apps_. Pritisnite `?` za potpuni popis tipkovničkih prečaca.

## Što je s Wi-Fi-jem i Bluetoothom?

Nećete pronaći TUI-je za Wi-Fi i Bluetooth — ti poslovi pripadaju Omarchy ljusci. Kliknite ikonu Wi-Fi-ja u gornjoj traci (ili pritisnite `Super + Ctrl + N`) kako biste vidjeli mreže i povezali se, a kliknite ikonu Bluetootha (ili pritisnite `Super + Ctrl + B`) za uparivanje i povezivanje uređaja. Cijelu priču pogledajte u [umrežavanju](35-networking.md).

## Dodavanje vlastitih

Svaki terminalski program može dobiti potpuni tretman aplikacije. Otvorite _Install > TUI_ u Omarchy izborniku (`Super + Space`), dajte mu naziv, naredbu za pokretanje, stil prozora i ikonu, i pojavit će se u pokretaču aplikacija kao i svaka druga aplikacija. Možete ga ponovno ukloniti pod _Remove > TUI_.
