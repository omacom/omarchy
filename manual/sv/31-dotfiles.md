# Dotfiles

Omarchy konfigureras i första hand via de så kallade dotfilerna som finns i `~/.config`. De betraktas som dina filer för dina ändringar. Filerna som finns i `/usr/share/omarchy` tillhör själva Omarchy, och dem ska du inte hålla på och ändra i. Om du behöver ändra något i `/usr/share/omarchy` ska du i stället skriva över värdet i `~/.config`.

De viktigaste konfigurationerna kan redigeras direkt från Omarchy-menyn (`Super + Space`), som _Setup > Keybindings_, _Setup > Input_ och _Setup > Config > [file]_. När du gör det på det här sättet startas alla processer som behöver startas om efter konfigurationsändringar automatiskt om när du stänger redigeraren (Neovim som standard — `:wq`, kom ihåg! — men du kan ändra det via _Setup > Defaults > Editor_).

Här är en lista över de viktigaste filerna i `~/.config` och vad de styr:

| File                  | Purpose              |
| ----------------------- | --------------------- |
| `~/.config/hypr/hyprland.lua` | Den huvudsakliga Hyprland-konfigurationen. Läser in Omarchys standardvärden plus dina åsidosättande filer nedan. [Läs mer om Hyprland-konfigurationer](https://wiki.hypr.land/Configuring/).  |
| `~/.config/hypr/bindings.lua` | Dina egna tangentbindningar och åsidosättningar av standardvärdena. |
| `~/.config/hypr/monitors.lua` | Bildskärmsinställningar som bildskärmspanelen inte täcker, som rotation, extra lägen eller att hålla en bildskärm avstängd. |
| `~/.config/hypr/input.lua` | Styr din tangentbordslayout, mus och styrplatta. |
| `~/.config/hypr/looknfeel.lua` | Styr mellanrum, kanter, animationer och resten av utseendet. |
| `~/.config/hypr/autostart.lua` | Styr extra processer som startas med sessionen. |
| `~/.config/omarchy/shell.json` | Styr Omarchy-skalet: panelposition, layout och widgetar, plus skärmsläckare, lås och inaktivitetstider. |
| `~/.config/foot/foot.ini` | Styr din terminal (foot är standard). |
| `~/.XCompose` | Definierar dina snabbåtkomst-emojier och automatisk komplettering för namn/e-post. Se till att köra `omarchy-restart-xcompose` efter att du har gjort ändringar. |

Om du till slut gör många ändringar för att anpassa din egen installation är det en bra idé att säkerhetskopiera alla dessa dotfiler. [Stow är ett utmärkt sätt att göra det på](https://www.youtube.com/watch?v=NoFiYOqnC4o).

### Starta dina egna appar med sessionen

Om du vill att något ska köras varje gång du loggar in — en synkroniseringsdemon, en chattapp, ditt eget skript — lägger du det i `~/.config/hypr/autostart.lua`:

```lua
o.launch_on_start("my-service")
```

Det startar kommandot som en del av sessionen, så att det städas upp ordentligt när du loggar ut igen.

### Köra skript vid systemhändelser

Omarchy utlöser hookar vid ett handfull tillfällen, och du kan hänga på dina egna skript på dem. De finns i `~/.config/omarchy/hooks/<event>.d/`, en katalog per händelse, och varje körbar fil där körs när händelsen inträffar:

| Event | When it runs |
| ----- | ------------ |
| `post-boot` | Direkt efter att skrivbordet har startat |
| `post-update` | Nära slutet av `omarchy update`, efter paket, migreringar och omstarter av tjänster, innan mise-verktyg uppdateras |
| `pre-refresh-pacman` | Efter att `omarchy refresh pacman` har synkroniserat om paketkonfigurationen, innan den uppdaterar paket; ett kanalbyte kör den under samma uppdateringssteg |
| `theme-set` | Efter ett temabyte (temanamn i `$1`) |
| `font-set` | Efter ett teckensnittsbyte (teckensnittsnamn i `$1`) |
| `battery-low` | När batteriet börjar ta slut (procent i `$1`) |

Hooken `pre-refresh-pacman` är platsen där anpassade förråd eller `IgnorePkg`-rader hör hemma, eftersom den körs före pakettransaktionen. Båda uppdateringsrelaterade hookar körs som din användare efter att Omarchy har rensat sin cachade sudo-auktorisering, så en hook som använder `sudo` behöver sin egen auktorisering och kan be om ditt lösenord.

Var och en av dessa kataloger innehåller redan en `.sample`-fil som visar hur en hook ska se ut — ta bort `.sample` från namnet för att börja använda den. För att installera ett skript som du har skrivit någon annanstans använder du `omarchy hook install post-boot ~/my-hook`, som kopierar in det och gör det körbart.

### Lägga till egna menyalternativ

Omarchy-menyn (`Super + Space`) kan utökas med dina egna rader genom att redigera `~/.config/omarchy/extensions/omarchy-menu.jsonc`. Alternativ nycklas med ett punktavgränsat id, och det är id:t som placerar dem i trädet, så `personal` visas i rotmenyn och `personal.notes` visas inuti den:

```jsonc
"personal": {"icon":"","label":"Personal"},
"personal.notes": {"icon":"󰎞","label":"Notes","action":"omarchy-launch-editor ~/notes"},
```

Återanvänder du ett befintligt id åsidosätter du den raden i stället för att lägga till en ny. Filen levereras med alla tillgängliga fält dokumenterade som kommentarer.

### Lägga till egna skalexporter, funktioner och alias

Omarchy levereras med en massa ergonomiska alias och hjälpsamma funktioner, men det är mycket vanligt att vilja lägga till sina egna. Du ska lägga till både alias, funktioner och exporter i `~/.bashrc`. Den här filen skrivs inte över vid uppdateringar. Om du vill ändra något av Omarchys standardvärden kan du också tryggt lägga till dem här.

### Ändra interna Omarchy-filer

Hör här, det här är din dator. Du kan göra precis vad du vill med den, men jag avråder från att göra ändringar direkt i filerna i `/usr/share/omarchy`. De tillhör Omarchys pacman-paket, så dina ändringar skrivs helt enkelt över vid nästa uppdatering. Du gör bättre i att bara skriva över alla standardvärden du inte gillar i mappen `~/.config/*` i stället.

Du kan ändra nästan allt på det sättet, som standardtangentbindningarna. Redigera bara `~/.config/hypr/bindings.lua` för att, säg, ersätta [Obsidian](https://obsidian.md/) med [Joplin](https://joplinapp.org/) (installera med `omarchy-pkg-add joplin-bin`):

```lua
o.rebind("SUPER + SHIFT + O", "Joplin", "joplin-desktop")
```

`o.rebind` tar bort den befintliga bindningen innan den lägger till sin ersättning. Den tar samma argument som `o.bind`, inklusive starthjälpare och bindningsalternativ. Använd `o.bind` för att lägga till en bindning, eller `hl.unbind` för att ta bort en utan att ersätta den.

Om du insisterar på att hacka på de interna Omarchy-filerna byter du till dev-kanalen via _Update > Channel > Dev_. Det länkar Omarchy till en git-utcheckning av källkoden i `~/omarchy`, som du fritt kan ändra precis hur mycket du vill. Det finns ingen här som ska tala om för dig vad du ska göra!

### Återställa ändringar

Om du till slut rör till konfigurationerna kan du alltid återställa dem till standardvärdena via _Update > Config_ i Omarchy-menyn. Eller genom att köra `omarchy reinstall configs` för att återställa allt.
