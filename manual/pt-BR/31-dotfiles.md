# Dotfiles

O Omarchy é configurado principalmente pelos chamados dotfiles que ficam em `~/.config`. Eles são considerados seus arquivos, para suas alterações. Os arquivos que ficam em `/usr/share/omarchy` pertencem ao próprio Omarchy, e você não deve mexer neles. Se você precisar alterar qualquer coisa em `/usr/share/omarchy`, deverá sobrescrever o valor em `~/.config`.

As configurações principais podem ser editadas direto do menu do Omarchy (`Super + Space`), como _Configuração > Monitores_, _Configuração > Atalhos de teclado_, _Configuração > Entrada_ e _Setup > Config > [file]_. Quando você faz isso dessa maneira, qualquer processo que precise ser reiniciado depois das edições de configuração automaticamente será depois que você sair do editor (o Neovim por padrão — `:wq`, lembre-se! — mas você pode alterar isso em _Setup > Defaults > Editor_).

Aqui está uma lista dos principais arquivos em `~/.config` e o que eles controlam:

| Arquivo                  | Finalidade              |
| ----------------------- | --------------------- |
| `~/.config/hypr/hyprland.lua` | A configuração principal do Hyprland. Carrega os padrões do Omarchy mais seus arquivos de substituição abaixo. [Saiba mais sobre as configurações do Hyprland](https://wiki.hypr.land/Configuring/).  |
| `~/.config/hypr/bindings.lua` | Seus próprios atalhos de teclado e substituições dos padrões. |
| `~/.config/hypr/monitors.lua` | Controla seus monitores, resolução e posição. |
| `~/.config/hypr/input.lua` | Controla seu layout de teclado, mouse e configurações do trackpad. |
| `~/.config/hypr/looknfeel.lua` | Controla espaçamentos, bordas, animações e o restante do visual. |
| `~/.config/hypr/autostart.lua` | Controla processos extras iniciados com a sessão. |
| `~/.config/omarchy/shell.json` | Controla o shell do Omarchy: posição da barra, layout e widgets, além de tempos de proteção de tela, bloqueio e ociosidade. |
| `~/.config/foot/foot.ini` | Controla seu terminal (o foot é o padrão). |
| `~/.XCompose` | Define seu acesso rápido a emoji e preenchimento automático de nome/e-mail. Não se esqueça de executar `omarchy-restart-xcompose` depois de fazer alterações. |

Se você acabar fazendo muitas alterações para ajustar sua própria configuração, é uma boa ideia fazer backup de todos esses dotfiles. [O Stow é uma ótima maneira de fazer isso](https://www.youtube.com/watch?v=NoFiYOqnC4o).

### Iniciando seus próprios aplicativos com a sessão

Se você quiser que algo seja executado toda vez que fizer login — um daemon de sincronização, um aplicativo de chat, seu próprio script — coloque-o em `~/.config/hypr/autostart.lua`:

```lua
o.launch_on_start("my-service")
```

Isso inicia o comando como parte da sessão, então ele é devidamente limpo quando você fizer logout de novo.

### Executando scripts em eventos do sistema

O Omarchy dispara ganchos em alguns momentos, e você pode pendurar seus próprios scripts neles. Eles ficam em `~/.config/omarchy/hooks/<event>.d/`, um diretório por evento, e todos os arquivos executáveis ali são executados quando o evento acontece:

| Evento | Quando é executado |
| ----- | ------------ |
| `post-boot` | Logo depois que a área de trabalho foi iniciada |
| `post-update` | Perto do fim de `omarchy update`, depois dos pacotes, das migrações e das reinicializações de serviço, antes de as ferramentas do mise serem atualizadas |
| `pre-refresh-pacman` | Depois que `omarchy refresh pacman` ressincroniza a configuração de pacotes, antes de atualizar os pacotes; uma troca de canal o executa durante essa mesma etapa de atualização |
| `theme-set` | Depois de uma alteração de tema (nome do tema em `$1`) |
| `font-set` | Depois de uma alteração de fonte (nome da fonte em `$1`) |
| `battery-low` | Quando a bateria está baixa (porcentagem em `$1`) |

O gancho `pre-refresh-pacman` é onde repositórios personalizados ou linhas `IgnorePkg` pertencem, pois ele é executado antes da transação de pacotes. Os dois ganchos relacionados a atualizações são executados como seu usuário depois que o Omarchy limpa sua autorização sudo em cache, então um gancho que usa `sudo` precisa de sua própria autorização e pode pedir sua senha.

Cada um desses diretórios já contém um arquivo `.sample` mostrando o formato de um gancho — retire o `.sample` do nome para colocá-lo para trabalhar. Para instalar um script que você escreveu em outro lugar, use `omarchy hook install post-boot ~/my-hook`, o que o copia e o torna executável.

### Adicionando suas próprias entradas de menu

O menu do Omarchy (`Super + Space`) pode ser estendido com suas próprias linhas editando `~/.config/omarchy/extensions/omarchy-menu.jsonc`. As entradas são identificadas por um id com pontos, e é o id que as coloca na árvore, então `personal` aparece no menu raiz e `personal.notes` aparece dentro dele:

```jsonc
"personal": {"icon":"","label":"Personal"},
"personal.notes": {"icon":"󰎞","label":"Notes","action":"omarchy-launch-editor ~/notes"},
```

Reutilize um id existente e você substituirá aquela linha em vez de adicionar uma nova. O arquivo vem com todos os campos disponíveis documentados como comentários.

### Adicionando suas próprias exportações, funções e aliases de shell

O Omarchy vem com vários aliases ergonômicos e funções úteis, mas é muito comum querer adicionar os seus próprios. Você deve adicionar aliases, funções e exportações em `~/.bashrc`. Esse arquivo não será sobrescrito nas atualizações. Se você quiser alterar qualquer um dos padrões do Omarchy, também poderá adicioná-los aqui com segurança.

### Alterando arquivos internos do Omarchy

Olha, este é o seu computador. Você pode fazer o que quiser com ele, mas eu desaconselharia fazer alterações nos arquivos em `/usr/share/omarchy` diretamente. Eles pertencem ao pacote pacman do Omarchy, então suas alterações serão simplesmente sobrescritas na próxima atualização. É melhor apenas sobrescrever quaisquer valores padrão de que você não goste na pasta `~/.config/*`.

Você pode alterar praticamente tudo dessa maneira, como os atalhos de teclado padrão. Basta editar `~/.config/hypr/bindings.lua` para, digamos, substituir o [Obsidian](https://obsidian.md/) pelo [Joplin](https://joplinapp.org/) (instale com `omarchy-pkg-add joplin-bin`):

```lua
o.rebind("SUPER + SHIFT + O", "Joplin", "joplin-desktop")
```

`o.rebind` remove a vinculação existente antes de adicionar sua substituição. Ele recebe os mesmos argumentos que `o.bind`, incluindo auxiliares de inicialização e opções de vinculação. Use `o.bind` para adicionar uma vinculação, ou `hl.unbind` para remover uma sem substituí-la.

Se você insistir em mexer nos arquivos internos do Omarchy, mude para o canal dev por _Atualizar > Canal > Dev_. Isso vincula o Omarchy a um checkout git do código-fonte em `~/omarchy`, que você está livre para alterar quanto quiser. Não tem ninguém aqui para lhe dizer o que fazer!

### Redefinindo quaisquer alterações

Se você acabar fazendo uma bagunça nas configurações, sempre poderá revertê-las para os padrões por _Atualizar > Configuração_ no menu do Omarchy. Ou executando `omarchy reinstall configs` para redefinir tudo.
