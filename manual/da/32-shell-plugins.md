# Shell-plugins

Omarchy-skrivebordet kører som en enkelt langlivet Quickshell-proces ved navn `omarchy-shell`, og næsten alt, hvad du ser på skærmen, er et plugin inde i det. Linjen er et plugin. Det samme er panelerne, der falder ned fra den, fuldskærmsoverlays som emoji-vælgeren og udklipsholderhåndteringen, selve Omarchy-menuen, låseskærmen, polkit-dialogen og de hovedløse tjenester, der holder øje med dit batteri og varmer din skærm op om natten.

Det er ikke bare en implementeringsdetalje. Det betyder, at du kan slukke for dele af skrivebordet, bytte dem ud eller skrive dine egne uden at røre en linje af Omarchys kildekode.

De førsteparts-plugins leveres med Omarchy og lever i `$OMARCHY_PATH/shell/plugins/`. Alt, hvad du selv tilføjer — dine egne eksperimenter eller noget, du fandt på GitHub — lever i `~/.config/omarchy/plugins/`. Begge opdages på samme måde ved opstart, men de indbyggede modtager betroede shell-grænseflader, mens tredjeparts-plugins modtager en begrænset grænseflade afgrænset til deres egen tjeneste og livscyklus. Kloner af indbyggede beholder kun den kilde-specifikke konfiguration og de UI-kald, der er nødvendige for den oprindelige adfærd.

## Se, hvad du har

```
omarchy plugin list
```

Det udskriver hvert opdaget plugin med dets id, om det er aktiveret, om det er førsteparts eller tredjeparts, dets typer og dets visningsnavn. Tilføj `--json`, hvis du fodrer det til noget andet.

Plugin-id'er er navngivet med namespace. De indbyggede starter alle med `omarchy.` — `omarchy.clock`, `omarchy.network`, `omarchy.notifications` — og det namespace er reserveret, så et tredjeparts-plugin aldrig kan gøre krav på det.

## Tænde og slukke for dem

```
omarchy plugin enable omarchy.tailscale
omarchy plugin disable omarchy.weather
```

Eller brug menuen: _Opsætning > Plugins_ har Enable, Disable, Add, Clone og Remove, hver med en vælger, der kun tilbyder de plugins, der giver mening for den handling.

Aktiveret tilstand gemmes i `~/.config/omarchy/shell.json`, og reglen adskiller sig lidt for de to slags plugins. Et tredjeparts-plugin er aktiveret præcis, når dets id vises et eller andet sted i den fil — som en linjelayoutpost, som en post i `plugins[]` eller som `bar.id`. Førsteparts-plugins, der ikke er linje-widgets, er omvendt: de er tændt som standard og slukkes kun ved at blive listet i `disabledPlugins[]`.

Et fuldt linje-plugin har slet ingen slukket tilstand. Der er altid præcis én linje, så du erstatter den ved at aktivere en anden. Placering af linje-widgets er dækket i [menulinjen](05-the-top-bar.md).

## Tilføje et plugin fra git

Et tredjeparts-plugin er bare et git-repo med en `manifest.json` i roden.

```
omarchy plugin add https://github.com/acme/omarchy-weather.git --enable
```

Før den gør noget, fortæller den dig direkte, at plugins kører som vilkårlig, ikke-sandkasset kode inde i din langlivede shell-proces, viser dig URL'en og beder dig bekræfte. Tag det alvorligt. Tredjeparts-plugin-grænsefladen eksponerer ikke direkte autentificeringstjenester, og en erstatningslinje modtager kun begrænsede kapaciteter til konfigureret ikke-autentificerings-UI. Visuelle plugins deler stadig skallens QML-scene og kan gå på almindelige forældreobjekter, mens al plugin-kode kører med alt, hvad din brugerkonto kan nå. Autentificeringstilstand beskyttes separat ved at holde de tjenester uden for den tilgængelige værtsobjektgraf. Tilføj kun repos, du er villig til at køre, og læs dem, før du aktiverer dem.

En erstatningslinje kan gengive installerede widgets, men tjenesteunderstøttede tredjeparts-widgets kan have reduceret funktionalitet der, fordi linjen ikke har lov til at anmode om et andet plugins live tjenesteobjekt. Skift tilbage til den indbyggede `omarchy.bar`, hvis sådan en widget har brug for sin følgetjeneste.

Derefter kloner den repoet til en staging-mappe, validerer manifestet, nægter installationen, hvis et andet plugin allerede gør krav på det id, og flytter det ind i `~/.config/omarchy/plugins/<id>/`. Uden `--enable` spørger den, om du vil have den tændt nu, og du kan sige nej og gå og læse koden først. Den kører aldrig noget fra pluginet, udfører aldrig en installations-hook og beder aldrig om sudo — den kloner filer, tjekker manifestet og flipper en bit over IPC.

