# Topplinjen

Stripen langs toppen av skjermen er Omarchy-linjen. Det er ikke en påskrudd statuslinje, men en del av Omarchy-skallet, den ene langvarige Quickshell-prosessen som også tegner menyen, varslene, OSD-popupene og låseskjermen. Derfor får den perfekt tema sammen med alt annet, og derfor åpnes et panel øyeblikkelig i stedet for å starte en ny app.

Det er også den ene delen av skrivebordet som alltid er på skjermen, så det er verdt å vite hva alle de små tegnene gjør.

## Hva som er på den som standard

Linjen har tre seksjoner. Til venstre sitter Omarchy-logoen (menystarteren) og arbeidsområdeindikatorene. I midten får du statusindikatorene, klokken, Elsewhen (en verdensklokke), været og et merke for Omarchy-oppdatering. Til høyre: systemkurven, tastaturoppsettet (når mer enn ett er konfigurert), agenter, bluetooth, nettverk, lyd, skjerm og strøm.

Noen av dem dukker bare opp når de har noe å si. Tastaturoppsettet vises bare hvis du har konfigurert mer enn ett oppsett. Oppdateringsmerket vises bare når det venter en Omarchy-oppdatering. Og agentikonet vises første gang Omarchy finner AI-kodebruk på maskinen (se [AI](17-ai.md)).

## Å klikke rundt

Nesten hver widget gjør noe ved venstre-, høyre- og midtklikk, og flere reagerer på rulling. Dette er delen folk går glipp av — høyre- og midtknappene er der mye av det gode skjuler seg.

| Widget | Venstre | Høyre | Midten / rulling |
| --- | --- | --- | --- |
| Meny | Omarchy-meny | Ny terminal | — |
| Arbeidsområder | Fokuser det arbeidsområdet på denne skjermen | — | Rulling: neste/forrige arbeidsområde |
| Klokke | Kalender-popup | Bytt etikettformat | Midten: tidssonevelger |
| Vær | Værmelding-popup | Fullt vær som et varsel | Midten: oppdater |
| Lyd | Lydpanel | Demp | Midten: panel · rulling: volum |
| Mikrofon | Demp mikrofonen | — | Midten: lydpanel · rulling: inngangsvolum |
| Nettverk | Nettverkspanel | — | — |
| Bluetooth | Bluetooth-panel | Slå radioen av/på | — |
| Skjerm | Skjermpanel | — | Rulling: lysstyrke |
| Strøm | Strømpanel | Slå batteriprosent av/på | — |
| Medier | Spill av / pause | Cover-popup | Midten: neste · rulling: forrige/neste |
| Agenter | Agentpanel | Start agenten din | Midten: neste abonnement |
| Systemkurv | Hold musepekeren over for å vise skuffen | Høyreklikk på chevronen for å administrere | — |
| Omarchy-oppdatering | Kjør oppdateringen | — | — |

Ikke alt i den tabellen er på linjen din rett ut av boksen. Mediewidgeten (MPRIS som spilles nå, med en rullende tittel og artist) og mikrofonwidgeten er begge innebygd, men av som standard — legg dem til hvis du vil ha dem, som beskrevet nedenfor.

## Panelene

Å klikke på et linjeikon åpner et panel, som er en skikkelig popup med glidebrytere, lister og tastaturnavigasjon i stedet for et verktøytips. Hvert panel har også en hurtigtast, så du aldri må sikte på et tegn på 16 piksler:

| Hurtigtast | Panel |
| --- | --- |
| `Super + Ctrl + A` | Lyd |
| `Super + Ctrl + N` | Nettverk |
| `Super + Ctrl + B` | Bluetooth |
| `Super + Ctrl + D` | Skjerm |
| `Super + Ctrl + P` | Strøm |
| `Super + Ctrl + Alt + D` | Kalender |
| `Super + Ctrl + Alt + E` | Verdensklokke |
| `Super + Ctrl + 1-9` | Slå av/på det n-te panelet i høyre seksjon |

Panelene er ikke avlesninger. De er der du faktisk gjør tingen:

