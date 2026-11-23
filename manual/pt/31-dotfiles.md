# Dotfiles

O Omarchy é configurado principalmente através dos chamados dotfiles que vivem em `~/.config`. Esses são considerados os teus ficheiros, para as tuas alterações. Os ficheiros que vivem em `/usr/share/omarchy` pertencem ao próprio Omarchy, e não devias andar a mexer neles. Se precisares de alterar alguma coisa em `/usr/share/omarchy`, devias substituir antes o valor em `~/.config`.

As configurações principais podem ser editadas diretamente a partir do menu do Omarchy (`Super + Space`), como _Setup > Keyboard > Keybindings_, _Setup > Input_ e _Setup > Config > [file]_. Quando o fazes desta forma, qualquer processo que precise de ser reiniciado após as edições de configuração sê-lo-á automaticamente depois de saíres do editor (Neovim por omissão — `:wq`, não te esqueças! — mas podes alterá-lo através de _Setup > Defaults > Editor_).

Aqui está uma lista dos ficheiros principais em `~/.config` e do que controlam:

| Ficheiro                  | Finalidade              |
| ----------------------- | --------------------- |
| `~/.config/hypr/hyprland.lua` | A configuração principal do Hyprland. Carrega os valores por omissão do Omarchy mais os teus ficheiros de substituição abaixo. [Sabe mais sobre as configurações do Hyprland](https://wiki.hypr.land/Configuring/).  |
| `~/.config/hypr/bindings.lua` | Os teus próprios atalhos de teclado e substituições dos valores por omissão. |
| `~/.config/hypr/monitors.lua` | Definições de monitor que o painel de monitores não abrange, como rotação, modos extra ou manter um monitor desligado. |
| `~/.config/hypr/input.lua` | Controla o esquema do teu teclado, o rato e as definições do trackpad. |
| `~/.config/hypr/looknfeel.lua` | Controla espaços, bordas, animações e o resto do aspeto. |
| `~/.config/hypr/autostart.lua` | Controla processos extra iniciados com a sessão. |
| `~/.config/omarchy/shell.json` | Controla a shell do Omarchy: posição da barra, esquema e widgets, além da proteção de ecrã, do bloqueio e dos tempos de inatividade. |
| `~/.config/foot/foot.ini` | Controla o teu terminal (o foot é o predefinido). |
| `~/.XCompose` | Define os teus emoji de acesso rápido e o preenchimento automático de nome/email. Não te esqueças de executar `omarchy-restart-xcompose` depois de fazeres alterações. |

Se acabares por fazer muitas alterações para ajustar a tua própria configuração, é boa ideia fazeres uma cópia de segurança de todos estes dotfiles. [O Stow é uma excelente forma de o fazer](https://www.youtube.com/watch?v=NoFiYOqnC4o).

### Arrancar as tuas próprias aplicações com a sessão

Se queres que algo seja executado sempre que inicias sessão — um daemon de sincronização, uma aplicação de chat, o teu próprio script — coloca-o em `~/.config/hypr/autostart.lua`:

```lua
o.launch_on_start("my-service")
```

Isso arranca o comando como parte da sessão, pelo que é devidamente limpo quando terminas sessão outra vez.

### Executar scripts em eventos do sistema

O Omarchy dispara hooks em alguns momentos, e podes pendurar os teus próprios scripts neles. Vivem em `~/.config/omarchy/hooks/<event>.d/`, um diretório por evento, e todos os ficheiros aí dentro que não terminem em `.sample` são executados com bash quando o evento acontece:

| Evento | Quando é executado |
| ----- | ------------ |
| `post-boot` | Logo depois de o ambiente de trabalho ter arrancado |
| `post-update` | Perto do fim do `omarchy update`, depois dos pacotes, das migrações e dos reinícios de serviços, antes de as ferramentas do mise serem atualizadas |
| `pre-refresh-pacman` | Depois de `omarchy refresh pacman` voltar a sincronizar a configuração de pacotes, antes de atualizar os pacotes; uma mudança de canal executa-o durante esse mesmo passo de atualização |
| `theme-set` | Depois de uma alteração de tema (nome do tema em `$1`) |
| `font-set` | Depois de uma alteração de tipo de letra (nome do tipo de letra em `$1`) |
| `battery-low` | Quando a bateria está a ficar fraca (percentagem em `$1`) |

É no hook `pre-refresh-pacman` que devem ficar os repositórios personalizados ou as linhas `IgnorePkg`, já que é executado antes da transação de pacotes. Ambos são executados como o teu utilizador. O `post-update` é executado enquanto a autorização sudo do `omarchy update` ainda está fresca, por isso um hook que use `sudo` não te voltará a pedir a palavra-passe; o `pre-refresh-pacman` é executado logo depois de o `omarchy refresh pacman` ter usado o sudo.

Cada um desses diretórios já contém um ficheiro `.sample` que mostra o formato de um hook — retira o `.sample` do nome para o pôr a trabalhar. Para instalares um script que escreveste noutro sítio, usa `omarchy hook install post-boot ~/my-hook`, que o copia para lá e o torna executável.

### Adicionar as tuas próprias entradas de menu

O menu do Omarchy (`Super + Space`) pode ser alargado com as tuas próprias linhas, editando `~/.config/omarchy/extensions/omarchy-menu.jsonc`. As entradas são identificadas por um id com pontos, e é o id que as coloca na árvore, pelo que `personal` aparece no menu raiz e `personal.notes` aparece dentro dele:

```jsonc
"personal": {"icon":"","label":"Personal"},
"personal.notes": {"icon":"󰎞","label":"Notes","action":"omarchy-launch-editor ~/notes"},
```

Reutiliza um id existente e substituis essa linha em vez de adicionares uma nova. O ficheiro vem com todos os campos disponíveis documentados como comentários.

### Adicionar as tuas próprias exportações da shell, funções e aliases

O Omarchy vem com uma série de aliases ergonómicos e funções úteis, mas é muito comum quereres adicionar os teus próprios. Devias adicionar aliases, funções e exportações em `~/.bashrc`. Este ficheiro não será substituído nas atualizações. Se quiseres alterar qualquer um dos valores por omissão do Omarchy, também os podes adicionar aqui em segurança.

### Definir variáveis de ambiente para o ambiente de trabalho

As exportações da sessão do ambiente de trabalho pertencem a `~/.config/uwsm/env.d/`. Estes ficheiros são executados antes de o teu ambiente de trabalho arrancar, pelo que um erro da shell pode enviar-te de volta para o ecrã de início de sessão. Mantém um terminal a funcionar aberto enquanto os editas. Para desativares uma substituição, move-a para fora de `env.d`. Consulta a [recuperação de início de sessão](45-troubleshooting.md#my-password-is-accepted-but-i-return-to-the-login-screen) se uma alteração impedir o início de sessão.

### Alterar ficheiros internos do Omarchy

Olha, este computador é teu. Podes fazer o que quiseres com ele, mas aconselho-te a não fazeres alterações diretamente aos ficheiros em `/usr/share/omarchy`. Pertencem ao pacote pacman do Omarchy, por isso as tuas alterações serão simplesmente substituídas na próxima atualização. Ficas melhor a substituir simplesmente quaisquer valores por omissão de que não gostes na pasta `~/.config/*`.

Podes alterar praticamente tudo dessa forma, como os atalhos de teclado por omissão. Basta editares `~/.config/hypr/bindings.lua` para, digamos, substituir o [Obsidian](https://obsidian.md/) pelo [Joplin](https://joplinapp.org/) (instala com `omarchy-pkg-add joplin-bin`):

```lua
o.rebind("SUPER + SHIFT + O", "Joplin", "joplin-desktop")
```

O `o.rebind` remove o atalho existente antes de adicionar a substituição. Aceita os mesmos argumentos que `o.bind`, incluindo auxiliares de lançamento e opções de atalho. Usa `o.bind` para adicionares um atalho, ou `hl.unbind` para removeres um sem o substituir.

Se insistes em andar a mexer nos ficheiros internos do Omarchy, muda para o canal dev através de _Update > Channel > Dev_. Isso liga o Omarchy a um checkout git do código-fonte em `~/omarchy`, que podes alterar à vontade, até te fartares. Não está aqui ninguém para te dizer o que fazer!

### Repor quaisquer alterações

Se acabares por fazer uma confusão com as configurações, podes sempre repô-las nos valores por omissão através de _Update > Config_ no menu do Omarchy. Ou executando `omarchy reinstall configs` para repor tudo.
