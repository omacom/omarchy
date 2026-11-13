# Topbjælken

Striben langs toppen af din skærm er Omarchy-bjælken. Den er ikke en påskruet statuslinje, men en del af Omarchy-skallen, den ene langvarige Quickshell-proces, der også tegner menuen, notifikationerne, OSD-popup'erne og låseskærmen. Derfor matcher dens tema perfekt alt det andet, og derfor åbner et panel øjeblikkeligt i stedet for at starte en ny app.

Det er også den eneste del af skrivebordet, der altid er på skærmen, så det er værd at vide, hvad alle de små glyffer gør.

## Hvad er der på den som standard

Bjælken har tre sektioner. Til venstre sidder Omarchy-logoet (menustarteren) og arbejdsområdeindikatorerne. I midten får du statusindikatorerne, uret, Elsewhen (et verdensure), vejret og et Omarchy-opdateringsmærke. Til højre: systembakken, tastaturlayoutet (når mere end ét er konfigureret), agenter, bluetooth, netværk, lyd, skærm og strøm.

Nogle af dem dukker kun op, når de har noget at sige. Tastaturlayoutet vises kun, hvis du har konfigureret mere end ét layout. Opdateringsmærket vises kun, når der venter en Omarchy-opdatering. Og agentikonet vises første gang Omarchy finder AI-kodeforbrug på maskinen (se [AI](17-ai.md)).

## At klikke rundt

Næsten alle widgets gør noget ved venstre-, højre- og midterklik, og flere reagerer på rulning. Det er den del, folk overser — det er på højre- og midterknappen, at meget af det gode gemmer sig.

| Widget | Venstre | Højre | Midten / rul |
| --- | --- | --- | --- |
| Menu | Omarchy-menu | Ny terminal | — |
| Arbejdsområder | Fokuser det arbejdsområde på denne skærm | — | Rul: næste/forrige arbejdsområde |
| Ur | Kalender-popup | Skift mellem etiketformater | Midten: tidszonevælger |
| Vejr | Vejrudsigt-popup | Fuldt vejr som en notifikation | Midten: opdater |
| Lyd | Lydpanel | Slå lyd fra | Midten: panel · rul: lydstyrke |
| Mikrofon | Slå mikrofonen fra | — | Midten: lydpanel · rul: indgangslydstyrke |
| Netværk | Netværkspanel | — | — |
| Bluetooth | Bluetooth-panel | Slå radioen til/fra | — |
| Skærm | Skærmpanel | — | Rul: lysstyrke |
| Strøm | Strømpanel | Slå batteriprocent til/fra | — |
| Medier | Afspil/pause | Coverbillede-popup | Midten: næste · rul: forrige/næste |
| Agenter | Agentpanel | Start din agent | Midten: næste abonnement |
| Bakke | Hold markøren over for at vise skuffen | Højreklik på chevronen for at administrere | — |
| Omarchy-opdatering | Kør opdateringen | — | — |

Ikke alt i den tabel er på din bjælke fra start. Mediewidgetten (MPRIS nu spiller, med et rullende spor og kunstner) og mikrofonwidgetten er begge indbyggede, men slået fra som standard — tilføj dem, hvis du vil have dem, som beskrevet nedenfor.

## Panelerne

At klikke på et bjælkeikon åbner et panel, som er en rigtig popup med skydere, lister og tastaturnavigation i stedet for et værktøjstip. Hver af dem har også en genvejstast, så du aldrig behøver at sigte efter en glyph på 16 pixel:

| Hotkey | Panel |
| --- | --- |
| `Super + Ctrl + A` | Lyd |
| `Super + Ctrl + N` | Netværk |
| `Super + Ctrl + B` | Bluetooth |
| `Super + Ctrl + D` | Skærm |
| `Super + Ctrl + P` | Strøm |
| `Super + Ctrl + Alt + D` | Kalender |
| `Super + Ctrl + Alt + E` | Verdensur |
| `Super + Ctrl + 1-9` | Slå det n'te panel i højre sektion til/fra |

