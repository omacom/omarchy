# Windows-VM

Omarchy biedt een eenvoudige manier om Windows via een Docker-VM te draaien op x86_64-machines. Je kunt het installeren via _Install > Windows_ in het Omarchy-menu (`Super + Space`).

Je machine heeft hiervoor KVM-virtualisatie nodig, wat de meeste machines hebben — maar het staat soms uitgeschakeld in het BIOS, en het installatieprogramma laat het je weten als dat het geval is. Je wilt ook de schijfruimte hebben: wat je Windows ook geeft, plus ongeveer 10GB voor de image zelf.

Het installatieprogramma vraagt hoeveel RAM, hoeveel CPU-cores en hoeveel schijfruimte je wilt overhandigen (64GB of meer is de verstandige ondergrens), en daarna om een Windows-gebruikersnaam en -wachtwoord. Laat die leeg en je krijgt `docker` / `admin`. De download duurt even — 10-15 minuten is normaal — en je kunt de voortgang volgen in de browser op `http://127.0.0.1:8006`. De browser vraagt om dezelfde gebruikersnaam en hetzelfde wachtwoord voordat de console wordt geopend.

 ![windows-vm](images/windows-vm.webp)

## Gebruik

Zodra het is geïnstalleerd, start je _Windows_ vanuit de app launcher. Dat start de VM als die nog niet draait en verbindt je via RDP, in volledig scherm. Geef het 15-30 seconden bij een koude start.

De RDP-sessie geeft geluid, je microfoon en een gedeeld klembord door, dus tekst kopiëren tussen Linux en Windows werkt gewoon. De resolutie volgt je venster, en Omarchy geeft de schaal van je beeldscherm door, dus het is geen wazige bende op een HiDPI-scherm.

Wanneer je het RDP-venster sluit, wordt de VM automatisch afgesloten. Als je hem liever laat draaien — stel dat je daar iets in hebt draaien dat door moet werken — start hem dan in plaats daarvan met `omarchy windows vm launch --keep-alive`.

De rest van de bediening zit op hetzelfde commando:

```bash
omarchy windows vm status    # is it running?
omarchy windows vm stop      # shut it down
omarchy windows vm launch    # start and connect
```

## Bestanden delen

De map `~/Windows` in je thuismap wordt automatisch gedeeld met de VM. Zet daar bestanden neer als je wilt dat Windows erbij kan. De VM heeft geen toegang tot enig ander deel van je bestandssysteem, dus je bent veilig voor alles wat er aan de Windows-kant misgaat. De eigen virtuele schijf is beschikbaar op `~/.windows`.

Die vertrouwde thuispaden blijven op hun eigen bestandssystemen. Ze kunnen ook symlinks zijn naar mappen van jou, wat handig is wanneer de virtuele schijf op een grotere schijf staat. Het installatieprogramma meet de vrije ruimte op het bestandssysteem dat `~/.windows` daadwerkelijk bevat, niet noodzakelijk het bestandssysteem dat je thuismap bevat.

Houd de schijf- en gedeelde paden als afzonderlijke, niet-overlappende mappen. Verwijdering leegt bewust de schijfmap, maar behoudt de gedeelde map. Vlak voor het verwijderen voert Omarchy een begrensde containment-controle uit en weigert het iets te verwijderen als die controle een time-out krijgt of niet kan bewijzen dat de twee directorybomen gescheiden zijn.

Voordat de VM start, opent Omarchy die twee mappen en pint ze vast, en bind-mount het vervolgens de exacte directory-inodes op private, per gebruiker gescheiden ankers onder `/var/lib/omarchy/windows/mounts`. Docker ziet alleen die door root beschermde ankers. Dit behoudt aangepaste schijflocaties en voorkomt tegelijk dat een ander proces dat als jou draait een gecontroleerd pad verwisselt voordat de geprivilegieerde container het gebruikt. Bestaande schijf- en gedeelde mappen worden tijdens de migratie aangescherpt tot modus `0700`, zodat andere lokale accounts hun inhoud niet kunnen doorbladeren.

De poorten van de VM zijn alleen aan localhost gebonden, dus niets op je netwerk kan de Windows-machine bereiken. De webconsole vereist ook de ingestelde Windows-gebruikersnaam en het wachtwoord, waardoor een ander lokaal account de VM niet kan bedienen via poort 8006.

## Beperkingen en licenties

Er is geen GPU-passthrough met deze opzet, dus hij is niet geschikt voor gaming of videobewerking. Het is een geweldige manier om Microsoft Office te draaien, of wat je verder ook absoluut moet hebben.

De geïnstalleerde versie is Windows 11 Pro, niet geactiveerd. Je hebt je eigen licentiesleutel nodig om de afgeschermde functies te gebruiken.

Als deze computer met Windows werd geleverd, staat de OEM-sleutel nog steeds in de firmware, zelfs na het installeren van Omarchy. Print hem met `omarchy windows key`. Die sleutel is gebonden aan deze machine — hij activeert Windows dat opnieuw op deze hardware is geïnstalleerd, maar hij activeert meestal niet de VM.

Je kunt de toewijzing van resources later wijzigen door `omarchy windows vm install` in een terminal uit te voeren; dat herschrijft de configuratie van de VM op basis van je antwoorden. Het compose-bestand zelf staat nu op `/var/lib/omarchy/windows/docker-compose.yml` en is eigendom van root — dat is bewust zo, zodat een proces dat als jou draait het niet kan herschrijven en de geprivilegieerde opstart je hele schijf in de container kan laten mounten. Als je het met de hand moet bewerken (bijvoorbeeld om een USB-apparaat te mounten), bewerk het dan met `sudo` en bekijk alle opties op [het Dockur Windows-project](https://github.com/dockur/windows).

Om van het hele ding af te komen, gebruik je _Remove > Windows_ in het Omarchy-menu. Dat verwijdert de schijf van de VM in `~/.windows` en alles wat binnen Windows is geïnstalleerd, dus kopieer eerst alles wat je nodig hebt uit de VM. Je gedeelde map `~/Windows` wordt met rust gelaten.
