# Sieť

Sieť v Omarchy spravuje NetworkManager a ovládate ju z ikony siete v [hornej lište](05-the-top-bar.md) alebo pomocou `Super + Ctrl + N`.

Tento panel vyhľadáva siete Wi-Fi, ukazuje silu signálu a pripája sa k nim. Ethernet nepotrebuje vôbec nič — zapojíte ho a funguje. Ak radšej zostanete v termináli, `nmtui` vám dá rovnaké ovládanie a existuje aj skupina príkazov `omarchy network`.

## Zdieľanie vašej Wi-Fi

Namiesto toho, aby ste nahlas čítali dlhé heslo, spustite _Nastavenie > Sieť > QR kód_, keď ste na Wi-Fi. Na obrazovke sa zobrazí QR kód, ktorý môže naskenovať fotoaparát akéhokoľvek telefónu a pripojiť sa. Je to jedna z tých vecí, ktoré budete používať častejšie, než by ste čakali, keď už viete, že tam je.

Ak skutočne potrebujete samotné heslo, vypíše ho `omarchy network password <interface>`.

## DNS

Omarchy používa akékoľvek DNS, ktoré vaša sieť poskytne cez DHCP. Pre celý počítač to môžete prepísať v _Nastavenie > Sieť > DNS_, kde sú Cloudflare a Google vzdialené na jedno kliknutie. Vyberte _Vlastné_, ak chcete zadať vlastné servery.

Z terminálu `omarchy dns` vypíše aktuálneho poskytovateľa a `omarchy dns Cloudflare` jedného nastaví.

## Pripnutie pásma Wi-Fi

Ak váš router používa pre 2.4GHz, 5GHz a 6GHz rovnaký názov siete, váš notebook sa niekedy bude držať toho pomalého. `omarchy network band` ukáže, na ktorom pásme ste, a `omarchy network band 5` ho pripne. Použite `auto`, aby si znova vyberal sám.

Tým sa pripne pásmo, a nie konkrétny prístupový bod, takže sa naďalej normálne presúvate medzi APs.

## Aké je to rýchle?

_Spúšťač > Test rýchlosti > Test rýchlosti siete_ meria vašu skutočnú rýchlosť sťahovania a odosielania pomocou dvojice ciferníkov. Z terminálu je to `omarchy network speedtest down` alebo `up`. Meria voči vlastnej službe Omarchy a počíta len svoje testovacie prenosy. Iné sťahovania môžu súťažiť o šírku pásma, ale do výsledku testu rýchlosti sa nepripočítavajú. (V tom menu je hneď vedľa aj test rýchlosti disku, ak meriate to druhé úzke hrdlo.)

## Firewall

Firewall je predvolene zapnutý a blokuje všetku prichádzajúcu prevádzku, s jednou výnimkou: port 53317, aby [LocalSend](22-guis.md) fungoval hneď po inštalácii.

SSH je vypnuté, kým ho nezapnete pomocou _Nastavenie > Zabezpečenie > SSHD_, čo spustí démona, otvorí port 22 s obmedzením rýchlosti proti útokom hrubou silou a autorizuje kľúč. Docker je tiež uzamknutý, takže kontajnery sa nemôžu náhodou vystaviť svetu. Celý príbeh nájdete v časti [zabezpečenie](48-security.md).

## Tailscale

[Tailscale](https://tailscale.com/) je mesh VPN, vďaka ktorej je prístup ku všetkým vašim počítačom a serverom cez internet jednoduchý a bezpečný. Nainštalujete ho pomocou _Inštalácia > Služba > Tailscale_.

Získate tak panel Tailscale v lište, ktorý pripája a odpája tailnet, prepína účty a vyberá výstupný uzol — v zozname sa zobrazia vaše vlastné počítače aj regióny Mullvad. Prechádza tiež vaše počítače a práve tam žije Taildrop: vyberte počítač a stlačte `s`, ak mu chcete poslať súbory, alebo `c`, `n` a `d`, ak chcete skopírovať jeho IP, názov alebo úplný názov DNS. Ekvivalentom v termináli je `omarchy tailscale send <machine> [file...]` a súbory poslané vám automaticky pristanú v `~/Downloads`. Oznámenie o príchode čaká, kým ho kliknutím otvoríte alebo zrušíte, takže súbor, ktorý príde, keď ste preč od počítača, tam na vás stále čaká, keď sa vrátite.

Jeho inštalácia pridá aj webovú aplikáciu pre administračnú konzolu Tailscale.

## Keď to prestane fungovať

Pred reštartovaním skúste reštartovať len problematickú časť samostatne. _Aktualizácia > Hardvér_ obsahuje Wi-Fi, Bluetooth, Audio a Trackpad a opätovné načítanie jedného z nich vyrieši väčšinu situácií typu „pred piatimi minútami to fungovalo“. Pozrite si [riešenie problémov](45-troubleshooting.md).
