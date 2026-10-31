# Riešenie problémov

### Aktualizácia mi rozbila systém!

Najprv skúste [vrátiť systém](47-system-snapshots.md) na verziu pred nedávnou aktualizáciou. Ak to nepomôže, použite `omarchy-debug` a podeľte sa o svoj problém na #omarchy-help na Discorde. A ak zlyhá aj to, môžete pomocou `omarchy-reinstall` preinštalovať predvolené konfigurácie a balíky.

### Prečo sú niektoré aplikácie na mojom displeji také veľké?

Omarchy predpokladá 2x displej s vysokým rozlíšením, takže nastavuje `GDK_SCALE` na 2, kým si v paneli monitora nevyberiete mierku. Ak máte 1x displej a GTK alebo X11 aplikácie vyzerajú príliš veľké, vyberte preň v paneli monitora 1x, alebo pridajte `hl.env("GDK_SCALE", "1")` do `~/.config/hypr/monitors.lua` (a potom reštartujte každú aplikáciu, ktorá je príliš veľká). Pozrite si [manuál o monitoroch](33-monitors.md).

V Spotify môžete pomocou `Ctrl + Minus` zmenšiť používateľské rozhranie (a pomocou `Ctrl + Plus` ho zväčšiť).

### Prečo mi prestali fungovať všetky klávesové skratky so Super?

Na niektorých laptopoch ASUS ROG a TUF je `Fn + Super` ľahko prehliadnuteľná kombinácia, ktorá prepína firmvérový zámok klávesu Windows (určený na hranie, aby ste omylom neodišli z hry). Na obrazovke nič nenaznačuje, že sa to stalo. Kým je zámok zapnutý, Super nevydáva vôbec nič — takže každá skratka Omarchy, ktorá používa Super, jednoducho prestane fungovať a vyzerá to, akoby sa pokazil Hyprland.

Skôr než sa začnete hrabať v `~/.config/hypr/`, stlačte raz `Fn + Super`, a ak to Super nevráti, stlačte ho znova, aby ste zámok nenechali zapnutý. Nie je to Fn-lock, ktorý mení len správanie radu F klávesov.

### Práve mi prestalo fungovať Wi-Fi, Bluetooth, zvuk alebo trackpad

Skôr než reštartujete počítač, skúste reštartovať len problematický subsystém samostatne. _Update > Hardware_ v menu Omarchy obsahuje Wi-Fi, Bluetooth, Audio a Trackpad a opätovné načítanie jedného z nich vyrieši väčšinu situácií typu „pred piatimi minútami to fungovalo“ — Bluetooth slúchadlá, ktoré sa nechcú znova pripojiť, trackpad, ktorý po uspaní prestal reagovať, zvuk, ktorý zmizol po odpojení monitora.

### Prečo mi nehrajú externé reproduktory?

Pravdepodobne preto, že nie sú nastavené ako hlavný výstup. Kliknite na ikonu reproduktora na pravej strane lišty a otvorí sa vyskakovacie okno hlasitosti, kde si môžete vybrať výstupné zariadenie (a nastaviť aj hlasitosť jednotlivých aplikácií).

### Reproduktory môjho laptopu znejú čudne

Na niektorých laptopoch Omarchy automaticky použije ladenie reproduktorov, ktoré koriguje frekvenčnú odozvu vstavaných reproduktorov. `omarchy audio tuning status` vám povie, či je nejaké na vašom počítači aktívne, a `omarchy audio tuning off` ho vypne, ak chcete reproduktory počuť bez úprav.

### Prečo sa nemôžem prihlásiť alebo použiť sudo so svojím heslom?

Pravdepodobne ste ho príliš veľakrát zadali nesprávne a účet sa vám uzamkol. Ak sa to deje na uzamknutej obrazovke, môžete stlačiť `CTRL + ALT + F2`, čím spustíte nové TTY, kde sa môžete prihlásiť ako root, a potom spustiť `faillock --reset --user [your-username]`. Tým sa uzamknutie zruší a môžete pokračovať.

### Prečo sa mi nezobrazujú výzvy na autorizáciu 1Password pre 1Password SSH Agent / CLI?

Môže sa to stať z 2 dôvodov:

Aby sa zobrazila plnohodnotná výzva na schválenie, musí byť zapnuté Settings > Advanced > Use Hardware Acceleration. _Poznámka: Aby to začalo fungovať, je potrebný reštart._

 ![troubleshooting-1password](images/troubleshooting-1password.webp)

Alebo ak ste od spustenia počítača nespustili 1Password, výzva sa nezobrazí.
