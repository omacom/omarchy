# Ferramentas de Desenvolvimento

## Editores Alternativos

O Omarchy traz o Plain como editor predefinido nas novas instalações e o [Neovim](https://neovim.io/) pré-instalado, mas se quiseres algo um pouco mais convencional e familiar, podes abrir o Omarchy Menu (`Super + Space`) e ver as opções em _Install > Editor_. Temos lá o VSCode, o Cursor, o Zed, o Sublime Text, o Helix, o Vim e o Emacs. Se não encontrares o que procuras, dá uma vista de olhos a _Install > Package_ e vê se não está num pacote Arch (e, se não estiver, experimenta _Install > AUR_ para verificares no AUR).

O editor `vi` original também está disponível de imediato. Executa `vi filename` para editares um ficheiro no terminal.

A correspondência de tema é oferecida para o `VSCode`, o `Cursor`, o `VSCodium` e o `Helix`.

Podes definir o editor predefinido para todo o sistema em `Setup > Defaults > Editor`.

## Ambiente

O Omarchy permite configurar uma série de ambientes de desenvolvimento através da secção _Install > Development_ do Omarchy Menu (`Super + Space`). Encontras, claro, o _Ruby on Rails_, mas também os três principais runtimes de JavaScript (Node.js, Bun, Deno), bem como frameworks PHP populares como o Laravel e o Symfony. Ah, e também há Go, Rust, Python, Java, Elixir (com Phoenix), .NET, OCaml, Zig, Clojure e Scala. É uma seleção muito ampla!

A maioria destes ambientes é gerida pelo [Mise](https://mise.jdx.dev/). É uma ferramenta que te permite instalar e executar várias versões de uma linguagem de programação na mesma máquina. É como o rbenv ou o rvm para Ruby, ou o virtualenv para Python, mas funciona com uma série de ambientes diferentes.

Para instalares, por exemplo, o Ruby, executas `mise use -g ruby`, o que instala o Ruby e o define como predefinição global. Ou, se o teu projeto tiver um ficheiro .ruby-version, podes simplesmente executar `mise i` na raiz desse projeto.

## Ferramentas CLI pré-instaladas

O `uv`, o Node.js e o `playwright-cli` (para os agentes controlarem um navegador, com o Chrome instalado) vêm instalados como pacotes, e o `omarchy update` mantém-nos atualizados juntamente com o resto do sistema. O `ghui`, o [Hunk](https://github.com/modem-dev/hunk) e as CLI da Basecamp, da Cloudflare e do HEY estão a um passo de distância em _Install > CLI_, e os [agentes de programação](17-ai.md) em _Install > AI > CLI_.

O mise só gere os runtimes que configurares a partir de _Install > Development_; por si só, o Omarchy não instala nada através dele. Executa `omarchy update` para os atualizares juntamente com o resto do Omarchy; o alias `mup` atualiza apenas as ferramentas geridas pelo mise. Para adicionares outra ferramenta à tua própria configuração, usa `mise use -g <tool>`.

## Docker

O [Docker](https://www.docker.com/) dispensa apresentações. Permite-te executar contentores isolados, e o Omarchy instala tudo o que é necessário para o executar bem, incluindo o próprio Docker e o [Docker Compose](https://docs.docker.com/compose/).

Por predefinição, o teu utilizador *não* está no grupo `docker`. Esse grupo é, na prática, root sem palavra-passe — qualquer coisa nele pode executar `docker run -v /:/host` e tomar conta da máquina — portanto, um simples script malicioso ou uma dependência a executar como tu estaria, de outro modo, a um comando de distância do root. Por isso, na linha de comandos, executas o Docker com `sudo` (`sudo docker ps`, `sudo docker compose up`), e as ferramentas gráficas que comunicam com o daemon — a VM Windows — pedem autorização quando precisam dela. Se quiseres de volta a comodidade de uma configuração sem grupo e compreenderes o compromisso, ativa-a em **Setup > Security > Sudoless Docker** (ou executa `omarchy-setup-security-sudoless-docker`), o que te adiciona ao grupo `docker` depois de um aviso; depois, o `docker` simples e o alias `d` voltam a funcionar sem `sudo`.

Podes configurar as bases de dados comuns para desenvolvimento local no Docker através de _Install > Development > Docker DB_ no menu Omarchy.

## GitHub CLI

O [GitHub CLI](https://cli.github.com/) é o `gh`, para trabalhares com repositórios, issues e pull requests a partir do terminal. O _Setup > Git_ instala-o quando optas por iniciar sessão no GitHub aí, e depois `gh repo clone org/repo` clona um repositório. Executa `gh --help` para explorares os seus comandos.

_Install > CLI > GitHub_ instala o GitHub CLI, o `gh`, juntamente com o `ghui`, uma interface de terminal para pull requests. O [Lazygit](https://github.com/jesseduffield/lazygit) vem pré-instalado para trabalhares com o próprio Git.
