# Eines de desenvolupament

## Editors alternatius

Omarchy inclou Plain com a editor per defecte en les instal·lacions noves i [Neovim](https://neovim.io/) preinstal·lat, però si vols alguna cosa una mica més convencional i familiar, pots obrir el menú d'Omarchy (`Super + Space`) i consultar les opcions a _Instal·la > Editor_. Hi tenim VSCode, Cursor, Zed, Sublime Text, Helix, Vim i Emacs. Si no trobes el que busques, fes una ullada a _Instal·la > Paquet_ i comprova si no hi és com a paquet d'Arch (i si no hi és, prova _Instal·la > AUR_ per comprovar l'AUR).

L'editor `vi` original també està disponible de sèrie. Executa `vi filename` per editar un fitxer al terminal.

S'ofereix coincidència de tema per a `VSCode`, `Cursor`, `VSCodium` i `Helix`.

Pots definir l'editor per defecte de tot el sistema a `Setup > Defaults > Editor`.

## Entorn

Omarchy permet configurar tota una pila d'entorns de desenvolupament mitjançant la secció _Instal·la > Desenvolupament_ del menú d'Omarchy (`Super + Space`). Hi trobaràs, evidentment, _Ruby on Rails_, però també els tres entorns d'execució principals per a JavaScript (Node.js, Bun, Deno), així com frameworks populars de PHP com Laravel i Symfony. Ah, i també hi ha Go, Rust, Python, Java, Elixir (amb Phoenix), .NET, OCaml, Zig, Clojure i Scala. És una selecció molt àmplia!

La majoria d'aquests entorns es gestionen amb [Mise](https://mise.jdx.dev/). És una eina que et permet instal·lar i executar diverses versions d'un llenguatge de programació a la mateixa màquina. És com rbenv o rvm per a Ruby o virtualenv per a Python, però funciona per a un munt d'entorns diferents.

Per instal·lar, per exemple, Ruby, executaries `mise use -g ruby`, que instal·larà Ruby i el definirà com a valor per defecte global. O, si el teu projecte té un fitxer .ruby-version, pots executar simplement `mise i` a l'arrel d'aquest projecte.

## Eines CLI preinstal·lades

`uv`, Node.js i `playwright-cli` (perquè els agents controlin un navegador, amb el Chrome instal·lat) vénen instal·lats com a paquets, i `omarchy update` els manté actualitzats amb la resta del sistema. `ghui`, [Hunk](https://github.com/modem-dev/hunk) i les CLI de Basecamp, Cloudflare i HEY són a una tria de distància a _Instal·la > CLI_, i els [agents de programació](17-ai.md) a _Instal·la > AI > CLI_.

mise només gestiona els entorns d'execució que configures des de _Instal·la > Desenvolupament_; Omarchy no instal·la res per si mateix a través d'ell. Executa `omarchy update` per actualitzar-los amb la resta d'Omarchy; l'àlies `mup` actualitza només les eines gestionades per mise. Per afegir una altra eina a la teva pròpia configuració, utilitza `mise use -g <tool>`.

## Docker

[Docker](https://www.docker.com/) gairebé no necessita presentació. Et permet executar contenidors aïllats, i Omarchy instal·la tot el necessari perquè funcioni bé, incloent-hi Docker mateix i [Docker Compose](https://docs.docker.com/compose/).

Per defecte, el teu usuari *no* és al grup `docker`. Aquest grup és, en la pràctica, root sense contrasenya — qualsevol cosa que en formi part pot executar `docker run -v /:/host` i prendre el control de la màquina —, de manera que un sol script o dependència malintencionats que s'executessin com a tu estarien, en cas contrari, a una sola ordre de ser root. Així doncs, a la línia d'ordres executes Docker amb `sudo` (`sudo docker ps`, `sudo docker compose up`), i les eines gràfiques que es comuniquen amb el dimoni — la VM de Windows — demanen autorització quan la necessiten. Si vols recuperar la comoditat d'una configuració sense grup i entens el compromís que suposa, activa-la des de **Configuració > Seguretat > Sudoless Docker** (o executa `omarchy-setup-security-sudoless-docker`), que t'afegeix al grup `docker` després d'un avís; aleshores el `docker` normal i l'àlies `d` tornen a funcionar sense `sudo`.

Pots configurar les bases de dades habituals per al desenvolupament local a Docker mitjançant _Instal·la > Desenvolupament > Docker DB_ al menú d'Omarchy.

## GitHub CLI

[GitHub CLI](https://cli.github.com/) és `gh`, per treballar amb repositoris, incidències i pull requests des del terminal. _Configuració > Git_ l'instal·la quan tries iniciar sessió a GitHub allà, i després `gh repo clone org/repo` clona un repositori. Executa `gh --help` per explorar-ne les ordres.

_Instal·la > CLI > GitHub_ instal·la la GitHub CLI, `gh`, juntament amb `ghui`, una interfície de terminal per a pull requests. [Lazygit](https://github.com/jesseduffield/lazygit) ve preinstal·lat per treballar amb Git mateix.
