# Řešení problémů

### Rozbil jsem si systém aktualizací!

Nejprve zkuste [vrátit systém zpět](47-system-snapshots.md) na verzi před poslední aktualizací. Pokud to nepomůže, použijte `omarchy-debug` a podělte se o svůj problém na #omarchy-help na Discordu. A pokud selže i to, můžete výchozí konfigurace a balíčky přeinstalovat pomocí `omarchy-reinstall`.

### Proč jsou některé aplikace na mém displeji tak velké?

Omarchy předpokládá displej s vysokým rozlišením a měřítkem 2x, takže nastavuje `GDK_SCALE` na 2, dokud si v panelu monitoru nezvolíte vlastní měřítko. Pokud máte displej s měřítkem 1x a aplikace GTK nebo X11 vycházejí příliš velké, vyberte pro něj v panelu monitoru 1x, nebo přidejte `hl.env("GDK_SCALE", "1")` do `~/.config/hypr/monitors.lua` (a pak restartujte každou aplikaci, která je příliš velká). Viz [příručka o monitorech](33-monitors.md).

U Spotify můžete použít `Ctrl + Minus` ke zmenšení rozhraní (a `Ctrl + Plus` k jeho zvětšení).

### Proč mi přestaly fungovat všechny vazby klávesy Super?

Na některých noteboocích ASUS ROG a TUF je `Fn + Super` snadno přehlédnutelná kombinace, která přepíná firmwarový zámek klávesy Windows (určený pro hraní, abyste omylem neopustili hru). Na obrazovce nic nenaznačuje, že se to stalo. Dokud je zámek zapnutý, Super nevydává vůbec nic — takže každá vazba Omarchy, která používá Super, prostě přestane fungovat a vypadá to, že se rozbil Hyprland.

Než se začnete hrabat v `~/.config/hypr/`, stiskněte jednou `Fn + Super`, a pokud to Super nevrátí, stiskněte to znovu, abyste zámek nenechali zapnutý. Nejde o Fn-lock, ten mění jen to, co dělá řada kláves F.

### Moje Wi-Fi, Bluetooth, zvuk nebo trackpad právě přestaly fungovat

Než budete restartovat, zkuste restartovat jen dotyčný subsystém samostatně. _Aktualizace > Hardware_ v nabídce Omarchy obsahuje Wi-Fi, Bluetooth, Zvuk a Trackpad a opětovné načtení jednoho z nich vyřeší většinu situací typu „před pěti minutami to fungovalo“ — Bluetooth sluchátka, která se nechtějí znovu připojit, trackpad, který po uspání přestal reagovat, zvuk, který zmizel po odpojení monitoru.

### Proč mi nehrají externí reproduktory?

Nejspíš proto, že nejsou nastavené jako primární výstup. Klikněte na ikonu reproduktoru na pravé straně lišty a otevře se vyskakovací okno hlasitosti, kde si můžete vybrat výstupní zařízení (a taky míchat hlasitosti jednotlivých aplikací).

### Reproduktory mého notebooku znějí divně

Na některých noteboocích Omarchy automaticky používá ladění reproduktorů, které koriguje frekvenční odezvu vestavěných reproduktorů. `omarchy audio tuning status` vám řekne, jestli je nějaké na vašem počítači aktivní, a `omarchy audio tuning off` ho vypne, pokud chcete reproduktory slyšet raději bez úprav.

### Proč se nemůžu přihlásit ani použít sudo svým heslem?

Nejspíš jste ho příliš mnohokrát zadali špatně a účet se vám zamkl. Pokud se to děje na zamykací obrazovce, můžete stisknout `CTRL + ALT + F2` a spustit nové TTY, kde se můžete přihlásit jako root, a pak spustit `faillock --reset --user [your-username]`. Tím zámek resetujete a můžete pokračovat.

### Proč se mi nezobrazují autorizační výzvy 1Password pro 1Password SSH Agent / CLI?

Může to mít 2 důvody:

Aby se zobrazila bohatá výzva ke schválení, musí být zapnuté Nastavení > Pokročilé > Použít hardwarovou akceleraci. _Poznámka: Aby to začalo fungovat, je nutný restart._

 ![troubleshooting-1password](images/troubleshooting-1password.webp)

Nebo pokud jste od spuštění systému nespustili 1Password, výzva se nezobrazí.
