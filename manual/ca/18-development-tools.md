# Eines de desenvolupament

## Editors alternatius

Omarchy ve amb Plain com a editor per defecte en les instal·lacions noves i [Neovim](https://neovim.io/) preinstal·lat, però si voleu alguna cosa una mica més convencional i familiar, podeu obrir el Menú d'Omarchy (`Super + Space`) i veure les opcions a _Install > Editor_. Hi tenim VSCode, Cursor, Zed, Sublime Text, Helix, Vim i Emacs. Si no trobeu el que busqueu, mireu _Install > Package_ i comproveu si no és en un paquet d'Arch (i si no, proveu _Install > AUR_ per comprovar l'AUR).

L'editor `vi` original també està disponible de sèrie. Executeu `vi filename` per editar un fitxer al terminal.

S'ofereix la coincidència de tema per a `VSCode`, `Cursor`, `VSCodium` i `Helix`.

Podeu definir l'editor per defecte de tot el sistema a `Setup > Defaults > Editor`.

## Entorn

Omarchy permet configurar un munt d'entorns de desenvolupament des de la secció _Install > Development_ del Menú d'Omarchy (`Super + Space`). Hi trobareu, és clar, _Ruby on Rails_, però també els tres principals entorns d'execució per a JavaScript (Node.js, Bun, Deno), així com frameworks populars de PHP com Laravel i Symfony. Ah, i també hi ha Go, Rust, Python, Java, Elixir (amb Phoenix), .NET, OCaml, Zig, Clojure i Scala. És una selecció molt àmplia!

La majoria d'aquests entorns es gestionen amb [Mise](https://mise.jdx.dev/). És una eina que us permet instal·lar i executar diverses versions d'un llenguatge de programació a la mateixa màquina. És com rbenv o rvm per a Ruby o virtualenv per a Python, però funciona per a un munt d'entorns diferents.

Per instal·lar, posem per cas, Ruby, executaríeu `mise use -g ruby`, que tant instal·larà Ruby com el definirà com a valor per defecte global. O, si el vostre projecte té un fitxer .ruby-version, podeu executar simplement `mise i` a l'arrel d'aquest projecte.

## Eines CLI preinstal·lades

`uv`, Node.js i `playwright-cli` (perquè els agents puguin controlar un navegador, amb el Chrome instal·lat) vénen instal·lats com a paquets, i `omarchy update` els manté al dia amb la resta del sistema. [Hunk](https://github.com/modem-dev/hunk) i les CLI de GitHub, Basecamp, Cloudflare i HEY són a una tria de distància a _Install > CLI_, i els [agents de programació](17-ai.md) a _Install > AI > CLI_.

mise només gestiona els entorns d'execució que configureu des d'_Install > Development_; Omarchy no hi instal·la res pel seu compte. Executeu `omarchy update` per actualitzar-los amb la resta d'Omarchy; l'àlies `mup` actualitza només les eines gestionades per mise. Per afegir una altra eina a la vostra pròpia configuració, feu servir `mise use -g <tool>`.

## Docker

[Docker](https://www.docker.com/) gairebé no necessita presentació. Us permet executar contenidors aïllats, i Omarchy instal·la tot el que cal per fer-lo funcionar bé, incloent-hi Docker mateix i [Docker Compose](https://docs.docker.com/compose/).

Per defecte, el vostre usuari *no* és al grup `docker`. Aquest grup és, en la pràctica, root sense contrasenya — qualsevol que hi sigui pot executar `docker run -v /:/host` i apoderar-se de la màquina —, així que un sol script o dependència malintencionat que s'executés com a vós altrament estaria a una sola ordre de ser root. Així doncs, a la línia d'ordres executeu Docker amb `sudo` (`sudo docker ps`, `sudo docker compose up`), i les eines gràfiques que parlen amb el dimoni — la VM de Windows — demanen autorització quan la necessiten. Si voleu recuperar la comoditat d'una configuració sense grup i enteneu el compromís, activeu-la des de **Setup > Security > Sudoless Docker** (o executeu `omarchy-setup-security-sudoless-docker`), que us afegeix al grup `docker` després d'un avís; aleshores `docker` a seques i l'àlies `d` tornen a funcionar sense `sudo`.

Podeu configurar les bases de dades habituals per al desenvolupament local a Docker amb _Install > Development > Docker DB_ al menú d'Omarchy.

## GitHub CLI

[GitHub CLI](https://cli.github.com/) és `gh`, per treballar amb repositoris, incidències i pull requests des del terminal. _Setup > Git_ l'instal·la quan trieu iniciar sessió a GitHub allà, o instal·leu-lo per separat des d'_Install > CLI > GitHub_. Aleshores `gh repo clone org/repo` clona un repositori; executeu `gh --help` per explorar-ne les ordres.

[Lazygit](https://github.com/jesseduffield/lazygit) ve preinstal·lat per treballar amb Git mateix.
