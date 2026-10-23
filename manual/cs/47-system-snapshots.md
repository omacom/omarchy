# Snímky systému

Snímky vytváříme automaticky při každé aktualizaci Omarchy, ale pokud byste si chtěli vytvořit vlastní, můžete použít příkaz `omarchy-snapshot create`.

Chcete-li snímek spustit a obnovit, vyberete ho ze zavaděče Limine. (Pokud se nyní spouštíte přímo na obrazovku pro dešifrování Omarchy, budete muset nejprve vybrat Limine jako možnost spouštění v systému BIOS.)

Na této obrazovce zvolte snímek, který chcete spustit, podle data a verze. Verzi systému Omarchy v době pořízení snímku uvidíte v levém dolním rohu.

 ![snapshots-bootloader](images/snapshots-bootloader.webp)

Až se do systému dostanete, zobrazí se oznámení, které vás informuje, že jste ve spustitelném snímku, a kliknutím na něj zahájíte proces obnovení. Případně můžete použít příkaz `omarchy-snapshot restore`.

 ![snapshots-restore](images/snapshots-restore.webp)

Tím se obnoví kořenový souborový systém, ale nikoli složka `/home`. Funguje to tedy pro vrácení nepodařené aktualizace systému, ale ne pro obnovu ztracených osobních souborů.

Znamená to také, že adresář `~/.config` zůstane beze změny. Pokud se tedy vracíte ke starší verzi knihovny nebo aplikace, která ukládá konfigurační soubory v novém formátu, budete to muset vyřešit ručně.

_Poznámka: Tato funkce je k dispozici pouze u instalací používajících zavaděč Limine, který je výchozím zavaděčem od verze Omarchy 2.0. Není k dispozici, pokud používáte GRUB nebo systemd-boot._

### Přeskočení nabídky při spouštění

Pokud nabídku při spouštění nikdy nepoužíváte a chcete pouze, aby počítač přešel rovnou na obrazovku pro dešifrování, spusťte v nabídce Omarchy volbu _Nastavení > Direct Boot_. Tím se přidá záznam EFI odkazující přímo na Omarchy, takže ho firmware spustí bez zastavení u Limine.

Nevýhodou je výše zmíněná věc: při zapnutém přímém spouštění se ke snímku dostanete jedině tak, že nejprve vyberete Limine ze spouštěcí nabídky systému BIOS. Dalším spuštěním volby _Nastavení > Direct Boot_ záznam odeberete a vrátíte se ke spouštění přes Limine. Některý firmware si s vlastními záznamy EFI dobře nerozumí, takže nastavení odmítne běžet u firmwaru American Megatrends a Apple.
