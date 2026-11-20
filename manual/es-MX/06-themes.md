# Temas

Omarchy viene con veintidós temas hermosos. Puedes elegir entre ellos a través de _Apariencia > Tema_ en el Menú de Omarchy (`Super + Space`) o saltar directamente al selector de temas usando `Super + Ctrl + T`.

Cada tema da estilo al escritorio, la terminal, neovim, la pantalla de actividad (btop), Chromium y a toda la interfaz de Omarchy: barra superior, menú, notificaciones, OSD y la pantalla de bloqueo. (Para Obsidian, debes seleccionar manualmente el tema de Omarchy a través de _Apariencia > Temas_ dentro de la app).

Los temas tienen un conjunto de imágenes de fondo entre las que puedes elegir usando `Super + Ctrl + W`.

Puedes encontrar aún más temas en [la página de temas extra](https://omarchy.org/themes/) o incluso [crear tu propio tema](43-making-your-own-theme.md).

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

### Íconos de aplicaciones

Los íconos en el lanzador de aplicaciones y el dock se dibujan con los colores de tu tema, así que cambian junto con él. Provienen de un conjunto de íconos, que eliges por separado del tema en _Apariencia > Íconos_, a partir de vistas previas de cada conjunto, de la misma forma en que eliges un tema:

- _Papercraft_ es el predeterminado: todo lo que viene instalado, dibujado en un solo estilo. Las apps conocidas por su logo, como Chrome, HEY o YouTube, mantienen su forma y adoptan los colores del tema.
- _Arcade_ dibuja las mismas apps como arte de píxeles de 8 bits, como lo haría una consola de videojuegos antigua.
- _Original_ muestra cada app con el ícono que le dio su creador.

Puedes instalar un conjunto de íconos que alguien más haya creado con _Instalar > Estilo > Íconos_ (o `omarchy icons install <git url>`), y eliminarlo de nuevo en _Eliminar > Íconos_. _Actualizar > Íconos extra_ obtiene la versión más reciente de los conjuntos que tienes instalados.

Para crear el tuyo, coloca tus íconos en `~/.config/omarchy/icons/<name>/`, un archivo por app, nombrado según la línea `Icon=` del archivo `.desktop` de la app. Un archivo que termina en `.svg` se muestra tal como está. Un archivo que termina en `.svg.tpl` se dibuja con los colores del tema: escribe `{{ icon_main }}`, `{{ icon_mark }}`, `{{ icon_paper }}`, `{{ icon_body }}`, `{{ icon_edge }}`, `{{ icon_ink }}` o `{{ icon_shadow }}` donde va un color. El conjunto predeterminado en `/usr/share/omarchy/icons/papercraft/` es un buen punto de partida. Agrega un `preview.png` para mostrar tu conjunto en el selector; sin uno, Omarchy dibuja una vista previa a partir de tus íconos. Para cambiar un solo ícono del conjunto predeterminado, coloca tu versión en `~/.config/omarchy/icons/papercraft/`.

### Desbloqueos

Los temas también pueden tener un diseño de desbloqueo personalizado, que se usa para el proceso de descifrado durante el arranque. Puedes seleccionar uno de estos en _Apariencia > Desbloqueo_. Se ven así:

 ![catppuccin](../themes/catppuccin/preview-unlock.png)
_Catppuccin_

 ![catppuccin-latte](../themes/catppuccin-latte/preview-unlock.png)
_Catppuccin Latte_

 ![ethereal](../themes/ethereal/preview-unlock.png)
_Ethereal_

 ![everforest](../themes/everforest/preview-unlock.png)
_Everforest_

 ![flexoki-light](../themes/flexoki-light/preview-unlock.png)
_Flexoki Light_

 ![gruvbox](../themes/gruvbox/preview-unlock.png)
_Gruvbox_

 ![hackerman](../themes/hackerman/preview-unlock.png)
_Hackerman_

 ![jade-horse](../themes/jade-horse/preview-unlock.png)
_Jade Horse_

 ![kanagawa](../themes/kanagawa/preview-unlock.png)
_Kanagawa_

 ![lumon](../themes/lumon/preview-unlock.png)
_Lumon_

 ![matte-black](../themes/matte-black/preview-unlock.png)
_Matte Black_

![miasma](../themes/miasma/preview-unlock.png)
_Miasma_

 ![nord](../themes/nord/preview-unlock.png)
_Nord_

 ![retro-82](../themes/retro-82/preview-unlock.png)
_Retro 82_

 ![ristretto](../themes/ristretto/preview-unlock.png)
_Ristretto_

![rose-pine](../themes/rose-pine/preview-unlock.png)
_Rose Pine_

 ![tokyo-night](../themes/tokyo-night/preview-unlock.png)
_Tokyo Night_

 ![vantablack](../themes/vantablack/preview-unlock.png)
_Vantablack_

 ![white](../themes/white/preview-unlock.png)
_White_
