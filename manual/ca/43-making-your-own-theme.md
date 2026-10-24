# Crear el teu propi tema

Pots afegir els teus propis temes a `~/.config/omarchy/themes`. Només cal que copiïs un dels existents com a base (mira a `/usr/share/omarchy/themes`) i després l'ajustis fins a deixar-lo al teu gust. Mentre el teu tema sigui dins d'aquesta carpeta, quedarà inclòs al menú de selecció de temes.

El fitxer principal que has d'ajustar és `colors.toml`. Aquest defineix el conjunt de colors que després es fa servir per generar configuracions per al terminal (Foot/Alacritty/Ghostty/Kitty), btop, Chromium, Hyprland, Neovim, Helix, VSCode, Obsidian i tota la shell d'Omarchy (barra superior, menú, notificacions, OSD i pantalla de bloqueig).

També pots fer servir l'aplicació Aether inclosa per crear un tema nou fent servir una interfície gràfica preciosa per jugar amb els colors i cercar fons. Només cal que l'engeguis des de la graella d'aplicacions amb `Super + Alt + Space`.

### Què pot contenir un tema instal·lat

Un tema que escrivis tu mateix a `~/.config/omarchy/themes` pot contenir el que vulguis: és la teva màquina i el teu fitxer, i Omarchy ho aplica tot.

Un tema que instal·les des del dipòsit d'algú altre amb `omarchy theme install` conserva tot el que és color i perd el grapat de fitxers que executarien codi a la teva màquina: qualsevol fitxer `.lua`, les configuracions de terminal (`alacritty.toml`, `foot.ini`, `ghostty.conf`, `kitty.conf`) i `vscode.json`. L'`hyprland.lua` d'un tema és Lua que el teu compositor executa en iniciar sessió, una configuració de terminal anomena el programa que el teu terminal engega, i `vscode.json` anomena una extensió de VSCode per instal·lar. Instal·lar el tema d'algú hauria de canviar l'aspecte del teu escriptori, mai el que executa.

La resta continua funcionant exactament com l'autor del tema ho va escriure: `btop.theme`, `chromium.theme`, `helix.toml`, `icons.theme`, `shell.toml`, els fons i les previsualitzacions es conserven tots. Només el que s'ha descartat es regenera a partir de `colors.toml` a la teva màquina.

Omarchy distingeix l'un de l'altre segons si el tema té el seu propi dipòsit git a dins, que és el que `omarchy theme install` deixa enrere quan clona. D'aquesta manera, un tema que has escrit continua sent teu, i un que has tret d'internet continua sent colors.

### Mode clar

Si estàs creant un tema en mode clar, posa `mode = "light"` a la part superior del teu `colors.toml`. Aleshores es vincularà automàticament amb el mode clar per a totes les aplicacions. (La manera antiga de deixar caure un fitxer buit anomenat `light.mode` a l'arrel del teu tema també continua funcionant.)

### Colors de les icones

Si vols fer coincidir el color de les icones del gestor de fitxers amb el teu tema, afegeix un fitxer anomenat `icons.theme` amb el nom del conjunt d'icones que vols fer servir. Per defecte, les opcions són: `Yaru Yaru-blue Yaru-dark Yaru-magenta Yaru-olive Yaru-prussiangreen Yaru-purple Yaru-red Yaru-sage Yaru-wartybrown Yaru-yellow`.

### Imatge de desbloqueig

Els temes subministrats amb les imatges `unlock.png` i `preview-unlock.png` apareixeran a _Estil > Desbloqueja_. El teu `unlock.png` hauria de ser preferiblement un png transparent. I pots crear la imatge de previsualització fent servir `omarchy plymouth preview`.

### Tematitzar aplicacions que Omarchy no cobreix

Si fas servir una aplicació que no és en aquesta llista, pots ensenyar tu mateix a Omarchy a tematitzar-la amb una plantilla. Deixa un fitxer a `~/.config/omarchy/themed/` amb el nom de la configuració que genera més una extensió `.tpl`, i escriu la configuració amb `{{ background }}`, `{{ foreground }}`, `{{ accent }}`, `{{ red }}`, des de `{{ color0 }}` fins a `{{ color15 }}`, i la resta de la paleta com a marcadors de posició. Cada vegada que canvies de tema, el fitxer es regenera amb els colors d'aquell tema.

En aquesta carpeta hi ha un `alacritty.toml.tpl.sample` completament comentat del qual pots copiar: hi apareixen totes les variables que pots fer servir, més els modificadors `_strip` i `_rgb` per a les aplicacions que volen els seus colors sense el `#` o com a RGB decimals. Les teves plantilles tenen prioritat sobre les del mateix Omarchy, de manera que també pots fer servir això per substituir la manera com es tematitza una aplicació integrada.

### Distribuir el teu tema

Si vols distribuir el teu tema perquè altres el puguin fer servir, l'has de posar en un servidor git públic, com GitHub. Aleshores la gent el pot instal·lar fent servir _Instal·la > Estil > Tema_ al menú d'Omarchy fent servir aquesta URL. Es recomana que segueixis la convenció de noms d'`omarchy-[themename]-theme`, perquè el tema es mostrarà correctament només com a `[themename]` al menú de selecció de temes després de la instal·lació.

Aquest `[themename]` restant es converteix en el nom de directori del tema, de manera que ha de ser un nom que Omarchy pugui passar-se d'una banda a l'altra amb seguretat: ha de començar per una lletra, un dígit o un guió baix, i la resta pot contenir lletres, dígits, `.`, `_`, `+` i `-`. Les majúscules es passen a minúscula per tu, però qualsevol altra cosa —un espai, una cometa, un caràcter no anglès— es rebutja en el moment de la instal·lació en comptes de convertir-se en un nom de directori. D'aquesta manera, `omarchy-tokyo-night-theme`, `omarchy-flexoki_light-theme` i `omarchy-c++-theme` s'instal·len tots sense problemes.

Recorda que, un cop instal·lat des d'un dipòsit, qualsevol `.lua`, configuració de terminal o `vscode.json` que inclogui es descarta, de manera que no construeixis el tema al seu voltant.

Pots fer que el teu tema s'afegeixi a [la pàgina de temes extra](https://omarchy.org/themes/) enviant una sol·licitud d'extracció al [dipòsit omarchy-site](https://github.com/omacom-io/omarchy-site).