Opdatering er en fast-forward pull af det samme checkout:

```
omarchy plugin update acme.weather
omarchy plugin update
```

Uden id opdaterer den hvert git-administreret plugin, du har. Den viser dig diff'en, før den anvender den, nægter at opdatere, hvis du har lokale ændringer, den ikke kan fast-forwarde forbi, og ruller tilbage, hvis den nye revision fejler validering.

```
omarchy plugin remove acme.weather
```

Fjernelse deaktiverer først pluginet og sletter det derefter, hvis det er et git-checkout (repoet er stadig upstream), eller afkobler det, hvis det er et symlink. En håndlavet plugin-mappe uden git-repo flyttes til en tidsstemplet backup inde i plugins-mappen i stedet for at blive slettet direkte.

## Klone et indbygget plugin for at ændre det

Dette er min yndlingsdel. Hvis du vil ændre, hvordan en indbygget widget opfører sig, skal du ikke redigere filerne under `$OMARCHY_PATH` — de tilhører pakken, og den næste opdatering vil overskrive dem. Klon den i stedet:

```
omarchy plugin clone omarchy.clock
```

Det kopierer hele pluginet ind i `~/.config/omarchy/plugins/dhh.clock` (dit brugernavn, ikke mit), omdøber det til "My Clock", aktiverer det og skifter skallen over fra det indbyggede til din kopi — og bevarer en eksisterende linje-widgets position og indstillinger. Tilføj `--edit` for at åbne den nye mappe i din `$EDITOR` med det samme, hvilket er, hvad menuens _Opsætning > Plugins > Clone Plugin_ gør for dig.

Brugernavnspræfikset holder din klons id dit eget, så deling af det ikke kolliderer med nogen andens. Kald til det oprindelige indbyggede id dirigeres til din klon, så intet, der henviste til `omarchy.clock`, skal opdateres. Og hvis du laver rod i det, sætter `omarchy plugin remove dhh.clock` det indbyggede tilbage.

At gemme en fil hvor som helst under `~/.config/omarchy/plugins/` genindlæser automatisk plugin-koden, så du kan lade editoren stå åben og se dine ændringer lande.

## Skrive dine egne

Et plugin er en mappe med en `manifest.json` og noget QML. Manifestet erklærer `schemaVersion: 1`, et `id`, `name`, `version`, en eller flere `kinds` og et `entryPoints`-objekt, der peger på QML-filen for hver type:

| Kind | What it is |
|------|------------|
| `bar-widget` | En komponent, den aktive linje kan smide ind i en sektion |
| `panel` | Et vedvarende eller tilkaldt flydende vindue |
| `overlay` | Et fuldskærmsoverlay |
| `menu` | En tilkaldt menuoverflade |
| `service` | En hovedløs singleton uden UI |
| `bar` | En fuld linje, der erstatter den indbyggede |

Et plugin kan erklære flere typer på én gang — medie-pluginet er både en `service` og en `bar-widget`. Linje-widgets får en ekstra `barWidget`-blok med et visningsnavn, en kategori, en valgfri `defaultSection` og `allowMultiple`, som siger, om det giver mening at have mere end én på linjen. De fleste widgets sætter den til `false`; afstandsstykker og indikatorer sætter den til `true`.

Før du udgiver noget, skal du tjekke det:

```
omarchy plugin validate ./my-plugin
```

Det kører de samme tjek, som skallen gør ved indlæsningstid: skemaversionen, de påkrævede felter, et id, der ikke er reserveret, indgangspunkter, der er sikre relative stier og faktisk eksisterer, et indgangspunkt for hver type, du gjorde krav på, og ingen symlinks nogen steder inde i mappen.

Til plugin-udvikling, se [shell-referencen](https://github.com/omacom/omarchy/blob/quattro/docs/omarchy-shell.md) og [katalog over førsteparts-plugins](https://github.com/omacom/omarchy/blob/quattro/shell/plugins/README.md).

## Dele dine med verden

Når du har lavet noget, du kan lide, så læg det i et offentligt git-repo. Det er hele distributionsmekanismen — enhver kan derefter køre `omarchy plugin add` mod din URL og have det kørende på sekunder.

For at hjælpe folk med faktisk at finde det, så list det på [plugins.omarchy.org](https://plugins.omarchy.org). Det er markedspladsen for Omarchy shell-plugins, og det er det første sted at kigge, når du spekulerer på, om nogen allerede har bygget den widget, du er ved at skrive. Gennemse den, før du starter!
