# Dotfiles

Omarchy es configura principalment mitjançant els anomenats dotfiles que viuen a `~/.config`. Aquests es consideren els teus fitxers per als teus canvis. Els fitxers que viuen a `/usr/share/omarchy` pertanyen al mateix Omarchy, i no hauries de tocar-los. Si necessites canviar alguna cosa a `/usr/share/omarchy`, hauries de sobreescriure el valor a `~/.config` en comptes d'això.

Les configuracions clau es poden editar directament des del menú d'Omarchy (`Super + Space`), com ara _Configuració > Assignacions de tecles_, _Configuració > Entrada_ i _Configuració > Configuració > [file]_. Quan ho fas d'aquesta manera, qualsevol procés que s'hagi de reiniciar després d'editar la configuració ho farà automàticament quan surtis de l'editor (Neovim per defecte — `:wq`, recorda-ho! — però pots canviar-ho mitjançant _Configuració > Valors per defecte > Editor_).

Aquí tens una llista dels fitxers clau de `~/.config` i què controlen:

| File                  | Purpose              |
| ----------------------- | --------------------- |
| `~/.config/hypr/hyprland.lua` | La configuració principal de Hyprland. Carrega els valors per defecte d'Omarchy més els teus fitxers de substitució de sota. [Més informació sobre les configuracions de Hyprland](https://wiki.hypr.land/Configuring/).  |
| `~/.config/hypr/bindings.lua` | Les teves pròpies assignacions de tecles i substitucions dels valors per defecte. |
| `~/.config/hypr/monitors.lua` | Ajustos del monitor que el panell del monitor no cobreix, com ara la rotació, modes addicionals o mantenir un monitor apagat. |
| `~/.config/hypr/input.lua` | Controla la disposició del teclat, el ratolí i els ajustos del panell tàctil. |
| `~/.config/hypr/looknfeel.lua` | Controla els espais, les vores, les animacions i la resta de l'aspecte. |
| `~/.config/hypr/autostart.lua` | Controla els processos addicionals que s'inicien amb la sessió. |
| `~/.config/omarchy/shell.json` | Controla la shell d'Omarchy: la posició de la barra, la disposició i els ginys, a més dels temps de l'estalvi de pantalla, el bloqueig i la inactivitat. |
| `~/.config/foot/foot.ini` | Controla el teu terminal (foot és el per defecte). |
| `~/.XCompose` | Defineix els teus emoji d'accés ràpid i l'autocompletat de nom/correu electrònic. Assegura't d'executar `omarchy-restart-xcompose` després de fer canvis. |

