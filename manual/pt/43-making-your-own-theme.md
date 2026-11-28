# Criar o seu próprio tema

Pode adicionar os seus próprios temas a `~/.config/omarchy/themes`. Basta copiar um dos existentes como base (veja em `/usr/share/omarchy/themes`) e depois ajustá-lo a seu gosto. Desde que o seu tema esteja dentro dessa pasta, será incluído no menu de seleção de temas.

O ficheiro principal que tem de ajustar é `colors.toml`. É ele que define o conjunto de cores que depois é usado para gerar as configurações do terminal (Foot/Alacritty/Ghostty/Kitty), do btop, do Chromium, do Hyprland, do Neovim, do Helix, do VSCode, do Obsidian, das aplicações Qt, da retroiluminação do teclado, do método de introdução, do seletor de partilha de ecrã, dos ícones das aplicações, de várias ferramentas de IA (Claude, Pi, Hermes, T3 Code, Herdr) e de toda a shell do Omarchy (barra superior, menu, notificações, OSD e ecrã de bloqueio).

Também pode usar a aplicação Aether incluída para criar um novo tema através de uma agradável interface GUI, para brincar com as cores e procurar fundos. Basta iniciá-la a partir da grelha de aplicações com `Super + Alt + Space`.

### O que um tema instalado pode conter

Um tema que escreva você mesmo em `~/.config/omarchy/themes` pode conter o que quiser — é a sua máquina e o seu ficheiro, e o Omarchy aplica tudo.

Um tema que instale a partir do repositório de outra pessoa com `omarchy theme install` mantém tudo o que é cor e perde o pequeno conjunto de ficheiros que executaria código na sua máquina: qualquer ficheiro `.lua`, as configurações do terminal (`alacritty.toml`, `foot.ini`, `ghostty.conf`, `kitty.conf`) e `vscode.json`. O `hyprland.lua` de um tema é Lua que o seu compositor executa ao iniciar sessão, uma configuração do terminal indica o programa que o seu terminal arranca, e o `vscode.json` indica uma extensão do VSCode para instalar. Instalar o tema de outra pessoa deve mudar o aspeto do seu ambiente de trabalho, nunca aquilo que ele executa.

Tudo o resto continua a funcionar exatamente como o autor do tema o escreveu — `btop.theme`, `chromium.theme`, `helix.toml`, `shell.toml`, os fundos e as pré-visualizações são todos mantidos. Só aquilo que foi eliminado é regenerado a partir do `colors.toml` na sua máquina.

O Omarchy distingue os dois casos consoante o tema tenha ou não o seu próprio repositório git dentro dele, que é o que o `omarchy theme install` deixa para trás quando faz a clonagem. Assim, um tema que escreveu continua a ser seu, e um que foi buscar à internet fica-se pelas cores.

### Modo claro

Se estiver a criar um tema em modo claro, defina `mode = "light"` no topo do seu `colors.toml`. Depois, ele será automaticamente associado ao modo claro em todas as aplicações. (A forma antiga de deixar um ficheiro vazio chamado `light.mode` na raiz do seu tema também continua a funcionar.)

### Ecrãs de arranque e de início de sessão

O ecrã que pede a palavra-passe do disco no arranque e o ecrã de início de sessão desenham o logótipo do Omarchy na cor `accent` do seu tema sobre o seu `background`, com o campo da palavra-passe no seu `foreground` e `red` para uma palavra-passe errada. Não há nada extra para incluir para eles: o Omarchy já não usa o `unlock.png` nem o `preview-unlock.png` de um tema. Nos Macs com Apple Silicon, o ecrã da palavra-passe do disco mantém o aspeto predefinido do Omarchy, seja qual for o tema.

### Aplicar temas a aplicações que o Omarchy não abrange

Se utilizar uma aplicação que não está nessa lista, pode ensinar o Omarchy a aplicar-lhe um tema você mesmo com um modelo. Deixe um ficheiro em `~/.config/omarchy/themed/` com o nome da configuração que ele gera mais a extensão `.tpl`, e escreva a configuração com `{{ background }}`, `{{ foreground }}`, `{{ accent }}`, `{{ red }}`, `{{ color0 }}` até `{{ color15 }}`, e o resto da paleta como marcadores de posição. Sempre que mudar de tema, o ficheiro é regenerado com as cores desse tema.

Nessa pasta há um `alacritty.toml.tpl.sample` totalmente comentado para servir de base — lista todas as variáveis que pode usar, mais os modificadores `_strip` e `_rgb` para aplicações que querem as suas cores sem o `#` ou como RGB decimal. Os seus modelos têm prioridade sobre os do próprio Omarchy, pelo que também pode usar isto para substituir a forma como um tema é aplicado a uma aplicação integrada.

### Distribuir o seu tema

Se quiser distribuir o seu tema para que outras pessoas o possam usar, tem de o colocar num servidor git público, como o GitHub. Depois, as pessoas podem instalá-lo através de _Install > Style > Theme_ no menu do Omarchy, usando esse URL. Recomenda-se que siga a convenção de nomenclatura `omarchy-[themename]-theme`, pois o tema será apresentado corretamente apenas como `[themename]` no menu de seleção de temas após a instalação.

Esse `[themename]` restante torna-se o nome do diretório do tema, pelo que tem de ser um nome que o Omarchy possa manipular em segurança: tem de começar por uma letra, um dígito ou um carácter de sublinhado, e o resto pode conter letras, dígitos, `.`, `_`, `+` e `-`. As maiúsculas são convertidas em minúsculas por si, mas qualquer outra coisa — um espaço, uma aspa, um carácter não inglês — é recusada no momento da instalação, em vez de ser transformada num nome de diretório. Por isso, `omarchy-tokyo-night-theme`, `omarchy-flexoki_light-theme` e `omarchy-c++-theme` instalam-se todos sem problemas.

Lembre-se de que, depois de instalado a partir de um repositório, qualquer ficheiro `.lua`, configuração do terminal ou `vscode.json` que ele inclua é eliminado, por isso não construa o tema em torno deles.

Pode fazer com que o seu tema seja adicionado à [página de temas extra](https://omarchy.org/themes/) enviando um pull request para [o repositório omarchy-site](https://github.com/omacom-io/omarchy-site).