- **Lyd** har en glidebryter for hovedvolum, en velger for utgangsenhet og en mikser per app, så du kan skru ned den ene nettleserfanen uten å røre alt annet.
- **Nettverk** skanner etter Wi-Fi, viser signalstyrke, kobler til og lar deg velge en DNS-leverandør.
- **Bluetooth** lister enhetene dine med tilkobling/frakobling og batterinivåer.
- **Strøm** viser batteristatistikk, bytter strømprofiler (den husker et eget valg for batteri og AC), og skriver ut litt systeminfo.
- **Skjerm** har en glidebryter for lysstyrke, tekststørrelse, forhåndsinnstillinger for skjermskalering og — når du har mer enn én skjerm — kontroller per skjerm. Se [skjermer](33-monitors.md) for den dypere historien.
- **Klokke** åpner et månedsrutenett med ISO-ukenumre og månedsbytte.
- **Verdensklokke** har en rad per by, med været der og hvordan dagen dens går. Søk finner tettsteder så vel som tidssoner, så Fort Lauderdale er Fort Lauderdale og ikke New York. Hvis linjen øverst navngir feil by, klikk på den og si hvor du er; velg et sted i en annen tidssone, og systemklokken flytter dit også, noe som er hendig når du reiser. Hold musepekeren over en by og klikk på personknappen for å si hvem som bor der — enkle navn, eller `@` GitHub-brukernavn for å ta med ansiktene deres.

Hvert panel tar tastaturet så vel som musen: piler flytter, Return aktiverer, Tab går til nabopanelet, og Escape lukker.

`Super + Ctrl + 1-9` teller paneler fra venstre til høyre i høyre seksjon, og hopper over systemkurven siden den ikke har et eget panel. Så tallet samsvarer med ikonet du ville pekt på.

### Tailscale og Dropbox

To widgeter til vises på linjen bare når du installerer den tilhørende tjenesten fra **Install → Service**, og begge er verdt å kjenne til fordi de gjør mer enn å rapportere status.

**Tailscale**-panelet kobler til og fra tailnet-et, bytter mellom kontoer og velger en exit node (både dine egne maskiner og Mullvad-regioner dukker opp i den listen). Det blar også gjennom maskinene dine — og med én valgt sender `s` filer til den over Taildrop, som er den raskeste måten å flytte en fil til telefonen din eller en annen bærbar PC på. `c` kopierer maskinens IP, `n` navnet dens, og `d` det fulle DNS-navnet dens. Det er en sendeknapp på hver maskinrad også, hvis du heller vil klikke. Det samme fra terminalen er `omarchy tailscale send <machine> [file...]`.

**Dropbox**-panelet håndterer innlogging, viser hvor mye lagringsplass du har brukt, og lister nylig synkroniserte filer.

Å fjerne en av tjenestene tar widgeten dens av linjen igjen.

## Indikatorer

Den lille klyngen i midten er indikatorwidgeten. Dette er statustegn for moduser du har slått på: ikke forstyrr, nattlys, en køet [påminnelse](09-reminders.md), et aktivt skjermopptak, hold deg våken, og [diktering](11-text-extraction-dictation.md). De lyser opp når modusen er aktiv og holder seg ellers unna — hold musepekeren hvor som helst på linjen for å kikke på de inaktive. Å klikke på en indikator slår den modusen av/på. Én til er bare status: en ekstern økt lyser rødt mens noen er koblet til denne maskinen gjennom gliff.

Hvis du heller vil at de alltid skal være synlige, setter du `alwaysShow` til `true` på widgeten. Og hvis du bare bryr deg om noen av dem, lister du dem du vil ha i `items`: `["Dnd", "Reminder", "NightLight"]`. Du kan ha mer enn én indikatorwidget, så ulike seksjoner kan vise ulike delmengder.

## Å omorganisere linjen

Linjen konfigurerer seg selv. Du trenger ikke åpne en konfigurasjonsfil for å flytte ting.

Grip et tomt felt på linjen rundt midten og dra det mot en annen skjermkant, og linjen flytter dit — venstre, høyre, topp eller bunn fungerer alle, og hver widget tilpasser seg (vertikale linjer faller tilbake til kompakte former med bare ikoner). Et klikk-og-hold starter samme dra. Dobbeltklikk med venstre knapp på samme tomme plass for å bytte linjebakgrunn fra klar til glassaktig til ugjennomsiktig. Og dra en hvilken som helst widget for å omorganisere den eller kaste den inn i en annen seksjon; de andre widgetene glir fra hverandre for å gi plass der den skal lande.

