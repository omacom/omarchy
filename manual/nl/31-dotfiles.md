# Dotfiles

Omarchy wordt voornamelijk geconfigureerd via de zogenaamde dotfiles die in `~/.config` leven. Die worden beschouwd als jouw bestanden voor jouw wijzigingen. De bestanden die in `/usr/share/omarchy` leven behoren tot Omarchy zelf, en daar moet je niet aan knoeien. Als je iets in `/usr/share/omarchy` moet wijzigen, moet je in plaats daarvan de waarde in `~/.config` overschrijven.

De belangrijkste configuraties kunnen direct vanuit het Omarchy-menu (`Super + Space`) worden bewerkt, zoals _Instellen > Monitoren_, _Instellen > Sneltoetsen_, _Instellen > Invoer_ en _Instellen > Configuratie > [file]_. Wanneer je het op deze manier doet, wordt elk proces dat na configuratiewijzigingen automatisch moet worden herstart dat ook nadat je de editor afsluit (Neovim standaard — `:wq`, onthoud! — maar je kunt dat wijzigen via _Instellen > Standaardwaarden > Editor_).

Hier is een lijst van de belangrijkste bestanden in `~/.config` en wat ze beheren:

| File                  | Purpose              |
| ----------------------- | --------------------- |
| `~/.config/hypr/hyprland.lua` | De hoofd-Hyprland-configuratie. Laadt de Omarchy-standaardwaarden plus je override-bestanden hieronder. [Lees meer over Hyprland-configuraties](https://wiki.hypr.land/Configuring/).  |
| `~/.config/hypr/bindings.lua` | Je eigen sneltoetsen en overrides van de standaardwaarden. |
| `~/.config/hypr/monitors.lua` | Beheert je monitoren, resolutie en positie. |
| `~/.config/hypr/input.lua` | Beheert je toetsenbordindeling, muis- en touchpadinstellingen. |
| `~/.config/hypr/looknfeel.lua` | Beheert afstanden, randen, animaties en de rest van het uiterlijk. |
| `~/.config/hypr/autostart.lua` | Beheert extra processen die met de sessie worden gestart. |
| `~/.config/omarchy/shell.json` | Beheert de Omarchy-shell: balkpositie, indeling en widgets, plus schermbeveiliging-, vergrendel- en idle-timingen. |
| `~/.config/foot/foot.ini` | Beheert je terminal (foot is de standaard). |
| `~/.XCompose` | Definieert je sneltoegankelijke emoji en naam/e-mail autocomplete. Zorg ervoor dat je `omarchy-restart-xcompose` uitvoert na het aanbrengen van wijzigingen. |

Als je uiteindelijk veel wijzigingen aanbrengt om je eigen setup aan te passen, is het een goed idee om al deze dotfiles te back-uppen. [Stow is een geweldige manier om dat te doen](https://www.youtube.com/watch?v=NoFiYOqnC4o).

### Je eigen apps met de sessie starten

Als je wilt dat iets elke keer draait wanneer je inlogt — een sync-daemon, een chatapp, je eigen script — zet het dan in `~/.config/hypr/autostart.lua`:

```lua
o.launch_on_start("my-service")
```

Dat start het commando als onderdeel van de sessie, zodat het netjes wordt opgeruimd wanneer je weer uitlogt.

### Scripts uitvoeren bij systeemgebeurtenissen

Omarchy vuurt hooks af op een handvol momenten, en je kunt je eigen scripts eraan hangen. Ze leven in `~/.config/omarchy/hooks/<event>.d/`, één map per gebeurtenis, en elk uitvoerbaar bestand daarin draait wanneer de gebeurtenis plaatsvindt:

| Event | When it runs |
| ----- | ------------ |
| `post-boot` | Direct nadat het bureaublad is gestart |
| `post-update` | Tegen het einde van `omarchy update`, na pakketten, migraties en service-herstarts, voordat mise-tools worden bijgewerkt |
| `pre-refresh-pacman` | Nadat `omarchy refresh pacman` de pakketconfiguratie opnieuw synchroniseert, voordat het pakketten bijwerkt; een kanaalwissel voert het uit tijdens diezelfde refresh-stap |
| `theme-set` | Na een themawijziging (themanaam in `$1`) |
| `font-set` | Na een lettertypewijziging (lettertypenaam in `$1`) |
| `battery-low` | Wanneer de batterij bijna leeg is (percentage in `$1`) |

De `pre-refresh-pacman`-hook is waar aangepaste repositories of `IgnorePkg`-regels thuishoren, aangezien deze vóór de pakkettransactie draait. Beide update-gerelateerde hooks draaien als je gebruiker nadat Omarchy zijn gecachte sudo-autorisatie heeft gewist, dus een hook die `sudo` gebruikt heeft zijn eigen autorisatie nodig en kan om je wachtwoord vragen.

Elk van die mappen bevat al een `.sample`-bestand dat de vorm van een hook toont — haal de `.sample` van de naam af om hem aan het werk te zetten. Om een script te installeren dat je elders hebt geschreven, gebruik je `omarchy hook install post-boot ~/my-hook`, wat het kopieert en uitvoerbaar maakt.

### Je eigen menu-items toevoegen

Het Omarchy-menu (`Super + Space`) kan worden uitgebreid met je eigen rijen door `~/.config/omarchy/extensions/omarchy-menu.jsonc` te bewerken. Items worden gesleuteld door een gestippelde id, en de id is wat ze in de boom plaatst, dus `personal` verschijnt in het hoofdmenu en `personal.notes` verschijnt erin:

```jsonc
"personal": {"icon":"","label":"Personal"},
"personal.notes": {"icon":"󰎞","label":"Notes","action":"omarchy-launch-editor ~/notes"},
```

Hergebruik een bestaande id en je overschrijft die rij in plaats van een nieuwe toe te voegen. Het bestand wordt geleverd met alle beschikbare velden gedocumenteerd als commentaar.

### Je eigen shell-exports, functies en aliassen toevoegen

Omarchy wordt geleverd met een heleboel ergonomische aliassen en handige functies, maar het is heel gebruikelijk om je eigen te willen toevoegen. Je moet zowel aliassen, functies als exports toevoegen in `~/.bashrc`. Dit bestand wordt bij updates niet overschreven. Als je een van de Omarchy-standaardwaarden wilt wijzigen, kun je ze ook veilig hier toevoegen.

### Interne Omarchy-bestanden wijzigen

Kijk, dit is jouw computer. Je kunt ermee doen wat je wilt, maar ik zou afraden om wijzigingen direct aan te brengen in de bestanden in `/usr/share/omarchy`. Ze behoren tot het Omarchy pacman-pakket, dus je wijzigingen worden bij de volgende update eenvoudig overschreven. Je kunt beter gewoon alle standaardwaarden die je niet bevallen overschrijven in de map `~/.config/*`.

Je kunt op die manier vrijwel alles wijzigen, zoals de standaard sneltoetsen. Bewerk gewoon `~/.config/hypr/bindings.lua` om bijvoorbeeld [Obsidian](https://obsidian.md/) te vervangen door [Joplin](https://joplinapp.org/) (installeer met `omarchy-pkg-add joplin-bin`):

```lua
o.rebind("SUPER + SHIFT + O", "Joplin", "joplin-desktop")
```

`o.rebind` verwijdert de bestaande binding voordat de vervanging wordt toegevoegd. Het neemt dezelfde argumenten als `o.bind`, inclusief launch-helpers en binding-opties. Gebruik `o.bind` om een binding toe te voegen, of `hl.unbind` om er een te verwijderen zonder deze te vervangen.

Als je erop staat om aan de interne Omarchy-bestanden te hacken, schakel dan over naar het dev-kanaal via _Bijwerken > Channel > Dev_. Dat koppelt Omarchy aan een git-checkout van de broncode in `~/omarchy`, die je naar hartenlust kunt wijzigen. Er is hier niemand om je te vertellen wat je moet doen!

### Eventuele wijzigingen resetten

Als je uiteindelijk een puinhoop maakt van de configuraties, kun je ze altijd terugzetten naar de standaardwaarden via _Bijwerken > Config_ in het Omarchy-menu. Of door `omarchy reinstall configs` uit te voeren om alles te resetten.
