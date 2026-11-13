# Criando seu próprio tema

Você pode adicionar seus próprios temas a `~/.config/omarchy/themes`. Basta copiar um dos existentes como base (veja em `/usr/share/omarchy/themes`), depois ajustar até ficar do seu gosto. Enquanto o seu tema estiver dentro dessa pasta, ele será incluído no menu de seleção de temas.

O arquivo principal que você precisa ajustar é `colors.toml`. Ele define o conjunto de cores que depois é usado para gerar configurações para o terminal (Foot/Alacritty/Ghostty/Kitty), btop, Chromium, Hyprland, Neovim, Helix, VSCode, Obsidian e todo o shell do Omarchy (barra superior, menu, notificações, OSD e tela de bloqueio).

Você também pode usar o aplicativo Aether incluído para criar um novo tema usando uma adorável interface GUI para brincar com as cores e procurar planos de fundo. Basta iniciá-lo a partir da grade de aplicativos com `Super + Alt + Space`.

### O que um tema instalado pode conter

Um tema que você mesmo escreve em `~/.config/omarchy/themes` pode conter o que você quiser — é a sua máquina e o seu arquivo, e o Omarchy aplica tudo.

Um tema que você instala do repositório de outra pessoa com `omarchy theme install` mantém tudo o que é cor e perde o punhado de arquivos que executariam código na sua máquina: qualquer arquivo `.lua`, as configurações de terminal (`alacritty.toml`, `foot.ini`, `ghostty.conf`, `kitty.conf`) e `vscode.json`. O `hyprland.lua` de um tema é Lua que o seu compositor executa no login, uma configuração de terminal nomeia o programa que o seu terminal inicia e `vscode.json` nomeia uma extensão do VSCode para instalar. Instalar o tema de alguém deve mudar a aparência da sua área de trabalho, nunca o que ela executa.

Todo o resto continua funcionando exatamente como o autor do tema escreveu — `btop.theme`, `chromium.theme`, `helix.toml`, `shell.toml`, os planos de fundo e as pré-visualizações são todos mantidos. Só o que foi descartado é regenerado a partir de `colors.toml` na sua máquina.

O Omarchy distingue os dois por o tema ter ou não seu próprio repositório git dentro dele, que é o que `omarchy theme install` deixa para trás quando clona. Então um tema que você escreveu continua sendo seu, e um que você pegou da internet continua sendo só cores.

### Modo claro

Se você estiver criando um tema de modo claro, defina `mode = "light"` no topo do seu `colors.toml`. Então ele será automaticamente pareado com o modo claro para todos os aplicativos. (A maneira antiga de largar um arquivo vazio chamado `light.mode` na raiz do seu tema ainda funciona também.)

### Imagem de desbloqueio

Temas fornecidos com as imagens `unlock.png` e `preview-unlock.png` serão listados em _Aparência > Desbloqueio_. Seu `unlock.png` deve ser preferencialmente um png transparente. E você pode criar a imagem de pré-visualização usando `omarchy plymouth preview`.

### Aplicando temas a aplicativos que o Omarchy não cobre

Se você usa um aplicativo que não está nessa lista, pode ensinar o Omarchy a aplicar temas nele você mesmo com um template. Largue um arquivo em `~/.config/omarchy/themed/` com o nome da configuração que ele gera mais uma extensão `.tpl` e escreva a configuração com `{{ background }}`, `{{ foreground }}`, `{{ accent }}`, `{{ red }}`, `{{ color0 }}` até `{{ color15 }}` e o resto da paleta como placeholders. Toda vez que você trocar de tema, o arquivo é regenerado com as cores daquele tema.

Há um `alacritty.toml.tpl.sample` totalmente comentado nessa pasta para você copiar — ele lista todas as variáveis que você pode usar, além dos modificadores `_strip` e `_rgb` para aplicativos que querem suas cores sem o `#` ou como RGB decimal. Seus templates têm prioridade sobre os do próprio Omarchy, então você também pode usar isso para substituir como um aplicativo integrado recebe o tema.

### Distribuindo seu tema

Se você quiser distribuir seu tema para que outras pessoas possam usá-lo, precisa colocá-lo em um servidor git público, como o GitHub. Então as pessoas podem instalá-lo usando _Instalar > Estilo > Tema_ no menu do Omarchy usando essa URL. Recomenda-se que você siga a convenção de nomenclatura `omarchy-[themename]-theme`, pois o tema será exibido corretamente como apenas `[themename]` no menu de seleção de temas após a instalação.

Esse `[themename]` restante vira o nome do diretório do tema, então precisa ser um que o Omarchy possa passar adiante com segurança: ele deve começar com uma letra, um dígito ou um sublinhado, e o resto pode conter letras, dígitos, `.`, `_`, `+` e `-`. Letras maiúsculas são convertidas para minúsculas para você, mas qualquer outra coisa — um espaço, uma aspa, um caractere não inglês — é recusada na hora da instalação em vez de virar um nome de diretório. Então `omarchy-tokyo-night-theme`, `omarchy-flexoki_light-theme` e `omarchy-c++-theme` instalam sem problema.

Lembre-se de que, depois de instalado a partir de um repositório, qualquer `.lua`, configuração de terminal ou `vscode.json` que ele trouxer é descartado, então não construa o tema em torno disso.

Você pode ter seu tema adicionado à [página de temas extras](https://omarchy.org/themes/) enviando um pull request para [o repositório omarchy-site](https://github.com/omacom-io/omarchy-site).
