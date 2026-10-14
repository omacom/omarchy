# Windows-VM

Omarchy biedt een eenvoudige manier om Windows via een Docker-VM te draaien. Je kunt het installeren via _Installeren > Windows_ in het Omarchy-menu (`Super + Space`).

Je machine heeft KVM-virtualisatie hiervoor nodig, wat de meeste hebben — maar het is soms uitgeschakeld in het BIOS, en het installatieprogramma vertelt je als dat het geval is. Je wilt ook de schijfruimte: wat je Windows ook geeft, plus ongeveer 10GB voor de image zelf.

Het installatieprogramma vraagt hoeveel RAM, hoeveel CPU-cores en hoeveel schijfruimte je wilt overhandigen (64GB of meer is de verstandige ondergrens), en vervolgens om een Windows-gebruikersnaam en -wachtwoord. Laat die leeg en je krijgt `docker` / `admin`. De download duurt even — 10-15 minuten is normaal — en je kunt de voortgang volgen in de browser op `http://127.0.0.1:8006`. De browser vraagt om dezelfde gebruikersnaam en hetzelfde wachtwoord voordat de console wordt geopend.

 ![windows-vm](images/windows-vm.webp)

## Het gebruiken

Zodra het is geïnstalleerd, start je _Windows_ vanuit de app-launcher. Dat start de VM als deze nog niet draait en verbindt je via RDP, fullscreen. Geef het 15-30 seconden bij een koude start.

De RDP-sessie voert geluid, je microfoon en een gedeeld klembord mee, dus tekst kopiëren tussen Linux en Windows werkt gewoon. De resolutie volgt je venster, en Omarchy geeft je beeldschermschaling door, dus het is geen wazige rotzooi op een HiDPI-scherm.

Wanneer je het RDP-venster sluit, schakelt de VM automatisch uit. Als je hem liever laat draaien — stel dat je daar iets aan het werk hebt — start hem dan in plaats daarvan met `omarchy windows vm launch --keep-alive`.

De rest van de bediening zit op hetzelfde commando:

```bash
omarchy windows vm status    # is it running?
omarchy windows vm stop      # shut it down
omarchy windows vm launch    # start and connect
```

## Bestanden delen

De map `~/Windows` in je thuismap wordt automatisch gedeeld met de VM. Zet daar bestanden neer als je wilt dat ze toegankelijk zijn voor Windows. De VM heeft geen toegang tot enig ander deel van je bestandssysteem, dus je bent veilig voor alles wat naar is aan de Windows-kant. Zijn eigen virtuele schijf is beschikbaar op `~/.windows`.

Die vertrouwde thuispaden blijven op hun eigen bestandssystemen. Ze kunnen ook symlinks zijn naar mappen die van jou zijn, wat handig is wanneer de virtuele schijf op een grotere schijf leeft. Het installatieprogramma meet de vrije ruimte op het bestandssysteem dat daadwerkelijk `~/.windows` bevat, niet noodzakelijk het bestandssysteem dat je thuismap bevat.

Houd de schijf- en gedeelde paden als afzonderlijke, niet-overlappende mappen. Verwijdering leegt bewust de schijfmap maar behoudt de gedeelde map. Vlak voor verwijdering voert Omarchy een begrensde insluitingscontrole uit en weigert het iets te verwijderen als die controle een time-out heeft of niet kan bewijzen dat de twee bomen gescheiden zijn.

Voordat de VM start, opent en pint Omarchy die twee mappen, en bind-mount het daarna de exacte map-inodes op private per-gebruiker ankers onder `/var/lib/omarchy/windows/mounts`. Docker ziet alleen die door root beschermde ankers. Dit behoudt aangepaste schijflocaties terwijl het voorkomt dat een ander proces dat als jou draait een gecontroleerd pad verwisselt voordat de geprivilegieerde container het consumeert. Bestaande schijf- en gedeelde mappen worden tijdens migratie aangescherpt naar modus `0700`, zodat andere lokale accounts hun inhoud niet kunnen doorbladeren.

De poorten van de VM zijn alleen aan localhost gebonden, dus niets op je netwerk kan de Windows-machine bereiken. De webconsole vereist ook de geconfigureerde Windows-gebruikersnaam en het wachtwoord, wat voorkomt dat een ander lokaal account de VM aanstuurt via poort 8006.

## Beperkingen en licenties

Er is geen GPU-passthrough bij deze opstelling, dus het is niet geschikt voor gaming of videobewerking. Het is een geweldige manier om Microsoft Office te draaien of wat je verder absoluut moet hebben.

De geïnstalleerde versie is Windows 11 Pro, niet geactiveerd. Je hebt je eigen licentiesleutel nodig om de gated functies te gebruiken.

Als deze computer met Windows werd geleverd, zit de OEM-sleutel nog steeds in de firmware, zelfs na het installeren van Omarchy. Print hem met `omarchy windows key`. Die sleutel is gebonden aan deze machine — hij activeert Windows dat opnieuw is geïnstalleerd op deze hardware, maar hij activeert de VM meestal niet.

Je kunt de resourcetoewijzing later wijzigen door `omarchy-windows-vm install` opnieuw uit te voeren, wat de configuratie van de VM herschrijft op basis van je antwoorden. Het compose-bestand zelf leeft nu op `/var/lib/omarchy/windows/docker-compose.yml` en is eigendom van root — dat is bewust, zodat een proces dat als jou draait het niet kan herschrijven en de geprivilegieerde bring-up je hele schijf in de container kan laten mounten. Als je het met de hand moet bewerken (bijvoorbeeld om een USB-apparaat te mounten), bewerk het dan met `sudo` en bekijk alle opties op [het Dockur Windows-project](https://github.com/dockur/windows).

Om het hele ding kwijt te raken, gebruik je _Verwijderen > Windows_ in het Omarchy-menu. Dat verwijdert de schijf van de VM en al zijn data, dus zorg ervoor dat alles waar je om geeft eerst uit `~/Windows` is.
