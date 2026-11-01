# Umrežavanje

Mrežom u Omarchyju upravlja NetworkManager, a upravljate njome putem ikone mreže u [gornjoj traci](05-the-top-bar.md) ili pomoću `Super + Ctrl + N`.

Ta ploča pretražuje Wi-Fi mreže, prikazuje jačinu signala i povezuje se. Za Ethernet ne trebate baš ništa — priključite ga i radi. Ako radije ostajete u terminalu, `nmtui` nudi vam iste kontrole, a postoji i skupina naredbi `omarchy network`.

## Dijeljenje vaše Wi-Fi mreže

Umjesto da dugu lozinku čitate naglas, dok ste na Wi-Fi mreži pokrenite _Setup > Network > QR Code_. Time se na zaslonu prikazuje QR kôd koji kamera bilo kojeg telefona može skenirati i tako se pridružiti mreži. To je jedna od onih stvari koje ćete koristiti češće nego što biste očekivali kad jednom saznate da je tu.

Ako vam zapravo treba sama lozinka, ispisuje je `omarchy network password <interface>`.

## DNS

Omarchy koristi onaj DNS koji vam mreža dodijeli putem DHCP-a. To možete zaobići za cijelo računalo pod _Setup > Network > DNS_, gdje su Cloudflare i Google udaljeni jednim klikom. Odaberite _Custom_ da biste upisali vlastite poslužitelje.

Iz terminala `omarchy dns` ispisuje trenutačnog pružatelja, a `omarchy dns Cloudflare` postavlja ga.

## Fiksiranje Wi-Fi pojasa

Ako vaš usmjerivač 2.4GHz, 5GHz i 6GHz stavlja pod isti naziv mreže, vaše će se prijenosno računalo ponekad držati onog sporog. `omarchy network band` pokazuje na kojem ste pojasu, a `omarchy network band 5` fiksira ga. Upotrijebite `auto` da bi opet sam birao.

Time se fiksira pojas, a ne određena pristupna točka, pa se i dalje normalno krećete između AP-ova.

## Koliko je brza?

_Trigger > Speed Test > Network Speed Test_ mjeri vašu stvarnu brzinu preuzimanja i slanja pomoću dvaju brojčanika. Iz terminala to je `omarchy network speedtest down` ili `up`. Mjeri u odnosu na vlastitu uslugu Omarchyja i broji samo svoje testne prijenose. Druga preuzimanja mogu se natjecati za propusnost, ali se ne dodaju rezultatu testa brzine. (U tom se izborniku pored njega nalazi i test brzine diska, ako testirate drugo usko grlo.)

## Vatrozid

Vatrozid je prema zadanim postavkama uključen i blokira sav dolazni promet, uz jednu iznimku: port 53317, kako bi [LocalSend](22-guis.md) radio odmah po instalaciji.

SSH je isključen dok ga ne uključite pomoću _Setup > Security > SSHD_, što pokreće daemon, otvara port 22 uz ograničenje brzine protiv napada grubom silom i autorizira ključ. Docker je također zaključan, pa se spremnici ne mogu slučajno izložiti svijetu. Cijelu priču potražite u [sigurnosti](48-security.md).

## Tailscale

[Tailscale](https://tailscale.com/) je mesh VPN koji dosezanje svih vaših računala i poslužitelja putem interneta čini jednostavnim i sigurnim. Instalirajte ga pomoću _Install > Service > Tailscale_.

Time dobivate Tailscale ploču u traci, koja povezuje i odspaja tailnet, mijenja račune i bira izlazni čvor — i vaša vlastita računala i Mullvad regije pojavljuju se na popisu. Također pregledava vaša računala, a tu živi i Taildrop: odaberite računalo i pritisnite `s` da biste mu poslali datoteke, ili `c`, `n` i `d` da biste kopirali njegovu IP adresu, naziv ili puni DNS naziv. Ekvivalent u terminalu je `omarchy tailscale send <machine> [file...]`, a datoteke poslane vama automatski završavaju u `~/Downloads`. Obavijest koja najavljuje dolazak čeka dok je ne kliknete da biste je otvorili ili je ne odbacite, pa je datoteka koja stigne dok niste za računalom i dalje tu kad se vratite da na nju odgovorite.

Instalacijom se dodaje i web-aplikacija za administratorsku konzolu Tailscalea.

## Kada prestane raditi

Prije ponovnog pokretanja računala pokušajte ponovno pokrenuti samo problematični dio. _Update > Hardware_ ima Wi-Fi, Bluetooth, Audio i Trackpad, a ponovno učitavanje jednog od njih rješava većinu situacija „radilo je prije pet minuta“. Pogledajte [rješavanje problema](45-troubleshooting.md).
