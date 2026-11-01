# Dotfiles

Omarchy wordt voornamelijk geconfigureerd via de zogenoemde dotfiles die in `~/.config` staan. Die worden beschouwd als jouw bestanden voor jouw wijzigingen. De bestanden die in `/usr/share/omarchy` staan, behoren tot Omarchy zelf, en daar moet je vanaf blijven. Als je iets in `/usr/share/omarchy` moet wijzigen, moet je in plaats daarvan de waarde overschrijven in `~/.config`.

De belangrijkste configs kun je rechtstreeks vanuit het Omarchy-menu (`Super + Space`) bewerken, zoals _Setup > Keybindings_, _Setup > Input_ en _Setup > Config > [file]_. Als je het op deze manier doet, wordt elk proces dat na config-wijzigingen opnieuw moet worden gestart dat automatisch nadat je de editor afsluit (Neovim is de standaard — `:wq`, onthoud dat! — maar je kunt dat wijzigen via _Setup > Defaults > Editor_).

Hier is een lijst van de belangrijkste bestanden in `~/.config` en wat ze aansturen:

| File                  | Purpose              |
| ----------------------- | --------------------- |
| `~/.config/hypr/hyprland.lua` | De hoofdconfig van Hyprland. Laadt de Omarchy-standaardwaarden plus je onderstaande override-bestanden. [Meer informatie over Hyprland-configs](https://wiki.hypr.land/Configuring/).  |
| `~/.config/hypr/bindings.lua` | Je eigen toetsbindingen en overschrijvingen van de standaardwaarden. |
| `~/.config/hypr/monitors.lua` | Monitorinstellingen die het monitorpaneel niet dekt, zoals rotatie, extra modi, of een monitor uit laten staan. |
| `~/.config/hypr/input.lua` | Stuurt je toetsenbordindeling, muis- en trackpadinstellingen aan. |
| `~/.config/hypr/looknfeel.lua` | Stuurt tussenruimtes, randen, animaties en de rest van het uiterlijk aan. |
| `~/.config/hypr/autostart.lua` | Stuurt extra processen aan die met de sessie worden gestart. |
| `~/.config/omarchy/shell.json` | Stuurt de Omarchy-shell aan: balkpositie, indeling en widgets, plus timings voor screensaver, vergrendeling en inactiviteit. |
| `~/.config/foot/foot.ini` | Stuurt je terminal aan (foot is de standaard). |
| `~/.XCompose` | Definieert je snel toegankelijke emoji en autocomplete voor naam/e-mail. Zorg dat je `omarchy-restart-xcompose` uitvoert nadat je wijzigingen hebt aangebracht. |

Als je uiteindelijk veel wijzigingen aanbrengt om je eigen setup te tweaken, is het een goed idee om al deze dotfiles te back-uppen. [Stow is een geweldige manier om dat te doen](https://www.youtube.com/watch?v=NoFiYOqnC4o).

### Je eigen apps starten met de sessie

Als je wilt dat er iets draait telkens wanneer je inlogt — een sync-daemon, een chat-app, je eigen script — zet het dan in `~/.config/hypr/autostart.lua`:

```lua
o.launch_on_start("my-service")
```

Dat start het commando als onderdeel van de sessie, zodat het netjes wordt opgeruimd wanneer je weer uitlogt.

### Scripts draaien bij systeemgebeurtenissen

Omarchy vuurt hooks af op een handvol momenten, en je kunt er je eigen scripts aan hangen. Ze staan in `~/.config/omarchy/hooks/<event>.d/`, één directory per gebeurtenis, en elk uitvoerbaar bestand daarin draait wanneer de gebeurtenis plaatsvindt:

| Event | When it runs |
| ----- | ------------ |
| `post-boot` | Direct nadat de desktop is gestart |
| `post-update` | Tegen het einde van `omarchy update`, na pakketten, migraties en herstarts van services, voordat mise-tools worden bijgewerkt |
| `pre-refresh-pacman` | Nadat `omarchy refresh pacman` de pakketconfig opnieuw synchroniseert, voordat het pakketten bijwerkt; een kanaalwissel draait het tijdens diezelfde refresh-stap |
| `theme-set` | Na een themawijziging (themanaam in `$1`) |
| `font-set` | Na een lettertypewijziging (lettertypenaam in `$1`) |
| `battery-low` | Wanneer de batterij bijna leeg is (percentage in `$1`) |

De `pre-refresh-pacman`-hook is waar aangepaste repositories of `IgnorePkg`-regels thuishoren, omdat hij draait vóór de pakkettransactie. Beide update-gerelateerde hooks draaien als jouw gebruiker nadat Omarchy zijn gecachete sudo-autorisatie heeft gewist, dus een hook die `sudo` gebruikt, heeft zijn eigen autorisatie nodig en kan om je wachtwoord vragen.

Elk van die directories bevat al een `.sample`-bestand dat de vorm van een hook laat zien — haal `.sample` uit de naam om hem in werking te stellen. Om een script te installeren dat je elders hebt geschreven, gebruik je `omarchy hook install post-boot ~/my-hook`, waarmee het wordt ingekopieerd en uitvoerbaar wordt gemaakt.

### Je eigen menu-items toevoegen

Het Omarchy-menu (`Super + Space`) kan worden uitgebreid met je eigen rijen door `~/.config/omarchy/extensions/omarchy-menu.jsonc` te bewerken. Items worden opgeslagen onder een id met punten, en de id is wat ze in de boom plaatst, dus `personal` verschijnt in het hoofdmenu en `personal.notes` verschijnt daarbinnen:

```jsonc
"personal": {"icon":"","label":"Personal"},
"personal.notes": {"icon":"󰎞","label":"Notes","action":"omarchy-launch-editor ~/notes"},
```

Hergebruik een bestaande id en je overschrijft die rij in plaats van een nieuwe toe te voegen. Het bestand wordt geleverd met alle beschikbare velden gedocumenteerd als commentaar.

### Je eigen shell-exports, functies en aliassen toevoegen

Omarchy wordt geleverd met een hoop ergonomische aliassen en handige functies, maar het is heel gebruikelijk om je eigen toe te willen voegen. Je moet aliassen, functies en exports allemaal toevoegen in `~/.bashrc`. Dit bestand wordt bij updates niet overschreven. Als je een van de Omarchy-standaardwaarden wilt wijzigen, kun je die hier ook veilig toevoegen.

### Omgevingsvariabelen instellen voor de desktop

Exports voor de desktopsessie horen in `~/.config/uwsm/env.d/`. Deze bestanden draaien voordat je desktop start, dus een shell-fout kan je terugsturen naar het inlogscherm. Houd een werkende terminal open terwijl je ze bewerkt. Om een override uit te schakelen, verplaats je hem uit `env.d`. Zie [inlogherstel](45-troubleshooting.md#my-password-is-accepted-but-i-return-to-the-login-screen) als een wijziging inloggen verhindert.

### Interne Omarchy-bestanden wijzigen

Kijk, dit is jouw computer. Je kunt ermee doen wat je wilt, maar ik raad je af om rechtstreeks wijzigingen aan te brengen in de bestanden in `/usr/share/omarchy`. Ze behoren tot het Omarchy pacman-pakket, dus je wijzigingen worden bij de volgende update gewoon overschreven. Je kunt beter gewoon alle standaardwaarden die je niet bevallen overschrijven in de map `~/.config/*`.

Je kunt op die manier vrijwel alles wijzigen, zoals de standaard toetsbindingen. Bewerk gewoon `~/.config/hypr/bindings.lua` om bijvoorbeeld [Obsidian](https://obsidian.md/) te vervangen door [Joplin](https://joplinapp.org/) (installeer met `omarchy-pkg-add joplin-bin`):

```lua
o.rebind("SUPER + SHIFT + O", "Joplin", "joplin-desktop")
```

`o.rebind` verwijdert de bestaande binding voordat het zijn vervanging toevoegt. Het neemt dezelfde argumenten als `o.bind`, inclusief launch-helpers en bindingopties. Gebruik `o.bind` om een binding toe te voegen, of `hl.unbind` om er een te verwijderen zonder hem te vervangen.

Als je erop staat om aan de interne Omarchy-bestanden te sleutelen, schakel dan over naar het dev-kanaal via _Update > Channel > Dev_. Dat koppelt Omarchy aan een git-checkout van de broncode in `~/omarchy`, die je naar hartenlust kunt wijzigen. Niemand hier gaat je vertellen wat je moet doen!

### Wijzigingen resetten

Als je er uiteindelijk een puinhoop van maakt met de configuraties, kun je ze altijd terugzetten naar de standaardwaarden via _Update > Config_ in het Omarchy-menu. Of door `omarchy reinstall configs` uit te voeren om alles te resetten.
