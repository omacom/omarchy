# Systémové snímky

Snímky vytvárame automaticky pri každej aktualizácii Omarchy, ale ak si chcete vytvoriť vlastnú, môžete použiť `omarchy-snapshot create`.

Ak chcete snímku spustiť a obnoviť, vyberiete ju zo zavádzača Limine. Ponuka zavádzania zostáva predvolene skrytá, takže hneď ako sa Limine spustí, stlačte ľubovoľnú klávesu, aby sa zobrazila.

Na tejto obrazovke si podľa dátumu a verzie vyberte snímku, do ktorej chcete systém spustiť. Verziu Omarchy v čase vytvorenia snímky vidíte v ľavom dolnom rohu.

 ![snapshots-bootloader](images/snapshots-bootloader.webp)

Keď sa dostanete dovnútra, vyskočí oznámenie, že sa nachádzate v spustiteľnej snímke, a ak naň kliknete, spustí sa proces obnovenia. Prípadne môžete použiť `omarchy-snapshot restore`.

 ![snapshots-restore](images/snapshots-restore.webp)

Týmto sa obnoví váš koreňový súborový systém, ale nie váš `/home`. Funguje to teda na vrátenie pokazenej aktualizácie systému, ale nie na obnovu stratených osobných súborov.

Znamená to tiež, že váš adresár `~/.config` zostáva tak, ako je. Ak sa teda vraciate k staršej verzii knižnice alebo aplikácie, ktorá ukladá konfiguračné súbory v novom formáte, budete to musieť vyriešiť ručne.

To isté platí aj pre vlastný záznam Omarchy o tom, ktoré migrácie už prebehli: nachádza sa vo vašom domovskom adresári, takže obnovenie prežije. Migrácie, ktoré prebehli po vytvorení snímky, zostanú označené ako dokončené, aj keď zmeny, ktoré vykonali v koreňovom súborovom systéme, boli vrátené späť, a ďalší príkaz `omarchy update` ich už znova nespustí. Ak teda po obnovení znova aktualizujete a niečo, čo nastavila skoršia aktualizácia, stále chýba, je to pravdepodobný dôvod.

_Poznámka: Táto funkcia je dostupná len na inštaláciách používajúcich zavádzač Limine, ktorý je predvolený od verzie Omarchy 2.0. Nie je dostupná, ak používate GRUB alebo systemd-boot._
