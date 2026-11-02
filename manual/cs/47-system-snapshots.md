# Snímky systému

Snímky vytváříme automaticky při každé aktualizaci Omarchy, ale pokud si chcete vytvořit vlastní, můžete použít `omarchy-snapshot create`.

Chcete-li snímek nabootovat a obnovit z něj systém, vyberete ho v zavaděči Limine. (Pokud se vám teď počítač spouští rovnou na obrazovku pro dešifrování Omarchy, budete muset nejdřív v BIOSu zvolit Limine jako možnost spuštění).

Na této obrazovce si podle data a verze vyberte snímek, do kterého chcete nabootovat. Verzi Omarchy v době pořízení snímku vidíte v levém dolním rohu.

 ![snapshots-bootloader](images/snapshots-bootloader.webp)

Jakmile se dostanete dovnitř, vyskočí na vás oznámení, že jste v bootovatelném snímku, a když na něj kliknete, spustí se proces obnovy. Případně můžete použít `omarchy-snapshot restore`.

 ![snapshots-restore](images/snapshots-restore.webp)

Tím se obnoví váš kořenový souborový systém, ale ne váš `/home`. Hodí se to tedy na vrácení pokažené aktualizace systému, ale ne na obnovu ztracených osobních souborů.

To také znamená, že váš adresář `~/.config` zůstane tak, jak je. Takže pokud se vracíte ke starší verzi knihovny nebo aplikace, která ukládá konfigurační soubory v novém formátu, budete si to muset vyřešit ručně.

Totéž platí pro vlastní záznam Omarchy o tom, které migrace už proběhly: žije ve vašem domovském adresáři, takže obnovu přežije. Migrace, které proběhly po pořízení snímku, zůstanou označené jako hotové, i když změny, které provedly v kořenovém souborovém systému, byly vráceny zpět, a příští `omarchy update` je znovu nespustí. Takže pokud po obnově znovu aktualizujete a něco, co měla nastavit dřívější aktualizace, pořád chybí, je to nejspíš ten důvod.

_Poznámka: Tato funkce je k dispozici pouze na instalacích používajících zavaděč Limine, který je výchozí od Omarchy 2.0. Není k dispozici, pokud používáte GRUB nebo systemd-boot._

### Přeskočení bootovací nabídky

Pokud se bootovací nabídky nikdy nedotknete a chcete, aby počítač šel rovnou na obrazovku pro dešifrování, spusťte v nabídce Omarchy _Nastavení > Přímé spuštění_. Tím se přidá položka EFI mířící přímo na Omarchy, takže ji firmware nabootuje, aniž by se zastavoval v Limine.

Kompromis je ten zmíněný na začátku: se zapnutým přímým spuštěním znamená dostat se ke snímku nejdřív vybrat Limine z bootovací nabídky BIOSu. Položku odstraníte a k bootování přes Limine se vrátíte opětovným spuštěním _Nastavení > Přímé spuštění_. Některý firmware vlastní položky EFI zrovna nemiluje, takže se nastavení odmítne spustit na firmwaru American Megatrends a Apple.
