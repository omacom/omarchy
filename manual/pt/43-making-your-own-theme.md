# Criar o seu próprio tema

Pode adicionar os seus próprios temas a `~/.config/omarchy/themes`. Basta copiar um dos existentes como base (veja em `/usr/share/omarchy/themes`) e depois ajustá-lo como bem lhe apetecer. Desde que o seu tema esteja dentro dessa pasta, será incluído no menu de seleção de temas.

O ficheiro principal que tem de ajustar é `colors.toml`. Esse ficheiro define o conjunto de cores que é depois usado para gerar configurações para o terminal (Foot/Alacritty/Ghostty/Kitty), btop, Chromium, Hyprland, Neovim, Helix, VSCode, Obsidian, aplicações Qt, a retroiluminação do teclado, o método de introdução, o seletor de partilha de ecrã, os ícones das aplicações, várias ferramentas de IA (Claude, Pi, Hermes, T3 Code, Herdr) e toda a shell do Omarchy (barra superior, menu, notificações, OSD e ecrã de bloqueio).

Pode também usar a aplicação Aether incluída para criar um novo tema com uma agradável interface GUI para brincar com as cores e procurar fundos. Basta iniciá-la a partir da grelha de aplicações com `Super + Alt + Space`.

### O que pode conter um tema instalado

Um tema que escreva você mesmo em `~/.config/omarchy/themes` pode conter o que quiser — é a sua máquina e o seu ficheiro, e o Omarchy aplica tudo.

Um tema que instale a partir do repositório de outra pessoa com `omarchy theme install` mantém tudo o que é cor e perde o punhado de ficheiros que executariam código na sua máquina: qualquer ficheiro `.lua`, as configurações do terminal (`alacritty.toml`, `foot.ini`, `ghostty.conf`, `kitty.conf`) e `vscode.json`. O `hyprland.lua` de um tema é Lua que o seu compositor executa ao iniciar sessão, uma configuração do terminal indica o programa que o seu terminal inicia, e o `vscode.json` indica uma extensão do VSCode a instalar. Instalar o tema de alguém deve mudar o aspeto do seu ambiente de trabalho, nunca o que ele executa.

Tudo o resto continua a funcionar exatamente como o autor do tema o escreveu — `btop.theme`, `chromium.theme`, `helix.toml`, `shell.toml`, os fundos e as pré-visualizações são todos mantidos. Só o que foi descartado é regenerado a partir de `colors.toml` na sua máquina.

O Omarchy distingue os dois consoante o tema tenha ou não o seu próprio repositório git dentro dele, que é o que o `omarchy theme install` deixa para trás quando faz a clonagem. Assim, um tema que escreveu continua a ser seu, e um que obteve da internet fica-se pelas cores.

### Modo claro

Se estiver a fazer um tema em modo claro, defina `mode = "light"` no topo do seu `colors.toml`. Depois, será automaticamente emparelhado com o modo claro para todas as aplicações. (A forma antiga de deixar um ficheiro vazio chamado `light.mode` na raiz do seu tema também continua a funcionar.)

### Imagem de desbloqueio

Os temas fornecidos com as imagens `unlock.png` e `preview-unlock.png` serão listados em _Appearance > Unlock_. O seu `unlock.png` deve ser, de preferência, um png transparente. E pode criar a imagem de pré-visualização com `omarchy plymouth preview`.

### Aplicar temas a aplicações que o Omarchy não abrange

Se usar uma aplicação que não está nessa lista, pode ensinar o Omarchy a aplicar-lhe um tema você mesmo com um modelo. Deixe um ficheiro em `~/.config/omarchy/themed/` com o nome da configuração que ele gera mais a extensão `.tpl`, e escreva a configuração com `{{ background }}`, `{{ foreground }}`, `{{ accent }}`, `{{ red }}`, `{{ color0 }}` até `{{ color15 }}`, e o resto da paleta como marcadores de posição. Sempre que mudar de tema, o ficheiro é regenerado com as cores desse tema.

Nessa pasta há um `alacritty.toml.tpl.sample` totalmente comentado para copiar — indica todas as variáveis que pode usar, mais os modificadores `_strip` e `_rgb` para aplicações que querem as suas cores sem o `#` ou como RGB decimal. Os seus modelos têm prioridade sobre os do próprio Omarchy, pelo que também pode usar isto para substituir a forma como um tema é aplicado a uma aplicação integrada.

### Distribuir o seu tema

Se quiser distribuir o seu tema para que outros o possam usar, tem de o colocar num servidor git público, como o GitHub. Depois, as pessoas podem instalá-lo através de _Install > Style > Theme_ no menu do Omarchy com esse URL. Recomenda-se que siga a convenção de nomenclatura `omarchy-[themename]-theme`, pois o tema será apresentado corretamente apenas como `[themename]` no menu de seleção de temas após a instalação.

Esse `[themename]` restante torna-se o nome do diretório do tema, pelo que tem de ser um que o Omarchy possa passar de um lado para o outro em segurança: tem de começar com uma letra, um dígito ou um underscore, e o resto pode conter letras, dígitos, `.`, `_`, `+` e `-`. As maiúsculas são convertidas em minúsculas por si, mas qualquer outra coisa — um espaço, uma aspa, um carácter não inglês — é recusada no momento da instalação em vez de ser transformada num nome de diretório. Por isso, `omarchy-tokyo-night-theme`, `omarchy-flexoki_light-theme` e `omarchy-c++-theme` instalam-se todos sem problemas.

Lembre-se de que, depois de instalado a partir de um repositório, qualquer `.lua`, configuração do terminal ou `vscode.json` que ele traga é descartado, por isso não construa o tema em torno desses ficheiros.

Pode fazer com que o seu tema seja adicionado à [página de temas extra](https://omarchy.org/themes/) ao enviar um pull request para o [repositório omarchy-site](https://github.com/omacom-io/omarchy-site).
