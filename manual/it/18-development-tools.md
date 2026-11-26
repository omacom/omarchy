# Strumenti di sviluppo

## Editor alternativi

Omarchy viene fornito con Plain come editor predefinito nelle nuove installazioni e [Neovim](https://neovim.io/) preinstallato, ma se vuoi qualcosa di un po' più mainstream e familiare, puoi aprire il Menu Omarchy (`Super + Space`) e vedere le opzioni in _Install > Editor_. Lì trovi elencati VSCode, Cursor, Zed, Sublime Text, Helix, Vim ed Emacs. Se non trovi quello che cerchi, dai un'occhiata a _Install > Package_ e verifica se non è presente in un pacchetto Arch (e in caso contrario, prova _Install > AUR_ per controllare l'AUR).

Anche l'editor `vi` originale è disponibile immediatamente. Esegui `vi filename` per modificare un file nel terminale.

L'abbinamento del tema è offerto per `VSCode`, `Cursor`, `VSCodium` e `Helix`.

Puoi impostare l'editor predefinito a livello di sistema in `Setup > Defaults > Editor`.

## Ambiente

Omarchy permette di configurare tutta una serie di ambienti di sviluppo tramite la sezione _Install > Development_ del Menu Omarchy (`Super + Space`). Ovviamente troverai _Ruby on Rails_, ma anche tutti e tre i principali runtime per JavaScript (Node.js, Bun, Deno), oltre a popolari framework PHP come Laravel e Symfony. Oh, e ci sono anche Go, Rust, Python, Java, Elixir (con Phoenix), .NET, OCaml, Zig, Clojure e Scala. È una selezione davvero ampia!

La maggior parte di questi ambienti è gestita da [Mise](https://mise.jdx.dev/). È uno strumento che ti permette di installare ed eseguire più versioni di un linguaggio di programmazione sulla stessa macchina. È come rbenv o rvm per Ruby o virtualenv per Python, ma funziona per un sacco di ambienti diversi.

Per installare, ad esempio, Ruby, eseguiresti `mise use -g ruby`, che installerà Ruby e lo imposterà come predefinito globale. Oppure, se il tuo progetto ha un file .ruby-version, puoi semplicemente eseguire `mise i` nella radice di quel progetto.

## Strumenti CLI preinstallati

`uv`, Node.js e `playwright-cli` (per consentire agli agent di controllare un browser, usando Chrome installato) sono installati come pacchetti, e `omarchy update` li mantiene aggiornati insieme al resto del sistema. [Hunk](https://github.com/modem-dev/hunk) e le CLI di GitHub, Basecamp, Cloudflare e HEY sono a una scelta di distanza in _Install > CLI_, e gli [agent di programmazione](17-ai.md) in _Install > AI > CLI_.

mise gestisce solo i runtime che configuri da _Install > Development_; Omarchy non installa nulla tramite esso di propria iniziativa. Esegui `omarchy update` per aggiornarli insieme al resto di Omarchy; l'alias `mup` aggiorna solo gli strumenti gestiti da mise. Per aggiungere un altro strumento alla tua configurazione, usa `mise use -g <tool>`.

## Docker

[Docker](https://www.docker.com/) non ha certo bisogno di presentazioni. Ti permette di eseguire container isolati, e Omarchy installa tutto il necessario per farlo funzionare bene, incluso Docker stesso e [Docker Compose](https://docs.docker.com/compose/).

Per impostazione predefinita il tuo utente *non* appartiene al gruppo `docker`. Quel gruppo equivale di fatto a root senza password — chiunque ne faccia parte può eseguire `docker run -v /:/host` e prendere il controllo della macchina — quindi un singolo script o una singola dipendenza dannosa eseguiti con il tuo utente sarebbero altrimenti a un solo comando da root. Quindi da riga di comando esegui Docker con `sudo` (`sudo docker ps`, `sudo docker compose up`), e gli strumenti grafici che comunicano con il daemon — la VM Windows — chiedono l'autorizzazione quando ne hanno bisogno. Se vuoi ritrovare la comodità di una configurazione senza gruppo e ne comprendi il compromesso, abilitala da **Setup > Security > Sudoless Docker** (oppure esegui `omarchy-setup-security-sudoless-docker`), che ti aggiunge al gruppo `docker` dopo un avviso; a quel punto `docker` semplice e l'alias `d` funzionano di nuovo senza `sudo`.

Puoi configurare i database più comuni per lo sviluppo locale in Docker usando _Install > Development > Docker DB_ nel menu Omarchy.

## GitHub CLI

[GitHub CLI](https://cli.github.com/) è `gh`, per lavorare con repository, issue e pull request dal terminale. _Setup > Git_ lo installa quando scegli di accedere a GitHub da lì, oppure installalo separatamente da _Install > CLI > GitHub_. Poi `gh repo clone org/repo` clona un repository; esegui `gh --help` per esplorarne i comandi.

[Lazygit](https://github.com/jesseduffield/lazygit) è preinstallato per lavorare con Git stesso.
