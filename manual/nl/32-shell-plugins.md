# Shell-plugins

Het Omarchy-bureaublad draait als één langlevend Quickshell-proces genaamd `omarchy-shell`, en bijna alles wat je op het scherm ziet is een plugin erin. De balk is een plugin. Dat geldt ook voor de panelen die eruit naar beneden vallen, de fullscreen-overlays zoals de emoji-picker en de klembordbeheerder, het Omarchy-menu zelf, het vergrendelscherm, de polkit-dialoog, en de headless diensten die je batterij in de gaten houden en je scherm 's nachts opwarmen.

Dat is niet alleen een implementatiedetail. Het betekent dat je delen van het bureaublad kunt uitschakelen, ze kunt vervangen, of je eigen kunt schrijven zonder een regel van Omarchy's broncode aan te raken.

De first-party plugins worden met Omarchy geleverd en leven in `$OMARCHY_PATH/shell/plugins/`. Alles wat je zelf toevoegt — je eigen experimenten, of iets dat je op GitHub hebt gevonden — leeft in `~/.config/omarchy/plugins/`. Beide worden op dezelfde manier ontdekt bij het opstarten, maar built-ins ontvangen vertrouwde shell-interfaces, terwijl third-party plugins een beperkte interface ontvangen die is beperkt tot hun eigen dienst en levenscyclus. Kloons van built-ins behouden alleen de bronspecifieke configuratie- en UI-aanroepen die nodig zijn voor het originele gedrag.

## Zien wat je hebt

```
omarchy plugin list
```

Dat print elke ontdekte plugin met zijn id, of deze is ingeschakeld, of het first-party of third-party is, zijn soorten, en zijn weergavenaam. Voeg `--json` toe als je het aan iets anders voedt.

Plugin-id's zijn genamespaced. De built-ins beginnen allemaal met `omarchy.` — `omarchy.clock`, `omarchy.network`, `omarchy.notifications` — en die namespace is gereserveerd, dus een third-party plugin kan deze nooit claimen.

## Ze in- en uitschakelen

```
omarchy plugin enable omarchy.tailscale
omarchy plugin disable omarchy.weather
```

Of gebruik het menu: _Instellen > Plugins_ heeft Inschakelen, Uitschakelen, Toevoegen, Klonen en Verwijderen, elk met een picker die alleen de plugins aanbiedt die zinvol zijn voor die actie.

De ingeschakelde staat wordt opgeslagen in `~/.config/omarchy/shell.json`, en de regel verschilt enigszins voor de twee soorten plugins. Een third-party plugin is precies ingeschakeld wanneer zijn id ergens in dat bestand verschijnt — als een balkindeling-item, als item in `plugins[]`, of als `bar.id`. First-party plugins die geen balkwidgets zijn, werken andersom: ze zijn standaard aan en gaan alleen uit door te worden vermeld in `disabledPlugins[]`.

Een volledige balkplugin heeft helemaal geen uit-status. Er is altijd precies één balk, dus je vervangt hem door een andere in te schakelen. De plaatsing van balkwidgets wordt behandeld in [de menubalk](05-the-top-bar.md).

## Een plugin toevoegen vanuit git

Een third-party plugin is gewoon een git-repo met een `manifest.json` in zijn root.

```
omarchy plugin add https://github.com/acme/omarchy-weather.git --enable
```

Voordat het iets doet, vertelt het je duidelijk dat plugins draaien als arbitraire, niet-gesandboxte code in je langlevende shell-proces, toont het je de URL, en vraagt het je om te bevestigen. Neem dat serieus. De third-party plugin-interface stelt authenticatiediensten niet direct bloot, en een vervangende balk ontvangt alleen beperkte mogelijkheden voor geconfigureerde niet-authenticatie-UI. Visuele plugins delen nog steeds de QML-scène van de shell en kunnen gewone bovenliggende objecten doorlopen, terwijl alle plugincode draait met alles wat je gebruikersaccount kan bereiken. Authenticatiestatus wordt afzonderlijk beschermd door die diensten buiten de bereikbare host-objectgrafiek te houden. Voeg alleen repo's toe die je bereid bent uit te voeren, en lees ze voordat je ze inschakelt.

Een vervangende balk kan geïnstalleerde widgets renderen, maar service-backed third-party widgets kunnen daar verminderde functionaliteit hebben omdat de balk geen live service-object van een andere plugin mag aanvragen. Schakel terug naar de ingebouwde `omarchy.bar` als zo'n widget zijn bijbehorende dienst nodig heeft.

Daarna kloont het de repo in een staging-map, valideert het het manifest, weigert het de installatie als een andere plugin die id al claimt, en verplaatst het naar `~/.config/omarchy/plugins/<id>/`. Zonder `--enable` vraagt het of je het nu aan wilt hebben, en je kunt nee zeggen en eerst de code gaan lezen. Het voert nooit iets uit van de plugin, voert nooit een install-hook uit, en vraagt nooit om sudo — het kloont bestanden, controleert het manifest, en flipt een bit via IPC.

