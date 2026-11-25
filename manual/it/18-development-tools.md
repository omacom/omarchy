# Strumenti di sviluppo

## Editor alternativi

Omarchy viene fornito con Plain come editor predefinito sulle nuove installazioni e [Neovim](https://neovim.io/) preinstallato, ma se vuoi qualcosa di un po' più mainstream e familiare, puoi avviare l'Omarchy Menu (`Super + Space`) e vedere le opzioni in _Install > Editor_. Lì troverai elencati VSCode, Cursor, Zed, Sublime Text, Helix, Vim ed Emacs. Se non trovi quello che cerchi, dai un'occhiata a _Install > Package_ e verifica se non è disponibile in un pacchetto Arch (e in caso contrario, prova _Install > AUR_ per controllare l'AUR).

L'editor `vi` originale è disponibile anche fin da subito. Esegui `vi filename` per modificare un file nel terminale.

L'abbinamento del tema è offerto per `VSCode`, `Cursor`, `VSCodium` e `Helix`.

Puoi impostare l'editor predefinito a livello di sistema in `Setup > Defaults > Editor`.

## Ambiente

Omarchy supporta la configurazione di un'intera serie di ambienti di sviluppo tramite la sezione _Install > Development_ dell'Omarchy Menu (`Super + Space`). Troverai ovviamente _Ruby on Rails_, ma anche tutti e tre i principali runtime per JavaScript (Node.js, Bun, Deno), oltre a popolari framework PHP come Laravel e Symfony. Oh, e ci sono anche Go, Rust, Python, Java, Elixir (con Phoenix), .NET, OCaml, Zig, Clojure e Scala. È una selezione molto ampia!

La maggior parte di questi ambienti è gestita da [Mise](https://mise.jdx.dev/). È uno strumento che ti permette di installare ed eseguire più versioni di un linguaggio di programmazione sulla stessa macchina. È come rbenv o rvm per Ruby o virtualenv per Python, ma funziona per un sacco di ambienti diversi.

Per installare, ad esempio, Ruby, eseguiresti `mise use -g ruby`, che installerà Ruby e lo imposterà come predefinito globale. Oppure, se il tuo progetto ha un file .ruby-version, puoi semplicemente eseguire `mise i` nella radice di quel progetto.

## Strumenti CLI preinstallati

`uv`, Node.js e `playwright-cli` (per consentire agli agenti di controllare un browser, utilizzando Chrome installato) sono installati come pacchetti, e `omarchy update` li mantiene aggiornati insieme al resto del sistema. `ghui`, [Hunk](https://github.com/modem-dev/hunk) e le CLI di Basecamp, Cloudflare e HEY sono a portata di clic in _Install > CLI_, e gli [agenti di coding](17-ai.md) in _Install > AI > CLI_.

mise gestisce solo i runtime che configuri da _Install > Development_; Omarchy non installa nulla tramite esso di propria iniziativa. Esegui `omarchy update` per aggiornarli insieme al resto di Omarchy; l'alias `mup` aggiorna solo gli strumenti gestiti da mise. Per aggiungere un altro strumento alla tua configurazione, usa `mise use -g <tool>`.

## Docker

[Docker](https://www.docker.com/) non ha certo bisogno di presentazioni. Ti permette di eseguire container isolati, e Omarchy installa tutto il necessario per farlo funzionare bene, incluso Docker stesso e [Docker Compose](https://docs.docker.com/compose/).

Per impostazione predefinita il tuo utente *non* è nel gruppo `docker`. Quel gruppo equivale in pratica a root senza password — qualsiasi cosa ne faccia parte può eseguire `docker run -v /:/host` e prendere il controllo della macchina — quindi un singolo script o una singola dipendenza malevola in esecuzione con il tuo utente sarebbe altrimenti a un solo comando da root. Quindi da riga di comando esegui Docker con `sudo` (`sudo docker ps`, `sudo docker compose up`), e gli strumenti grafici che comunicano con il daemon — la Windows VM — chiedono l'autorizzazione quando ne hanno bisogno. Se vuoi ritrovare la comodità di una configurazione senza gruppo e ne comprendi il compromesso, abilitala da **Setup > Security > Sudoless Docker** (oppure esegui `omarchy-setup-security-sudoless-docker`), che ti aggiunge al gruppo `docker` dopo un avviso; poi il semplice `docker` e l'alias `d` funzionano di nuovo senza `sudo`.

Puoi configurare i database più comuni per lo sviluppo locale in Docker usando _Install > Development > Docker DB_ nel menu di Omarchy.

## GitHub CLI

[GitHub CLI](https://cli.github.com/) è `gh`, per lavorare con repository, issue e pull request dal terminale. _Setup > Git_ lo installa quando scegli di accedere a GitHub lì, poi `gh repo clone org/repo` clona un repository. Esegui `gh --help` per esplorarne i comandi.

_Install > CLI > GitHub_ installa la GitHub CLI, `gh`, insieme a `ghui`, un'interfaccia da terminale per le pull request. [Lazygit](https://github.com/jesseduffield/lazygit) è preinstallato per lavorare con Git stesso.
