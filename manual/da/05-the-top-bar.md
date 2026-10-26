# Topbjælken

Strimlen langs toppen af din skærm er Omarchy-bjælken. Den er ikke en påboltet statusbjælke, men en del af Omarchy-skallen, den ene langvarige Quickshell-proces, der også tegner menuen, notifikationerne, OSD-popup'erne og låseskærmen. Derfor matcher den perfekt i tema med alt andet, og derfor åbner et panel øjeblikkeligt i stedet for at starte en ny app.

Den er også det eneste stykke af skrivebordet, der altid er på skærmen, så det er værd at vide, hvad alle de små glyffer gør.

## Hvad der er på den som standard

Bjælken har tre sektioner. Til venstre sidder Omarchy-logoet (menustarteren) og arbejdsområdeindikatorerne. I midten får du statusindikatorerne, uret, Elsewhen (et verdensure), vejret og et Omarchy-opdateringsbadge. Til højre: systembakken, tastaturlayoutet (når mere end ét er konfigureret), agenter, bluetooth, netværk, lyd, skærm og strøm.

Nogle få af dem dukker kun op, når de har noget at sige. Tastaturlayoutet vises kun, hvis du har konfigureret mere end ét layout. Opdateringsbadget vises kun, når der venter en Omarchy-opdatering. Og agentikonet vises første gang Omarchy finder AI-kodningsforbrug på maskinen (se [AI](17-ai.md)).

## Klik rundt

Næsten alle widgets gør noget ved venstre-, højre- og midterklik, og flere reagerer på rulning. Det er den del, folk overser — de gode ting gemmer sig i højre- og midterknapperne.

| Widget | Venstre | Højre | Midten / rul |
| --- | --- | --- | --- |
| Menu | Omarchy-menu | Ny terminal | — |
| Arbejdsområder | Fokuser det arbejdsområde på denne skærm | — | Rul: næste/forrige arbejdsområde |
| Ur | Kalender-popup | Skift etiketformat i cyklus | Midten: tidszonevælger |
| Vejr | Vejrudsigt-popup | Fuld vejrudsigt som notifikation | Midten: opdater |
| Lyd | Lydpanel | Slå lyd fra | Midten: panel · rul: lydstyrke |
| Mikrofon | Slå mikrofonen fra | — | Midten: lydpanel · rul: inputlydstyrke |
| Netværk | Netværkspanel | — | — |
| Bluetooth | Bluetooth-panel | Slå radioen til/fra | — |
| Skærm | Skærmpanel | — | Rul: lysstyrke |
| Strøm | Strømpanel | Slå batteriprocent til/fra | — |
| Medier | Afspil/pause | Coverbillede-popup | Midten: næste · rul: forrige/næste |
| Agenter | Agentpanel | Start din agent | Midten: næste abonnement |
| Bakke | Hold musen over for at vise skuffen | Højreklik på chevronen for at administrere | — |
| Omarchy-opdatering | Kør opdateringen | — | — |

Ikke alt i den tabel er på din bjælke fra start. Mediewidgetten (MPRIS afspiller nu, med et rullende spor og kunstner) og mikrofonwidgetten er begge indbyggede, men slået fra som standard — tilføj dem, hvis du vil have dem, som beskrevet nedenfor.

## Panelerne

Når du klikker på et bjælkeikon, åbnes et panel, som er en rigtig popup med skydere, lister og tastaturnavigation i stedet for et værktøjstip. Hver af dem har også en genvejstast, så du aldrig behøver sigte efter en glyph på 16 pixel:

| Genvejstast | Panel |
| --- | --- |
| `Super + Ctrl + A` | Lyd |
| `Super + Ctrl + N` | Netværk |
| `Super + Ctrl + B` | Bluetooth |
| `Super + Ctrl + D` | Skærm |
| `Super + Ctrl + P` | Strøm |
| `Super + Ctrl + Alt + D` | Kalender |
| `Super + Ctrl + Alt + E` | Verdensure |
| `Super + Ctrl + 1-9` | Slå det n'te panel i højre sektion til/fra |

Panelerne er ikke aflæsninger. Det er der, hvor du faktisk gør tingene:

