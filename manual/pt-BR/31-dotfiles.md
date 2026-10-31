# Dotfiles

O Omarchy é configurado principalmente por meio dos chamados dotfiles que ficam em `~/.config`. Esses são considerados seus arquivos, para as suas alterações. Os arquivos que ficam em `/usr/share/omarchy` pertencem ao próprio Omarchy, e você não deveria mexer neles. Se precisar alterar qualquer coisa em `/usr/share/omarchy`, você deve, em vez disso, sobrescrever o valor em `~/.config`.

As configurações principais podem ser editadas direto do menu do Omarchy (`Super + Space`), como _Configuração > Atalhos de teclado_, _Configuração > Entrada_ e _Configuração > Configuração > [arquivo]_. Quando você faz isso dessa forma, qualquer processo que precise ser reiniciado após as edições de configuração será reiniciado automaticamente depois que você sair do editor (Neovim por padrão — `:wq`, lembre-se! — mas você pode mudar isso em _Configuração > Padrões > Editor_).

Aqui está uma lista dos arquivos principais em `~/.config` e o que eles controlam:

| Arquivo | Finalidade |
| ----------------------- | --------------------- |
| `~/.config/hypr/hyprland.lua` | A configuração principal do Hyprland. Carrega os padrões do Omarchy mais os seus arquivos de sobrescrita abaixo. [Saiba mais sobre as configurações do Hyprland](https://wiki.hypr.land/Configuring/). |
| `~/.config/hypr/bindings.lua` | Seus próprios atalhos de teclado e sobrescritas dos padrões. |
| `~/.config/hypr/monitors.lua` | Configurações de monitor que o painel de monitores não cobre, como rotação, modos extras ou manter um monitor desligado. |
| `~/.config/hypr/input.lua` | Controla o layout do seu teclado, as configurações de mouse e trackpad. |
| `~/.config/hypr/looknfeel.lua` | Controla espaçamentos, bordas, animações e o restante da aparência. |
| `~/.config/hypr/autostart.lua` | Controla processos extras iniciados com a sessão. |
| `~/.config/omarchy/shell.json` | Controla o shell do Omarchy: posição da barra, layout e widgets, além dos tempos de protetor de tela, bloqueio e ociosidade. |
| `~/.config/foot/foot.ini` | Controla o seu terminal (foot é o padrão). |
| `~/.XCompose` | Define seus emoji de acesso rápido e o preenchimento automático de nome/e-mail. Certifique-se de executar `omarchy-restart-xcompose` depois de fazer alterações. |

Se você acabar fazendo muitas alterações para ajustar a sua própria configuração, é uma boa ideia fazer backup de todos esses dotfiles. [O Stow é uma ótima maneira de fazer isso](https://www.youtube.com/watch?v=NoFiYOqnC4o).

### Iniciando seus próprios aplicativos com a sessão

Se você quiser que algo seja executado toda vez que fizer login — um daemon de sincronização, um aplicativo de bate-papo, seu próprio script — coloque-o em `~/.config/hypr/autostart.lua`:

```lua
o.launch_on_start("my-service")
```

Isso inicia o comando como parte da sessão, então ele é encerrado corretamente quando você faz logout novamente.

### Executando scripts em eventos do sistema

O Omarchy dispara hooks em alguns momentos, e você pode pendurar seus próprios scripts neles. Eles ficam em `~/.config/omarchy/hooks/<event>.d/`, um diretório por evento, e todo arquivo executável ali dentro é executado quando o evento acontece:

| Evento | Quando é executado |
| ----- | ------------ |
| `post-boot` | Logo depois que a área de trabalho foi iniciada |
| `post-update` | Perto do fim de `omarchy update`, depois dos pacotes, das migrações e da reinicialização dos serviços, antes que as ferramentas do mise sejam atualizadas |
| `pre-refresh-pacman` | Depois que `omarchy refresh pacman` ressincroniza a configuração de pacotes, antes de atualizar os pacotes; uma troca de canal o executa durante essa mesma etapa de atualização |
| `theme-set` | Depois de uma troca de tema (nome do tema em `$1`) |
| `font-set` | Depois de uma troca de fonte (nome da fonte em `$1`) |
| `battery-low` | Quando a bateria fica baixa (porcentagem em `$1`) |

O hook `pre-refresh-pacman` é onde pertencem repositórios personalizados ou linhas `IgnorePkg`, já que ele é executado antes da transação de pacotes. Ambos os hooks relacionados à atualização são executados como seu usuário depois que o Omarchy limpa sua autorização sudo em cache, então um hook que usa `sudo` precisa de sua própria autorização e pode pedir sua senha.

Cada um desses diretórios já contém um arquivo `.sample` mostrando o formato de um hook — retire o `.sample` do nome para colocá-lo para funcionar. Para instalar um script que você escreveu em outro lugar, use `omarchy hook install post-boot ~/my-hook`, que o copia para lá e o torna executável.

### Adicionando suas próprias entradas de menu

O menu do Omarchy (`Super + Space`) pode ser estendido com suas próprias linhas editando `~/.config/omarchy/extensions/omarchy-menu.jsonc`. As entradas são identificadas por um id com pontos, e é o id que as posiciona na árvore, então `personal` aparece no menu raiz e `personal.notes` aparece dentro dele:

```jsonc
"personal": {"icon":"","label":"Personal"},
"personal.notes": {"icon":"󰎞","label":"Notes","action":"omarchy-launch-editor ~/notes"},
```

Reutilize um id existente e você sobrescreve aquela linha em vez de adicionar uma nova. O arquivo vem com todos os campos disponíveis documentados como comentários.

### Adicionando seus próprios exports, funções e aliases do shell

O Omarchy vem com vários aliases ergonômicos e funções úteis, mas é muito comum querer adicionar os seus próprios. Você deve adicionar aliases, funções e exports em `~/.bashrc`. Esse arquivo não será sobrescrito nas atualizações. Se quiser alterar qualquer um dos padrões do Omarchy, você também pode adicioná-los aqui com segurança.

### Definindo variáveis de ambiente para a área de trabalho

Os exports da sessão da área de trabalho pertencem a `~/.config/uwsm/env.d/`. Esses arquivos são executados antes que sua área de trabalho inicie, então um erro de shell pode mandá-lo de volta para a tela de login. Mantenha um terminal funcionando aberto enquanto os edita. Para desativar uma sobrescrita, mova-a para fora de `env.d`. Veja [recuperação de login](45-troubleshooting.md#my-password-is-accepted-but-i-return-to-the-login-screen) se uma alteração impedir o login.

### Alterando arquivos internos do Omarchy

Olha, este é o seu computador. Você pode fazer o que quiser com ele, mas eu desaconselharia fazer alterações direto nos arquivos em `/usr/share/omarchy`. Eles pertencem ao pacote pacman do Omarchy, então suas alterações simplesmente serão sobrescritas na próxima atualização. É melhor simplesmente sobrescrever, na pasta `~/.config/*`, qualquer valor padrão de que você não goste.

Você pode alterar praticamente tudo dessa forma, como os atalhos de teclado padrão. Basta editar `~/.config/hypr/bindings.lua` para, digamos, substituir o [Obsidian](https://obsidian.md/) pelo [Joplin](https://joplinapp.org/) (instale com `omarchy-pkg-add joplin-bin`):

```lua
o.rebind("SUPER + SHIFT + O", "Joplin", "joplin-desktop")
```

`o.rebind` remove o atalho existente antes de adicionar seu substituto. Ele recebe os mesmos argumentos que `o.bind`, incluindo auxiliares de inicialização e opções de atalho. Use `o.bind` para adicionar um atalho, ou `hl.unbind` para remover um sem substituí-lo.

Se você insistir em mexer nos arquivos internos do Omarchy, mude para o canal dev por _Atualização > Canal > Dev_. Isso vincula o Omarchy a um checkout git do código-fonte em `~/omarchy`, que você pode alterar à vontade. Não há ninguém aqui para dizer o que você deve fazer!

### Revertendo quaisquer alterações

Se você acabar fazendo uma bagunça nas configurações, sempre pode revertê-las para os padrões por _Atualização > Configuração_ no menu do Omarchy. Ou executando `omarchy reinstall configs` para redefinir tudo.
