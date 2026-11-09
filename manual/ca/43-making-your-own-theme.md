# Crear el teu propi tema

Pots afegir els teus propis temes a `~/.config/omarchy/themes`. Només has de copiar-ne un dels existents com a base (mira a `/usr/share/omarchy/themes`), i després retocar-lo al teu gust. Sempre que el teu tema sigui dins d'aquesta carpeta, s'inclourà al menú de selecció de temes.

El fitxer principal que has de retocar és `colors.toml`. Aquest defineix el conjunt de colors que després s'utilitza per generar les configuracions per al terminal (Foot/Alacritty/Ghostty/Kitty), btop, Chromium, Hyprland, Neovim, Helix, VSCode, Obsidian, i tot l'entorn d'Omarchy (barra superior, menú, notificacions, OSD i pantalla de bloqueig).

També pots utilitzar l'aplicació Aether inclosa per crear un tema nou amb una bonica interfície GUI per jugar amb els colors i cercar fons. Només has d'iniciar-la des de la graella d'aplicacions amb `Super + Alt + Space`.

### Què pot contenir un tema instal·lat

Un tema que escriguis tu mateix a `~/.config/omarchy/themes` pot contenir el que vulguis — és la teva màquina i el teu fitxer, i Omarchy ho aplica tot.

Un tema que instal·lis des del repositori d'algú altre amb `omarchy theme install` conserva tot el que és color, i perd el grapat de fitxers que executarien codi a la teva màquina: qualsevol fitxer `.lua`, les configuracions del terminal (`alacritty.toml`, `foot.ini`, `ghostty.conf`, `kitty.conf`) i `vscode.json`. El `hyprland.lua` d'un tema és Lua que el teu compositor executa en iniciar sessió, una configuració del terminal anomena el programa que el teu terminal inicia, i `vscode.json` anomena una extensió de VSCode per instal·lar. Instal·lar el tema d'algú hauria de canviar l'aspecte del teu escriptori, mai el que executa.

Tota la resta continua funcionant exactament com l'autor del tema ho va escriure — `btop.theme`, `chromium.theme`, `helix.toml`, `icons.theme`, `shell.toml`, els fons i les previsualitzacions es conserven tots. Només el que s'ha descartat es regenera a partir de `colors.toml` a la teva màquina.

Omarchy els distingeix segons si el tema té el seu propi repositori git a dins, que és el que `omarchy theme install` deixa enrere quan clona. Així, un tema que hagis escrit continua sent teu, i un que hagis descarregat d'internet continua sent colors.

### Mode clar

Si estàs creant un tema en mode clar, defineix `mode = "light"` a la part superior del teu `colors.toml`. Aleshores es vincularà automàticament amb el mode clar per a totes les aplicacions. (La manera antiga de deixar un fitxer buit anomenat `light.mode` a l'arrel del teu tema també continua funcionant.)

### Colors de les icones

Si vols que les icones del gestor de fitxers combinin en color amb el teu tema, afegeix un fitxer anomenat `icons.theme` amb el nom del conjunt d'icones que vulguis utilitzar. Per defecte, les opcions són: `Yaru Yaru-blue Yaru-dark Yaru-magenta Yaru-olive Yaru-prussiangreen Yaru-purple Yaru-red Yaru-sage Yaru-wartybrown Yaru-yellow`.

### Imatge de desbloqueig

Els temes subministrats amb imatges `unlock.png` i `preview-unlock.png` apareixeran a _Aparença > Desbloqueig_. El teu `unlock.png` hauria de ser preferiblement un png transparent. I pots crear la imatge de previsualització amb `omarchy plymouth preview`.

### Aplicar temes a aplicacions que Omarchy no cobreix

Si utilitzes una aplicació que no és en aquesta llista, pots ensenyar tu mateix a Omarchy a aplicar-hi un tema amb una plantilla. Deixa un fitxer a `~/.config/omarchy/themed/` amb el nom de la configuració que genera més una extensió `.tpl`, i escriu la configuració amb `{{ background }}`, `{{ foreground }}`, `{{ accent }}`, `{{ red }}`, `{{ color0 }}` fins a `{{ color15 }}`, i la resta de la paleta com a marcadors de posició. Cada vegada que canviïs de tema, el fitxer es regenera amb els colors d'aquest tema.

Hi ha un `alacritty.toml.tpl.sample` completament comentat en aquesta carpeta per copiar-lo — enumera totes les variables que pots utilitzar, a més dels modificadors `_strip` i `_rgb` per a aplicacions que volen els seus colors sense el `#` o com a RGB decimal. Les teves plantilles tenen prioritat sobre les pròpies d'Omarchy, de manera que també pots utilitzar això per substituir com s'aplica el tema a una aplicació integrada.

### Distribuir el teu tema

Si vols distribuir el teu tema perquè altres el puguin utilitzar, has de posar-lo en un servidor git públic, com GitHub. Aleshores la gent el pot instal·lar mitjançant _Instal·la > Estil > Tema_ al menú d'Omarchy utilitzant aquest URL. Es recomana que segueixis la convenció de noms `omarchy-[themename]-theme`, ja que el tema es mostrarà correctament com a només `[themename]` al menú de selecció de temes després de la instal·lació.

Aquest `[themename]` restant es converteix en el nom de directori del tema, de manera que ha de ser un que Omarchy pugui passar amb seguretat: ha de començar amb una lletra, un dígit o un guió baix, i la resta pot contenir lletres, dígits, `.`, `_`, `+` i `-`. Les majúscules es converteixen a minúscules per tu, però qualsevol altra cosa — un espai, una cometa, un caràcter no anglès — es rebutja en el moment de la instal·lació en lloc de convertir-se en un nom de directori. Així, `omarchy-tokyo-night-theme`, `omarchy-flexoki_light-theme` i `omarchy-c++-theme` s'instal·len tots sense problemes.

Recorda que una vegada instal·lat des d'un repositori, qualsevol `.lua`, configuració del terminal o `vscode.json` que inclogui es descarta, així que no construeixis el tema al voltant d'aquests.

Pots fer que el teu tema s'afegeixi a [la pàgina de temes extres](https://omarchy.org/themes/) enviant una pull request a [el repositori omarchy-site](https://github.com/omacom-io/omarchy-site).
