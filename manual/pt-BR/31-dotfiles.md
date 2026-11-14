# Dotfiles

O Omarchy é configurado principalmente por meio dos chamados dotfiles que ficam em `~/.config`. Esses são considerados seus arquivos, para as suas alterações. Os arquivos que ficam em `/usr/share/omarchy` pertencem ao próprio Omarchy, e você não deveria mexer neles. Se precisar alterar qualquer coisa em `/usr/share/omarchy`, você deveria substituir o valor em `~/.config`.

As configurações principais podem ser editadas diretamente pelo menu do Omarchy (`Super + Space`), como em _Setup > Keyboard > Keybindings_, _Setup > Input_ e _Setup > Config > [file]_. Ao fazer isso dessa maneira, qualquer processo que precise ser reiniciado após edições na configuração será reiniciado automaticamente depois que você sair do editor (Neovim por padrão — `:wq`, lembre-se! — mas você pode alterar isso em _Setup > Defaults > Editor_).

Aqui está uma lista dos arquivos principais em `~/.config` e o que eles controlam:

| File                  | Purpose              |
| ----------------------- | --------------------- |
| `~/.config/hypr/hyprland.lua` | A configuração principal do Hyprland. Carrega os padrões do Omarchy e os seus arquivos de substituição abaixo. [Saiba mais sobre as configurações do Hyprland](https://wiki.hypr.land/Configuring/).  |
| `~/.config/hypr/bindings.lua` | Seus próprios atalhos de teclado e substituições dos padrões. |
| `~/.config/hypr/monitors.lua` | Configurações de monitor que o painel de monitores não abrange, como rotação, modos extras ou manter um monitor desligado. |
| `~/.config/hypr/input.lua` | Controla o layout do seu teclado, as configurações do mouse e do trackpad. |
| `~/.config/hypr/looknfeel.lua` | Controla espaçamentos, bordas, animações e o restante da aparência. |
| `~/.config/hypr/autostart.lua` | Controla processos extras iniciados com a sessão. |
| `~/.config/omarchy/shell.json` | Controla o shell do Omarchy: posição da barra, layout e widgets, além dos tempos de protetor de tela, bloqueio e inatividade. |
| `~/.config/foot/foot.ini` | Controla o seu terminal (foot é o padrão). |
| `~/.XCompose` | Define seus emojis de acesso rápido e o preenchimento automático de nome/e-mail. Certifique-se de executar `omarchy-restart-xcompose` após fazer alterações. |

Se você acabar fazendo muitas alterações para ajustar a sua própria configuração, é uma boa ideia fazer backup de todos esses dotfiles. [O Stow é uma ótima maneira de fazer isso](https://www.youtube.com/watch?v=NoFiYOqnC4o).

### Iniciando seus próprios aplicativos com a sessão

Se você quiser que algo seja executado toda vez que fizer login — um daemon de sincronização, um aplicativo de chat, seu próprio script — coloque-o em `~/.config/hypr/autostart.lua`:

```lua
o.launch_on_start("my-service")
```

Isso inicia o comando como parte da sessão, então ele é encerrado corretamente quando você faz logout novamente.

### Executando scripts em eventos do sistema

O Omarchy dispara hooks em alguns momentos, e você pode vincular seus próprios scripts a eles. Eles ficam em `~/.config/omarchy/hooks/<event>.d/`, um diretório por evento, e todo arquivo executável que estiver ali é executado quando o evento acontece:

| Event | When it runs |
| ----- | ------------ |
| `post-boot` | Logo após a área de trabalho ser iniciada |
| `post-update` | Perto do fim de `omarchy update`, após pacotes, migrações e reinicializações de serviços, antes de as ferramentas do mise serem atualizadas |
| `pre-refresh-pacman` | Após `omarchy refresh pacman` ressincronizar a configuração de pacotes, antes de atualizar os pacotes; uma troca de canal o executa durante essa mesma etapa de atualização |
| `theme-set` | Após uma mudança de tema (nome do tema em `$1`) |
| `font-set` | Após uma mudança de fonte (nome da fonte em `$1`) |
| `battery-low` | Quando a bateria fica baixa (porcentagem em `$1`) |

O hook `pre-refresh-pacman` é onde pertencem repositórios personalizados ou linhas `IgnorePkg`, já que ele é executado antes da transação de pacotes. Ambos os hooks relacionados à atualização são executados como o seu usuário depois que o Omarchy limpa sua autorização sudo armazenada em cache, então um hook que usa `sudo` precisa de sua própria autorização e pode pedir sua senha.

Cada um desses diretórios já contém um arquivo `.sample` mostrando o formato de um hook — remova o `.sample` do nome para colocá-lo em funcionamento. Para instalar um script que você escreveu em outro lugar, use `omarchy hook install post-boot ~/my-hook`, que o copia para lá e o torna executável.

### Adicionando suas próprias entradas ao menu

O menu do Omarchy (`Super + Space`) pode ser estendido com suas próprias linhas editando `~/.config/omarchy/extensions/omarchy-menu.jsonc`. As entradas são identificadas por um id com pontos, e é o id que as posiciona na árvore, então `personal` aparece no menu raiz e `personal.notes` aparece dentro dele:

```jsonc
"personal": {"icon":"","label":"Personal"},
"personal.notes": {"icon":"󰎞","label":"Notes","action":"omarchy-launch-editor ~/notes"},
```

Reutilize um id existente e você substituirá essa linha em vez de adicionar uma nova. O arquivo vem com todos os campos disponíveis documentados como comentários.

### Adicionando seus próprios exports, funções e aliases de shell

O Omarchy vem com um monte de aliases ergonômicos e funções úteis, mas é muito comum querer adicionar os seus próprios. Você deve adicionar aliases, funções e exports em `~/.bashrc`. Esse arquivo não será substituído nas atualizações. Se quiser alterar qualquer um dos padrões do Omarchy, você também pode adicioná-los aqui com segurança.

### Definindo variáveis de ambiente para a área de trabalho

Os exports da sessão da área de trabalho pertencem a `~/.config/uwsm/env.d/`. Esses arquivos são executados antes de a sua área de trabalho ser iniciada, então um erro de shell pode mandar você de volta para a tela de login. Mantenha um terminal funcionando aberto enquanto os edita. Para desativar uma substituição, mova-a para fora de `env.d`. Consulte [recuperação de login](45-troubleshooting.md#my-password-is-accepted-but-i-return-to-the-login-screen) se uma alteração impedir o login.

### Alterando arquivos internos do Omarchy

Olha, este é o seu computador. Você pode fazer o que quiser com ele, mas eu desaconselharia fazer alterações diretamente nos arquivos em `/usr/share/omarchy`. Eles pertencem ao pacote pacman do Omarchy, então suas alterações serão simplesmente substituídas na próxima atualização. É melhor você apenas substituir, na pasta `~/.config/*`, qualquer valor padrão de que não goste.

Você pode alterar praticamente tudo dessa maneira, como os atalhos de teclado padrão. Basta editar `~/.config/hypr/bindings.lua` para, digamos, substituir o [Obsidian](https://obsidian.md/) pelo [Joplin](https://joplinapp.org/) (instale com `omarchy-pkg-add joplin-bin`):

```lua
o.rebind("SUPER + SHIFT + O", "Joplin", "joplin-desktop")
```

`o.rebind` remove o atalho existente antes de adicionar o substituto. Ele aceita os mesmos argumentos que `o.bind`, incluindo auxiliares de inicialização e opções de atalho. Use `o.bind` para adicionar um atalho, ou `hl.unbind` para remover um sem substituí-lo.

Se você insistir em fuçar nos arquivos internos do Omarchy, mude para o canal dev em _Update > Channel > Dev_. Isso vincula o Omarchy a um checkout git do código-fonte em `~/omarchy`, que você pode alterar à vontade, até cansar. Não tem ninguém aqui para dizer o que você deve fazer!

### Desfazendo quaisquer alterações

Se você acabar fazendo uma bagunça nas configurações, sempre poderá revertê-las para os padrões em _Update > Config_ no menu do Omarchy. Ou executando `omarchy reinstall configs` para redefinir tudo.