Si acabes fent molts canvis per ajustar la teva pròpia configuració, és una bona idea fer una còpia de seguretat de tots aquests dotfiles. [Stow és una manera fantàstica de fer-ho](https://www.youtube.com/watch?v=NoFiYOqnC4o).

### Iniciar les teves pròpies aplicacions amb la sessió

Si vols que alguna cosa s'executi cada vegada que inicies sessió — un dimoni de sincronització, una aplicació de xat, el teu propi script — posa-ho a `~/.config/hypr/autostart.lua`:

```lua
o.launch_on_start("my-service")
```

Això inicia l'ordre com a part de la sessió, de manera que es neteja correctament quan tornes a tancar la sessió.

### Executar scripts en esdeveniments del sistema

Omarchy activa hooks en un grapat de moments, i hi pots penjar els teus propis scripts. Viuen a `~/.config/omarchy/hooks/<event>.d/`, un directori per esdeveniment, i cada fitxer executable que hi hagi s'executa quan es produeix l'esdeveniment:

| Event | When it runs |
| ----- | ------------ |
| `post-boot` | Just després que l'escriptori s'hagi iniciat |
| `post-update` | Cap al final d'`omarchy update`, després dels paquets, les migracions i els reinicis de serveis, abans que s'actualitzin les eines de mise |
| `pre-refresh-pacman` | Després que `omarchy refresh pacman` torni a sincronitzar la configuració de paquets, abans que actualitzi els paquets; un canvi de canal l'executa durant aquest mateix pas de refresc |
| `theme-set` | Després d'un canvi de tema (nom del tema a `$1`) |
| `font-set` | Després d'un canvi de tipus de lletra (nom del tipus de lletra a `$1`) |
| `battery-low` | Quan la bateria està baixa (percentatge a `$1`) |

El hook `pre-refresh-pacman` és on han d'anar els repositoris personalitzats o les línies `IgnorePkg`, ja que s'executa abans de la transacció de paquets. Tots dos hooks relacionats amb les actualitzacions s'executen com el teu usuari després que Omarchy esborri la seva autorització de sudo emmagatzemada a la memòria cau, de manera que un hook que utilitzi `sudo` necessita la seva pròpia autorització i potser et demanarà la contrasenya.

Cadascun d'aquests directoris ja conté un fitxer `.sample` que mostra la forma d'un hook — treu el `.sample` del nom per posar-lo en funcionament. Per instal·lar un script que has escrit en un altre lloc, utilitza `omarchy hook install post-boot ~/my-hook`, que el copia a dins i el fa executable.

### Afegir les teves pròpies entrades de menú

El menú d'Omarchy (`Super + Space`) es pot ampliar amb les teves pròpies files editant `~/.config/omarchy/extensions/omarchy-menu.jsonc`. Les entrades es clauegen amb un id amb punts, i l'id és el que les col·loca a l'arbre, de manera que `personal` apareix al menú arrel i `personal.notes` apareix dins seu:

```jsonc
"personal": {"icon":"","label":"Personal"},
"personal.notes": {"icon":"󰎞","label":"Notes","action":"omarchy-launch-editor ~/notes"},
```

Reutilitza un id existent i substituirás aquella fila en comptes d'afegir-ne una de nova. El fitxer inclou tots els camps disponibles documentats com a comentaris.

### Afegir les teves pròpies exportacions de shell, funcions i àlies

Omarchy inclou un munt d'àlies ergonòmics i funcions útils, però és molt habitual voler afegir-hi els teus propis. Hauries d'afegir tant els àlies com les funcions i les exportacions a `~/.bashrc`. Aquest fitxer no se sobreescriurà en les actualitzacions. Si vols canviar qualsevol dels valors per defecte d'Omarchy, també els pots afegir aquí amb seguretat.

### Canviar els fitxers interns d'Omarchy

Mira, aquest és el teu ordinador. Pots fer-hi el que vulguis, però t'aconsellaria que no fessis canvis directament als fitxers de `/usr/share/omarchy`. Pertanyen al paquet pacman d'Omarchy, de manera que els teus canvis simplement se sobreescriuran en la propera actualització. Faràs millor sobreescrivint simplement qualsevol valor per defecte que no t'agradi a la carpeta `~/.config/*`.

D'aquesta manera pots canviar pràcticament tot, com ara les assignacions de tecles per defecte. Només cal que editis `~/.config/hypr/bindings.lua` per, posem per cas, substituir [Obsidian](https://obsidian.md/) per [Joplin](https://joplinapp.org/) (instal·la-ho amb `omarchy-pkg-add joplin-bin`):

```lua
o.rebind("SUPER + SHIFT + O", "Joplin", "joplin-desktop")
```

`o.rebind` elimina l'assignació existent abans d'afegir-ne la substituta. Accepta els mateixos arguments que `o.bind`, inclosos els auxiliars d'inici i les opcions d'assignació. Utilitza `o.bind` per afegir una assignació, o `hl.unbind` per eliminar-ne una sense substituir-la.

Si insisteixes a trastejar amb els fitxers interns d'Omarchy, canvia al canal dev mitjançant _Actualització > Canal > Dev_. Això enllaça Omarchy amb una còpia de treball git del codi font a `~/omarchy`, que pots canviar tant com vulguis. Aquí no hi ha ningú per dir-te què has de fer!

### Restablir qualsevol canvi

Si acabes fent un embolic amb les configuracions, sempre pots revertir-les als valors per defecte mitjançant _Actualització > Configuració_ al menú d'Omarchy. O executant `omarchy reinstall configs` per restablir-ho tot.
