# Řešení problémů

### Rozbil jsem si systém aktualizací!

Nejprve zkuste [vrátit systém zpět](47-system-snapshots.md) na verzi před poslední aktualizací. Pokud to nepomůže, použijte `omarchy-debug` a podělte se o svůj problém na #omarchy-help na Discordu. A pokud selže i to, můžete pomocí `omarchy-reinstall` znovu nainstalovat výchozí konfigurace a balíčky.

### Proč jsou některé aplikace na mém displeji tak velké?

Omarchy předpokládá displej s vysokým rozlišením a měřítkem 2x, takže nastavuje `GDK_SCALE` na 2, dokud si v panelu monitoru nezvolíte vlastní měřítko. Pokud máte displej s měřítkem 1x a aplikace GTK nebo X11 vycházejí příliš velké, vyberte pro něj v panelu monitoru 1x, nebo přidejte `hl.env("GDK_SCALE", "1")` do `~/.config/hypr/monitors.lua` (a pak restartujte všechny aplikace, které jsou příliš velké). Viz [manuál o monitorech](33-monitors.md).

U Spotify můžete pomocí `Ctrl + Minus` zmenšit uživatelské rozhraní (a pomocí `Ctrl + Plus` ho zvětšit).

### Proč mi přestaly fungovat všechny klávesové vazby se Super?

Na některých noteboocích ASUS ROG a TUF je `Fn + Super` snadno přehlédnutelná kombinace, která přepíná zámek klávesy Windows ve firmwaru (určený pro hraní, abyste náhodou neopustili hru). Nic na obrazovce vám nedá vědět, že se to stalo. Dokud je zámek zapnutý, Super neposílá vůbec nic — takže každá vazba Omarchy, která používá Super, prostě přestane fungovat a vypadá to, jako by se rozbil Hyprland.

Stiskněte jednou `Fn + Super`, než se začnete hrabat v `~/.config/hypr/`, a pokud to Super nevrátí, stiskněte ji znovu, abyste zámek nenechali zapnutý. Nejedná se o Fn-lock, který mění pouze to, co dělá řada kláves F.

### Wi-Fi, Bluetooth, zvuk nebo trackpad mi prostě přestaly fungovat

Než restartujete počítač, zkuste restartovat pouze daný subsystém samostatně. _Update > Hardware_ v nabídce Omarchy obsahuje Wi-Fi, Bluetooth, Audio a Trackpad a opětovné načtení některého z nich vyřeší většinu situací typu „před pěti minutami to fungovalo“ — Bluetooth sluchátka, která se nechtějí znovu připojit, trackpad, který přestal fungovat po uspání, nebo zvuk, který zmizel, když jste odpojili monitor.

### Proč mi nehrají externí reproduktory?

Pravděpodobně proto, že nejsou nastavené jako primární výstup. Klikněte na ikonu reproduktoru na pravé straně lišty a otevře se vyskakovací okno hlasitosti, kde si můžete vybrat výstupní zařízení (a také míchat hlasitosti jednotlivých aplikací).

### Reproduktory mého notebooku znějí divně

Na některých noteboocích Omarchy automaticky použije vyladění reproduktorů, které koriguje frekvenční odezvu vestavěných reproduktorů. `omarchy audio tuning status` vám řekne, zda je na vašem počítači nějaké aktivní, a `omarchy audio tuning off` ho vypne, pokud chcete reproduktory raději slyšet v surovém stavu.

### Proč se nemohu přihlásit ani použít sudo svým heslem?

Pravděpodobně jste ho desetkrát zadali špatně a byli jste uzamčeni. Uzamčení se samo zruší po dvou minutách. Pokud nemůžete čekat a děje se to na zamykací obrazovce, můžete stisknout `CTRL + ALT + F2` a spustit nové TTY, kde se můžete přihlásit jako root, a pak spustit `faillock --reset --user [your-username]`. Tím se uzamčení resetuje a můžete pokračovat.

### Heslo je přijato, ale vrátím se na přihlašovací obrazovku

Rozbitý soubor prostředí relace může zabránit spuštění plochy, i když je vaše heslo správné. To stojí za kontrolu zejména po úpravách `~/.config/uwsm/env.d/`.

Stiskněte `Ctrl + Alt + F2`, přihlaste se svým běžným uživatelským jménem a heslem a prohlédněte si uživatelský žurnál aktuálního startu systému:

```bash
journalctl --user -b -t uwsm_env-preloader --no-pager
```

Hledejte chybu, ve které je uveden některý z vašich souborů prostředí, například `bad substitution`, těsně před zprávou, že značka výstupu prostředí nebyla nalezena. Než se zkusíte znovu přihlásit, přesuňte tento soubor z `env.d` pryč. Pokud například chyba uvádí `99-custom`:

```bash
mkdir -p ~/.config/uwsm/disabled
mv -i ~/.config/uwsm/env.d/99-custom ~/.config/uwsm/disabled/
```

UWSM soubor s chybou syntaxe přeskočí, ale fatální chyba, která se projeví až při spuštění souboru, jako je `bad substitution`, může spuštění plochy stále zabránit. Vrácení systému pomocí snímku tyto soubory neopraví, protože `/home` se nevrací zpět.

Jakmile se dokážete přihlásit, opravte uloženou kopii, než ji přesunete zpět. `sh -n` zachytí chyby syntaxe, aniž by soubor spustil, ale nedokáže zachytit každou chybu, ke které dojde, když je soubor načten příkazem source. Při testování změn nechte otevřený funkční terminál.

### Proč se mi nezobrazují autorizační výzvy 1Password pro 1Password SSH Agent / CLI?

K tomu může dojít ze 2 důvodů:

Aby se zobrazila bohatá výzva ke schválení, musí být zapnutá volba Settings > Advanced > Use Hardware Acceleration. _Poznámka: Aby to začalo fungovat, je nutný restart._

 ![troubleshooting-1password](images/troubleshooting-1password.webp)

Nebo pokud jste od spuštění počítače nespustili 1Password, výzva se nezobrazí.
