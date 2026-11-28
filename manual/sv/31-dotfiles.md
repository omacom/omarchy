# Dotfiles

Omarchy konfigureras i första hand via de så kallade dotfiles som ligger i `~/.config`. De betraktas som dina filer för dina ändringar. Filerna som ligger i `/usr/share/omarchy` tillhör själva Omarchy, och dem ska du inte hålla på och pilla med. Om du behöver ändra något i `/usr/share/omarchy` ska du i stället skriva över värdet i `~/.config`.

De viktigaste konfigurationsfilerna kan redigeras direkt från Omarchy-menyn (`Super + Space`), som _Setup > Keyboard > Keybindings_, _Setup > Input_ och _Setup > Config > [file]_. När du gör det på det här sättet kommer alla processer som behöver startas om efter konfigurationsändringar att startas om automatiskt när du stänger editorn (Neovim som standard — `:wq`, kom ihåg det! — men du kan ändra det via _Setup > Defaults > Editor_).

Här är en lista över de viktigaste filerna i `~/.config` och vad de styr:

| Fil | Syfte |
| ----------------------- | --------------------- |
| `~/.config/hypr/hyprland.lua` | Den huvudsakliga Hyprland-konfigurationen. Läser in Omarchys standardvärden plus dina åsidosättande filer nedan. [Läs mer om Hyprland-konfigurationer](https://wiki.hypr.land/Configuring/). |
| `~/.config/hypr/bindings.lua` | Dina egna tangentbindningar och åsidosättningar av standardvärdena. |
| `~/.config/hypr/monitors.lua` | Skärminställningar som skärmpanelen inte täcker, som rotation, extra lägen eller att hålla en skärm avstängd. |
| `~/.config/hypr/input.lua` | Styr inställningarna för tangentbordslayout, mus och styrplatta. |
| `~/.config/hypr/looknfeel.lua` | Styr mellanrum, kanter, animationer och resten av utseendet. |
| `~/.config/hypr/autostart.lua` | Styr extra processer som startas med sessionen. |
| `~/.config/omarchy/shell.json` | Styr Omarchy-skalet: panelplacering, layout och widgetar, plus tidsinställningar för skärmsläckare, lås och inaktivitet. |
| `~/.config/foot/foot.ini` | Styr din terminal (foot är standard). |
| `~/.XCompose` | Definierar dina snabbåtkomst-emojier och automatisk komplettering av namn/e-post. Se till att köra `omarchy-restart-xcompose` efter att du har gjort ändringar. |

Om du till slut gör många ändringar för att finjustera din egen uppsättning är det en bra idé att säkerhetskopiera alla dessa dotfiles. [Stow är ett utmärkt sätt att göra det på](https://www.youtube.com/watch?v=NoFiYOqnC4o).

### Starta dina egna appar med sessionen

Om du vill att något ska köras varje gång du loggar in — en synkdaemon, en chattapp, ditt eget skript — lägg det i `~/.config/hypr/autostart.lua`:

```lua
o.launch_on_start("my-service")
```

Det startar kommandot som en del av sessionen, så det städas ordentligt upp när du loggar ut igen.

### Köra skript vid systemhändelser

Omarchy utlöser hooks vid en handfull tillfällen, och du kan hänga på dina egna skript på dem. De ligger i `~/.config/omarchy/hooks/<event>.d/`, en katalog per händelse, och varje fil där inne som inte slutar på `.sample` körs med bash när händelsen inträffar:

| Händelse | När den körs |
| ----- | ------------ |
| `post-boot` | Direkt efter att skrivbordet har startat |
| `post-update` | Nära slutet av `omarchy update`, efter paket, migrationer och omstarter av tjänster, innan mise-verktyg uppdateras |
| `pre-refresh-pacman` | Efter att `omarchy refresh pacman` har synkat om paketkonfigurationen, innan den uppdaterar paket; ett kanalbyte kör den under samma refresh-steg |
| `theme-set` | Efter ett temabyte (temanamn i `$1`) |
| `font-set` | Efter ett teckensnittsbyte (teckensnittsnamn i `$1`) |
| `battery-low` | När batteriet börjar bli lågt (procent i `$1`) |

`pre-refresh-pacman`-hooken är där anpassade förråd eller `IgnorePkg`-rader hör hemma, eftersom den körs före pakettransaktionen. Båda körs som din användare. `post-update` körs medan sudo-auktoriseringen för `omarchy update` fortfarande är färsk, så en hook som använder `sudo` kommer inte att fråga efter ditt lösenord igen; `pre-refresh-pacman` körs direkt efter att `omarchy refresh pacman` själv har använt sudo.

Var och en av dessa kataloger innehåller redan en `.sample`-fil som visar hur en hook ska se ut — ta bort `.sample` från namnet för att sätta den i arbete. För att installera ett skript som du har skrivit någon annanstans använder du `omarchy hook install post-boot ~/my-hook`, vilket kopierar in det och gör det körbart.

### Lägga till egna menyposter

Omarchy-menyn (`Super + Space`) kan utökas med dina egna rader genom att redigera `~/.config/omarchy/extensions/omarchy-menu.jsonc`. Poster nycklas med ett punktseparerat id, och det är id:t som placerar dem i trädet, så `personal` visas i rotmenyn och `personal.notes` visas inuti den:

```jsonc
"personal": {"icon":"","label":"Personal"},
"personal.notes": {"icon":"󰎞","label":"Notes","action":"omarchy-launch-editor ~/notes"},
```

Återanvänder du ett befintligt id åsidosätter du den raden i stället för att lägga till en ny. Filen levereras med alla tillgängliga fält dokumenterade som kommentarer.

### Lägga till egna skalexporter, funktioner och alias

Omarchy levereras med en mängd ergonomiska alias och hjälpsamma funktioner, men det är mycket vanligt att vilja lägga till egna. Du ska lägga till både alias, funktioner och exporter i `~/.bashrc`. Den filen kommer inte att skrivas över vid uppdateringar. Om du vill ändra något av Omarchys standardvärden kan du också tryggt lägga dem här.

### Ställa in miljövariabler för skrivbordet

Exporter för skrivbordssessionen hör hemma i `~/.config/uwsm/env.d/`. Dessa filer körs innan skrivbordet startar, så ett skalfel kan skicka dig tillbaka till inloggningsskärmen. Håll en fungerande terminal öppen medan du redigerar dem. För att inaktivera en åsidosättning flyttar du den ut ur `env.d`. Se [återställning av inloggning](45-troubleshooting.md#my-password-is-accepted-but-i-return-to-the-login-screen) om en ändring förhindrar inloggning.

### Ändra interna Omarchy-filer

Lyssna, det här är din dator. Du kan göra vad du vill med den, men jag skulle avråda från att göra ändringar direkt i filerna i `/usr/share/omarchy`. De tillhör Omarchys pacman-paket, så dina ändringar kommer helt enkelt att skrivas över vid nästa uppdatering. Du gör bättre i att bara skriva över de standardvärden du inte gillar i mappen `~/.config/*` i stället.

Du kan ändra nästan allt på det sättet, som standardtangentbindningarna. Redigera bara `~/.config/hypr/bindings.lua` för att, låt säga, ersätta [Obsidian](https://obsidian.md/) med [Joplin](https://joplinapp.org/) (installera med `omarchy-pkg-add joplin-bin`):

```lua
o.rebind("SUPER + SHIFT + O", "Joplin", "joplin-desktop")
```

`o.rebind` tar bort den befintliga bindningen innan den lägger till ersättningen. Den tar samma argument som `o.bind`, inklusive starthjälpfunktioner och bindningsalternativ. Använd `o.bind` för att lägga till en bindning, eller `hl.unbind` för att ta bort en utan att ersätta den.

Om du insisterar på att hacka på de interna Omarchy-filerna, byt till dev-kanalen via _Update > Channel > Dev_. Det länkar Omarchy till en git-checkout av källkoden i `~/omarchy`, som du fritt kan ändra så mycket du vill. Här finns det ingen som kan tala om för dig vad du ska göra!

### Återställa alla ändringar

Om du till slut rör till konfigurationerna kan du alltid återställa dem till standardvärdena via _Update > Config_ i Omarchy-menyn. Eller genom att köra `omarchy reinstall configs` för att återställa allt.
