# Temas

Omarchy viene con veintitrés temas hermosos. Puedes elegir entre ellos desde _Apariencia > Tema_ en el menú de Omarchy (`Super + Space`) o ir directo al selector de temas con `Super + Ctrl + T`.

Cada tema le da estilo al escritorio, la terminal, neovim, la pantalla de actividad (btop), tu navegador (Chrome, Chromium, Edge o Brave) y toda la interfaz de Omarchy: barra superior, menú, notificaciones, OSD y pantalla de bloqueo. (En Obsidian, debes seleccionar el tema de Omarchy manualmente desde _Apariencia > Temas_ dentro de la app).

Los temas tienen un conjunto de imágenes de fondo entre las que puedes elegir con `Super + Ctrl + W`.

Puedes encontrar todavía más temas en [la página de temas extra](https://omarchy.org/themes/) o incluso [crear tu propio tema](43-making-your-own-theme.md).

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

### Íconos de aplicaciones

Los íconos del lanzador de aplicaciones y el dock se dibujan con los colores de tu tema, así que cambian junto con él. Vienen de un conjunto de íconos, que eliges por separado del tema desde _Apariencia > Íconos_, a partir de las vistas previas de cada conjunto, igual que eliges un tema:

- _Papercraft_ es el predeterminado: todo lo que viene instalado, dibujado con un mismo estilo. Las apps que se reconocen por su logotipo, como Chrome, HEY o YouTube, conservan su forma y adoptan los colores del tema.
- _Arcade_ dibuja las mismas apps como arte de píxeles de 8 bits, como lo haría una consola de juegos antigua.
- _Original_ muestra cada app con el ícono que le dio su creador.

Puedes instalar un conjunto de íconos que haya creado otra persona desde _Instalar > Estilo > Íconos_ (o con `omarchy icons install <git url>`), y eliminarlo de nuevo desde _Eliminar > Íconos_. _Actualizar > Íconos extra_ descarga la versión más reciente de los conjuntos que tengas instalados.

Para crear el tuyo, pon tus íconos en `~/.config/omarchy/icons/<name>/`, un archivo por app, con el nombre indicado en la línea `Icon=` del archivo `.desktop` de la app. Un archivo que termina en `.svg` se muestra tal cual. Un archivo que termina en `.svg.tpl` se dibuja con los colores del tema: escribe `{{ icon_main }}`, `{{ icon_mark }}`, `{{ icon_paper }}`, `{{ icon_body }}`, `{{ icon_edge }}`, `{{ icon_ink }}` o `{{ icon_shadow }}` donde va un color. El conjunto predeterminado en `/usr/share/omarchy/icons/papercraft/` es un buen punto de partida. Agrega un `preview.png` para mostrar tu conjunto en el selector; si no lo agregas, Omarchy dibuja una vista previa a partir de tus íconos. Para cambiar un solo ícono del conjunto predeterminado, pon tu versión en `~/.config/omarchy/icons/papercraft/`.

### Arranque e inicio de sesión

La pantalla que te pide la contraseña de tu disco cuando arranca la computadora, y la pantalla de inicio de sesión, también siguen el tema. Cada vez que cambias de tema, adoptan sus colores de fondo, texto, acento y rojo, así que no hay un diseño de desbloqueo aparte que elegir. En las Mac con Apple Silicon, la pantalla de contraseña del disco mantiene el aspecto predeterminado de Omarchy sea cual sea el tema.
