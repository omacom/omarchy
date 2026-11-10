# Síťové připojení

Síťové připojení v Omarchy spravuje NetworkManager a ovládáte ho z ikony sítě v [horní liště](05-the-top-bar.md) nebo pomocí `Super + Ctrl + N`.

Tento panel vyhledává Wi-Fi sítě, ukazuje sílu signálu a připojuje se k nim. Ethernet nepotřebuje vůbec nic — zapojíte ho a funguje. Pokud raději zůstanete v terminálu, `nmtui` vám nabídne stejné ovládací prvky a existuje také skupina příkazů `omarchy network`.

## Sdílení vaší Wi-Fi

Místo abyste nahlas četli dlouhé heslo, spusťte _Setup > Network > QR Code_, když jste připojeni k Wi-Fi. Na obrazovce se tím zobrazí QR kód, který může naskenovat fotoaparát jakéhokoli telefonu a připojit se. Je to jedna z těch věcí, které budete používat častěji, než byste čekali, jakmile o ní budete vědět.

Pokud skutečně potřebujete samotné heslo, příkaz `omarchy network password <interface>` ho vytiskne.

## DNS

Omarchy používá DNS, které vaše síť předává přes DHCP. Pro celý počítač to můžete změnit v _Setup > Network > DNS_, kde jsou Cloudflare a Google na jedno kliknutí. Zvolte _Custom_, pokud chcete zadat vlastní servery.

Z terminálu příkaz `omarchy dns` vytiskne aktuálního poskytovatele a `omarchy dns Cloudflare` jednoho nastaví.

## Připnutí pásma Wi-Fi

Pokud váš router používá pro 2.4GHz, 5GHz a 6GHz stejný název sítě, váš notebook se někdy bude držet toho pomalého pásma. Příkaz `omarchy network band` ukáže, na kterém pásmu jste, a `omarchy network band 5` ho připne. Pomocí `auto` mu znovu dovolíte vybírat samostatně.

Tímto připnete pásmo, nikoli konkrétní přístupový bod, takže se dál normálně přesouváte mezi APs.

## Jak rychlé to je?

_Trigger > Speed Test > Network Speed Test_ měří vaši skutečnou rychlost stahování a odesílání pomocí dvojice ukazatelů. Z terminálu je to `omarchy network speedtest down` nebo `up`. Měření probíhá proti vlastní službě Omarchy a započítává pouze její testovací přenosy. Ostatní stahování mohou soupeřit o šířku pásma, ale do výsledku testu rychlosti se nepřičítají. (V tomto menu vedle něj najdete test rychlosti disku, pokud chcete změřit druhé úzké hrdlo.)

## Firewall

Firewall je ve výchozím nastavení zapnutý a blokuje veškerý příchozí provoz, s jedinou výjimkou: port 53317, aby [LocalSend](22-guis.md) fungoval okamžitě po instalaci.

SSH je vypnuté, dokud ho nezapnete v _Setup > Security > SSHD_, což spustí démona, otevře port 22 s omezením rychlosti proti brute force a autorizuje klíč. Docker je také uzamčený, takže kontejnery se nemohou náhodou vystavit světu. Celý příběh najdete v kapitole o [zabezpečení](48-security.md).

## Tailscale

[Tailscale](https://tailscale.com/) je mesh VPN, díky níž je přístup ke všem vašim počítačům a serverům přes internet jednoduchý a bezpečný. Nainstalujete ho přes _Install > Service > Tailscale_.

Tím získáte do lišty panel Tailscale, který připojuje a odpojuje tailnet, přepíná účty a vybírá výstupní uzel — v seznamu se objeví jak vaše vlastní počítače, tak regiony Mullvad. Umožňuje také procházet vaše počítače a právě tam žije Taildrop: vyberte počítač a stiskněte `s`, abyste mu poslali soubory, nebo `c`, `n` a `d` pro zkopírování jeho IP, názvu nebo úplného názvu DNS. Ekvivalentem v terminálu je `omarchy tailscale send <machine> [file...]` a soubory poslané vám automaticky přistanou v `~/Downloads`. Oznámení o doručení čeká, dokud ho kliknutím neotevřete nebo nezavřete, takže soubor, který dorazí ve vaší nepřítomnosti, tam pořád bude čekat na vyřízení, až se vrátíte.

Instalace rovněž přidá webovou aplikaci pro administrační konzoli Tailscale.

## Když to přestane fungovat

Než budete restartovat, zkuste restartovat pouze vadnou součást samostatně. _Update > Hardware_ obsahuje Wi-Fi, Bluetooth, Audio a Trackpad a opětovné načtení jedné z těchto položek vyřeší většinu situací typu „před pěti minutami to fungovalo“. Viz [řešení potíží](45-troubleshooting.md).
