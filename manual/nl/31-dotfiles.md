# Dotfiles

Omarchy wordt voornamelijk geconfigureerd via de zogenoemde dotfiles die in `~/.config` staan. Die worden beschouwd als jouw bestanden voor jouw wijzigingen. De bestanden die in `/usr/share/omarchy` staan, behoren tot Omarchy zelf, en daar moet je niet mee rommelen. Als je iets in `/usr/share/omarchy` moet wijzigen, moet je in plaats daarvan de waarde in `~/.config` overschrijven.

De belangrijkste configuraties kun je rechtstreeks bewerken vanuit het Omarchy-menu (`Super + Space`), zoals _Setup > Keyboard > Keybindings_, _Setup > Input_ en _Setup > Config > [file]_. Als je het op deze manier doet, wordt elk proces dat na configuratiewijzigingen opnieuw moet worden gestart automatisch opnieuw gestart nadat je de editor afsluit (standaard Neovim — `:wq`, vergeet het niet! — maar dat kun je wijzigen via _Setup > Defaults > Editor_).

Hier is een lijst met de belangrijkste bestanden in `~/.config` en wat ze regelen:

| Bestand                  | Doel              |
| ----------------------- | --------------------- |
| `~/.config/hypr/hyprland.lua` | Het belangrijkste Hyprland-configuratiebestand. Laadt de Omarchy-standaardwaarden plus je onderstaande override-bestanden. [Meer informatie over Hyprland-configuraties](https://wiki.hypr.land/Configuring/).  |
| `~/.config/hypr/bindings.lua` | Je eigen sneltoetsen en overrides van de standaardwaarden. |
| `~/.config/hypr/monitors.lua` | Monitorinstellingen die het monitorpaneel niet dekt, zoals rotatie, extra modi, of een monitor uit laten staan. |
| `~/.config/hypr/input.lua` | Regelt je toetsenbordindeling, muis- en trackpadinstellingen. |
| `~/.config/hypr/looknfeel.lua` | Regelt tussenruimtes, randen, animaties en de rest van het uiterlijk. |
| `~/.config/hypr/autostart.lua` | Regelt extra processen die met de sessie worden gestart. |
| `~/.config/omarchy/shell.json` | Regelt de Omarchy-shell: positie van de balk, indeling en widgets, plus tijdinstellingen voor screensaver, vergrendeling en inactiviteit. |
| `~/.config/foot/foot.ini` | Regelt je terminal (foot is de standaard). |
| `~/.XCompose` | Definieert je snel toegankelijke emoji en autocomplete voor naam/e-mail. Zorg ervoor dat je `omarchy-restart-xcompose` uitvoert nadat je wijzigingen hebt aangebracht. |

Als je uiteindelijk veel wijzigingen aanbrengt om je eigen setup aan te passen, is het een goed idee om een back-up te maken van al deze dotfiles. [Stow is een geweldige manier om dat te doen](https://www.youtube.com/watch?v=NoFiYOqnC4o).

### Je eigen apps starten met de sessie

Als je wilt dat er elke keer dat je inlogt iets wordt uitgevoerd — een synchronisatiedaemon, een chatapp, je eigen script — zet het dan in `~/.config/hypr/autostart.lua`:

```lua
o.launch_on_start("my-service")
```

Dat start het commando als onderdeel van de sessie, zodat het netjes wordt opgeruimd wanneer je weer uitlogt.

### Scripts uitvoeren bij systeemgebeurtenissen

Omarchy activeert hooks op een handvol momenten, en je kunt er je eigen scripts aan koppelen. Ze staan in `~/.config/omarchy/hooks/<event>.d/`, één map per gebeurtenis, en elk uitvoerbaar bestand daarin wordt uitgevoerd wanneer de gebeurtenis plaatsvindt:

| Gebeurtenis | Wanneer deze wordt uitgevoerd |
| ----- | ------------ |
| `post-boot` | Direct nadat het bureaublad is gestart |
| `post-update` | Tegen het einde van `omarchy update`, na pakketten, migraties en het opnieuw starten van services, voordat mise-tools worden bijgewerkt |
| `pre-refresh-pacman` | Nadat `omarchy refresh pacman` de pakketconfiguratie opnieuw heeft gesynchroniseerd, voordat het pakketten bijwerkt; bij het wisselen van kanaal wordt deze tijdens dezelfde refresh-stap uitgevoerd |
| `theme-set` | Na een themawijziging (themanaam in `$1`) |
| `font-set` | Na een lettertypewijziging (lettertypenaam in `$1`) |
| `battery-low` | Wanneer de accu bijna leeg is (percentage in `$1`) |

De `pre-refresh-pacman`-hook is de plek waar aangepaste repositories of `IgnorePkg`-regels thuishoren, aangezien deze wordt uitgevoerd vóór de pakkettransactie. Beide update-gerelateerde hooks worden uitgevoerd als jouw gebruiker nadat Omarchy zijn gecachte sudo-autorisatie heeft gewist, dus een hook die `sudo` gebruikt heeft zijn eigen autorisatie nodig en kan om je wachtwoord vragen.

Elke van die mappen bevat al een `.sample`-bestand dat de vorm van een hook laat zien — verwijder `.sample` uit de naam om hem in gebruik te nemen. Om een script te installeren dat je elders hebt geschreven, gebruik je `omarchy hook install post-boot ~/my-hook`, waarmee het wordt ingekopieerd en uitvoerbaar wordt gemaakt.

### Je eigen menu-items toevoegen

Het Omarchy-menu (`Super + Space`) kan worden uitgebreid met je eigen rijen door `~/.config/omarchy/extensions/omarchy-menu.jsonc` te bewerken. Items worden geïdentificeerd met een id met punten, en die id bepaalt waar ze in de structuur terechtkomen, dus `personal` verschijnt in het hoofdmenu en `personal.notes` verschijnt daarbinnen:

```jsonc
"personal": {"icon":"","label":"Personal"},
"personal.notes": {"icon":"󰎞","label":"Notes","action":"omarchy-launch-editor ~/notes"},
```

Hergebruik je een bestaande id, dan overschrijf je die rij in plaats van een nieuwe toe te voegen. Het bestand wordt geleverd met alle beschikbare velden gedocumenteerd als commentaar.

### Je eigen shell-exports, functies en aliassen toevoegen

Omarchy wordt geleverd met een heleboel ergonomische aliassen en handige functies, maar het is heel gebruikelijk dat je je eigen wilt toevoegen. Je moet zowel aliassen, functies als exports toevoegen in `~/.bashrc`. Dit bestand wordt bij updates niet overschreven. Als je een van de Omarchy-standaardwaarden wilt wijzigen, kun je die hier ook veilig toevoegen.

### Omgevingsvariabelen voor het bureaublad instellen

Exports voor de bureaubladsessie horen in `~/.config/uwsm/env.d/`. Deze bestanden worden uitgevoerd voordat je bureaublad start, dus een shellfout kan je terugsturen naar het inlogscherm. Houd een werkende terminal open terwijl je ze bewerkt. Om een override uit te schakelen, verplaats je deze uit `env.d`. Zie [inlogherstel](45-troubleshooting.md#my-password-is-accepted-but-i-return-to-the-login-screen) als een wijziging inloggen verhindert.

### Interne Omarchy-bestanden wijzigen

Kijk, dit is jouw computer. Je kunt ermee doen wat je wilt, maar ik raad je af om rechtstreeks wijzigingen aan te brengen in de bestanden in `/usr/share/omarchy`. Ze behoren tot het Omarchy-pacman-pakket, dus je wijzigingen worden bij de volgende update gewoon overschreven. Je kunt beter gewoon alle standaardwaarden die je niet bevallen overschrijven in de map `~/.config/*`.

Op die manier kun je vrijwel alles wijzigen, zoals de standaard sneltoetsen. Bewerk gewoon `~/.config/hypr/bindings.lua` om bijvoorbeeld [Obsidian](https://obsidian.md/) te vervangen door [Joplin](https://joplinapp.org/) (installeer met `omarchy-pkg-add joplin-bin`):

```lua
o.rebind("SUPER + SHIFT + O", "Joplin", "joplin-desktop")
```

`o.rebind` verwijdert de bestaande binding voordat de vervanging wordt toegevoegd. Het neemt dezelfde argumenten als `o.bind`, inclusief launch-helpers en bindingopties. Gebruik `o.bind` om een binding toe te voegen, of `hl.unbind` om er een te verwijderen zonder deze te vervangen.

Als je erop staat om aan de interne Omarchy-bestanden te sleutelen, schakel dan over naar het dev-kanaal via _Update > Channel > Dev_. Dat koppelt Omarchy aan een git-checkout van de broncode in `~/omarchy`, die je naar hartenlust kunt wijzigen. Er is hier niemand die je vertelt wat je moet doen!

### Alle wijzigingen resetten

Als je er uiteindelijk een puinhoop van je configuraties maakt, kun je ze altijd terugzetten naar de standaardwaarden via _Update > Config_ in het Omarchy-menu. Of door `omarchy reinstall configs` uit te voeren om alles te resetten.
