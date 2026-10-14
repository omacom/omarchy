# Menylinjen

Stripa langs toppen av skjermen er Omarchy-linjen. Den er ikke en påskrudd statuslinje, men en del av Omarchy-skallet, den ene langtidskjørende Quickshell-prosessen som også tegner menyen, varslene, OSD-sprettoppvinduene og låseskjermen. Derfor tematiseres den perfekt med alt annet, og derfor åpner et panel øyeblikkelig i stedet for å starte en ny app.

Den er også den ene delen av skrivebordet som alltid er på skjermen, så det er verdt å vite hva alle de små tegnene gjør.

## Hva som er på den som standard

Linjen har tre seksjoner. Til venstre sitter Omarchy-logoen (menystarteren) og arbeidsområdeindikatorene. I midten får du statusindikatorene, klokken, Elsewhen (en verdensk klokke), været og et merke for Omarchy-oppdatering. Til høyre: tastaturoppsettet (når mer enn ett er konfigurert), systemstatusfeltet, agenter, bluetooth, nettverk, lyd, skjerm og strøm.

Noen av disse vises bare når de har noe å si. Tastaturoppsettet vises bare hvis du har konfigurert mer enn ett oppsett. Oppdateringsmerket vises bare når det venter en Omarchy-oppdatering. Og agentikonet vises første gang Omarchy finner AI-kodingsbruk på maskinen (se [AI](17-ai.md)).

## Å klikke rundt

Nesten hver widget gjør noe ved venstre-, høyre- og midtklikk, og flere svarer på rulling. Dette er delen folk går glipp av — høyre- og midtknappene er der mye av det gode skjuler seg.

| Widget | Venstre | Høyre | Midt / rulling |
| --- | --- | --- | --- |
| Meny | Omarchy-menyen | Ny terminal | — |
| Arbeidsområder | Fokuser det arbeidsområdet | — | Rulling: neste/forrige arbeidsområde |
| Klokke | Kalender-sprettoppvindu | Bla gjennom etikettformatet | Midt: tidssonevelger |
| Vær | Prognose-sprettoppvindu | Fullt vær som et varsel | Midt: oppdater |
| Lyd | Lydpanel | Demp | Midt: panel · rulling: volum |
| Mikrofon | Demp mikrofonen | — | Midt: lydpanel · rulling: inndatavolum |
| Nettverk | Nettverkspanel | — | — |
| Bluetooth | Bluetooth-panel | Veksle radioen | — |
| Skjerm | Skjermpanel | — | Rulling: lysstyrke |
| Strøm | Strømpanel | Veksle batteriprosenten | — |
| Media | Spill av / pause | Cover-art-sprettoppvindu | Midt: neste · rulling: forrige/neste |
| Agenter | Agentpanel | Start agenten din | Midt: neste abonnement |
| Statusfelt | Hold over for å vise skuffen | Høyreklikk på vinkeltegnet for å administrere | — |
| Omarchy-oppdatering | Kjør oppdateringen | — | — |

Ikke alt i den tabellen er på linjen din rett fra boksen. Mediewidgeten (MPRIS nå-spilles, med et rullende spor og artist) og mikrofonwidgeten er begge innebygd, men av som standard — legg dem til hvis du vil ha dem, som beskrevet nedenfor.

## Panelene

Å klikke et linjeikon åpner et panel, som er et ordentlig sprettoppvindu med glidere, lister og tastaturnavigering snarere enn et verktøytips. Hvert av dem har også en snarvei, så du aldri trenger å sikte på et tegn på 16 piksler:

| Snarvei | Panel |
| --- | --- |
| `Super + Ctrl + A` | Lyd |
| `Super + Ctrl + W` | Nettverk |
| `Super + Ctrl + B` | Bluetooth |
| `Super + Ctrl + D` | Skjerm |
| `Super + Ctrl + P` | Strøm |
| `Super + Ctrl + Alt + D` | Kalender |
| `Super + Ctrl + Alt + E` | Verdensk klokke |
| `Super + Ctrl + 1-9` | Veksle det n-te panelet i høyre seksjon |

