# Criar o seu próprio tema

Pode adicionar os seus próprios temas a `~/.config/omarchy/themes`. Basta copiar um dos existentes como base (veja em `/usr/share/omarchy/themes`) e depois ajustá-lo a seu gosto. Desde que o seu tema esteja dentro dessa pasta, será incluído no menu de seleção de temas.

O ficheiro principal que tem de ajustar é `colors.toml`. Esse ficheiro define o conjunto de cores que é depois utilizado para gerar as configurações para o terminal (Foot/Alacritty/Ghostty/Kitty), btop, Chromium, Hyprland, Neovim, Helix, VSCode, Obsidian e toda a shell do Omarchy (barra superior, menu, notificações, OSD e ecrã de bloqueio).

Também pode utilizar a aplicação Aether incluída para criar um novo tema através de uma agradável interface GUI, para brincar com as cores e procurar fundos. Basta iniciá-la a partir da grelha de aplicações com `Super + Alt + Space`.

### O que um tema instalado pode conter

Um tema que escreva você mesmo em `~/.config/omarchy/themes` pode conter o que quiser — é a sua máquina e o seu ficheiro, e o Omarchy aplica tudo.

Um tema que instale a partir do repositório de outra pessoa com `omarchy theme install` mantém tudo o que é cor e perde o punhado de ficheiros que executariam código na sua máquina: qualquer ficheiro `.lua`, as configurações do terminal (`alacritty.toml`, `foot.ini`, `ghostty.conf`, `kitty.conf`) e `vscode.json`. O `hyprland.lua` de um tema é Lua que o seu compositor executa ao iniciar sessão, uma configuração do terminal indica o programa que o seu terminal arranca e `vscode.json` indica uma extensão do VSCode para instalar. Instalar o tema de alguém deve mudar o aspeto do seu ambiente de trabalho, nunca o que ele executa.

Tudo o resto continua a funcionar exatamente como o autor do tema o escreveu — `btop.theme`, `chromium.theme`, `helix.toml`, `shell.toml`, os fundos e as pré-visualizações são todos mantidos. Apenas o que foi eliminado é regenerado a partir de `colors.toml` na sua máquina.

O Omarchy distingue os dois pela existência de um repositório git próprio dentro do tema, que é o que `omarchy theme install` deixa para trás quando faz a clonagem. Assim, um tema que escreveu continua a ser seu, e um que foi buscar à internet fica-se pelas cores.

### Modo claro

Se estiver a fazer um tema em modo claro, defina `mode = "light"` no topo do seu `colors.toml`. Depois, será automaticamente emparelhado com o modo claro em todas as aplicações. (A forma antiga de deixar um ficheiro vazio chamado `light.mode` na raiz do seu tema também continua a funcionar.)

### Imagem de desbloqueio

Os temas fornecidos com as imagens `unlock.png` e `preview-unlock.png` serão listados em _Aparência > Desbloqueio_. O seu `unlock.png` deve ser, de preferência, um png transparente. E pode criar a imagem de pré-visualização utilizando `omarchy plymouth preview`.

### Aplicar temas a aplicações que o Omarchy não abrange

Se utilizar uma aplicação que não está nessa lista, pode ensinar você mesmo o Omarchy a aplicar-lhe um tema com um modelo. Deixe um ficheiro em `~/.config/omarchy/themed/` com o nome da configuração que ele gera mais a extensão `.tpl`, e escreva a configuração com `{{ background }}`, `{{ foreground }}`, `{{ accent }}`, `{{ red }}`, `{{ color0 }}` até `{{ color15 }}` e o resto da paleta como marcadores de posição. Sempre que mudar de tema, o ficheiro é regenerado com as cores desse tema.

Nessa pasta existe um `alacritty.toml.tpl.sample` totalmente comentado para servir de base — lista todas as variáveis que pode utilizar, além dos modificadores `_strip` e `_rgb` para aplicações que querem as suas cores sem o `#` ou em RGB decimal. Os seus modelos têm prioridade sobre os do próprio Omarchy, por isso também pode utilizá-los para substituir a forma como uma aplicação integrada recebe o tema.

### Distribuir o seu tema

Se quiser distribuir o seu tema para que outras pessoas o possam utilizar, tem de o colocar num servidor git público, como o GitHub. Depois, as pessoas podem instalá-lo através de _Instalar > Estilo > Tema_ no menu do Omarchy, utilizando esse URL. Recomenda-se que siga a convenção de nomenclatura `omarchy-[themename]-theme`, pois o tema será apresentado corretamente apenas como `[themename]` no menu de seleção de temas após a instalação.

Esse `[themename]` restante torna-se o nome do diretório do tema, por isso tem de ser um nome que o Omarchy possa manipular em segurança: tem de começar com uma letra, um dígito ou um underscore, e o resto pode conter letras, dígitos, `.`, `_`, `+` e `-`. As maiúsculas são convertidas para minúsculas por si, mas qualquer outra coisa — um espaço, uma aspa, um caráter não inglês — é recusada durante a instalação, em vez de ser transformada num nome de diretório. Assim, `omarchy-tokyo-night-theme`, `omarchy-flexoki_light-theme` e `omarchy-c++-theme` instalam-se todos sem problemas.

Lembre-se de que, uma vez instalado a partir de um repositório, qualquer `.lua`, configuração do terminal ou `vscode.json` que inclua é eliminado, por isso não construa o tema em torno desses ficheiros.

Pode ter o seu tema adicionado à [página de temas extra](https://omarchy.org/themes/) enviando um pull request para o [repositório omarchy-site](https://github.com/omacom-io/omarchy-site).
