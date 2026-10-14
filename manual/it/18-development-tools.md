# Strumenti di sviluppo

## Editor alternativi

Omarchy include [Neovim](https://neovim.io/) come editor predefinito, ma se vuoi qualcosa di più comune e familiare puoi aprire il menu Omarchy (`Super + Space`) e vedere le opzioni in _Installa > Editor_. Troverai VSCode, Cursor, Zed, Sublime Text, Helix, Vim ed Emacs. Se non trovi quello che cerchi, dai un'occhiata a _Installa > Pacchetto_ per vedere se esiste un pacchetto Arch (e in caso contrario prova _Installa > AUR_ per controllare l'AUR).

Anche l'editor `vi` originale è disponibile subito. Esegui `vi filename` per modificare un file nel terminale.

L'abbinamento del tema è disponibile per `VSCode`, `Cursor`, `VSCodium` e `Helix`.

Puoi impostare l'editor predefinito a livello di sistema in `Setup > Defaults > Editor`.

## Ambienti

Omarchy consente di configurare moltissimi ambienti di sviluppo dalla sezione _Installa > Sviluppo_ del menu Omarchy (`Super + Space`). Troverai naturalmente _Ruby on Rails_, ma anche tutti e tre i principali runtime JavaScript (Node.js, Bun, Deno) e popolari framework PHP come Laravel e Symfony. Ah, e ci sono anche Go, Rust, Python, Java, Elixir (con Phoenix), .NET, OCaml, Zig, Clojure e Scala. È una selezione davvero ampia!

La maggior parte di questi ambienti è gestita da [Mise](https://mise.jdx.dev/). È uno strumento che ti permette di installare ed eseguire più versioni di un linguaggio di programmazione sulla stessa macchina. È come rbenv o rvm per Ruby o virtualenv per Python, ma funziona per molti ambienti diversi.

Per installare, ad esempio, Ruby, esegui `mise use -g ruby`: installerà Ruby e lo imposterà come predefinito globale. Oppure, se il tuo progetto ha un file .ruby-version, puoi semplicemente eseguire `mise i` nella radice del progetto.

## Docker

[Docker](https://www.docker.com/) non ha certo bisogno di presentazioni. Ti permette di eseguire container isolati e Omarchy installa tutto il necessario per farlo funzionare bene, incluso Docker stesso e [Docker Compose](https://docs.docker.com/compose/).

Per impostazione predefinita il tuo utente *non* appartiene al gruppo `docker`. Quel gruppo equivale di fatto a root senza password — chi ne fa parte può eseguire `docker run -v /:/host` e prendere il controllo della macchina — quindi un singolo script o una dipendenza malevola in esecuzione come te sarebbe altrimenti a un comando da root. Per questo da riga di comando esegui Docker con `sudo` (`sudo docker ps`, `sudo docker compose up`), e gli strumenti grafici che parlano con il daemon — la VM Windows — chiedono l'autorizzazione quando ne hanno bisogno. Se vuoi riavere la comodità di una configurazione senza gruppo e ne capisci il compromesso, abilitala da **Impostazioni > Sicurezza > Docker senza sudo** (oppure esegui `omarchy-setup-security-sudoless-docker`), che dopo un avviso ti aggiunge al gruppo `docker`; a quel punto `docker` semplice e l'alias `d` funzionano di nuovo senza `sudo`.

Puoi configurare i database più comuni per lo sviluppo locale in Docker da _Installa > Sviluppo > Docker DB_ nel menu Omarchy.

## GitHub CLI

[La GitHub CLI](https://cli.github.com/) ti permette di autenticarti con il tuo account GitHub e clonare repository privati usandola. È collegata come uno degli stub mise a caricamento differito, quindi la prima volta che esegui `gh` si installa da sola. Per autenticarti, esegui `gh auth login`. Poi puoi clonare repository privati con `gh repo clone org/repo`.

Con questo comando puoi eseguire anche molte altre operazioni su GitHub. Esegui semplicemente `gh` per vedere tutto ciò che è possibile.

C'è anche uno stub a installazione differita per `ghui` per gestire le tue pull request in una TUI. E [lazygit](https://github.com/jesseduffield/lazygit) è preinstallato, se vuoi gestire git stesso da una TUI.
