# Riešenie problémov

### Pokazil som si systém aktualizáciou!

Najprv skúste [vrátiť systém späť](47-system-snapshots.md) na verziu pred vašou nedávnou aktualizáciou. Ak to nepomôže, použite `omarchy-debug` a podeľte sa o svoj problém v #omarchy-help na Discorde. A ak zlyhá aj to, môžete znova nainštalovať predvolené konfigurácie a balíky pomocou `omarchy-reinstall`.

### Prečo sú niektoré aplikácie na mojom displeji také veľké?

Omarchy predpokladá displej s vysokým rozlíšením a mierkou 2x, takže nastavuje `GDK_SCALE` na 2, kým si v paneli monitora nezvolíte mierku. Ak máte displej s mierkou 1x a aplikácie GTK alebo X11 vychádzajú nadrozmerné, vyberte preň v paneli monitora 1x alebo pridajte `hl.env("GDK_SCALE", "1")` do `~/.config/hypr/monitors.lua` (a potom reštartujte každú aplikáciu, ktorá je nadrozmerná). Pozrite si [príručku o monitoroch](33-monitors.md).

V Spotify môžete použiť `Ctrl + Minus` na zmenšenie používateľského rozhrania (a `Ctrl + Plus` na jeho zväčšenie).

### Prečo mi prestali fungovať všetky klávesové skratky so Super?

Na niektorých notebookoch ASUS ROG a TUF je `Fn + Super` ľahko prehliadnuteľná kombinácia, ktorá prepína firmvérový zámok klávesu Windows (určený na hranie, aby ste náhodou neopustili hru). Nič na obrazovke vám nepovie, že sa to stalo. Kým je zámok zapnutý, Super nevydáva vôbec nič — takže každá skratka Omarchy, ktorá používa Super, jednoducho prestane fungovať a vyzerá to, akoby sa pokazil Hyprland.

Skôr než sa začnete hrabať v `~/.config/hypr/`, stlačte raz `Fn + Super`, a ak to Super nevráti späť, stlačte to znova, aby ste zámok nenechali zapnutý. Nie je to Fn-lock, ktorý mení iba to, čo robí rad klávesov F.

### Moje Wi-Fi, Bluetooth, zvuk alebo trackpad práve prestali fungovať

Skôr než reštartujete počítač, skúste reštartovať len problematický subsystém samostatne. _Aktualizácia > Hardvér_ v ponuke Omarchy má Wi-Fi, Bluetooth, Zvuk a Trackpad a opätovné načítanie jedného z nich vyrieši väčšinu situácií typu „pred piatimi minútami to fungovalo“ — Bluetooth slúchadlá, ktoré sa nechcú znova pripojiť, trackpad, ktorý po uspaní prestal reagovať, zvuk, ktorý zmizol, keď ste odpojili monitor.

### Prečo moje externé reproduktory nehrajú?

Pravdepodobne preto, že nie sú nastavené ako primárny výstup. Kliknite na ikonu reproduktora na pravej strane panela a otvorí sa vyskakovacie okno hlasitosti, kde si môžete vybrať výstupné zariadenie (a tiež miešať hlasitosti jednotlivých aplikácií).

### Reproduktory môjho notebooku znejú čudne

Na niektorých notebookoch Omarchy automaticky použije ladenie reproduktorov, ktoré koriguje frekvenčnú odozvu vstavaných reproduktorov. `omarchy audio tuning status` vám povie, či je na vašom zariadení nejaké aktívne, a `omarchy audio tuning off` ho vypne, ak radšej chcete počuť reproduktory bez úprav.

### Prečo sa nemôžem prihlásiť alebo použiť sudo so svojím heslom?

Pravdepodobne ste ho príliš veľakrát zadali nesprávne a zablokovali ste sa. Ak sa to deje na uzamknutej obrazovke, môžete stlačiť `CTRL + ALT + F2` a spustiť nové TTY, kde sa môžete prihlásiť ako root, a potom spustiť `faillock --reset --user [your-username]`. Tým sa blokovanie resetuje a môžete pokračovať.

### Moje heslo je prijaté, ale vrátim sa na prihlasovaciu obrazovku

Poškodený súbor prostredia relácie môže zabrániť spusteniu pracovnej plochy, aj keď je vaše heslo správne. Toto sa obzvlášť oplatí skontrolovať po úprave `~/.config/uwsm/env.d/`.

Stlačte `Ctrl + Alt + F2`, prihláste sa so svojím bežným používateľským menom a heslom a skontrolujte používateľský denník aktuálneho spustenia:

```bash
journalctl --user -b -t uwsm_env-preloader --no-pager
```

Hľadajte chybu, ktorá pomenúva jeden z vašich súborov prostredia, napríklad `bad substitution`, tesne pred správou, že sa nenašla značka výstupu prostredia. Pred ďalším pokusom o prihlásenie presuňte tento súbor z `env.d`. Napríklad, ak chyba pomenúva `99-custom`:

```bash
mkdir -p ~/.config/uwsm/disabled
mv -i ~/.config/uwsm/env.d/99-custom ~/.config/uwsm/disabled/
```

UWSM preskočí súbor so syntaktickou chybou, ale závažná chyba, ktorá sa prejaví až počas behu súboru, napríklad `bad substitution`, môže stále zabrániť spusteniu pracovnej plochy. Vrátenie systému zo snímky tieto súbory neopraví, pretože `/home` sa nevracia späť.

Keď sa budete môcť prihlásiť, opravte uloženú kópiu, skôr než ju presuniete späť. `sh -n` zachytí syntaktické chyby bez spustenia súboru, ale nedokáže zachytiť každú chybu, ktorá nastane, keď sa načíta ako zdroj. Počas testovania zmien majte otvorený funkčný terminál.

### Prečo sa mi nezobrazujú autorizačné výzvy 1Password pre 1Password SSH Agent / CLI?

Môže sa to stať z 2 dôvodov:

Aby sa zobrazila bohatá výzva na schválenie, musí byť zapnuté Nastavenia > Pokročilé > Použiť hardvérovú akceleráciu. _Poznámka: Aby to začalo fungovať, je potrebný reštart._

 ![troubleshooting-1password](images/troubleshooting-1password.webp)

Alebo ak ste od spustenia systému nespustili 1Password, výzva sa nezobrazí.
