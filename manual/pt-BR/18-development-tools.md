# Ferramentas de Desenvolvimento

## Editores Alternativos

O Omarchy vem com o Plain como editor padrão nas novas instalações e com o [Neovim](https://neovim.io/) pré-instalado, mas se você quiser algo um pouco mais mainstream e familiar, pode abrir o Omarchy Menu (`Super + Space`) e ver as opções em _Install > Editor_. Temos VSCode, Cursor, Zed, Sublime Text, Helix, Vim e Emacs listados lá. Se não encontrar o que procura, confira _Install > Package_ e veja se não está em um pacote do Arch (e, se não estiver, tente _Install > AUR_ para verificar no AUR).

O editor `vi` original também está disponível de fábrica. Execute `vi filename` para editar um arquivo no terminal.

A correspondência de tema é oferecida para `VSCode`, `Cursor`, `VSCodium` e `Helix`.

Você pode definir o editor padrão de todo o sistema em `Setup > Defaults > Editor`.

## Ambiente

O Omarchy permite configurar uma porção de ambientes de desenvolvimento pela seção _Install > Development_ do Omarchy Menu (`Super + Space`). Você vai encontrar, é claro, o _Ruby on Rails_, mas também os três principais runtimes para JavaScript (Node.js, Bun, Deno), além de frameworks PHP populares como Laravel e Symfony. Ah, e também tem Go, Rust, Python, Java, Elixir (com Phoenix), .NET, OCaml, Zig, Clojure e Scala. É uma seleção bem ampla!

A maioria desses ambientes é gerenciada pelo [Mise](https://mise.jdx.dev/). É uma ferramenta que permite instalar e executar várias versões de uma linguagem de programação na mesma máquina. É como o rbenv ou o rvm para Ruby ou o virtualenv para Python, mas funciona para um monte de ambientes diferentes.

Para instalar, digamos, o Ruby, você executaria `mise use -g ruby`, o que vai instalar o Ruby e defini-lo como padrão global. Ou, se o seu projeto tiver um arquivo .ruby-version, basta executar `mise i` na raiz desse projeto.

## Ferramentas de CLI Pré-instaladas

`uv`, Node.js e `playwright-cli` (para os agentes controlarem um navegador, usando o Chrome instalado) vêm instalados como pacotes, e o `omarchy update` os mantém atualizados junto com o resto do sistema. O [Hunk](https://github.com/modem-dev/hunk) e as CLIs do GitHub, Basecamp, Cloudflare e HEY estão a uma escolha de distância em _Install > CLI_, e os [agentes de programação](17-ai.md) em _Install > AI > CLI_.

O mise só gerencia os runtimes que você configura em _Install > Development_; o Omarchy não instala nada por ele por conta própria. Execute `omarchy update` para atualizá-los junto com o resto do Omarchy; o alias `mup` atualiza somente as ferramentas gerenciadas pelo mise. Para adicionar outra ferramenta à sua própria configuração, use `mise use -g <tool>`.

## Docker

O [Docker](https://www.docker.com/) dispensa apresentações. Ele permite executar contêineres isolados, e o Omarchy instala tudo o que é necessário para rodá-lo bem, incluindo o próprio Docker e o [Docker Compose](https://docs.docker.com/compose/).

Por padrão, seu usuário *não* está no grupo `docker`. Esse grupo é, na prática, root sem senha — qualquer coisa nele pode executar `docker run -v /:/host` e tomar conta da máquina —, então um único script ou dependência maliciosa rodando como você estaria, de outro modo, a um comando de distância do root. Por isso, na linha de comando você roda o Docker com `sudo` (`sudo docker ps`, `sudo docker compose up`), e as ferramentas gráficas que falam com o daemon — a VM do Windows — pedem autorização quando precisam. Se você quiser de volta a conveniência de uma configuração sem grupo e entende o compromisso envolvido, ative-a em **Setup > Security > Sudoless Docker** (ou execute `omarchy-setup-security-sudoless-docker`), o que adiciona você ao grupo `docker` depois de um aviso; aí o `docker` puro e o alias `d` voltam a funcionar sem `sudo`.

Você pode configurar os bancos de dados comuns para desenvolvimento local no Docker usando _Install > Development > Docker DB_ no menu do Omarchy.

## GitHub CLI

O [GitHub CLI](https://cli.github.com/) é o `gh`, para trabalhar com repositórios, issues e pull requests pelo terminal. _Setup > Git_ o instala quando você escolhe entrar no GitHub por lá, ou instale-o separadamente em _Install > CLI > GitHub_. Então `gh repo clone org/repo` clona um repositório; execute `gh --help` para explorar seus comandos.

O [Lazygit](https://github.com/jesseduffield/lazygit) vem pré-instalado para trabalhar com o próprio Git.
