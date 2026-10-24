# Menulinjen

Striben langs toppen af din skærm er Omarchy-linjen. Den er ikke en påspændt statuslinje, men en del af Omarchy-shell'en, den ene langvarige Quickshell-proces, som også tegner menuen, notifikationerne, OSD-popups og låseskærmen. Det er derfor, den har perfekt tema med alt andet, og hvorfor et panel åbner øjeblikkeligt i stedet for at starte en ny app.

Den er også det eneste stykke af skrivebordet, der altid er på skærmen, så det er værd at vide, hvad alle de små tegn gør.

## Hvad der er på den som standard

Linjen har tre sektioner. Til venstre sidder Omarchy-logoet (menustarteren) og arbejdsområdeindikatorerne. I midten får du statusindikatorerne, uret, Elsewhen (et verdensuret), vejret og et Omarchy-opdateringsbadge. Til højre: tastaturlayoutet (når mere end ét er konfigureret), systembakken, agenter, bluetooth, netværk, lyd, skærm og strøm.

Nogle af dem vises kun, når de har noget at sige. Tastaturlayoutet vises kun, hvis du har konfigureret mere end ét layout. Opdateringsbadget vises kun, når der venter en Omarchy-opdatering. Og agentikonet vises første gang, Omarchy finder AI-kodningsforbrug på maskinen (se [AI](17-ai.md)).

## At klikke rundt

Næsten alle widgets gør noget ved venstre-, højre- og midterklik, og flere reagerer på rulning. Det er den del, folk overser — højre- og midterknapperne er der, hvor meget af det gode gemmer sig.

| Widget | Venstre | Højre | Midter / rul |
| --- | --- | --- | --- |
| Menu | Omarchy-menu | Ny terminal | — |
| Arbejdsområder | Fokusér det arbejdsområde | — | Rul: næste/forrige arbejdsområde |
| Ur | Kalender-popup | Bladr igennem etiketformatet | Midter: tidszonevælger |
| Vejr | Udsigt-popup | Fuldt vejr som notifikation | Midter: opdater |
| Lyd | Lydpanel | Lydløs | Midter: panel · rul: lydstyrke |
| Mikrofon | Slå mikrofonen fra | — | Midter: lydpanel · rul: inputlydstyrke |
| Netværk | Netværkspanel | — | — |
| Bluetooth | Bluetooth-panel | Slå radioen til/fra | — |
| Skærm | Skærmpanel | — | Rul: lysstyrke |
| Strøm | Strømpanel | Slå batteriprocenten til/fra | — |
| Medier | Afspil/pause | Cover-popup | Midter: næste · rul: forrige/næste |
| Agenter | Agentpanel | Start din agent | Midter: næste abonnement |
| Bakke | Hold musen over for at afsløre skuffen | Højreklik på chevronen for at administrere | — |
| Omarchy-opdatering | Kør opdateringen | — | — |

Ikke alt i den tabel er på din linje fra start. Mediewidget'en (MPRIS-nu-kørende med et rullende nummer og kunstner) og mikrofonwidget'en er begge indbyggede, men slået fra som standard — tilføj dem, hvis du vil, som beskrevet nedenfor.

## Panelerne

Et klik på et linjeikon åbner et panel, som er en rigtig popup med skydere, lister og tastaturnavigation snarere end et værktøjstip. Hvert af dem har også en genvejstast, så du aldrig behøver at sigte efter et 16-pixel-tegn:

| Genvejstast | Panel |
| --- | --- |
| `Super + Ctrl + A` | Lyd |
| `Super + Ctrl + W` | Netværk |
| `Super + Ctrl + B` | Bluetooth |
| `Super + Ctrl + D` | Skærm |
| `Super + Ctrl + P` | Strøm |
| `Super + Ctrl + Alt + D` | Kalender |
| `Super + Ctrl + Alt + E` | Verdensur |
| `Super + Ctrl + 1-9` | Slå det n'te panel i højre sektion til/fra |

Panelerne er ikke aflæsninger. De er der, hvor du rent faktisk gør tingene:

- **Lyd** har en masterlydstyrkeskyder, en vælger til outputenhed og en mixer pr. app, så du kan skrue ned for den ene browserfane uden at røre alt andet.
- **Netværk** scanner efter Wi-Fi, viser signalstyrke, forbinder og lader dig vælge en DNS-udbyder.
- **Bluetooth** lister dine enheder med tilslut/afbryd og batteriniveauer.
- **Strøm** viser batteristatistik, skifter strømprofiler (den husker et separat valg for batteri og vekselstrøm) og udskriver nogle systemoplysninger.
- **Skærm** rummer en lysstyrkeskyder, tekststørrelse, forudindstillinger for skærmskalering og — når du har mere end én skærm — kontroller pr. skærm. Se [skærme](33-monitors.md) for hele historien.
- **Ur** åbner et månedsgitter med ISO-ugenumre og månedstrin.

Hvert panel tager tastaturet såvel som musen: pilene flytter, Return aktiverer, Tab går videre til nabopanelet, og Escape lukker.

`Super + Ctrl + 1-9` tæller paneler fra venstre mod højre i højre sektion og springer bakken over, da den ikke har noget eget panel. Så nummeret matcher det ikon, du ville pege på.

### Tailscale og Dropbox

To widgets mere vises på linjen, først når du installerer den matchende tjeneste fra **Installer → Service**, og begge er værd at kende, fordi de gør mere end at rapportere status.

