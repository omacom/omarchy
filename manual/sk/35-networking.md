# Siete

Siete v Omarchy má na starosti NetworkManager a ovládate ich cez ikonu siete v [hornej lište](05-the-top-bar.md) alebo skratkou `Super + Ctrl + W`.

Ten panel vyhľadá siete Wi-Fi, ukáže silu signálu a pripojí vás. Ethernet nepotrebuje vôbec nič — stačí ho zapojiť a funguje. Ak radšej zostávate v termináli, `nmtui` vám dáva rovnaké ovládacie prvky a existuje aj skupina príkazov `omarchy network`.

## Zdieľanie Wi-Fi

Namiesto toho, aby ste nahlas čítali dlhé heslo, spustite _Nastavenie > Sieť > QR kód_, keď ste na Wi-Fi. Tým sa na obrazovke zobrazí QR kód, ktorý dokáže naskenovať fotoaparát každého telefónu a pripojiť sa. Je to jedna z vecí, ktoré budete používať častejšie, než by ste čakali, keď viete, že tam je.

Ak skutočne potrebujete samotné heslo, `omarchy network password <interface>` ho vypíše.

## DNS

Omarchy používa také DNS, aké vaša sieť rozdáva cez DHCP. Môžete to prepísať pre celý stroj v časti _Nastavenie > Sieť > DNS_, kde sú Cloudflare a Google na jedno kliknutie. Vyberte _Vlastné_, ak chcete zadať vlastné servery.

Z terminálu `omarchy dns` vypíše aktuálneho poskytovateľa a `omarchy dns Cloudflare` jedného nastaví.

## Pripnutie pásma Wi-Fi

Ak váš smerovač dáva 2.4GHz, 5GHz a 6GHz na rovnaký názov siete, váš notebook sa niekedy bude držať toho pomalého pásma. `omarchy network band` ukáže, v ktorom pásme ste, a `omarchy network band 5` ho pripne. Použite `auto`, ak mu chcete dovoliť vyberať si znova.

Tým sa pripne pásmo, nie konkrétny prístupový bod, takže sa naďalej normálne prepájate medzi prístupovými bodmi.

## Ako rýchle to je?

_Akcie > Test rýchlosti > Test rýchlosti siete_ zmeria vašu skutočnú rýchlosť sťahovania a odosielania pomocou dvojice stupníc. Z terminálu je to `omarchy network speedtest down` alebo `up`. (Hneď vedľa v tej ponuke je aj test rýchlosti disku, ak práve meriate druhé úzke miesto.)

## Firewall

Firewall je predvolene zapnutý a blokuje všetku prichádzajúcu prevádzku, s jednou výnimkou: port 53317, aby [LocalSend](22-guis.md) fungoval hneď po vybalení.

SSH je vypnuté, kým ho nezapnete v časti _Nastavenie > Security > SSHD_, čo spustí démona, otvorí port 22 s obmedzením rýchlosti proti útokom hrubou silou a autorizuje kľúč. Aj Docker je uzamknutý, takže sa kontajnery nemôžu náhodne vystaviť svetu. Celý príbeh nájdete v časti [bezpečnosť](48-security.md).

## Tailscale

[Tailscale](https://tailscale.com/) je sieťová VPN typu mesh, vďaka ktorej je dosiahnutie všetkých vašich počítačov a serverov cez internet jednoduché a bezpečné. Nainštalujete ho cez _Inštalovať > Service > Tailscale_.

Tým získate panel Tailscale v lište, ktorý pripája a odpája tailnet, prepína účty a vyberá výstupný uzol — v zozname sa zobrazujú vaše vlastné stroje aj regióny Mullvad. Takisto prechádza vaše stroje a práve tam žije Taildrop: vyberte stroj a stlačte `s`, ak mu chcete poslať súbory, alebo `c`, `n` a `d`, ak chcete skopírovať jeho IP adresu, názov alebo úplný názov DNS. Ekvivalent v termináli je `omarchy tailscale send <machine> [file...]` a súbory poslané vám automaticky pristávajú v `~/Downloads`. Upozornenie oznamujúce príchod čaká, kým naň nekliknete a neotvoríte ho alebo ho nezavriete, takže súbor, ktorý dorazí, keď ste preč od stroja, tam stále čaká na odpoveď, keď sa vrátite.

Inštaláciou sa pridá aj webová aplikácia pre konzolu správcu Tailscale.

## Keď to prestane fungovať

Pred reštartom skúste reštartovať len ten problematický kus samostatne. _Aktualizovať > Hardware_ má Wi-Fi, Bluetooth, Audio a Trackpad a opätovné načítanie jedného z nich vyrieši väčšinu situácií typu „pred piatimi minútami to fungovalo“. Pozrite si [riešenie problémov](45-troubleshooting.md).
