# Tekstextractie & dicteren

### Tekstextractie

Druk op `Super + Ctrl + PrtScr` om een gebied op het scherm te selecteren voor tekstextractie. Het open source OCR-model tesseract zet die selectie vervolgens snel om naar tekst en plaatst die op het klembord. Daarna druk je gewoon op `Super + V` om te plakken.

Dit is erg handig om adressen uit voetteksten van afbeeldingen te halen of telefoonnummers die in koppen van websites zijn ingesloten.

 ![text-extraction](images/text-extraction.webp)

### Dicteren

Bij nieuwe installaties is [Superwhisper](https://superwhisper.com/) de standaard backend voor dicteren, met verwerking in de cloud zonder offline modellen te downloaden. Kies Superwhisper of [Voxtype](https://voxtype.io/) via _Setup > Defaults > Dictation_ in het Omarchy-menu. Wanneer je een backend selecteert, wordt die indien nodig geïnstalleerd en de standaard voor dicteren gemaakt. Voxtype laadt een Engels basismodel dat 150MB in beslag neemt; wijzig het model met `voxtype setup model` en andere instellingen via `~/.config/voxtype/config.toml`. Superwhisper opent de instellingen om te kiezen voor verwerking in de cloud of lokaal, en OPR houdt de applicatie bijgewerkt.

Je dicteert door `Right Alt` ingedrukt te houden, of door te schakelen met `Alt + Space`, en de gedicteerde tekst verschijnt in het invoerveld met de focus. Deze sneltoetsen gebruiken de geselecteerde backend. Right Alt start dicteren ook wanneer die in een combinatie met een modificatietoets wordt gebruikt; gebruik Left Alt voor die combinaties. Gebruik bij toetsenbordindelingen waar Right Alt AltGr is `Alt + Space` om AltGr beschikbaar te houden om te typen. Installaties van voordat Alt + Space de standaard werd, behouden `F9` voor push-to-talk en `Super + Ctrl + X` om te schakelen, toegevoegd aan `~/.config/hypr/bindings.lua`; verwijder ze daar om die toetsen terug te geven aan applicaties.

Dezelfde sneltoetsen werken met beide backends. Selecteer je backend via Setup > Defaults > Dictation. Het installatieprogramma van de backend configureert die en slaat de selectie op. Voer `omarchy default dictation` uit om te zien welke is geselecteerd. De selectie wordt opgeslagen in `~/.config/omarchy/defaults/dictation`. Nieuwe installaties selecteren Superwhisper automatisch.

Omarchy laadt de desktopintegratie van de geselecteerde backend automatisch. Er is geen Superwhisper-configuratie nodig in `~/.config/hypr/`.

Aangepaste bindingen en scripts kunnen `omarchy dictation start`, `omarchy dictation stop` en `omarchy dictation toggle` gebruiken. De geselecteerde backend handelt de opname en transcriptie af. Superwhisper selecteren schakelt de eigen sneltoets voor ingedrukt houden uit en stelt de eigen schakeltoets in op `Ctrl + Alt + Space`, zodat die apart blijft van de opnametoetsen van Omarchy. Superwhisper vereist minstens één eigen sneltoets voor opname, en de eigen sneltoets voor annuleren blijft beschikbaar.

Extra backends kunnen integreren zonder Omarchy te wijzigen. Lever een uitvoerbaar bestand genaamd `omarchy-dictation-<backend>` in PATH dat `start`, `stop` en `toggle` accepteert en direct terugkeert, met een andere status dan nul bij een fout. Het installatieprogramma configureert de provider en roept na een geslaagde installatie `omarchy-dictation-use <backend>` aan. Dit stopt de vorige backend en slaat de selectie atomair op; `stop` moet slagen wanneer de provider inactief of niet beschikbaar is. Backendnamen gebruiken kleine letters, cijfers en koppeltekens. Lever `omarchy-install-dictation-<backend>` voor de installatie; `omarchy default dictation <backend>` start deze. Voeg een vermelding in het Defaults-menu toe via een uitbreiding van het Omarchy-menu om die selector aan te roepen. Optionele desktopintegratie kan in `${XDG_CONFIG_HOME:-$HOME/.config}/<backend>/shortcuts.lua` staan.