**Tailscale**-panelet tilslutter og frakobler tailnet'et, skifter mellem konti og vælger en exit-node (både dine egne maskiner og Mullvad-regioner vises på den liste). Den gennemser også dine maskiner — og når én er valgt, sender `s` filer til den via Taildrop, hvilket er den hurtigste måde at flytte en fil til din telefon eller en anden bærbar på. `c` kopierer maskinens IP, `n` dens navn og `d` dens fulde DNS-navn. Der er også en sendeknap på hver maskinrække, hvis du hellere vil klikke. Det samme fra terminalen er `omarchy tailscale send <machine> [file...]`.

**Dropbox**-panelet håndterer login, viser, hvor meget lagerplads du har brugt, og lister nyligt synkroniserede filer.

Fjerner du en af tjenesterne, tages dens widget af linjen igen.

## Indikatorer

Den lille klynge i midten er indikatorwidget'en. Det er statustegn for tilstande, du har slået til: forstyr ikke, natlys, en [påmindelse](09-reminders.md) i kø, en aktiv skærmoptagelse, hold vågen og [diktering](11-text-extraction-dictation.md). De lyser op, når tilstanden er aktiv, og holder sig ellers væk — hold musen til venstre for uret (over det på en lodret linje) for at smugkigge på de inaktive. Et klik på en indikator slår den tilstand til eller fra. Én mere er kun status: en ekstern session lyser rødt, mens nogen er forbundet til denne maskine via gliff.

Hvis du hellere vil have dem altid synlige, skal du sætte `alwaysShow` til `true` på widget'en. Og hvis du kun går op i nogle af dem, skal du liste dem, du vil have, i `items`: `["Dnd", "Reminder", "NightLight"]`. Du kan have mere end én indikatorwidget, så forskellige sektioner kan vise forskellige delsæt.

## Omarrangering af linjen

Linjen konfigurerer sig selv. Du behøver ikke at åbne en konfigurationsfil for at flytte ting.

Grib et tomt område på linjen omkring midten, og træk det mod en anden skærmkant, og linjen flytter derover — venstre, højre, top eller bund virker alle, og hver widget tilpasser sig (lodrette linjer falder tilbage til kompakte former kun med ikoner). Et klik-og-hold starter den samme trækning. Dobbelt-venstreklik på det samme tomme område for at bladre linjens baggrund fra klar til glasagtig til uigennemsigtig. Og træk en hvilken som helst widget for at omarrangere den eller kaste den ind i en anden sektion.

En widget, du vil have ved hånden, men ikke altid i syne, kan ryge i bakkens skuffe: træk den hen på bakken, og skuffen åbner sig og tager imod den. Den sidder der efter appikonerne, dukker op, hver gang skuffen gør det, og holder sin skuffe åben, mens dens panel er oppe. Træk den tilbage ud på linjen for at sætte den på plads igen.

Hvis du hellere vil vælge fra en menu, har **Udløs → Udseende → Menulinje** placeringen, og **Linjebaggrund** vælger, hvordan linjen tegnes: **Uigennemsigtig linje**, **Glaslinje** (gennemsigtig, med det bagved sløret) eller **Klar linje**.

De samme ting har kommandoer, hvilket er det, du vil have til en [dotfiles](31-dotfiles.md)-opsætning:

```bash
omarchy bar position bottom
omarchy bar background glassy  # opaque, glassy, none, or cycle
omarchy bar move omarchy.clock --section center --index 0
omarchy bar move omarchy.bluetooth --section tray  # into the tray's drawer
omarchy bar set omarchy.clock format "HH:mm"
omarchy bar defaults          # back to the shipped layout
```

For at tilføje eller fjerne en widget helt skal du bruge plugin-kommandoerne. `omarchy plugin list` udskriver alle widgets, shell'en kender, med deres id, og derefter:

```bash
omarchy plugin enable omarchy.media --section center
omarchy plugin disable omarchy.weather
```

## At skjule linjen

`Super + Shift + Space` slår linjen fra og til igen uden at dræbe shell'en — paneler og genvejstaster virker stadig, du får bare pixelne tilbage. Det findes også i menuen under **Udløs → Udseende → Menulinje → Skjul linje**.

## Konfigurationsfilen

Det hele gemmes i `~/.config/omarchy/shell.json` under nøglen `bar`. Her er en beskåret version:

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

Hver widget er én post i ét af de tre layout-arrays, og dets indstillinger sidder inline på den post — der er ingen separat indstillingsfil og intet `config`-underobjekt. Urets `format`, `formatAlt` (hvad højreklik bladrer til) og `verticalFormat` bor alle lige der på `{ "id": "omarchy.clock" }`.

`centerAnchor` navngiver den ene midterwidget, der fastgøres til skærmens nøjagtige midte, med de andre ved dens side. Det er sådan, uret forbliver præcis i midten, selv når vejret og opdateringsbadget kommer og går. Sæt det til en tom streng, og midterlisten centreres bare som en gruppe i stedet.

Én regel, der er værd at internalisere: **når du først har din egen `shell.json`, er den kanonisk**. Indtil du tilpasser noget, læser shell'en Omarchys standardfil. I det øjeblik du trækker en widget, kører `omarchy bar` eller redigerer filen selv, ejer du den — der er ingen dyb sammenfletning, så nye standardwidgets i fremtidige Omarchy-udgivelser vises ikke automatisk på din linje. `omarchy bar defaults` sætter det leverede layout tilbage, når du vil have en ren tavle.

Den samme fil rummer også dine ledig-tider på øverste niveau, uden for nøglen `bar`: `idle.screensaver` og `idle.lock`, begge i sekunder, siden du gik i ledig. Så standardpauseskærmen sætter ind ved 150 sekunder, og låsen ved 300.
