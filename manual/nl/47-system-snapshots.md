# Systeemsnapshots

We maken automatisch snapshots bij elke Omarchy-update, maar als je er zelf een wilt maken, kun je `omarchy-snapshot create` gebruiken.

Om een snapshot op te starten en te herstellen, selecteer je hem in de Limine-bootloader. (Als je momenteel rechtstreeks in het Omarchy-ontsleutelscherm opstart, moet je eerst Limine selecteren als opstartoptie via het BIOS).

Kies op dat scherm de snapshot waarin je wilt opstarten op basis van de datum en versie. De versie van Omarchy op het moment van de snapshot is te zien in de linkerbenedenhoek.

 ![snapshots-bootloader](images/snapshots-bootloader.webp)

Als je binnen bent, verschijnt er een melding die je laat weten dat je in een opstartbare snapshot zit, en als je erop klikt, start het herstelproces. Als alternatief kun je `omarchy-snapshot restore` gebruiken.

 ![snapshots-restore](images/snapshots-restore.webp)

Dit herstelt je root-bestandssysteem, maar niet je `/home`. Dus het werkt om een kapotte systeemupdate terug te draaien, maar niet om verloren persoonlijke bestanden te herstellen.

Dit betekent ook dat je map `~/.config` blijft zoals hij is. Dus als je terugdraait naar een eerdere versie van een bibliotheek of applicatie die configuratiebestanden in een nieuw formaat opslaat, moet je dat handmatig uitzoeken.

_Let op: deze functie is alleen beschikbaar op installaties die de Limine-bootloader gebruiken, wat de standaard is sinds Omarchy 2.0. Hij is niet beschikbaar als je op GRUB of systemd-boot zit._

### Het opstartmenu overslaan

Als je het opstartmenu nooit aanraakt en gewoon wilt dat de machine rechtstreeks naar het ontsleutelscherm gaat, voer dan _Instellen > Direct Boot_ uit in het Omarchy-menu. Dat voegt een EFI-item toe dat rechtstreeks naar Omarchy wijst, zodat de firmware het opstart zonder bij Limine te stoppen.

De keerzijde is degene die bovenaan is genoemd: met direct boot aan betekent bij een snapshot komen dat je eerst Limine kiest in het opstartmenu van je BIOS. Voer _Instellen > Direct Boot_ opnieuw uit om het item te verwijderen en terug te gaan naar opstarten via Limine. Sommige firmware neemt aangepaste EFI-items niet in dank aan, dus de setup weigert te draaien op American Megatrends- en Apple-firmware.
