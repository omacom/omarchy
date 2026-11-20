# Systeemsnapshots

We maken automatisch snapshots bij elke Omarchy-update, maar als je er zelf een wilt maken, kun je `omarchy-snapshot create` gebruiken.

Om een snapshot op te starten en te herstellen, selecteer je deze in de Limine boot loader. Het opstartmenu blijft standaard verborgen, dus druk op een willekeurige toets zodra Limine start om het tevoorschijn te halen.

Kies vanaf dat scherm de snapshot waarin je wilt opstarten op basis van de datum en versie. De versie van Omarchy op het moment van de snapshot zie je in de linkerbenedenhoek.

 ![snapshots-bootloader](images/snapshots-bootloader.webp)

Wanneer je binnen bent, verschijnt er een melding die je laat weten dat je in een opstartbare snapshot zit en als je erop klikt, start het herstelproces. Je kunt ook `omarchy-snapshot restore` gebruiken.

 ![snapshots-restore](images/snapshots-restore.webp)

Hiermee wordt je rootbestandssysteem hersteld, maar niet je `/home`. Het werkt dus om een defecte systeemupdate terug te draaien, maar niet om verloren persoonlijke bestanden te herstellen.

Dit betekent ook dat je `~/.config`-map blijft zoals deze is. Dus als je teruggaat naar een eerdere versie van een bibliotheek of applicatie die configuratiebestanden in een nieuw formaat opslaat, moet je dat handmatig oplossen.

Hetzelfde geldt voor Omarchy's eigen administratie van welke migraties al zijn uitgevoerd: die staat in je thuismap, dus die overleeft het herstel. Migraties die zijn uitgevoerd nadat de snapshot was gemaakt, blijven gemarkeerd als voltooid, ook al zijn de wijzigingen die ze in het rootbestandssysteem hebben aangebracht teruggedraaid, en de volgende `omarchy update` voert ze niet opnieuw uit. Dus als je na een herstel opnieuw bijwerkt en iets dat een eerdere update had ingesteld nog steeds ontbreekt, is dat waarschijnlijk de reden.

_Opmerking: Deze functie is alleen beschikbaar op installaties die de Limine boot loader gebruiken, die sinds Omarchy 2.0 de standaard is. Ze is niet beschikbaar als je GRUB of systemd-boot gebruikt._
