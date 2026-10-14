# Funzioni della shell

Omarchy include una serie di funzioni della shell per semplificare le attività comuni e incapsulare chiamate con parametri contorti.

## Compressione

- `compress [file/dir]`: crea un archivio tar.gz dal file/dir.
- `decompress [file.tar.gz]`: espande un file tar.gz.

## Unità

- `iso2sd [image.iso]`: crea un'unità avviabile su una scheda SD usando il file iso indicato e scegliendo l'unità in modo interattivo.
- `format-drive [device] [name]`: formatta un intero disco con una singola partizione exFAT (che funziona anche su Windows e macOS). Eseguilo senza argomenti per vedere le unità disponibili. Fai attenzione!

## Layout di sviluppo

Layout di sviluppo a più riquadri istantanei per tmux:

- `tdl [ai]`: crea un Tmux Dev Layout con il tuo editor, un agente AI e un terminale. Usa gli alias degli agenti, come `tdl c` per opencode o `tdl cx` per Claude Code, oppure passa un secondo agente per eseguirli entrambi, come `tdl c cx`.
- `tds`: crea un Tmux Dev Square con editor, monitoraggio delle differenze (tramite `hunk diff --watch`), terminale e opencode.
- `tdlm [ai]`: crea una finestra `tdl` per ogni sottodirectory nella directory corrente.
- `tsl [count] [command]`: crea uno sciame di riquadri affiancati in una griglia, tutti con lo stesso comando in esecuzione (ottimo per gli agenti AI).

Gli stessi layout sono disponibili per Herdr come `hdl`, `hds`, `hdlm` e `hsl`.

## Git worktree

- `ga [branch]`: crea un nuovo worktree e un nuovo branch accanto al repository corrente e ci salta dentro.
- `gd`: rimuove il worktree corrente e il suo branch (chiede prima conferma).

## Monitoraggi Rsync

- `rsw [source] [destination]`: avvia un monitoraggio in background che sincronizza con rsync l'origine verso la destinazione ogni volta che qualcosa cambia. La destinazione può essere un host remoto, come `rsw ~/Work/app nyc-dev:Work/app`.
- `lsw`: elenca tutti i monitoraggi attivi.
- `dsw`: ferma tutti i monitoraggi attivi.

## Inoltro porte SSH

Ideale per fare sviluppo web con i privilegi di contesto sicuro di localhost contro una macchina remota.

- `fip`: inoltra una o più porte da un host remoto a localhost via SSH.
- `dip`: disconnette una o più porte inoltrate.
- `lip`: elenca tutti gli inoltri di porte SSH attivi.

Diciamo che avvii un server di sviluppo sulla porta `3000` su una macchina accessibile come `nyc-dev`: allora puoi eseguire `fip nyc-dev 3000` per inoltrare quella porta, così `localhost:3000` raggiunge effettivamente `nyc-dev:3000`, ma senza bisogno di certificati SSL per stabilire il contesto sicuro necessario per testare web socket o simili.

## Riconnessione SSH

`ssh` stesso è avvolto in una funzione che ripulisce il terminale se una connessione muore mentre un tmux, Herdr o editor remoto lo ha occupato, e poi si riconnette automaticamente quando una sessione interattiva cade (Ctrl-C ferma il ciclo di nuovi tentativi).
