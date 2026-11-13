# Crear el teu propi tema

Pots afegir els teus propis temes a `~/.config/omarchy/themes`. Només has de copiar un dels existents com a base (mira a `/usr/share/omarchy/themes`) i després retocar-lo al teu gust. Mentre el teu tema sigui dins d'aquesta carpeta, s'inclourà al menú de selecció de temes.

El fitxer principal que has de retocar és `colors.toml`. Aquest defineix el conjunt de colors que després s'utilitza per generar les configuracions del terminal (Foot/Alacritty/Ghostty/Kitty), btop, Chromium, Hyprland, Neovim, Helix, VSCode, Obsidian i de tota la shell d'Omarchy (barra superior, menú, notificacions, OSD i pantalla de bloqueig).

També pots fer servir l'aplicació Aether inclosa per crear un tema nou amb una interfície GUI encantadora per jugar amb els colors i cercar fons de pantalla. Només has d'iniciar-la des de la graella d'aplicacions amb `Super + Alt + Space`.

### Què pot contenir un tema instal·lat

Un tema que escriguis tu mateix a `~/.config/omarchy/themes` pot contenir el que vulguis: és la teva màquina i el teu fitxer, i Omarchy ho aplica tot.

Un tema que instal·lis des del repositori d'algú altre amb `omarchy theme install` conserva tot el que és color i perd el grapat de fitxers que executarien codi a la teva màquina: qualsevol fitxer `.lua`, les configuracions del terminal (`alacritty.toml`, `foot.ini`, `ghostty.conf`, `kitty.conf`) i `vscode.json`. El `hyprland.lua` d'un tema és Lua que el teu compositor executa en iniciar sessió, una configuració del terminal nomena el programa que el teu terminal inicia, i `vscode.json` nomena una extensió de VSCode per instal·lar. Instal·lar el tema d'algú altre hauria de canviar l'aspecte del teu escriptori, mai el que executa.

Tota la resta continua funcionant exactament com l'autor del tema ho va escriure: `btop.theme`, `chromium.theme`, `helix.toml`, `shell.toml`, els fons de pantalla i les previsualitzacions es conserven tots. Només el que s'ha descartat es regenera a partir de `colors.toml` a la teva màquina.

Omarchy distingeix els dos casos segons si el tema té el seu propi repositori git a dins, que és el que `omarchy theme install` deixa enrere quan clona. Així, un tema que has escrit continua sent teu, i un que has descarregat d'internet es queda en colors.

### Mode clar

Si estàs fent un tema en mode clar, estableix `mode = "light"` a la part superior del teu `colors.toml`. Aleshores s'aparellarà automàticament amb el mode clar per a totes les aplicacions. (La manera antiga de deixar un fitxer buit anomenat `light.mode` a l'arrel del teu tema també continua funcionant.)

### Imatge de desbloqueig

Els temes subministrats amb imatges `unlock.png` i `preview-unlock.png` apareixeran a _Aparença > Desbloqueig_. El teu `unlock.png` hauria de ser preferiblement un png transparent. I pots crear la imatge de previsualització amb `omarchy plymouth preview`.

### Aplicar temes a aplicacions que Omarchy no cobreix

Si fas servir una aplicació que no és en aquesta llista, pots ensenyar a Omarchy a aplicar-li el tema tu mateix amb una plantilla. Deixa un fitxer a `~/.config/omarchy/themed/` amb el nom de la configuració que genera més una extensió `.tpl`, i escriu la configuració amb `{{ background }}`, `{{ foreground }}`, `{{ accent }}`, `{{ red }}`, `{{ color0 }}` fins a `{{ color15 }}`, i la resta de la paleta com a marcadors de posició. Cada vegada que canviïs de tema, el fitxer es regenerarà amb els colors d'aquest tema.

Hi ha un `alacritty.toml.tpl.sample` completament comentat en aquesta carpeta perquè el copiïs: enumera totes les variables que pots fer servir, a més dels modificadors `_strip` i `_rgb` per a aplicacions que volen els seus colors sense el `#` o com a RGB decimal. Les teves plantilles tenen prioritat sobre les d'Omarchy, de manera que també pots fer servir això per anul·lar com s'aplica el tema a una aplicació integrada.

### Distribuir el teu tema

Si vols distribuir el teu tema perquè altres el puguin fer servir, l'has de posar en un servidor git públic, com GitHub. Aleshores la gent el podrà instal·lar amb _Instal·la > Estil > Tema_ al menú d'Omarchy fent servir aquesta URL. Es recomana que segueixis la convenció de noms `omarchy-[themename]-theme`, ja que el tema es mostrarà correctament com a només `[themename]` al menú de selecció de temes després de la instal·lació.

Aquest `[themename]` restant es converteix en el nom del directori del tema, de manera que ha de ser un que Omarchy pugui passar d'una banda a l'altra amb seguretat: ha de començar amb una lletra, un dígit o un guió baix, i la resta pot contenir lletres, dígits, `.`, `_`, `+` i `-`. Les majúscules es passen a minúscules per tu, però qualsevol altra cosa —un espai, una cometa, un caràcter no anglès— es rebutja en el moment de la instal·lació en lloc de convertir-se en un nom de directori. Així doncs, `omarchy-tokyo-night-theme`, `omarchy-flexoki_light-theme` i `omarchy-c++-theme` s'instal·len tots sense problemes.

Recorda que, un cop instal·lat des d'un repositori, qualsevol `.lua`, configuració del terminal o `vscode.json` que inclogui es descarta, així que no construeixis el tema al voltant d'aquests.

Pots fer que el teu tema s'afegeixi a [la pàgina de temes addicionals](https://omarchy.org/themes/) enviant una pull request a [el repositori omarchy-site](https://github.com/omacom-io/omarchy-site).
