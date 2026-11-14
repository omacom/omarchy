# TUIs

## Lazygit

[Lazygit](https://github.com/jesseduffield/lazygit) est une alternative délicieuse à quelque chose comme l'application GitHub Desktop, et il tourne dans le terminal.

Vous pouvez le lancer directement, en vous rendant dans n'importe quel répertoire géré par git et en lançant `lazygit`. Ou vous pouvez le lancer dans Neovim, où il peut être démarré avec `Space G G`.

Vous passez d'un panneau à l'autre avec `Tab`. Dans le panneau Files, vous sélectionnez les fichiers à ajouter à l'index avec `Space`, puis vous pouvez créer un nouveau commit avec `c`. Vous pouvez voir toutes les commandes disponibles avec `?`.

## Btop

[Btop](https://github.com/aristocratos/btop) est un magnifique gestionnaire de ressources qui affiche l'utilisation de la mémoire, du CPU, du disque et du réseau. Il liste aussi tous les processus actifs et vous permet de les gérer.

Omarchy l'appelle Activity, et vous le lancez en appuyant sur `Super + Shift + T`. Il s'ouvre dans une fenêtre flottante, que vous pouvez passer en mosaïque avec `Super + T`.

## Herdr

[Herdr](https://github.com/omacom-io/herdr) est un gestionnaire d'espaces de travail pour le terminal qui vous donne des espaces de travail, des onglets et des panneaux, et les garde tous en fonctionnement dans une session persistante dont vous pouvez vous détacher et à laquelle vous pouvez revenir plus tard.

Vous le lancez (ou vous rattachez à votre session existante) avec `Super + Ctrl + Return`. Omarchy fournit une configuration Herdr qui reflète sa configuration Tmux, donc la touche préfixe est ici aussi `Ctrl + Space`. Vous pouvez parcourir tous les raccourcis clavier avec `Super + Ctrl + K`.

## Fastfetch

[Fastfetch](https://github.com/fastfetch-cli/fastfetch) affiche les informations système, comme la version du noyau, le temps de fonctionnement, le thème, le CPU, la mémoire, et bien plus. C'est un successeur du populaire outil neofetch.

Omarchy l'a intégré sous le nom _About_ dans le menu Omarchy (`Super + Space`).

## Cliamp

[Cliamp](https://www.cliamp.stream/) est un lecteur de musique rétro pour le terminal inspiré de Winamp 2.x, avec des stations de radio intégrées pour des rythmes lo-fi. Lancez-le avec `Super + Shift + Alt + M`, ou depuis le menu Omarchy sous _Apps_. Appuyez sur `?` pour la liste complète des raccourcis clavier.

## Et pour le Wi-Fi et le Bluetooth ?

Vous ne trouverez pas de TUIs pour le Wi-Fi et le Bluetooth — ces tâches reviennent au shell Omarchy. Cliquez sur l'icône Wi-Fi dans la barre supérieure (ou appuyez sur `Super + Ctrl + N`) pour voir les réseaux et vous connecter, et cliquez sur l'icône Bluetooth (ou appuyez sur `Super + Ctrl + B`) pour appairer et connecter des appareils. Voir [réseau](35-networking.md) pour tout savoir.

## Ajouter les vôtres

N'importe quel programme pour le terminal peut bénéficier du traitement complet d'une application. Allez dans _Install > TUI_ dans le menu Omarchy (`Super + Space`), donnez-lui un nom, une commande de lancement, un style de fenêtre et une icône, et il apparaîtra dans le lanceur d'applications comme n'importe quelle autre application. Vous pouvez le supprimer à nouveau sous _Remove > TUI_.
