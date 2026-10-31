# Skallutvidelser

Omarchy-skrivebordet kjører som én enkelt langvarig Quickshell-prosess kalt `omarchy-shell`, og nesten alt du ser på skjermen er en utvidelse inni den. Linjen er en utvidelse. Det er også panelene som faller ned fra den, fullskjermoverleggene som emoji-velgeren og utklippstavlebehandleren, selve Omarchy-menyen, låseskjermen, polkit-dialogen og de hodeløse tjenestene som overvåker batteriet ditt og varmer opp skjermen om natten.

Det er ikke bare en implementasjonsdetalj. Det betyr at du kan slå av deler av skrivebordet, bytte dem ut eller skrive dine egne uten å røre én linje med Omarchys kildekode.

Førstepartsutvidelsene leveres med Omarchy og bor i `$OMARCHY_PATH/shell/plugins/`. Alt du legger til selv — dine egne eksperimenter eller noe du fant på GitHub — bor i `~/.config/omarchy/plugins/`. Begge oppdages på samme måte ved oppstart, men innebygde mottar betredde skallgrensesnitt, mens tredjepartsutvidelser mottar et begrenset grensesnitt avgrenset til deres egen tjeneste og livssyklus. Kloner av innebygde beholder bare den kildespesifikke konfigurasjonen og UI-kallene som trengs for den opprinnelige oppførselen.

## Se hva du har

```
omarchy plugin list
```

Det skriver ut hver oppdagede utvidelse med ID, om den er aktivert, om den er førsteparts eller tredjeparts, typene dens og visningsnavnet. Legg til `--json` hvis du mater den til noe annet.

Utvidelses-ID-er er navngitt med navnerom. De innebygde starter alle med `omarchy.` — `omarchy.clock`, `omarchy.network`, `omarchy.notifications` — og det navnerommet er reservert, så en tredjepartsutvidelse kan aldri hevde det.

## Slå dem på og av

```
omarchy plugin enable omarchy.tailscale
omarchy plugin disable omarchy.weather
```

Eller bruk menyen: _Oppsett > Utvidelser_ har Aktiver, Deaktiver, Legg til, Klon og Fjern, hver med en velger som bare tilbyr utvidelsene som gir mening for den handlingen.

Aktivert tilstand lagres i `~/.config/omarchy/shell.json`, og regelen skiller seg litt for de to typene utvidelser. En tredjepartsutvidelse er aktivert nøyaktig når ID-en vises et sted i filen — som en linjeoppsettoppføring, som en oppføring i `plugins[]`, eller som `bar.id`. Førstepartsutvidelser som ikke er linje-widgeter er motsatt: de er på som standard og slås bare av ved å stå i `disabledPlugins[]`.

En full linjeutvidelse har ingen av-tilstand i det hele tatt. Det finnes alltid nøyaktig én linje, så du erstatter den ved å aktivere en annen. Plassering av linje-widgeter dekkes i [menylinjen](05-the-top-bar.md).

## Legge til en utvidelse fra git

En tredjepartsutvidelse er bare et git-repo med en `manifest.json` i roten.

```
omarchy plugin add https://github.com/acme/omarchy-weather.git --enable
```

Før den gjør noe, forteller den deg rett ut at utvidelser kjører som vilkårlig, ikke-sandkasset kode inni den langvarige skallprosessen din, viser deg URL-en og ber deg bekrefte. Ta det alvorlig. Tredjeparts grensesnitt for utvidelser eksponerer ikke autentiseringstjenester direkte, og en erstatningslinje mottar bare begrensede muligheter for konfigurert ikke-autentiserings-UI. Visuelle utvidelser deler fortsatt skallets QML-scene og kan gå opp ordinære overordnede objekter, mens all utvidelseskode kjører med alt brukerkontoen din kan nå. Autentiseringstilstanden beskyttes separat ved å holde de tjenestene utenfor den nåbare vertsgrafen over objekter. Legg bare til repoer du er villig til å kjøre, og les dem før du aktiverer dem.

En erstatningslinje kan gjengi installerte widgets, men tjenestestøttede tredjeparts-widgeter kan ha redusert funksjonalitet der, fordi linjen ikke får lov til å be om en annen utvidelses direkte tjenesteobjekt. Bytt tilbake til den innebygde `omarchy.bar` hvis en slik widget trenger følge-tjenesten sin.

Deretter kloner den repoet til en staging-mappe, validerer manifestet, nekter installasjonen hvis en annen utvidelse allerede hevder ID-en, og flytter det til `~/.config/omarchy/plugins/<id>/`. Uten `--enable` spør den om du vil ha den på nå, og du kan si nei og gå og lese koden først. Den kjører aldri noe fra utvidelsen, kjører aldri en installasjonskrok og ber aldri om sudo — den kloner filer, sjekker manifestet og vipper en bit over IPC.