Bijwerken is een fast-forward pull van diezelfde checkout:

```
omarchy plugin update acme.weather
omarchy plugin update
```

Zonder id werkt het elke git-beheerde plugin bij die je hebt. Het toont je de diff voordat deze wordt toegepast, weigert bij te werken als je lokale wijzigingen hebt waar het niet voorbij kan fast-forwarden, en draait terug als de nieuwe revisie de validatie faalt.

```
omarchy plugin remove acme.weather
```

Verwijdering schakelt de plugin eerst uit, en verwijdert hem daarna als het een git-checkout is (de repo is nog steeds upstream) of ontkoppelt hem als het een symlink is. Een met de hand gemaakte pluginmap zonder git-repo wordt verplaatst naar een back-up met tijdstempel in de pluginsmap in plaats van helemaal te worden verwijderd.

## Een built-in klonen om hem te wijzigen

Dit is mijn favoriete deel. Als je wilt wijzigen hoe een built-in widget zich gedraagt, bewerk dan niet de bestanden onder `$OMARCHY_PATH` — die behoren tot het pakket en de volgende update overschrijft ze. Kloon hem in plaats daarvan:

```
omarchy plugin clone omarchy.clock
```

Dat kopieert de hele plugin naar `~/.config/omarchy/plugins/dhh.clock` (jouw gebruikersnaam, niet de mijne), hernoemt hem naar "My Clock", schakelt hem in, en schakelt de shell over van de built-in naar je kopie — terwijl de positie en instellingen van een bestaande balkwidget behouden blijven. Voeg `--edit` toe om de nieuwe map direct in je `$EDITOR` te openen, wat het menu _Instellen > Plugins > Plugin klonen_ voor je doet.

Het voorvoegsel van de gebruikersnaam houdt de id van je kloon van jou, zodat het delen ervan niet botst met die van iemand anders. Aanroepen naar de originele built-in id worden doorgestuurd naar je kloon, zodat niets dat naar `omarchy.clock` verwees bijgewerkt hoeft te worden. En als je er een puinhoop van maakt, zet `omarchy plugin remove dhh.clock` de built-in terug.

Een bestand opslaan ergens onder `~/.config/omarchy/plugins/` herlaadt de plugincode automatisch, zodat je de editor open kunt laten staan en je wijzigingen kunt zien landen.

## Je eigen schrijven

Een plugin is een map met een `manifest.json` en wat QML. Het manifest declareert `schemaVersion: 1`, een `id`, `name`, `version`, een of meer `kinds`, en een `entryPoints`-object dat wijst naar het QML-bestand voor elke soort:

| Kind | What it is |
|------|------------|
| `bar-widget` | Een component dat de actieve balk in een sectie kan plaatsen |
| `panel` | Een persistent of opgeroepen zwevend venster |
| `overlay` | Een fullscreen-overlay |
| `menu` | Een opgeroepen menu-oppervlak |
| `service` | Een headless singleton zonder UI |
| `bar` | Een volledige balk die de ingebouwde vervangt |

Een plugin kan meerdere soorten tegelijk declareren — de mediaplugin is zowel een `service` als een `bar-widget`. Balkwidgets krijgen een extra `barWidget`-blok met een weergavenaam, een categorie, een optionele `defaultSection`, en `allowMultiple`, wat zegt of het zinvol is om er meer dan één op de balk te hebben. De meeste widgets stellen het in op `false`; spacers en indicatoren stellen het in op `true`.

Voordat je iets publiceert, controleer je het:

```
omarchy plugin validate ./my-plugin
```

Dat voert dezelfde controles uit die de shell doet bij het laden: de schemaversie, de vereiste velden, een id die niet gereserveerd is, entry points die veilige relatieve paden zijn en daadwerkelijk bestaan, een entry point voor elke soort die je hebt geclaimd, en geen symlinks ergens in de map.

Voor pluginontwikkeling, zie de [shell-referentie](https://github.com/omacom/omarchy/blob/quattro/docs/omarchy-shell.md) en [first-party plugincatalogus](https://github.com/omacom/omarchy/blob/quattro/shell/plugins/README.md).

## De jouwe delen met de wereld

Zodra je iets hebt gemaakt dat je bevalt, zet je het in een publieke git-repo. Dat is het hele distributiemechanisme — iedereen kan dan `omarchy plugin add` uitvoeren tegen je URL en het binnen enkele seconden draaien.

Om mensen te helpen het daadwerkelijk te vinden, vermeld je het op [plugins.omarchy.org](https://plugins.omarchy.org). Dat is de marktplaats voor Omarchy-shell-plugins, en het is de eerste plek om te kijken wanneer je je afvraagt of iemand de widget die je gaat schrijven al heeft gebouwd. Blader erdoor voordat je begint!
