# Dotfiles

Omarchy konfigureras främst via de så kallade dotfiles som ligger i `~/.config`. De räknas som dina filer för dina ändringar. Filerna som ligger i `/usr/share/omarchy` tillhör själva Omarchy, och dem ska du inte pilla på. Om du behöver ändra något i `/usr/share/omarchy` ska du i stället skriva över värdet i `~/.config`.

De viktigaste konfigurationerna kan redigeras direkt från Omarchy-menyn (`Super + Space`), som _Setup > Keybindings_, _Setup > Input_ och _Setup > Config > [file]_. När du gör det på det här sättet startas alla processer som behöver startas om efter konfigurationsändringar automatiskt om när du avslutar editorn (Neovim som standard — `:wq`, kom ihåg det! — men du kan ändra det via _Setup > Defaults > Editor_).

Här är en lista över de viktigaste filerna i `~/.config` och vad de styr:

| Fil | Syfte |
| ----------------------- | --------------------- |
| `~/.config/hypr/hyprland.lua` | Huvudkonfigurationen för Hyprland. Läser in Omarchys standardvärden plus dina åsidosättningsfiler nedan. [Läs mer om Hyprland-konfigurationer](https://wiki.hypr.land/Configuring/).  |
| `~/.config/hypr/bindings.lua` | Dina egna tangentbindningar och åsidosättningar av standardvärdena. |
| `~/.config/hypr/monitors.lua` | Bildskärmsinställningar som bildskärmspanelen inte täcker, som rotation, extra lägen eller att hålla en bildskärm avstängd. |
| `~/.config/hypr/input.lua` | Styr inställningarna för tangentbordslayout, mus och styrplatta. |
| `~/.config/hypr/looknfeel.lua` | Styr mellanrum, kanter, animationer och resten av utseendet. |
| `~/.config/hypr/autostart.lua` | Styr extra processer som startas med sessionen. |
| `~/.config/omarchy/shell.json` | Styr Omarchy-skalet: panelens position, layout och widgetar, plus tider för skärmsläckare, lås och inaktivitet. |
| `~/.config/foot/foot.ini` | Styr din terminal (foot är standard). |
| `~/.XCompose` | Definierar dina snabbåtkomst-emojier och autokomplettering för namn/e-post. Se till att köra `omarchy-restart-xcompose` efter att du har gjort ändringar. |

Om du till slut gör många ändringar för att finjustera din egen uppsättning är det en bra idé att säkerhetskopiera alla dessa dotfiles. [Stow är ett utmärkt sätt att göra det på](https://www.youtube.com/watch?v=NoFiYOqnC4o).

### Starta dina egna appar med sessionen

Om du vill att något ska köras varje gång du loggar in — en synkdaemon, en chattapp, ditt eget skript — lägger du det i `~/.config/hypr/autostart.lua`:

```lua
o.launch_on_start("my-service")
```

Det startar kommandot som en del av sessionen, så det städas upp ordentligt när du loggar ut igen.

### Köra skript vid systemhändelser

Omarchy utlöser hooks vid en handfull tillfällen, och du kan hänga på dina egna skript på dem. De ligger i `~/.config/omarchy/hooks/<event>.d/`, en katalog per händelse, och varje körbar fil där inne körs när händelsen inträffar:

| Händelse | När den körs |
| ----- | ------------ |
| `post-boot` | Direkt efter att skrivbordet har startat |
| `post-update` | Mot slutet av `omarchy update`, efter paket, migreringar och omstarter av tjänster, innan mise-verktygen uppdateras |
| `pre-refresh-pacman` | Efter att `omarchy refresh pacman` har synkat om paketkonfigurationen, innan den uppdaterar paket; ett kanalbyte kör den under samma uppdateringssteg |
| `theme-set` | Efter ett temabyte (temanamn i `$1`) |
| `font-set` | Efter ett teckensnittsbyte (teckensnittsnamn i `$1`) |
| `battery-low` | När batteriet börjar bli lågt (procent i `$1`) |

`pre-refresh-pacman`-hooken är där anpassade förråd eller `IgnorePkg`-rader hör hemma, eftersom den körs före pakettransaktionen. Båda uppdateringsrelaterade hooks körs som din användare efter att Omarchy har rensat sin cachade sudo-auktorisering, så en hook som använder `sudo` behöver sin egen auktorisering och kan be om ditt lösenord.

Var och en av de katalogerna innehåller redan en `.sample`-fil som visar hur en hook ska se ut — ta bort `.sample` från namnet för att sätta den i arbete. För att installera ett skript du har skrivit någon annanstans använder du `omarchy hook install post-boot ~/my-hook`, som kopierar in det och gör det körbart.

### Lägga till egna menyalternativ

Omarchy-menyn (`Super + Space`) kan utökas med dina egna rader genom att redigera `~/.config/omarchy/extensions/omarchy-menu.jsonc`. Posterna nycklas med ett punktavgränsat id, och det är id:t som placerar dem i trädet, så `personal` dyker upp i rotmenyn och `personal.notes` dyker upp inuti den:

```jsonc
"personal": {"icon":"","label":"Personal"},
"personal.notes": {"icon":"󰎞","label":"Notes","action":"omarchy-launch-editor ~/notes"},
```

Återanvänd ett befintligt id så åsidosätter du den raden i stället för att lägga till en ny. Filen levereras med alla tillgängliga fält dokumenterade som kommentarer.

### Lägga till egna exporterade variabler, funktioner och alias för skalet

Omarchy levereras med en massa ergonomiska alias och hjälpsamma funktioner, men det är mycket vanligt att vilja lägga till egna. Du ska lägga till alias, funktioner och exporter i `~/.bashrc`. Den filen skrivs inte över vid uppdateringar. Om du vill ändra någon av Omarchys standardinställningar kan du också tryggt lägga till dem här.

### Ställa in miljövariabler för skrivbordet

Exporter för skrivbordssessionen hör hemma i `~/.config/uwsm/env.d/`. De filerna körs innan skrivbordet startar, så ett skalfel kan skicka dig tillbaka till inloggningsskärmen. Håll en fungerande terminal öppen medan du redigerar dem. För att inaktivera en åsidosättning flyttar du ut den från `env.d`. Se [återställning av inloggning](45-troubleshooting.md#my-password-is-accepted-but-i-return-to-the-login-screen) om en ändring hindrar inloggning.

### Ändra interna Omarchy-filer

Hör här, det här är din dator. Du kan göra vad du vill med den, men jag avråder från att ändra filerna i `/usr/share/omarchy` direkt. De tillhör Omarchys pacman-paket, så dina ändringar kommer helt enkelt att skrivas över vid nästa uppdatering. Det är bättre att bara skriva över de standardvärden du inte gillar i mappen `~/.config/*` i stället.

Du kan ändra i stort sett allt på det sättet, som standardtangentbindningarna. Redigera bara `~/.config/hypr/bindings.lua` för att till exempel ersätta [Obsidian](https://obsidian.md/) med [Joplin](https://joplinapp.org/) (installera med `omarchy-pkg-add joplin-bin`):

```lua
o.rebind("SUPER + SHIFT + O", "Joplin", "joplin-desktop")
```

`o.rebind` tar bort den befintliga bindningen innan den lägger till ersättningen. Den tar samma argument som `o.bind`, inklusive starthjälpare och bindningsalternativ. Använd `o.bind` för att lägga till en bindning, eller `hl.unbind` för att ta bort en utan att ersätta den.

Om du insisterar på att hacka på de interna Omarchy-filerna byter du till dev-kanalen via _Update > Channel > Dev_. Det länkar Omarchy till en git-utcheckning av källkoden i `~/omarchy`, som du fritt kan ändra så mycket du vill. Här finns det minsann ingen som talar om för dig vad du ska göra!

### Återställa alla ändringar

Om du till slut rör till konfigurationerna kan du alltid återställa dem till standardvärdena via _Update > Config_ i Omarchy-menyn. Eller genom att köra `omarchy reinstall configs` för att återställa allt.
