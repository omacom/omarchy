# Funcții de shell

Omarchy vine cu un set de funcții de shell care simplifică sarcinile obișnuite și încapsulează apelurile întortocheate cu parametri.

## Compresie

- `compress [file/dir]`: Creează o arhivă tar.gz din fișierul/directorul dat.
- `decompress [file.tar.gz]`: Expandează un fișier tar.gz.

## Unități

- `iso2sd [image.iso]`: Creează o unitate bootabilă pe un card SD folosind fișierul iso referit și alegând unitatea interactiv.
- `format-drive [device] [name]`: Formatează un disc întreg cu o singură partiție exFAT (care funcționează și pe Windows și pe macOS). Ruleaz-o fără argumente ca să vezi unitățile disponibile. Ai grijă!

## Aranjări pentru dezvoltare

Aranjări instantanee cu mai multe panouri pentru dezvoltarea în tmux:

- `tdl [ai]`: Creează o aranjare Tmux Dev Layout cu editorul tău, un agent AI și un terminal. Folosește aliasurile de agenți, cum ar fi `tdl c` pentru opencode sau `tdl cx` pentru Claude Code, sau pasează un al doilea agent ca să-i rulezi pe amândoi, cum ar fi `tdl c cx`.
- `tds`: Creează un Tmux Dev Square cu editor, urmărire de diff (prin `hunk diff --watch`), terminal și opencode.
- `tdlm [ai]`: Creează o fereastră `tdl` pentru fiecare subdirector din directorul curent.
- `tsl [count] [command]`: Creează un roi de panouri dispuse în grilă, toate rulând aceeași comandă (excelent pentru agenți AI).

Aceleași aranjări sunt disponibile pentru Herdr ca `hdl`, `hds`, `hdlm` și `hsl`.

## Git worktrees

- `ga [branch]`: Creează un worktree și o ramură noi lângă depozitul curent și sare în ele.
- `gd`: Elimină worktree-ul curent și ramura lui (cere mai întâi confirmare).

## Urmăritori rsync

- `rsw [source] [destination]`: Pornește un urmăritor în fundal care face rsync din sursă în destinație ori de câte ori se schimbă ceva. Destinația poate fi o gazdă la distanță, cum ar fi `rsw ~/Work/app nyc-dev:Work/app`.
- `lsw`: Listează toți urmăritorii activi.
- `dsw`: Oprește toți urmăritorii activi.

## Redirecționare de porturi SSH

Ideal pentru dezvoltare web cu privilegii de context securizat localhost împotriva unei mașini la distanță.

- `fip`: Redirecționează unul sau mai multe porturi de la o gazdă la distanță către localhost prin SSH.
- `dip`: Deconectează unul sau mai multe porturi redirecționate.
- `lip`: Listează toate redirecționările de porturi SSH active.

Să zicem că pornești un server de dezvoltare pe portul `3000` pe o mașină accesibilă ca `nyc-dev`; atunci poți rula `fip nyc-dev 3000` ca să redirecționezi acel port, astfel încât `localhost:3000` să ajungă de fapt la `nyc-dev:3000`, dar fără să ai nevoie de certificate SSL ca să stabilești contextul securizat necesar pentru testarea websocket-urilor sau a altora de genul acesta.

## Reconectare SSH

`ssh` în sine este înfășurat într-o funcție care curăță terminalul dacă o conexiune moare în timp ce un tmux, Herdr sau editor de la distanță l-a revendicat, apoi se reconectează automat când o sesiune interactivă cade (Ctrl-C oprește bucla de reîncercări).
