# Aktualizace

Omarchy a vaše balíčky jsou udržovány aktuální prostřednictvím části _Aktualizovat > Omarchy_ v nabídce Omarchy (`Super + Space`).

Samotné Omarchy je nainstalováno jako běžné balíčky pacman z [repozitáře balíčků Omarchy](https://github.com/omacom-io/omarchy-pkgs), takže aktualizace nainstaluje [nejnovější vydání Omarchy](https://github.com/omacom/omarchy/releases), spustí všechny čekající migrace, aby byl váš systém v souladu s nejnovějším vydáním, a aktualizuje všechny systémové balíčky ze [zrcadla Omarchy Arch Mirror](https://github.com/omacom-io/omarchy-mirror) a [AUR](https://aur.archlinux.org/) (pokud jste nainstalovali nějaké balíčky z AUR).

Když vyjdou nová vydání, napravo od vašich hodin se objeví kruhová ikona se šipkou. Klikněte na ni a proces aktualizace začne.

![update-available](images/update-available.webp)

### Čtyři kanály

Omarchy se aktualizuje ve čtyřech kanálech: stable, RC, edge a dev. Nové instalace začínají na kanálu stable, který sleduje [oficiální vydání](https://github.com/omacom/omarchy/releases/), a také [stabilní zrcadlo Omarchy Arch mirror](https://github.com/omacom-io/omarchy-mirror), které je měsíc pozadu za nejnovějším vydáním, abychom mohli zachytit všechny nové nekompatibility, které vyžadují změny konfigurace, dříve, než lidem způsobí problémy.

Pokud byste ale chtěli pomoct tyto potenciální problémy odhalovat, můžete běžet na kanálu edge. Vaše balíčky Omarchy díky tomu budou sledovat nejnovější vývojové sestavy a umožní vám aktualizovat na nejnovější balíčky Archu, jakmile budou k dispozici. Měli byste to dělat pouze v případě, že máte zkušenosti s Linuxem a víte, jak obnovit systém, který má problémy.

Před každým novým hlavním vydáním budeme provádět konečné ověřování pomocí kanálu RC. Pokud máte zájem pomoct s konečným vybroušením, přijďte se podívat do kanálu #omarchy-release-candidates na Discordu.

A nakonec je tu kanál dev, který propojuje Omarchy přímo s gitovým checkoutem zdrojového kódu v adresáři `~/omarchy`, v kombinaci s balíčky edge. Tento kanál byste měli používat pouze v případě, že jste zkušeným uživatelem Linuxu, pracujete přímo na Omarchy a jste ochotni tolerovat rozbití.

Mezi kanály můžete přepínat pomocí části _Aktualizovat > Kanál_ z nabídky Omarchy (nebo příkazu `omarchy-channel-set` v terminálu).

### Aktualizace firmwaru

Vaše balíčky nejsou jedinou věcí, která zastarává. Mnoho notebooků a periferií dodává firmware pro BIOS, SSD a doky prostřednictvím služby Linux Vendor Firmware Service a část _Aktualizovat > Firmware_ v nabídce Omarchy stáhne a nainstaluje cokoli, co na váš hardware čeká. Při prvním spuštění nainstaluje program `fwupd`. Spoustu firmwaru lze zapsat pouze během restartu, takže se nedivte, když budete požádáni o jeden.

### Varování týkající se přímých aktualizací pacmanem/yayem

Pokud jste již s Archem seznámeni, možná budete v pokušení jednoduše spustit sami příkaz `pacman -Syu` nebo `yay -Syu`, ale pokud to uděláte, přijdete o snímek, migrace a aktualizace konfigurace, které Omarchy spouští společně s novými balíčky. To je důvod, proč Omarchy ve skutečnosti zastaví přímou aktualizaci systému a nasměruje vás místo toho na příkaz `omarchy update`. (Pokud skutečně víte, co děláte, stráž vám řekne, jak ji obejít pro jednu transakci.)

### Vrácení špatných aktualizací

Pokud po provedení aktualizace někdy nastane problém, můžete svůj systém vrátit zpět ke snímku pořízenému před aktualizací. Stačí restartovat a v zaváděcí nabídce vybrat snímek z doby před zahájením aktualizace.

![bootloader](images/bootloader.webp)

Pokud se vaše konfigurační soubory nějak poškodily, můžete také provést přeinstalování Omarchy pomocí příkazu `omarchy reinstall` v terminálu. Tím se přeinstalují všechny výchozí balíčky Omarchy, nastavíte se na stable a všechny příliš nové balíčky se vrátí na nižší verzi a všechny konfigurační soubory se nastaví na výchozí hodnoty. Pamatujte, že tímto se přepíšou všechny vaše uživatelské změny konfigurace výchozích nastavení Omarchy!
