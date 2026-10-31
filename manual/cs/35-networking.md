# Síťové připojení

Síť v Omarchy zajišťuje NetworkManager a ovládáte ji přes ikonu sítě v [horní liště](05-the-top-bar.md) nebo zkratkou `Super + Ctrl + N`.

Tento panel vyhledává Wi-Fi sítě, ukazuje sílu signálu a připojuje se k nim. Ethernet nepotřebuje vůbec nic — zapojíte ho a funguje. Pokud raději zůstanete v terminálu, `nmtui` vám nabídne stejné ovládací prvky a existuje také skupina příkazů `omarchy network`.

## Sdílení vaší Wi-Fi

Místo abyste nahlas četli dlouhé heslo, spusťte _Setup > Network > QR Code_, když jste připojeni k Wi-Fi. Na obrazovce se tím zobrazí QR kód, který může naskenovat fotoaparát jakéhokoli telefonu a připojit se. Je to jedna z těch věcí, které budete používat častěji, než byste čekali, jakmile o ní budete vědět.

Pokud skutečně potřebujete samotné heslo, příkaz `omarchy network password <interface>` ho vytiskne.

## DNS

Omarchy používá DNS, které vaše síť předává přes DHCP. Pro celý počítač to můžete změnit v _Setup > Network > DNS_, kde jsou Cloudflare a Google na jedno kliknutí. Zvolte _Custom_, pokud chcete zadat vlastní servery.

Z terminálu příkaz `omarchy dns` vytiskne aktuálního poskytovatele a `omarchy dns Cloudflare` jednoho nastaví.

## Výběr pásma Wi-Fi

Pokud váš router používá pro pásma 2,4 GHz, 5 GHz a 6 GHz stejný název sítě, notebook se někdy připojí k pomalejšímu pásmu. Příkaz `omarchy network band` ukáže, ve kterém pásmu jste, a příkaz `omarchy network band 5` omezí připojení na 5 GHz. Pomocí `auto` znovu povolíte automatický výběr.

Omezí se pouze pásmo, nikoli konkrétní přístupový bod. Zařízení tak může nadále automaticky přecházet mezi přístupovými body.

## Jak rychlé to je?

_Trigger > Speed Test > Network Speed Test_ měří vaši skutečnou rychlost stahování a odesílání pomocí dvojice ukazatelů. Z terminálu je to `omarchy network speedtest down` nebo `up`. Měření probíhá proti vlastní službě Omarchy a započítává pouze její testovací přenosy. Ostatní stahování mohou soupeřit o šířku pásma, ale do výsledku testu rychlosti se nepřičítají. (V tomto menu vedle něj najdete test rychlosti disku, pokud chcete změřit druhé úzké hrdlo.)

## Firewall

Firewall je ve výchozím nastavení zapnutý a blokuje veškerý příchozí provoz, s jedinou výjimkou: port 53317, aby [LocalSend](22-guis.md) fungoval okamžitě po instalaci.

SSH je vypnuté, dokud ho nezapnete volbou _Nastavení > Zabezpečení > SSHD_, která spustí démona, otevře port 22 s omezením rychlosti proti útokům hrubou silou a autorizuje klíč. I Docker je uzamčený, aby se kontejnery nemohly nechtěně vystavit světu. Celý příběh najdete v části [zabezpečení](48-security.md).

## Tailscale

[Tailscale](https://tailscale.com/) je síťová VPN typu mesh, která umožňuje jednoduše a bezpečně dosáhnout na všechny vaše počítače a servery přes internet. Nainstalujete ji volbou _Instalovat > Služba > Tailscale_.

Na horní liště tím získáte ikonu Tailscale. Otevře ovládací panel, ve kterém se můžete připojit k síti Tailscale nebo se odpojit, přepnout účet a vybrat výstupní uzel — v seznamu se objeví vaše vlastní počítače i regiony sítě Mullvad. Zobrazuje také vaše počítače a nabízí Taildrop: vyberete počítač a stiskem `s` mu pošlete soubory, případně pomocí `c`, `n` a `d` zkopírujete jeho IP adresu, název nebo úplný název DNS. Ekvivalentem v terminálu je `omarchy tailscale send <machine> [file...]` a soubory odeslané vám automaticky skončí ve složce `~/Downloads`. Oznámení o doručení čeká, dokud na něj nekliknete a neotevřete ho nebo ho nezavřete, takže soubor, který dorazí, zatímco nejste u počítače, na vás po návratu stále čeká.

Instalace rovněž přidá webovou aplikaci pro administrační konzoli Tailscale.

## Když to přestane fungovat

Než budete restartovat, zkuste restartovat pouze vadnou součást samostatně. _Update > Hardware_ obsahuje Wi-Fi, Bluetooth, Audio a Trackpad a opětovné načtení jedné z těchto položek vyřeší většinu situací typu „před pěti minutami to fungovalo“. Viz [řešení potíží](45-troubleshooting.md).
