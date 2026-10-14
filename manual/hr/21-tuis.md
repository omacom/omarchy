# TUI-ji

## Lazygit

[Lazygit](https://github.com/jesseduffield/lazygit) divna je alternativa nečemu poput aplikacije GitHub Desktop, a radi unutar terminala.

Možeš ga pokrenuti izravno, tako da odeš u bilo koji direktorij kojim upravlja git i pokreneš `lazygit`. Ili ga možeš pokrenuti unutar Neovima gdje se može pokrenuti sa `Space G G`.

Između različitih okana skačeš pomoću `Tab`. U oknu Files odabireš datoteke za staging pomoću `Space`, a zatim možeš stvoriti novi commit pomoću `c`. Sve dostupne naredbe možeš vidjeti pomoću `?`.

## Btop

[Btop](https://github.com/aristocratos/btop) prekrasan je upravitelj resursa koji prikazuje korištenje memorije, CPU-a, diska i mreže. Također navodi sve aktivne procese i omogućuje ti da njima upravljaš.

Omarchy ga zove Activity, a pokrećeš ga pritiskom na `Super + Ctrl + T`. Otvara se kao plutajući prozor, koji možeš popločiti sa `Super + T`.

## Herdr

[Herdr](https://github.com/omacom-io/herdr) upravitelj je terminalskih radnih prostora koji ti daje radne prostore, kartice i okna te ih sve drži aktivnima u trajnoj sesiji iz koje se možeš odspojiti i kasnije se vratiti.

Pokrećeš ga (ili se ponovno spajaš na postojeću sesiju) sa `Super + Ctrl + Return`. Omarchy isporučuje Herdr konfiguraciju koja odražava njegovu Tmux konfiguraciju, pa je prefiksna tipka i ovdje `Ctrl + Space`. Sve prečace možeš pregledati sa `Super + Ctrl + K`.

## Fastfetch

[Fastfetch](https://github.com/fastfetch-cli/fastfetch) prikazuje informacije o sustavu, poput verzije kernela, vremena rada, teme, CPU-a, memorije i više. Nasljednik je popularnog alata neofetch.

Omarchy je to zapakirao kao _O programu_ u izborniku Omarchy (`Super + Space`).

## Cliamp

[Cliamp](https://www.cliamp.stream/) retro je terminalski glazbeni player inspiriran Winampom 2.x, zajedno s ugrađenim radijskim postajama za lo-fi beatove. Pokreni ga sa `Super + Shift + Alt + M` ili iz izbornika Omarchy pod _Aplikacije_. Pritisni `?` za potpuni popis prečaca.

## Što je s Wi-Fi-jem i Bluetoothom?

Nećeš pronaći TUI-je za Wi-Fi i Bluetooth — ti poslovi pripadaju Omarchy ljusci. Klikni ikonu Wi-Fi u traci izbornika (ili pritisni `Super + Ctrl + W`) za pregled mreža i spajanje, a klikni ikonu Bluetooth (ili pritisni `Super + Ctrl + B`) za uparivanje i spajanje uređaja. Pogledaj [networking](35-networking.md) za cijelu priču.

## Dodavanje vlastitih

Svaki terminalski program može dobiti puni tretman aplikacije. Idi na _Instaliraj > TUI_ u izborniku Omarchy (`Super + Space`), daj mu ime, naredbu za pokretanje, stil prozora i ikonu i pojavit će se u pokretaču aplikacija kao i svaka druga aplikacija. Možeš ga ponovno ukloniti pod _Ukloni > TUI_.
