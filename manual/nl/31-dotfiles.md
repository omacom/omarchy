# Dotfiles

Omarchy wordt voornamelijk geconfigureerd via de zogeheten dotfiles die in `~/.config` staan. Die worden beschouwd als jouw bestanden voor jouw wijzigingen. De bestanden die in `/usr/share/omarchy` staan, horen bij Omarchy zelf, en daar moet je niet mee rommelen. Als je iets in `/usr/share/omarchy` moet wijzigen, moet je in plaats daarvan de waarde in `~/.config` overschrijven.

De belangrijkste configuraties kun je rechtstreeks bewerken vanuit het Omarchy-menu (`Super + Space`), zoals _Instellingen > Sneltoetsen_, _Instellingen > Invoer_ en _Instellingen > Configuratie > [file]_. Als je het op deze manier doet, wordt elk proces dat na configuratiewijzigingen opnieuw moet worden gestart automatisch opnieuw gestart nadat je de editor afsluit (standaard Neovim — `:wq`, niet vergeten! — maar dat kun je wijzigen via _Instellingen > Standaardinstellingen > Editor_).

Hier is een lijst van de belangrijkste bestanden in `~/.config` en wat ze regelen:

| Bestand | Doel |
| ----------------------- | --------------------- |
| `~/.config/hypr/hyprland.lua` | De hoofdconfiguratie van Hyprland. Laadt de standaardinstellingen van Omarchy plus je onderstaande override-bestanden. [Meer informatie over Hyprland-configuraties](https://wiki.hypr.land/Configuring/). |
| `~/.config/hypr/bindings.lua` | Je eigen sneltoetsen en overschrijvingen van de standaardinstellingen. |
| `~/.config/hypr/monitors.lua` | Monitorinstellingen die het monitorpaneel niet dekt, zoals rotatie, extra modi, of een monitor uit laten staan. |
| `~/.config/hypr/input.lua` | Regelt je toetsenbordindeling, muis- en trackpadinstellingen. |
| `~/.config/hypr/looknfeel.lua` | Regelt tussenruimtes, randen, animaties en de rest van het uiterlijk. |
| `~/.config/hypr/autostart.lua` | Regelt extra processen die met de sessie worden gestart. |
| `~/.config/omarchy/shell.json` | Regelt de Omarchy-shell: positie van de balk, lay-out en widgets, plus de timing voor schermbeveiliging, vergrendeling en inactiviteit. |
| `~/.config/foot/foot.ini` | Regelt je terminal (foot is de standaard). |
| `~/.XCompose` | Definieert je snel toegankelijke emoji en de automatische aanvulling van namen/e-mailadressen. Zorg dat je na wijzigingen `omarchy-restart-xcompose` uitvoert. |

Als je uiteindelijk veel wijzigingen aanbrengt om je eigen setup naar je hand te zetten, is het een goed idee om al deze dotfiles te back-uppen. [Stow is daar een geweldige manier voor](https://www.youtube.com/watch?v=NoFiYOqnC4o).

### Je eigen apps starten met de sessie

Als je wilt dat iets elke keer wordt uitgevoerd wanneer je inlogt — een sync-daemon, een chatapp, je eigen script — zet het dan in `~/.config/hypr/autostart.lua`:

```lua
o.launch_on_start("my-service")
```

Daarmee start de opdracht als onderdeel van de sessie, zodat hij netjes wordt opgeruimd wanneer je je weer afmeldt.

### Scripts uitvoeren bij systeemgebeurtenissen

Omarchy activeert hooks op een handvol momenten, en je kunt er je eigen scripts aan hangen. Ze staan in `~/.config/omarchy/hooks/<event>.d/`, één map per gebeurtenis, en elk uitvoerbaar bestand daarin wordt uitgevoerd wanneer de gebeurtenis plaatsvindt:

| Gebeurtenis | Wanneer deze wordt uitgevoerd |
| ----- | ------------ |
| `post-boot` | Vlak nadat het bureaublad is gestart |
| `post-update` | Tegen het einde van `omarchy update`, na pakketten, migraties en het opnieuw starten van services, voordat mise-tools worden bijgewerkt |
| `pre-refresh-pacman` | Nadat `omarchy refresh pacman` de pakketconfiguratie opnieuw synchroniseert, voordat hij pakketten bijwerkt; bij het wisselen van kanaal wordt hij tijdens diezelfde vernieuwingsstap uitgevoerd |
| `theme-set` | Na een themawijziging (themanaam in `$1`) |
| `font-set` | Na een lettertypewijziging (naam van het lettertype in `$1`) |
| `battery-low` | Wanneer de batterij bijna leeg is (percentage in `$1`) |

In de `pre-refresh-pacman`-hook horen aangepaste repositories of `IgnorePkg`-regels thuis, aangezien hij wordt uitgevoerd vóór de pakkettransactie. Beide update-gerelateerde hooks draaien als jouw gebruiker nadat Omarchy zijn gecachete sudo-autorisatie heeft gewist, dus een hook die `sudo` gebruikt, heeft zijn eigen autorisatie nodig en kan om je wachtwoord vragen.

Elk van die mappen bevat al een `.sample`-bestand dat laat zien hoe een hook eruitziet — haal `.sample` uit de naam om hem in werking te stellen. Om een script te installeren dat je elders hebt geschreven, gebruik je `omarchy hook install post-boot ~/my-hook`, waarmee het wordt ingekopieerd en uitvoerbaar wordt gemaakt.

### Je eigen menu-items toevoegen

Het Omarchy-menu (`Super + Space`) kan worden uitgebreid met je eigen rijen door `~/.config/omarchy/extensions/omarchy-menu.jsonc` te bewerken. Items worden gesleuteld met een id met punten, en die id bepaalt waar ze in de boom terechtkomen, dus `personal` verschijnt in het hoofdmenu en `personal.notes` verschijnt daarbinnen:

```jsonc
"personal": {"icon":"","label":"Personal"},
"personal.notes": {"icon":"󰎞","label":"Notes","action":"omarchy-launch-editor ~/notes"},
```

Gebruik je een bestaande id opnieuw, dan overschrijf je die rij in plaats van een nieuwe toe te voegen. Het bestand wordt geleverd met alle beschikbare velden gedocumenteerd als commentaar.

### Je eigen shell-exports, -functies en -aliassen toevoegen

Omarchy wordt geleverd met een heleboel ergonomische aliassen en handige functies, maar het is heel gebruikelijk om je eigen toe te willen voegen. Je moet aliassen, functies en exports toevoegen in `~/.bashrc`. Dit bestand wordt bij updates niet overschreven. Als je een van de standaardinstellingen van Omarchy wilt wijzigen, kun je die hier ook veilig toevoegen.

### Interne Omarchy-bestanden wijzigen

Kijk, dit is jouw computer. Je kunt ermee doen wat je wilt, maar ik raad je af om de bestanden in `/usr/share/omarchy` rechtstreeks te wijzigen. Ze horen bij het Omarchy-pacman-pakket, dus je wijzigingen worden bij de volgende update gewoon overschreven. Je kunt beter gewoon alle standaardwaarden die je niet bevallen overschrijven in de map `~/.config/*`.

Op die manier kun je vrijwel alles wijzigen, zoals de standaard sneltoetsen. Bewerk gewoon `~/.config/hypr/bindings.lua` om bijvoorbeeld [Obsidian](https://obsidian.md/) te vervangen door [Joplin](https://joplinapp.org/) (installeer met `omarchy-pkg-add joplin-bin`):

```lua
o.rebind("SUPER + SHIFT + O", "Joplin", "joplin-desktop")
```

`o.rebind` verwijdert de bestaande binding voordat hij de vervanging toevoegt. Hij neemt dezelfde argumenten als `o.bind`, inclusief launch-helpers en bindingopties. Gebruik `o.bind` om een binding toe te voegen, of `hl.unbind` om er een te verwijderen zonder hem te vervangen.

Als je erop staat om aan de interne Omarchy-bestanden te sleutelen, schakel dan over naar het dev-kanaal via _Update > Kanaal > Dev_. Dat koppelt Omarchy aan een git-checkout van de broncode in `~/omarchy`, die je naar hartenlust kunt wijzigen. Niemand hier die jou vertelt wat je moet doen!

### Wijzigingen resetten

Als je er uiteindelijk een puinhoop van maakt met de configuraties, kun je ze altijd terugzetten naar de standaardinstellingen via _Update > Configuratie_ in het Omarchy-menu. Of door `omarchy reinstall configs` uit te voeren om alles te resetten.
