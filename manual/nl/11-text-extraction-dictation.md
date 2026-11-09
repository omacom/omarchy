# Tekstextractie & Dicteren

### Tekstextractie

Druk op `Super + Ctrl + PrtScr` om een gebied op het scherm te selecteren voor tekstextractie. Het open source OCR-model tesseract zet die selectie vervolgens snel om in tekst en plaatst die op het klembord. Daarna druk je gewoon op `Super + V` om te plakken.

Dit is erg handig om adressen uit voetteksten van afbeeldingen te halen of telefoonnummers die in koppen van websites zijn ingesloten.

 ![text-extraction](images/text-extraction.webp)

### Dicteren

Bij nieuwe installaties is [Superwhisper](https://superwhisper.com/) de standaardbackend voor dicteren, met verwerking in de cloud en zonder downloads van offline modellen. Kies Superwhisper, [Voxtype](https://voxtype.io/) of [Hex](https://anoma.ly/hex/) via _Instellen > Standaardwaarden > Dicteren_ in het Omarchy-menu. Als je een backend selecteert, wordt die indien nodig geïnstalleerd en ingesteld als standaard voor dicteren. Voxtype laadt een Engels basismodel dat 150MB in beslag neemt; wijzig het model met `voxtype setup model` en andere instellingen via `~/.config/voxtype/config.toml`. Superwhisper opent zijn instellingen om te kiezen tussen verwerking in de cloud of lokaal, en OPR houdt de applicatie up-to-date. Hex downloadt zijn spraakmodel op het apparaat tijdens de installatie en draait als de gebruikersservice `hex.service`; open het venster via het systeemvakpictogram in de balk of door `hex` uit te voeren om het model en andere instellingen te wijzigen.

Je dicteert door `Right Alt` ingedrukt te houden, of door te schakelen met `Alt + Space`, en de gedicteerde tekst verschijnt in het invoerveld met focus. Deze sneltoetsen gebruiken de geselecteerde backend. Right Alt start dicteren ook wanneer die wordt gebruikt in een combinatie met een modificatietoets; gebruik Left Alt voor die combinaties. Bij toetsenbordindelingen waar Right Alt AltGr is, gebruik je `Alt + Space` om AltGr beschikbaar te houden om te typen. Installaties van voordat Alt + Space de standaard werd, behouden `F9` voor push-to-talk en `Super + Ctrl + X` om te schakelen, toegevoegd aan `~/.config/hypr/bindings.lua`; verwijder ze daar om die toetsen terug te geven aan applicaties.

Dezelfde sneltoetsen werken met elke backend. Selecteer je backend via Instellen > Standaardwaarden > Dicteren. Het installatieprogramma van de backend configureert die en slaat de selectie op. Voer `omarchy default dictation` uit om te zien welke is geselecteerd. De selectie wordt opgeslagen in `~/.config/omarchy/defaults/dictation`. Bij nieuwe installaties wordt Superwhisper automatisch geselecteerd.

Omarchy laadt de desktopintegratie van de geselecteerde backend automatisch. Er is geen configuratie voor Superwhisper nodig in `~/.config/hypr/`.

Aangepaste sneltoetsen en scripts kunnen `omarchy dictation start`, `omarchy dictation stop` en `omarchy dictation toggle` gebruiken. De geselecteerde backend handelt de opname en transcriptie af. Als je Superwhisper selecteert, wordt de eigen sneltoets voor ingedrukt houden uitgeschakeld en wordt de eigen schakeltoets ingesteld op `Ctrl + Alt + Space`, zodat die gescheiden blijft van de opnametoetsen van Omarchy. Superwhisper vereist minstens één eigen sneltoets voor opname, en de eigen sneltoets voor annuleren blijft beschikbaar.

Extra backends kunnen integreren zonder Omarchy te wijzigen. Lever een uitvoerbaar bestand met de naam `omarchy-dictation-<backend>` in PATH dat `start`, `stop` en `toggle` accepteert en direct terugkeert, met een status ongelijk aan nul bij een fout. Het installatieprogramma configureert de provider en roept na een geslaagde installatie `omarchy-dictation-use <backend>` aan. Dit stopt de vorige backend en slaat de selectie atomisch op; `stop` moet slagen wanneer de provider inactief of niet beschikbaar is. Backendnamen gebruiken kleine letters, cijfers en koppeltekens. Lever `omarchy-install-dictation-<backend>` voor de installatie; `omarchy default dictation <backend>` start dat. Voeg een menu-item voor Standaardwaarden toe via een Omarchy-menu-extensie om die selector aan te roepen. Optionele desktopintegratie kan staan in `${XDG_CONFIG_HOME:-$HOME/.config}/<backend>/shortcuts.lua`.
