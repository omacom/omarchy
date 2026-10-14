# Snímky systému

Snímky vytvárame automaticky pri každej aktualizácii Omarchy, ale ak by ste chceli vytvoriť vlastnú, môžete použiť `omarchy-snapshot create`.

Ak chcete snímku zaviesť a obnoviť, vyberiete ju zo zavádzača Limine. (Ak momentálne zavádzate rovno na dešifrovaciu obrazovku Omarchy, budete musieť najskôr cez BIOS vybrať Limine ako možnosť zavádzania.)

Na tej obrazovke vyberte snímku, do ktorej chcete zaviesť, na základe dátumu a verzie. Verziu Omarchy v čase snímky môžete vidieť v ľavom dolnom rohu.

 ![snapshots-bootloader](images/snapshots-bootloader.webp)

Keď sa dostanete dnu, vyskočí upozornenie, ktoré vás informuje, že ste v zavádzateľnej snímke, a ak naň kliknete, spustí sa proces obnovy. Prípadne môžete využiť `omarchy-snapshot restore`.

 ![snapshots-restore](images/snapshots-restore.webp)

Tým sa obnoví váš koreňový súborový systém, ale nie váš `/home`. Takže to funguje na vrátenie pokazenej aktualizácie systému, ale nie na obnovenie stratených osobných súborov.

To tiež znamená, že váš adresár `~/.config` zostáva taký, aký je. Takže ak sa vraciate k skoršej verzii knižnice alebo aplikácie, ktorá ukladá konfiguračné súbory v novom formáte, budete to musieť vyriešiť ručne.

_Poznámka: Táto funkcia je dostupná len na inštaláciách používajúcich zavádzač Limine, ktorý je predvoleným od Omarchy 2.0. Nie je dostupná, ak používate GRUB alebo systemd-boot._

### Preskočenie ponuky zavádzania

Ak sa ponuky zavádzania nikdy nedotknete a chcete len, aby stroj prešiel rovno na dešifrovaciu obrazovku, spustite _Nastavenie > Direct Boot_ v ponuke Omarchy. Tým sa pridá záznam EFI ukazujúci priamo na Omarchy, takže ho firmvér zavedie bez zastavenia na Limine.

Kompromis je ten spomenutý na začiatku: so zapnutým priamym zavádzaním dostať sa k snímke znamená najskôr vybrať Limine z ponuky zavádzania BIOS-u. Spustite _Nastavenie > Direct Boot_ znova, ak chcete záznam odstrániť a vrátiť sa k zavádzaniu cez Limine. Niektorý firmvér nemá rád vlastné záznamy EFI, takže nastavenie sa odmietne spustiť na firmvéri American Megatrends a Apple.
