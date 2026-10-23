# Dotfiles

Omarchy konfigureras främst via de så kallade dotfiles som bor i `~/.config`. De betraktas som dina filer för dina ändringar. Filerna som bor i `/usr/share/omarchy` tillhör Omarchy självt, och du bör inte hålla på och pilla med dem. Om du behöver ändra något i `/usr/share/omarchy` bör du skriva över värdet i `~/.config` istället.

Nyckelkonfigurationerna kan redigeras direkt från Omarchy-menyn (`Super + Space`), som _Installation > Skärmar_, _Installation > Tangentgenvägar_, _Installation > Input_ och _Installation > Config > [file]_. När du gör det på det här sättet startas varje process som behöver startas om efter configredigeringar automatiskt om efter att du har avslutat editorn (Neovim som standard — `:wq`, kom ihåg! — men du kan ändra det via _Installation > Standarder > Editor_).

Här är en lista över nyckelfilerna i `~/.config` och vad de styr:

| File                  | Purpose              |
| ----------------------- | --------------------- |
| `~/.config/hypr/hyprland.lua` | Huvudkonfigen för Hyprland. Laddar Omarchy-standarderna plus dina åsidosättande filer nedan. [Läs mer om Hyprland-konfigar](https://wiki.hypr.land/Configuring/).  |
| `~/.config/hypr/bindings.lua` | Dina egna tangentbindningar och åsidosättningar av standarderna. |
| `~/.config/hypr/monitors.lua` | Styr dina skärmar, upplösning och position. |
| `~/.config/hypr/input.lua` | Styr din tangentbordslayout, mus och styrplatta. |
| `~/.config/hypr/looknfeel.lua` | Styr mellanrum, kantlinjer, animationer och resten av utseendet. |
| `~/.config/hypr/autostart.lua` | Styr extra processer som startas med sessionen. |
| `~/.config/omarchy/shell.json` | Styr Omarchy-skalet: fältposition, layout och widgetar, plus skärmsläckare, lås och viloperiodstider. |
| `~/.config/foot/foot.ini` | Styr din terminal (foot är standard). |
| `~/.XCompose` | Definierar din snabbåtkomst-emoji och namn/e-post-autokomplettering. Se till att köra `omarchy-restart-xcompose` efter att du gjort ändringar. |

Om du till slut gör många ändringar för att finslipa din egen uppsättning är det en god idé att säkerhetskopiera alla dessa dotfiles. [Stow är ett utmärkt sätt att göra det](https://www.youtube.com/watch?v=NoFiYOqnC4o).

### Starta dina egna appar med sessionen

Om du vill att något ska köras varje gång du loggar in — en synk-daemon, en chattapp, ditt eget skript — lägg det i `~/.config/hypr/autostart.lua`:

```lua
o.launch_on_start("my-service")
```

Det startar kommandot som en del av sessionen, så det städas upp ordentligt när du loggar ut igen.

### Köra skript vid systemhändelser

Omarchy avfyrar hooks vid en handfull tillfällen, och du kan hänga dina egna skript på dem. De bor i `~/.config/omarchy/hooks/<event>.d/`, en katalog per händelse, och varje körbar fil där inne körs när händelsen inträffar:

| Event | When it runs |
| ----- | ------------ |
| `post-boot` | Direkt efter att skrivbordet har startat |
| `post-update` | Nära slutet av `omarchy update`, efter paket, migrationer och tjänsteomstarter, innan mise-verktyg uppdateras |
| `pre-refresh-pacman` | Efter att `omarchy refresh pacman` synkar om paketkonfigurationen, innan den uppdaterar paket; en kanalväxlare kör den under samma uppdateringssteg |
| `theme-set` | Efter ett temabyte (temanamn i `$1`) |
| `font-set` | Efter ett typsnittsbyte (typsnittsnamn i `$1`) |
| `battery-low` | När batteriet börjar bli lågt (procent i `$1`) |

Den `pre-refresh-pacman`-hooken är där anpassade repositories eller `IgnorePkg`-rader hör hemma, eftersom den körs före pakettransaktionen. Båda uppdateringsrelaterade hookar körs som din användare efter att Omarchy rensat sin cachade sudo-behörighet, så en hook som använder `sudo` behöver sin egen behörighet och kan be om ditt lösenord.

Var och en av dessa kataloger innehåller redan en `.sample`-fil som visar hur en hook ser ut — ta bort `.sample` från namnet för att sätta den i arbete. För att installera ett skript du har skrivit någon annanstans, använd `omarchy hook install post-boot ~/my-hook`, vilket kopierar in det och gör det körbart.

### Lägga till dina egna menyposter

Omarchy-menyn (`Super + Space`) kan utökas med dina egna rader genom att redigera `~/.config/omarchy/extensions/omarchy-menu.jsonc`. Poster nycklas av ett punktid, och id:t är det som placerar dem i trädet, så `personal` dyker upp på rotmenyn och `personal.notes` dyker upp inuti den:

```jsonc
"personal": {"icon":"","label":"Personal"},
"personal.notes": {"icon":"󰎞","label":"Notes","action":"omarchy-launch-editor ~/notes"},
```

Återanvänd ett befintligt id så åsidosätter du den raden istället för att lägga till en ny. Filen levereras med alla tillgängliga fält dokumenterade som kommentarer.

### Lägga till dina egna shell-exporter, funktioner och alias

Omarchy levereras med en massa ergonomiska alias och hjälpsamma funktioner, men det är väldigt vanligt att vilja lägga till egna. Du bör lägga till både alias, funktioner och exporter i `~/.bashrc`. Den här filen skrivs inte över vid uppdateringar. Om du vill ändra någon av Omarchy-standarderna kan du också säkert lägga till dem här.

### Ändra interna Omarchy-filer

Okej, det här är din dator. Du kan göra vad du vill med den, men jag avråder från att göra ändringar i filerna i `/usr/share/omarchy` direkt. De tillhör Omarchys pacman-paket, så dina ändringar skrivs helt enkelt över vid nästa uppdatering. Det är bättre att bara skriva över de standardvärden du inte gillar i mappen `~/.config/*` istället.

Du kan ändra ungefär allt på det sättet, som standard-tangentbindningarna. Redigera bara `~/.config/hypr/bindings.lua` för att till exempel ersätta [Obsidian](https://obsidian.md/) med [Joplin](https://joplinapp.org/) (installera med `omarchy-pkg-add joplin-bin`):

```lua
o.rebind("SUPER + SHIFT + O", "Joplin", "joplin-desktop")
```

`o.rebind` tar bort den befintliga bindningen innan den lägger till ersättningen. Den tar samma argument som `o.bind`, inklusive starhjälpare och bindningsalternativ. Använd `o.bind` för att lägga till en bindning, eller `hl.unbind` för att ta bort en utan att ersätta den.

Om du insisterar på att hacka på de interna Omarchy-filerna, växla till dev-kanalen via _Uppdatera > Channel > Dev_. Det länkar Omarchy till en git-checkout av källkoden i `~/omarchy`, som du fritt kan ändra i hjärtans lust. Det finns ingen här som kan säga åt dig vad du ska göra!

### Återställa ändringar

Om du till slut rör till konfigurationerna kan du alltid återställa dem till standarderna via _Uppdatera > Config_ i Omarchy-menyn. Eller genom att köra `omarchy reinstall configs` för att återställa allt.
