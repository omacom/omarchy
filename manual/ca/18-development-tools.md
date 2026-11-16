# Eines de desenvolupament

## Editors alternatius

Omarchy inclou [Neovim](https://neovim.io/) per defecte, però si vols alguna cosa una mica més convencional i familiar, pots obrir el menú d'Omarchy (`Super + Space`) i veure les opcions a _Instal·la > Editor_. Hi tenim VSCode, Cursor, Zed, Sublime Text, Helix, Vim i Emacs. Si no trobes el que busques, fes una ullada a _Instal·la > Paquet_ i comprova si no hi és com a paquet d'Arch (i, si no, prova _Instal·la > AUR_ per comprovar l'AUR).

L'editor `vi` original també està disponible de sèrie. Executa `vi filename` per editar un fitxer al terminal.

La coincidència de temes s'ofereix per a `VSCode`, `Cursor`, `VSCodium` i `Helix`.

Pots definir l'editor per defecte de tot el sistema a `Setup > Defaults > Editor`.

## Entorn

Omarchy permet configurar una gran quantitat d'entorns de desenvolupament mitjançant la secció _Instal·la > Desenvolupament_ del menú d'Omarchy (`Super + Space`). Hi trobaràs, evidentment, _Ruby on Rails_, però també els tres principals entorns d'execució per a JavaScript (Node.js, Bun, Deno), així com frameworks populars de PHP com Laravel i Symfony. Ah, i també hi ha Go, Rust, Python, Java, Elixir (amb Phoenix), .NET, OCaml, Zig, Clojure i Scala. És una selecció molt àmplia!

La majoria d'aquests entorns es gestionen amb [Mise](https://mise.jdx.dev/). És una eina que et permet instal·lar i executar diverses versions d'un llenguatge de programació a la mateixa màquina. És com rbenv o rvm per a Ruby o virtualenv per a Python, però funciona per a un munt d'entorns diferents.

Per instal·lar, posem per cas, Ruby, executaries `mise use -g ruby`, que instal·larà Ruby i el definirà com a valor per defecte global. O, si el teu projecte té un fitxer .ruby-version, pots simplement executar `mise i` a l'arrel d'aquest projecte.

## Eines de CLI preinstal·lades

Omarchy fa que eines com `gh`, `uv` i la majoria dels [agents de programació](17-ai.md) estiguin disponibles mitjançant la [instal·lació diferida de mise](https://mise.jdx.dev/dev-tools/shims.html#lazy-tools). La primera vegada que n'executes una, mise la instal·la. Les execucions posteriors reutilitzen la versió instal·lada; no comproven si hi ha una actualització a cada inici.

També pots consultar els valors per defecte o instal·lar-los per endavant:

```bash
mise ls --current              # List the tools configured for this directory
mise install gh               # Install one tool now
mise install --include-lazy    # Install all configured tools, including lazy tools
```

Executa `omarchy update` per actualitzar les eines instal·lades juntament amb la resta d'Omarchy. L'àlies `mup` actualitza només les eines gestionades per mise. Per afegir una altra eina a la teva pròpia configuració, utilitza `mise use -g <tool>`.

La configuració de Python també instal·la `uv` mitjançant mise. Si elimines l'entorn de desenvolupament de Python, `uv` continua disponible com a eina independent.

### Ús de la teva pròpia instal·lació

Les ordres de mise van abans de `~/.local/bin` a `PATH`, de manera que una eina que hagis instal·lat tu mateix, per exemple amb l'instal·lador propi de Claude Code o de Cursor, continua executant la còpia de mise. Les aplicacions llançades des de l'escriptori també troben les ordres de mise abans que els paquets del sistema, de manera que una aplicació que executa `gh` obté la còpia de mise encara que hagis instal·lat `github-cli` amb pacman, i mise instal·la aquesta còpia la primera vegada. Per utilitzar la teva, desactiva la còpia de mise a `~/.config/mise/config.toml`. Per exemple, si has instal·lat Cursor CLI tu mateix:

```toml
[settings]
disable_tools = ["cursor-agent"]
```

Si ja tens una taula `[settings]`, afegeix-hi l'entrada allà; amplia una llista `disable_tools` existent en lloc de substituir-la. Assegura't que la teva instal·lació és a `PATH`. Utilitza el nom d'eina de mise, que pot diferir de la seva ordre: `oh-my-pi` proporciona `omp`, per exemple. El llançador de l'agent per defecte també prefereix un Cursor o un Muse instal·lat per l'usuari a `~/.local/bin`.

### Eliminació i restauració dels valors per defecte

_Elimina les preinstal·lacions_ fa que mise ometi les declaracions d'eines d'Omarchy per al teu usuari, afegint-les a `ignored_config_paths` a `~/.config/mise/miserc.toml`. _Restaura les preinstal·lacions_ elimina aquesta línia de nou. Les eines que declaris tu mateix, a la teva pròpia configuració o al `mise.toml` d'un projecte, continuen funcionant en tots dos casos. Si tries un agent per defecte o configures Python després d'eliminar les preinstal·lacions, aquesta eina s'afegeix a la teva pròpia configuració. Totes dues opcions s'apliquen només al teu usuari; els altres usuaris de la màquina mantenen la seva pròpia elecció.

## Docker

[Docker](https://www.docker.com/) gairebé no necessita presentació. Et permet executar contenidors aïllats, i Omarchy instal·la tot el necessari perquè funcioni bé, incloent-hi Docker mateix i [Docker Compose](https://docs.docker.com/compose/).

Per defecte, el teu usuari *no* pertany al grup `docker`. Aquest grup equival, a la pràctica, a root sense contrasenya — qualsevol membre pot executar `docker run -v /:/host` i apoderar-se de la màquina —, de manera que un sol script o dependència maliciosa que s'executi com tu estaria, altrament, a una ordre de distància de root. Així doncs, a la línia d'ordres executes Docker amb `sudo` (`sudo docker ps`, `sudo docker compose up`), i les eines gràfiques que parlen amb el dimoni — la VM de Windows — demanen autorització quan la necessiten. Si vols recuperar la comoditat d'una configuració sense grup i entens el compromís que implica, activa-la des de **Configuració > Seguretat > Docker sense sudo** (o executa `omarchy-setup-security-sudoless-docker`), cosa que t'afegeix al grup `docker` després d'un avís; aleshores `docker` a seques i l'àlies `d` tornen a funcionar sense `sudo`.

Pots configurar les bases de dades habituals per al desenvolupament local a Docker mitjançant _Instal·la > Desenvolupament > Docker DB_ al menú d'Omarchy.

## GitHub CLI

[GitHub CLI](https://cli.github.com/) està disponible com a `gh` per treballar amb repositoris, incidències i pull requests des del terminal. Executa `gh auth login` per instal·lar-lo el primer cop que l'utilitzis i autenticar-te, i després `gh repo clone org/repo` per clonar un repositori. Executa `gh --help` per explorar-ne les ordres.

Per a una interfície de terminal per a les pull requests, executa `ghui`; mise també l'instal·la el primer cop que l'utilitzis. [Lazygit](https://github.com/jesseduffield/lazygit) ve preinstal·lat per treballar amb Git mateix.
