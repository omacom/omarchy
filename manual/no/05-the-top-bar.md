# Topplinjen

Stripen langs toppen av skjermen din er Omarchy-linjen. Den er ikke en påskrudd statuslinje, men en del av Omarchy-skallet, den ene Quickshell-prosessen som kjører lenge og som også tegner menyen, varslene, OSD-popupene og låseskjermen. Derfor får den et perfekt tema sammen med alt annet, og derfor åpnes et panel øyeblikkelig i stedet for å starte en ny app.

Den er også den eneste delen av skrivebordet som alltid er på skjermen, så det er verdt å vite hva alle de små symbolene gjør.

## Hva som er på den som standard

Linjen har tre seksjoner. Til venstre sitter Omarchy-logoen (menystarteren) og arbeidsområdeindikatorene. I midten får du statusindikatorene, klokken, Elsewhen (et verdensur), været og et merke for Omarchy-oppdatering. Til høyre: systemskuffen, tastaturoppsettet (når mer enn ett oppsett eller én inndatametode er konfigurert), agenter, Bluetooth, nettverk, lyd, skjerm og strøm.

Noen av dem dukker bare opp når de har noe å si. Tastaturoppsettet vises bare hvis du har konfigurert mer enn ett oppsett eller én inndatametode. Oppdateringsmerket vises bare når en Omarchy-oppdatering venter.

## Å klikke rundt

Nesten hver widget gjør noe ved venstre-, høyre- og midtklikk, og flere reagerer på rulling. Dette er delen folk går glipp av — høyre- og midtknappen er der mye av det gode skjuler seg.

| Widget | Venstre | Høyre | Midten / rulling |
| --- | --- | --- | --- |
| Meny | Omarchy-meny | Ny terminal | — |
| Arbeidsområder | Fokuser det arbeidsområdet på denne skjermen | — | Rull: neste/forrige arbeidsområde |
| Klokke | Kalender-popup | Bla gjennom etikettformatene | Midten: tidssonevelger |
| Verdensur | Verdensurpanel | Oppdater | Midten: oppdater |
| Vær | Værmelding-popup | Full værmelding som et varsel | Midten: oppdater |
| Lyd | Lydpanel | Demp | Midten: panel · rull: volum |
| Mikrofon | Demp mikrofonen | — | Midten: lydpanel · rull: inndatavolum |
| Nettverk | Nettverkspanel | — | — |
| Bluetooth | Bluetooth-panel | Slå radioen av/på | — |
| Skjerm | Skjermpanel | — | Rull: lysstyrke |
| Strøm | Strømpanel | Slå batteriprosenten av/på | — |
| Media | Spill av/pause | Popup med omslagsbilde | Midten: neste · rull: forrige/neste |
| Agenter | Agentpanel | Start agenten din | Midten: oppdater bruk |
| Systemskuff | Hold musepekeren over for å vise skuffen | Høyreklikk på chevronen for å administrere | — |
| Omarchy-oppdatering | Kjør oppdateringen | — | — |

Ikke alt i den tabellen er på linjen din fra start. Mediawidgeten (MPRIS som spiller nå, med et rullende spor og artist) og mikrofonwidgeten er begge innebygd, men av som standard — legg dem til hvis du vil ha dem, som beskrevet nedenfor.

## Panelene

Å klikke på et linjeikon åpner et panel, som er en ordentlig popup med glidebrytere, lister og tastaturnavigasjon i stedet for et verktøytips. Hvert av dem har også en hurtigtast, så du aldri må sikte på et symbol på 16 piksler:

| Hurtigtast | Panel |
| --- | --- |
| `Super + Ctrl + A` | Lyd |
| `Super + Ctrl + N` | Nettverk |
| `Super + Ctrl + B` | Bluetooth |
| `Super + Ctrl + D` | Skjerm |
| `Super + Ctrl + P` | Strøm |
| `Super + Ctrl + Alt + D` | Kalender |
| `Super + Ctrl + Alt + E` | Verdensur |
| `Super + Ctrl + X` | Agenter |
| `Super + Ctrl + 1-9` | Slå av/på det n-te panelet i høyre seksjon |

Panelene er ikke avlesninger. De er der du faktisk gjør tingen:

