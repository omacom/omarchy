# Criando seu próprio tema

Você pode adicionar seus próprios temas em `~/.config/omarchy/themes`. É só copiar um dos existentes como base (veja em `/usr/share/omarchy/themes`) e depois ajustar à vontade. Desde que seu tema esteja dentro dessa pasta, ele será incluído no menu de seleção de temas.

O arquivo principal que você precisa ajustar é o `colors.toml`. Ele define o conjunto de cores que é então usado para gerar as configurações do terminal (Foot/Alacritty/Ghostty/Kitty), btop, Chromium, Hyprland, Neovim, Helix, VSCode, Obsidian e de toda a shell do Omarchy (barra superior, menu, notificações, OSD e tela de bloqueio).

Você também pode usar o aplicativo Aether incluído para criar um novo tema usando uma interface gráfica adorável para brincar com cores e procurar planos de fundo. É só iniciá-lo na grade de aplicativos com `Super + Alt + Space`.

### O que um tema instalado pode conter

Um tema que você mesmo escreve em `~/.config/omarchy/themes` pode conter o que você quiser — é a sua máquina e o seu arquivo, e o Omarchy aplica tudo isso.

Um tema que você instala do repositório de outra pessoa com `omarchy theme install` mantém tudo o que é cor e perde o punhado de arquivos que executariam código na sua máquina: qualquer arquivo `.lua`, as configurações do terminal (`alacritty.toml`, `foot.ini`, `ghostty.conf`, `kitty.conf`) e o `vscode.json`. O `hyprland.lua` de um tema é Lua que o seu compositor executa no login, uma configuração de terminal nomeia o programa que o seu terminal inicia, e o `vscode.json` nomeia uma extensão do VSCode para instalar. Instalar o tema de alguém deve mudar a aparência da sua área de trabalho, nunca o que ela executa.

Todo o resto continua funcionando exatamente como o autor do tema escreveu — `btop.theme`, `chromium.theme`, `helix.toml`, `icons.theme`, `shell.toml`, os planos de fundo e as pré-visualizações são todos mantidos. Só o que foi descartado é regenerado a partir do `colors.toml` na sua máquina.

O Omarchy distingue os dois por saber se o tema tem seu próprio repositório git dentro dele, que é o que o `omarchy theme install` deixa para trás quando clona. Então um tema que você escreveu continua seu, e um que você baixou da internet continua sendo só cores.

### Modo claro

Se você está criando um tema de modo claro, defina `mode = "light"` no topo do seu `colors.toml`. Aí ele será pareado automaticamente com o modo claro em todos os aplicativos. (A maneira antiga, de soltar um arquivo vazio chamado `light.mode` na raiz do seu tema, ainda funciona também.)

### Cores dos ícones

Se você quer combinar as cores dos ícones do gerenciador de arquivos com o seu tema, adicione um arquivo chamado `icons.theme` com o nome do conjunto de ícones que você quer usar. Por padrão, as opções são: `Yaru Yaru-blue Yaru-dark Yaru-magenta Yaru-olive Yaru-prussiangreen Yaru-purple Yaru-red Yaru-sage Yaru-wartybrown Yaru-yellow`.

### Imagem de desbloqueio

Temas fornecidos com imagens `unlock.png` e `preview-unlock.png` serão listados em _Estilo > Desbloquear_. Seu `unlock.png` deve ser de preferência um png transparente. E você pode criar a imagem de pré-visualização usando `omarchy plymouth preview`.

### Aplicando temas a aplicativos que o Omarchy não cobre

Se você usa um aplicativo que não está nessa lista, pode ensinar o Omarchy a aplicar o tema a ele você mesmo com um template. Solte um arquivo em `~/.config/omarchy/themed/` nomeado com o nome da configuração que ele gera mais uma extensão `.tpl`, e escreva a configuração com `{{ background }}`, `{{ foreground }}`, `{{ accent }}`, `{{ red }}`, `{{ color0 }}` até `{{ color15 }}`, e o restante da paleta como placeholders. Toda vez que você troca de tema, o arquivo é regenerado com as cores daquele tema.

Há um `alacritty.toml.tpl.sample` totalmente comentado nessa pasta para copiar — ele lista todas as variáveis que você pode usar, além dos modificadores `_strip` e `_rgb` para aplicativos que querem suas cores sem o `#` ou como RGB decimal. Seus templates têm prioridade sobre os do próprio Omarchy, então você também pode usar isso para substituir como um aplicativo embutido recebe o tema.

### Distribuindo seu tema

Se você quer distribuir seu tema para que outras pessoas possam usá-lo, precisa colocá-lo em um servidor git público, como o GitHub. Aí as pessoas podem instalá-lo em _Instalar > Estilo > Tema_ no menu do Omarchy usando essa URL. Recomenda-se seguir a convenção de nomenclatura `omarchy-[nome-do-tema]-theme`, pois o tema aparecerá corretamente como apenas `[nome-do-tema]` no menu de seleção de temas após a instalação.

Esse `[nome-do-tema]` restante se torna o nome do diretório do tema, então ele precisa ser um nome que o Omarchy possa manipular com segurança: deve começar com uma letra, um dígito ou um sublinhado, e o restante pode conter letras, dígitos, `.`, `_`, `+` e `-`. Maiúsculas são convertidas para minúsculas para você, mas qualquer outra coisa — um espaço, uma aspa, um caractere não inglês — é recusada no momento da instalação em vez de ser transformada em um nome de diretório. Então `omarchy-tokyo-night-theme`, `omarchy-flexoki_light-theme` e `omarchy-c++-theme` instalam todos sem problemas.

Lembre-se de que, uma vez instalado a partir de um repositório, qualquer `.lua`, configuração de terminal ou `vscode.json` que ele traga é descartado, então não construa o tema em torno disso.

Você pode ter seu tema adicionado à [página de temas extras](https://omarchy.org/themes/) enviando um pull request para [o repositório omarchy-site](https://github.com/omacom-io/omarchy-site).
