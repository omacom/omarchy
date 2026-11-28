# Aktualizace

Omarchy a vaše balíčky udržujete aktuální přes _Aktualizace > Omarchy_ v nabídce Omarchy (`Super + Space`).

Omarchy samotné se instaluje jako běžné balíčky pacman z [repozitáře balíčků Omarchy](https://github.com/omacom-io/omarchy-pkgs), takže aktualizace nainstaluje [nejnovější vydání Omarchy](https://github.com/omacom/omarchy/releases), spustí všechny čekající migrace, aby byl váš systém v souladu s nejnovější verzí, a aktualizuje všechny systémové balíčky z [Omarchy Arch Mirror](https://github.com/omacom-io/omarchy-mirror) a [AUR](https://aur.archlinux.org/) (pokud máte nainstalované nějaké balíčky z AUR).

Když vyjdou nová vydání, objeví se napravo od vašich hodin ikona kruhové šipky. Klikněte na ni a proces aktualizace se spustí.

![update-available](images/update-available.webp)

### Čtyři kanály

Omarchy se aktualizuje ve čtyřech kanálech: stable, RC, edge a dev. Nové instalace začínají na kanálu stable, který sleduje [oficiální vydání](https://github.com/omacom/omarchy/releases/) i [stabilní Omarchy Arch mirror](https://github.com/omacom-io/omarchy-mirror) běžící o měsíc pozadu za nejnovějším, abychom mohli zachytit všechny nové nekompatibility, které vyžadují změny konfigurace, dříve než lidem způsobí problémy.

Pokud ale chcete pomoci tyto potenciální problémy odhalovat, můžete běžet na kanálu edge. Ten udrží vaše balíčky Omarchy v souladu s nejnovějšími vývojovými sestaveními a umožní vám aktualizovat na nejnovější balíčky Arch, jakmile budou k dispozici. Měli byste to dělat, jen pokud máte zkušenosti s Linuxem a víte, jak obnovit systém, který má problémy.

Před každým novým hlavním vydáním budeme provádět finální ověřování pomocí kanálu RC. Pokud máte zájem pomoci s finálním doladěním, přijďte posedět do #omarchy-release-candidates na Discordu.

Nakonec je tu kanál dev, který propojuje Omarchy přímo s git checkoutem zdrojového kódu v `~/omarchy` v kombinaci s balíčky edge. Tento kanál byste měli používat, jen pokud jste zkušený uživatel Linuxu, pracujete přímo na Omarchy a jste ochotni snášet rozbití.

Mezi kanály můžete přepínat pomocí _Aktualizace > Kanál_ v nabídce Omarchy (nebo `omarchy channel set <stable|rc|edge|dev>` v terminálu, přičemž `omarchy channel current` vám ukáže, kde právě jste).

### Přepínání jader

Omarchy startuje vlastní jádro `linux-omarchy`, ale vedle něj můžete mít nainstalovaná další, jako je standardní jádro Arch `linux` nebo experimentální sestavení, které testujete. Když jich je víc než jedno, položka _Aktualizace > Jádro_ v nabídce Omarchy je vypíše se zaškrtnutím vedle toho, které se ve výchozím nastavení startuje. Vyberte jiné, jednou zadejte heslo a po příštím restartu se systém spustí z něj. Ostatní jádra zůstanou v zaváděcí nabídce, takže si jedno můžete stále vybrat ručně, pokud vám nové výchozí bude dělat problémy. V terminálu slouží `omarchy kernel` k zobrazení aktuálního výchozího jádra, `omarchy kernel list` k výpisu toho, co je nainstalováno, a `omarchy kernel set <kernel>` k přepnutí.

### Aktualizace firmwaru

Vaše balíčky nejsou jedinou věcí, která zastarává. Mnoho notebooků a periferií dodává firmware pro BIOS, SSD a dokovací stanice prostřednictvím Linux Vendor Firmware Service a položka _Aktualizace > Firmware_ v nabídce Omarchy stáhne a nainstaluje vše, co pro váš hardware čeká. Při prvním spuštění nainstaluje `fwupd`. Spoustu firmwaru lze zapsat pouze během restartu, takže se nedivte, pokud o něj budete požádáni.

Když potřebujete změnit nastavení v samotném BIOSu, podržte `Alt` v systémové nabídce (`Super + Escape`) a _Restartovat_ se změní na _Restartovat do BIOSu_, což restartuje rovnou do nastavení firmwaru, aniž byste museli při startu trefit správnou klávesu. Z terminálu je to `omarchy system firmware`.

### Varování ohledně přímých aktualizací přes pacman/yay

Pokud už Arch znáte, možná vás bude lákat prostě si sami spustit `pacman -Syu` nebo `yay -Syu`, ale pokud to uděláte, přijdete o snímek, migrace a aktualizace konfigurace, které Omarchy spouští spolu s novými balíčky. Proto Omarchy přímou aktualizaci systému ve skutečnosti zastaví a místo toho vás odkáže na `omarchy update`. (Pokud opravdu víte, co děláte, ochrana vám řekne, jak ji pro jednu transakci obejít.)

### Vrácení špatných aktualizací

Pokud budete mít někdy po provedení aktualizace problém, můžete svůj systém vrátit zpět ke snímku pořízenému před aktualizací. Stačí restartovat a v zaváděcí nabídce vybrat snímek z doby před zahájením aktualizace.

![bootloader](images/bootloader.webp)

Pokud se vaše konfigurační soubory nějakým způsobem poškodí, můžete také provést přeinstalaci Omarchy pomocí `omarchy reinstall` v terminálu. Tím se přeinstalují všechny výchozí balíčky Omarchy, přepnete se na stable (na Apple Silicon na edge), downgradují se všechny balíčky, které jsou příliš nové, a obnoví se všechny konfigurační soubory. Mějte na paměti, že při tom budou přepsány všechny vaše uživatelské změny konfigurace oproti výchozímu nastavení Omarchy!
