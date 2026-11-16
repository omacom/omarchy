# Tekstextractie & dicteren

### Tekstextractie

Druk op `Super + Ctrl + PrtScr` om een gebied op het scherm te selecteren voor tekstextractie. Het open source OCR-model tesseract zet die selectie vervolgens snel om in tekst en plaatst die op het klembord. Daarna druk je gewoon op `Super + V` om te plakken.

Dit is erg handig om adressen uit voetteksten van afbeeldingen of telefoonnummers in koppen van websites te halen.

 ![text-extraction](images/text-extraction.webp)

### Dicteren

Bij nieuwe installaties is [Superwhisper](https://superwhisper.com/) de standaardbackend voor dicteren, met cloudverwerking zonder offline downloads van modellen. Kies Superwhisper, [Voxtype](https://voxtype.io/) of [Hex](https://anoma.ly/hex/) via _Setup > Defaults > Dictation_ in het Omarchy-menu. Wanneer je een backend selecteert, wordt deze indien nodig geïnstalleerd en ingesteld als standaard voor dicteren. Voxtype laadt een Engels basismodel dat 150MB in beslag neemt; wijzig het model met `voxtype setup model` en andere instellingen via `~/.config/voxtype/config.toml`. Superwhisper opent zijn instellingen om te kiezen voor cloud- of lokale verwerking, en OPR houdt de applicatie bijgewerkt. Hex downloadt zijn spraakmodel op het apparaat tijdens de installatie en draait als de gebruikersservice `hex.service`; open het venster via het pictogram in het systeemvak van de balk of door `hex` uit te voeren om het model en andere instellingen te wijzigen.

Je dicteert door `Right Alt` ingedrukt te houden, of door te schakelen met `Alt + Space`, en de gedicteerde tekst verschijnt in het invoerveld met focus. Deze sneltoetsen gebruiken de geselecteerde backend. Right Alt start het dicteren ook wanneer deze wordt gebruikt in een combinatie met een modificatietoets; gebruik Left Alt voor die combinaties. Gebruik op toetsenbordindelingen waarbij Right Alt AltGr is `Alt + Space` om AltGr beschikbaar te houden om te typen. Installaties van voordat Alt + Space de standaard werd, behouden `F9` voor push-to-talk en `Super + Ctrl + X` om te schakelen, toegevoegd aan `~/.config/hypr/bindings.lua`, waar die `Super + Ctrl + X` de plaats inneemt van het agentenpaneel; verwijder ze daar om die toetsen terug te geven aan applicaties en het paneel.

Dezelfde sneltoetsen werken met elke backend. Selecteer je backend via Setup > Defaults > Dictation. Het installatieprogramma van de backend configureert deze en slaat de selectie op. Voer `omarchy default dictation` uit om te zien welke backend is geselecteerd. De selectie wordt opgeslagen in `~/.config/omarchy/defaults/dictation`. Nieuwe installaties selecteren automatisch Superwhisper.

Omarchy laadt de desktopintegratie van de geselecteerde backend automatisch. Er is geen Superwhisper-configuratie nodig in `~/.config/hypr/`.

Aangepaste bindingen en scripts kunnen `omarchy dictation start`, `omarchy dictation stop` en `omarchy dictation toggle` gebruiken. De geselecteerde backend verzorgt de opname en transcriptie. Wanneer je Superwhisper selecteert, wordt de eigen sneltoets om ingedrukt te houden uitgeschakeld en wordt de eigen schakeltoets ingesteld op `Ctrl + Alt + Space`, zodat deze gescheiden blijft van de opnametoetsen van Omarchy. Superwhisper vereist minstens één eigen opnamesneltoets, en de eigen sneltoets om te annuleren blijft beschikbaar.

Extra backends kunnen integreren zonder Omarchy te wijzigen. Lever een uitvoerbaar bestand met de naam `omarchy-dictation-<backend>` op PATH dat `start`, `stop` en `toggle` accepteert en direct terugkeert, met een status ongelijk aan nul bij een fout. Het installatieprogramma configureert de provider en roept na een geslaagde installatie `omarchy-dictation-use <backend>` aan. Dit stopt de vorige backend en slaat de selectie atomair op; `stop` moet slagen wanneer de provider inactief of niet beschikbaar is. Backendnamen gebruiken kleine letters, cijfers en koppeltekens. Lever `omarchy-install-dictation-<backend>` voor de installatie; `omarchy default dictation <backend>` start dit. Voeg via een uitbreiding van het Omarchy-menu een menu-item toe aan Defaults om die selector aan te roepen. Optionele desktopintegratie kan staan in `${XDG_CONFIG_HOME:-$HOME/.config}/<backend>/shortcuts.lua`.
