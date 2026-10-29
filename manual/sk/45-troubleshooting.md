# Riešenie problémov

### Pokazil som si systém aktualizáciou!

Najprv skúste [vrátiť systém](47-system-snapshots.md) na verziu spred vašej nedávnej aktualizácie. Ak to nepomôže, použite `omarchy-debug` a zdieľajte svoj problém na #omarchy-help na Discorde. A ak zlyhá aj to, môžete znova nainštalovať predvolené konfigurácie a balíky pomocou `omarchy-reinstall`.

### Prečo sú niektoré aplikácie na mojom displeji také veľké?

Omarchy predpokladá 2x displej s vysokým rozlíšením, čo vyžaduje nastaviť `GDK_SCALE` na 2 v `~/.config/hypr/monitors.lua`. Ak však máte 1x displej, môžete zmeniť `local omarchy_gdk_scale = 2` na 1 (a potom reštartovať každú aplikáciu, ktorá je príliš veľká). Pozrite si [príručku o monitoroch](33-monitors.md).

Pri Spotify môžete použiť `Ctrl + Minus` na zmenšenie UI (a `Ctrl + Plus` na jeho zväčšenie).

### Prečo mi prestali fungovať všetky klávesové skratky so Super?

Na niektorých laptopoch ASUS ROG a TUF je `Fn + Super` ľahko prehliadnuteľná kombinácia klávesov, ktorá prepína firmvérový zámok klávesu Windows (určený na hranie, aby ste omylom neodišli z hry). Nič na obrazovke vám nepovie, že sa to stalo. Kým je zámok zapnutý, Super nevysiela vôbec nič — takže každá skratka Omarchy, ktorá používa Super, jednoducho prestane fungovať a vyzerá to, akoby sa pokazil Hyprland.

Stlačte `Fn + Super` raz, skôr než sa začnete hrabať v `~/.config/hypr/`, a ak to Super nevráti späť, stlačte to znova, aby ste nenechali zámok zapnutý. Toto nie je Fn-lock, ktorý mení iba to, čo robí rad F-klávesov.

### Moje Wi-Fi, Bluetooth, zvuk alebo trackpad práve prestali fungovať

Skôr než reštartujete počítač, skúste reštartovať problémový subsystém samostatne. _Update > Hardware_ v menu Omarchy obsahuje Wi-Fi, Bluetooth, Audio a Trackpad a opätovné načítanie jedného z nich vyrieši väčšinu situácií typu „pred piatimi minútami to fungovalo“ — Bluetooth slúchadlá, ktoré sa nechcú znova pripojiť, trackpad, ktorý po uspávaní prestal reagovať, zvuk, ktorý zmizol, keď ste odpojili monitor.

### Prečo moje externé reproduktory nehrajú?

Pravdepodobne preto, že nie sú nastavené ako primárny výstup. Kliknite na ikonu reproduktora na pravej strane panela a otvorí sa vyskakovacie okno hlasitosti, v ktorom si môžete vybrať výstupné zariadenie (a tiež miešať hlasitosti jednotlivých aplikácií).

### Reproduktory môjho laptopu znejú divne

Na niektorých laptopoch Omarchy automaticky použije ladenie reproduktorov, ktoré koriguje frekvenčnú odozvu vstavaných reproduktorov. `omarchy audio tuning status` vám povie, či je na vašom počítači nejaké aktívne, a `omarchy audio tuning off` ho vypne, ak chcete radšej počuť reproduktory bez úprav.

### Prečo sa nemôžem prihlásiť ani použiť sudo so svojím heslom?

Pravdepodobne ste ho príliš veľakrát zadali nesprávne a boli ste zablokovaní. Ak sa to deje na uzamknutej obrazovke, môžete stlačiť `CTRL + ALT + F2` a spustiť nové TTY, kde sa môžete prihlásiť ako root, a potom spustiť `faillock --reset --user [your-username]`. Tým sa zablokovanie resetuje a môžete pokračovať.

### Prečo sa mi nezobrazujú výzvy na autorizáciu 1Password pre 1Password SSH Agent / CLI?

Môže sa to stať z 2 dôvodov:

Aby sa zobrazila rozšírená výzva na schválenie, musí byť zapnuté Settings > Advanced > Use Hardware Acceleration. _Poznámka: Aby to začalo fungovať, je potrebný reštart._

 ![troubleshooting-1password](images/troubleshooting-1password.webp)

Alebo ak ste od spustenia systému nespustili 1Password, výzva sa nezobrazí.
