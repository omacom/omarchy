# Criar o seu próprio tema

Pode adicionar os seus próprios temas a `~/.config/omarchy/themes`. Basta copiar um dos existentes como base (veja em `/usr/share/omarchy/themes`), depois ajuste ao seu gosto. Desde que o seu tema esteja dentro dessa pasta, será incluído no menu de seleção de temas.

O ficheiro principal que tem de ajustar é `colors.toml`. Este define o conjunto de cores que é depois utilizado para gerar configurações para o terminal (Foot/Alacritty/Ghostty/Kitty), btop, Chromium, Hyprland, Neovim, Helix, VSCode, Obsidian e toda a shell do Omarchy (barra superior, menu, notificações, OSD e ecrã de bloqueio).

Pode também utilizar a aplicação Aether incluída para criar um novo tema usando uma agradável interface GUI para brincar com as cores e procurar fundos. Basta iniciá-la a partir da grelha de aplicações em `Super + Alt + Space`.

### O que um tema instalado pode conter

Um tema que escreve você mesmo em `~/.config/omarchy/themes` pode conter o que quiser — a máquina é sua e o ficheiro é seu, e o Omarchy aplica tudo.

Um tema que instala a partir do repositório de outra pessoa com `omarchy theme install` mantém tudo o que é cor, e perde o punhado de ficheiros que executariam código na sua máquina: qualquer ficheiro `.lua`, as configurações do terminal (`alacritty.toml`, `foot.ini`, `ghostty.conf`, `kitty.conf`) e `vscode.json`. O `hyprland.lua` de um tema é Lua que o seu compositor executa ao iniciar sessão, uma configuração do terminal indica o programa que o seu terminal inicia, e `vscode.json` indica uma extensão do VSCode a instalar. Instalar o tema de alguém deve mudar o aspeto do seu ambiente de trabalho, nunca o que ele executa.

Tudo o resto continua a funcionar exatamente como o autor do tema escreveu — `btop.theme`, `chromium.theme`, `helix.toml`, `icons.theme`, `shell.toml`, os fundos e as pré-visualizações são todos mantidos. Apenas o que foi removido é regenerado a partir de `colors.toml` na sua máquina.

O Omarchy distingue os dois pela existência de um repositório git próprio dentro do tema, que é o que `omarchy theme install` deixa para trás quando clona. Assim, um tema que escreveu continua a ser seu, e um que descarregou da internet fica-se pelas cores.

### Modo claro

Se estiver a criar um tema de modo claro, defina `mode = "light"` no topo do seu `colors.toml`. Depois, ele será automaticamente emparelhado com o modo claro para todas as aplicações. (A forma antiga de deixar um ficheiro vazio chamado `light.mode` na raiz do seu tema também continua a funcionar.)

### Cores dos ícones

Se quiser combinar as cores dos ícones do gestor de ficheiros com o seu tema, adicione um ficheiro chamado `icons.theme` com o nome do conjunto de ícones que pretende utilizar. Por predefinição, as opções são: `Yaru Yaru-blue Yaru-dark Yaru-magenta Yaru-olive Yaru-prussiangreen Yaru-purple Yaru-red Yaru-sage Yaru-wartybrown Yaru-yellow`.

### Imagem de desbloqueio

Os temas fornecidos com imagens `unlock.png` e `preview-unlock.png` serão listados em _Aparência > Desbloqueio_. O seu `unlock.png` deve ser, de preferência, um png transparente. E pode criar a imagem de pré-visualização utilizando `omarchy plymouth preview`.

### Aplicar temas a aplicações que o Omarchy não abrange

Se utilizar uma aplicação que não está nessa lista, pode ensinar o Omarchy a aplicar-lhe um tema você mesmo com um modelo. Deixe um ficheiro em `~/.config/omarchy/themed/` com o nome da configuração que gera mais a extensão `.tpl`, e escreva a configuração com `{{ background }}`, `{{ foreground }}`, `{{ accent }}`, `{{ red }}`, `{{ color0 }}` até `{{ color15 }}`, e o resto da paleta como marcadores. Sempre que mudar de tema, o ficheiro é regenerado com as cores desse tema.

Existe um `alacritty.toml.tpl.sample` totalmente comentado nessa pasta para copiar — lista todas as variáveis que pode utilizar, mais os modificadores `_strip` e `_rgb` para aplicações que querem as suas cores sem o `#` ou como RGB decimal. Os seus modelos têm prioridade sobre os do próprio Omarchy, por isso também pode utilizar isto para substituir a forma como um tema é aplicado a uma aplicação integrada.

### Distribuir o seu tema

Se quiser distribuir o seu tema para que outros possam utilizá-lo, precisa de o colocar num servidor git público, como o GitHub. Depois, as pessoas podem instalá-lo utilizando _Instalar > Estilo > Tema_ no menu do Omarchy, usando esse URL. Recomenda-se que siga a convenção de nomenclatura `omarchy-[themename]-theme`, pois o tema será apresentado corretamente apenas como `[themename]` no menu de seleção de temas após a instalação.

Esse `[themename]` restante torna-se o nome do diretório do tema, por isso tem de ser um que o Omarchy consiga passar de um lado para o outro em segurança: tem de começar com uma letra, um dígito ou um sublinhado, e o resto pode conter letras, dígitos, `.`, `_`, `+` e `-`. As maiúsculas são convertidas para minúsculas por si, mas qualquer outra coisa — um espaço, uma aspa, um caráter não inglês — é recusada no momento da instalação, em vez de ser transformada num nome de diretório. Por isso, `omarchy-tokyo-night-theme`, `omarchy-flexoki_light-theme` e `omarchy-c++-theme` instalam todos sem problemas.

Lembre-se de que, depois de instalado a partir de um repositório, qualquer `.lua`, configuração de terminal ou `vscode.json` que ele traga é removido, por isso não construa o tema em torno desses ficheiros.

Pode fazer com que o seu tema seja adicionado à [página de temas extra](https://omarchy.org/themes/) enviando um pull request para [o repositório omarchy-site](https://github.com/omacom-io/omarchy-site).
