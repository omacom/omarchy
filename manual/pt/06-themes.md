# Temas

O Omarchy inclui vinte e dois temas lindíssimos. Pode selecionar entre eles em _Aparência > Tema_ no Omarchy Menu (`Super + Space`) ou saltar diretamente para o seletor de temas com `Super + Ctrl + T`.

Cada tema define o estilo do ambiente de trabalho, do terminal, do neovim, do ecrã de atividade (btop), do Chromium e de toda a shell do Omarchy: barra superior, menu, notificações, OSD e ecrã de bloqueio. (Para o Obsidian, tem de selecionar manualmente o tema do Omarchy em _Aparência > Temas_ dentro da aplicação).

Os temas têm um conjunto de imagens de fundo entre as quais pode escolher com `Super + Ctrl + W`.

Pode encontrar ainda mais temas na [página de temas extra](https://omarchy.org/themes/) ou até [criar o seu próprio tema](43-making-your-own-theme.md).

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

### Ícones das aplicações

Os ícones no lançador de aplicações e na dock são desenhados nas cores do seu tema, por isso mudam juntamente com ele. Provêm de um conjunto de ícones, que escolhe separadamente do tema em _Aparência > Ícones_:

- _Papercraft_ é o predefinido: tudo o que vem instalado, desenhado num único estilo. As aplicações conhecidas pelo seu logótipo, como o Chrome, o HEY ou o YouTube, mantêm a sua forma e assumem as cores do tema.
- _Arcade_ desenha as mesmas aplicações como pixel art de 8 bits, como faria uma consola de jogos antiga.
- _Original_ mostra cada aplicação com o ícone que o seu criador lhe deu.

Pode instalar um conjunto de ícones criado por outra pessoa em _Instalar > Estilo > Ícones_ (ou `omarchy icons install <git url>`) e removê-lo novamente em _Remover > Ícones_. _Atualizar > Ícones Extra_ obtém a versão mais recente dos conjuntos que tem instalados.

Para criar o seu próprio conjunto, coloque os seus ícones em `~/.config/omarchy/icons/<name>/`, um ficheiro por aplicação, com o nome correspondente à linha `Icon=` do ficheiro `.desktop` da aplicação. Um ficheiro terminado em `.svg` é mostrado tal como está. Um ficheiro terminado em `.svg.tpl` é desenhado nas cores do tema: escreva `{{ icon_main }}`, `{{ icon_mark }}`, `{{ icon_paper }}`, `{{ icon_body }}`, `{{ icon_edge }}`, `{{ icon_ink }}` ou `{{ icon_shadow }}` onde deve ir uma cor. O conjunto predefinido em `/usr/share/omarchy/icons/papercraft/` é um bom ponto de partida. Para alterar um único ícone do conjunto predefinido, coloque a sua versão em `~/.config/omarchy/icons/papercraft/`.

### Desbloqueios

Os temas também podem ter um design de desbloqueio personalizado, que é utilizado no processo de desencriptação no arranque. Pode selecionar um deles em _Aparência > Desbloqueio_. Têm este aspeto:

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
