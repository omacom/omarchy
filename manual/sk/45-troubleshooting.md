# Riešenie problémov

### Pokazil som si systém aktualizáciou!

Najskôr skúste [vrátiť systém späť](47-system-snapshots.md) na verziu pred najnovšou aktualizáciou. Ak to nefunguje, použite `omarchy-debug` a podeľte sa o problém v kanáli #omarchy-help na Discorde. A ak všetko ostatné zlyhá, môžete znova nainštalovať predvolené konfigurácie a balíky pomocou `omarchy-reinstall`.

### Prečo sú niektoré aplikácie na mojom displeji také veľké?

Omarchy predpokladá displej s vysokým rozlíšením 2x, čo si vyžaduje nastavenie `GDK_SCALE` na hodnotu 2 v `~/.config/hypr/monitors.lua`. Ale ak máte displej 1x, môžete zmeniť `local omarchy_gdk_scale = 2` na 1 (a potom reštartovať každú aplikáciu, ktorá je príliš veľká). Pozrite si [príručku o monitoroch](33-monitors.md).

Pre Spotify môžete rozhranie zmenšiť skratkou `Ctrl + Minus` (a skratkou `Ctrl + Plus` ho zväčšiť).

### Moja Wi-Fi, Bluetooth, zvuk alebo trackpad práve prestali fungovať

Pred reštartom skúste reštartovať problematický podsystém samostatne. _Aktualizovať > Hardware_ v ponuke Omarchy má Wi-Fi, Bluetooth, Audio a Trackpad a opätovné načítanie jedného z nich vyrieši väčšinu situácií typu „pred piatimi minútami to fungovalo“ — slúchadlá Bluetooth, ktoré sa nechcú znova pripojiť, trackpad, ktorý po uspaní prestal reagovať, zvuk, ktorý zmizol, keď ste odpojili monitor.

### Prečo nehrajú moje externé reproduktory?

Pravdepodobne preto, že nie sú nastavené ako primárny výstup. Kliknite na ikonu reproduktora na pravej strane lišty a otvorí sa vyskakovacie okno hlasitosti, kde si môžete vybrať výstupné zariadenie (a mixovať aj hlasitosť jednotlivých aplikácií).

### Reproduktory môjho notebooku znejú divne

Na niektorých notebookoch Omarchy automaticky použije ladenie reproduktorov, ktoré koriguje frekvenčnú odozvu vstavaných reproduktorov. `omarchy audio tuning status` vám povie, či je niektoré na vašom stroji aktívne, a `omarchy audio tuning off` ho vypne, ak chcete radšej počuť reproduktory bez úprav.

### Prečo sa nemôžem prihlásiť alebo použiť sudo so svojím heslom?

Pravdepodobne ste ho príliš veľakrát zadali nesprávne a systém vás zamkol. Ak sa to deje na zamknutej obrazovke, môžete stlačiť `CTRL + ALT + F2` a spustiť nový TTY, kde sa môžete prihlásiť ako root, a potom spustiť `faillock --reset --user [your-username]`. Tým sa zamknutie zruší a môžete pokračovať.

### Prečo sa nezobrazujú moje výzvy na autorizáciu 1Password pre 1Password SSH Agent / CLI?

Môže sa to stať z 2 dôvodov:

Aby sa zobrazila bohatá výzva na schválenie, musí byť zapnutá možnosť Settings > Advanced > Use Hardware Acceleration. _Poznámka: Aby začala fungovať, je potrebný reštart._

 ![troubleshooting-1password](images/troubleshooting-1password.webp)

Alebo ak ste od zavedenia systému nespustili 1Password, výzva sa nezobrazí.
