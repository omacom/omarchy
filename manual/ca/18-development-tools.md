# Eines de desenvolupament

## Editors alternatius

Omarchy inclou Plain com a editor per defecte en les instal·lacions noves i [Neovim](https://neovim.io/) preinstal·lat, però si vols alguna cosa una mica més convencional i familiar, pots executar el menú d'Omarchy (`Super + Space`) i veure les opcions a _Install > Editor_. Hi tenim VSCode, Cursor, Zed, Sublime Text, Helix, Vim i Emacs. Si no hi trobes el que busques, fes una ullada a _Install > Package_ i mira si no hi és en un paquet d'Arch (i si no hi és, prova _Install > AUR_ per comprovar l'AUR).

L'editor `vi` original també està disponible de fàbrica. Executa `vi filename` per editar un fitxer al terminal.

S'ofereix concordança de tema per a `VSCode`, `Cursor`, `VSCodium` i `Helix`.

Pots definir l'editor per defecte de tot el sistema a `Setup > Defaults > Editor`.

## Entorn

Omarchy permet configurar un munt d'entorns de desenvolupament des de la secció _Install > Development_ del menú d'Omarchy (`Super + Space`). Hi trobaràs, és clar, _Ruby on Rails_, però també els tres principals entorns d'execució de JavaScript (Node.js, Bun, Deno), així com frameworks populars de PHP com Laravel i Symfony. Ah, i també hi ha Go, Rust, Python, Java, Elixir (amb Phoenix), .NET, OCaml, Zig, Clojure i Scala. És una selecció ben àmplia!

La majoria d'aquests entorns es gestionen amb [Mise](https://mise.jdx.dev/). És una eina que et permet instal·lar i executar múltiples versions d'un llenguatge de programació a la mateixa màquina. És com rbenv o rvm per a Ruby o virtualenv per a Python, però funciona per a un munt d'entorns diferents.

Per instal·lar, posem per cas, Ruby, executaries `mise use -g ruby`, que instal·larà Ruby i el definirà com a predeterminat global. O, si el teu projecte té un fitxer .ruby-version, pots executar simplement `mise i` a l'arrel d'aquest projecte.

## Eines CLI preinstal·lades

Omarchy posa a disposició eines com `gh`, `uv` i la majoria d'[agents de programació](17-ai.md) mitjançant la [instal·lació diferida de mise](https://mise.jdx.dev/dev-tools/shims.html#lazy-tools). La primera vegada que n'executes una, mise la instal·la. Després, els agents de programació comproven si hi ha una actualització abans d'executar-se, com a molt un cop cada quatre hores; altres eines, com `gh` i `uv`, reutilitzen la versió instal·lada fins que actualitzes.

També pots consultar els valors predeterminats o instal·lar-los per endavant:

```bash
mise ls --current              # List the tools configured for this directory
mise install gh               # Install one tool now
mise install --include-lazy    # Install all configured tools, including lazy tools
```

Executa `omarchy update` per actualitzar les eines instal·lades juntament amb la resta d'Omarchy. L'àlies `mup` actualitza només les eines gestionades per mise. Per afegir una altra eina a la teva pròpia configuració, fes servir `mise use -g <tool>`.

La configuració de Python també instal·la `uv` mitjançant mise. Eliminar l'entorn de desenvolupament de Python deixa `uv` disponible com a eina independent.

### Fer servir la teva pròpia instal·lació

Les ordres de mise van abans de `~/.local/bin` a `PATH`, de manera que una eina que hagis instal·lat tu mateix, per exemple amb l'instal·lador propi de Claude Code o de Cursor, continua executant la còpia de mise. Les aplicacions llançades des de l'escriptori també troben les ordres de mise abans que els paquets del sistema, de manera que una aplicació que executa `gh` obté la còpia de mise encara que hagis instal·lat `github-cli` amb pacman, i mise instal·la aquesta còpia la primera vegada. Per fer servir la teva, desactiva la còpia de mise a `~/.config/mise/config.toml`. Per exemple, si has instal·lat Cursor CLI tu mateix:

```toml
[settings]
disable_tools = ["cursor-agent"]
```

Si ja tens una taula `[settings]`, afegeix-hi l'entrada; amplia una llista `disable_tools` existent en lloc de substituir-la. Assegura't que la teva instal·lació sigui a `PATH`. Fes servir el nom de l'eina de mise, que pot diferir de la seva ordre: `oh-my-pi` proporciona `omp`, per exemple. El llançador de l'agent per defecte també prefereix un Cursor o Muse instal·lat per l'usuari a `~/.local/bin`.

### Eliminar i restaurar els valors predeterminats

_Remove > Preinstalls_ elimina les aplicacions web, les TUI i les aplicacions preinstal·lades d'Omarchy, i fa que mise ometi les declaracions d'eines d'Omarchy per al teu usuari, afegint-les a `ignored_config_paths` a `~/.config/mise/miserc.toml`. _Install > Preinstalls_ les torna a posar i torna a eliminar aquesta línia. Les eines que declaris tu mateix, a la teva pròpia configuració o a la `mise.toml` d'un projecte, continuen funcionant en qualsevol cas. Si tries un agent per defecte o configures Python després d'eliminar les preinstal·lacions, aquesta eina s'afegeix a la teva pròpia configuració. La configuració de mise s'aplica només al teu usuari, i els altres usuaris conserven la seva pròpia elecció; les aplicacions són paquets, però, de manera que eliminar-les o restaurar-les les canvia per a tothom a la màquina.

## Docker

[Docker](https://www.docker.com/) gairebé no necessita presentació. Et permet executar contenidors aïllats, i Omarchy instal·la tot el necessari perquè funcioni bé, incloent-hi el mateix Docker i [Docker Compose](https://docs.docker.com/compose/).

Per defecte, el teu usuari *no* és al grup `docker`. Aquest grup és, en la pràctica, root sense contrasenya — qualsevol cosa que hi sigui pot fer `docker run -v /:/host` i apoderar-se de la màquina —, de manera que un sol script o dependència malintencionats que s'executin com a tu estarien, altrament, a una ordre de distància de ser root. Així doncs, a la línia d'ordres executes Docker amb `sudo` (`sudo docker ps`, `sudo docker compose up`), i les eines gràfiques que parlen amb el dimoni — la VM de Windows — demanen autorització quan la necessiten. Si vols recuperar la comoditat d'una configuració sense grup i entens el compromís que implica, activa-la des de **Setup > Security > Sudoless Docker** (o executa `omarchy-setup-security-sudoless-docker`), que t'afegeix al grup `docker` després d'un avís; aleshores `docker` a seques i l'àlies `d` tornen a funcionar sense `sudo`.

Pots configurar les bases de dades habituals per al desenvolupament local a Docker amb _Install > Development > Docker DB_ al menú d'Omarchy.

## GitHub CLI

[GitHub CLI](https://cli.github.com/) està disponible com a `gh` per treballar amb repositoris, incidències i pull requests des del terminal. Executa `gh auth login` per instal·lar-lo el primer cop que l'utilitzis i autenticar-te, i després `gh repo clone org/repo` per clonar un repositori. Executa `gh --help` per explorar les seves ordres.

Per a una interfície de terminal per a les pull requests, executa `ghui`; mise també l'instal·la el primer cop que l'utilitzes. [Lazygit](https://github.com/jesseduffield/lazygit) ve preinstal·lat per treballar amb el mateix Git.
