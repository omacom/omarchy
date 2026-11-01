# Aktualizace

Omarchy a vaše balíčky se udržují aktuální přes _Aktualizace > Omarchy_ v nabídce Omarchy (`Super + Space`).

Samotná Omarchy je nainstalovaná jako běžné balíčky pacman z [repozitáře balíčků Omarchy](https://github.com/omacom-io/omarchy-pkgs), takže aktualizace nainstaluje [nejnovější vydání Omarchy](https://github.com/omacom/omarchy/releases), spustí všechny čekající migrace, aby byl váš systém v souladu s nejnovější verzí, a aktualizuje všechny systémové balíčky z [Arch mirroru Omarchy](https://github.com/omacom-io/omarchy-mirror) a [AUR](https://aur.archlinux.org/) (pokud máte nainstalované nějaké balíčky z AUR).

Když vyjdou nová vydání, objeví se vpravo od vašich hodin ikona kruhové šipky. Klikněte na ni a proces aktualizace se spustí.

![update-available](images/update-available.webp)

### Čtyři kanály

Omarchy se aktualizuje ve čtyřech kanálech: stable, RC, edge a dev. Nové instalace začínají na kanálu stable, který sleduje [oficiální vydání](https://github.com/omacom/omarchy/releases/) a také [stabilní Arch mirror Omarchy](https://github.com/omacom-io/omarchy-mirror), který běží o měsíc pozadu za nejnovějším, abychom mohli zachytit všechny nové nekompatibility vyžadující změny konfigurace dřív, než způsobí lidem problémy.

Pokud ale chcete pomoci tyhle potenciální problémy odhalovat, můžete běžet na kanálu edge. Ten udrží vaše balíčky Omarchy na nejnovějších vývojových sestaveních a umožní vám aktualizovat na nejnovější balíčky Arch, jakmile budou k dispozici. Měli byste to dělat jen tehdy, pokud máte zkušenosti s Linuxem a víte, jak obnovit systém, který má problémy.

Před každým novým hlavním vydáním budeme provádět finální ověření pomocí kanálu RC. Pokud máte zájem pomoci s finálním laděním, přijďte si popovídat do #omarchy-release-candidates na Discordu.

A konečně je tu kanál dev, který propojí Omarchy přímo s git checkoutem zdrojového kódu v `~/omarchy` v kombinaci s balíčky edge. Tento kanál byste měli používat jen tehdy, pokud jste zkušený uživatel Linuxu, pracujete přímo na Omarchy a jste ochotní tolerovat, že se něco rozbije.

Mezi kanály můžete přepínat pomocí _Aktualizace > Kanál_ v nabídce Omarchy (nebo `omarchy-channel-set` v terminálu).

### Přepínání kernelů

Omarchy bootuje svůj vlastní kernel `linux-omarchy`, ale vedle něj můžete mít nainstalované i další, například výchozí kernel `linux` z Archu nebo experimentální sestavení, které testujete. Když jich máte více než jeden, položka _Aktualizace > Kernel_ v nabídce Omarchy je vypíše se zaškrtnutím u toho, který se bootuje ve výchozím nastavení. Vyberte jiný, jednou zadejte své heslo a po příštím restartu nabootuje právě ten. Ostatní kernely zůstanou v bootovací nabídce, takže si jeden stále můžete vybrat ručně, pokud vám nový výchozí dělá potíže. V terminálu zobrazí `omarchy-kernel` aktuální výchozí kernel, `omarchy-kernel list` to, co je nainstalované, a `omarchy-kernel set <kernel>` slouží k přepnutí.

### Aktualizace firmwaru

Vaše balíčky nejsou to jediné, co zastarává. Mnoho laptopů a periferií dodává firmware pro BIOS, SSD a dok prostřednictvím Linux Vendor Firmware Service a položka _Aktualizace > Firmware_ v nabídce Omarchy stáhne a nainstaluje vše, co na váš hardware čeká. Při prvním spuštění nainstaluje `fwupd`. Spoustu firmwaru lze zapsat jen během restartu, takže se nedivte, když o něj budete požádáni.

### Varování před přímými aktualizacemi přes pacman/yay

Pokud už Arch znáte, možná vás bude lákat prostě si sami spustit `pacman -Syu` nebo `yay -Syu`, ale pokud to uděláte, přijdete o snímek, migrace a aktualizace konfigurace, které Omarchy spouští společně s novými balíčky. Proto Omarchy přímou aktualizaci systému ve skutečnosti zastaví a místo toho vás odkáže na `omarchy update`. (Pokud opravdu víte, co děláte, ochrana vám řekne, jak ji pro jednu transakci obejít.)

### Vrácení špatných aktualizací

Pokud budete mít někdy po aktualizaci problém, můžete systém vrátit zpět ke snímku pořízenému před aktualizací. Stačí restartovat a v nabídce boot loaderu vybrat snímek z doby před tím, než jste aktualizaci spustili.

![bootloader](images/bootloader.webp)

Pokud se vám nějak poškodí konfigurační soubory, můžete také provést reinstalaci Omarchy pomocí `omarchy reinstall` v terminálu. Tím se přeinstalují všechny výchozí balíčky Omarchy, přepnete se na stable, downgradují se všechny balíčky, které jsou příliš nové, a resetují se všechny konfigurační soubory. Pozor, všechny vaše uživatelské změny výchozí konfigurace Omarchy se při tom přepíšou!
