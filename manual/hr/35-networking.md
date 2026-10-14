# Umrežavanje

Umrežavanjem u Omarchyju upravlja NetworkManager, a njime upravljate putem ikone mreže u [gornjoj traci](05-the-top-bar.md) ili prečacem `Super + Ctrl + W`.

Ta ploča traži Wi-Fi mreže, prikazuje jačinu signala i povezuje se. Za Ethernet ne treba baš ništa — priključite ga i radi. Ako radije ostajete u terminalu, `nmtui` vam daje iste kontrole, a postoji i skupina naredbi `omarchy network`.

## Dijeljenje vaše Wi-Fi mreže

Umjesto da naglas čitate dugu lozinku, pokrenite _Postavke > Network > QR Code_ dok ste na Wi-Fi mreži. Time se na zaslonu prikaže QR kod koji svaka kamera telefona može skenirati za pridruživanje. To je jedna od onih stvari koje ćete koristiti češće nego što biste očekivali kad jednom znate da je ondje.

Ako vam zapravo treba sama lozinka, `omarchy network password <interface>` je ispisuje.

## DNS

Omarchy koristi onaj DNS koji vaša mreža dijeli putem DHCP-a. To možete nadjačati za cijelo računalo pod _Postavke > Network > DNS_, gdje su Cloudflare i Google udaljeni jedan klik. Odaberite _Custom_ za unos vlastitih poslužitelja.

Iz terminala `omarchy dns` ispisuje trenutačnog pružatelja, a `omarchy dns Cloudflare` postavlja jednog.

## Fiksiranje Wi-Fi pojasa

Ako vaš usmjerivač stavi 2.4GHz, 5GHz i 6GHz pod isto ime mreže, vaše prijenosno računalo ponekad će se držati sporog. `omarchy network band` pokazuje na kojem ste pojasu, a `omarchy network band 5` ga fiksira. Upotrijebite `auto` da ponovno samo bira.

Time se fiksira pojas, a ne određena pristupna točka, pa se i dalje normalno krećete između pristupnih točaka.

## Koliko je brzo?

_Pokreni > Speed Test > Network Speed Test_ mjeri vašu stvarnu brzinu preuzimanja i prijenosa s parom brojčanika. Iz terminala je to `omarchy network speedtest down` ili `up`. (Odmah pored toga u tom izborniku sjedi i test brzine diska, ako mjerite drugo usko grlo.)

## Vatrozid

Vatrozid je prema zadanim postavkama uključen i blokira sav dolazni promet, uz jednu iznimku: priključak 53317, tako da [LocalSend](22-guis.md) radi odmah po instalaciji.

SSH je isključen dok ga ne uključite pod _Postavke > Security > SSHD_, što pokreće servis, otvara priključak 22 s ograničenjem brzine protiv napada grubom silom i odobrava ključ. Docker je također zaključan, pa se spremnici ne mogu slučajno izložiti svijetu. Cijelu priču potražite u [sigurnosti](48-security.md).

## Tailscale

[Tailscale](https://tailscale.com/) je mesh VPN koji dosezanje svih vaših računala i poslužitelja putem interneta čini jednostavnim i sigurnim. Instalirajte ga pod _Instaliraj > Service > Tailscale_.

Time dobivate Tailscale ploču u traci, koja povezuje i odspaja tailnet, mijenja račune i odabire izlazni čvor — vaša vlastita računala i Mullvad regije pojavljuju se na popisu. Također pregledava vaša računala, a tu živi i Taildrop: odaberite računalo i pritisnite `s` za slanje datoteka ili `c`, `n` i `d` za kopiranje njegove IP adrese, imena ili punog DNS imena. Ekvivalent u terminalu je `omarchy tailscale send <machine> [file...]`, a datoteke poslane vama automatski stižu u `~/Downloads`. Obavijest o dolasku čeka dok je ne kliknete za otvaranje ili odbacite, pa datoteka koja stigne dok niste za računalom i dalje ondje čeka da na nju odgovorite kad se vratite.

Instalacija također dodaje web-aplikaciju za Tailscale administratorsku konzolu.

## Kad prestane raditi

Prije ponovnog pokretanja pokušajte samostalno ponovno pokrenuti problematični dio. _Ažuriraj > Hardware_ ima Wi-Fi, Bluetooth, Audio i Trackpad, a ponovno učitavanje jednog od njih rješava većinu situacija tipa „radilo je prije pet minuta“. Pogledajte [rješavanje problema](45-troubleshooting.md).
