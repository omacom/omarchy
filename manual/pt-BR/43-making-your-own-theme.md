# Criando seu próprio tema

Você pode adicionar seus próprios temas em `~/.config/omarchy/themes`. É só copiar um dos temas existentes como base (veja em `/usr/share/omarchy/themes`) e depois ajustar do jeito que você quiser. Enquanto seu tema estiver dentro dessa pasta, ele vai aparecer no menu de seleção de temas.

O arquivo principal que você precisa ajustar é `colors.toml`. Ele define o conjunto de cores que depois é usado para gerar as configurações do terminal (Foot/Alacritty/Ghostty/Kitty), do btop, do Chromium, do Hyprland, do Neovim, do Helix, do VSCode, do Obsidian, dos apps Qt, da retroiluminação do teclado, do método de entrada, do seletor de compartilhamento de tela, dos ícones de apps, de várias ferramentas de IA (Claude, Pi, Hermes, T3 Code, Herdr) e de todo o shell do Omarchy (barra superior, menu, notificações, OSD e tela de bloqueio).

Você também pode usar o aplicativo Aether incluído para criar um novo tema usando uma bela interface GUI para brincar com as cores e procurar planos de fundo. É só abri-lo na grade de apps com `Super + Alt + Space`.

### O que um tema instalado pode conter

Um tema que você mesmo escreve em `~/.config/omarchy/themes` pode conter o que você quiser — a máquina é sua e o arquivo é seu, e o Omarchy aplica tudo isso.

Um tema que você instala do repositório de outra pessoa com `omarchy theme install` mantém tudo o que é cor e perde o punhado de arquivos que executariam código na sua máquina: qualquer arquivo `.lua`, as configurações do terminal (`alacritty.toml`, `foot.ini`, `ghostty.conf`, `kitty.conf`) e `vscode.json`. O `hyprland.lua` de um tema é Lua que seu compositor executa no login, uma configuração de terminal indica o programa que seu terminal inicia e `vscode.json` indica uma extensão do VSCode para instalar. Instalar o tema de alguém deve mudar a aparência da sua área de trabalho, nunca o que ela executa.

Todo o resto continua funcionando exatamente como o autor do tema escreveu — `btop.theme`, `chromium.theme`, `helix.toml`, `shell.toml`, os planos de fundo e as pré-visualizações são todos mantidos. Só o que foi descartado é regenerado a partir de `colors.toml` na sua máquina.

O Omarchy diferencia os dois por saber se o tema tem seu próprio repositório git dentro dele, que é o que `omarchy theme install` deixa para trás quando clona. Assim, um tema que você escreveu continua sendo seu, e um que você baixou da internet continua sendo só cores.

### Modo claro

Se você está criando um tema de modo claro, defina `mode = "light"` no topo do seu `colors.toml`. Aí ele será pareado automaticamente com o modo claro para todos os apps. (O jeito antigo de largar um arquivo vazio chamado `light.mode` na raiz do seu tema ainda funciona também.)

### Telas de inicialização e de login

A tela que pede a senha do disco na inicialização e a tela de login desenham o logotipo do Omarchy na cor `accent` do seu tema sobre o `background` dele, com o campo de senha em seu `foreground` e `red` para uma senha errada. Não há nada extra para incluir para elas: o Omarchy não usa mais o `unlock.png` nem o `preview-unlock.png` de um tema. Em Macs com Apple Silicon, a tela de senha do disco mantém a aparência padrão do Omarchy, seja qual for o tema.

### Aplicando temas a apps que o Omarchy não cobre

Se você usa um app que não está nessa lista, pode ensinar o Omarchy a aplicar um tema nele você mesmo com um modelo. Largue um arquivo em `~/.config/omarchy/themed/` com o nome da configuração que ele gera mais a extensão `.tpl` e escreva a configuração com `{{ background }}`, `{{ foreground }}`, `{{ accent }}`, `{{ red }}`, `{{ color0 }}` até `{{ color15 }}` e o resto da paleta como placeholders. Toda vez que você troca de tema, o arquivo é regenerado com as cores daquele tema.

Tem um `alacritty.toml.tpl.sample` totalmente comentado nessa pasta para você copiar — ele lista todas as variáveis que você pode usar, além dos modificadores `_strip` e `_rgb` para apps que querem suas cores sem o `#` ou como RGB decimal. Seus modelos têm prioridade sobre os do próprio Omarchy, então você também pode usar isso para substituir como um app integrado recebe o tema.

### Distribuindo seu tema

Se você quer distribuir seu tema para que outros possam usá-lo, precisa colocá-lo em um servidor git público, como o GitHub. Aí as pessoas podem instalá-lo usando _Instalar > Estilo > Tema_ no menu do Omarchy usando essa URL. É recomendado seguir a convenção de nomenclatura `omarchy-[themename]-theme`, pois o tema vai aparecer corretamente como apenas `[themename]` no menu de seleção de temas após a instalação.

Esse `[themename]` restante se torna o nome do diretório do tema, então ele precisa ser um que o Omarchy possa manipular com segurança: ele deve começar com uma letra, um dígito ou um sublinhado, e o restante pode conter letras, dígitos, `.`, `_`, `+` e `-`. As maiúsculas são convertidas para minúsculas para você, mas qualquer outra coisa — um espaço, uma aspa, um caractere não inglês — é recusada na hora da instalação em vez de ser transformada em um nome de diretório. Então `omarchy-tokyo-night-theme`, `omarchy-flexoki_light-theme` e `omarchy-c++-theme` todos instalam sem problemas.

Lembre-se de que, depois que ele é instalado de um repositório, qualquer `.lua`, configuração de terminal ou `vscode.json` que ele trouxer é descartado, então não construa o tema em torno disso.

Você pode ter seu tema adicionado à [página de temas extras](https://omarchy.org/themes/) enviando um pull request para [o repositório omarchy-site](https://github.com/omacom-io/omarchy-site).
