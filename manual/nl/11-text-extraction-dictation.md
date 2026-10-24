# Tekstextractie & dicteren

### Tekstextractie

Druk op `Super + Ctrl + PrtScr` om een gebied op het scherm te selecteren voor tekstextractie. Het tesseract open source OCR-model zet die selectie dan snel om in tekst en plaatst het op het klembord. Dan druk je gewoon op `Super + V` om te plakken.

Dit is erg handig om adressen uit afbeeldingsvoetteksten of telefoonnummers in websitekoppen te halen.

 ![text-extraction](images/text-extraction.webp)

### Dicteren

Bij nieuwe installaties is [Superwhisper](https://superwhisper.com/) de standaard dicteer-backend, met cloudverwerking zonder offline modeldownloads. Kies Superwhisper of [Voxtype](https://voxtype.io/) via _Instellen > Standaardwaarden > Dicteren_ in het Omarchy-menu. Een backend selecteren installeert hem indien nodig en maakt hem de standaard voor dicteren. Voxtype laadt een basis Engels model dat 150MB inneemt; verander het model met `voxtype setup model` en andere instellingen via `~/.config/voxtype/config.toml`. Superwhisper opent zijn instellingen om cloud- of lokale verwerking te kiezen, en OPR houdt de applicatie bijgewerkt.

Je dicteert door `Right Alt` of `F9` ingedrukt te houden, of door te schakelen met `Super + Ctrl + X`, en de gedicteerde tekst verschijnt in het gefocuste invoergebied. Deze sneltoetsen gebruiken de geselecteerde backend. Right Alt start dicteren ook wanneer het wordt gebruikt in een modifier-akkoord; gebruik Left Alt voor die akkoorden. Op toetsenbordindelingen waar Right Alt AltGr is, gebruik je `F9` om AltGr beschikbaar te houden voor typen.

Dezelfde sneltoetsen werken met beide backends. Selecteer je backend via Instellen > Standaardwaarden > Dicteren. Het backend-installatieprogramma configureert hem en slaat de selectie op. Voer `omarchy default dictation` uit om te zien welke is geselecteerd. De selectie wordt opgeslagen in `~/.config/omarchy/defaults/dictation`. Nieuwe installaties selecteren Superwhisper automatisch.

Omarchy laadt de desktopintegratie van de geselecteerde backend automatisch. Er is geen Superwhisper-configuratie nodig in `~/.config/hypr/`.

Aangepaste bindingen en scripts kunnen `omarchy dictation start`, `omarchy dictation stop` en `omarchy dictation toggle` gebruiken. De geselecteerde backend behandelt de opname en transcriptie. Superwhisper selecteren schakelt zijn native ingedrukt-houden-sneltoets uit en stelt zijn native schakelaar in op `Alt + Space`, waardoor hij gescheiden blijft van Omarchy's opnametoetsen. Superwhisper vereist minstens één native opname-sneltoets, en zijn annuleer-sneltoets blijft beschikbaar.

Extra backends kunnen integreren zonder Omarchy te veranderen. Lever een uitvoerbaar bestand met de naam `omarchy-dictation-<backend>` op PATH dat `start`, `stop` en `toggle` accepteert en prompt retourneert, met een niet-nul status bij falen. Zijn installatieprogramma configureert de provider en roept `omarchy-dictation-use <backend>` aan na succesvolle setup. Dit stopt de vorige backend en slaat de selectie atomisch op; `stop` moet slagen wanneer de provider idle of niet beschikbaar is. Backend-namen gebruiken kleine letters, cijfers en streepjes. Lever `omarchy-install-dictation-<backend>` voor setup; `omarchy default dictation <backend>` start het. Voeg een Standaardwaarden-menu-item toe via een Omarchy-menu-extensie om die selector aan te roepen. Optionele desktopintegratie kan leven in `${XDG_CONFIG_HOME:-$HOME/.config}/<backend>/shortcuts.lua`.
