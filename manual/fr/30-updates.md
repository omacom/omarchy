# Mises à jour

Omarchy et vos paquets sont maintenus à jour via _Mise à jour > Omarchy_ dans le menu Omarchy (`Super + Space`).

Omarchy lui-même est installé sous forme de paquets pacman ordinaires depuis le [dépôt de paquets Omarchy](https://github.com/omacom-io/omarchy-pkgs), donc une mise à jour installe [la dernière version d'Omarchy](https://github.com/omacom/omarchy/releases), exécute toutes les migrations en attente pour synchroniser votre système avec la dernière version, et met à jour tous les paquets système depuis le [miroir Arch d'Omarchy](https://github.com/omacom-io/omarchy-mirror) et [AUR](https://aur.archlinux.org/) (si vous avez installé des paquets AUR).

Lorsque de nouvelles versions sont publiées, une icône en forme de flèche circulaire apparaîtra à droite de votre horloge. Cliquez dessus et le processus de mise à jour démarrera.

![update-available](images/update-available.webp)

### Quatre canaux

Omarchy est mis à jour via quatre canaux : stable, RC, edge et dev. Les nouvelles installations démarrent sur le canal stable, qui suit les [versions officielles](https://github.com/omacom/omarchy/releases/), ainsi que le [miroir Arch stable d'Omarchy](https://github.com/omacom-io/omarchy-mirror) qui a un mois de retard sur la dernière version, afin que nous puissions repérer toute nouvelle incompatibilité nécessitant des changements de configuration avant qu'elle ne cause des problèmes aux gens.

Mais si vous voulez aider à repérer ces problèmes potentiels, vous pouvez passer au canal edge. Vos paquets Omarchy suivront alors les dernières versions de développement, et vous pourrez mettre à jour vers les derniers paquets Arch dès qu'ils sont disponibles. Ne le faites que si vous avez de l'expérience avec Linux et que vous savez récupérer un système qui rencontre des problèmes.

Avant chaque nouvelle version majeure, nous effectuerons la validation finale via le canal RC. Si vous voulez aider aux derniers ajustements, venez nous rejoindre sur #omarchy-release-candidates sur Discord.

Enfin, il y a le canal dev, qui relie Omarchy directement à un clone git du code source dans `~/omarchy`, combiné aux paquets edge. N'utilisez ce canal que si vous êtes un utilisateur Linux expérimenté, que vous travaillez directement sur Omarchy et que vous êtes prêt à tolérer des casses.

Vous pouvez changer de canal via _Mise à jour > Canal_ dans le menu Omarchy (ou `omarchy channel set <stable|rc|edge|dev>` dans le terminal, avec `omarchy channel current` pour voir où vous en êtes).

### Changer de noyau

Omarchy démarre avec son propre noyau `linux-omarchy`, mais vous pouvez en garder d'autres installés à côté, comme le noyau Arch standard `linux` ou une version expérimentale que vous testez. Quand il y en a plusieurs, _Mise à jour > Noyau_ dans le menu Omarchy les liste avec une coche à côté de celui qui démarre par défaut. Choisissez-en un autre, saisissez votre mot de passe une fois, et il démarrera après le prochain redémarrage. Les autres noyaux restent dans le menu de démarrage, vous pouvez donc toujours en choisir un manuellement si le nouveau par défaut vous pose problème. Dans le terminal, c'est `omarchy kernel` pour voir celui par défaut actuel, `omarchy kernel list` pour ce qui est installé, et `omarchy kernel set <kernel>` pour changer.

### Mises à jour du firmware

Vos paquets ne sont pas les seuls à devenir obsolètes. De nombreux ordinateurs portables et périphériques fournissent les firmwares BIOS, SSD et de station d'accueil via le Linux Vendor Firmware Service, et _Mise à jour > Firmware_ dans le menu Omarchy récupérera et installera tout ce qui attend pour votre matériel. Il installe `fwupd` la première fois que vous le lancez. Beaucoup de firmwares ne peuvent être écrits que pendant un redémarrage, ne soyez donc pas surpris si on vous en demande un.

Quand vous devez modifier un réglage dans le BIOS lui-même, maintenez `Alt` dans le menu système (`Super + Escape`) et _Redémarrer_ devient _Redémarrer vers le BIOS_, ce qui redémarre directement dans la configuration du firmware sans avoir à attraper la bonne touche au démarrage. Depuis le terminal, c'est `omarchy system firmware`.

### Avertissement concernant les mises à jour directes avec pacman/yay

Si vous connaissez déjà Arch, vous pourriez être tenté de lancer simplement `pacman -Syu` ou `yay -Syu` vous-même, mais si vous le faites, vous manquerez l'instantané, les migrations et les mises à jour de configuration qu'Omarchy exécute en même temps que les nouveaux paquets. C'est pourquoi Omarchy arrêtera en fait une mise à niveau directe du système et vous orientera plutôt vers `omarchy update`. (Si vous savez vraiment ce que vous faites, le garde-fou vous indiquera comment le contourner pour une seule transaction.)

### Revenir en arrière après une mauvaise mise à jour

Si vous rencontrez un jour un problème après une mise à jour, vous pouvez restaurer votre système à l'instantané pris avant la mise à jour. Redémarrez simplement et choisissez dans le menu de démarrage l'instantané datant d'avant le début de la mise à jour.

![bootloader](images/bootloader.webp)

Si vos fichiers de configuration ont été corrompus d'une manière ou d'une autre, vous pouvez aussi effectuer une réinstallation d'Omarchy avec `omarchy reinstall` dans le terminal. Cela réinstallera tous les paquets Omarchy par défaut, vous placera sur stable (edge sur Apple Silicon), rétrogradera tous les paquets trop récents et réinitialisera tous les fichiers de configuration. Notez que toutes vos modifications utilisateur apportées à la configuration par défaut d'Omarchy seront écrasées ce faisant !