Oppdatering er en fast-forward-henting av den samme utsjekkingen:

```
omarchy plugin update acme.weather
omarchy plugin update
```

Uten ID oppdaterer den hver git-administrerte utvidelse du har. Den viser deg diffen før den bruker den, nekter å oppdatere hvis du har lokale endringer den ikke kan fast-forward forbi, og ruller tilbake hvis den nye revisjonen feiler validering.

```
omarchy plugin remove acme.weather
```

Fjerning deaktiverer utvidelsen først, deretter sletter den den hvis den er en git-utsjekking (repoet er fortsatt oppstrøms) eller ulenker den hvis den er en symlenke. En håndlaget utvidelsesmappe uten git-repo flyttes til en tidsstemplet sikkerhetskopi inne i utvidelsesmappen i stedet for å bli slettet fullstendig.

## Klone en innebygd for å endre den

Dette er favorittdelen min. Hvis du vil endre hvordan en innebygd widget oppfører seg, ikke rediger filene under `$OMARCHY_PATH` — de tilhører pakken, og neste oppdatering overskriver dem. Klon den i stedet:

```
omarchy plugin clone omarchy.clock
```

Det kopierer hele utvidelsen til `~/.config/omarchy/plugins/dhh.clock` (ditt brukernavn, ikke mitt), gir den nytt navn til "My Clock", aktiverer den og bytter skallet over fra den innebygde til kopiene din — og beholder en eksisterende linje-widgets posisjon og innstillinger. Legg til `--edit` for å åpne den nye mappen i `$EDITOR` umiddelbart, noe menyens _Oppsett > Utvidelser > Klon utvidelse_ gjør for deg.

Brukernavnprefikset holder klonens ID din, så deling av den kolliderer ikke med noen annes. Kall gjort til den opprinnelige innebygde ID-en rutes til klonen din, så ingenting som refererte til `omarchy.clock` trenger oppdatering. Og hvis du roter det til, setter `omarchy plugin remove dhh.clock` den innebygde tilbake.

Å lagre en fil hvor som helst under `~/.config/omarchy/plugins/` laster utvidelseskoden på nytt automatisk, så du kan la editoren stå åpen og se endringene dine lande.

## Skrive din egen

En utvidelse er en mappe med en `manifest.json` og litt QML. Manifestet erklærer `schemaVersion: 1`, en `id`, `name`, `version`, én eller flere `kinds` og et `entryPoints`-objekt som peker på QML-filen for hver type:

| Type | Hva det er |
|------|------------|
| `bar-widget` | En komponent den aktive linjen kan slippe inn i en seksjon |
| `panel` | Et vedvarende eller påkalt flytende vindu |
| `overlay` | Et fullskjermoverlegg |
| `menu` | En påkalt menyflate |
| `service` | En hodeløs singleton uten UI |
| `bar` | En full linje som erstatter den innebygde |

En utvidelse kan erklære flere typer på en gang — medieutvidelsen er både en `service` og en `bar-widget`. Linje-widgeter får en ekstra `barWidget`-blokk med et visningsnavn, en kategori, en valgfri `defaultSection` og `allowMultiple`, som sier om det gir mening å ha mer enn én på linjen. De fleste widgets setter den til `false`; avstandsstykker og indikatorer setter den til `true`.

Før du publiserer noe, sjekk det:

```
omarchy plugin validate ./my-plugin
```

Det kjører de samme sjekkene som skallet gjør ved lasting: skjemaversjonen, påkrevde felter, en ID som ikke er reservert, inngangspunkter som er trygge relative stier og faktisk eksisterer, et inngangspunkt for hver type du hevdet, og ingen symlenker noe sted inni mappen.

For utvidelsesutvikling, se [skallreferansen](https://github.com/omacom/omarchy/blob/quattro/docs/omarchy-shell.md) og [katalogen over førstepartsutvidelser](https://github.com/omacom/omarchy/blob/quattro/shell/plugins/README.md).

## Dele din med verden

Når du har laget noe du liker, legg det i et offentlig git-repo. Det er hele distribusjonsmekanismen — hvem som helst kan deretter kjøre `omarchy plugin add` mot URL-en din og ha det i gang på sekunder.

For å hjelpe folk faktisk å finne den, list den på [plugins.omarchy.org](https://plugins.omarchy.org). Det er markedsplassen for Omarchy-skallutvidelser, og det er det første stedet å se når du lurer på om noen allerede har bygd widgeten du er i ferd med å skrive. Bla i den før du starter!