Midten av linjen er en boks: det som er i den, holder seg sentrert som én gruppe, og widgetene på hver side av den henger på kantene dens. Mens du drar en widget, vises boksen som en kontur, eller en linje på tvers av linjen når den er tom, og du kan slippe inn i den eller ved siden av den. Når et slipp ville landet i boksen, vokser boksen for å ta widgeten inn.

En widget du vil ha rundt deg, men ikke alltid i syne, kan gå i systemkurvens skuff: dra den på systemkurven, og skuffen åpnes for å ta den. Den sitter der etter appikonene, dukker opp hver gang skuffen gjør det, og holder skuffen sin åpen mens panelet dens er oppe. Dra den tilbake ut på linjen for å sette den tilbake.

Hvis du heller vil velge fra en meny, har **Appearance → Menu Bar** posisjonen, og **Bar Background** velger hvordan linjen tegnes: **Opaque Bar**, **Glassy Bar** (gjennomsiktig, med det som er bak, uskarpt), eller **Clear Bar**.

De samme tingene har kommandoer, som er det du vil ha for et [dotfiles](31-dotfiles.md)-oppsett:

```bash
omarchy bar position bottom
omarchy bar background glassy  # opaque, glassy, none, or cycle
omarchy bar move omarchy.weather --section centerBegin --index 0
omarchy bar move omarchy.bluetooth --section tray  # into the tray's drawer
omarchy bar set omarchy.clock format "HH:mm"
omarchy bar defaults          # back to the shipped layout
```

For å legge til eller fjerne en widget helt bruker du plugin-kommandoene. `omarchy plugin list` skriver ut hver widget skallet kjenner til med id-en dens, og deretter:

```bash
omarchy plugin enable omarchy.media --section centerEnd
omarchy plugin disable omarchy.weather
```

## Å skjule linjen

`Super + Shift + Space` slår linjen av og på igjen uten å drepe skallet — paneler og hurtigtaster fortsetter å fungere, du får bare pikslene tilbake. Det er også i menyen under **Appearance → Menu Bar → Hide Bar**.

## Konfigurasjonsfilen

Alt er lagret i `~/.config/omarchy/shell.json`, under nøkkelen `bar`. Her er en trimmet versjon:

```json
{
  "version": 1,
  "bar": {
    "position": "top",
    "background": "opaque",
    "layout": {
      "left": [{ "id": "omarchy.menu" }, { "id": "omarchy.workspaces" }],
      "centerBegin": [{ "id": "omarchy.indicators" }],
      "center": [{ "id": "omarchy.clock", "format": "HH:mm" }],
      "centerEnd": [{ "id": "omarchy.weather" }],
      "right": [{ "id": "omarchy.audio" }, { "id": "omarchy.power" }]
    }
  }
}
```

Hver widget er én oppføring i ett av de fem layout-arrayene, og innstillingene dens sitter innebygd på den oppføringen — det er ingen egen innstillingsfil og ingen `config`-underobjekt. Klokkens `format`, `formatAlt` (det høyreklikk bytter til), og `verticalFormat` lever alle rett der på `{ "id": "omarchy.clock" }`.

`center` er boksen i midten av linjen: alt i den er sentrert på skjermen som én gruppe. `centerBegin` og `centerEnd` henger på hver side av boksen, og det er slik klokken holder seg midt i sentrum selv mens været og oppdateringsmerket kommer og går. Sett mer enn én widget i `center`, og de sentreres sammen; la den være tom, og `centerBegin` og `centerEnd` møtes i midten av linjen.

Én regel verdt å internalisere: **når du først har din egen `shell.json`, er den kanonisk**. Helt til du tilpasser noe, leser skallet Omarchys standardfil. I det øyeblikket du drar en widget, kjører `omarchy bar`, eller redigerer filen selv, eier du den — det er ingen dyp sammenslåing, så nye standardwidgeter i fremtidige Omarchy-utgivelser vil ikke dukke opp på linjen din automatisk. `omarchy bar defaults` setter det medfølgende oppsettet tilbake når du vil ha et rent ark.

Samme fil holder også inaktivitetstidene dine på øverste nivå, utenfor nøkkelen `bar`: `idle.screensaver` og `idle.lock`, begge i sekunder siden du ble inaktiv. Så standard skjermspareren slår inn ved 150 sekunder og låsen ved 300.
