# Tekstutvinning og diktering

### Tekstutvinning

Trykk `Super + Ctrl + PrtScr` for å velge et område på skjermen til tekstutvinning. OCR-modellen tesseract med åpen kildekode vil deretter raskt konvertere det valgte området til tekst og legge det på utklippstavlen. Deretter trykker du bare `Super + V` for å lime inn.

Dette er svært nyttig for å hente adresser ut av bunntekster i bilder eller telefonnumre innebygd i overskrifter på nettsteder.

 ![text-extraction](images/text-extraction.webp)

### Diktering

På ferske installasjoner er [Superwhisper](https://superwhisper.com/) standardbackend for diktering, med skybehandling uten nedlasting av modeller for frakoblet bruk. Velg Superwhisper, [Voxtype](https://voxtype.io/) eller [Hex](https://anoma.ly/hex/) via _Setup > Defaults > Dictation_ i Omarchy-menyen. Å velge en backend installerer den om nødvendig og gjør den til standard for diktering. Voxtype laster en grunnleggende engelsk modell som tar opp 150MB; bytt modell med `voxtype setup model` og andre innstillinger via `~/.config/voxtype/config.toml`. Superwhisper åpner innstillingene sine for å velge skybehandling eller lokal behandling, og OPR holder applikasjonen oppdatert. Hex laster ned talemodellen sin for bruk på enheten under oppsettet og kjører som brukertjenesten `hex.service`; åpne vinduet dens fra systemstatusfeltikonet på linjen eller ved å kjøre `hex` for å bytte modell og andre innstillinger.

Du dikterer ved å holde nede `Right Alt`, eller ved å veksle med `Alt + Space`, og den dikterte teksten vises i det fokuserte inndatafeltet. Disse snarveiene bruker den valgte backenden. Right Alt starter også diktering når den brukes i en modifikatorkombinasjon; bruk Left Alt til slike kombinasjoner. På tastaturoppsett der Right Alt er AltGr, bruker du `Alt + Space` for å beholde AltGr tilgjengelig for skriving. Installasjoner fra før Alt + Space ble standard, beholder `F9` for trykk-og-snakk og `Super + Ctrl + X` for å veksle, lagt til i `~/.config/hypr/bindings.lua`, der `Super + Ctrl + X` tar plassen til agentpanelet; fjern dem der for å gi disse tastene tilbake til applikasjoner og panelet.

De samme snarveiene fungerer med alle backender. Velg backenden din via Setup > Defaults > Dictation. Installasjonsprogrammet for backenden konfigurerer den og lagrer valget. Kjør `omarchy default dictation` for å se hvilken som er valgt. Valget lagres i `~/.config/omarchy/defaults/dictation`. Ferske installasjoner velger Superwhisper automatisk.

Omarchy laster den valgte backendens skrivebordsintegrasjon automatisk. Ingen Superwhisper-konfigurasjon er nødvendig i `~/.config/hypr/`.

Egendefinerte bindinger og skript kan bruke `omarchy dictation start`, `omarchy dictation stop` og `omarchy dictation toggle`. Den valgte backenden håndterer opptaket og transkripsjonen. Å velge Superwhisper deaktiverer den innebygde holdesnarveien dens og setter den innebygde vekslesnarveien til `Ctrl + Alt + Space`, slik at den holdes atskilt fra Omarchys opptakstaster. Superwhisper krever minst én innebygd snarvei for opptak, og avbruddssnarveien dens forblir tilgjengelig.

Flere backender kan integreres uten å endre Omarchy. Sørg for en kjørbar fil med navnet `omarchy-dictation-<backend>` på PATH som godtar `start`, `stop` og `toggle` og returnerer raskt, med en status som ikke er null ved feil. Installasjonsprogrammet dens konfigurerer leverandøren og kaller `omarchy-dictation-use <backend>` etter vellykket oppsett. Dette stopper den forrige backenden og lagrer valget atomisk; `stop` må lykkes når leverandøren er inaktiv eller utilgjengelig. Backendnavn bruker små bokstaver, sifre og bindestreker. Sørg for `omarchy-install-dictation-<backend>` til oppsett; `omarchy default dictation <backend>` starter den. Legg til en menyoppføring under Defaults via en utvidelse av Omarchy-menyen for å kalle den velgeren. Valgfri skrivebordsintegrasjon kan ligge i `${XDG_CONFIG_HOME:-$HOME/.config}/<backend>/shortcuts.lua`.