Panelerne er ikke aflæsninger. Det er der, hvor du faktisk gør tingene:

- **Lyd** har en skyder til hovedlydstyrke, en vælger til outputenhed og en mixer pr. app, så du kan skrue ned for den ene browserfane uden at røre ved alt det andet.
- **Netværk** scanner efter Wi-Fi, viser signalstyrke, opretter forbindelse og lader dig vælge en DNS-udbyder.
- **Bluetooth** viser dine enheder med tilslut/afbryd og batteriniveauer.
- **Strøm** viser batteristatistik, skifter strømprofiler (den husker et separat valg for batteri og AC) og viser nogle systemoplysninger.
- **Skærm** har en lysstyrkeskyder, tekststørrelse, forudindstillinger for skærmskalering og — når du har mere end én skærm — kontroller pr. skærm. Se [skærme](33-monitors.md) for den dybere historie.
- **Ur** åbner et månedsgitter med ISO-ugenumre og månedsskift.
- **Verdensur** har en række pr. by med dens vejr, og hvordan dens dag går. Søgning finder byer såvel som tidszoner, så Fort Lauderdale er Fort Lauderdale og ikke New York. Hvis linjen øverst nævner den forkerte by, så klik på den og sig, hvor du er; vælg et sted i en anden tidszone, og systemuret flytter også derhen, hvilket er praktisk, når du rejser. Hold markøren over en by og klik på personknappen for at sige, hvem der bor der — almindelige navne eller `@` GitHub-brugernavne for at få deres ansigter med.

Hvert panel tager imod tastaturet såvel som musen: pile flytter, Return aktiverer, Tab går til nabopanelet, og Escape lukker.

`Super + Ctrl + 1-9` tæller paneler fra venstre mod højre i højre sektion og springer bakken over, da den ikke har sit eget panel. Så tallet matcher det ikon, du ville pege på.

### Tailscale og Dropbox

To widgets mere vises kun på bjælken, når du installerer den tilsvarende tjeneste fra **Install → Service**, og begge er værd at kende, fordi de gør mere end at rapportere status.

**Tailscale**-panelet tilslutter og afbryder tailnet, skifter mellem konti og vælger en exit node (både dine egne maskiner og Mullvad-regioner vises på den liste). Det gennemser også dine maskiner — og med én valgt sender `s` filer til den over Taildrop, hvilket er den hurtigste måde at flytte en fil til din telefon eller en anden bærbar på. `c` kopierer maskinens IP, `n` dens navn og `d` dens fulde DNS-navn. Der er også en send-knap på hver maskinrække, hvis du hellere vil klikke. Det samme fra terminalen er `omarchy tailscale send <machine> [file...]`.

**Dropbox**-panelet håndterer login, viser hvor meget lagerplads du har brugt, og lister nyligt synkroniserede filer.

At fjerne en af tjenesterne fjerner dens widget fra bjælken igen.

## Indikatorer

Den lille klynge i midten er indikatorwidgetten. Det er statusglyffer for tilstande, du har slået til: forstyr ikke, natlys, en [påmindelse](09-reminders.md) i kø, en aktiv skærmoptagelse, hold vågen og [diktering](11-text-extraction-dictation.md). De lyser, når tilstanden er aktiv, og holder sig ellers ude af vejen — hold markøren lige ved siden af dem, hvor de inaktive ville sidde, for at kigge på dem. At klikke på en indikator slår den tilstand til/fra. En mere er kun status: en fjernsession lyser rødt, mens nogen er forbundet til denne maskine gennem gliff.

Hvis du hellere vil have, at de altid er synlige, så sæt `alwaysShow` til `true` på widgetten. Og hvis du kun går op i nogle af dem, så list dem, du vil have, i `items`: `["Dnd", "Reminder", "NightLight"]`. Du kan have mere end én indikatorwidget, så forskellige sektioner kan vise forskellige delmængder.

