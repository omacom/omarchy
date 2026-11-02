# Řešení problémů

### Rozbil jsem si systém aktualizací!

Nejprve zkuste [vrátit systém](47-system-snapshots.md) do verze před vaší poslední aktualizací. Pokud to nepomůže, použijte `omarchy-debug` a podělte se o svůj problém na #omarchy-help na Discordu. A pokud selže i to, můžete výchozí konfigurace a balíčky přeinstalovat pomocí `omarchy-reinstall`.

### Proč jsou některé aplikace na mém displeji tak velké?

Omarchy předpokládá displej s vysokým rozlišením a škálováním 2x, takže nastavuje `GDK_SCALE` na 2, dokud si na panelu monitoru nezvolíte škálování. Pokud máte displej se škálováním 1x a aplikace GTK nebo X11 vycházejí příliš velké, zvolte pro něj na panelu monitoru 1x, nebo přidejte `hl.env("GDK_SCALE", "1")` do `~/.config/hypr/monitors.lua` (a pak restartujte všechny aplikace, které jsou příliš velké). Viz [příručka o monitorech](33-monitors.md).

U Spotify můžete uživatelské rozhraní zmenšit pomocí `Ctrl + Minus` (a zvětšit pomocí `Ctrl + Plus`).

### Proč mi přestaly fungovat všechny klávesové zkratky s klávesou Super?

U některých notebooků ASUS ROG a TUF je `Fn + Super` snadno přehlédnutelná kombinace, která přepíná firmwarový zámek klávesy Windows (určený pro hraní, abyste omylem neodešli ze hry). Nic na obrazovce vám neřekne, že k tomu došlo. Když je zámek zapnutý, Super nevysílá vůbec nic — takže každá zkratka Omarchy, která Super používá, prostě přestane fungovat a vypadá to, jako by se rozbil Hyprland.

Než se začnete hrabat v `~/.config/hypr/`, stiskněte jednou `Fn + Super`, a pokud to Super nevrátí, stiskněte to znovu, abyste zámek nenechali zapnutý. Nejde o Fn-lock, který mění jen to, co dělá řada F-kláves.

### Právě mi přestala fungovat Wi-Fi, Bluetooth, zvuk nebo trackpad

Než budete restartovat, zkuste nejprve restartovat jen problematický subsystém samotný. _Aktualizovat > Hardware_ v nabídce Omarchy obsahuje Wi-Fi, Bluetooth, Zvuk a Trackpad a opětovné načtení jednoho z nich vyřeší většinu situací typu „před pěti minutami to fungovalo“ — Bluetooth sluchátka, která se nechtějí znovu připojit, trackpad, který přestal reagovat po uspání, zvuk, který zmizel, když jste odpojili monitor.

### Proč mi nehrají externí reproduktory?

Pravděpodobně proto, že nejsou nastavené jako primární výstup. Klikněte na ikonu reproduktoru na pravé straně lišty a otevře se vám vyskakovací okno hlasitosti, kde si můžete vybrat výstupní zařízení (a taky míchat hlasitosti jednotlivých aplikací).

### Reproduktory mého notebooku znějí divně

U některých notebooků Omarchy automaticky používá ladění reproduktorů, které koriguje frekvenční odezvu vestavěných reproduktorů. `omarchy audio tuning status` vám řekne, zda je na vašem počítači nějaké aktivní, a `omarchy audio tuning off` ho vypne, pokud raději chcete slyšet reproduktory bez úprav.

### Proč se nemůžu přihlásit ani použít sudo se svým heslem?

Pravděpodobně jste ho zadali příliš mnohokrát nesprávně a systém vás zamkl. Pokud se to děje na zamykací obrazovce, můžete stiskem `CTRL + ALT + F2` spustit nový TTY, kde se přihlásíte jako root, a poté spustit příkaz `faillock --reset --user [your-username]`. Tím zrušíte zablokování přihlášení a můžete pokračovat.

### Heslo je přijato, ale vracím se na přihlašovací obrazovku

Rozbitý soubor s proměnnými prostředí relace může zabránit spuštění desktopu, i když je vaše heslo správné. Stojí za to to zkontrolovat zejména po úpravách v `~/.config/uwsm/env.d/`.

Stiskněte `Ctrl + Alt + F2`, přihlaste se svým obvyklým uživatelským jménem a heslem a prohlédněte si uživatelský žurnál aktuálního startu:

```bash
journalctl --user -b -t uwsm_env-preloader --no-pager
```

Hledejte chybu, která jmenuje jeden z vašich souborů s prostředím, například `bad substitution`, těsně před zprávou, že nebyla nalezena značka výstupu prostředí. Než se zkusíte přihlásit znovu, přesuňte tento soubor mimo `env.d`. Pokud například chyba jmenuje `99-custom`:

```bash
mkdir -p ~/.config/uwsm/disabled
mv -i ~/.config/uwsm/env.d/99-custom ~/.config/uwsm/disabled/
```

UWSM přeskočí soubor se syntaktickou chybou, ale fatální chyba, která se projeví až při spuštění souboru, například `bad substitution`, může desktopu stále zabránit ve startu. Návrat k systémovému snímku tyto soubory neopraví, protože `/home` se nevrací.

Jakmile se přihlásíte, opravte uloženou kopii, než ji přesunete zpět. `sh -n` zachytí syntaktické chyby bez spuštění souboru, ale nezachytí každou chybu, která nastane při jeho načtení. Při testování změn mějte otevřený funkční terminál.

### Proč se mi nezobrazují autorizační výzvy 1Password pro 1Password SSH Agent / CLI?

K tomu může dojít ze 2 důvodů:

Aby se zobrazila plnohodnotná výzva ke schválení, musí být zapnutá volba Settings > Advanced > Use Hardware Acceleration. _Poznámka: Aby to začalo fungovat, je nutný restart._

 ![troubleshooting-1password](images/troubleshooting-1password.webp)

Nebo pokud jste od spuštění počítače 1Password ještě nespustili, výzva se nezobrazí.
