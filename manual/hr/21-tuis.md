# TUIs

## Lazygit

[Lazygit](https://github.com/jesseduffield/lazygit) je sjajna alternativa nečemu poput aplikacije GitHub Desktop, a radi unutar terminala.

Možete ga pokrenuti izravno, tako da odete u bilo koji direktorij kojim upravlja git i pokrenete `lazygit`. Ili ga možete pokrenuti unutar Neovima, gdje se može pokrenuti s `Space G G`.

Između različitih okna skačete pomoću `Tab`. U oknu Files datoteke za staging odabirete pomoću `Space`, a zatim možete stvoriti novi commit pomoću `c`. Sve dostupne naredbe možete vidjeti pomoću `?`.

## Btop

[Btop](https://github.com/aristocratos/btop) je prekrasan upravitelj resursa koji prikazuje korištenje memorije, CPU-a, diska i mreže. Također navodi sve aktivne procese i omogućuje vam da njima upravljate.

Omarchy ga naziva Activity Monitor, a pokrećete ga iz pokretača aplikacija ili pritiskom na `Super + Shift + T`. Otvara se kao plutajući prozor, koji s `Super + T` možete prebaciti u način slaganja pločica.

## Herdr

[Herdr](https://github.com/omacom-io/herdr) je upravitelj radnih prostora za terminal koji vam daje radne prostore, kartice i okna te ih sve održava pokrenutima u trajnoj sesiji iz koje se možete odvojiti i kojoj se kasnije možete vratiti.

Pokrećete ga (ili se ponovno povezujete na svoju postojeću sesiju) s `Super + Ctrl + Return`. Omarchy isporučuje konfiguraciju za Herdr koja zrcali njegovu Tmux konfiguraciju, pa je i ovdje prefiksna tipka `Ctrl + Space`. Sve tipkovničke prečace možete pregledati s `Super + Ctrl + K`.

## Fastfetch

[Fastfetch](https://github.com/fastfetch-cli/fastfetch) prikazuje informacije o sustavu, poput verzije kernela, vremena rada, teme, CPU-a, memorije i još mnogo toga. Nasljednik je popularnog alata neofetch.

Omarchy ga je zapakirao kao _About_ u izborniku Omarchy (`Super + Space`).

## Cliamp

[Cliamp](https://www.cliamp.stream/) je retro glazbeni reproduktor za terminal inspiriran Winampom 2.x, s ugrađenim radijskim postajama za lo-fi beatove. Pokrenite ga s `Super + Shift + Alt + M` ili iz izbornika Omarchy pod _Apps_. Pritisnite `?` za cijeli popis tipkovničkih prečaca.

## A što je s Wi-Fi-jem i Bluetoothom?

Nećete pronaći TUIs za Wi-Fi i Bluetooth — ti poslovi pripadaju ljusci Omarchyja. Kliknite ikonu Wi-Fi-ja u gornjoj traci (ili pritisnite `Super + Ctrl + N`) da biste vidjeli mreže i povezali se, a kliknite ikonu Bluetootha (ili pritisnite `Super + Ctrl + B`) za uparivanje i povezivanje uređaja. Pogledajte [umrežavanje](35-networking.md) za cijelu priču.

## Dodavanje vlastitih

Svaki program za terminal može dobiti puni tretman aplikacije. Idite na _Install > TUI_ u izborniku Omarchy (`Super + Space`), dajte mu ime, naredbu za pokretanje, stil prozora i ikonu i pojavit će se u pokretaču aplikacija kao i svaka druga aplikacija. Možete ga ponovno ukloniti pod _Remove > TUI_.
