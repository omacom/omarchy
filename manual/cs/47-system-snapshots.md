# Systémové snímky

Snímky vytváříme automaticky při každé aktualizaci Omarchy, ale pokud si chcete vytvořit vlastní, můžete použít `omarchy-snapshot create`.

Pokud chcete ze snímku nabootovat a obnovit systém, vyberete ho v zavaděči Limine. Nabídka bootování zůstává ve výchozím nastavení skrytá, takže ji zobrazíte stisknutím libovolné klávesy hned, jakmile se Limine spustí.

Na této obrazovce si podle data a verze vyberte snímek, ze kterého chcete nabootovat. Verzi Omarchy v době pořízení snímku vidíte v levém dolním rohu.

 ![snapshots-bootloader](images/snapshots-bootloader.webp)

Když se do systému dostanete, vyskočí oznámení, že jste v bootovatelném snímku, a pokud na něj kliknete, spustí se proces obnovy. Případně můžete použít `omarchy-snapshot restore`.

 ![snapshots-restore](images/snapshots-restore.webp)

Tím se obnoví váš kořenový souborový systém, ale ne váš `/home`. Hodí se to tedy na vrácení rozbité aktualizace systému, ale ne na obnovu ztracených osobních souborů.

Znamená to také, že váš adresář `~/.config` zůstane tak, jak je. Pokud se tedy vracíte k dřívější verzi knihovny nebo aplikace, která ukládá konfigurační soubory v novém formátu, budete to muset vyřešit ručně.

Totéž platí pro vlastní záznam Omarchy o tom, které migrace už proběhly: nachází se ve vašem domovském adresáři, takže obnovu přežije. Migrace, které proběhly po pořízení snímku, zůstanou označené jako hotové, i když změny, které provedly v kořenovém souborovém systému, byly vráceny zpět, a příští `omarchy update` je znovu nespustí. Pokud tedy po obnově znovu aktualizujete a něco, co dřívější aktualizace nastavila, stále chybí, je to pravděpodobně důvod.

_Poznámka: Tato funkce je dostupná pouze na instalacích používajících zavaděč Limine, který je výchozí od Omarchy 2.0. Není dostupná, pokud používáte GRUB nebo systemd-boot._
