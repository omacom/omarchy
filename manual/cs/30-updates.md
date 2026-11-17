# Aktualizace

Omarchy a vaše balíčky se udržují aktuální přes _Update > Omarchy_ v nabídce Omarchy (`Super + Space`).

Samotné Omarchy je nainstalované jako běžné balíčky pacman z [repozitáře balíčků Omarchy](https://github.com/omacom-io/omarchy-pkgs), takže aktualizace nainstaluje [nejnovější vydání Omarchy](https://github.com/omacom/omarchy/releases), spustí všechny čekající migrace, aby byl váš systém synchronizovaný s nejnovější verzí, a aktualizuje všechny systémové balíčky z [mirroru Omarchy Arch](https://github.com/omacom-io/omarchy-mirror) a [AUR](https://aur.archlinux.org/) (pokud máte nainstalované nějaké balíčky z AUR).

Když vyjdou nová vydání, objeví se vpravo od vašich hodin ikona kruhové šipky. Klikněte na ni a proces aktualizace se spustí.

![update-available](images/update-available.webp)

### Čtyři kanály

Omarchy se aktualizuje ve čtyřech kanálech: stable, RC, edge a dev. Nové instalace začínají na kanálu stable, který sleduje [oficiální vydání](https://github.com/omacom/omarchy/releases/) a také [stabilní mirror Omarchy Arch](https://github.com/omacom-io/omarchy-mirror), který běží o měsíc pozadu za nejnovější verzí, abychom mohli zachytit případné nové nekompatibility vyžadující změny konfigurace, dříve než lidem způsobí problémy.

Pokud ale chcete pomáhat tyto potenciální problémy odhalovat, můžete běžet na kanálu edge. Ten udrží vaše balíčky Omarchy na nejnovějších vývojových buildech a umožní vám aktualizovat na nejnovější balíčky Arch, jakmile budou k dispozici. Dělejte to jen tehdy, pokud máte zkušenosti s Linuxem a víte, jak obnovit systém, který má problémy.

Před každým novým hlavním vydáním budeme provádět finální ověřování pomocí kanálu RC. Pokud máte zájem pomáhat s finálním laděním, přijďte si popovídat do #omarchy-release-candidates na Discordu.

Nakonec je tu kanál dev, který propojuje Omarchy přímo s git checkoutem zdrojového kódu v `~/omarchy` v kombinaci s balíčky edge. Tento kanál používejte jen tehdy, pokud jste zkušený uživatel Linuxu, pracujete přímo na Omarchy a jste ochotni snášet rozbití.

Mezi kanály můžete přepínat pomocí _Update > Channel_ v nabídce Omarchy (nebo `omarchy-channel-set` v terminálu).

### Přepínání jader

Omarchy bootuje své vlastní jádro `linux-omarchy`, ale vedle něj můžete mít nainstalovaná i další, například standardní archové jádro `linux` nebo experimentální build, který testujete. Když jich je víc než jedno, _Update > Kernel_ v nabídce Omarchy je vypíše se zaškrtnutím u toho, které se ve výchozím nastavení bootuje. Vyberte jiné, jednou zadejte heslo a po příštím restartu se nabootuje. Ostatní jádra zůstanou v bootovací nabídce, takže si je stále můžete ručně vybrat, pokud vám nové výchozí jádro bude dělat problémy. V terminálu slouží `omarchy-kernel` k zobrazení aktuálního výchozího jádra, `omarchy-kernel list` k výpisu nainstalovaných a `omarchy-kernel set <kernel>` k přepnutí.

### Aktualizace firmwaru

Vaše balíčky nejsou to jediné, co zastarává. Mnoho notebooků a periferií dodává firmware pro BIOS, SSD a dokovací stanice prostřednictvím Linux Vendor Firmware Service a _Update > Firmware_ v nabídce Omarchy stáhne a nainstaluje vše, co pro váš hardware čeká. Při prvním spuštění nainstaluje `fwupd`. Spoustu firmwaru lze zapsat pouze během restartu, takže se nedivte, když o něj budete požádáni.

Když potřebujete změnit nastavení v samotném BIOSu, podržte `Alt` v systémové nabídce (`Super + Escape`) a _Reboot_ se změní na _Reboot to BIOS_, což restartuje přímo do nastavení firmwaru, aniž byste museli při bootování trefit správnou klávesu. Z terminálu je to `omarchy system firmware`.

### Varování před přímými aktualizacemi přes pacman/yay

Pokud už Arch znáte, možná vás bude lákat spustit si sami `pacman -Syu` nebo `yay -Syu`, ale pokud to uděláte, přijdete o snímek, migrace a aktualizace konfigurace, které Omarchy spouští společně s novými balíčky. Právě proto Omarchy přímou aktualizaci systému zastaví a odkáže vás místo toho na `omarchy update`. (Pokud opravdu víte, co děláte, ochrana vám řekne, jak ji pro jednu transakci obejít.)

### Vrácení špatné aktualizace

Pokud budete mít po provedení aktualizace někdy problém, můžete systém vrátit do snímku pořízeného před aktualizací. Stačí restartovat a v zaváděcí nabídce vybrat snímek z doby před zahájením aktualizace.

![bootloader](images/bootloader.webp)

Pokud se vaše konfigurační soubory nějak poškodily, můžete také provést reinstalaci Omarchy pomocí `omarchy reinstall` v terminálu. Tím se znovu nainstalují všechny výchozí balíčky Omarchy, přepnete se na stable, downgradují se všechny balíčky, které jsou příliš nové, a resetují se všechny konfigurační soubory. Upozorňujeme, že všechny vaše uživatelské změny konfigurace oproti výchozímu nastavení Omarchy budou při tom přepsány!
