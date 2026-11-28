# Fer el teu propi tema

Pots afegir els teus propis temes a `~/.config/omarchy/themes`. Només has de copiar-ne un dels existents com a base (mira a `/usr/share/omarchy/themes`), després retoca'l al teu gust. Sempre que el teu tema sigui dins d'aquesta carpeta, s'inclourà al menú de selecció de temes.

El fitxer principal que has de retocar és `colors.toml`. Aquest defineix el conjunt de colors que després s'utilitza per generar configuracions per al terminal (Foot/Alacritty/Ghostty/Kitty), btop, Chromium, Hyprland, Neovim, Helix, VSCode, Obsidian, les aplicacions Qt, la retroil·luminació del teclat, el mètode d'entrada, el selector de compartició de pantalla, les icones d'aplicacions, diverses eines d'IA (Claude, Pi, Hermes, T3 Code, Herdr) i tot el shell d'Omarchy (barra superior, menú, notificacions, OSD i pantalla de bloqueig).

També pots fer servir l'aplicació inclosa Aether per crear un tema nou amb una interfície GUI preciosa per jugar amb els colors i cercar fons. Només has d'iniciar-la des de la graella d'aplicacions amb `Super + Alt + Space`.

### Què pot contenir un tema instal·lat

Un tema que escrius tu mateix a `~/.config/omarchy/themes` pot contenir el que vulguis: és la teva màquina i el teu fitxer, i Omarchy ho aplica tot.

Un tema que instal·les des del repositori d'una altra persona amb `omarchy theme install` conserva tot el que és color i perd el grapat de fitxers que executarien codi a la teva màquina: qualsevol fitxer `.lua`, les configuracions de terminal (`alacritty.toml`, `foot.ini`, `ghostty.conf`, `kitty.conf`) i `vscode.json`. El `hyprland.lua` d'un tema és Lua que el teu compositor executa en iniciar sessió, una configuració de terminal indica el programa que inicia el teu terminal, i `vscode.json` indica una extensió de VSCode per instal·lar. Instal·lar el tema d'algú hauria de canviar l'aspecte del teu escriptori, mai no el que executa.

Tota la resta continua funcionant exactament com ho va escriure l'autor del tema: `btop.theme`, `chromium.theme`, `helix.toml`, `shell.toml`, els fons i les previsualitzacions es conserven tots. Només el que s'ha descartat es regenera a partir de `colors.toml` a la teva màquina.

Omarchy els distingeix segons si el tema té el seu propi repositori git a dins, que és el que `omarchy theme install` deixa enrere quan el clona. Així, un tema que has escrit continua sent teu, i un que has descarregat d'internet continua sent només colors.

### Mode clar

Si estàs fent un tema en mode clar, defineix `mode = "light"` a la part superior del teu `colors.toml`. Llavors es vincularà automàticament amb el mode clar per a totes les aplicacions. (La manera antiga de deixar un fitxer buit anomenat `light.mode` a l'arrel del tema també continua funcionant.)

### Imatge de desbloqueig

Els temes proporcionats amb les imatges `unlock.png` i `preview-unlock.png` apareixeran a _Aparença > Desbloqueig_. El teu `unlock.png` hauria de ser preferiblement un png transparent. I pots crear la imatge de previsualització amb `omarchy plymouth preview`.

### Tematitzar aplicacions que Omarchy no cobreix

Si utilitzes una aplicació que no és en aquesta llista, pots ensenyar a Omarchy a tematitzar-la tu mateix amb una plantilla. Deixa un fitxer a `~/.config/omarchy/themed/` amb el nom de la configuració que genera més una extensió `.tpl`, i escriu la configuració amb `{{ background }}`, `{{ foreground }}`, `{{ accent }}`, `{{ red }}`, `{{ color0 }}` fins a `{{ color15 }}`, i la resta de la paleta com a marcadors de posició. Cada vegada que canvies de tema, el fitxer es regenera amb els colors d'aquell tema.

Hi ha un `alacritty.toml.tpl.sample` totalment comentat en aquesta carpeta del qual pots copiar: enumera totes les variables que pots utilitzar, a més dels modificadors `_strip` i `_rgb` per a les aplicacions que volen els seus colors sense el `#` o com a RGB decimal. Les teves plantilles tenen prioritat sobre les d'Omarchy, de manera que també pots utilitzar això per substituir la manera com es tematitza una aplicació integrada.

### Distribuir el teu tema

Si vols distribuir el teu tema perquè altres el puguin utilitzar, has de posar-lo en un servidor git públic, com GitHub. Després, la gent el podrà instal·lar mitjançant _Instal·lar > Estil > Tema_ al menú d'Omarchy utilitzant aquesta URL. Es recomana que segueixis la convenció de noms `omarchy-[themename]-theme`, ja que el tema es mostrarà correctament només com a `[themename]` al menú de selecció de temes després de la instal·lació.

Aquest `[themename]` restant es converteix en el nom del directori del tema, de manera que ha de ser un que Omarchy pugui gestionar amb seguretat: ha de començar amb una lletra, un dígit o un guió baix, i la resta pot contenir lletres, dígits, `.`, `_`, `+` i `-`. Les majúscules es passen a minúscules per tu, però qualsevol altra cosa —un espai, una cometa, un caràcter no anglès— es rebutja en el moment de la instal·lació en lloc de convertir-se en un nom de directori. Així, `omarchy-tokyo-night-theme`, `omarchy-flexoki_light-theme` i `omarchy-c++-theme` s'instal·len tots sense problemes.

Recorda que, una vegada instal·lat des d'un repositori, qualsevol `.lua`, configuració de terminal o `vscode.json` que inclogui es descarta, així que no construeixis el tema al voltant d'aquests.

Pots fer que el teu tema s'afegeixi a [la pàgina de temes addicionals](https://omarchy.org/themes/) enviant una pull request a [el repositori omarchy-site](https://github.com/omacom-io/omarchy-site).
