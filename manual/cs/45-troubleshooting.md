# Řešení potíží

### Rozbil jsem si systém aktualizací!

Nejprve zkuste [vrátit systém zpět](47-system-snapshots.md) na verzi před poslední aktualizací. Pokud to nepomůže, použijte `omarchy-debug` a podělte se o svůj problém v kanálu #omarchy-help na Discordu. A pokud selže i to, můžete výchozí konfigurace a balíčky znovu nainstalovat pomocí `omarchy-reinstall`.

### Proč jsou některé aplikace na mém displeji tak velké?

Omarchy předpokládá displej s vysokým rozlišením a měřítkem 2x, takže nastavuje `GDK_SCALE` na 2, dokud si v panelu monitoru nezvolíte vlastní měřítko. Pokud máte displej s měřítkem 1x a aplikace GTK nebo X11 vycházejí příliš velké, zvolte pro něj v panelu monitoru 1x, nebo přidejte `hl.env("GDK_SCALE", "1")` do `~/.config/hypr/monitors.lua` (a pak restartujte všechny aplikace, které jsou příliš velké). Viz [manuál k monitorům](33-monitors.md).

U Spotify můžete uživatelské rozhraní zmenšit pomocí `Ctrl + Minus` (a zvětšit pomocí `Ctrl + Plus`).

### Proč mi přestaly fungovat všechny klávesové zkratky s klávesou Super?

Na některých noteboocích ASUS ROG a TUF je `Fn + Super` snadno přehlédnutelná kombinace, která přepíná firmwarový zámek klávesy Windows (určený pro hraní her, abyste omylem neopustili hru). Na obrazovce se vám o tom nic neukáže. Když je zámek zapnutý, Super nevysílá vůbec nic — takže každá zkratka Omarchy, která Super používá, prostě přestane fungovat a vypadá to, jako by se rozbil Hyprland.

Než se začnete hrabat v `~/.config/hypr/`, stiskněte jednou `Fn + Super`, a pokud to Super nevrátí, stiskněte to znovu, abyste zámek nenechali zapnutý. Nejde o Fn-lock, který mění pouze to, co dělá řada kláves F.

### Právě mi přestala fungovat Wi-Fi, Bluetooth, zvuk nebo trackpad

Než budete restartovat počítač, zkuste restartovat samostatně jen daný nefunkční subsystém. _Update > Hardware_ v nabídce Omarchy obsahuje Wi-Fi, Bluetooth, Audio a Trackpad a opětovné načtení některého z nich vyřeší většinu situací typu „před pěti minutami to fungovalo“ — Bluetooth sluchátka, která se nechtějí znovu připojit, trackpad, který přestal reagovat po uspání, nebo zvuk, který zmizel po odpojení monitoru.

### Proč mi nehrají externí reproduktory?

Pravděpodobně proto, že nejsou nastavené jako primární výstup. Klikněte na ikonu reproduktoru na pravé straně lišty a otevře se vyskakovací okno hlasitosti, kde si můžete vybrat výstupní zařízení (a také míchat hlasitost jednotlivých aplikací).

### Reproduktory mého notebooku znějí divně

Na některých noteboocích Omarchy automaticky používá ladění reproduktorů, které koriguje frekvenční odezvu vestavěných reproduktorů. `omarchy audio tuning status` vám řekne, zda je na vašem počítači nějaké aktivní, a `omarchy audio tuning off` ho vypne, pokud chcete reproduktory raději slyšet bez úprav.

### Proč se nemůžu přihlásit nebo použít sudo se svým heslem?

Pravděpodobně jste ho příliš mnohokrát zadali špatně a byli jste uzamčeni. Pokud se to děje na zamykací obrazovce, můžete stisknout `CTRL + ALT + F2` a spustit nové TTY, kde se můžete přihlásit jako root, a pak spustit `faillock --reset --user [your-username]`. Tím se uzamčení resetuje a můžete pokračovat.

### Heslo je přijato, ale vrátím se na přihlašovací obrazovku

Poškozený soubor prostředí relace může zabránit spuštění pracovní plochy, i když je vaše heslo správné. To stojí za kontrolu zejména po úpravách `~/.config/uwsm/env.d/`.

Stiskněte `Ctrl + Alt + F2`, přihlaste se svým běžným uživatelským jménem a heslem a prohlédněte si uživatelský žurnál aktuálního spuštění:

```bash
journalctl --user -b -t uwsm_env-preloader --no-pager
```

Hledejte chybu, která jmenuje některý z vašich souborů prostředí, například `bad substitution`, těsně před zprávou, že značka výstupu prostředí nebyla nalezena. Než se zkusíte znovu přihlásit, přesuňte tento soubor z `env.d` pryč. Například pokud chyba jmenuje `99-custom`:

```bash
mkdir -p ~/.config/uwsm/disabled
mv -i ~/.config/uwsm/env.d/99-custom ~/.config/uwsm/disabled/
```

UWSM přeskočí soubor s chybou syntaxe, ale fatální chyba, která se projeví až při běhu souboru, jako je `bad substitution`, může spuštění pracovní plochy stále zabránit. Vrácení systémového snímku tyto soubory neopraví, protože `/home` se nevrací.

Jakmile se budete moct přihlásit, opravte uloženou kopii, než ji přesunete zpět. `sh -n` zachytí chyby syntaxe, aniž by soubor spustil, ale nedokáže zachytit každou chybu, která nastane při jeho načítání. Při testování změn mějte otevřený funkční terminál.

### Proč se mi nezobrazují výzvy k autorizaci 1Password pro 1Password SSH Agent / CLI?

K tomu může dojít ze 2 důvodů:

Aby se zobrazila bohatá výzva ke schválení, musí být zapnuté Settings > Advanced > Use Hardware Acceleration. _Poznámka: Aby to začalo fungovat, je nutný restart._

 ![troubleshooting-1password](images/troubleshooting-1password.webp)

Nebo pokud jste od spuštění počítače 1Password nespustili, výzva se nezobrazí.
