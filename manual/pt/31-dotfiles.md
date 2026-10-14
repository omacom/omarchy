# Dotfiles

O Omarchy é sobretudo configurado através dos chamados dotfiles que vivem em `~/.config`. Esses são considerados os teus ficheiros, para as tuas alterações. Os ficheiros que vivem em `/usr/share/omarchy` pertencem ao próprio Omarchy, e não deves andar a mexer neles. Se precisares de alterar alguma coisa em `/usr/share/omarchy`, deves antes substituir o valor em `~/.config`.

As configurações principais podem ser editadas diretamente a partir do menu Omarchy (`Super + Space`), como _Configurar > Ecrãs_, _Configurar > Atalhos_, _Configurar > Entrada_ e _Configurar > Configuração > [ficheiro]_. Quando o fazes desta forma, qualquer processo que precise de ser reiniciado automaticamente depois de edições de configuração sê-lo-á depois de saíres do editor (Neovim por predefinição — `:wq`, lembra-te! —, mas podes alterar isso em _Configurar > Predefinições > Editor_).

Eis uma lista dos ficheiros principais em `~/.config` e daquilo que controlam:

| Ficheiro                  | Finalidade              |
| ----------------------- | --------------------- |
| `~/.config/hypr/hyprland.lua` | A configuração principal do Hyprland. Carrega as predefinições do Omarchy mais os teus ficheiros de substituição abaixo. [Sabe mais sobre as configurações do Hyprland](https://wiki.hypr.land/Configuring/).  |
| `~/.config/hypr/bindings.lua` | Os teus próprios atalhos e substituições das predefinições. |
| `~/.config/hypr/monitors.lua` | Controla os teus monitores, resolução e posição. |
| `~/.config/hypr/input.lua` | Controla o esquema do teu teclado, rato e definições do painel tátil. |
| `~/.config/hypr/looknfeel.lua` | Controla espaçamentos, contornos, animações e o resto do aspeto. |
| `~/.config/hypr/autostart.lua` | Controla processos extra iniciados com a sessão. |
| `~/.config/omarchy/shell.json` | Controla a shell do Omarchy: posição da barra, disposição e widgets, mais os tempos de proteção de ecrã, bloqueio e inatividade. |
| `~/.config/foot/foot.ini` | Controla o teu terminal (o foot é o predefinido). |
| `~/.XCompose` | Define os teus emoji de acesso rápido e o preenchimento automático de nome/e-mail. Certifica-te de que executas `omarchy-restart-xcompose` depois de fazeres alterações. |

Se acabares por fazer muitas alterações para ajustares a tua própria configuração, é boa ideia fazeres uma cópia de segurança de todos estes dotfiles. [O Stow é uma ótima forma de o fazer](https://www.youtube.com/watch?v=NoFiYOqnC4o).

### Iniciar as tuas próprias aplicações com a sessão

Se quiseres que alguma coisa corra sempre que iniciares sessão — um daemon de sincronização, uma aplicação de chat, o teu próprio script —, coloca-a em `~/.config/hypr/autostart.lua`:

```lua
o.launch_on_start("my-service")
```

Isso inicia o comando como parte da sessão, por isso é devidamente limpo quando terminares sessão outra vez.

### Executar scripts em eventos do sistema

O Omarchy dispara hooks num punhado de momentos, e podes pendurar neles os teus próprios scripts. Vivem em `~/.config/omarchy/hooks/<event>.d/`, um diretório por evento, e todos os ficheiros executáveis lá dentro correm quando o evento acontece:

| Evento | Quando corre |
| ----- | ------------ |
| `post-boot` | Logo depois de o ambiente de trabalho ter arrancado |
| `post-update` | Perto do fim do `omarchy update`, depois dos pacotes, das migrações e dos reinícios de serviços, antes de as ferramentas mise serem atualizadas |
| `pre-refresh-pacman` | Depois de o `omarchy refresh pacman` voltar a sincronizar a configuração de pacotes, antes de atualizar os pacotes; uma mudança de canal executa-o durante esse mesmo passo de atualização |
| `theme-set` | Depois de uma mudança de tema (nome do tema em `$1`) |
| `font-set` | Depois de uma mudança de tipo de letra (nome do tipo de letra em `$1`) |
| `battery-low` | Quando a bateria fica fraca (percentagem em `$1`) |

O hook `pre-refresh-pacman` é onde pertencem repositórios personalizados ou linhas `IgnorePkg`, uma vez que corre antes da transação de pacotes. Ambos os hooks relacionados com atualizações correm como o teu utilizador depois de o Omarchy limpar a sua autorização sudo em cache, por isso um hook que use `sudo` precisa da sua própria autorização e pode pedir-te a palavra-passe.

Cada um desses diretórios já contém um ficheiro `.sample` que mostra a forma de um hook — retira o `.sample` do nome para o pores a trabalhar. Para instalares um script que escreveste noutro sítio, usa `omarchy hook install post-boot ~/my-hook`, o que o copia para lá e o torna executável.

### Adicionar as tuas próprias entradas de menu

O menu Omarchy (`Super + Space`) pode ser alargado com as tuas próprias linhas editando `~/.config/omarchy/extensions/omarchy-menu.jsonc`. As entradas são identificadas por um id com pontos, e é o id que as coloca na árvore, por isso `personal` aparece no menu raiz e `personal.notes` aparece dentro dele:

```jsonc
"personal": {"icon":"","label":"Personal"},
"personal.notes": {"icon":"󰎞","label":"Notes","action":"omarchy-launch-editor ~/notes"},
```

Reutiliza um id existente e substituis essa linha em vez de adicionares uma nova. O ficheiro vem com todos os campos disponíveis documentados como comentários.

### Adicionar as tuas próprias exportações, funções e aliases de shell

O Omarchy vem com uma série de aliases ergonómicos e funções úteis, mas é muito comum quereres adicionar os teus próprios. Deves adicionar aliases, funções e exportações em `~/.bashrc`. Este ficheiro não será substituído nas atualizações. Se quiseres alterar alguma das predefinições do Omarchy, também as podes adicionar aqui em segurança.

### Alterar ficheiros internos do Omarchy

Repara, este é o teu computador. Podes fazer com ele o que quiseres, mas aconselho-te a não fazeres alterações diretamente aos ficheiros em `/usr/share/omarchy`. Pertencem ao pacote pacman do Omarchy, por isso as tuas alterações serão simplesmente substituídas na próxima atualização. Ficas melhor servido se substituíres apenas, na pasta `~/.config/*`, quaisquer valores predefinidos de que não gostes.

Podes alterar praticamente tudo dessa forma, como os atalhos predefinidos. Basta editares `~/.config/hypr/bindings.lua` para, digamos, substituíres o [Obsidian](https://obsidian.md/) pelo [Joplin](https://joplinapp.org/) (instala com `omarchy-pkg-add joplin-bin`):

```lua
o.rebind("SUPER + SHIFT + O", "Joplin", "joplin-desktop")
```

O `o.rebind` remove a associação existente antes de adicionar a sua substituição. Aceita os mesmos argumentos que o `o.bind`, incluindo auxiliares de arranque e opções de associação. Usa o `o.bind` para adicionares uma associação, ou o `hl.unbind` para removeres uma sem a substituíres.

Se insistires em mexer nos ficheiros internos do Omarchy, muda para o canal dev em _Atualizar > Canal > Dev_. Isso liga o Omarchy a um checkout git do código-fonte em `~/omarchy`, que estás livre de alterar como te apetecer. Não há aqui ninguém para te dizer o que fazer!

### Repor quaisquer alterações

Se acabares por fazer uma confusão nas configurações, podes sempre revertê-las para as predefinições em _Atualizar > Configuração_ no menu Omarchy. Ou executando `omarchy reinstall configs` para repor tudo.
