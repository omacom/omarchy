# Fonctions du shell

Omarchy est livré avec un ensemble de fonctions shell pour simplifier les tâches courantes et encapsuler des appels de paramètres alambiqués.

## Compression

- `compress [file/dir]` : Créer une archive tar.gz à partir du fichier/répertoire.
- `decompress [file.tar.gz]` : Décompacter un fichier tar.gz.

## Lecteurs

- `iso2sd [image.iso]` : Créer un lecteur bootable sur une carte SD à partir du fichier iso référencé en choisissant le lecteur de façon interactive.
- `format-drive [device] [name]` : Formater un disque entier avec une seule partition exFAT (qui fonctionne aussi sous Windows et macOS). Lancez-la sans argument pour voir les lecteurs disponibles. Faites attention !

## Dispositions de développement

Des dispositions de développement multi-volets instantanées pour tmux :

- `tdl [ai]` : Créer une disposition de développement Tmux avec votre éditeur, un agent IA et un terminal. Utilisez les alias d'agent, comme `tdl c` pour opencode ou `tdl cx` pour Claude Code, ou passez un deuxième agent pour lancer les deux, comme `tdl c cx`.
- `tds` : Créer un carré de développement Tmux avec éditeur, surveillance de diff (via `hunk diff --watch`), terminal et opencode.
- `tdlm [ai]` : Créer une fenêtre `tdl` pour chaque sous-répertoire du répertoire courant.
- `tsl [count] [command]` : Créer un essaim de volets en mosaïque dans une grille, exécutant tous la même commande (parfait pour les agents IA).

Les mêmes dispositions sont disponibles pour Herdr sous les noms `hdl`, `hds`, `hdlm` et `hsl`.

## Worktrees Git

- `ga [branch]` : Créer un nouveau worktree et une nouvelle branche à côté du dépôt courant et y entrer.
- `gd` : Supprimer le worktree courant et sa branche (demande d'abord confirmation).

## Surveillants Rsync

- `rsw [source] [destination]` : Démarrer un surveillant en arrière-plan qui synchronise la source vers la destination avec rsync dès que quelque chose change. La destination peut être un hôte distant, comme `rsw ~/Work/app nyc-dev:Work/app`.
- `lsw` : Lister tous les surveillants actifs.
- `dsw` : Arrêter tous les surveillants actifs.

## Redirection de ports SSH

Idéal pour faire du développement web avec les privilèges de contexte sécurisé de localhost contre une machine distante.

- `fip` : Rediriger un ou plusieurs ports d'un hôte distant vers localhost via SSH.
- `dip` : Déconnecter un ou plusieurs ports redirigés.
- `lip` : Lister toutes les redirections de ports SSH actives.

Disons que vous démarrez un serveur de développement sur le port `3000` sur une machine accessible sous le nom `nyc-dev` ; vous pouvez alors lancer `fip nyc-dev 3000` pour rediriger ce port, de sorte que `localhost:3000` atteigne en réalité `nyc-dev:3000`, mais sans avoir besoin de certificats SSL pour établir le contexte sécurisé nécessaire pour tester les websockets ou autres choses du même genre.

## Reconnexion SSH

`ssh` lui-même est enveloppé dans une fonction qui nettoie le terminal si une connexion meurt alors qu'un tmux, Herdr ou éditeur distant s'en est emparé, puis se reconnecte automatiquement quand une session interactive tombe (Ctrl-C arrête la boucle de nouvelles tentatives).
