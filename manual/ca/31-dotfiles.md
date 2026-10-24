# Dotfiles

Omarchy es configura principalment mitjançant els anomenats dotfiles que viuen a `~/.config`. Aquests es consideren els teus fitxers per als teus canvis. Els fitxers que viuen a `/usr/share/omarchy` pertanyen al mateix Omarchy, i no hi hauries de remenar. Si necessites canviar alguna cosa a `/usr/share/omarchy`, hauries de sobreescriure'n el valor a `~/.config` en el seu lloc.

Les configuracions clau es poden editar directament des del menú d'Omarchy (`Super + Space`), com ara _Configuració > Monitors_, _Configuració > Dreceres de teclat_, _Configuració > Entrada_ i _Configuració > Config > [file]_. Quan ho fas d'aquesta manera, qualsevol procés que s'hagi de reiniciar després de les edicions de configuració ho farà automàticament després que surtis de l'editor (Neovim per defecte — `:wq`, recorda-ho! — però ho pots canviar mitjançant _Configuració > Per defecte > Editor_).

Aquí tens una llista dels fitxers clau a `~/.config` i què controlen:

| Fitxer                  | Finalitat              |
| ----------------------- | --------------------- |
| `~/.config/hypr/hyprland.lua` | La configuració principal de Hyprland. Carrega els valors per defecte d'Omarchy més els teus fitxers d'anul·lació de sota. [Més informació sobre les configuracions de Hyprland](https://wiki.hypr.land/Configuring/).  |
| `~/.config/hypr/bindings.lua` | Les teves pròpies dreceres de teclat i les anul·lacions dels valors per defecte. |
| `~/.config/hypr/monitors.lua` | Controla els teus monitors, la resolució i la posició. |
| `~/.config/hypr/input.lua` | Controla la disposició de teclat, el ratolí i la configuració del panell tàctil. |
| `~/.config/hypr/looknfeel.lua` | Controla les separacions, les vores, les animacions i la resta de l'aspecte. |
| `~/.config/hypr/autostart.lua` | Controla els processos addicionals que s'inicien amb la sessió. |
| `~/.config/omarchy/shell.json` | Controla l'intèrpret d'escriptori d'Omarchy: posició de la barra, disposició i ginys, a més dels temps del salvapantalles, el bloqueig i la inactivitat. |
| `~/.config/foot/foot.ini` | Controla el teu terminal (foot és el per defecte). |
| `~/.XCompose` | Defineix els emojis d'accés ràpid i l'autocompletatge de nom i correu electrònic. Assegura't d'executar `omarchy-restart-xcompose` després de fer canvis. |

Si acabes fent molts canvis per ajustar la teva pròpia configuració, és una bona idea fer una còpia de seguretat de tots aquests dotfiles. [Stow és una manera fantàstica de fer-ho](https://www.youtube.com/watch?v=NoFiYOqnC4o).

### Iniciar les teves pròpies aplicacions amb la sessió

Si vols que alguna cosa s'executi cada vegada que inicies sessió — un dimoni de sincronització, una aplicació de xat, el teu propi script —, posa-ho a `~/.config/hypr/autostart.lua`:

```lua
o.launch_on_start("my-service")
```

Això inicia l'ordre com a part de la sessió, de manera que es neteja com cal quan tornes a tancar la sessió.

### Executar scripts en esdeveniments del sistema

Omarchy dispara ganxos en un grapat de moments, i hi pots penjar els teus propis scripts. Viuen a `~/.config/omarchy/hooks/<event>.d/`, un directori per esdeveniment, i cada fitxer executable que hi hagi s'executa quan es produeix l'esdeveniment:

| Esdeveniment | Quan s'executa |
| ----- | ------------ |
| `post-boot` | Just després que l'escriptori s'hagi iniciat |
| `post-update` | Cap al final d'`omarchy update`, després dels paquets, les migracions i els reinicis de servei, abans que s'actualitzin les eines de mise |
| `pre-refresh-pacman` | Després que `omarchy refresh pacman` torni a sincronitzar la configuració de paquets, abans que actualitzi els paquets; un canvi de canal l'executa durant aquell mateix pas d'actualització |
| `theme-set` | Després d'un canvi de tema (el nom del tema a `$1`) |
| `font-set` | Després d'un canvi de tipus de lletra (el nom del tipus de lletra a `$1`) |
| `battery-low` | Quan la bateria es fa baixa (el percentatge a `$1`) |

El ganxo `pre-refresh-pacman` és on pertanyen els repositoris personalitzats o les línies `IgnorePkg`, perquè s'executa abans de la transacció de paquets. Tots dos ganxos relacionats amb l'actualització s'executen com el teu usuari després que Omarchy esborri la seva autorització sudo desada a la memòria cau, de manera que un ganxo que faci servir `sudo` necessita la seva pròpia autorització i pot demanar-te la contrasenya.

Cadascun d'aquells directoris ja conté un fitxer `.sample` que mostra la forma d'un ganxo: treu el `.sample` del nom per posar-lo a treballar. Per instal·lar un script que hagis escrit en un altre lloc, fes servir `omarchy hook install post-boot ~/my-hook`, que el copia a dins i el fa executable.

### Afegir entrades pròpies al menú

El menú d'Omarchy (`Super + Space`) es pot ampliar amb les teves pròpies files editant `~/.config/omarchy/extensions/omarchy-menu.jsonc`. Les entrades s'indexen per un identificador amb punts, i l'identificador és el que les col·loca a l'arbre, de manera que `personal` apareix al menú arrel i `personal.notes` apareix a dins seu:

```jsonc
"personal": {"icon":"","label":"Personal"},
"personal.notes": {"icon":"󰎞","label":"Notes","action":"omarchy-launch-editor ~/notes"},
```

Si reutilitzes un identificador existent, anul·les aquella fila en lloc d'afegir-ne una de nova. El fitxer ve amb tots els camps disponibles documentats com a comentaris.

### Afegir les teves pròpies exportacions, funcions i àlies de l'intèrpret d'ordres

Omarchy ve amb una pila d'àlies ergonòmics i funcions útils, però és molt habitual voler afegir els propis. Hauries d'afegir tant àlies com funcions i exportacions a `~/.bashrc`. Aquest fitxer no se sobreescriurà amb les actualitzacions. Si vols canviar algun dels valors per defecte d'Omarchy, també els hi pots afegir sense perill.

### Canviar fitxers interns d'Omarchy

Mira, aquest és el teu ordinador. Hi pots fer el que vulguis, però et desaconsellaria fer canvis directament als fitxers de `/usr/share/omarchy`. Pertanyen al paquet pacman d'Omarchy, de manera que els teus canvis simplement se sobreescriuran a la propera actualització. És millor que sobreescriguis simplement qualsevol valor per defecte que no t'agradi a la carpeta `~/.config/*` en el seu lloc.

Pots canviar gairebé tot d'aquesta manera, com les dreceres de teclat per defecte. Edita simplement `~/.config/hypr/bindings.lua` per, posem per cas, substituir [Obsidian](https://obsidian.md/) per [Joplin](https://joplinapp.org/) (instal·la'l amb `omarchy-pkg-add joplin-bin`):

```lua
o.rebind("SUPER + SHIFT + O", "Joplin", "joplin-desktop")
```

`o.rebind` elimina la drecera existent abans d'afegir-ne el substitut. Pren els mateixos arguments que `o.bind`, incloent-hi els ajudants d'inici i les opcions de drecera. Fes servir `o.bind` per afegir una drecera, o `hl.unbind` per eliminar-ne una sense substituir-la.

Si insisteixes a remenar els fitxers interns d'Omarchy, canvia al canal dev mitjançant _Actualitza > Canal > Dev_. Això enllaça Omarchy a una còpia git del codi font a `~/omarchy`, que pots canviar tant com et plagui. No hi ha ningú aquí per dir-te què has de fer!

### Restablir qualsevol canvi

Si acabes fent un embolic de les configuracions, sempre les pots revertir als valors per defecte mitjançant _Actualitza > Config_ al menú d'Omarchy. O executant `omarchy reinstall configs` per restablir-ho tot.
