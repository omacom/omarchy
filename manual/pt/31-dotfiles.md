# Dotfiles

A configuração do Omarchy faz-se principalmente através dos chamados dotfiles que vivem em `~/.config`. Esses são considerados os seus ficheiros, para as suas alterações. Os ficheiros que vivem em `/usr/share/omarchy` pertencem ao próprio Omarchy, e não devia andar a mexer neles. Se precisar de alterar alguma coisa em `/usr/share/omarchy`, deve em vez disso substituir o valor em `~/.config`.

As configurações principais podem ser editadas diretamente a partir do menu do Omarchy (`Super + Space`), como _Setup > Keybindings_, _Setup > Input_ e _Setup > Config > [file]_. Quando o faz desta forma, qualquer processo que precise de ser reiniciado depois das edições à configuração sê-lo-á automaticamente depois de sair do editor (Neovim por predefinição — `:wq`, lembre-se! — mas pode alterar isso através de _Setup > Defaults > Editor_).

Aqui está uma lista dos principais ficheiros em `~/.config` e daquilo que controlam:

| Ficheiro                  | Finalidade              |
| ----------------------- | --------------------- |
| `~/.config/hypr/hyprland.lua` | A configuração principal do Hyprland. Carrega as predefinições do Omarchy mais os seus ficheiros de substituição indicados abaixo. [Saiba mais sobre as configurações do Hyprland](https://wiki.hypr.land/Configuring/).  |
| `~/.config/hypr/bindings.lua` | As suas próprias combinações de teclas e substituições das predefinições. |
| `~/.config/hypr/monitors.lua` | Definições de monitor que o painel de monitores não abrange, como a rotação, modos extra ou manter um monitor desligado. |
| `~/.config/hypr/input.lua` | Controla o esquema do teclado, o rato e as definições do trackpad. |
| `~/.config/hypr/looknfeel.lua` | Controla os intervalos, os contornos, as animações e o resto do aspeto visual. |
| `~/.config/hypr/autostart.lua` | Controla processos extra arrancados com a sessão. |
| `~/.config/omarchy/shell.json` | Controla a shell do Omarchy: a posição da barra, o esquema e os widgets, além dos tempos do protetor de ecrã, do bloqueio e da inatividade. |
| `~/.config/foot/foot.ini` | Controla o seu terminal (o foot é o predefinido). |
| `~/.XCompose` | Define os seus emoji de acesso rápido e o preenchimento automático de nome/email. Certifique-se de que executa `omarchy-restart-xcompose` depois de fazer alterações. |

Se acabar por fazer muitas alterações para ajustar a sua própria configuração, é boa ideia fazer uma cópia de segurança de todos estes dotfiles. [O Stow é uma ótima forma de o fazer](https://www.youtube.com/watch?v=NoFiYOqnC4o).

### Arrancar as suas próprias aplicações com a sessão

Se quiser que alguma coisa seja executada sempre que iniciar sessão — um daemon de sincronização, uma aplicação de conversação, um script seu — coloque-a em `~/.config/hypr/autostart.lua`:

```lua
o.launch_on_start("my-service")
```

Isso arranca o comando como parte da sessão, por isso é devidamente limpo quando voltar a terminar sessão.

### Executar scripts em eventos do sistema

O Omarchy dispara hooks num punhado de momentos, e pode pendurar neles os seus próprios scripts. Eles vivem em `~/.config/omarchy/hooks/<event>.d/`, um diretório por evento, e todos os ficheiros executáveis lá dentro são executados quando o evento acontece:

| Evento | Quando é executado |
| ----- | ------------ |
| `post-boot` | Logo depois de o ambiente de trabalho ter arrancado |
| `post-update` | Perto do fim de `omarchy update`, depois dos pacotes, das migrações e dos reinícios de serviços, antes de as ferramentas do mise serem atualizadas |
| `pre-refresh-pacman` | Depois de `omarchy refresh pacman` voltar a sincronizar a configuração de pacotes, antes de atualizar os pacotes; uma mudança de canal executa-o durante esse mesmo passo de atualização |
| `theme-set` | Depois de uma alteração de tema (nome do tema em `$1`) |
| `font-set` | Depois de uma alteração de tipo de letra (nome do tipo de letra em `$1`) |
| `battery-low` | Quando a bateria fica fraca (percentagem em `$1`) |

O hook `pre-refresh-pacman` é onde pertencem os repositórios personalizados ou as linhas `IgnorePkg`, uma vez que é executado antes da transação de pacotes. Ambos os hooks relacionados com atualizações são executados como o seu utilizador depois de o Omarchy limpar a sua autorização sudo em cache, por isso um hook que utilize `sudo` precisa da sua própria autorização e pode pedir-lhe a palavra-passe.

Cada um desses diretórios já contém um ficheiro `.sample` que mostra a forma de um hook — retire o `.sample` do nome para o pôr a trabalhar. Para instalar um script que escreveu noutro sítio, utilize `omarchy hook install post-boot ~/my-hook`, que o copia para lá e o torna executável.

### Adicionar as suas próprias entradas de menu

O menu do Omarchy (`Super + Space`) pode ser alargado com as suas próprias linhas ao editar `~/.config/omarchy/extensions/omarchy-menu.jsonc`. As entradas são identificadas por um id com pontos, e é o id que as coloca na árvore, por isso `personal` aparece no menu raiz e `personal.notes` aparece dentro dele:

```jsonc
"personal": {"icon":"","label":"Personal"},
"personal.notes": {"icon":"󰎞","label":"Notes","action":"omarchy-launch-editor ~/notes"},
```

Reutilize um id existente e substitui essa linha em vez de adicionar uma nova. O ficheiro vem com todos os campos disponíveis documentados como comentários.

### Adicionar as suas próprias exportações da shell, funções e aliases

O Omarchy vem com uma série de aliases ergonómicos e funções úteis, mas é muito comum querer adicionar os seus próprios. Deve adicionar aliases, funções e exportações em `~/.bashrc`. Este ficheiro não será substituído nas atualizações. Se quiser alterar alguma das predefinições do Omarchy, também pode adicioná-las aqui em segurança.

### Alterar ficheiros internos do Omarchy

Ouça, este é o seu computador. Pode fazer com ele o que quiser, mas aconselho-o a não fazer alterações diretamente aos ficheiros em `/usr/share/omarchy`. Eles pertencem ao pacote pacman do Omarchy, por isso as suas alterações serão simplesmente substituídas na próxima atualização. É preferível substituir apenas quaisquer valores predefinidos de que não goste na pasta `~/.config/*`.

Pode alterar praticamente tudo dessa forma, como as combinações de teclas predefinidas. Basta editar `~/.config/hypr/bindings.lua` para, por exemplo, substituir o [Obsidian](https://obsidian.md/) pelo [Joplin](https://joplinapp.org/) (instale com `omarchy-pkg-add joplin-bin`):

```lua
o.rebind("SUPER + SHIFT + O", "Joplin", "joplin-desktop")
```

O `o.rebind` remove a combinação existente antes de adicionar a sua substituta. Aceita os mesmos argumentos que o `o.bind`, incluindo auxiliares de arranque e opções de combinação. Utilize o `o.bind` para adicionar uma combinação, ou o `hl.unbind` para remover uma sem a substituir.

Se insistir em mexer nos ficheiros internos do Omarchy, mude para o canal dev através de _Update > Channel > Dev_. Isso liga o Omarchy a um checkout git do código-fonte em `~/omarchy`, que pode alterar à vontade, como bem lhe apetecer. Não está aqui ninguém para lhe dizer o que fazer!

### Repor quaisquer alterações

Se acabar por fazer uma confusão nas configurações, pode sempre revertê-las para as predefinições através de _Update > Config_ no menu do Omarchy. Ou ao executar `omarchy reinstall configs` para repor tudo.
