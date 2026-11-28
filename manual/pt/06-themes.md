# Temas

O Omarchy vem com vinte e três temas lindíssimos. Pode escolher entre eles em _Aparência > Tema_ no Menu Omarchy (`Super + Space`) ou saltar diretamente para o seletor de temas usando `Super + Ctrl + T`.

Cada tema dá estilo ao ambiente de trabalho, ao terminal, ao neovim, ao ecrã de atividade (btop), ao seu navegador (Chrome, Chromium, Edge ou Brave) e a toda a shell do Omarchy: barra superior, menu, notificações, OSD e ecrã de bloqueio. (No Obsidian, tem de selecionar manualmente o tema Omarchy em _Aparência > Temas_ dentro da aplicação).

Os temas têm um conjunto de imagens de fundo entre as quais pode escolher usando `Super + Ctrl + W`.

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

 ![last-horizon](../themes/last-horizon/preview.png)
_Last Horizon_

 ![lupine](../themes/lupine/preview.png)
_Lupine_

 ![solitude](../themes/solitude/preview.png)
_Solitude_

 ![starship](../themes/starship/preview.png)
_Starship_

### Ícones das aplicações

Os ícones no lançador de aplicações e na dock são desenhados com as cores do seu tema, por isso mudam juntamente com ele. Vêm de um conjunto de ícones, que escolhe separadamente do tema em _Aparência > Ícones_, a partir de pré-visualizações de cada conjunto, da mesma forma que escolhe um tema:

- _Papercraft_ é o predefinido: tudo o que vem instalado, desenhado num único estilo. As aplicações conhecidas pelo seu logótipo, como o Chrome, o HEY ou o YouTube, mantêm a sua forma e adotam as cores do tema.
- _Arcade_ desenha as mesmas aplicações como pixel art de 8 bits, como faria uma consola de jogos antiga.
- _Original_ mostra cada aplicação com o ícone que o seu criador lhe deu.

Pode instalar um conjunto de ícones criado por outra pessoa em _Instalar > Estilo > Ícones_ (ou `omarchy icons install <git url>`) e removê-lo novamente em _Remover > Ícones_. _Atualizar > Ícones Extra_ vai buscar a versão mais recente dos conjuntos que tem instalados.

Para criar o seu próprio conjunto, coloque os seus ícones em `~/.config/omarchy/icons/<name>/`, um ficheiro por aplicação, com o nome correspondente à linha `Icon=` do ficheiro `.desktop` da aplicação. Um ficheiro com a extensão `.svg` é mostrado tal como está. Um ficheiro com a extensão `.svg.tpl` é desenhado com as cores do tema: escreva `{{ icon_main }}`, `{{ icon_mark }}`, `{{ icon_paper }}`, `{{ icon_body }}`, `{{ icon_edge }}`, `{{ icon_ink }}` ou `{{ icon_shadow }}` onde deve ir uma cor. O conjunto predefinido em `/usr/share/omarchy/icons/papercraft/` é um bom ponto de partida. Adicione um `preview.png` para mostrar o seu conjunto no seletor; sem um, o Omarchy desenha uma pré-visualização a partir dos seus ícones. Para alterar um único ícone do conjunto predefinido, coloque a sua versão em `~/.config/omarchy/icons/papercraft/`.

### Desbloqueios

Os temas também podem ter um design de desbloqueio personalizado, que é utilizado no processo de desencriptação do arranque. Pode selecionar um deles em _Aparência > Desbloqueio_. Têm este aspeto:

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

 ![last-horizon](../themes/last-horizon/preview-unlock.png)
_Last Horizon_

 ![lumon](../themes/lumon/preview-unlock.png)
_Lumon_

 ![lupine](../themes/lupine/preview-unlock.png)
_Lupine_

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

 ![solitude](../themes/solitude/preview-unlock.png)
_Solitude_

 ![tokyo-night](../themes/tokyo-night/preview-unlock.png)
_Tokyo Night_

 ![vantablack](../themes/vantablack/preview-unlock.png)
_Vantablack_

 ![white](../themes/white/preview-unlock.png)
_White_
