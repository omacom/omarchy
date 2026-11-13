# Tekstudtræk & diktering

### Tekstudtræk

Tryk på `Super + Ctrl + PrtScr` for at vælge et område på skærmen til tekstudtræk. Den open source OCR-model tesseract vil derefter hurtigt konvertere det valgte område til tekst og lægge det på udklipsholderen. Så trykker du bare på `Super + V` for at indsætte.

Det er meget nyttigt til at hente adresser ud af sidefødder i billeder eller telefonnumre indlejret i overskrifter på websites.

 ![text-extraction](images/text-extraction.webp)

### Diktering

På nye installationer er [Superwhisper](https://superwhisper.com/) standardbackend til diktering og bruger cloudbehandling uden download af offlinemodeller. Vælg Superwhisper, [Voxtype](https://voxtype.io/) eller [Hex](https://anoma.ly/hex/) via _Setup > Defaults > Dictation_ i Omarchy-menuen. Når du vælger en backend, installeres den om nødvendigt og gøres til standard for diktering. Voxtype indlæser en engelsk basismodel, der fylder 150MB; skift modellen med `voxtype setup model`, og andre indstillinger via `~/.config/voxtype/config.toml`. Superwhisper åbner sine indstillinger til at vælge cloud- eller lokal behandling, og OPR holder applikationen opdateret. Hex downloader sin talemodel på enheden under opsætningen og kører som brugertjenesten `hex.service`; åbn dens vindue fra bakkeikonet i bjælken eller ved at køre `hex` for at skifte modellen og andre indstillinger.

Du dikterer ved at holde `Right Alt` nede eller ved at slå det til og fra med `Alt + Space`, og den dikterede tekst vil blive vist i det fokuserede indtastningsområde. Disse genveje bruger den valgte backend. Right Alt starter også diktering, når den bruges i en kombination med modifikatorer; brug Left Alt til de kombinationer. På tastaturlayouts, hvor Right Alt er AltGr, skal du bruge `Alt + Space` for at holde AltGr tilgængelig til at skrive med. Installationer fra før `Alt + Space` blev standarden beholder `F9` til push-to-talk og `Super + Ctrl + X` til at slå til og fra, tilføjet til `~/.config/hypr/bindings.lua`, hvor den `Super + Ctrl + X` tager agentpanelets plads; fjern dem der for at give de taster tilbage til applikationer og panelet.

De samme genveje virker med hver backend. Vælg din backend via Setup > Defaults > Dictation. Backendens installationsprogram konfigurerer den og gemmer valget. Kør `omarchy default dictation` for at se, hvilken der er valgt. Valget gemmes i `~/.config/omarchy/defaults/dictation`. Nye installationer vælger automatisk Superwhisper.

Omarchy indlæser automatisk den valgte backends desktopintegration. Der kræves ingen konfiguration af Superwhisper i `~/.config/hypr/`.

Brugerdefinerede bindinger og scripts kan bruge `omarchy dictation start`, `omarchy dictation stop` og `omarchy dictation toggle`. Den valgte backend håndterer optagelsen og transskriptionen. Når du vælger Superwhisper, deaktiveres dens indbyggede holdegenvej, og dens indbyggede genvej til at slå til og fra sættes til `Ctrl + Alt + Space`, så den holdes adskilt fra Omarchys optagelsestaster. Superwhisper kræver mindst én indbygget optagelsesgenvej, og dens annulleringsgenvej forbliver tilgængelig.

Yderligere backends kan integreres uden at ændre Omarchy. Sørg for en eksekverbar fil med navnet `omarchy-dictation-<backend>` på PATH, som accepterer `start`, `stop` og `toggle` og returnerer med det samme, med en status forskellig fra nul ved fejl. Dens installationsprogram konfigurerer udbyderen og kalder `omarchy-dictation-use <backend>` efter vellykket opsætning. Det stopper den forrige backend og gemmer valget atomisk; `stop` skal lykkes, når udbyderen er inaktiv eller utilgængelig. Backendnavne bruger små bogstaver, cifre og bindestreger. Sørg for `omarchy-install-dictation-<backend>` til opsætning; `omarchy default dictation <backend>` starter den. Tilføj et menupunkt i Defaults via en Omarchy-menuudvidelse for at kalde den pågældende vælger. Valgfri desktopintegration kan ligge i `${XDG_CONFIG_HOME:-$HOME/.config}/<backend>/shortcuts.lua`.
