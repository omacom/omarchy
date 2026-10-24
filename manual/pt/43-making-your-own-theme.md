# Criar o seu próprio tema

Pode adicionar os seus próprios temas a `~/.config/omarchy/themes`. Basta copiar um dos existentes como base (veja em `/usr/share/omarchy/themes`) e depois ajustá-lo a seu gosto. Desde que o seu tema esteja dentro dessa pasta, será incluído no menu de seleção de temas.

O ficheiro principal que tem de ajustar é o `colors.toml`. Ele define o conjunto de cores que depois é usado para gerar configurações para o terminal (Foot/Alacritty/Ghostty/Kitty), btop, Chromium, Hyprland, Neovim, Helix, VSCode, Obsidian e toda a shell do Omarchy (barra superior, menu, notificações, OSD e ecrã de bloqueio).

Também pode usar a aplicação Aether incluída para criar um novo tema usando uma bela interface gráfica para brincar com as cores e procurar fundos. Basta iniciá-la a partir da grelha de aplicações com `Super + Alt + Space`.

### O que um tema instalado pode conter

Um tema que escreva por si em `~/.config/omarchy/themes` pode conter o que quiser — a máquina é sua e o ficheiro é seu, e o Omarchy aplica tudo isso.

Um tema que instale a partir do repositório de outra pessoa com `omarchy theme install` mantém tudo o que é cor, e perde o pequeno conjunto de ficheiros que executariam código na sua máquina: qualquer ficheiro `.lua`, as configurações de terminal (`alacritty.toml`, `foot.ini`, `ghostty.conf`, `kitty.conf`) e o `vscode.json`. O `hyprland.lua` de um tema é Lua que o seu compositor executa no início de sessão, uma configuração de terminal nomeia o programa que o seu terminal inicia, e o `vscode.json` nomeia uma extensão do VSCode a instalar. Instalar o tema de outra pessoa deve mudar o aspeto do seu ambiente de trabalho, nunca aquilo que ele executa.

Tudo o resto continua a funcionar exatamente como o autor do tema o escreveu — `btop.theme`, `chromium.theme`, `helix.toml`, `icons.theme`, `shell.toml`, os fundos e as pré-visualizações são todos mantidos. Só o que foi descartado é regenerado a partir de `colors.toml` na sua máquina.

O Omarchy distingue os dois pela presença, ou não, de um repositório git próprio do tema dentro dele, que é o que `omarchy theme install` deixa para trás quando o clona. Por isso um tema que escreveu continua a ser seu, e um que foi buscar à Internet continua a ser só cores.

### Modo claro

Se estiver a fazer um tema em modo claro, defina `mode = "light"` no topo do seu `colors.toml`. Assim, será automaticamente emparelhado com o modo claro para todas as aplicações. (A forma antiga, de deixar um ficheiro vazio chamado `light.mode` na raiz do seu tema, também continua a funcionar.)

### Cores dos ícones

Se quiser fazer corresponder as cores dos ícones do gestor de ficheiros ao seu tema, adicione um ficheiro chamado `icons.theme` com o nome do conjunto de ícones que quer usar. Por predefinição, as opções são: `Yaru Yaru-blue Yaru-dark Yaru-magenta Yaru-olive Yaru-prussiangreen Yaru-purple Yaru-red Yaru-sage Yaru-wartybrown Yaru-yellow`.

### Imagem de desbloqueio

Os temas fornecidos com imagens `unlock.png` e `preview-unlock.png` serão listados em _Estilo > Desbloquear_. O seu `unlock.png` deve ser, de preferência, um png transparente. E pode criar a imagem de pré-visualização usando `omarchy plymouth preview`.

### Tematizar aplicações que o Omarchy não abrange

Se usar uma aplicação que não esteja nessa lista, pode ensinar o Omarchy a tematizá-la por si com um modelo. Deixe um ficheiro em `~/.config/omarchy/themed/` com o nome da configuração que ele gera mais uma extensão `.tpl`, e escreva a configuração com `{{ background }}`, `{{ foreground }}`, `{{ accent }}`, `{{ red }}`, `{{ color0 }}` a `{{ color15 }}` e o resto da paleta como marcadores. Sempre que mudar de tema, o ficheiro é regenerado com as cores desse tema.

Há nessa pasta um `alacritty.toml.tpl.sample` totalmente comentado para copiar — lista todas as variáveis que pode usar, além dos modificadores `_strip` e `_rgb` para aplicações que querem as suas cores sem o `#` ou como RGB decimal. Os seus modelos têm prioridade sobre os do próprio Omarchy, por isso também pode usar isto para substituir a forma como uma aplicação integrada é tematizada.

### Distribuir o seu tema

Se quiser distribuir o seu tema para que outros o possam usar, precisa de o colocar num servidor git público, como o GitHub. Depois, as pessoas podem instalá-lo usando _Instalar > Estilo > Tema_ no menu Omarchy usando esse URL. Recomenda-se que siga a convenção de nomes `omarchy-[themename]-theme`, pois o tema aparecerá corretamente apenas como `[themename]` no menu de seleção de temas após a instalação.

Esse `[themename]` que sobra torna-se o nome do diretório do tema, por isso tem de ser um que o Omarchy possa manipular em segurança: deve começar com uma letra, um dígito ou um sublinhado, e o resto pode conter letras, dígitos, `.`, `_`, `+` e `-`. As maiúsculas são convertidas para minúsculas por si, mas qualquer outra coisa — um espaço, uma aspa, um carácter não inglês — é recusada no momento da instalação em vez de ser transformada num nome de diretório. Por isso, `omarchy-tokyo-night-theme`, `omarchy-flexoki_light-theme` e `omarchy-c++-theme` instalam-se todos sem problemas.

Lembre-se de que, depois de instalado a partir de um repositório, qualquer `.lua`, configuração de terminal ou `vscode.json` que ele traga é descartado, por isso não construa o tema à volta deles.

Pode fazer com que o seu tema seja adicionado à [página de temas extra](https://omarchy.org/themes/) enviando um pull request para [o repositório omarchy-site](https://github.com/omacom-io/omarchy-site).
