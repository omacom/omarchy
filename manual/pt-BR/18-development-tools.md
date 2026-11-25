# Ferramentas de Desenvolvimento

## Editores Alternativos

O Omarchy vem com o Plain como editor padrão nas novas instalações e com o [Neovim](https://neovim.io/) pré-instalado, mas, se você quiser algo um pouco mais convencional e familiar, pode abrir o Menu do Omarchy (`Super + Space`) e ver as opções em _Install > Editor_. Temos VSCode, Cursor, Zed, Sublime Text, Helix, Vim e Emacs listados ali. Se não encontrar o que procura, confira _Install > Package_ e veja se ele não está em um pacote do Arch (e, se não estiver, tente _Install > AUR_ para verificar na AUR).

O editor `vi` original também está disponível de fábrica. Execute `vi filename` para editar um arquivo no terminal.

A correspondência de tema é oferecida para `VSCode`, `Cursor`, `VSCodium` e `Helix`.

Você pode definir o editor padrão de todo o sistema em `Setup > Defaults > Editor`.

## Ambiente

O Omarchy oferece suporte à configuração de uma grande variedade de ambientes de desenvolvimento por meio da seção _Install > Development_ do Menu do Omarchy (`Super + Space`). Você encontrará, é claro, o _Ruby on Rails_, mas também os três principais runtimes de JavaScript (Node.js, Bun, Deno), além de frameworks PHP populares como Laravel e Symfony. Ah, e também há Go, Rust, Python, Java, Elixir (com Phoenix), .NET, OCaml, Zig, Clojure e Scala. É uma seleção bem ampla!

A maioria desses ambientes é gerenciada pelo [Mise](https://mise.jdx.dev/). É uma ferramenta que permite instalar e executar várias versões de uma linguagem de programação na mesma máquina. É como o rbenv ou o rvm para Ruby ou o virtualenv para Python, mas funciona para vários ambientes diferentes.

Para instalar, digamos, o Ruby, você executaria `mise use -g ruby`, que instalará o Ruby e o definirá como padrão global. Ou, se o seu projeto tiver um arquivo .ruby-version, você pode simplesmente executar `mise i` na raiz desse projeto.

## Ferramentas de CLI pré-instaladas

`uv`, Node.js e `playwright-cli` (para que agentes dirijam um navegador, usando o Chrome instalado) vêm instalados como pacotes, e o `omarchy update` os mantém atualizados com o restante do sistema. `ghui`, [Hunk](https://github.com/modem-dev/hunk) e as CLIs do Basecamp, do Cloudflare e do HEY estão a uma escolha de distância em _Install > CLI_, e os [agentes de código](17-ai.md) em _Install > AI > CLI_.

A mise gerencia apenas os runtimes que você configura em _Install > Development_; o Omarchy não instala nada por meio dela por conta própria. Execute `omarchy update` para atualizá-los com o restante do Omarchy; o alias `mup` atualiza apenas as ferramentas gerenciadas pela mise. Para adicionar outra ferramenta à sua própria configuração, use `mise use -g <tool>`.

## Docker

O [Docker](https://www.docker.com/) dispensa apresentações. Ele permite executar contêineres isolados, e o Omarchy instala tudo o que é necessário para executá-lo bem, incluindo o próprio Docker e o [Docker Compose](https://docs.docker.com/compose/).

Por padrão, seu usuário *não* está no grupo `docker`. Esse grupo é, na prática, root sem senha — qualquer coisa nele pode executar `docker run -v /:/host` e tomar conta da máquina —, então um único script ou dependência maliciosa executando como você estaria, de outra forma, a um comando de distância do root. Por isso, na linha de comando, você executa o Docker com `sudo` (`sudo docker ps`, `sudo docker compose up`), e as ferramentas gráficas que se comunicam com o daemon — a VM do Windows — pedem autorização quando precisam. Se você quiser a conveniência de uma configuração sem grupo de volta e entender o que está abrindo mão, ative-a em **Setup > Security > Sudoless Docker** (ou execute `omarchy-setup-security-sudoless-docker`), que adiciona você ao grupo `docker` após um aviso; então o `docker` simples e o alias `d` voltam a funcionar sem `sudo`.

Você pode configurar os bancos de dados comuns para desenvolvimento local no Docker usando _Install > Development > Docker DB_ no menu do Omarchy.

## GitHub CLI

O [GitHub CLI](https://cli.github.com/) é o `gh`, para trabalhar com repositórios, issues e pull requests a partir do terminal. _Setup > Git_ o instala quando você opta por entrar no GitHub ali, e então `gh repo clone org/repo` clona um repositório. Execute `gh --help` para explorar seus comandos.

_Install > CLI > GitHub_ instala o GitHub CLI, o `gh`, junto com o `ghui`, uma interface de terminal para pull requests. O [Lazygit](https://github.com/jesseduffield/lazygit) vem pré-instalado para trabalhar com o próprio Git.
