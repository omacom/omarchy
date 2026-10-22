# Ferramentas de desenvolvimento

## Editores alternativos

O Omarchy vem com o [Neovim](https://neovim.io/) por padrão, mas se você quiser algo um pouco mais comum e familiar, pode abrir o Menu do Omarchy (`Super + Space`) e ver as opções em _Instalar > Editor_. Temos VSCode, Cursor, Zed, Sublime Text, Helix, Vim e Emacs listados lá. Se você não encontrar o que procura, confira _Instalar > Pacote_ e veja se ele não está em um pacote do Arch (e, se não estiver, tente _Instalar > AUR_ para verificar o AUR).

O editor `vi` original também está disponível por padrão. Execute `vi filename` para editar um arquivo no terminal.

A correspondência de tema é oferecida para `VSCode`, `Cursor`, `VSCodium` e `Helix`.

Você pode definir o editor padrão de todo o sistema em `Setup > Defaults > Editor`.

## Ambiente

O Omarchy permite configurar uma grande variedade de ambientes de desenvolvimento pela seção _Instalar > Desenvolvimento_ do Menu do Omarchy (`Super + Space`). Você encontrará, é claro, o _Ruby on Rails_, mas também os três principais runtimes de JavaScript (Node.js, Bun, Deno), além de frameworks PHP populares como Laravel e Symfony. Ah, e também há Go, Rust, Python, Java, Elixir (com Phoenix), .NET, OCaml, Zig, Clojure e Scala. É uma seleção bem ampla!

A maioria desses ambientes é gerenciada pelo [Mise](https://mise.jdx.dev/). É uma ferramenta que permite instalar e executar várias versões de uma linguagem de programação na mesma máquina. É como o rbenv ou o rvm para o Ruby ou o virtualenv para o Python, mas funciona para vários ambientes diferentes.

Para instalar, digamos, o Ruby, você executaria `mise use -g ruby`, o que instala o Ruby e o define como o padrão global. Ou, se o seu projeto tiver um arquivo .ruby-version, você pode simplesmente executar `mise i` na raiz desse projeto.

## Docker

O [Docker](https://www.docker.com/) dispensa apresentações. Ele permite executar contêineres isolados, e o Omarchy instala tudo o que é necessário para executá-lo bem, incluindo o próprio Docker e o [Docker Compose](https://docs.docker.com/compose/).

Por padrão, seu usuário *não* está no grupo `docker`. Esse grupo é, na prática, root sem senha — qualquer coisa nele pode executar `docker run -v /:/host` e tomar conta da máquina — então um único script ou dependência maliciosa executada como você estaria a um comando de distância do root. Por isso, na linha de comando você executa o Docker com `sudo` (`sudo docker ps`, `sudo docker compose up`), e as ferramentas gráficas que conversam com o daemon — a VM do Windows — pedem autorização quando precisam. Se você quiser a conveniência de uma configuração sem grupo de volta e entender o compromisso, ative-a em **Setup > Security > Sudoless Docker** (ou execute `omarchy-setup-security-sudoless-docker`), o que o adiciona ao grupo `docker` após um aviso; depois, o `docker` puro e o alias `d` voltam a funcionar sem `sudo`.

Você pode configurar os bancos de dados comuns para desenvolvimento local no Docker usando _Instalar > Desenvolvimento > Docker DB_ no menu do Omarchy.

## GitHub CLI

[A GitHub CLI](https://cli.github.com/) permite que você se autentique com sua conta do GitHub e clone repositórios privados com ela. Ela está conectada como um dos stubs do mise com carregamento preguiçoso, então a primeira vez que você executar `gh`, ela se instala sozinha. Para se autenticar, execute `gh auth login`. Depois, você pode clonar repositórios privados usando `gh repo clone org/repo`.

Você também pode realizar várias outras operações do GitHub com esse comando. Basta executar `gh` para ver tudo o que é possível.

Há também um stub de instalação preguiçosa para o `ghui`, para gerenciar seus pull requests em uma TUI. E o [lazygit](https://github.com/jesseduffield/lazygit) vem pré-instalado, caso você queira controlar o próprio git a partir de uma TUI também.
