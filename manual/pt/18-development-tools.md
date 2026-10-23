# Ferramentas de desenvolvimento

## Editores alternativos

O Omarchy vem com o [Neovim](https://neovim.io/) por predefinição, mas se quiseres algo um pouco mais comum e familiar, podes abrir o menu Omarchy (`Super + Space`) e ver as opções em _Instalar > Editor_. Temos lá o VSCode, o Cursor, o Zed, o Sublime Text, o Helix, o Vim e o Emacs. Se não encontrares o que procuras, passa por _Instalar > Pacote_ e vê se não existe num pacote Arch (e, se não existir, experimenta _Instalar > AUR_ para consultar o AUR).

O editor `vi` original também está disponível de origem. Executa `vi filename` para editar um ficheiro no terminal.

A correspondência de tema é disponibilizada para `VSCode`, `Cursor`, `VSCodium` e `Helix`.

Podes definir o editor predefinido para todo o sistema em `Configurar > Predefinições > Editor`.

## Ambiente

O Omarchy permite configurar uma grande variedade de ambientes de desenvolvimento através da secção _Instalar > Desenvolvimento_ do menu Omarchy (`Super + Space`). Encontras lá, claro, o _Ruby on Rails_, mas também os três principais runtimes de JavaScript (Node.js, Bun, Deno), bem como frameworks PHP populares como o Laravel e o Symfony. Ah, e também há Go, Rust, Python, Java, Elixir (com Phoenix), .NET, OCaml, Zig, Clojure e Scala. É uma seleção muito abrangente!

A maioria destes ambientes é gerida pelo [Mise](https://mise.jdx.dev/). É uma ferramenta que te permite instalar e executar várias versões de uma linguagem de programação na mesma máquina. É como o rbenv ou o rvm para Ruby ou o virtualenv para Python, mas funciona para uma série de ambientes diferentes.

Para instalar, digamos, o Ruby, executas `mise use -g ruby`, o que instala o Ruby e o define como predefinição global. Ou, se o teu projeto tiver um ficheiro .ruby-version, podes simplesmente executar `mise i` na raiz desse projeto.

## Docker

O [Docker](https://www.docker.com/) dispensa apresentações. Permite-te executar contentores isolados, e o Omarchy instala tudo o que é preciso para o executar bem, incluindo o próprio Docker e o [Docker Compose](https://docs.docker.com/compose/).

Por predefinição, o teu utilizador *não* pertence ao grupo `docker`. Esse grupo equivale, na prática, a root sem palavra-passe — qualquer coisa nele pode executar `docker run -v /:/host` e tomar conta da máquina —, por isso um único script ou dependência malicioso a correr como tu ficaria, de outra forma, a um comando de distância do root. Assim, na linha de comandos executas o Docker com `sudo` (`sudo docker ps`, `sudo docker compose up`), e as ferramentas gráficas que falam com o daemon — a VM Windows — pedem autorização quando precisam dela. Se quiseres recuperar a conveniência de uma configuração sem grupo e perceberes o compromisso, ativa-a em **Configurar > Segurança > Docker sem sudo** (ou executa `omarchy-setup-security-sudoless-docker`), o que te adiciona ao grupo `docker` depois de um aviso; a partir daí, o `docker` simples e o alias `d` voltam a funcionar sem `sudo`.

Podes configurar as bases de dados comuns para desenvolvimento local no Docker usando _Instalar > Desenvolvimento > Docker DB_ no menu Omarchy.

## GitHub CLI

[O GitHub CLI](https://cli.github.com/) permite-te autenticar com a tua conta GitHub e clonar repositórios privados com ele. Está ligado como um dos stubs de carregamento preguiçoso do mise, por isso, da primeira vez que executares `gh`, ele instala-se sozinho. Para te autenticares, executa `gh auth login`. Depois podes fazer checkout de repositórios privados com `gh repo clone org/repo`.

Também podes fazer uma série de outras operações do GitHub com este comando. Basta executares `gh` para veres tudo o que é possível.

Existe também um stub de instalação preguiçosa para o `ghui`, para gerires os teus pull requests numa TUI. E o [lazygit](https://github.com/jesseduffield/lazygit) vem pré-instalado, se também quiseres controlar o próprio git a partir de uma TUI.
