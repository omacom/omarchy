# Řešení problémů

### Rozbil jsem si systém aktualizací!

Nejprve zkuste [vrátit systém](47-system-snapshots.md) do verze před vaší poslední aktualizací. Pokud to nepomůže, použijte `omarchy-debug` a podělte se o svůj problém na #omarchy-help na Discordu. A pokud selže i to, můžete výchozí konfigurace a balíčky přeinstalovat pomocí `omarchy-reinstall`.

### Proč jsou některé aplikace na mém displeji tak velké?

Omarchy předpokládá displej s vysokým rozlišením a škálováním 2x, což vyžaduje nastavení `GDK_SCALE` na 2 v `~/.config/hypr/monitors.lua`. Pokud ale máte displej se škálováním 1x, můžete změnit `local omarchy_gdk_scale = 2` na 1 (a pak restartovat všechny aplikace, které jsou příliš velké). Viz [příručka o monitorech](33-monitors.md).

U Spotify můžete uživatelské rozhraní zmenšit pomocí `Ctrl + Minus` (a zvětšit pomocí `Ctrl + Plus`).

### Proč mi přestaly fungovat všechny klávesové zkratky s klávesou Super?

U některých notebooků ASUS ROG a TUF je `Fn + Super` snadno přehlédnutelná kombinace, která přepíná firmwarový zámek klávesy Windows (určený pro hraní, abyste omylem neodešli ze hry). Nic na obrazovce vám neřekne, že k tomu došlo. Když je zámek zapnutý, Super nevysílá vůbec nic — takže každá zkratka Omarchy, která Super používá, prostě přestane fungovat a vypadá to, jako by se rozbil Hyprland.

Než se začnete hrabat v `~/.config/hypr/`, stiskněte jednou `Fn + Super`, a pokud to Super nevrátí, stiskněte to znovu, abyste zámek nenechali zapnutý. Nejde o Fn-lock, který mění jen to, co dělá řada F-kláves.

### Právě mi přestala fungovat Wi-Fi, Bluetooth, zvuk nebo trackpad

Než budete restartovat, zkuste nejprve restartovat jen problematický subsystém samotný. _Update > Hardware_ v nabídce Omarchy obsahuje Wi-Fi, Bluetooth, Audio a Trackpad a opětovné načtení jednoho z nich vyřeší většinu situací typu „před pěti minutami to fungovalo“ — Bluetooth sluchátka, která se nechtějí znovu připojit, trackpad, který přestal reagovat po uspání, zvuk, který zmizel, když jste odpojili monitor.

### Proč mi nehrají externí reproduktory?

Pravděpodobně proto, že nejsou nastavené jako primární výstup. Klikněte na ikonu reproduktoru na pravé straně lišty a otevře se vám vyskakovací okno hlasitosti, kde si můžete vybrat výstupní zařízení (a taky míchat hlasitosti jednotlivých aplikací).

### Reproduktory mého notebooku znějí divně

U některých notebooků Omarchy automaticky používá ladění reproduktorů, které koriguje frekvenční odezvu vestavěných reproduktorů. `omarchy audio tuning status` vám řekne, zda je na vašem počítači nějaké aktivní, a `omarchy audio tuning off` ho vypne, pokud raději chcete slyšet reproduktory bez úprav.

### Proč se nemůžu přihlásit ani použít sudo se svým heslem?

Pravděpodobně jste ho příliš mnohokrát zadali špatně a systém vás zablokoval. Pokud se to děje na zamykací obrazovce, můžete stisknout `CTRL + ALT + F2`, čímž spustíte nové TTY, kde se můžete přihlásit jako root, a pak spustit `faillock --reset --user [your-username]`. Tím blokování resetujete a můžete pokračovat.

### Proč se mi nezobrazují autorizační výzvy 1Password pro 1Password SSH Agent / CLI?

K tomu může dojít ze 2 důvodů:

Aby se zobrazila plnohodnotná výzva ke schválení, musí být zapnutá volba Settings > Advanced > Use Hardware Acceleration. _Poznámka: Aby to začalo fungovat, je nutný restart._

 ![troubleshooting-1password](images/troubleshooting-1password.webp)

Nebo pokud jste od spuštění počítače 1Password ještě nespustili, výzva se nezobrazí.
