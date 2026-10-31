# Tekstekstraksjon og diktering

### Tekstekstraksjon

Trykk på `Super + Ctrl + PrtScr` for å velge et område på skjermen for tekstekstraksjon. OCR-modellen tesseract med åpen kildekode konverterer deretter raskt utvalget til tekst og legger det på utklippstavlen. Deretter trykker du bare på `Super + V` for å lime inn.

Dette er svært nyttig for å hente adresser fra bildebunner eller telefonnumre som er innebygd i overskrifter på nettsteder.

 ![text-extraction](images/text-extraction.webp)

### Diktering

På nye installasjoner er [Superwhisper](https://superwhisper.com/) standard backend for diktering, med behandling i skyen uten nedlasting av frakoblede modeller. Velg Superwhisper eller [Voxtype](https://voxtype.io/) via _Oppsett > Standardvalg > Diktering_ i Omarchy-menyen. Når du velger en backend, installeres den ved behov og gjøres til standard for diktering. Voxtype laster en grunnleggende engelsk modell som tar opp 150MB; bytt modell med `voxtype setup model` og endre andre innstillinger via `~/.config/voxtype/config.toml`. Superwhisper åpner innstillingene sine for å velge behandling i skyen eller lokalt, og OPR holder applikasjonen oppdatert.

Du dikterer ved å holde nede `Right Alt`, eller ved å veksle med `Alt + Space`, og den dikterte teksten vises i det fokuserte inndataområdet. Disse snarveiene bruker den valgte backenden. Høyre Alt starter også diktering når den brukes i en modifikatorkombinasjon; bruk venstre Alt til slike kombinasjoner. På tastaturoppsett der høyre Alt er AltGr, bruker du `Alt + Space` for å beholde AltGr tilgjengelig for skriving. Installasjoner fra før Alt + Space ble standarden, beholder `F9` for hold-for-å-snakke og `Super + Ctrl + X` for å veksle, lagt til i `~/.config/hypr/bindings.lua`; fjern dem der for å gi tastene tilbake til applikasjonene.

De samme snarveiene fungerer med begge backendene. Velg backend via Oppsett > Standardvalg > Diktering. Installasjonsprogrammet for backenden konfigurerer den og lagrer valget. Kjør `omarchy default dictation` for å se hvilken som er valgt. Valget lagres i `~/.config/omarchy/defaults/dictation`. Nye installasjoner velger Superwhisper automatisk.

Omarchy laster automatisk skrivebordsintegrasjonen til den valgte backenden. Ingen Superwhisper-konfigurasjon er nødvendig i `~/.config/hypr/`.

Egendefinerte bindinger og skript kan bruke `omarchy dictation start`, `omarchy dictation stop` og `omarchy dictation toggle`. Den valgte backenden håndterer opptaket og transkripsjonen. Når du velger Superwhisper, deaktiveres den innebygde snarveien for å holde nede, og den innebygde vekslesnarveien settes til `Ctrl + Alt + Space`, slik at den holdes atskilt fra opptakstastene til Omarchy. Superwhisper krever minst én innebygd opptakssnarvei, og snarveien for avbryting forblir tilgjengelig.

Ekstra backender kan integreres uten å endre Omarchy. Oppgi en kjørbar fil med navnet `omarchy-dictation-<backend>` på PATH som godtar `start`, `stop` og `toggle` og returnerer umiddelbart, med en status som ikke er null ved feil. Installasjonsprogrammet konfigurerer leverandøren og kaller `omarchy-dictation-use <backend>` etter vellykket oppsett. Dette stopper den forrige backenden og lagrer valget atomisk; `stop` må lykkes når leverandøren er inaktiv eller utilgjengelig. Backend-navn bruker små bokstaver, sifre og bindestreker. Oppgi `omarchy-install-dictation-<backend>` for oppsett; `omarchy default dictation <backend>` starter den. Legg til en menyoppføring under Standardvalg via en menyutvidelse for Omarchy for å kalle den velgeren. Valgfri skrivebordsintegrasjon kan ligge i `${XDG_CONFIG_HOME:-$HOME/.config}/<backend>/shortcuts.lua`.
