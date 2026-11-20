# Dotfiles

O Omarchy é configurado principalmente através dos chamados dotfiles que vivem em `~/.config`. Esses são considerados os seus ficheiros para as suas alterações. Os ficheiros que vivem em `/usr/share/omarchy` pertencem ao próprio Omarchy, e não devia andar a mexer neles. Se precisar de alterar alguma coisa em `/usr/share/omarchy`, deve, em vez disso, substituir o valor em `~/.config`.

As configurações principais podem ser editadas diretamente a partir do menu do Omarchy (`Super + Space`), como _Setup > Keyboard > Keybindings_, _Setup > Input_ e _Setup > Config > [file]_. Quando o faz desta forma, qualquer processo que precise de ser reiniciado após edições à configuração fá-lo-á automaticamente depois de sair do editor (Neovim por predefinição — `:wq`, não se esqueça! — mas pode alterar isso através de _Setup > Defaults > Editor_).

Eis uma lista dos ficheiros principais em `~/.config` e do que controlam:

| Ficheiro                  | Finalidade              |
| ----------------------- | --------------------- |
| `~/.config/hypr/hyprland.lua` | A configuração principal do Hyprland. Carrega as predefinições do Omarchy mais os seus ficheiros de substituição abaixo. [Saber mais sobre as configurações do Hyprland](https://wiki.hypr.land/Configuring/).  |
| `~/.config/hypr/bindings.lua` | Os seus próprios atalhos de teclado e substituições das predefinições. |
| `~/.config/hypr/monitors.lua` | Definições do monitor que o painel do monitor não abrange, como rotação, modos extra ou manter um monitor desligado. |
| `~/.config/hypr/input.lua` | Controla a disposição do seu teclado, o rato e as definições do trackpad. |
| `~/.config/hypr/looknfeel.lua` | Controla intervalos, contornos, animações e o resto do aspeto. |
| `~/.config/hypr/autostart.lua` | Controla processos extra iniciados com a sessão. |
| `~/.config/omarchy/shell.json` | Controla a shell do Omarchy: posição da barra, disposição e widgets, além da proteção de ecrã, do bloqueio e dos tempos de inatividade. |
| `~/.config/foot/foot.ini` | Controla o seu terminal (o foot é a predefinição). |
| `~/.XCompose` | Define os seus emoji de acesso rápido e o preenchimento automático de nome/email. Certifique-se de que executa `omarchy-restart-xcompose` depois de fazer alterações. |

Se acabar por fazer muitas alterações para afinar a sua própria configuração, é boa ideia fazer uma cópia de segurança de todos estes dotfiles. [O Stow é uma excelente forma de o fazer](https://www.youtube.com/watch?v=NoFiYOqnC4o).

### Arrancar as suas próprias aplicações com a sessão

Se quiser que algo seja executado sempre que iniciar sessão — um daemon de sincronização, uma aplicação de chat, um script seu — coloque-o em `~/.config/hypr/autostart.lua`:

```lua
o.launch_on_start("my-service")
```

Isso arranca o comando como parte da sessão, pelo que é limpo como deve ser quando terminar sessão outra vez.

### Executar scripts em eventos do sistema

O Omarchy dispara hooks num punhado de momentos, e pode pendurar os seus próprios scripts neles. Vivem em `~/.config/omarchy/hooks/<event>.d/`, um diretório por evento, e todos os ficheiros executáveis que lá estiverem são executados quando o evento acontece:

| Evento | Quando é executado |
| ----- | ------------ |
| `post-boot` | Logo depois de o ambiente de trabalho ter arrancado |
| `post-update` | Perto do fim de `omarchy update`, depois dos pacotes, das migrações e dos reinícios de serviços, antes de as ferramentas do mise serem atualizadas |
| `pre-refresh-pacman` | Depois de `omarchy refresh pacman` voltar a sincronizar a configuração de pacotes, antes de atualizar os pacotes; uma mudança de canal executa-o durante esse mesmo passo de atualização |
| `theme-set` | Depois de uma mudança de tema (nome do tema em `$1`) |
| `font-set` | Depois de uma mudança de tipo de letra (nome do tipo de letra em `$1`) |
| `battery-low` | Quando a bateria fica fraca (percentagem em `$1`) |

O hook `pre-refresh-pacman` é onde pertencem os repositórios personalizados ou as linhas `IgnorePkg`, uma vez que é executado antes da transação de pacotes. Ambos os hooks relacionados com atualizações são executados como o seu utilizador depois de o Omarchy limpar a sua autorização sudo em cache, pelo que um hook que utilize `sudo` precisa da sua própria autorização e pode pedir-lhe a sua palavra-passe.

Cada um desses diretórios já contém um ficheiro `.sample` que mostra a forma de um hook — retire o `.sample` do nome para o pôr a trabalhar. Para instalar um script que escreveu noutro sítio, utilize `omarchy hook install post-boot ~/my-hook`, que o copia para lá e o torna executável.

### Adicionar as suas próprias entradas de menu

O menu do Omarchy (`Super + Space`) pode ser alargado com as suas próprias linhas através da edição de `~/.config/omarchy/extensions/omarchy-menu.jsonc`. As entradas são identificadas por um id com pontos, e é o id que as coloca na árvore, pelo que `personal` aparece no menu raiz e `personal.notes` aparece dentro dele:

```jsonc
"personal": {"icon":"","label":"Personal"},
"personal.notes": {"icon":"󰎞","label":"Notes","action":"omarchy-launch-editor ~/notes"},
```

Reutilize um id existente e substituirá essa linha em vez de adicionar uma nova. O ficheiro vem com todos os campos disponíveis documentados como comentários.

### Adicionar os seus próprios exports, funções e aliases da shell

O Omarchy vem com uma série de aliases ergonómicos e funções úteis, mas é muito comum querer adicionar os seus próprios. Deve adicionar aliases, funções e exports em `~/.bashrc`. Este ficheiro não será substituído nas atualizações. Se quiser alterar alguma das predefinições do Omarchy, também pode adicioná-las aqui em segurança.

### Definir variáveis de ambiente para o ambiente de trabalho

Os exports da sessão do ambiente de trabalho pertencem a `~/.config/uwsm/env.d/`. Estes ficheiros são executados antes de o seu ambiente de trabalho arrancar, pelo que um erro da shell pode mandá-lo de volta para o ecrã de início de sessão. Mantenha um terminal a funcionar aberto enquanto os edita. Para desativar uma substituição, mova-a para fora de `env.d`. Consulte [recuperação do início de sessão](45-troubleshooting.md#my-password-is-accepted-but-i-return-to-the-login-screen) se uma alteração impedir o início de sessão.

### Alterar ficheiros internos do Omarchy

Olhe, este computador é seu. Pode fazer com ele o que quiser, mas eu desaconselharia fazer alterações diretamente aos ficheiros em `/usr/share/omarchy`. Pertencem ao pacote pacman do Omarchy, pelo que as suas alterações serão simplesmente substituídas na próxima atualização. Em vez disso, fica melhor servido a substituir apenas quaisquer valores predefinidos de que não goste na pasta `~/.config/*`.

Pode alterar praticamente tudo dessa forma, como os atalhos de teclado predefinidos. Basta editar `~/.config/hypr/bindings.lua` para, por exemplo, substituir o [Obsidian](https://obsidian.md/) pelo [Joplin](https://joplinapp.org/) (instale com `omarchy-pkg-add joplin-bin`):

```lua
o.rebind("SUPER + SHIFT + O", "Joplin", "joplin-desktop")
```

`o.rebind` remove a associação existente antes de adicionar a sua substituição. Aceita os mesmos argumentos que `o.bind`, incluindo auxiliares de arranque e opções de associação. Utilize `o.bind` para adicionar uma associação, ou `hl.unbind` para remover uma sem a substituir.

Se insistir em mexer nos ficheiros internos do Omarchy, mude para o canal dev através de _Update > Channel > Dev_. Isso liga o Omarchy a um checkout git do código-fonte em `~/omarchy`, que pode alterar à vontade, até se fartar. Não está aqui ninguém para lhe dizer o que fazer!

### Repor quaisquer alterações

Se acabar por fazer uma confusão com as configurações, pode sempre revertê-las para as predefinições através de _Update > Config_ no menu do Omarchy. Ou executando `omarchy reinstall configs` para repor tudo.