## Omorganisering af bjælken

Bjælken konfigurerer sig selv. Du behøver ikke at åbne en konfigurationsfil for at flytte ting.

Tag fat i et tomt område på bjælken omkring midten, og træk det mod en anden skærmkant, så flytter bjælken derhen — venstre, højre, top eller bund fungerer alle, og alle widgets tilpasser sig (lodrette bjælker falder tilbage til kompakte former kun med ikoner). Et klik-og-hold starter samme træk. Dobbeltklik med venstre knap på det samme tomme område for at skifte bjælkens baggrund fra klar til glasagtig til uigennemsigtig. Og træk en hvilken som helst widget for at omarrangere den eller smide den ind i en anden sektion; de andre widgets glider fra hinanden for at give plads, hvor den vil lande.

Midten af bjælken er en boks: hvad der end er i den, forbliver centreret som én gruppe, og widgets på hver side af den hænger på dens kanter. Mens du trækker en widget, vises boksen som en omrids, eller en linje tværs over bjælken, når den er tom, og du kan slippe i den eller ved siden af den. Når et slip ville lande i boksen, vokser boksen for at tage widgetten ind.

En widget, du vil have i nærheden, men ikke altid i syne, kan komme i bakkens skuffe: træk den hen på bakken, og skuffen åbner sig for at tage den. Den sidder der efter appikonerne, dukker op, hver gang skuffen gør, og holder sin skuffe åben, mens dens panel er oppe. Træk den tilbage ud på bjælken for at sætte den tilbage.

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

For helt at tilføje eller fjerne en widget skal du bruge plugin-kommandoerne. `omarchy plugin list` viser alle widgets, skallen kender til, med deres id, og derefter:

```bash
omarchy plugin enable omarchy.media --section centerEnd
omarchy plugin disable omarchy.weather
```

## At skjule bjælken

`Super + Shift + Space` slår bjælken fra og til igen uden at dræbe skallen — paneler og genvejstaster bliver ved med at virke, du får bare pixlerne tilbage. Den findes også i menuen under **Appearance → Menu Bar → Hide Bar**.

## Konfigurationsfilen

Det hele gemmes i `~/.config/omarchy/shell.json` under `bar`-nøglen. Her er en forkortet version:

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

Hver widget er én post i et af de fem layoutarrays, og dens indstillinger sidder inline på den post — der er ingen separat indstillingsfil og intet `config`-underobjekt. Urets `format`, `formatAlt` (det, højreklik skifter til) og `verticalFormat` bor alle lige der på `{ "id": "omarchy.clock" }`.

`center` er boksen i midten af bjælken: alt i den centreres på skærmen som én gruppe. `centerBegin` og `centerEnd` hænger på hver side af boksen, hvilket er sådan, uret bliver præcist i midten, selv mens vejret og opdateringsmærket kommer og går. Læg mere end én widget i `center`, og de centreres sammen; lad den være tom, og `centerBegin` og `centerEnd` mødes i midten af bjælken.

En regel, der er værd at internalisere: **når du først har din egen `shell.json`, er den kanonisk**. Indtil du tilpasser noget, læser skallen Omarchys standardfil. I det øjeblik du trækker en widget, kører `omarchy bar` eller selv redigerer filen, ejer du den — der er ingen dyb fletning, så nye standardwidgets i fremtidige Omarchy-udgivelser vises ikke automatisk på din bjælke. `omarchy bar defaults` sætter det medfølgende layout tilbage, hver gang du vil have en ren tavle.

Den samme fil indeholder også dine inaktivitetstider på øverste niveau, uden for `bar`-nøglen: `idle.screensaver` og `idle.lock`, begge i sekunder, siden du blev inaktiv. Så standardpauseskærmen går i gang efter 150 sekunder og låsen efter 300.
