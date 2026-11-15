# Temas

Omarchy viene con veintidós temas hermosos. Puedes elegir entre ellos desde _Apariencia > Tema_ en el Menú de Omarchy (`Super + Space`) o ir directo al selector de temas con `Super + Ctrl + T`.

Cada tema aplica su estilo al escritorio, la terminal, neovim, la pantalla de actividad (btop), Chromium y todo el shell de Omarchy: la barra superior, el menú, las notificaciones, el OSD y la pantalla de bloqueo. (En Obsidian, debes seleccionar manualmente el tema de Omarchy desde _Apariencia > Temas_ dentro de la app).

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

### Iconos de aplicaciones

Los iconos del lanzador de aplicaciones y el dock se dibujan con los colores de tu tema, así que cambian junto con él. Vienen de un conjunto de iconos, que eliges por separado del tema en _Apariencia > Iconos_:

- _Papercraft_ es el predeterminado: todo lo que viene instalado, dibujado en un solo estilo. Las apps conocidas por su logo, como Chrome, HEY o YouTube, mantienen su forma y adoptan los colores del tema.
- _Arcade_ dibuja las mismas apps como pixel art de 8 bits, como lo haría una consola de juegos antigua.
- _Original_ muestra cada app con el icono que le dio su creador.

Puedes instalar un conjunto de iconos que haya creado alguien más desde _Instalar > Estilo > Iconos_ (o `omarchy icons install <git url>`), y quitarlo de nuevo en _Quitar > Iconos_. _Actualizar > Iconos extra_ descarga la versión más reciente de los conjuntos que tienes instalados.

Para crear el tuyo, pon tus iconos en `~/.config/omarchy/icons/<name>/`, un archivo por app, con el nombre que aparece en la línea `Icon=` del archivo `.desktop` de la app. Un archivo que termina en `.svg` se muestra tal cual. Un archivo que termina en `.svg.tpl` se dibuja con los colores del tema: escribe `{{ icon_main }}`, `{{ icon_mark }}`, `{{ icon_paper }}`, `{{ icon_body }}`, `{{ icon_edge }}`, `{{ icon_ink }}` o `{{ icon_shadow }}` donde va un color. El conjunto predeterminado en `/usr/share/omarchy/icons/papercraft/` es un buen punto de partida. Para cambiar un solo icono del conjunto predeterminado, pon tu versión en `~/.config/omarchy/icons/papercraft/`.

### Desbloqueos

Los temas también pueden tener un diseño de desbloqueo personalizado, que se usa para el proceso de descifrado al arrancar. Puedes seleccionar uno de ellos en _Apariencia > Desbloqueo_. Se ven así:

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
