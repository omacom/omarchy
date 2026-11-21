# Strumenti di sviluppo

## Editor alternativi

Omarchy viene fornito con Plain come editor predefinito sulle nuove installazioni e [Neovim](https://neovim.io/) preinstallato, ma se vuoi qualcosa di un po' più mainstream e familiare, puoi aprire il Menu Omarchy (`Super + Space`) e vedere le opzioni sotto _Install > Editor_. Lì troverai VSCode, Cursor, Zed, Sublime Text, Helix, Vim ed Emacs. Se non trovi quello che cerchi, dai un'occhiata a _Install > Package_ e verifica se non è in un pacchetto Arch (e in caso contrario, prova _Install > AUR_ per controllare l'AUR).

Anche l'editor originale `vi` è disponibile fin da subito. Esegui `vi filename` per modificare un file nel terminale.

L'abbinamento del tema è offerto per `VSCode`, `Cursor`, `VSCodium` e `Helix`.

Puoi impostare l'editor predefinito a livello di sistema in `Setup > Defaults > Editor`.

## Ambiente

Omarchy supporta la configurazione di un'intera serie di ambienti di sviluppo tramite la sezione _Install > Development_ del Menu Omarchy (`Super + Space`). Troverai ovviamente _Ruby on Rails_, ma anche tutti e tre i principali runtime per JavaScript (Node.js, Bun, Deno), oltre a popolari framework PHP come Laravel e Symfony. Oh, e ci sono anche Go, Rust, Python, Java, Elixir (con Phoenix), .NET, OCaml, Zig, Clojure e Scala. È una selezione davvero ampia!

La maggior parte di questi ambienti è gestita da [Mise](https://mise.jdx.dev/). È uno strumento che ti permette di installare ed eseguire più versioni di un linguaggio di programmazione sulla stessa macchina. È come rbenv o rvm per Ruby o virtualenv per Python, ma funziona per un sacco di ambienti diversi.

Per installare, ad esempio, Ruby, esegui `mise use -g ruby`, che installerà Ruby e lo imposterà come predefinito globale. Oppure, se il tuo progetto ha un file .ruby-version, puoi semplicemente eseguire `mise i` nella root di quel progetto.

## Strumenti CLI preinstallati

Omarchy rende disponibili strumenti come `gh`, `uv` e la maggior parte dei [coding agent](17-ai.md) tramite l'[installazione lazy di mise](https://mise.jdx.dev/dev-tools/shims.html#lazy-tools). La prima volta che ne esegui uno, mise lo installa. I coding agent controllano poi la presenza di un aggiornamento prima di avviarsi, al massimo una volta ogni quattro ore; gli altri strumenti, come `gh` e `uv`, riutilizzano la versione installata finché non esegui l'aggiornamento.

Puoi anche controllare le impostazioni predefinite o installarli in anticipo:

```bash
mise ls --current              # List the tools configured for this directory
mise install gh               # Install one tool now
mise install --include-lazy    # Install all configured tools, including lazy tools
```

Esegui `omarchy update` per aggiornare gli strumenti installati insieme al resto di Omarchy. L'alias `mup` aggiorna solo gli strumenti gestiti da mise. Per aggiungere un altro strumento alla tua configurazione, usa `mise use -g <tool>`.

La configurazione di Python installa anche `uv` tramite mise. La rimozione dell'ambiente di sviluppo Python lascia `uv` disponibile come strumento indipendente.

### Utilizzare la tua installazione

I comandi di mise vengono prima di `~/.local/bin` nel `PATH`, quindi uno strumento che hai installato tu stesso, ad esempio con l'installer di Claude Code o di Cursor, esegue comunque la copia di mise. Anche le app avviate dal desktop trovano i comandi di mise prima dei pacchetti di sistema, quindi un'app che esegue `gh` ottiene la copia di mise anche se hai installato `github-cli` con pacman, e mise installa quella copia la prima volta. Per usare invece la tua, disabilita la copia di mise in `~/.config/mise/config.toml`. Ad esempio, se hai installato Cursor CLI tu stesso:

```toml
[settings]
disable_tools = ["cursor-agent"]
```

Se hai già una tabella `[settings]`, aggiungi lì la voce; estendi un elenco `disable_tools` esistente invece di sostituirlo. Assicurati che la tua installazione sia nel `PATH`. Usa il nome dello strumento mise, che può differire dal suo comando: `oh-my-pi` fornisce `omp`, ad esempio. Il launcher dell'agente predefinito preferisce anche un Cursor o Muse installato dall'utente in `~/.local/bin`.

### Rimozione e ripristino delle impostazioni predefinite

_Remove > Preinstalls_ rimuove le web app, le TUI e le app preinstallate di Omarchy e fa in modo che mise ignori le dichiarazioni degli strumenti di Omarchy per il tuo utente, aggiungendole a `ignored_config_paths` in `~/.config/mise/miserc.toml`. _Install > Preinstalls_ le ripristina e rimuove di nuovo quella riga. Gli strumenti che dichiari tu stesso, nella tua configurazione o nel `mise.toml` di un progetto, continuano a funzionare in entrambi i casi. Se scegli un agente predefinito o configuri Python dopo aver rimosso i preinstallati, quello strumento viene aggiunto alla tua configurazione. L'impostazione mise si applica solo al tuo utente e gli altri utenti mantengono la propria scelta; le app sono però pacchetti, quindi rimuoverle o ripristinarle le modifica per tutti sulla macchina.

## Docker

[Docker](https://www.docker.com/) non ha certo bisogno di presentazioni. Ti permette di eseguire container isolati e Omarchy installa tutto il necessario per farlo funzionare bene, incluso Docker stesso e [Docker Compose](https://docs.docker.com/compose/).

Per impostazione predefinita il tuo utente *non* è nel gruppo `docker`. Quel gruppo è di fatto root senza password — chiunque ne faccia parte può eseguire `docker run -v /:/host` e prendere il controllo della macchina — quindi un singolo script o una singola dipendenza dannosa in esecuzione con il tuo utente sarebbe altrimenti a un solo comando da root. Quindi da riga di comando esegui Docker con `sudo` (`sudo docker ps`, `sudo docker compose up`) e gli strumenti grafici che comunicano con il daemon — la VM Windows — chiedono l'autorizzazione quando ne hanno bisogno. Se vuoi ritrovare la comodità di una configurazione senza gruppo e ne comprendi il compromesso, abilitala da **Setup > Security > Sudoless Docker** (oppure esegui `omarchy-setup-security-sudoless-docker`), che ti aggiunge al gruppo `docker` dopo un avviso; a quel punto il semplice `docker` e l'alias `d` funzionano di nuovo senza `sudo`.

Puoi configurare i database più comuni per lo sviluppo locale in Docker usando _Install > Development > Docker DB_ nel menu Omarchy.

## GitHub CLI

[GitHub CLI](https://cli.github.com/) è disponibile come `gh` per lavorare con repository, issue e pull request dal terminale. Esegui `gh auth login` per installarlo al primo utilizzo e autenticarti, poi `gh repo clone org/repo` per clonare un repository. Esegui `gh --help` per esplorare i suoi comandi.

Per un'interfaccia terminale per le pull request, esegui `ghui`; anche in questo caso mise lo installa al primo utilizzo. [Lazygit](https://github.com/jesseduffield/lazygit) è preinstallato per lavorare con Git stesso.
