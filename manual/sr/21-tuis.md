# TUIs

## Lazygit

[Lazygit](https://github.com/jesseduffield/lazygit) je divna alternativa nečemu poput aplikacije GitHub Desktop, i radi unutar terminala.

Možete je pokrenuti direktno, tako što ćete otići u bilo koji direktorijum kojim upravlja git i pokrenuti `lazygit`. Ili je možete pokrenuti unutar Neovim-a gde se može pokrenuti pomoću `Space G G`.

Preskačete između različitih panela pomoću `Tab`. U panelu Files, birate datoteke za pripremu korišćenjem `Space`, a zatim možete kreirati novi commit pomoću `c`. Sve dostupne komande možete videti pomoću `?`.

## Btop

[Btop](https://github.com/aristocratos/btop) je prelep menadžer resursa koji prikazuje korišćenje memorije, CPU-a, diska i mreže. Takođe navodi sve aktivne procese i omogućava vam da njima upravljate.

Omarchy ga naziva Activity Monitor, i pokrećete ga iz pokretača aplikacija ili pritiskom na `Super + Shift + T`. Otvara se kao plutajući prozor, koji možete postaviti u pločice pomoću `Super + T`.

## Herdr

[Herdr](https://github.com/omacom-io/herdr) je menadžer radnog prostora za terminal koji vam daje radne prostore, kartice i panele, i održava ih sve aktivnim u trajnoj sesiji iz koje se možete odvojiti i kojoj se kasnije možete vratiti.

Pokrećete ga (ili se ponovo povezujete na postojeću sesiju) iz pokretača aplikacija ili pomoću `Super + Ctrl + Return`. Omarchy isporučuje Herdr konfiguraciju koja odražava njegovu Tmux konfiguraciju, tako da je ovde prefiksni taster takođe `Ctrl + Space`. Sve prečice na tastaturi možete pregledati pomoću `Super + Ctrl + K`.

## Fastfetch

[Fastfetch](https://github.com/fastfetch-cli/fastfetch) prikazuje sistemske informacije, kao što su verzija kernela, vreme rada, tema, CPU, memorija i još mnogo toga. Naslednik je popularnog alata neofetch.

Omarchy je ovo upakovao kao _System > About_ u Omarchy meniju (`Super + Space`).

## Cliamp

[Cliamp](https://www.cliamp.stream/) je retro muzički plejer za terminal inspirisan Winamp-om 2.x, kompletan sa ugrađenim radio stanicama za lo-fi bitove. Pokrenite ga pomoću `Super + Shift + Alt + M`, ili iz Omarchy menija pod _Apps_. Pritisnite `?` za potpunu listu prečica na tastaturi.

## Šta je sa Wi-Fi-jem i Bluetooth-om?

Nećete naći TUI-je za Wi-Fi i Bluetooth — ti poslovi pripadaju Omarchy ljusci. Kliknite na ikonu Wi-Fi-ja u gornjoj traci (ili pritisnite `Super + Ctrl + N`) da vidite mreže i povežete se, i kliknite na ikonu Bluetooth-a (ili pritisnite `Super + Ctrl + B`) da uparite i povežete uređaje. Pogledajte [mrežno povezivanje](35-networking.md) za celu priču.

## Dodavanje sopstvenih

Bilo koji terminalski program može dobiti pun tretman aplikacije. Idite na _Install > TUI_ u Omarchy meniju (`Super + Space`), dajte mu ime, komandu za pokretanje, stil prozora i ikonu, i pojaviće se u pokretaču aplikacija kao i svaka druga aplikacija. Možete ga ponovo ukloniti pod _Remove > TUI_.
