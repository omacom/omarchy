# Sieť

Sieť v Omarchy spravuje NetworkManager a ovládate ju z ikony siete v [hornom paneli](05-the-top-bar.md) alebo pomocou `Super + Ctrl + N`.

Panel vyhľadá siete Wi-Fi, ukáže silu signálu a pripojí vás. S Ethernetom nemusíte robiť vôbec nič — stačí zapojiť kábel a funguje. Ak radšej zostanete v termináli, `nmtui` vám ponúkne rovnaké ovládanie a existuje aj skupina príkazov `omarchy network`.

## Zdieľanie Wi-Fi

Namiesto toho, aby ste nahlas čítali dlhé heslo, spustite _Setup > Network > QR Code_, keď ste pripojení k Wi-Fi. Na obrazovke sa zobrazí QR kód, ktorý môže naskenovať fotoaparát každého telefónu a pripojiť sa. Je to jedna z tých vecí, ktoré budete používať častejšie, než by ste čakali, keď už viete, že tam je.

Ak skutočne potrebujete samotné heslo, príkaz `omarchy network password <interface>` ho vypíše.

## DNS

Omarchy používa DNS, ktoré vaša sieť poskytne cez DHCP. Pre celý počítač to môžete prepísať v časti _Setup > Network > DNS_, kde sú Cloudflare a Google na jedno kliknutie. Ak chcete zadať vlastné servery, vyberte _Custom_.

Z terminálu príkaz `omarchy dns` vypíše aktuálneho poskytovateľa a `omarchy dns Cloudflare` jedného nastaví.

## Zafixovanie pásma Wi-Fi

Ak váš router používa pre 2.4GHz, 5GHz a 6GHz rovnaký názov siete, váš laptop sa niekedy bude držať toho pomalého. Príkaz `omarchy network band` ukáže, v ktorom pásme sa nachádzate, a `omarchy network band 5` ho zafixuje. Použite `auto`, ak chcete, aby si opäť vyberal sám.

Týmto sa zafixuje pásmo, nie konkrétny prístupový bod, takže sa normálne pohybujete medzi jednotlivými AP.

## Aké je to rýchle?

_Trigger > Speed Test > Network Speed Test_ zmeria vašu skutočnú rýchlosť sťahovania a odosielania pomocou dvojice ciferníkov. Z terminálu je to `omarchy network speedtest down` alebo `up`. (V tom menu je hneď vedľa test rýchlosti disku, ak chcete otestovať druhé úzke hrdlo.)

## Firewall

Firewall je predvolene zapnutý a blokuje všetku prichádzajúcu komunikáciu, s jednou výnimkou: port 53317, aby [LocalSend](22-guis.md) fungoval hneď po inštalácii.

SSH je vypnuté, kým ho nezapnete v časti _Setup > Security > SSHD_, ktorá spustí démona, otvorí port 22 s obmedzením frekvencie proti útokom hrubou silou a autorizuje kľúč. Aj Docker je zabezpečený, takže kontajnery sa nemôžu náhodou vystaviť svetu. Celý príbeh nájdete v časti [zabezpečenie](48-security.md).

## Tailscale

[Tailscale](https://tailscale.com/) je mesh VPN, vďaka ktorej je dosiahnutie všetkých vašich počítačov a serverov cez internet jednoduché a bezpečné. Nainštalujete ho cez _Install > Service > Tailscale_.

Získate tak panel Tailscale v paneli, ktorý pripája a odpája tailnet, prepína účty a vyberá výstupný uzol — v zozname sa zobrazia vaše vlastné počítače aj regióny Mullvad. Taktiež prehliada vaše počítače a práve tam žije Taildrop: vyberte počítač a stlačte `s`, ak mu chcete poslať súbory, alebo `c`, `n` a `d`, ak chcete skopírovať jeho IP, názov alebo úplný názov DNS. Ekvivalentom v termináli je `omarchy tailscale send <machine> [file...]` a súbory odoslané vám automaticky pristanú v `~/Downloads`. Oznámenie o príchode čaká, kým ho neotvoríte kliknutím alebo neodmietnete, takže súbor, ktorý príde, keď nie ste pri počítači, na vás počká, kým sa vrátite.

Inštaláciou sa pridá aj webová aplikácia pre administračnú konzolu Tailscale.

## Keď to prestane fungovať

Pred reštartovaním skúste reštartovať len problematickú časť samostatne. _Update > Hardware_ obsahuje Wi-Fi, Bluetooth, Audio a Trackpad a opätovné načítanie jedného z nich vyrieši väčšinu situácií typu „pred piatimi minútami to fungovalo“. Pozrite si [riešenie problémov](45-troubleshooting.md).