Panelene er ikke avlesninger. De er der du faktisk gjør tingen:

- **Lyd** har en hovedvolumglider, en velger for utdataenhet og en mikser per app, slik at du kan skru ned den ene nettleserfanen uten å røre alt annet.
- **Nettverk** skanner etter Wi-Fi, viser signalstyrke, kobler til og lar deg velge en DNS-leverandør.
- **Bluetooth** lister enhetene dine med tilkobling/frakobling og batterinivåer.
- **Strøm** viser batteristatistikk, bytter strømprofiler (den husker et eget valg for batteri og vekselstrøm) og skriver ut litt systeminfo.
- **Skjerm** har en lysstyrkeglider, tekststørrelse, forhåndsinnstillinger for skjermskalering og — når du har mer enn én skjerm — kontroller per skjerm. Se [skjermer](33-monitors.md) for den dypere historien.
- **Klokke** åpner et månedsrutenett med ISO-ukenumre og månedsstepping.

Hvert panel tar tastaturet i tillegg til musen: piltastene flytter, Return aktiverer, Tab går til nabopanelet, og Escape lukker.

`Super + Ctrl + 1-9` teller paneler fra venstre til høyre i høyre seksjon, og hopper over statusfeltet siden det ikke har noe eget panel. Så tallet matcher ikonet du ville pekt på.

### Tailscale og Dropbox

To widgeter til vises på linjen bare når du installerer den matchende tjenesten fra **Installer → Tjeneste**, og begge er verdt å kjenne til fordi de gjør mer enn å rapportere status.

**Tailscale**-panelet kobler til og fra tailnet-et, bytter mellom kontoer og velger en utgangsnod (både dine egne maskiner og Mullvad-regioner vises i den listen). Det blar også gjennom maskinene dine — og med én valgt, sender `s` filer til den over Taildrop, som er den raskeste måten å flytte en fil til telefonen eller en annen bærbar på. `c` kopierer maskinens IP, `n` navnet dens, og `d` det fulle DNS-navnet dens. Det finnes en sendeknapp på hver maskinrad også, hvis du heller vil klikke. Det samme fra terminalen er `omarchy tailscale send <machine> [file...]`.

**Dropbox**-panelet håndterer innlogging, viser hvor mye lagringsplass du har brukt, og lister nylig synkroniserte filer.

Å fjerne en av tjenestene tar widgeten dens tilbake av linjen.

## Indikatorer

Den lille klyngen i midten er indikatorwidgeten. Dette er statustegn for moduser du har slått på: ikke forstyrr, nattlys, en køet [påminnelse](09-reminders.md), et aktivt skjermopptak, hold våken og [diktering](11-text-extraction-dictation.md). De lyser opp når modusen er aktiv og holder seg ellers av veien — hold til venstre for klokken (over den på en vertikal linje) for å kikke på de inaktive. Å klikke en indikator veksler den modusen. Én til er bare status: en ekstern økt lyser rødt mens noen er koblet til denne maskinen gjennom gliff.

Hvis du heller vil at de alltid skal være synlige, setter du `alwaysShow` til `true` på widgeten. Og hvis du bare bryr deg om noen av dem, lister du dem du vil ha i `items`: `["Dnd", "Reminder", "NightLight"]`. Du kan ha mer enn én indikatorwidget, slik at ulike seksjoner kan vise ulike delmengder.

## Omorganisere linjen

Linjen konfigurerer seg selv. Du trenger ikke åpne en konfigurasjonsfil for å flytte ting.

Ta tak i en tom flekk av linjen rundt midten og dra den mot en annen skjermkant, så flytter linjen dit — venstre, høyre, øverst eller nederst fungerer alle, og hver widget tilpasser seg (vertikale linjer går tilbake til kompakte former med bare ikoner). Et klikk-og-hold starter samme dra. Dobbeltvenstreklikk den samme tomme plassen for å bla gjennom linjebakgrunnen fra klar til glass til ugjennomsiktig. Og dra en hvilken som helst widget for å omorganisere den eller kaste den inn i en annen seksjon.

