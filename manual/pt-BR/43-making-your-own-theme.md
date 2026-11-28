# Criando seu próprio tema

Você pode adicionar seus próprios temas a `~/.config/omarchy/themes`. Basta copiar um dos temas existentes como base (veja em `/usr/share/omarchy/themes`) e depois ajustá-lo como quiser. Desde que seu tema esteja dentro dessa pasta, ele será incluído no menu de seleção de temas.

O principal arquivo que você precisa ajustar é o `colors.toml`. Ele define o conjunto de cores que é usado para gerar as configurações do terminal (Foot/Alacritty/Ghostty/Kitty), btop, Chromium, Hyprland, Neovim, Helix, VSCode, Obsidian, aplicativos Qt, a retroiluminação do teclado, o método de entrada, o seletor de compartilhamento de tela, os ícones de aplicativos, várias ferramentas de IA (Claude, Pi, Hermes, T3 Code, Herdr) e todo o shell do Omarchy (barra superior, menu, notificações, OSD e tela de bloqueio).

Você também pode usar o aplicativo Aether incluído para criar um novo tema usando uma interface gráfica adorável para brincar com as cores e procurar planos de fundo. Basta iniciá-lo a partir da grade de aplicativos com `Super + Alt + Space`.

### O que um tema instalado pode conter

Um tema que você mesmo escreve em `~/.config/omarchy/themes` pode conter o que você quiser — é a sua máquina e o seu arquivo, e o Omarchy aplica tudo isso.

Um tema que você instala do repositório de outra pessoa com `omarchy theme install` mantém tudo o que é cor e perde o punhado de arquivos que executaria código na sua máquina: qualquer arquivo `.lua`, as configurações do terminal (`alacritty.toml`, `foot.ini`, `ghostty.conf`, `kitty.conf`) e o `vscode.json`. O `hyprland.lua` de um tema é Lua que seu compositor executa ao fazer login, uma configuração de terminal define o programa que seu terminal inicia e o `vscode.json` define uma extensão do VSCode para instalar. Instalar o tema de alguém deve mudar a aparência da sua área de trabalho, nunca o que ela executa.

Todo o resto continua funcionando exatamente como o autor do tema escreveu — `btop.theme`, `chromium.theme`, `helix.toml`, `shell.toml`, os planos de fundo e as pré-visualizações são todos mantidos. Somente o que foi descartado é regenerado a partir do `colors.toml` na sua máquina.

O Omarchy distingue os dois casos verificando se o tema tem seu próprio repositório git dentro dele, que é o que o `omarchy theme install` deixa para trás quando clona. Assim, um tema que você escreveu continua sendo seu, e um que você baixou da internet continua sendo só cores.

### Modo claro

Se você estiver criando um tema de modo claro, defina `mode = "light"` no topo do seu `colors.toml`. Depois, ele será automaticamente combinado com o modo claro para todos os aplicativos. (A maneira antiga de colocar um arquivo vazio chamado `light.mode` na raiz do seu tema também ainda funciona.)

### Imagem de desbloqueio

Os temas fornecidos com as imagens `unlock.png` e `preview-unlock.png` serão listados em _Aparência > Desbloqueio_. Seu `unlock.png` deve ser, de preferência, um png transparente. E você pode criar a imagem de pré-visualização usando `omarchy plymouth preview`.

### Aplicando temas a aplicativos que o Omarchy não cobre

Se você usa um aplicativo que não está nessa lista, pode ensinar o Omarchy a aplicar um tema a ele com um modelo. Coloque um arquivo em `~/.config/omarchy/themed/` com o nome da configuração que ele gera mais a extensão `.tpl` e escreva a configuração com `{{ background }}`, `{{ foreground }}`, `{{ accent }}`, `{{ red }}`, `{{ color0 }}` até `{{ color15 }}` e o restante da paleta como espaços reservados. Toda vez que você trocar de tema, o arquivo será regenerado com as cores daquele tema.

Há um `alacritty.toml.tpl.sample` totalmente comentado nessa pasta para você copiar — ele lista todas as variáveis que você pode usar, além dos modificadores `_strip` e `_rgb` para aplicativos que querem suas cores sem o `#` ou como RGB decimal. Seus modelos têm prioridade sobre os do próprio Omarchy, então você também pode usar isso para substituir a forma como um aplicativo integrado recebe o tema.

### Distribuindo seu tema

Se você quiser distribuir seu tema para que outras pessoas possam usá-lo, precisa colocá-lo em um servidor git público, como o GitHub. Depois, as pessoas poderão instalá-lo usando _Instalar > Estilo > Tema_ no menu do Omarchy usando essa URL. É recomendável seguir a convenção de nomenclatura `omarchy-[themename]-theme`, pois o tema será exibido corretamente apenas como `[themename]` no menu de seleção de temas após a instalação.

Esse `[themename]` restante se torna o nome do diretório do tema, então precisa ser um nome que o Omarchy possa manipular com segurança: ele deve começar com uma letra, um dígito ou um sublinhado, e o restante pode conter letras, dígitos, `.`, `_`, `+` e `-`. As letras maiúsculas são convertidas em minúsculas para você, mas qualquer outra coisa — um espaço, uma aspas, um caractere não inglês — é recusada no momento da instalação em vez de ser transformada em um nome de diretório. Assim, `omarchy-tokyo-night-theme`, `omarchy-flexoki_light-theme` e `omarchy-c++-theme` são todos instalados sem problemas.

Lembre-se de que, depois de instalado a partir de um repositório, qualquer `.lua`, configuração de terminal ou `vscode.json` que ele contenha será descartado, então não construa o tema em torno desses arquivos.

Você pode ter seu tema adicionado à [página de temas extras](https://omarchy.org/themes/) enviando um pull request para [o repositório omarchy-site](https://github.com/omacom-io/omarchy-site).
