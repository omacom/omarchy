# Řešení potíží

### Aktualizací jsem si rozbil systém!

Nejprve zkuste [vrátit systém zpět](47-system-snapshots.md) na verzi před poslední aktualizací. Pokud to nepomůže, použijte příkaz `omarchy-debug`, pomocí kterého můžete svůj problém sdílet v kanálu #omarchy-help na Discordu. A pokud selže i to, můžete přeinstalovat výchozí konfigurace a balíčky příkazem `omarchy-reinstall`.

### Proč jsou některé aplikace na mém displeji tak velké?

Omarchy předpokládá displej s vysokým rozlišením 2x, což vyžaduje nastavení `GDK_SCALE` na hodnotu 2 v souboru `~/.config/hypr/monitors.lua`. Pokud jste ale na displeji 1x, můžete řádek `local omarchy_gdk_scale = 2` změnit na hodnotu 1 (a poté restartovat všechny příliš velké aplikace). Viz [příručka o monitorech](33-monitors.md).

U aplikace Spotify můžete rozhraní zmenšit zkratkou `Ctrl + Minus` (a zvětšit zkratkou `Ctrl + Plus`).

### Právě mi přestala fungovat Wi-Fi, Bluetooth, zvuk nebo touchpad

Než budete restartovat počítač, zkuste restartovat pouze daný problematický subsystém. Volba _Aktualizovat > Hardware_ v nabídce Omarchy nabízí Wi-Fi, Bluetooth, Zvuk a Touchpad a opětovné načtení některé z nich vyřeší většinu situací typu „před pěti minutami to fungovalo“ — náhlavní soupravu Bluetooth, která se nechce znovu připojit, touchpad, který po uspání přestal reagovat, nebo zvuk, který zmizel po odpojení monitoru.

### Proč mi nehrají externí reproduktory?

Pravděpodobně proto, že nejsou nastavené jako primární výstup. Klikněte na ikonu reproduktoru na pravé straně panelu a otevře se vyskakovací okno hlasitosti, kde si můžete zvolit výstupní zařízení (a také nastavit hlasitost pro jednotlivé aplikace).

### Reproduktory notebooku znějí divně

U některých notebooků Omarchy automaticky použije vyladění reproduktoru, které koriguje frekvenční odezvu vestavěných reproduktorů. Příkaz `omarchy audio tuning status` vám řekne, zda je nějaké na vašem počítači aktivní, a příkazem `omarchy audio tuning off` ho vypnete, pokud raději posloucháte reproduktory bez úprav.

### Proč se nemohu přihlásit nebo použít sudo se svým heslem?

Pravděpodobně jste ho zadali příliš mnohokrát nesprávně a systém vás zamkl. Pokud se to děje na zamykací obrazovce, můžete stiskem `CTRL + ALT + F2` spustit nový TTY, kde se přihlásíte jako root, a poté spustit příkaz `faillock --reset --user [your-username]`. Tím se uzamčení obnoví a můžete pokračovat.

### Proč se mi nezobrazují výzvy k autorizaci v aplikaci 1Password pro agenta 1Password SSH / rozhraní příkazového řádku?

Může k tomu docházet ze dvou důvodů:

Aby se zobrazila podrobná výzva ke schválení, musí být zapnutá volba Settings > Advanced > Use Hardware Acceleration. _Poznámka: Aby začala fungovat, vyžaduje restart počítače._

 ![troubleshooting-1password](images/troubleshooting-1password.webp)

Nebo, pokud jste aplikaci 1Password od zapnutí počítače nespustili, výzva se nezobrazí.
