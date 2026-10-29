# Systémové snímky

Snímky vytvárame automaticky pri každej aktualizácii Omarchy, ale ak si chcete vytvoriť vlastnú, môžete použiť `omarchy-snapshot create`.

Ak chcete snímku spustiť a obnoviť, vyberiete ju zo zavádzača Limine. (Ak sa vám momentálne systém spúšťa rovno na obrazovku dešifrovania Omarchy, budete musieť najprv vybrať Limine ako možnosť spustenia cez BIOS).

Na tejto obrazovke si vyberte snímku, do ktorej sa chcete spustiť, podľa dátumu a verzie. Verziu Omarchy v čase vytvorenia snímky vidíte v ľavom dolnom rohu.

 ![snapshots-bootloader](images/snapshots-bootloader.webp)

Keď sa dostanete dovnútra, vyskočí vám oznámenie, že sa nachádzate v spustiteľnej snímke, a ak naň kliknete, spustí sa proces obnovenia. Prípadne môžete použiť `omarchy-snapshot restore`.

 ![snapshots-restore](images/snapshots-restore.webp)

Týmto sa obnoví váš koreňový súborový systém, ale nie váš `/home`. Funguje to teda na vrátenie pokazenej aktualizácie systému, ale nie na obnovenie stratených osobných súborov.

Znamená to tiež, že váš adresár `~/.config` zostane tak, ako je. Ak sa teda vraciate k staršej verzii knižnice alebo aplikácie, ktorá ukladá konfiguračné súbory v novom formáte, budete si to musieť vyriešiť ručne.

To isté platí aj pre vlastný záznam Omarchy o tom, ktoré migrácie už prebehli: nachádza sa vo vašom domovskom adresári, takže obnovenie prežije. Migrácie, ktoré prebehli po vytvorení snímky, zostanú označené ako hotové, aj keď zmeny, ktoré vykonali v koreňovom súborovom systéme, boli vrátené späť, a ďalší príkaz `omarchy update` ich už znova nespustí. Ak teda po obnovení znova aktualizujete a niečo, čo nastavila skoršia aktualizácia, stále chýba, je to pravdepodobne dôvod.

_Poznámka: Táto funkcia je k dispozícii iba na inštaláciách používajúcich zavádzač Limine, ktorý je predvolený od Omarchy 2.0. Nie je k dispozícii, ak používate GRUB alebo systemd-boot._

### Preskočenie ponuky spustenia

Ak sa ponuky spustenia nikdy nedotknete a chcete, aby počítač išiel rovno na obrazovku dešifrovania, spustite v ponuke Omarchy položku _Nastavenie > Priame spustenie_. Tým sa pridá položka EFI smerujúca priamo na Omarchy, takže ju firmvér spustí bez zastavenia v Limine.

Kompromis je ten spomenutý na začiatku: pri zapnutom priamom spustení znamená dostať sa k snímke najprv vybrať Limine z ponuky spustenia BIOS. Ak chcete položku odstrániť a vrátiť sa k spúšťaniu cez Limine, spustite položku _Nastavenie > Priame spustenie_ znova. Niektorý firmvér nemá rád vlastné položky EFI, takže nastavenie sa odmietne spustiť na firmvéri American Megatrends a Apple.