- **Lyd** har en hovedvolumglidebryter, en velger for utdataenhet og en mikser per app, så du kan skru ned den ene nettleserfanen uten å røre alt annet.
- **Nettverk** søker etter Wi-Fi, viser signalstyrke, kobler til og lar deg velge en DNS-leverandør.
- **Bluetooth** lister enhetene dine med tilkobling/frakobling og batterinivåer.
- **Strøm** viser batteristatistikk, bytter strømprofiler (den husker et separat valg for batteri og AC) og skriver ut litt systeminfo.
- **Skjerm** har en glidebryter for lysstyrke, tekststørrelse, forhåndsinnstillinger for skjermskalering og — når du har mer enn én skjerm — kontroller per skjerm. Se [skjermer](33-monitors.md) for den dypere historien.
- **Klokke** åpner et månedsrutenett med ISO-ukenumre og månedsbytte.
- **Verdensur** har en rad per by, med været der og hvordan dagen dens går. Søk finner byer så vel som tidssoner, så Fort Lauderdale er Fort Lauderdale og ikke New York. Hvis linjen øverst navngir feil by, klikk på den og si hvor du er; velg et sted i en annen tidssone, og systemklokken flytter dit også, noe som er praktisk når du reiser. Hold musepekeren over en by og klikk på personknappen for å si hvem som bor der — enkle navn, eller `@` GitHub-brukernavn for å ta med ansiktene deres.

Hvert panel tar tastaturet så vel som musen: piler flytter, Return aktiverer, Tab går til nabopanelet, og Escape lukker.

`Super + Ctrl + 1-9` teller paneler fra venstre mot høyre i høyre seksjon, og hopper over systemskuffen siden den ikke har noe eget panel. Så tallet samsvarer med ikonet du ville pekt på.

### Tailscale og Dropbox

To widgeter til vises på linjen først når du installerer den tilsvarende tjenesten fra **Installer → Tjeneste**, og begge er verdt å kjenne til fordi de gjør mer enn å rapportere status.

**Tailscale**-panelet kobler til og fra tailnet-et, bytter mellom kontoer og velger en exit-node (både dine egne maskiner og Mullvad-regioner dukker opp i den listen). Det blar også i maskinene dine — og med én valgt sender `s` filer til den over Taildrop, som er den raskeste måten å flytte en fil til telefonen din eller en annen bærbar PC på. `c` kopierer maskinens IP, `n` navnet dens og `d` det fulle DNS-navnet dens. Det finnes også en sendeknapp på hver maskinrad, hvis du heller vil klikke. Det samme fra terminalen er `omarchy tailscale send <machine> [file...]`.

**Dropbox**-panelet håndterer innlogging, viser hvor mye lagringsplass du har brukt, og lister nylig synkroniserte filer.

Å fjerne en av tjenestene tar widgeten dens tilbake av linjen.

## Indikatorer

Den lille klyngen i midten er indikatorwidgeten. Dette er statussymboler for moduser du har slått på: ikke forstyrr, nattlys, en køet [påminnelse](09-reminders.md), et aktivt skjermopptak og hold våken, pluss advarsler mens passordløs sudo er på eller noen er koblet til en ekstern økt. De lyser opp når modusen er aktiv, og holder seg ellers unna — hold musepekeren like ved siden av dem, der de inaktive ville sittet, for å ta en kikk på dem. Å klikke på en indikator slår den modusen av eller på. Én til er kun status: en ekstern økt lyser rødt mens noen er koblet til denne maskinen gjennom gliff.

Hvis du heller vil at de alltid skal være synlige, sett `alwaysShow` til `true` på widgeten. Og hvis du bare bryr deg om noen av dem, list opp dem du vil ha i `items`: `["Dnd", "Reminder", "NightLight"]`. Du kan ha mer enn én indikatorwidget, så forskjellige seksjoner kan vise forskjellige delmengder.

## Å omorganisere linjen

Linjen konfigurerer seg selv. Du trenger ikke åpne en konfigurasjonsfil for å flytte ting.

