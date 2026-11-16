# Shell-plugins

Omarchy-skrivbordet körs som en enda långlivad Quickshell-process kallad `omarchy-shell`, och nästan allt du ser på skärmen är en plugin i den. Fältet är en plugin. Det är också panelerna som faller ner från det, helskärmsöverläggen som emoji-väljaren och urklippshanteraren, själva Omarchy-menyn, låsskärmen, polkit-dialogen och de huvudlösa tjänsterna som bevakar ditt batteri och värmer din skärm på natten.

Det är inte bara en implementationsdetalj. Det betyder att du kan stänga av delar av skrivbordet, byta ut dem, eller skriva dina egna utan att röra en enda rad av Omarchys källkod.

Förstaparts-pluginsen levereras med Omarchy och bor i `$OMARCHY_PATH/shell/plugins/`. Allt du lägger till själv — dina egna experiment, eller något du hittade på GitHub — bor i `~/.config/omarchy/plugins/`. Båda upptäcks på samma sätt vid uppstart, men inbyggda får betrodda shell-gränssnitt medan tredjeparts-plugins får ett begränsat gränssnitt avgränsat till sin egen tjänst och livscykel. Kloner av inbyggda behåller endast den källspecifika konfiguration och de UI-anrop som behövs för det ursprungliga beteendet.

## Se vad du har

```
omarchy plugin list
```

Det skriver ut varje upptäckt plugin med dess id, om den är aktiverad, om den är förstaparts eller tredjeparts, dess typer och dess visningsnamn. Lägg till `--json` om du matar den till något annat.

Plugin-id:n är namngivna med namespace. De inbyggda börjar alla med `omarchy.` — `omarchy.clock`, `omarchy.network`, `omarchy.notifications` — och det namespacet är reserverat, så en tredjeparts-plugin kan aldrig göra anspråk på det.

## Slå på och stänga av dem

```
omarchy plugin enable omarchy.tailscale
omarchy plugin disable omarchy.weather
```

Eller använd menyn: _Installation > Plugins_ har Aktivera, Inaktivera, Lägg till, Klona och Ta bort, var och en med en väljare som bara erbjuder de plugins som är meningsfulla för den åtgärden.

Aktiverat läge lagras i `~/.config/omarchy/shell.json`, och regeln skiljer sig något åt för de två typerna av plugins. En tredjeparts-plugin är aktiverad precis när dess id dyker upp någonstans i den filen — som en post i fältlayouten, som en post i `plugins[]`, eller som `bar.id`. Förstaparts-plugins som inte är fältwidgetar fungerar tvärtom: de är på som standard och stängs bara av genom att listas i `disabledPlugins[]`.

En full fält-plugin har inget avstängt läge alls. Det finns alltid exakt en fält, så du ersätter den genom att aktivera en annan. Placering av fältwidgetar behandlas i [det övre fältet](05-the-top-bar.md).

## Lägga till en plugin från git

En tredjeparts-plugin är bara ett git-repo med en `manifest.json` i dess rot.

```
omarchy plugin add https://github.com/acme/omarchy-weather.git --enable
```

Innan den gör något talar den rakt på sak om att plugins körs som godtycklig, icke-sandboxad kod inuti din långlivade shell-process, visar dig URL:en och ber dig bekräfta. Ta det på allvar. Tredjeparts-plugin-gränssnittet exponerar inte direkt autentiseringstjänster, och en ersättningsfält får bara begränsade förmågor för konfigurerat icke-autentiserande UI. Visuella plugins delar fortfarande skalets QML-scen och kan vandra vanliga föräldraobjekt, medan all plugin-kod körs med allt ditt användarkonto kan nå. Autentiseringstillstånd skyddas separat genom att hålla de tjänsterna utanför den nåbara värdobjektgrafen. Lägg bara till repos du är villig att köra, och läs dem innan du aktiverar dem.

En ersättningsfält kan rendera installerade widgetar, men tjänstebackade tredjepartswidgetar kan ha reducerad funktionalitet där eftersom fältet inte får begära en annan plugins live-tjänstobjekt. Växla tillbaka till den inbyggda `omarchy.bar` om en sådan widget behöver sin följetjänst.

Sedan klonar den repot till en staging-katalog, validerar manifestet, vägrar installationen om en annan plugin redan gör anspråk på det id:t, och flyttar den till `~/.config/omarchy/plugins/<id>/`. Utan `--enable` frågar den om du vill ha den på nu, och du kan säga nej och läsa koden först. Den kör aldrig något från pluginen, kör aldrig någon install-hook, och ber aldrig om sudo — den klonar filer, kontrollerar manifestet och slår om en bit via IPC.

