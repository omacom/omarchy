# Tekstudtrækning og diktering

### Tekstudtrækning

Tryk på `Super + Ctrl + PrtScr` for at vælge et område på skærmen til tekstudtrækning. OCR-modellen tesseract, der er open source, konverterer derefter hurtigt det valgte område til tekst og lægger det på udklipsholderen. Derefter trykker du bare på `Super + V` for at indsætte.

Det er meget nyttigt til at hente adresser ud af sidefødder på billeder eller telefonnumre, der er indlejret i overskrifter på websites.

 ![text-extraction](images/text-extraction.webp)

### Diktering

På nye installationer er [Superwhisper](https://superwhisper.com/) standard-backend til diktering og bruger cloud-behandling uden downloads af offline-modeller. Vælg Superwhisper, [Voxtype](https://voxtype.io/) eller [Hex](https://anoma.ly/hex/) via _Opsætning > Standarder > Diktering_ i Omarchy-menuen. Når du vælger en backend, installeres den om nødvendigt og gøres til standard for diktering. Voxtype indlæser en grundlæggende engelsk model, der fylder 150MB; skift model med `voxtype setup model` og andre indstillinger via `~/.config/voxtype/config.toml`. Superwhisper åbner sine indstillinger, hvor du kan vælge cloud- eller lokal behandling, og OPR holder applikationen opdateret. Hex downloader sin talemodel på enheden under opsætningen og kører som brugertjenesten `hex.service`; åbn dens vindue fra bjælkens systembakkeikon eller ved at køre `hex` for at skifte model og andre indstillinger.

Du dikterer ved at holde `Right Alt` nede eller ved at slå det til og fra med `Alt + Space`, og den dikterede tekst vises i det fokuserede indtastningsområde. Disse genveje bruger den valgte backend. Right Alt starter også diktering, når den bruges i en modifikatorkombination; brug Left Alt til de kombinationer. På tastaturlayout, hvor Right Alt er AltGr, herunder når et sådant layout er et, du skifter til, skal du holde den nede alene et øjeblik for at diktere; AltGr trykket sammen med en anden tast skriver stadig dens tegn. Installationer fra før Alt + Space blev standarden beholder `F9` til push-to-talk og `Super + Ctrl + X` til at slå til og fra, tilføjet til `~/.config/hypr/bindings.lua`, hvor `Super + Ctrl + X` træder i stedet for agentpanelet; fjern dem der for at give de taster tilbage til applikationer og panelet.

De samme genveje fungerer med alle backends. Vælg din backend via Opsætning > Standarder > Diktering. Backendens installationsprogram konfigurerer den og gemmer valget. Kør `omarchy default dictation` for at se, hvilken der er valgt. Valget gemmes i `~/.config/omarchy/defaults/dictation`. Nye installationer vælger automatisk Superwhisper.

Omarchy indlæser automatisk den valgte backends desktopintegration. Der er ikke brug for nogen Superwhisper-konfiguration i `~/.config/hypr/`.

Brugerdefinerede bindinger og scripts kan bruge `omarchy dictation start`, `omarchy dictation stop` og `omarchy dictation toggle`. Den valgte backend håndterer optagelsen og transskriptionen. Når du vælger Superwhisper, deaktiveres dens indbyggede holdegenvej, og dens indbyggede til/fra-genvej sættes til `Ctrl + Alt + Space`, så den holdes adskilt fra Omarchys optagetaster. Superwhisper kræver mindst én indbygget optagegenvej, og dens annulleringsgenvej forbliver tilgængelig.

Yderligere backends kan integreres uden at ændre Omarchy. Tilbyd en eksekverbar fil med navnet `omarchy-dictation-<backend>` på PATH, som accepterer `start`, `stop` og `toggle` og vender tilbage med det samme, med en status forskellig fra nul ved fejl. Dens installationsprogram konfigurerer udbyderen og kalder `omarchy-dictation-use <backend>` efter vellykket opsætning. Dette stopper den tidligere backend og gemmer valget atomisk; `stop` skal lykkes, når udbyderen er inaktiv eller utilgængelig. Backendnavne bruger små bogstaver, tal og bindestreger. Tilbyd `omarchy-install-dictation-<backend>` til opsætning; `omarchy default dictation <backend>` starter den. Tilføj et menupunkt under Standarder via en Omarchy-menuudvidelse til at kalde den vælger. Valgfri desktopintegration kan ligge i `${XDG_CONFIG_HOME:-$HOME/.config}/<backend>/shortcuts.lua`.
