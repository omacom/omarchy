# Temes

Omarchy inclou vint-i-tres temes preciosos. Pots triar entre ells a través d'_Appearance > Theme_ a l'Omarchy Menu (`Super + Space`) o saltar directament al selector de temes fent servir `Super + Ctrl + T`.

Cada tema aplica l'estil a l'escriptori, el terminal, neovim, la pantalla d'activitat (btop), el teu navegador (Chrome, Chromium, Edge o Brave) i a tota la shell d'Omarchy: la barra superior, el menú, les notificacions, l'OSD i la pantalla de bloqueig. (Per a Obsidian, has de seleccionar manualment el tema d'Omarchy a través d'_Appearance > Themes_ dins de l'aplicació).

Els temes tenen un conjunt d'imatges de fons entre les quals pots triar fent servir `Super + Ctrl + W`.

Pots trobar encara més temes a [la pàgina de temes extra](https://omarchy.org/themes/) o fins i tot [crear el teu propi tema](43-making-your-own-theme.md).

 ![tokyo-night](../themes/tokyo-night/preview.png)
_Tokyo Night_

 ![catppuccin](../themes/catppuccin/preview.png)
_Catppuccin_

 ![lumon](../themes/lumon/preview.png)
_Lumon_

 ![ethereal](../themes/ethereal/preview.png)
_Ethereal_

 ![everforest](../themes/everforest/preview.png)
_Everforest_

 ![gruvbox](../themes/gruvbox/preview.png)
_Gruvbox_

 ![miasma](../themes/miasma/preview.png)
_Miasma_

 ![hackerman](../themes/hackerman/preview.png)
_Hackerman_

 ![jade-horse](../themes/jade-horse/preview.png)
_Jade Horse_

 ![kanagawa](../themes/kanagawa/preview.png)
_Kanagawa_

 ![nord](../themes/nord/preview.png)
_Nord_

 ![matte-black](../themes/matte-black/preview.png)
_Matte Black_

 ![vantablack](../themes/vantablack/preview.png)
_Vantablack_

 ![ristretto](../themes/ristretto/preview.png)
_Ristretto_

 ![retro-82](../themes/retro-82/preview.png)
_Retro 82_

 ![flexoki-light](../themes/flexoki-light/preview.png)
_Flexoki Light_

 ![rose-pine](../themes/rose-pine/preview.png)
_Rose Pine_

 ![catppuccin-latte](../themes/catppuccin-latte/preview.png)
_Catppuccin Latte_

 ![white](../themes/white/preview.png)
_White_

 ![last-horizon](../themes/last-horizon/preview.png)
_Last Horizon_

 ![lupine](../themes/lupine/preview.png)
_Lupine_

 ![solitude](../themes/solitude/preview.png)
_Solitude_

 ![starship](../themes/starship/preview.png)
_Starship_

### Icones de les aplicacions

Les icones del llançador d'aplicacions i del dock es dibuixen amb els colors del teu tema, de manera que canvien juntament amb ell. Provenen d'un conjunt d'icones, que tries per separat del tema a _Appearance > Icons_, a partir de vistes prèvies de cada conjunt, de la mateixa manera que tries un tema:

- _Papercraft_ és el predeterminat: tot el que ve instal·lat, dibuixat amb un sol estil. Les aplicacions conegudes pel seu logotip, com Chrome, HEY o YouTube, conserven la seva forma i adopten els colors del tema.
- _Arcade_ dibuixa les mateixes aplicacions com a pixel art de 8 bits, com ho faria una consola de jocs antiga.
- _Original_ mostra cada aplicació amb la icona que li va donar el seu creador.

Pots instal·lar un conjunt d'icones que hagi creat algú altre amb _Install > Style > Icons_ (o `omarchy icons install <git url>`), i eliminar-lo de nou a _Remove > Icons_. _Update > Extra Icons_ obté la versió més recent dels conjunts que tens instal·lats.

Per crear el teu propi conjunt, posa les teves icones a `~/.config/omarchy/icons/<name>/`, un fitxer per aplicació, amb el nom de la línia `Icon=` del fitxer `.desktop` de l'aplicació. Un fitxer que acaba en `.svg` es mostra tal com és. Un fitxer que acaba en `.svg.tpl` es dibuixa amb els colors del tema: escriu `{{ icon_main }}`, `{{ icon_mark }}`, `{{ icon_paper }}`, `{{ icon_body }}`, `{{ icon_edge }}`, `{{ icon_ink }}` o `{{ icon_shadow }}` on va un color. El conjunt predeterminat a `/usr/share/omarchy/icons/papercraft/` és un bon lloc per començar. Afegeix un `preview.png` per mostrar el teu conjunt al selector; sense un, Omarchy dibuixa una vista prèvia a partir de les teves icones. Per canviar una sola icona del conjunt predeterminat, posa la teva versió a `~/.config/omarchy/icons/papercraft/`.

### Arrencada i inici de sessió

La pantalla que demana la contrasenya de la teva unitat quan l'ordinador s'inicia, i la pantalla d'inici de sessió, també segueixen el tema. Cada vegada que canvies de tema, adopten el seu fons, el seu text, el seu color d'accent i els seus colors vermells, de manera que no hi ha cap disseny de desbloqueig separat per triar. Als Mac amb Apple Silicon, la pantalla de contrasenya de la unitat conserva l'aspecte predeterminat d'Omarchy sigui quin sigui el tema.
