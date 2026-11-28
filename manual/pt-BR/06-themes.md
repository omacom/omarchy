# Temas

O Omarchy vem com vinte e três temas lindos. Você pode escolher entre eles em _Aparência > Tema_ no Menu do Omarchy (`Super + Space`) ou ir direto para o seletor de temas usando `Super + Ctrl + T`.

Cada tema estiliza a área de trabalho, o terminal, o neovim, a tela de atividade (btop), seu navegador (Chrome, Chromium, Edge ou Brave) e todo o shell do Omarchy: barra superior, menu, notificações, OSD e tela de bloqueio. (No Obsidian, você precisa selecionar manualmente o tema do Omarchy em _Aparência > Temas_ dentro do aplicativo).

Os temas têm um conjunto de imagens de fundo entre as quais você pode escolher usando `Super + Ctrl + W`.

Você pode encontrar ainda mais temas na [página de temas extras](https://omarchy.org/themes/) ou até [criar seu próprio tema](43-making-your-own-theme.md).

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

### Ícones de aplicativos

Os ícones no lançador de aplicativos e na dock são desenhados nas cores do seu tema, então mudam junto com ele. Eles vêm de um conjunto de ícones, que você escolhe separadamente do tema em _Aparência > Ícones_, a partir de pré-visualizações de cada conjunto, da mesma forma que escolhe um tema:

- _Papercraft_ é o padrão: tudo o que vem instalado, desenhado em um único estilo. Aplicativos conhecidos pelo seu logotipo, como Chrome, HEY ou YouTube, mantêm seu formato e assumem as cores do tema.
- _Arcade_ desenha os mesmos aplicativos como pixel art de 8 bits, como faria um console de jogos antigo.
- _Original_ mostra cada aplicativo com o ícone que seu criador deu a ele.

Você pode instalar um conjunto de ícones feito por outra pessoa em _Instalar > Estilo > Ícones_ (ou `omarchy icons install <git url>`), e removê-lo novamente em _Remover > Ícones_. _Atualizar > Ícones Extras_ busca a versão mais recente dos conjuntos que você instalou.

Para criar o seu próprio, coloque seus ícones em `~/.config/omarchy/icons/<name>/`, um arquivo por aplicativo, nomeado de acordo com a linha `Icon=` do arquivo `.desktop` do aplicativo. Um arquivo terminado em `.svg` é exibido como está. Um arquivo terminado em `.svg.tpl` é desenhado nas cores do tema: escreva `{{ icon_main }}`, `{{ icon_mark }}`, `{{ icon_paper }}`, `{{ icon_body }}`, `{{ icon_edge }}`, `{{ icon_ink }}` ou `{{ icon_shadow }}` onde vai uma cor. O conjunto padrão em `/usr/share/omarchy/icons/papercraft/` é um bom lugar para começar. Adicione um `preview.png` para mostrar seu conjunto no seletor; sem um, o Omarchy desenha uma pré-visualização a partir dos seus ícones. Para alterar um único ícone do conjunto padrão, coloque sua versão em `~/.config/omarchy/icons/papercraft/`.

### Inicialização e login

A tela que pede a senha da sua unidade quando o computador inicia, e a tela de login, também seguem o tema. Sempre que você troca de tema, elas assumem seu plano de fundo, texto, cor de destaque e cores vermelhas, então não há um design de desbloqueio separado para escolher. Em Macs com Apple Silicon, a tela de senha da unidade mantém a aparência padrão do Omarchy, seja qual for o tema.
