# Eines de desenvolupament

## Editors alternatius

Omarchy ve amb [Neovim](https://neovim.io/) per defecte, però si vols alguna cosa una mica més convencional i familiar, pots obrir el menú d'Omarchy (`Super + Space`) i veure les opcions a _Instal·la > Editor_. Hi tenim VSCode, Cursor, Zed, Sublime Text, Helix, Vim i Emacs. Si no hi trobes el que busques, passa per _Instal·la > Paquet_ i mira si hi és com a paquet d'Arch (i si no, prova _Instal·la > AUR_ per consultar l'AUR).

L'editor `vi` original també està disponible de sèrie. Executa `vi filename` per editar un fitxer al terminal.

S'ofereix coincidència de tema per a `VSCode`, `Cursor`, `VSCodium` i `Helix`.

Pots definir l'editor per defecte de tot el sistema a `Configuració > Per defecte > Editor`.

## Entorn

Omarchy permet configurar una pila d'entorns de desenvolupament des de la secció _Instal·la > Desenvolupament_ del menú d'Omarchy (`Super + Space`). Hi trobaràs, és clar, _Ruby on Rails_, però també els tres entorns d'execució principals de JavaScript (Node.js, Bun i Deno), així com frameworks de PHP populars com Laravel i Symfony. Ah, i també hi ha Go, Rust, Python, Java, Elixir (amb Phoenix), .NET, OCaml, Zig, Clojure i Scala. És una selecció molt àmplia!

La majoria d'aquests entorns els gestiona [Mise](https://mise.jdx.dev/). És una eina que et permet instal·lar i executar versions múltiples d'un llenguatge de programació a la mateixa màquina. És com rbenv o rvm per a Ruby o virtualenv per a Python, però funciona per a un munt d'entorns diferents.

Per instal·lar, posem per cas, Ruby, executaries `mise use -g ruby`, que instal·la Ruby i el defineix com a opció global per defecte. O, si el teu projecte té un fitxer .ruby-version, pots executar directament `mise i` a l'arrel del projecte.

## Docker

De [Docker](https://www.docker.com/) gairebé no cal fer-ne presentacions. Et permet executar contenidors aïllats, i Omarchy instal·la tot el que cal perquè funcioni bé, incloent-hi el mateix Docker i [Docker Compose](https://docs.docker.com/compose/).

Per defecte, el teu usuari *no* és al grup `docker`. Aquest grup és, a la pràctica, root sense contrasenya — qualsevol cosa que hi sigui pot fer `docker run -v /:/host` i apoderar-se de la màquina —, de manera que un sol script o una dependència malintencionats que s'executin com tu estarien, altrament, a una ordre de distància de root. Per això, a la línia d'ordres executes Docker amb `sudo` (`sudo docker ps`, `sudo docker compose up`), i les eines gràfiques que parlen amb el dimoni — la màquina virtual de Windows — demanen autorització quan la necessiten. Si vols recuperar la comoditat d'una configuració sense grup i entens què hi perds a canvi, activa-la des de **Configuració > Seguretat > Docker sense sudo** (o executa `omarchy-setup-security-sudoless-docker`), que t'afegeix al grup `docker` després d'un avís; aleshores `docker` sol i l'àlies `d` tornen a funcionar sense `sudo`.

Pots configurar les bases de dades habituals per al desenvolupament local a Docker des d'_Instal·la > Desenvolupament > Docker DB_ al menú d'Omarchy.

## GitHub CLI

[La CLI de GitHub](https://cli.github.com/) et permet autenticar-te amb el teu compte de GitHub i clonar-hi repositoris privats. Està connectada com un dels stubs de mise de càrrega diferida, de manera que la primera vegada que executes `gh`, s'instal·la sola. Per autenticar-te, executa `gh auth login`. Després pots obtenir repositoris privats amb `gh repo clone org/repo`.

També pots fer una pila d'altres operacions de GitHub amb aquesta ordre. Executa simplement `gh` per veure tot el que és possible.

També hi ha un stub d'instal·lació diferida per a `ghui` per gestionar les teves pull requests en una TUI. I [lazygit](https://github.com/jesseduffield/lazygit) ve preinstal·lat, si vols conduir git mateix des d'una TUI.
