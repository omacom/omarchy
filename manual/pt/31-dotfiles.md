# Dotfiles

O Omarchy é configurado principalmente através dos chamados dotfiles que se encontram em `~/.config`. Esses são considerados os teus ficheiros, para as tuas alterações. Os ficheiros que se encontram em `/usr/share/omarchy` pertencem ao próprio Omarchy, e não deves andar a mexer neles. Se precisares de alterar alguma coisa em `/usr/share/omarchy`, deves, em vez disso, substituir o valor em `~/.config`.

As configurações principais podem ser editadas diretamente a partir do menu do Omarchy (`Super + Space`), como _Setup > Keybindings_, _Setup > Input_ e _Setup > Config > [file]_. Quando o fazes desta forma, qualquer processo que precise de ser reiniciado depois das edições de configuração será reiniciado automaticamente depois de fechares o editor (Neovim por predefinição — `:wq`, lembra-te! — mas podes alterar isso através de _Setup > Defaults > Editor_).

Aqui está uma lista dos ficheiros principais em `~/.config` e do que controlam:

| Ficheiro                  | Finalidade              |
| ----------------------- | --------------------- |
| `~/.config/hypr/hyprland.lua` | A configuração principal do Hyprland. Carrega os valores predefinidos do Omarchy e os teus ficheiros de substituição abaixo. [Sabe mais sobre as configurações do Hyprland](https://wiki.hypr.land/Configuring/).  |
| `~/.config/hypr/bindings.lua` | Os teus próprios atalhos de teclado e substituições dos valores predefinidos. |
| `~/.config/hypr/monitors.lua` | Definições do monitor que o painel do monitor não abrange, como rotação, modos extra ou manter um monitor desligado. |
| `~/.config/hypr/input.lua` | Controla o esquema do teu teclado e as definições do rato e do painel tátil. |
| `~/.config/hypr/looknfeel.lua` | Controla os espaços, os contornos, as animações e o resto do aspeto. |
| `~/.config/hypr/autostart.lua` | Controla processos extra iniciados com a sessão. |
| `~/.config/omarchy/shell.json` | Controla a shell do Omarchy: posição da barra, esquema e widgets, além da proteção de ecrã, do bloqueio e dos tempos de inatividade. |
| `~/.config/foot/foot.ini` | Controla o teu terminal (o foot é o predefinido). |
| `~/.XCompose` | Define os teus emojis de acesso rápido e o preenchimento automático de nome/email. Não te esqueças de executar `omarchy-restart-xcompose` depois de fazeres alterações. |

Se acabares por fazer muitas alterações para ajustar a tua própria configuração, é boa ideia fazeres uma cópia de segurança de todos estes dotfiles. [O Stow é uma forma excelente de o fazer](https://www.youtube.com/watch?v=NoFiYOqnC4o).

### Iniciar as tuas próprias aplicações com a sessão

Se quiseres que alguma coisa seja executada sempre que inicias sessão — um daemon de sincronização, uma aplicação de chat, o teu próprio script — coloca-a em `~/.config/hypr/autostart.lua`:

```lua
o.launch_on_start("my-service")
```

Isso inicia o comando como parte da sessão, por isso é devidamente limpo quando terminas sessão outra vez.

### Executar scripts em eventos do sistema

O Omarchy dispara hooks num punhado de momentos, e podes associar-lhes os teus próprios scripts. Eles encontram-se em `~/.config/omarchy/hooks/<event>.d/`, um diretório por evento, e todos os ficheiros executáveis lá dentro são executados quando o evento acontece:

| Evento | Quando é executado |
| ----- | ------------ |
| `post-boot` | Logo depois de o ambiente de trabalho ter iniciado |
| `post-update` | Perto do fim de `omarchy update`, depois dos pacotes, das migrações e do reinício dos serviços, antes de as ferramentas mise serem atualizadas |
| `pre-refresh-pacman` | Depois de `omarchy refresh pacman` voltar a sincronizar a configuração de pacotes, antes de atualizar os pacotes; uma mudança de canal executa-o durante esse mesmo passo de atualização |
| `theme-set` | Depois de uma mudança de tema (nome do tema em `$1`) |
| `font-set` | Depois de uma mudança de tipo de letra (nome do tipo de letra em `$1`) |
| `battery-low` | Quando a bateria fica fraca (percentagem em `$1`) |

O hook `pre-refresh-pacman` é onde devem ficar os repositórios personalizados ou as linhas `IgnorePkg`, uma vez que é executado antes da transação de pacotes. Ambos os hooks relacionados com atualizações são executados como o teu utilizador depois de o Omarchy limpar a sua autorização sudo em cache, por isso um hook que utilize `sudo` precisa da sua própria autorização e pode pedir-te a palavra-passe.

Cada um desses diretórios já contém um ficheiro `.sample` que mostra a forma de um hook — retira o `.sample` do nome para o pôr a funcionar. Para instalares um script que escreveste noutro local, usa `omarchy hook install post-boot ~/my-hook`, que o copia para lá e o torna executável.

### Adicionar as tuas próprias entradas ao menu

O menu do Omarchy (`Super + Space`) pode ser expandido com as tuas próprias linhas ao editares `~/.config/omarchy/extensions/omarchy-menu.jsonc`. As entradas são identificadas por um id com pontos, e é o id que as coloca na árvore, por isso `personal` aparece no menu raiz e `personal.notes` aparece dentro dele:

```jsonc
"personal": {"icon":"","label":"Personal"},
"personal.notes": {"icon":"󰎞","label":"Notes","action":"omarchy-launch-editor ~/notes"},
```

Reutiliza um id existente e substituis essa linha em vez de adicionares uma nova. O ficheiro inclui todos os campos disponíveis documentados como comentários.

### Adicionar os teus próprios exports, funções e aliases da shell

O Omarchy inclui uma série de aliases ergonómicos e funções úteis, mas é muito comum quereres adicionar os teus próprios. Deves adicionar aliases, funções e exports em `~/.bashrc`. Este ficheiro não será substituído nas atualizações. Se quiseres alterar algum dos valores predefinidos do Omarchy, podes também adicioná-los aqui em segurança.

### Definir variáveis de ambiente para o ambiente de trabalho

Os exports da sessão do ambiente de trabalho pertencem a `~/.config/uwsm/env.d/`. Estes ficheiros são executados antes de o teu ambiente de trabalho iniciar, por isso um erro da shell pode enviar-te de volta para o ecrã de início de sessão. Mantém um terminal funcional aberto enquanto os estiveres a editar. Para desativares uma substituição, move-a para fora de `env.d`. Consulta [recuperação do início de sessão](45-troubleshooting.md#my-password-is-accepted-but-i-return-to-the-login-screen) se uma alteração impedir o início de sessão.

### Alterar ficheiros internos do Omarchy

Olha, este computador é teu. Podes fazer com ele o que quiseres, mas aconselho-te a não alterares diretamente os ficheiros em `/usr/share/omarchy`. Eles pertencem ao pacote pacman do Omarchy, por isso as tuas alterações serão simplesmente substituídas na próxima atualização. É melhor substituíres os valores predefinidos de que não gostes na pasta `~/.config/*`.

Podes alterar praticamente tudo dessa forma, como os atalhos de teclado predefinidos. Basta editares `~/.config/hypr/bindings.lua` para, por exemplo, substituíres o [Obsidian](https://obsidian.md/) pelo [Joplin](https://joplinapp.org/) (instala com `omarchy-pkg-add joplin-bin`):

```lua
o.rebind("SUPER + SHIFT + O", "Joplin", "joplin-desktop")
```

O `o.rebind` remove o atalho existente antes de adicionar o seu substituto. Aceita os mesmos argumentos que o `o.bind`, incluindo auxiliares de arranque e opções de atalho. Usa o `o.bind` para adicionares um atalho, ou o `hl.unbind` para removeres um sem o substituíres.

Se insistires em mexer nos ficheiros internos do Omarchy, muda para o canal dev através de _Update > Channel > Dev_. Isso liga o Omarchy a um checkout git do código-fonte em `~/omarchy`, que podes alterar à tua vontade. Não há aqui ninguém para te dizer o que fazer!

### Repor quaisquer alterações

Se acabares por fazer uma confusão nas configurações, podes sempre repô-las nos valores predefinidos através de _Update > Config_ no menu do Omarchy. Ou executando `omarchy reinstall configs` para repor tudo.
