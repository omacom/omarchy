# Dotfiles

Omarchy wordt voornamelijk geconfigureerd via de zogenaamde dotfiles die in `~/.config` staan. Die worden beschouwd als jouw bestanden voor jouw wijzigingen. De bestanden die in `/usr/share/omarchy` staan, behoren tot Omarchy zelf, en daar moet je niet mee rommelen. Als je iets in `/usr/share/omarchy` moet wijzigen, moet je in plaats daarvan de waarde overschrijven in `~/.config`.

De belangrijkste configs kun je rechtstreeks bewerken vanuit het Omarchy-menu (`Super + Space`), zoals _Setup > Keyboard > Keybindings_, _Setup > Input_ en _Setup > Config > [file]_. Wanneer je het op deze manier doet, wordt elk proces dat na configuratiewijzigingen opnieuw moet worden gestart automatisch opnieuw gestart nadat je de editor afsluit (Neovim standaard — `:wq`, onthoud dat! — maar je kunt dat wijzigen via _Setup > Defaults > Editor_).

Hier is een lijst van de belangrijkste bestanden in `~/.config` en wat ze regelen:

| File                  | Purpose              |
| ----------------------- | --------------------- |
| `~/.config/hypr/hyprland.lua` | De hoofdconfiguratie van Hyprland. Laadt de standaardwaarden van Omarchy plus je onderstaande override-bestanden. [Meer informatie over Hyprland-configuraties](https://wiki.hypr.land/Configuring/).  |
| `~/.config/hypr/bindings.lua` | Je eigen keybindings en overrides van de standaardwaarden. |
| `~/.config/hypr/monitors.lua` | Monitorinstellingen die het monitorpaneel niet dekt, zoals rotatie, extra modi of een monitor uit houden. |
| `~/.config/hypr/input.lua` | Regelt je toetsenbordindeling, muis- en trackpadinstellingen. |
| `~/.config/hypr/looknfeel.lua` | Regelt gaps, borders, animaties en de rest van het uiterlijk. |
| `~/.config/hypr/autostart.lua` | Regelt extra processen die met de sessie worden gestart. |
| `~/.config/omarchy/shell.json` | Regelt de Omarchy-shell: barpositie, layout en widgets, plus timings voor screensaver, lock en idle. |
| `~/.config/foot/foot.ini` | Regelt je terminal (foot is de standaard). |
| `~/.XCompose` | Definieert je snel toegankelijke emoji en autocomplete voor naam/e-mail. Zorg ervoor dat je `omarchy-restart-xcompose` uitvoert nadat je wijzigingen hebt aangebracht. |

Als je uiteindelijk veel wijzigingen aanbrengt om je eigen setup te tweaken, is het een goed idee om al deze dotfiles te back-uppen. [Stow is daar een geweldige manier voor](https://www.youtube.com/watch?v=NoFiYOqnC4o).

### Je eigen apps starten met de sessie

Als je wilt dat er elke keer dat je inlogt iets draait — een sync-daemon, een chat-app, je eigen script — zet het dan in `~/.config/hypr/autostart.lua`:

```lua
o.launch_on_start("my-service")
```

Dat start het commando als onderdeel van de sessie, zodat het netjes wordt opgeruimd wanneer je weer uitlogt.

### Scripts uitvoeren bij systeemevents

Omarchy vuurt hooks af op een handvol momenten, en je kunt er je eigen scripts aan hangen. Ze staan in `~/.config/omarchy/hooks/<event>.d/`, één directory per event, en elk bestand daarin dat niet eindigt op `.sample` wordt met bash uitgevoerd wanneer het event plaatsvindt:

| Event | When it runs |
| ----- | ------------ |
| `post-boot` | Vlak nadat de desktop is gestart |
| `post-update` | Tegen het einde van `omarchy update`, na pakketten, migraties en het herstarten van services, voordat mise-tools worden bijgewerkt |
| `pre-refresh-pacman` | Nadat `omarchy refresh pacman` de pakketconfiguratie opnieuw heeft gesynchroniseerd, voordat het pakketten bijwerkt; een kanaalwissel voert het uit tijdens diezelfde refresh-stap |
| `theme-set` | Na een themaverandering (themanaam in `$1`) |
| `font-set` | Na een fontverandering (fontnaam in `$1`) |
| `battery-low` | Wanneer de batterij bijna leeg is (percentage in `$1`) |

De `pre-refresh-pacman`-hook is de plek waar custom repositories of `IgnorePkg`-regels thuishoren, aangezien deze draait vóór de pakkettransactie. Beide draaien als jouw gebruiker. `post-update` draait terwijl de sudo-autorisatie van `omarchy update` nog vers is, zodat een hook die `sudo` gebruikt niet opnieuw om je wachtwoord vraagt; `pre-refresh-pacman` draait vlak nadat `omarchy refresh pacman` zelf sudo heeft gebruikt.

Elk van die directories bevat al een `.sample`-bestand dat de vorm van een hook laat zien — haal `.sample` van de naam af om het aan het werk te zetten. Om een script te installeren dat je elders hebt geschreven, gebruik je `omarchy hook install post-boot ~/my-hook`, waarmee het wordt ingekopieerd en uitvoerbaar wordt gemaakt.

### Je eigen menu-items toevoegen

Het Omarchy-menu (`Super + Space`) kan worden uitgebreid met je eigen rijen door `~/.config/omarchy/extensions/omarchy-menu.jsonc` te bewerken. Items worden geïdentificeerd met een id met punten, en het id bepaalt waar ze in de boom terechtkomen, dus `personal` verschijnt in het hoofdmenu en `personal.notes` verschijnt daarbinnen:

```jsonc
"personal": {"icon":"","label":"Personal"},
"personal.notes": {"icon":"󰎞","label":"Notes","action":"omarchy-launch-editor ~/notes"},
```

Hergebruik je een bestaand id, dan overschrijf je die rij in plaats van een nieuwe toe te voegen. Het bestand wordt geleverd met alle beschikbare velden gedocumenteerd als commentaar.

### Je eigen shell-exports, -functies en -aliassen toevoegen

Omarchy wordt geleverd met een hoop ergonomische aliassen en handige functies, maar het is heel gebruikelijk om je eigen toe te willen voegen. Je moet aliassen, functies en exports allemaal toevoegen in `~/.bashrc`. Dit bestand wordt niet overschreven bij updates. Als je een van de standaardwaarden van Omarchy wilt wijzigen, kun je ze hier ook veilig toevoegen.

### Omgevingsvariabelen voor de desktop instellen

Exports voor de desktopsessie horen in `~/.config/uwsm/env.d/`. Deze bestanden draaien voordat je desktop start, dus een shellfout kan je terugsturen naar het inlogscherm. Houd een werkende terminal open terwijl je ze bewerkt. Om een override uit te schakelen, verplaats je deze uit `env.d`. Zie [inlogherstel](45-troubleshooting.md#my-password-is-accepted-but-i-return-to-the-login-screen) als een wijziging inloggen verhindert.

### Interne Omarchy-bestanden wijzigen

Kijk, dit is jouw computer. Je kunt ermee doen wat je wilt, maar ik zou je afraden om rechtstreeks wijzigingen aan te brengen in de bestanden in `/usr/share/omarchy`. Ze behoren tot het Omarchy pacman-pakket, dus je wijzigingen worden simpelweg overschreven bij de volgende update. Je kunt beter gewoon alle standaardwaarden die je niet bevallen overschrijven in de map `~/.config/*`.

Je kunt op die manier vrijwel alles wijzigen, zoals de standaardkeybindings. Bewerk gewoon `~/.config/hypr/bindings.lua` om bijvoorbeeld [Obsidian](https://obsidian.md/) te vervangen door [Joplin](https://joplinapp.org/) (installeer met `omarchy-pkg-add joplin-bin`):

```lua
o.rebind("SUPER + SHIFT + O", "Joplin", "joplin-desktop")
```

`o.rebind` verwijdert de bestaande binding voordat de vervanging wordt toegevoegd. Het neemt dezelfde argumenten als `o.bind`, inclusief launch-helpers en binding-opties. Gebruik `o.bind` om een binding toe te voegen, of `hl.unbind` om er een te verwijderen zonder deze te vervangen.

Als je erop staat om aan de interne Omarchy-bestanden te hacken, schakel dan over naar het dev-kanaal via _Update > Channel > Dev_. Dat koppelt Omarchy aan een git-checkout van de broncode in `~/omarchy`, die je naar hartenlust kunt wijzigen. Er is hier niemand die je vertelt wat je moet doen!

### Wijzigingen resetten

Als je er uiteindelijk een rommeltje van maakt met de configuraties, kun je ze altijd terugzetten naar de standaardwaarden via _Update > Config_ in het Omarchy-menu. Of door `omarchy reinstall configs` uit te voeren om alles te resetten.
