# Riešenie problémov

### Pokazil som si systém aktualizáciou!

Najprv skúste [vrátiť systém](47-system-snapshots.md) na verziu pred vašou nedávnou aktualizáciou. Ak to nepomôže, použite `omarchy-debug` a podeľte sa o svoj problém na #omarchy-help na Discorde. A ak zlyhá aj to, môžete preinštalovať predvolené konfigurácie a balíčky pomocou `omarchy-reinstall`.

### Prečo sú niektoré aplikácie na mojej obrazovke také veľké?

Omarchy predpokladá 2x displej s vysokým rozlíšením, takže nastavuje `GDK_SCALE` na 2, kým si v paneli monitorov nevyberiete mierku. Ak máte 1x displej a aplikácie GTK alebo X11 vyzerajú nadrozmerné, vyberte preň 1x v paneli monitorov alebo pridajte `hl.env("GDK_SCALE", "1")` do `~/.config/hypr/monitors.lua` (a potom reštartujte každú aplikáciu, ktorá je nadrozmerná). Pozrite si [manuál o monitoroch](33-monitors.md).

V Spotify môžete použiť `Ctrl + Minus` na zmenšenie používateľského rozhrania (a `Ctrl + Plus` na jeho zväčšenie).

### Prečo mi prestali fungovať všetky klávesové skratky s klávesom Super?

Na niektorých laptopoch ASUS ROG a TUF je `Fn + Super` ľahko prehliadnuteľná kombinácia, ktorá prepína firmvérový zámok klávesu Windows (určený na hranie, aby ste omylom neodišli z hry). Na obrazovke sa nič neukáže, že sa to stalo. Kým je zámok zapnutý, Super nevysiela vôbec nič — takže každá skratka v Omarchy, ktorá používa Super, jednoducho prestane fungovať a vyzerá to, akoby sa pokazil Hyprland.

Stlačte `Fn + Super` raz, skôr než sa začnete hrabať v `~/.config/hypr/`, a ak to Super nevráti späť, stlačte to znova, aby ste nenechali zámok zapnutý. Toto nie je Fn-lock, ktorý mení len to, čo robí rad F-klávesov.

### Moje Wi-Fi, Bluetooth, audio alebo trackpad práve prestali fungovať

Skôr než reštartujete počítač, skúste reštartovať len problematický podsystém samostatne. _Update > Hardware_ v menu Omarchy obsahuje Wi-Fi, Bluetooth, Audio a Trackpad a opätovné načítanie jedného z nich vyrieši väčšinu situácií typu „pred piatimi minútami to fungovalo“ — headset Bluetooth, ktorý sa nechce znova pripojiť, trackpad, ktorý po uspaní prestal reagovať, zvuk, ktorý zmizol, keď ste odpojili monitor.

### Prečo moje externé reproduktory nehrajú?

Pravdepodobne preto, že nie sú nastavené ako primárny výstup. Kliknite na ikonu reproduktora na pravej strane panela a otvorí sa vyskakovacie okno hlasitosti, kde si môžete vybrať výstupné zariadenie (a tiež nastaviť hlasitosť pre jednotlivé aplikácie).

### Reproduktory môjho laptopu znejú divne

Na niektorých laptopoch Omarchy automaticky použije ladenie reproduktorov, ktoré koriguje frekvenčnú odozvu vstavaných reproduktorov. `omarchy audio tuning status` vám povie, či je nejaké na vašom počítači aktívne, a `omarchy audio tuning off` ho vypne, ak chcete radšej počuť reproduktory bez úprav.

### Prečo sa nemôžem prihlásiť ani použiť sudo so svojím heslom?

Pravdepodobne ste ho desaťkrát zadali nesprávne a zablokovali ste sa. Zablokovanie sa samo zruší po dvoch minútach. Ak nemôžete čakať a deje sa to na uzamknutej obrazovke, môžete stlačiť `CTRL + ALT + F2` a spustiť nové TTY, kde sa môžete prihlásiť ako root, a potom spustiť `faillock --reset --user [your-username]`. Tým sa zablokovanie resetuje a môžete pokračovať.

### Heslo je prijaté, ale vrátim sa na prihlasovaciu obrazovku

Poškodený súbor prostredia relácie môže zabrániť spusteniu pracovnej plochy, aj keď je vaše heslo správne. Toto sa oplatí skontrolovať najmä po úprave `~/.config/uwsm/env.d/`.

Stlačte `Ctrl + Alt + F2`, prihláste sa so svojím bežným používateľským menom a heslom a skontrolujte používateľský denník aktuálneho spustenia:

```bash
journalctl --user -b -t uwsm_env-preloader --no-pager
```

Hľadajte chybu, ktorá uvádza niektorý z vašich súborov prostredia, napríklad `bad substitution`, tesne pred správou, že sa nenašla značka výstupu env. Presuňte tento súbor z `env.d` preč, skôr než sa skúsite znova prihlásiť. Napríklad, ak chyba uvádza `99-custom`:

```bash
mkdir -p ~/.config/uwsm/disabled
mv -i ~/.config/uwsm/env.d/99-custom ~/.config/uwsm/disabled/
```

UWSM preskočí súbor s chybou syntaxe, ale závažná chyba, ktorá sa prejaví až počas behu súboru, ako napríklad `bad substitution`, môže stále zabrániť spusteniu pracovnej plochy. Vrátenie systému zo snímky tieto súbory neopraví, pretože `/home` sa nevracia späť.

Keď sa už môžete prihlásiť, opravte uloženú kópiu, skôr než ju presuniete späť. `sh -n` zachytí chyby syntaxe bez spustenia súboru, ale nedokáže zachytiť každú chybu, ktorá sa vyskytne, keď sa súbor načíta. Počas testovania zmien majte otvorený funkčný terminál.

### Prečo sa mi nezobrazujú výzvy na autorizáciu 1Password pre 1Password SSH Agent / CLI?

Môže sa to stať z 2 dôvodov:

Aby sa zobrazila rozšírená výzva na schválenie, musí byť zapnuté Settings > Advanced > Use Hardware Acceleration. _Poznámka: Aby to začalo fungovať, je potrebný reštart._

 ![troubleshooting-1password](images/troubleshooting-1password.webp)

Alebo ak ste od spustenia počítača nespustili 1Password, výzva sa nezobrazí.
