# Ferramentas de Desenvolvimento

## Editores Alternativos

O Omarchy vem com o [Neovim](https://neovim.io/) por predefinição, mas se quiser algo um pouco mais convencional e familiar, pode abrir o Menu Omarchy (`Super + Space`) e ver as opções em _Instalar > Editor_. Temos VSCode, Cursor, Zed, Sublime Text, Helix, Vim e Emacs listados aí. Se não encontrar o que procura, veja _Instalar > Pacote_ e verifique se não está num pacote Arch (e, se não estiver, experimente _Instalar > AUR_ para verificar o AUR).

O editor `vi` original também está disponível de imediato. Execute `vi filename` para editar um ficheiro no terminal.

A correspondência de temas está disponível para `VSCode`, `Cursor`, `VSCodium` e `Helix`.

Pode definir o editor predefinido para todo o sistema em `Setup > Defaults > Editor`.

## Ambiente

O Omarchy permite configurar uma grande variedade de ambientes de desenvolvimento através da secção _Instalar > Desenvolvimento_ do Menu Omarchy (`Super + Space`). É claro que vai encontrar _Ruby on Rails_, mas também os três principais ambientes de execução para JavaScript (Node.js, Bun, Deno), bem como frameworks PHP populares como Laravel e Symfony. Ah, e também há Go, Rust, Python, Java, Elixir (com Phoenix), .NET, OCaml, Zig, Clojure e Scala. É uma seleção muito ampla!

A maioria destes ambientes é gerida pelo [Mise](https://mise.jdx.dev/). É uma ferramenta que permite instalar e executar várias versões de uma linguagem de programação na mesma máquina. É como o rbenv ou o rvm para Ruby ou o virtualenv para Python, mas funciona para uma série de ambientes diferentes.

Para instalar, por exemplo, Ruby, execute `mise use -g ruby`, o que instala o Ruby e o define como predefinição global. Ou, se o seu projeto tiver um ficheiro .ruby-version, basta executar `mise i` na raiz desse projeto.

## Ferramentas de CLI pré-instaladas

O Omarchy disponibiliza ferramentas como `gh`, `uv` e a maioria dos [agentes de programação](17-ai.md) através da [instalação lazy do mise](https://mise.jdx.dev/dev-tools/shims.html#lazy-tools). Na primeira vez que executa uma delas, o mise instala-a. As execuções posteriores reutilizam a versão instalada; não verificam se há uma atualização em cada arranque.

Também pode inspecionar as predefinições ou instalá-las antecipadamente:

```bash
mise ls --current              # List the tools configured for this directory
mise install gh               # Install one tool now
mise install --include-lazy    # Install all configured tools, including lazy tools
```

Execute `omarchy update` para atualizar as ferramentas instaladas juntamente com o resto do Omarchy. O alias `mup` atualiza apenas as ferramentas geridas pelo mise. Para adicionar outra ferramenta à sua própria configuração, utilize `mise use -g <tool>`.

A configuração do Python também instala o `uv` através do mise. Remover o ambiente de desenvolvimento Python mantém o `uv` disponível como ferramenta independente.

### Utilizar a sua própria instalação

Os comandos do mise vêm antes de `~/.local/bin` no `PATH`, pelo que uma ferramenta que tenha instalado por si, por exemplo com o instalador do Claude Code ou do Cursor, continua a executar a cópia do mise. As aplicações lançadas a partir do ambiente de trabalho também encontram os comandos do mise antes dos pacotes do sistema, pelo que uma aplicação que execute `gh` obtém a cópia do mise mesmo que tenha instalado `github-cli` com o pacman, e o mise instala essa cópia na primeira vez. Para utilizar a sua, desative a cópia do mise em `~/.config/mise/config.toml`. Por exemplo, se instalou o Cursor CLI por si:

```toml
[settings]
disable_tools = ["cursor-agent"]
```

Se já tiver uma tabela `[settings]`, adicione a entrada aí; estenda uma lista `disable_tools` existente em vez de a substituir. Certifique-se de que a sua instalação está no `PATH`. Utilize o nome da ferramenta do mise, que pode ser diferente do seu comando: o `oh-my-pi` fornece `omp`, por exemplo. O lançador do agente predefinido também prefere um Cursor ou Muse instalado pelo utilizador em `~/.local/bin`.

### Remover e restaurar predefinições

_Remover Pré-instalações_ faz com que o mise ignore as declarações de ferramentas do Omarchy para o seu utilizador, adicionando-as a `ignored_config_paths` em `~/.config/mise/miserc.toml`. _Restaurar Pré-instalações_ remove novamente essa linha. As ferramentas que declarar por si, na sua própria configuração ou num `mise.toml` de um projeto, continuam a funcionar em qualquer dos casos. Se escolher um agente predefinido ou configurar o Python depois de remover as pré-instalações, essa ferramenta é adicionada à sua própria configuração. Ambas se aplicam apenas ao seu utilizador; os outros utilizadores na máquina mantêm a sua própria escolha.

## Docker

O [Docker](https://www.docker.com/) dispensa apresentações. Permite executar contentores isolados, e o Omarchy instala tudo o que é necessário para o executar bem, incluindo o próprio Docker e o [Docker Compose](https://docs.docker.com/compose/).

Por predefinição, o seu utilizador *não* está no grupo `docker`. Esse grupo é, na prática, root sem palavra-passe — qualquer coisa nele pode executar `docker run -v /:/host` e tomar conta da máquina —, pelo que um único script ou dependência maliciosa a ser executado como o seu utilizador ficaria, de outra forma, a um comando de distância de root. Assim, na linha de comandos, executa o Docker com `sudo` (`sudo docker ps`, `sudo docker compose up`), e as ferramentas gráficas que comunicam com o daemon — a VM Windows — pedem autorização quando precisam dela. Se quiser recuperar a comodidade de uma configuração sem grupos e compreender o compromisso, ative-a em **Configuração > Segurança > Docker sem sudo** (ou execute `omarchy-setup-security-sudoless-docker`), que o adiciona ao grupo `docker` depois de um aviso; depois disso, o `docker` simples e o alias `d` voltam a funcionar sem `sudo`.

Pode configurar as bases de dados comuns para desenvolvimento local no Docker através de _Instalar > Desenvolvimento > Docker DB_ no menu Omarchy.

## GitHub CLI

O [GitHub CLI](https://cli.github.com/) está disponível como `gh` para trabalhar com repositórios, issues e pull requests a partir do terminal. Execute `gh auth login` para o instalar na primeira utilização e autenticar-se, e depois `gh repo clone org/repo` para clonar um repositório. Execute `gh --help` para explorar os seus comandos.

Para uma interface de terminal para pull requests, execute `ghui`; o mise também o instala na primeira utilização. O [Lazygit](https://github.com/jesseduffield/lazygit) vem pré-instalado para trabalhar com o próprio Git.