Grip en tom flekk på linjen rundt midten og dra den mot en annen skjermkant, og linjen flytter dit — venstre, høyre, topp eller bunn fungerer alle, og hver widget tilpasser seg (vertikale linjer faller tilbake til kompakte former med kun ikoner). Et klikk og hold starter den samme drabevegelsen. Dobbeltvenstreklikk på det samme tomme området for å bla gjennom linjens bakgrunn fra gjennomsiktig til glassaktig til ugjennomsiktig. Og dra en hvilken som helst widget for å endre rekkefølgen på den eller kaste den inn i en annen seksjon; de andre widgetene glir fra hverandre for å gi plass der den vil lande.

Midten av linjen er en boks: det som er i den, forblir sentrert som én gruppe, og widgetene på hver side av den henger på kantene dens. Mens du drar en widget, vises boksen som et omriss, eller en linje tvers over linjen når den er tom, og du kan slippe inn i den eller ved siden av den. Når et slipp ville landet i boksen, vokser boksen for å ta widgeten inn.

En widget du vil ha rundt deg, men ikke alltid i syne, kan gå i skuffen til systemskuffen: dra den opp på systemskuffen, og skuffen åpnes for å ta den imot. Den sitter der etter appikonene, dukker opp når skuffen gjør det, og holder skuffen sin åpen mens panelet dens er oppe. Dra den tilbake ut på linjen for å sette den tilbake.

Hvis du heller vil velge fra en meny, har **Utseende → Menylinje** posisjonen, og **Linjebakgrunn** velger hvordan linjen tegnes: **Ugjennomsiktig linje**, **Glassaktig linje** (gjennomsiktig, med det som er bak den uskarpt), eller **Gjennomsiktig linje**.

De samme tingene har kommandoer, og det er det du vil ha for et [dotfiles](31-dotfiles.md)-oppsett:

```bash
omarchy bar position bottom
omarchy bar background glassy  # opaque, glassy, none, or cycle
omarchy bar move omarchy.weather --section centerBegin --index 0
omarchy bar move omarchy.bluetooth --section tray  # into the tray's drawer
omarchy bar set omarchy.clock format "HH:mm"
omarchy bar defaults          # back to the shipped layout
```

For å legge til eller fjerne en widget helt, bruk plugin-kommandoene. `omarchy plugin list` skriver ut hver widget skallet kjenner til med ID-en dens, og deretter:

```bash
omarchy plugin enable omarchy.media --section centerEnd
omarchy plugin disable omarchy.weather
```

## Å skjule linjen

`Super + Shift + Space` slår linjen av og på igjen uten å drepe skallet — paneler og hurtigtaster fortsetter å fungere, du får bare pikslene tilbake. Den finnes også i menyen under **Utseende → Menylinje → Skjul linje**.

## Konfigurasjonsfilen

Alt er lagret i `~/.config/omarchy/shell.json`, under `bar`-nøkkelen. Her er en trimmet versjon:

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

Hver widget er én oppføring i ett av de fem layout-arrayene, og innstillingene dens sitter inne i den oppføringen — det finnes ingen separat innstillingsfil og intet `config`-underobjekt. Klokkens `format`, `formatAlt` (det høyreklikk blar til) og `verticalFormat` bor alle rett der på `{ "id": "omarchy.clock" }`.

`center` er boksen i midten av linjen: alt i den er sentrert på skjermen som én gruppe. `centerBegin` og `centerEnd` henger på hver sin side av boksen, og det er slik klokken forblir helt sentrert selv når været og oppdateringsmerket kommer og går. Sett mer enn én widget i `center`, og de sentreres sammen; la den være tom, og `centerBegin` og `centerEnd` møtes på midten av linjen.

Én regel er verdt å internalisere: **når du har din egen `shell.json`, er den kanonisk**. Inntil du tilpasser noe som helst, leser skallet Omarchy sin standardfil. I det øyeblikket du drar en widget, kjører `omarchy bar` eller redigerer filen selv, eier du den — det finnes ingen dyp sammenslåing, så nye standardwidgeter i fremtidige Omarchy-utgivelser dukker ikke opp på linjen din automatisk. `omarchy bar defaults` setter det medfølgende oppsettet tilbake når du vil ha et rent ark.

Den samme filen holder også inaktivitetstidene dine på toppnivå, utenfor `bar`-nøkkelen: `idle.screensaver` og `idle.lock`, begge i sekunder siden du ble inaktiv. Så standard skjermspareren slår inn etter 150 sekunder og låsen etter 300.
