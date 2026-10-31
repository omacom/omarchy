# Tekstudtræk & diktering

### Tekstudtræk

Tryk på `Super + Ctrl + PrtScr` for at vælge et område på skærmen til tekstudtræk. Den open source OCR-model tesseract vil derefter hurtigt konvertere det valg til tekst og placere det på udklipsholderen. Derefter trykker du bare på `Super + V` for at indsætte.

Det er meget nyttigt til at hente adresser ud af billedfødder eller telefonnumre indlejret i webstedsoverskrifter.

 ![text-extraction](images/text-extraction.webp)

### Diktering

På friske installationer er [Superwhisper](https://superwhisper.com/) standardbackend'en til diktering og bruger cloudbehandling uden offline modeldownloads. Vælg Superwhisper eller [Voxtype](https://voxtype.io/) via _Opsætning > Standarder > Diktering_ i Omarchy-menuen. Valg af en backend installerer den om nødvendigt og gør den til standard for diktering. Voxtype indlæser en engelsk basismodel, der fylder 150 MB; ændr modellen med `voxtype setup model` og andre indstillinger via `~/.config/voxtype/config.toml`. Superwhisper åbner sine indstillinger for at vælge cloud- eller lokal behandling, og OPR holder programmet opdateret.

Du dikterer ved at holde `Right Alt` eller `F9` nede eller ved at slå det til/fra med `Super + Ctrl + X`, og den dikterede tekst vises i det fokuserede indtastningsområde. Disse genveje bruger den valgte backend. Right Alt starter også diktering, når den bruges i en modifikatorakkord; brug Left Alt til de akkorder. På tastaturlayout, hvor Right Alt er AltGr, skal du bruge `F9` for at holde AltGr tilgængelig til at skrive.

De samme genveje virker med begge backends. Vælg din backend via Opsætning > Standarder > Diktering. Backend-installatøren konfigurerer den og gemmer valget. Kør `omarchy default dictation` for at se, hvilken der er valgt. Valget gemmes i `~/.config/omarchy/defaults/dictation`. Friske installationer vælger Superwhisper automatisk.

Omarchy indlæser automatisk den valgte backends skrivebordsintegration. Ingen Superwhisper-konfiguration er nødvendig i `~/.config/hypr/`.

Brugerdefinerede bindinger og scripts kan bruge `omarchy dictation start`, `omarchy dictation stop` og `omarchy dictation toggle`. Den valgte backend håndterer optagelsen og transskriptionen. Valg af Superwhisper deaktiverer dens indbyggede holde-genvej og sætter dens indbyggede til/fra til `Alt + Space`, så den holdes adskilt fra Omarchys optagetaster. Superwhisper kræver mindst én indbygget optagegenvej, og dens annulleringsgenvej forbliver tilgængelig.

Yderligere backends kan integrere uden at ændre Omarchy. Angiv en eksekverbar fil med navnet `omarchy-dictation-<backend>` på PATH, som accepterer `start`, `stop` og `toggle` og returnerer prompte med en status forskellig fra nul ved fejl. Dens installatør konfigurerer udbyderen og kalder `omarchy-dictation-use <backend>` efter vellykket opsætning. Det stopper den forrige backend og gemmer valget atomisk; `stop` skal lykkes, når udbyderen er ledig eller utilgængelig. Backend-navne bruger små bogstaver, cifre og bindestreger. Angiv `omarchy-install-dictation-<backend>` til opsætning; `omarchy default dictation <backend>` starter den. Tilføj en post i menuen Standarder via en Omarchy-menuudvidelse for at kalde den vælger. Valgfri skrivebordsintegration kan bo i `${XDG_CONFIG_HOME:-$HOME/.config}/<backend>/shortcuts.lua`.