En widget du vil ha i nærheten, men ikke alltid foran øynene, kan legges i statusfeltets skuff: dra den bort på statusfeltet, så åpner skuffen seg for å ta imot den. Den sitter der etter appikonene, dukker opp hver gang skuffen gjør det, og holder skuffen åpen mens panelet dens er oppe. Dra den tilbake ut på linjen for å legge den tilbake.

Hvis du heller vil velge fra en meny, har **Utløs → Utseende → Menylinje** posisjonen, og **Linjebakgrunn** velger hvordan linjen tegnes: **Ugjennomsiktig linje**, **Glasslinje** (gjennomskinnelig, med det bak den uskarpt) eller **Klar linje**.

De samme tingene har kommandoer, som er det du vil ha for et [dotfil](31-dotfiles.md)-oppsett:

```bash
omarchy bar position bottom
omarchy bar background glassy  # opaque, glassy, none, or cycle
omarchy bar move omarchy.clock --section center --index 0
omarchy bar move omarchy.bluetooth --section tray  # into the tray's drawer
omarchy bar set omarchy.clock format "HH:mm"
omarchy bar defaults          # back to the shipped layout
```

For å legge til eller fjerne en widget helt, bruker du plugin-kommandoene. `omarchy plugin list` skriver ut hver widget skallet kjenner til med ID-en dens, og deretter:

```bash
omarchy plugin enable omarchy.media --section center
omarchy plugin disable omarchy.weather
```

## Skjule linjen

`Super + Shift + Space` veksler linjen av og på igjen uten å drepe skallet — paneler og snarveier fortsetter å fungere, du får bare pikslene tilbake. Den er også i menyen under **Utløs → Utseende → Menylinje → Skjul linje**.

## Konfigurasjonsfilen

Alt lagres i `~/.config/omarchy/shell.json`, under nøkkelen `bar`. Her er en beskåret versjon:

```json
{
  "version": 1,
  "bar": {
    "position": "top",
    "background": "opaque",
    "centerAnchor": "omarchy.clock",
    "layout": {
      "left": [{ "id": "omarchy.menu" }, { "id": "omarchy.workspaces" }],
      "center": [{ "id": "omarchy.clock", "format": "HH:mm" }],
      "right": [{ "id": "omarchy.audio" }, { "id": "omarchy.power" }]
    }
  }
}
```

Hver widget er én oppføring i én av de tre layoutmatrisene, og innstillingene dens sitter innebygd på den oppføringen — det finnes ingen egen innstillingsfil og ingen `config`-underobjekt. Klokkens `format`, `formatAlt` (det høyreklikk blar til) og `verticalFormat` bor alle rett der på `{ "id": "omarchy.clock" }`.

`centerAnchor` navngir den ene senterwidgeten som festes til skjermens eksakte sentrum, med de andre flankert rundt den. Det er slik klokken forblir midt i sentrum selv når været og oppdateringsmerket kommer og går. Sett den til en tom streng, og senterlisten sentreres bare som en gruppe i stedet.

Én regel verdt å internalisere: **når du først har din egen `shell.json`, er den kanonisk**. Til du tilpasser noe som helst, leser skallet Omarchys standardfil. I øyeblikket du drar en widget, kjører `omarchy bar`, eller redigerer filen selv, eier du den — det finnes ingen dyp sammenslåing, så nye standardwidgeter i fremtidige Omarchy-utgivelser dukker ikke opp på linjen din automatisk. `omarchy bar defaults` legger den leverte layouten tilbake når du vil ha en ren tavle.

Den samme filen holder også inaktivitetstimingene dine på øverste nivå, utenfor nøkkelen `bar`: `idle.screensaver` og `idle.lock`, begge i sekunder siden du ble inaktiv. Så standard skjermsparer slår inn ved 150 sekunder og låsen ved 300.