- **Lyd** har en hovedlydstyrkeskyder, en vælger til outputenhed og en mixer pr. app, så du kan skrue ned for den ene browserfane uden at røre ved alt andet.
- **Netværk** scanner efter Wi-Fi, viser signalstyrke, opretter forbindelse og lader dig vælge en DNS-udbyder.
- **Bluetooth** viser dine enheder med tilslut/afbryd og batteriniveauer.
- **Strøm** viser batteristatistik, skifter strømprofiler (den husker et separat valg for batteri og AC) og udskriver nogle systemoplysninger.
- **Skærm** har en lysstyrkeskyder, tekststørrelse, forudindstillinger for skærmskalering og — når du har mere end én skærm — kontroller pr. skærm. Se [skærme](33-monitors.md) for den dybere historie.
- **Ur** åbner et månedsgitter med ISO-ugenumre og månedsskift.
- **Verdensure** holder en række pr. by med dens vejr, og hvordan dens dag går. Søgning finder byer såvel som tidszoner, så Fort Lauderdale er Fort Lauderdale og ikke New York. Hvis linjen øverst nævner den forkerte by, så klik på den og fortæl, hvor du er; vælg et sted i en anden tidszone, og systemuret flytter også derhen, hvilket er praktisk, når du rejser. Hold musen over en by og klik på personknappen for at fortælle, hvem der bor der — almindelige navne eller `@` GitHub-brugernavne for at tage deres ansigter med.

Hvert panel tager imod tastaturet såvel som musen: pile flytter, Return aktiverer, Tab går til nabopanelet, og Escape lukker.

`Super + Ctrl + 1-9` tæller paneler fra venstre mod højre i højre sektion og springer bakken over, da den ikke har sit eget panel. Så tallet matcher det ikon, du ville pege på.

### Tailscale og Dropbox

To widgets mere vises kun på bjælken, når du installerer den matchende tjeneste fra **Install → Service**, og begge er værd at kende, fordi de gør mere end at rapportere status.

**Tailscale**-panelet tilslutter og afbryder tailnettet, skifter mellem konti og vælger en exit node (dine egne maskiner og Mullvad-regioner vises begge på den liste). Det gennemser også dine maskiner — og med én valgt sender `s` filer til den over Taildrop, hvilket er den hurtigste måde at flytte en fil til din telefon eller en anden bærbar. `c` kopierer maskinens IP, `n` dens navn og `d` dens fulde DNS-navn. Der er også en send-knap på hver maskinrække, hvis du hellere vil klikke. Det samme fra terminalen er `omarchy tailscale send <machine> [file...]`.

**Dropbox**-panelet håndterer login, viser, hvor meget lagerplads du har brugt, og viser nyligt synkroniserede filer.

Hvis du fjerner en af tjenesterne, forsvinder dens widget igen fra bjælken.

## Indikatorer

Den lille klynge i midten er indikatorwidgetten. Det er statusglyffer for tilstande, du har slået til: forstyr ikke, natlys, en sat [påmindelse](09-reminders.md) i kø, en aktiv skærmoptagelse, hold vågen og [diktering](11-text-extraction-dictation.md). De lyser op, når tilstanden er aktiv, og holder sig ellers af vejen — hold musen overalt på bjælken for at kigge på de inaktive. Når du klikker på en indikator, slås den tilstand til/fra. Én mere er kun status: en fjernsession lyser rødt, mens nogen er forbundet til denne maskine gennem gliff.

Hvis du hellere vil have dem altid synlige, så sæt `alwaysShow` til `true` på widgetten. Og hvis du kun interesserer dig for nogle af dem, så angiv dem, du vil have, i `items`: `["Dnd", "Reminder", "NightLight"]`. Du kan have mere end én indikatorwidget, så forskellige sektioner kan vise forskellige delmængder.

## Omarranger bjælken

Bjælken konfigurerer sig selv. Du behøver ikke åbne en konfigurationsfil for at flytte ting.

