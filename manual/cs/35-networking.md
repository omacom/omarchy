# Síťové připojení

Síťové připojení v Omarchy zajišťuje NetworkManager a ovládáte ho z ikony sítě v [horní liště](05-the-top-bar.md) nebo pomocí `Super + Ctrl + N`.

Ten panel vyhledává sítě Wi-Fi, ukazuje sílu signálu a připojuje vás. Ethernet nepotřebuje vůbec nic — stačí ho zapojit a funguje. Pokud raději zůstanete v terminálu, `nmtui` vám poskytne stejné ovládání a existuje i skupina příkazů `omarchy network`.

## Sdílení vaší Wi-Fi

Místo abyste nahlas předčítali dlouhé heslo, spusťte během připojení k Wi-Fi _Nastavení > Síť > QR kód_. Na obrazovce se objeví QR kód, který může libovolný fotoaparát telefonu naskenovat a připojit se. Je to jedna z těch věcí, které budete používat častěji, než byste čekali, jakmile o ní budete vědět.

Pokud skutečně potřebujete samotné heslo, příkaz `omarchy network password <interface>` ho vytiskne.

## DNS

Omarchy používá takové DNS, jaké vaše síť předá přes DHCP. Pro celý počítač to můžete přepsat v _Nastavení > Síť > DNS_, kde jsou Cloudflare a Google na jedno kliknutí. Zvolte _Vlastní_ a zadejte své vlastní servery.

Z terminálu příkaz `omarchy dns` vytiskne aktuálního poskytovatele a `omarchy dns Cloudflare` jednoho nastaví.

## Připnutí pásma Wi-Fi

Pokud váš router uvádí 2.4GHz, 5GHz a 6GHz pod stejným názvem sítě, váš notebook se někdy bude držet toho pomalého. Příkaz `omarchy network band` ukáže, na kterém pásmu jste, a `omarchy network band 5` ho připne. Použijte `auto`, aby si opět vybíral sám.

Tím se připne pásmo, nikoli konkrétní přístupový bod, takže se mezi AP dál normálně přesouváte.

## Jak je to rychlé?

_Spouštěč > Test rychlosti > Test rychlosti sítě_ změří vaši skutečnou rychlost stahování a odesílání pomocí dvojice ukazatelů. Z terminálu je to `omarchy network speedtest down` nebo `up`. (V tom menu vedle toho sedí i test rychlosti disku, pokud zrovna měříte to druhé úzké hrdlo.)

## Firewall

Firewall je ve výchozím nastavení zapnutý a blokuje veškerý příchozí provoz, s jedinou výjimkou: port 53317, aby [LocalSend](22-guis.md) fungoval hned po vybalení.

SSH je vypnuté, dokud ho nezapnete v _Nastavení > Zabezpečení > SSHD_, což spustí démona, otevře port 22 s omezením rychlosti proti útokům hrubou silou a autorizuje klíč. Docker je také zabezpečený, takže kontejnery nemohou samy sebe náhodou vystavit světu. Celý příběh najdete v části [zabezpečení](48-security.md).

## Tailscale

[Tailscale](https://tailscale.com/) je mesh VPN, díky níž je přístup ke všem vašim počítačům a serverům přes internet jednoduchý a bezpečný. Nainstalujete ji přes _Instalace > Služba > Tailscale_.

Tím získáte v liště panel Tailscale, který připojuje a odpojuje tailnet, přepíná účty a vybírá výstupní uzel — vaše vlastní počítače i regiony Mullvad se zobrazují v seznamu. Také prochází vaše počítače a právě tam sídlí Taildrop: vyberte počítač a stiskněte `s` pro odeslání souborů, nebo `c`, `n` a `d` pro zkopírování jeho IP, názvu či úplného názvu DNS. Ekvivalentem v terminálu je `omarchy tailscale send <machine> [file...]` a soubory zaslané vám automaticky přistanou v `~/Downloads`. Oznámení o doručení čeká, dokud ho kliknutím neotevřete nebo neodstraníte, takže soubor, který dorazí, když nejste u počítače, tam po vašem návratu stále bude čekat na vyřízení.

Instalace také přidá webovou aplikaci pro administrační konzoli Tailscale.

## Když to přestane fungovat

Před restartováním zkuste restartovat jen danou nefungující část samostatně. _Aktualizace > Hardware_ obsahuje Wi-Fi, Bluetooth, Audio a Trackpad a opětovné načtení jedné z těchto položek vyřeší většinu situací typu „před pěti minutami to fungovalo“. Viz [řešení problémů](45-troubleshooting.md).
