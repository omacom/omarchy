# Tekstudtræk og diktering

### Tekstudtræk

Tryk på `Super + Ctrl + PrtScr` for at vælge et område på skærmen til tekstudtræk. Den åbne OCR-model tesseract vil derefter hurtigt konvertere det valgte område til tekst og placere det i udklipsholderen. Derefter trykker du bare på `Super + V` for at indsætte.

Det er meget nyttigt til at få fat i adresser fra billedfodnoter eller telefonnumre, der er indlejret i overskrifter på websteder.

 ![text-extraction](images/text-extraction.webp)

### Diktering

På friske installationer er [Superwhisper](https://superwhisper.com/) standardbackenden til diktering og bruger cloudbehandling uden downloads af offlinemodeller. Vælg Superwhisper eller [Voxtype](https://voxtype.io/) via _Setup > Defaults > Dictation_ i Omarchy-menuen. Når du vælger en backend, installeres den om nødvendigt og gøres til standard for diktering. Voxtype indlæser en engelsk basismodel, der fylder 150MB; skift modellen med `voxtype setup model` og andre indstillinger via `~/.config/voxtype/config.toml`. Superwhisper åbner sine indstillinger, så du kan vælge cloud- eller lokal behandling, og OPR holder applikationen opdateret.

Du dikterer ved at holde `Right Alt` nede eller ved at skifte med `Alt + Space`, hvorefter den dikterede tekst vises i det fokuserede indtastningsområde. Disse genveje bruger den valgte backend. Right Alt starter også diktering, når den bruges i en kombinationsgenvej med en modifikatortast; brug Left Alt til de kombinationsgenveje. På tastaturlayout, hvor Right Alt er AltGr, skal du bruge `Alt + Space` for at holde AltGr tilgængelig til skrivning. Installationer fra før Alt + Space blev standarden beholder `F9` til push-to-talk og `Super + Ctrl + X` til at skifte, tilføjet til `~/.config/hypr/bindings.lua`; fjern dem der for at give de taster tilbage til applikationerne.

De samme genveje virker med begge backends. Vælg din backend via Setup > Defaults > Dictation. Installationsprogrammet til backenden konfigurerer den og gemmer valget. Kør `omarchy default dictation` for at se, hvilken der er valgt. Valget gemmes i `~/.config/omarchy/defaults/dictation`. Friske installationer vælger automatisk Superwhisper.

Omarchy indlæser automatisk den valgte backends desktopintegration. Der er ikke brug for nogen Superwhisper-konfiguration i `~/.config/hypr/`.

Brugerdefinerede bindinger og scripts kan bruge `omarchy dictation start`, `omarchy dictation stop` og `omarchy dictation toggle`. Den valgte backend håndterer optagelsen og transskriptionen. Når du vælger Superwhisper, deaktiveres dens indbyggede genvej til at holde nede, og dens indbyggede skiftegenvej sættes til `Ctrl + Alt + Space`, så den holdes adskilt fra Omarchys optagelsestaster. Superwhisper kræver mindst én indbygget optagelsesgenvej, og dens annulleringsgenvej forbliver tilgængelig.

Yderligere backends kan integrere uden at ændre Omarchy. Angiv en eksekverbar fil med navnet `omarchy-dictation-<backend>` på PATH, som accepterer `start`, `stop` og `toggle` og returnerer hurtigt, med en status forskellig fra nul ved fejl. Dens installationsprogram konfigurerer udbyderen og kalder `omarchy-dictation-use <backend>` efter vellykket opsætning. Dette stopper den forrige backend og gemmer valget atomisk; `stop` skal lykkes, når udbyderen er inaktiv eller utilgængelig. Backendnavne bruger små bogstaver, tal og bindestreger. Angiv `omarchy-install-dictation-<backend>` til opsætning; `omarchy default dictation <backend>` starter den. Tilføj et menupunkt under Defaults via en Omarchy-menuudvidelse for at kalde den vælger. Valgfri desktopintegration kan ligge i `${XDG_CONFIG_HOME:-$HOME/.config}/<backend>/shortcuts.lua`.
