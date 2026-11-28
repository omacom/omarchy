# Snímky systému

Snímky vytváříme automaticky při každé aktualizaci Omarchy, ale pokud si chcete vytvořit vlastní, můžete použít `omarchy-snapshot create`.

Způsob spuštění a obnovení snímku záleží na zavaděči, kterým se váš počítač spouští. Nové instalace s UEFI používají systemd-boot; starší instalace a počítače s BIOS používají Limine. `omarchy-boot-backend` vám řekne, který z nich máte.

## Se systemd-boot

V nabídce Omarchy vyberte _Systém > Snímky_ a zvolte snímek, do kterého chcete systém spustit. Počítač se do něj jednou restartuje. Nebo při spouštění počítače podržte Space, abyste viděli spouštěcí nabídku, kde je každý snímek uveden od nejnovějšího po nejstarší spolu se svou verzí Omarchy a datem.

Snímek se spouští s dočasnou vrstvou navrchu, takže ho můžete používat jako obvykle, ale cokoli změníte, při příštím restartu zmizí. Pokud si ho chcete ponechat, udělejte z něj svůj systém: klikněte na oznámení, které se zobrazí při přihlášení, vyberte _Systém > Snímky > Obnovit tento snímek_, nebo spusťte `omarchy-snapshot restore`. Obnovení proběhne při restartování počítače. Systém v podobě, v jaké byl předtím, zůstává ve spouštěcí nabídce jako _Před obnovením_ a příkaz `omarchy-snapshot restore backup` ho vrátí zpět.

Z terminálu:

- `omarchy-snapshot list` vypíše snímky, do kterých můžete systém spustit;
- `omarchy-snapshot boot 12` se jednou restartuje do snímku 12;
- `omarchy-snapshot restore 12` udělá ze snímku 12 systém při příštím restartu a `omarchy-snapshot restore --cancel` vám před tímto restartem umožní si to rozmyslet.

## S Limine

Chcete-li snímek spustit a obnovit, vyberete ho ze zavaděče Limine. Spouštěcí nabídka zůstává ve výchozím nastavení skrytá, takže ji vyvoláte stisknutím libovolné klávesy, jakmile se Limine spustí.

Na této obrazovce si podle data a verze vyberte snímek, do kterého chcete systém spustit. Verzi Omarchy z doby pořízení snímku vidíte v levém dolním rohu.

 ![snapshots-bootloader](images/snapshots-bootloader.webp)

Když se dostanete dovnitř, vyskočí oznámení, které vás upozorní, že se nacházíte ve spustitelném snímku, a pokud na něj kliknete, spustí proces obnovení. Případně můžete využít `omarchy-snapshot restore`.

 ![snapshots-restore](images/snapshots-restore.webp)

## Co obnova zahrnuje

Obnova vrátí zpět váš kořenový souborový systém, ale ne vaše `/home`. Hodí se tedy k vrácení nepovedené aktualizace systému, ale ne k obnově ztracených osobních souborů.

To také znamená, že váš adresář `~/.config` zůstane tak, jak je. Pokud se tedy vracíte ke starší verzi knihovny nebo aplikace, která ukládá konfigurační soubory v novém formátu, budete to muset vyřešit ručně.

Totéž platí pro vlastní záznam Omarchy o tom, které migrace už proběhly: nachází se ve vašem domovském adresáři, takže obnovu přežije. Migrace, které proběhly po pořízení snímku, zůstanou označené jako dokončené, i když změny, které provedly v kořenovém souborovém systému, byly vráceny zpět, a příští `omarchy update` je znovu nespustí. Pokud tedy po obnově znovu aktualizujete a něco, co měla dřívější aktualizace nastavit, stále chybí, je to pravděpodobně ten důvod.
