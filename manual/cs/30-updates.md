# Aktualizace

Omarchy a vaše balíčky se udržují aktuální přes _Aktualizovat > Omarchy_ v nabídce Omarchy (`Super + Space`).

Samotná Omarchy je nainstalovaná jako běžné balíčky pacman z [repozitáře balíčků Omarchy](https://github.com/omacom-io/omarchy-pkgs), takže aktualizace nainstaluje [nejnovější vydání Omarchy](https://github.com/omacom/omarchy/releases), spustí všechny čekající migrace, aby byl váš systém v souladu s nejnovější verzí, a aktualizuje všechny systémové balíčky z [Arch mirroru Omarchy](https://github.com/omacom-io/omarchy-mirror) a [AUR](https://aur.archlinux.org/) (pokud máte nainstalované nějaké balíčky z AUR).

Když vyjdou nová vydání, objeví se vpravo od vašich hodin ikona kruhové šipky. Klikněte na ni a proces aktualizace se spustí.

![update-available](images/update-available.webp)

### Čtyři kanály

Omarchy se aktualizuje ve čtyřech kanálech: stable, RC, edge a dev. Nové instalace začínají na kanálu stable, který sleduje [oficiální vydání](https://github.com/omacom/omarchy/releases/) a také [stabilní Arch mirror Omarchy](https://github.com/omacom-io/omarchy-mirror), který je o měsíc pozadu za nejnovějšími balíčky, abychom mohli zachytit všechny nové nekompatibility vyžadující změny konfigurace dřív, než způsobí lidem problémy.

Pokud ale chcete pomoci tyhle potenciální problémy odhalovat, můžete běžet na kanálu edge. Ten udrží vaše balíčky Omarchy na nejnovějších vývojových sestaveních a umožní vám aktualizovat na nejnovější balíčky Arch, jakmile budou k dispozici. Měli byste to dělat jen tehdy, pokud máte zkušenosti s Linuxem a víte, jak obnovit systém, který má problémy.

Před každým novým hlavním vydáním budeme provádět finální ověření pomocí kanálu RC. Pokud máte zájem pomoci s finálním laděním, přijďte si popovídat do #omarchy-release-candidates na Discordu.

A konečně je tu kanál dev, který propojí Omarchy přímo s git checkoutem zdrojového kódu v `~/omarchy` v kombinaci s balíčky edge. Tento kanál byste měli používat jen tehdy, pokud jste zkušený uživatel Linuxu, pracujete přímo na Omarchy a jste ochotní tolerovat, že se něco rozbije.

Mezi kanály můžete přepínat pomocí _Aktualizovat > Kanál_ v nabídce Omarchy (nebo `omarchy-channel-set` v terminálu).

### Přepínání jader

Omarchy bootuje své vlastní jádro `linux-omarchy`, ale vedle něj můžete mít nainstalovaná i další, například výchozí jádro `linux` z Archu nebo experimentální sestavení, které testujete. Když jich máte více než jedno, položka _Aktualizovat > Jádro_ v nabídce Omarchy je vypíše se zaškrtnutím u toho, které se bootuje ve výchozím nastavení. Vyberte jiné, jednou zadejte své heslo a po příštím restartu nabootuje právě to. Ostatní jádra zůstanou v bootovací nabídce, takže si jedno z nich stále můžete vybrat ručně, pokud vám nové výchozí dělá potíže. V terminálu zobrazí `omarchy-kernel` aktuální výchozí jádro, `omarchy-kernel list` to, co je nainstalované, a `omarchy-kernel set <kernel>` slouží k přepnutí.

### Aktualizace firmwaru

Vaše balíčky nejsou to jediné, co zastarává. Mnoho notebooků a periferií dodává firmware pro BIOS, SSD a dok prostřednictvím Linux Vendor Firmware Service a položka _Aktualizovat > Firmware_ v nabídce Omarchy stáhne a nainstaluje vše, co na váš hardware čeká. Při prvním spuštění nainstaluje `fwupd`. Spoustu firmwaru lze zapsat jen během restartu, takže se nedivte, když o něj budete požádáni.

### Varování před přímými aktualizacemi přes pacman/yay

Pokud jste již s Archem seznámeni, možná budete v pokušení jednoduše spustit sami příkaz `pacman -Syu` nebo `yay -Syu`, ale pokud to uděláte, přijdete o snímek, migrace a aktualizace konfigurace, které Omarchy spouští společně s novými balíčky. To je důvod, proč Omarchy ve skutečnosti zastaví přímou aktualizaci systému a nasměruje vás místo toho na příkaz `omarchy update`. (Pokud skutečně víte, co děláte, ochranná kontrola vám řekne, jak ji obejít pro jednu transakci.)

### Vrácení špatných aktualizací

Pokud budete mít někdy po aktualizaci problém, můžete systém vrátit zpět ke snímku pořízenému před aktualizací. Stačí restartovat a v nabídce boot loaderu vybrat snímek z doby před tím, než jste aktualizaci spustili.

![bootloader](images/bootloader.webp)

Pokud se vám nějak poškodí konfigurační soubory, můžete také provést reinstalaci Omarchy pomocí `omarchy reinstall` v terminálu. Tím se přeinstalují všechny výchozí balíčky Omarchy, přepne vás na kanál stable, downgradují se všechny balíčky, které jsou příliš nové, a resetují se všechny konfigurační soubory. Pozor, všechny vaše uživatelské změny výchozí konfigurace Omarchy se při tom přepíšou!
