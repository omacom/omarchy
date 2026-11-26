# Tekstekstraksjon & diktering

### Tekstekstraksjon

Trykk `Super + Ctrl + PrtScr` for å velge et område på skjermen for tekstekstraksjon. OCR-modellen tesseract med åpen kildekode konverterer deretter raskt utvalget til tekst og legger det på utklippstavlen. Deretter trykker du bare `Super + V` for å lime inn.

Dette er svært nyttig for å hente adresser fra bildebunnetekster eller telefonnumre innebygd i overskrifter på nettsteder.

 ![text-extraction](images/text-extraction.webp)

### Diktering

På nye installasjoner er [Superwhisper](https://superwhisper.com/) standard dikteringsmotor, med skybehandling uten nedlastinger av frakoblede modeller. Velg Superwhisper, [Voxtype](https://voxtype.io/) eller [Hex](https://anoma.ly/hex/) gjennom _Setup > Defaults > Dictation_ i Omarchy-menyen. Når du velger en motor, installeres den om nødvendig og gjøres til standard for diktering. Voxtype laster inn en grunnleggende engelsk modell som tar 150MB; endre modellen med `voxtype setup model` og andre innstillinger gjennom `~/.config/voxtype/config.toml`. Superwhisper åpner innstillingene sine for å velge sky- eller lokal behandling, og OPR holder applikasjonen oppdatert. Hex laster ned sin talemodell på enheten under oppsettet og kjører som brukertjenesten `hex.service`; åpne vinduet fra tray-ikonet i linjen eller ved å kjøre `hex` for å endre modellen og andre innstillinger.

Du dikterer ved å holde nede `Right Alt`, eller ved å veksle med `Alt + Space`, og den dikterte teksten vises i det fokuserte inndatafeltet. Disse snarveiene bruker den valgte motoren. Right Alt starter også diktering når den brukes i en modifikatorkombinasjon; bruk Left Alt for slike kombinasjoner. På tastaturoppsett der Right Alt er AltGr, inkludert når et slikt oppsett er ett du bytter til, holder du den nede alene et øyeblikk for å diktere; AltGr trykket sammen med en annen tast skriver fortsatt tegnet sitt. Installasjoner fra før Alt + Space ble standard beholder `F9` for trykk-og-snakk og `Super + Ctrl + X` for å veksle, lagt til i `~/.config/hypr/bindings.lua`, der denne `Super + Ctrl + X` tar plassen til agentpanelet; fjern dem der for å gi disse tastene tilbake til applikasjoner og panelet.

De samme snarveiene fungerer med alle motorer. Velg motoren din gjennom Setup > Defaults > Dictation. Motorens installatør konfigurerer den og lagrer valget. Kjør `omarchy default dictation` for å se hvilken som er valgt. Valget lagres i `~/.config/omarchy/defaults/dictation`. Nye installasjoner velger Superwhisper automatisk.

Omarchy laster den valgte motorens skrivebordsintegrasjon automatisk. Ingen Superwhisper-konfigurasjon er nødvendig i `~/.config/hypr/`.

Tilpassede bindinger og skript kan bruke `omarchy dictation start`, `omarchy dictation stop` og `omarchy dictation toggle`. Den valgte motoren håndterer opptaket og transkripsjonen. Når du velger Superwhisper, deaktiviseres den innebygde hold-snarveien, og den innebygde veksle-snarveien settes til `Ctrl + Alt + Space`, slik at den holdes atskilt fra Omarchys opptakstaster. Superwhisper krever minst én innebygd opptakssnarvei, og avbruddssnarveien forblir tilgjengelig.

Flere motorer kan integreres uten å endre Omarchy. Tilby en kjørbar fil ved navn `omarchy-dictation-<backend>` på PATH som godtar `start`, `stop` og `toggle` og returnerer raskt, med en annen status enn null ved feil. Installatøren konfigurerer leverandøren og kaller `omarchy-dictation-use <backend>` etter vellykket oppsett. Dette stopper den forrige motoren og lagrer valget atomisk; `stop` må lykkes når leverandøren er inaktiv eller utilgjengelig. Motornavn bruker små bokstaver, sifre og bindestreker. Tilby `omarchy-install-dictation-<backend>` for oppsett; `omarchy default dictation <backend>` starter den. Legg til en Defaults-menyoppføring gjennom en Omarchy-menyutvidelse for å kalle denne velgeren. Valgfri skrivebordsintegrasjon kan ligge i `${XDG_CONFIG_HOME:-$HOME/.config}/<backend>/shortcuts.lua`.
