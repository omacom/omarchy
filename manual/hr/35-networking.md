# Umrežavanje

Mrežom u Omarchyju upravlja NetworkManager, a njome upravljate putem ikone mreže u [gornjoj traci](05-the-top-bar.md) ili pomoću `Super + Ctrl + N`.

Ta ploča pretražuje Wi-Fi mreže, prikazuje jačinu signala i povezuje se. Za Ethernet ne treba baš ništa — priključite ga i radi. Ako radije ostajete u terminalu, `nmtui` vam nudi iste kontrole, a postoji i skupina naredbi `omarchy network`.

## Dijeljenje vaše Wi-Fi mreže

Umjesto da dugu lozinku čitate naglas, dok ste na Wi-Fi mreži pokrenite _Setup > Network > QR Code_. To će na zaslon postaviti QR kod koji kamera bilo kojeg telefona može skenirati kako bi se pridružila. To je jedna od onih stvari koje ćete koristiti češće nego što biste očekivali kad jednom saznate da je tu.

Ako vam zapravo treba sama lozinka, `omarchy network password <interface>` će je ispisati.

## DNS

Omarchy koristi onaj DNS koji mu vaša mreža dodijeli putem DHCP-a. To možete zaobići za cijelo računalo pod _Setup > Network > DNS_, gdje su Cloudflare i Google udaljeni samo jedan klik. Odaberite _Custom_ kako biste upisali vlastite poslužitelje.

Iz terminala `omarchy dns` ispisuje trenutnog pružatelja, a `omarchy dns Cloudflare` postavlja jednoga.

## Fiksiranje Wi-Fi pojasa

Ako vaš usmjerivač 2.4GHz, 5GHz i 6GHz stavlja pod isto ime mreže, vaše će se prijenosno računalo ponekad držati onog sporog. `omarchy network band` pokazuje u kojem ste pojasu, a `omarchy network band 5` ga fiksira. Upotrijebite `auto` kako bi ponovno samo biralo.

Time se fiksira pojas, a ne određena pristupna točka, pa se i dalje normalno krećete između AP-ova.

## Koliko je brza?

_Trigger > Speed Test > Network Speed Test_ mjeri vašu stvarnu brzinu preuzimanja i prijenosa pomoću para brojčanika. Iz terminala je to `omarchy network speedtest down` ili `up`. (U tom se izborniku pored njega nalazi i test brzine diska, ako testirate ono drugo usko grlo.)

## Vatrozid

Vatrozid je prema zadanim postavkama uključen i blokira sav dolazni promet, s jednom iznimkom: priključak 53317, kako bi [LocalSend](22-guis.md) radio odmah po instalaciji.

SSH je isključen dok ga ne uključite pomoću _Setup > Security > SSHD_, što pokreće daemon, otvara priključak 22 s ograničenjem brzine protiv napada grubom silom i autorizira ključ. I Docker je zaključan, pa se spremnici ne mogu slučajno izložiti svijetu. Cijelu priču potražite u [sigurnosti](48-security.md).

## Tailscale

[Tailscale](https://tailscale.com/) je mesh VPN koji pristup svim vašim računalima i poslužiteljima putem interneta čini jednostavnim i sigurnim. Instalirajte ga pomoću _Install > Service > Tailscale_.

To vam daje ploču Tailscale u traci, koja povezuje i odspaja tailnet, mijenja račune i bira izlazni čvor — i vaša vlastita računala i Mullvad regije pojavljuju se na popisu. Njome također pregledavate svoja računala, a tu živi i Taildrop: odaberite računalo i pritisnite `s` kako biste mu poslali datoteke, ili `c`, `n` i `d` kako biste kopirali njegovu IP adresu, ime ili puno DNS ime. Ekvivalent u terminalu je `omarchy tailscale send <machine> [file...]`, a datoteke poslane vama automatski završavaju u `~/Downloads`. Obavijest koja najavljuje dolazak čeka dok je ne kliknete za otvaranje ili je ne odbacite, pa je datoteka koja stigne dok niste za računalom i dalje tu i čeka vas kad se vratite.

Instalacija dodaje i web aplikaciju za administratorsku konzolu Tailscalea.

## Kad prestane raditi

Prije ponovnog pokretanja računala pokušajte zasebno ponovno pokrenuti problematični dio. _Update > Hardware_ ima Wi-Fi, Bluetooth, Audio i Trackpad, a ponovno učitavanje jednog od njih rješava većinu situacija tipa „radilo je prije pet minuta”. Pogledajte [rješavanje problema](45-troubleshooting.md).
