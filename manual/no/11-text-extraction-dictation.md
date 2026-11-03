# Tekstekstraksjon & Diktering

### Tekstekstraksjon

Trykk `Super + Ctrl + PrtScr` for å velge et område på skjermen for tekstekstraksjon. OCR-modellen tesseract med åpen kildekode konverterer deretter raskt utvalget til tekst og plasserer det på utklippstavlen. Deretter trykker du bare `Super + V` for å lime inn.

Dette er svært nyttig for å hente adresser fra bildebunntekster eller telefonnumre innebygd i overskrifter på nettsteder.

 ![text-extraction](images/text-extraction.webp)

### Diktering

På ferske installasjoner er [Superwhisper](https://superwhisper.com/) standard dikteringsbackend, med skyprosessering uten nedlasting av frakoblede modeller. Velg Superwhisper, [Voxtype](https://voxtype.io/) eller [Hex](https://anoma.ly/hex/) via _Setup > Defaults > Dictation_ i Omarchy-menyen. Når du velger en backend, installeres den ved behov og settes som standard for diktering. Voxtype laster inn en grunnleggende engelsk modell som tar 150MB; endre modellen med `voxtype setup model` og andre innstillinger via `~/.config/voxtype/config.toml`. Superwhisper åpner innstillingene sine for å velge sky- eller lokal prosessering, og OPR holder applikasjonen oppdatert. Hex laster ned talemodellen på enheten under oppsettet og kjører som brukertjenesten `hex.service`; åpne vinduet fra systemstatusfeltikonet på linjen eller ved å kjøre `hex` for å endre modellen og andre innstillinger.

Du dikterer ved å holde nede `Right Alt`, eller ved å veksle med `Alt + Space`, og den dikterte teksten vises i det fokuserte inndataområdet. Disse snarveiene bruker den valgte backenden. Right Alt starter også diktering når den brukes i en modifikatorkombinasjon; bruk Left Alt for slike kombinasjoner. På tastaturoppsett der Right Alt er AltGr, bruker du `Alt + Space` for å holde AltGr tilgjengelig for skriving. Installasjoner fra før Alt + Space ble standard beholder `F9` for trykk-og-snakk og `Super + Ctrl + X` for å veksle, lagt til i `~/.config/hypr/bindings.lua`; fjern dem der for å gi tastene tilbake til applikasjonene.

De samme snarveiene fungerer med alle backender. Velg backend via Setup > Defaults > Dictation. Installasjonsprogrammet for backenden konfigurerer den og lagrer valget. Kjør `omarchy default dictation` for å se hvilken som er valgt. Valget lagres i `~/.config/omarchy/defaults/dictation`. Ferske installasjoner velger Superwhisper automatisk.

Omarchy laster automatisk inn skrivebordsintegrasjonen til den valgte backenden. Ingen Superwhisper-konfigurasjon er nødvendig i `~/.config/hypr/`.

Egendefinerte bindinger og skript kan bruke `omarchy dictation start`, `omarchy dictation stop` og `omarchy dictation toggle`. Den valgte backenden håndterer opptaket og transkripsjonen. Når du velger Superwhisper, deaktiveres dens innebygde hold-snarvei, og dens innebygde vekslesnarvei settes til `Ctrl + Alt + Space`, slik at den holdes adskilt fra Omarchys opptakstaster. Superwhisper krever minst én innebygd opptakssnarvei, og avbruddssnarveien forblir tilgjengelig.

Flere backender kan integreres uten å endre Omarchy. Oppgi en kjørbar fil med navnet `omarchy-dictation-<backend>` på PATH som godtar `start`, `stop` og `toggle` og returnerer umiddelbart, med en status ulik null ved feil. Installasjonsprogrammet konfigurerer leverandøren og kaller `omarchy-dictation-use <backend>` etter vellykket oppsett. Dette stopper den forrige backenden og lagrer valget atomisk; `stop` må lykkes når leverandøren er inaktiv eller utilgjengelig. Backend-navn bruker små bokstaver, sifre og bindestreker. Oppgi `omarchy-install-dictation-<backend>` for oppsett; `omarchy default dictation <backend>` starter den. Legg til en menypost i Defaults via en Omarchy-menyutvidelse for å kalle den velgeren. Valgfri skrivebordsintegrasjon kan ligge i `${XDG_CONFIG_HOME:-$HOME/.config}/<backend>/shortcuts.lua`.
