# Systémové snímky

Snímky vytvárame automaticky pri každej aktualizácii Omarchy, ale ak si chcete vytvoriť vlastnú, môžete použiť `omarchy-snapshot create`.

Ako snímku spustíte a obnovíte, závisí od zavádzača, s ktorým sa váš počítač spúšťa. Nové inštalácie UEFI používajú systemd-boot; staršie inštalácie a počítače s BIOS používajú Limine. `omarchy-boot-backend` vám povie, ktorý máte.

## So systemd-boot

V menu Omarchy vyberte _Systém > Snímky_ a vyberte snímku, do ktorej chcete spustiť systém. Počítač sa do nej raz reštartuje. Alebo pri spúšťaní počítača podržte Space, aby sa zobrazilo spúšťacie menu, v ktorom je každá snímka uvedená od najnovšej po najstaršiu spolu s jej verziou Omarchy a dátumom.

Snímka sa spúšťa s dočasnou vrstvou navrchu, takže ju môžete normálne používať, ale všetko, čo zmeníte, pri nasledujúcom reštarte zmizne. Ak si ju chcete ponechať, urobte z nej svoj systém: kliknite na oznámenie, ktoré sa zobrazí po prihlásení, vyberte _Systém > Snímky > Obnoviť túto snímku_, alebo spustite `omarchy-snapshot restore`. Obnovenie prebehne počas reštartu počítača. Systém v podobe, v akej bol predtým, zostáva v spúšťacom menu ako _Pred obnovením_ a `omarchy-snapshot restore backup` ho vráti späť.

Z terminálu:

- `omarchy-snapshot list` vypíše snímky, ktoré môžete spustiť;
- `omarchy-snapshot boot 12` sa raz reštartuje do snímky 12;
- `omarchy-snapshot restore 12` urobí zo snímky 12 pri nasledujúcom reštarte systém a `omarchy-snapshot restore --cancel` vám umožní zmeniť rozhodnutie pred týmto reštartom.

## S Limine

Ak chcete snímku spustiť a obnoviť, vyberiete ju zo zavádzača Limine. Spúšťacie menu zostáva predvolene skryté, takže ho zobrazíte stlačením ľubovoľného klávesu hneď, ako sa Limine spustí.

Na tejto obrazovke vyberte snímku, do ktorej chcete spustiť systém, podľa dátumu a verzie. Verziu Omarchy v čase vytvorenia snímky uvidíte v ľavom dolnom rohu.

 ![snapshots-bootloader](images/snapshots-bootloader.webp)

Po spustení sa zobrazí oznámenie, že ste v spustiteľnej snímke, a ak naň kliknete, spustí proces obnovenia. Prípadne môžete použiť `omarchy-snapshot restore`.

 ![snapshots-restore](images/snapshots-restore.webp)

## Čo obnovenie zahŕňa

Obnovenie vráti váš koreňový súborový systém, ale nie váš `/home`. Funguje teda na vrátenie pokazenej aktualizácie systému, ale nie na obnovu stratených osobných súborov.

Znamená to tiež, že váš adresár `~/.config` zostáva tak, ako je. Ak sa teda vraciate k staršej verzii knižnice alebo aplikácie, ktorá ukladá konfiguračné súbory v novom formáte, budete to musieť vyriešiť ručne.

To isté platí pre vlastný záznam Omarchy o tom, ktoré migrácie už prebehli: nachádza sa vo vašom domovskom adresári, takže obnovenie prežije. Migrácie, ktoré prebehli po vytvorení snímky, zostávajú označené ako hotové, hoci zmeny, ktoré urobili v koreňovom súborovom systéme, boli vrátené späť, a nasledujúce `omarchy update` ich znova nespustí. Ak teda po obnovení znova aktualizujete a stále chýba niečo, čo predchádzajúca aktualizácia nastavila, je to pravdepodobný dôvod.
