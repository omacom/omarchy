# Systeemsnapshots

We maken automatisch snapshots bij elke Omarchy-update, maar als je er zelf een wilt maken, kun je `omarchy-snapshot create` gebruiken.

Hoe je een snapshot opstart en herstelt, hangt af van de bootloader waarmee je machine start. Nieuwe UEFI-installaties gebruiken systemd-boot; oudere installaties en BIOS-machines gebruiken Limine. `omarchy-boot-backend` laat je zien welke je hebt.

## Met systemd-boot

Kies _Systeem > Snapshots_ in het Omarchy-menu en kies de snapshot waarin je wilt opstarten. De machine start er eenmalig in opnieuw op. Of houd Space ingedrukt terwijl de machine start om het opstartmenu te zien, waar elke snapshot wordt vermeld, nieuwste eerst, met de Omarchy-versie en datum.

Een snapshot start op met een tijdelijke laag erbovenop, dus je kunt hem normaal gebruiken, maar alles wat je wijzigt is bij de volgende herstart verdwenen. Om hem te behouden, maak je er je systeem van: klik op de melding die verschijnt wanneer je inlogt, kies _Systeem > Snapshots > Deze snapshot herstellen_, of voer `omarchy-snapshot restore` uit. Het herstel vindt plaats terwijl de machine opnieuw opstart. Het systeem zoals het daarvoor was, blijft in het opstartmenu staan als _Voor herstel_, en `omarchy-snapshot restore backup` zet het terug.

Vanuit de terminal:

- `omarchy-snapshot list` vermeldt de snapshots waarin je kunt opstarten;
- `omarchy-snapshot boot 12` start eenmalig opnieuw op in snapshot 12;
- `omarchy-snapshot restore 12` maakt snapshot 12 bij de volgende herstart tot het systeem, en met `omarchy-snapshot restore --cancel` bedenk je je vóór die herstart.

## Met Limine

Om een snapshot op te starten en te herstellen, selecteer je hem in de Limine-bootloader. Het opstartmenu blijft standaard verborgen, dus druk op een willekeurige toets zodra Limine start om het tevoorschijn te halen.

Kies vanaf dat scherm de snapshot waarin je wilt opstarten op basis van de datum en versie. De versie van Omarchy op het moment van de snapshot is linksonder in de hoek te zien.

 ![snapshots-bootloader](images/snapshots-bootloader.webp)

Wanneer je binnen bent, verschijnt er een melding die je laat weten dat je in een opstartbare snapshot zit en als je erop klikt, start het herstelproces. Je kunt ook `omarchy-snapshot restore` gebruiken.

 ![snapshots-restore](images/snapshots-restore.webp)

## Wat een herstel dekt

Een herstel brengt je rootbestandssysteem terug, maar niet je `/home`. Het werkt dus om een kapotte systeemupdate terug te draaien, maar niet om verloren persoonlijke bestanden te herstellen.

Dit betekent ook dat je map `~/.config` ongewijzigd blijft. Dus als je teruggaat naar een eerdere versie van een bibliotheek of applicatie die configuratiebestanden in een nieuw formaat opslaat, moet je dat handmatig uitzoeken.

Hetzelfde geldt voor Omarchy's eigen registratie van welke migraties al zijn uitgevoerd: die staat in je thuismap, dus die overleeft het herstel. Migraties die zijn uitgevoerd nadat de snapshot was gemaakt, blijven als voltooid gemarkeerd, ook al zijn de wijzigingen die ze aan het rootbestandssysteem hebben aangebracht teruggedraaid, en de volgende `omarchy update` voert ze niet opnieuw uit. Dus als je na een herstel opnieuw bijwerkt en iets dat een eerdere update had ingesteld nog steeds ontbreekt, is dat waarschijnlijk de reden.
