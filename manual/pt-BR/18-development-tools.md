# Ferramentas de Desenvolvimento

## Editores Alternativos

O Omarchy vem com o Plain como editor padrão nas novas instalações e com o [Neovim](https://neovim.io/) pré-instalado, mas, se você quiser algo um pouco mais mainstream e familiar, pode executar o Menu do Omarchy (`Super + Space`) e ver as opções em _Instalar > Editor_. Temos VSCode, Cursor, Zed, Sublime Text, Helix, Vim e Emacs listados lá. Se você não encontrar o que está procurando, dê uma olhada em _Instalar > Pacote_ e veja se ele não está em um pacote do Arch (e, se não estiver, tente _Instalar > AUR_ para verificar o AUR).

O editor `vi` original também está disponível de fábrica. Execute `vi filename` para editar um arquivo no terminal.

A correspondência de tema é oferecida para `VSCode`, `Cursor`, `VSCodium` e `Helix`.

Você pode definir o editor padrão de todo o sistema em `Setup > Defaults > Editor`.

## Ambiente

O Omarchy oferece suporte à configuração de uma grande variedade de ambientes de desenvolvimento por meio da seção _Instalar > Desenvolvimento_ do Menu do Omarchy (`Super + Space`). Você vai encontrar, é claro, o _Ruby on Rails_, mas também os três principais runtimes para JavaScript (Node.js, Bun, Deno), além de frameworks PHP populares como Laravel e Symfony. Ah, e também tem Go, Rust, Python, Java, Elixir (com Phoenix), .NET, OCaml, Zig, Clojure e Scala. É uma seleção bem ampla!

A maioria desses ambientes é gerenciada pelo [Mise](https://mise.jdx.dev/). É uma ferramenta que permite instalar e executar várias versões de uma linguagem de programação na mesma máquina. É como o rbenv ou o rvm para Ruby ou o virtualenv para Python, mas funciona para um monte de ambientes diferentes.

Para instalar, digamos, o Ruby, você executaria `mise use -g ruby`, o que vai instalar o Ruby e defini-lo como o padrão global. Ou, se o seu projeto tiver um arquivo .ruby-version, você pode simplesmente executar `mise i` na raiz desse projeto.

## Ferramentas de CLI pré-instaladas

O Omarchy disponibiliza ferramentas como `gh`, `uv` e a maioria dos [agentes de programação](17-ai.md) por meio da [instalação preguiçosa do mise](https://mise.jdx.dev/dev-tools/shims.html#lazy-tools). Na primeira vez que você executa uma delas, o mise a instala. Os agentes de programação então verificam se há uma atualização antes de executar, no máximo uma vez a cada quatro horas; outras ferramentas, como `gh` e `uv`, reutilizam a versão instalada até você atualizar.

Você também pode inspecionar os padrões ou instalá-los com antecedência:

```bash
mise ls --current              # List the tools configured for this directory
mise install gh               # Install one tool now
mise install --include-lazy    # Install all configured tools, including lazy tools
```

Execute `omarchy update` para atualizar as ferramentas instaladas junto com o restante do Omarchy. O alias `mup` atualiza somente as ferramentas gerenciadas pelo mise. Para adicionar outra ferramenta à sua própria configuração, use `mise use -g <tool>`.

A configuração do Python também instala o `uv` por meio do mise. Remover o ambiente de desenvolvimento Python mantém o `uv` disponível como uma ferramenta independente.

### Usando a sua própria instalação

Os comandos do mise vêm antes de `~/.local/bin` no `PATH`, então uma ferramenta que você mesmo instalou, por exemplo com o instalador do próprio Claude Code ou do Cursor, ainda executa a cópia do mise. Os aplicativos iniciados a partir da área de trabalho também encontram os comandos do mise antes dos pacotes do sistema, então um aplicativo que executa `gh` obtém a cópia do mise mesmo que você tenha instalado o `github-cli` com o pacman, e o mise instala essa cópia na primeira vez. Para usar a sua, desative a cópia do mise em `~/.config/mise/config.toml`. Por exemplo, se você mesmo instalou o Cursor CLI:

```toml
[settings]
disable_tools = ["cursor-agent"]
```

Se você já tiver uma tabela `[settings]`, adicione a entrada nela; estenda uma lista `disable_tools` existente em vez de substituí-la. Certifique-se de que a sua instalação esteja no `PATH`. Use o nome da ferramenta do mise, que pode ser diferente do seu comando: o `oh-my-pi` fornece o `omp`, por exemplo. O inicializador do agente padrão também prefere um Cursor ou Muse instalado pelo usuário em `~/.local/bin`.

### Removendo e restaurando os padrões

_Remover > Pré-instalações_ remove os web apps, TUIs e aplicativos pré-instalados do Omarchy e faz o mise ignorar as declarações de ferramentas do Omarchy para o seu usuário, adicionando-as a `ignored_config_paths` em `~/.config/mise/miserc.toml`. _Instalar > Pré-instalações_ os traz de volta e remove essa linha novamente. As ferramentas que você mesmo declara, na sua própria configuração ou no `mise.toml` de um projeto, continuam funcionando de qualquer maneira. Se você escolher um agente padrão ou configurar o Python depois de remover as pré-instalações, essa ferramenta é adicionada à sua própria configuração. A configuração do mise se aplica somente ao seu usuário, e outros usuários mantêm a própria escolha; os aplicativos são pacotes, porém, então removê-los ou restaurá-los os altera para todos na máquina.

## Docker

O [Docker](https://www.docker.com/) dificilmente precisa de qualquer apresentação. Ele permite executar contêineres isolados, e o Omarchy instala tudo o que é necessário para executá-lo bem, incluindo o próprio Docker e o [Docker Compose](https://docs.docker.com/compose/).

Por padrão, o seu usuário *não* está no grupo `docker`. Esse grupo é, na prática, root sem senha — qualquer coisa nele pode executar `docker run -v /:/host` e tomar conta da máquina —, então um único script ou dependência maliciosa executando como você estaria, de outra forma, a um comando do root. Então, na linha de comando, você executa o Docker com `sudo` (`sudo docker ps`, `sudo docker compose up`), e as ferramentas gráficas que se comunicam com o daemon — a VM do Windows — pedem autorização quando precisam. Se você quiser a conveniência de uma configuração sem grupo de volta e entender o compromisso envolvido, ative-a em **Configuração > Segurança > Sudoless Docker** (ou execute `omarchy-setup-security-sudoless-docker`), o que adiciona você ao grupo `docker` depois de um aviso; então o `docker` simples e o alias `d` voltam a funcionar sem `sudo`.

Você pode configurar os bancos de dados comuns para desenvolvimento local no Docker usando _Instalar > Desenvolvimento > Docker DB_ no menu do Omarchy.

## GitHub CLI

O [GitHub CLI](https://cli.github.com/) está disponível como `gh` para trabalhar com repositórios, issues e pull requests a partir do terminal. Execute `gh auth login` para instalá-lo no primeiro uso e se autenticar, depois `gh repo clone org/repo` para clonar um repositório. Execute `gh --help` para explorar seus comandos.

Para uma interface de terminal para pull requests, execute `ghui`; o mise também o instala no primeiro uso. O [Lazygit](https://github.com/jesseduffield/lazygit) vem pré-instalado para trabalhar com o próprio Git.