Tag fat i et tomt område på bjælken omkring midten og træk det mod en anden skærmkant, og bjælken flytter derhen — venstre, højre, top eller bund virker alle, og hver widget tilpasser sig (lodrette bjælker falder tilbage til kompakte former kun med ikoner). Et klik-og-hold starter det samme træk. Dobbeltvenstreklik på det samme tomme område for at skifte bjælkens baggrund i cyklus fra klar til glasagtig til uigennemsigtig. Og træk enhver widget for at omarrangere den eller smide den ind i en anden sektion; de andre widgets glider fra hinanden for at give plads, hvor den vil lande.

Midten af bjælken er en boks: hvad der end er i den, forbliver centreret som én gruppe, og widgetterne på hver side af den hænger ud fra dens kanter. Mens du trækker en widget, vises boksen som en kontur, eller en linje tværs over bjælken, når den er tom, og du kan slippe i den eller ved siden af den. Når et slip ville lande i boksen, vokser boksen for at tage widgetten ind.

En widget, du vil have i nærheden, men ikke altid i syne, kan komme i bakkens skuffe: træk den over på bakken, og skuffen åbner for at tage den. Den sidder der efter appikonerne, dukker op, når skuffen gør, og holder sin skuffe åben, mens dens panel er oppe. Træk den tilbage ud på bjælken for at sætte den tilbage.

Hvis du hellere vil vælge fra en menu, har **Appearance → Menu Bar** positionen, og **Bar Background** vælger, hvordan bjælken tegnes: **Opaque Bar**, **Glassy Bar** (gennemsigtig, med det bagved sløret) eller **Clear Bar**.

De samme ting har kommandoer, hvilket er det, du vil have til en [dotfiles](31-dotfiles.md)-opsætning:

```bash
omarchy bar position bottom
omarchy bar background glassy  # opaque, glassy, none, or cycle
omarchy bar move omarchy.weather --section centerBegin --index 0
omarchy bar move omarchy.bluetooth --section tray  # into the tray's drawer
omarchy bar set omarchy.clock format "HH:mm"
omarchy bar defaults          # back to the shipped layout
```

For at tilføje eller fjerne en widget helt skal du bruge pluginkommandoerne. `omarchy plugin list` udskriver hver widget, skallen kender til, med dens id, og derefter:

```bash
omarchy plugin enable omarchy.media --section centerEnd
omarchy plugin disable omarchy.weather
```

## Skjul bjælken

`Super + Shift + Space` slår bjælken fra og til igen uden at dræbe skallen — paneler og genvejstaster virker stadig, du får bare pixlerne tilbage. Den er også i menuen under **Appearance → Menu Bar → Hide Bar**.

## Konfigurationsfilen

Det hele gemmes i `~/.config/omarchy/shell.json` under `bar`-nøglen. Her er en beskåret version:

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

Hver widget er én post i et af de fem layoutarrays, og dens indstillinger sidder inline på den post — der er ingen separat indstillingsfil og intet `config`-underobjekt. Urets `format`, `formatAlt` (det, højreklik skifter til i cyklus) og `verticalFormat` bor alle lige der på `{ "id": "omarchy.clock" }`.

`center` er boksen i midten af bjælken: alt i den centreres på skærmen som én gruppe. `centerBegin` og `centerEnd` hænger ud fra hver side af boksen, hvilket er sådan, uret forbliver præcis i midten, selv mens vejret og opdateringsbadget kommer og går. Sæt mere end én widget i `center`, og de centreres sammen; lad den være tom, og `centerBegin` og `centerEnd` mødes i midten af bjælken.

Én regel, der er værd at internalisere: **når du først har din egen `shell.json`, er den kanonisk**. Indtil du tilpasser noget, læser skallen Omarchys standardfil. I det øjeblik du trækker en widget, kører `omarchy bar` eller selv redigerer filen, ejer du den — der er ingen dyb fletning, så nye standardwidgets i fremtidige Omarchy-udgivelser vises ikke automatisk på din bjælke. `omarchy bar defaults` sætter det leverede layout tilbage, når du vil have en ren tavle.

Den samme fil rummer også dine inaktivitetstider på øverste niveau, uden for `bar`-nøglen: `idle.screensaver` og `idle.lock`, begge i sekunder, siden du blev inaktiv. Så standardpauseskærmen går i gang efter 150 sekunder og låsen efter 300.
