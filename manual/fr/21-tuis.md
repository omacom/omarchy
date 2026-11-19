# TUIs

## Lazygit

[Lazygit](https://github.com/jesseduffield/lazygit) est une délicieuse alternative à quelque chose comme l’application GitHub Desktop, et elle s’exécute dans le terminal.

Vous pouvez l’exécuter directement, en vous rendant dans n’importe quel répertoire géré par git et en lançant `lazygit`. Ou vous pouvez l’exécuter dans Neovim, où elle peut être démarrée avec `Space G G`.

Vous passez d’un panneau à l’autre avec `Tab`. Dans le panneau Files, vous sélectionnez les fichiers à mettre en staging avec `Space`, puis vous pouvez créer un nouveau commit avec `c`. Vous pouvez voir toutes les commandes disponibles avec `?`.

## Btop

[Btop](https://github.com/aristocratos/btop) est un magnifique gestionnaire de ressources qui affiche l’utilisation de la mémoire, du CPU, du disque et du réseau. Il répertorie également tous les processus actifs et vous permet de les gérer.

Omarchy l’appelle Activity Monitor, et vous le démarrez depuis le lanceur d’applications ou en appuyant sur `Super + Shift + T`. Il s’ouvre sous forme de fenêtre flottante, que vous pouvez mettre en mosaïque avec `Super + T`.

## Herdr

[Herdr](https://github.com/omacom-io/herdr) est un gestionnaire d’espaces de travail pour terminal qui vous offre des espaces de travail, des onglets et des panneaux, et qui les maintient tous en cours d’exécution dans une session persistante dont vous pouvez vous détacher pour y revenir plus tard.

Vous le démarrez (ou vous rattachez à votre session existante) depuis le lanceur d’applications ou avec `Super + Ctrl + Return`. Omarchy fournit une configuration Herdr qui reflète sa configuration Tmux, donc la touche préfixe est ici aussi `Ctrl + Space`. Vous pouvez parcourir tous les raccourcis clavier avec `Super + Ctrl + K`.

## Fastfetch

[Fastfetch](https://github.com/fastfetch-cli/fastfetch) affiche des informations sur le système, comme la version du noyau, le temps de fonctionnement, le thème, le CPU, la mémoire, et bien plus encore. C’est le successeur du populaire outil neofetch.

Omarchy l’a intégré sous _System > About_ dans le menu Omarchy (`Super + Space`).

## Cliamp

[Cliamp](https://www.cliamp.stream/) est un lecteur de musique rétro pour terminal inspiré de Winamp 2.x, avec des stations de radio intégrées pour des rythmes lo-fi. Lancez-le avec `Super + Shift + Alt + M`, ou depuis le menu Omarchy sous _Apps_. Appuyez sur `?` pour afficher la liste complète des raccourcis clavier.

## Et pour le Wi-Fi et le Bluetooth ?

Vous ne trouverez pas de TUI pour le Wi-Fi et le Bluetooth — ces tâches relèvent du shell Omarchy. Cliquez sur l’icône Wi-Fi dans la barre supérieure (ou appuyez sur `Super + Ctrl + N`) pour voir les réseaux et vous y connecter, et cliquez sur l’icône Bluetooth (ou appuyez sur `Super + Ctrl + B`) pour appairer et connecter des appareils. Voir [réseau](35-networking.md) pour tout savoir.

## Ajouter les vôtres

N’importe quel programme pour terminal peut bénéficier du traitement complet réservé aux applications. Allez dans _Install > TUI_ dans le menu Omarchy (`Super + Space`), donnez-lui un nom, une commande de lancement, un style de fenêtre et une icône, et il apparaîtra dans le lanceur d’applications comme n’importe quelle autre application. Vous pouvez le supprimer à nouveau sous _Remove > TUI_.