Uppdatering är en fast-forward pull av samma checkout:

```
omarchy plugin update acme.weather
omarchy plugin update
```

Utan id uppdaterar den varje git-hanterad plugin du har. Den visar dig diffen innan den tillämpar den, vägrar att uppdatera om du har lokala ändringar den inte kan fast-forward förbi, och rullar tillbaka om den nya revisionen misslyckas med valideringen.

```
omarchy plugin remove acme.weather
```

Borttagning inaktiverar pluginen först, sedan raderar den den om det är en git-checkout (repot finns fortfarande uppströms) eller avlänkar den om det är en symlink. En handgjord plugin-mapp utan git-repo flyttas till en tidsstämplad backup i plugin-katalogen istället för att raderas rakt av.

## Klona en inbyggd för att modifiera den

Det här är min favoritdel. Om du vill ändra hur en inbyggd widget beter sig ska du inte redigera filerna under `$OMARCHY_PATH` — de tillhör paketet och nästa uppdatering kommer att skriva över dem. Klona den istället:

```
omarchy plugin clone omarchy.clock
```

Det kopierar hela pluginen till `~/.config/omarchy/plugins/dhh.clock` (ditt användarnamn, inte mitt), döper om den till "My Clock", aktiverar den och växlar skalet från den inbyggda till din kopia — och behåller en befintlig fältwidgets position och inställningar. Lägg till `--edit` för att öppna den nya katalogen i ditt `$EDITOR` direkt, vilket är vad menyns _Installation > Plugins > Clone Plugin_ gör åt dig.

Användarnamnsprefixet håller din klons id ditt, så att dela den inte kolliderar med någon annans. Anrop till det ursprungliga inbyggda id:t styrs till din klon, så ingenting som refererade till `omarchy.clock` behöver uppdateras. Och om du rör till det lägger `omarchy plugin remove dhh.clock` tillbaka den inbyggda.

Att spara en fil någonstans under `~/.config/omarchy/plugins/` laddar om plugin-koden automatiskt, så du kan lämna editorn öppen och se dina ändringar landa.

## Skriva din egen

En plugin är en katalog med en `manifest.json` och lite QML. Manifestet deklarerar `schemaVersion: 1`, ett `id`, `name`, `version`, en eller flera `kinds`, och ett `entryPoints`-objekt som pekar på QML-filen för varje kind:

| Kind | What it is |
|------|------------|
| `bar-widget` | En komponent som det aktiva fältet kan sätta in i en sektion |
| `panel` | Ett bestående eller framkallat flytande fönster |
| `overlay` | Ett helskärmsöverlägg |
| `menu` | En framkallad meny-yta |
| `service` | En huvudlös singleton utan UI |
| `bar` | En hel fält som ersätter den inbyggda |

En plugin kan deklarera flera typer samtidigt — media-pluginen är både en `service` och en `bar-widget`. Fältwidgetar får ett extra `barWidget`-block med ett visningsnamn, en kategori, en valfri `defaultSection`, och `allowMultiple`, vilket anger om det är meningsfullt att ha mer än en på fältet. De flesta widgetar sätter det till `false`; spacers och indikatorer sätter det till `true`.

Innan du publicerar något, kontrollera det:

```
omarchy plugin validate ./my-plugin
```

Det kör samma kontroller som skalet gör vid inläsning: schemaversionen, de obligatoriska fälten, ett id som inte är reserverat, entry points som är säkra relativa sökvägar och faktiskt existerar, en entry point för varje kind du gjort anspråk på, och inga symlinkar någonstans inne i mappen.

För plugin-utveckling, se [shell-referensen](https://github.com/omacom/omarchy/blob/quattro/docs/omarchy-shell.md) och [förstaparts-plugin-katalogen](https://github.com/omacom/omarchy/blob/quattro/shell/plugins/README.md).

## Dela din med världen

När du har gjort något du gillar, lägg det i ett offentligt git-repo. Det är hela distributionsmekanismen — vem som helst kan sedan köra `omarchy plugin add` mot din URL och ha den igång på sekunder.

För att hjälpa folk att faktiskt hitta den, lista den på [plugins.omarchy.org](https://plugins.omarchy.org). Det är marknadsplatsen för Omarchy shell-plugins, och det är första stället att titta på när du undrar om någon redan har byggt widgeten du håller på att skriva. Bläddra där innan du sätter igång!
