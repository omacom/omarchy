# Temas

O Omarchy vem com vinte e três temas bonitos. Podes escolher entre eles através de _Aparência > Tema_ no Menu Omarchy (`Super + Space`) ou saltar diretamente para o seletor de temas com `Super + Ctrl + T`.

Cada tema dá estilo ao ambiente de trabalho, ao terminal, ao neovim, ao ecrã de atividade (btop), ao teu navegador (Chrome, Chromium, Edge ou Brave) e a toda a shell do Omarchy: barra superior, menu, notificações, OSD e ecrã de bloqueio. (No Obsidian, tens de selecionar manualmente o tema Omarchy através de _Aparência > Temas_ dentro da aplicação).

Os temas têm um conjunto de imagens de fundo entre as quais podes escolher com `Super + Ctrl + W`.

Podes encontrar ainda mais temas na [página de temas extra](https://omarchy.org/themes/) ou até [criar o teu próprio tema](43-making-your-own-theme.md).

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

Os ícones no lançador de aplicações e na dock são desenhados nas cores do teu tema, por isso mudam juntamente com ele. Vêm de um conjunto de ícones, que escolhes separadamente do tema em _Aparência > Ícones_, a partir de pré-visualizações de cada conjunto, da mesma forma que escolhes um tema:

- _Papercraft_ é o predefinido: tudo o que vem instalado, desenhado num único estilo. As aplicações conhecidas pelo seu logótipo, como o Chrome, o HEY ou o YouTube, mantêm a sua forma e assumem as cores do tema.
- _Arcade_ desenha as mesmas aplicações como pixel art de 8 bits, como faria uma antiga consola de jogos.
- _Original_ mostra cada aplicação com o ícone que o seu criador lhe deu.

Podes instalar um conjunto de ícones criado por outra pessoa com _Instalar > Estilo > Ícones_ (ou `omarchy icons install <git url>`) e removê-lo novamente em _Remover > Ícones_. _Atualizar > Ícones Extra_ obtém a versão mais recente dos conjuntos que tens instalados.

Para criares o teu próprio conjunto, coloca os teus ícones em `~/.config/omarchy/icons/<name>/`, um ficheiro por aplicação, com o nome correspondente à linha `Icon=` do ficheiro `.desktop` da aplicação. Um ficheiro terminado em `.svg` é mostrado tal como está. Um ficheiro terminado em `.svg.tpl` é desenhado nas cores do tema: escreve `{{ icon_main }}`, `{{ icon_mark }}`, `{{ icon_paper }}`, `{{ icon_body }}`, `{{ icon_edge }}`, `{{ icon_ink }}` ou `{{ icon_shadow }}` onde vai uma cor. O conjunto predefinido em `/usr/share/omarchy/icons/papercraft/` é um bom ponto de partida. Adiciona um `preview.png` para mostrares o teu conjunto no seletor; sem ele, o Omarchy desenha uma pré-visualização a partir dos teus ícones. Para alterares um único ícone do conjunto predefinido, coloca a tua versão em `~/.config/omarchy/icons/papercraft/`.

### Arranque e início de sessão

O ecrã que pede a palavra-passe do disco quando o computador arranca e o ecrã de início de sessão também seguem o tema. Sempre que mudas de tema, assumem o respetivo fundo, texto, cor de destaque e tons de vermelho, por isso não há um design de desbloqueio separado para escolher. Nos Macs com Apple Silicon, o ecrã da palavra-passe do disco mantém o aspeto predefinido do Omarchy seja qual for o tema.
