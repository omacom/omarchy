# Criando seu próprio tema

Você pode adicionar seus próprios temas em `~/.config/omarchy/themes`. Basta copiar um dos temas existentes como base (veja em `/usr/share/omarchy/themes`) e depois ajustar como quiser. Enquanto seu tema estiver dentro dessa pasta, ele será incluído no menu de seleção de temas.

O principal arquivo que você precisa ajustar é `colors.toml`. Ele define o conjunto de cores que é então usado para gerar configurações para o terminal (Foot/Alacritty/Ghostty/Kitty), btop, Chromium, Hyprland, Neovim, Helix, VSCode, Obsidian e toda a shell do Omarchy (barra superior, menu, notificações, OSD e tela de bloqueio).

Você também pode usar o aplicativo Aether incluído para criar um novo tema usando uma bela interface GUI para brincar com as cores e procurar planos de fundo. Basta iniciá-lo a partir da grade de aplicativos com `Super + Alt + Space`.

### O que um tema instalado pode conter

Um tema que você mesmo escreve em `~/.config/omarchy/themes` pode conter o que você quiser — é a sua máquina e o seu arquivo, e o Omarchy aplica tudo.

Um tema que você instala do repositório de outra pessoa com `omarchy theme install` mantém tudo o que é cor e perde o punhado de arquivos que executariam código na sua máquina: qualquer arquivo `.lua`, as configurações do terminal (`alacritty.toml`, `foot.ini`, `ghostty.conf`, `kitty.conf`) e `vscode.json`. O `hyprland.lua` de um tema é Lua que seu compositor executa no login, uma configuração de terminal nomeia o programa que seu terminal inicia, e `vscode.json` nomeia uma extensão do VSCode para instalar. Instalar o tema de alguém deve mudar a aparência da sua área de trabalho, nunca o que ela executa.

Todo o resto continua funcionando exatamente como o autor do tema escreveu — `btop.theme`, `chromium.theme`, `helix.toml`, `icons.theme`, `shell.toml`, os planos de fundo e as pré-visualizações são todos mantidos. Somente o que foi descartado é regenerado a partir de `colors.toml` na sua máquina.

O Omarchy distingue os dois verificando se o tema tem seu próprio repositório git dentro dele, que é o que `omarchy theme install` deixa para trás quando clona. Assim, um tema que você escreveu continua sendo seu, e um que você baixou da internet continua sendo apenas cores.

### Modo claro

Se você estiver criando um tema de modo claro, defina `mode = "light"` no topo do seu `colors.toml`. Então ele será automaticamente emparelhado com o modo claro para todos os aplicativos. (A forma antiga de colocar um arquivo vazio chamado `light.mode` na raiz do seu tema ainda funciona também.)

### Cores dos ícones

Se você quiser combinar as cores dos ícones do gerenciador de arquivos com seu tema, adicione um arquivo chamado `icons.theme` com o nome do conjunto de ícones que você quer usar. Por padrão, as opções são: `Yaru Yaru-blue Yaru-dark Yaru-magenta Yaru-olive Yaru-prussiangreen Yaru-purple Yaru-red Yaru-sage Yaru-wartybrown Yaru-yellow`.

### Imagem de desbloqueio

Temas fornecidos com imagens `unlock.png` e `preview-unlock.png` serão listados em _Aparência > Desbloqueio_. Seu `unlock.png` deve ser, de preferência, um png transparente. E você pode criar a imagem de pré-visualização usando `omarchy plymouth preview`.

### Aplicando temas a aplicativos que o Omarchy não cobre

Se você usa um aplicativo que não está nessa lista, pode ensinar o Omarchy a aplicar um tema nele você mesmo com um modelo. Coloque um arquivo em `~/.config/omarchy/themed/` com o nome da configuração que ele gera mais a extensão `.tpl`, e escreva a configuração com `{{ background }}`, `{{ foreground }}`, `{{ accent }}`, `{{ red }}`, `{{ color0 }}` até `{{ color15 }}` e o restante da paleta como marcadores. Toda vez que você troca de tema, o arquivo é regenerado com as cores daquele tema.

Há um `alacritty.toml.tpl.sample` totalmente comentado nessa pasta para você copiar — ele lista todas as variáveis que você pode usar, além dos modificadores `_strip` e `_rgb` para aplicativos que querem suas cores sem o `#` ou como RGB decimal. Seus modelos têm prioridade sobre os do próprio Omarchy, então você também pode usar isso para substituir como um aplicativo integrado recebe o tema.

### Distribuindo seu tema

Se você quiser distribuir seu tema para que outras pessoas possam usá-lo, precisa colocá-lo em um servidor git público, como o GitHub. Então as pessoas poderão instalá-lo usando _Instalar > Estilo > Tema_ no menu do Omarchy usando essa URL. Recomenda-se seguir a convenção de nomenclatura `omarchy-[themename]-theme`, pois o tema será exibido corretamente como apenas `[themename]` no menu de seleção de temas após a instalação.

Esse `[themename]` restante se torna o nome do diretório do tema, então precisa ser um que o Omarchy possa manipular com segurança: deve começar com uma letra, um dígito ou um sublinhado, e o restante pode conter letras, dígitos, `.`, `_`, `+` e `-`. As maiúsculas são convertidas para minúsculas para você, mas qualquer outra coisa — um espaço, uma aspa, um caractere não inglês — é recusada na hora da instalação, em vez de ser transformada em um nome de diretório. Assim, `omarchy-tokyo-night-theme`, `omarchy-flexoki_light-theme` e `omarchy-c++-theme` são todos instalados sem problemas.

Lembre-se de que, depois de instalado a partir de um repositório, qualquer `.lua`, configuração de terminal ou `vscode.json` que ele trouxer será descartado, então não construa o tema em torno deles.

Você pode ter seu tema adicionado à [página de temas extras](https://omarchy.org/themes/) enviando um pull request para [o repositório omarchy-site](https://github.com/omacom-io/omarchy-site).
