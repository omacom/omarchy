# Ferramentas de Desenvolvimento

## Editores Alternativos

O Omarchy inclui o Plain como editor predefinido nas novas instalações e o [Neovim](https://neovim.io/) pré-instalado, mas se quiser algo um pouco mais convencional e familiar, pode executar o Omarchy Menu (`Super + Space`) e ver as opções em _Install > Editor_. Temos lá o VSCode, o Cursor, o Zed, o Sublime Text, o Helix, o Vim e o Emacs. Se não encontrar o que procura, consulte _Install > Package_ e veja se não está num pacote Arch (e, se não estiver, experimente _Install > AUR_ para verificar o AUR).

O editor `vi` original também está disponível de origem. Execute `vi filename` para editar um ficheiro no terminal.

A correspondência de temas está disponível para `VSCode`, `Cursor`, `VSCodium` e `Helix`.

Pode definir o editor predefinido para todo o sistema em `Setup > Defaults > Editor`.

## Ambiente

O Omarchy permite configurar uma grande variedade de ambientes de desenvolvimento através da secção _Install > Development_ do Omarchy Menu (`Super + Space`). É claro que vai encontrar o _Ruby on Rails_, mas também os três principais runtimes para JavaScript (Node.js, Bun, Deno), bem como frameworks PHP populares como o Laravel e o Symfony. Ah, e também há Go, Rust, Python, Java, Elixir (com Phoenix), .NET, OCaml, Zig, Clojure e Scala. É uma seleção mesmo muito abrangente!

A maioria destes ambientes é gerida pelo [Mise](https://mise.jdx.dev/). É uma ferramenta que lhe permite instalar e executar várias versões de uma linguagem de programação na mesma máquina. É como o rbenv ou o rvm para Ruby ou o virtualenv para Python, mas funciona para uma série de ambientes diferentes.

Para instalar, por exemplo, o Ruby, executaria `mise use -g ruby`, que instala o Ruby e o define como predefinição global. Ou, se o seu projeto tiver um ficheiro .ruby-version, pode simplesmente executar `mise i` na raiz desse projeto.

## Ferramentas CLI pré-instaladas

O Omarchy disponibiliza ferramentas como `gh`, `uv` e a maioria dos [agentes de programação](17-ai.md) através da [instalação lazy do mise](https://mise.jdx.dev/dev-tools/shims.html#lazy-tools). Na primeira vez que executar uma, o mise instala-a. Depois, os agentes de programação verificam se existe uma atualização antes de serem executados, no máximo uma vez a cada quatro horas; as outras ferramentas, como `gh` e `uv`, reutilizam a versão instalada até as atualizar.

Também pode inspecionar as predefinições ou instalá-las antecipadamente:

```bash
mise ls --current              # List the tools configured for this directory
mise install gh               # Install one tool now
mise install --include-lazy    # Install all configured tools, including lazy tools
```

Execute `omarchy update` para atualizar as ferramentas instaladas juntamente com o resto do Omarchy. O alias `mup` atualiza apenas as ferramentas geridas pelo mise. Para adicionar outra ferramenta à sua própria configuração, utilize `mise use -g <tool>`.

A configuração do Python também instala o `uv` através do mise. Remover o ambiente de desenvolvimento Python mantém o `uv` disponível como ferramenta independente.

### Utilizar a sua própria instalação

Os comandos do mise vêm antes de `~/.local/bin` no `PATH`, por isso uma ferramenta que tenha instalado por si, por exemplo com o instalador do próprio Claude Code ou do Cursor, continua a executar a cópia do mise. As aplicações lançadas a partir do ambiente de trabalho também encontram os comandos do mise antes dos pacotes do sistema, por isso uma aplicação que execute `gh` obtém a cópia do mise mesmo que tenha instalado o `github-cli` com o pacman, e o mise instala essa cópia na primeira vez. Para utilizar a sua, desative a cópia do mise em `~/.config/mise/config.toml`. Por exemplo, se instalou o Cursor CLI por si:

```toml
[settings]
disable_tools = ["cursor-agent"]
```

Se já tiver uma tabela `[settings]`, adicione a entrada aí; aumente uma lista `disable_tools` existente em vez de a substituir. Certifique-se de que a sua instalação está no `PATH`. Utilize o nome da ferramenta do mise, que pode ser diferente do seu comando: o `oh-my-pi` disponibiliza o `omp`, por exemplo. O lançador do agente predefinido também prefere um Cursor ou Muse instalado pelo utilizador em `~/.local/bin`.

### Remover e restaurar predefinições

O _Remove > Preinstalls_ remove as aplicações web, as TUIs e as aplicações pré-instaladas do Omarchy e faz com que o mise ignore as declarações de ferramentas do Omarchy para o seu utilizador, ao adicioná-las a `ignored_config_paths` em `~/.config/mise/miserc.toml`. O _Install > Preinstalls_ volta a colocá-las e remove novamente essa linha. As ferramentas que declarar por si, na sua própria configuração ou num `mise.toml` de um projeto, continuam a funcionar em qualquer dos casos. Se escolher um agente predefinido ou configurar o Python depois de remover as pré-instalações, essa ferramenta é adicionada à sua própria configuração. A definição do mise aplica-se apenas ao seu utilizador e os outros utilizadores mantêm a sua própria escolha; as aplicações são pacotes, no entanto, por isso removê-las ou restaurá-las altera-as para todos na máquina.

## Docker

O [Docker](https://www.docker.com/) dispensa apresentações. Permite executar contentores isolados e o Omarchy instala tudo o que é necessário para o executar bem, incluindo o próprio Docker e o [Docker Compose](https://docs.docker.com/compose/).

Por predefinição, o seu utilizador *não* está no grupo `docker`. Esse grupo é, na prática, root sem palavra-passe — qualquer coisa nele pode executar `docker run -v /:/host` e tomar conta da máquina —, por isso um único script ou dependência maliciosa executado como o seu utilizador ficaria, de outra forma, a um comando de ser root. Assim, na linha de comandos, executa o Docker com `sudo` (`sudo docker ps`, `sudo docker compose up`), e as ferramentas gráficas que comunicam com o daemon — a Windows VM — pedem autorização quando dela precisam. Se quiser recuperar a conveniência de uma configuração sem sudo e compreender o compromisso, ative-a a partir de **Setup > Security > Sudoless Docker** (ou execute `omarchy-setup-security-sudoless-docker`), que o adiciona ao grupo `docker` depois de um aviso; depois, o `docker` simples e o alias `d` voltam a funcionar sem `sudo`.

Pode configurar as bases de dados comuns para desenvolvimento local no Docker utilizando _Install > Development > Docker DB_ no menu Omarchy.

## GitHub CLI

O [GitHub CLI](https://cli.github.com/) está disponível como `gh` para trabalhar com repositórios, issues e pull requests a partir do terminal. Execute `gh auth login` para o instalar na primeira utilização e autenticar-se e, depois, `gh repo clone org/repo` para clonar um repositório. Execute `gh --help` para explorar os seus comandos.

Para uma interface de terminal para pull requests, execute `ghui`; o mise também o instala na primeira utilização. O [Lazygit](https://github.com/jesseduffield/lazygit) está pré-instalado para trabalhar com o próprio Git.
