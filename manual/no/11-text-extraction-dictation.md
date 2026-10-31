# Tekstuttrekking og diktering

### Tekstuttrekking

Trykk `Super + Ctrl + PrtScr` for å velge et område på skjermen for tekstuttrekking. Den åpne OCR-modellen tesseract konverterer deretter raskt valget til tekst og legger den på utklippstavlen. Deretter trykker du bare `Super + V` for å lime inn.

Dette er svært nyttig for å hente adresser ut av bildefoter eller telefonnumre som er innebygd i overskrifter på nettsteder.

 ![text-extraction](images/text-extraction.webp)

### Diktering

På ferske installasjoner er [Superwhisper](https://superwhisper.com/) standard dikteringsbackend, med skybehandling uten nedlasting av offline-modeller. Velg Superwhisper eller [Voxtype](https://voxtype.io/) via _Oppsett > Standarder > Diktering_ i Omarchy-menyen. Når du velger en backend, installeres den om nødvendig og gjøres til standard for diktering. Voxtype laster inn en grunnleggende engelsk modell som tar 150 MB; endre modellen med `voxtype setup model` og andre innstillinger via `~/.config/voxtype/config.toml`. Superwhisper åpner innstillingene sine for å velge sky- eller lokal behandling, og OPR holder applikasjonen oppdatert.

Du dikterer ved å holde nede `Right Alt` eller `F9`, eller ved å veksle med `Super + Ctrl + X`, og den dikterte teksten dukker opp i det fokuserte inndatafeltet. Disse snarveiene bruker den valgte backenden. Right Alt starter også diktering når den brukes i en modifikatorkombinasjon; bruk Left Alt for slike kombinasjoner. På tastaturoppsett der Right Alt er AltGr, bruker du `F9` for å beholde AltGr tilgjengelig for skriving.

De samme snarveiene fungerer med begge backendene. Velg backenden din via Oppsett > Standarder > Diktering. Backend-installasjonsprogrammet konfigurerer den og lagrer valget. Kjør `omarchy default dictation` for å se hvilken som er valgt. Valget lagres i `~/.config/omarchy/defaults/dictation`. Ferske installasjoner velger Superwhisper automatisk.

Omarchy laster den valgte backendens skrivebordsintegrasjon automatisk. Ingen Superwhisper-konfigurasjon er nødvendig i `~/.config/hypr/`.

Egendefinerte bindinger og skript kan bruke `omarchy dictation start`, `omarchy dictation stop` og `omarchy dictation toggle`. Den valgte backenden håndterer opptaket og transkriberingen. Å velge Superwhisper deaktiverer dens innebygde hold-snarvei og setter dens innebygde veksling til `Alt + Space`, slik at den holdes atskilt fra Omarchys opptakstaster. Superwhisper krever minst én innebygd opptakssnarvei, og avbrytelsessnarveien forblir tilgjengelig.

Flere backender kan integreres uten å endre Omarchy. Oppgi en kjørbar fil kalt `omarchy-dictation-<backend>` på PATH som godtar `start`, `stop` og `toggle` og returnerer raskt, med en status ulik null ved feil. Installasjonsprogrammet dens konfigurerer leverandøren og kaller `omarchy-dictation-use <backend>` etter vellykket oppsett. Dette stopper den forrige backenden og lagrer valget atomisk; `stop` må lykkes når leverandøren er inaktiv eller utilgjengelig. Backendnavn bruker små bokstaver, sifre og bindestreker. Oppgi `omarchy-install-dictation-<backend>` for oppsett; `omarchy default dictation <backend>` starter den. Legg til en oppføring i Standarder-menyen via en Omarchy-menyutvidelse for å kalle den velgeren. Valgfri skrivebordsintegrasjon kan ligge i `${XDG_CONFIG_HOME:-$HOME/.config}/<backend>/shortcuts.lua`.
