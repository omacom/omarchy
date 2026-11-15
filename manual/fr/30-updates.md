# Mises à jour

Omarchy et vos paquets restent à jour via _Mise à jour > Omarchy_ dans le menu Omarchy (`Super + Space`).

Omarchy lui-même est installé sous forme de paquets pacman ordinaires depuis le [dépôt de paquets Omarchy](https://github.com/omacom-io/omarchy-pkgs), donc une mise à jour installe [la dernière version d'Omarchy](https://github.com/omacom/omarchy/releases), exécute toutes les migrations en attente pour synchroniser votre système avec la dernière version, et met à jour tous les paquets système depuis le [miroir Arch d'Omarchy](https://github.com/omacom-io/omarchy-mirror) et [AUR](https://aur.archlinux.org/) (si vous avez installé des paquets AUR).

Lorsqu'une nouvelle version est publiée, une icône en forme de flèche circulaire apparaîtra à droite de votre horloge. Cliquez dessus et le processus de mise à jour démarrera.

![update-available](images/update-available.webp)

### Quatre canaux

Omarchy est mis à jour via quatre canaux : stable, RC, edge et dev. Les nouvelles installations commencent sur le canal stable, qui suit les [versions officielles](https://github.com/omacom/omarchy/releases/), ainsi que le [miroir Arch stable d'Omarchy](https://github.com/omacom-io/omarchy-mirror) qui a un mois de retard sur la dernière version, afin que nous puissions détecter toute nouvelle incompatibilité nécessitant des modifications de configuration avant qu'elle ne cause des problèmes aux gens.

Mais si vous souhaitez aider à repérer ces problèmes potentiels, vous pouvez utiliser le canal edge. Cela permettra à vos paquets Omarchy de suivre les dernières versions de développement, et vous permettra de passer aux derniers paquets Arch dès qu'ils seront disponibles. Vous ne devriez le faire que si vous avez de l'expérience avec Linux et si vous savez comment récupérer un système qui rencontre des problèmes.

Avant chaque nouvelle version majeure, nous effectuerons la validation finale à l'aide du canal RC. Si vous souhaitez aider pour les dernières touches, venez nous retrouver sur #omarchy-release-candidates sur Discord.

Enfin, il y a le canal dev, qui relie Omarchy directement à un clone git du code source dans `~/omarchy`, combiné aux paquets edge. Vous ne devriez utiliser ce canal que si vous êtes un utilisateur Linux expérimenté, que vous travaillez directement sur Omarchy et que vous êtes prêt à tolérer des casses.

Vous pouvez passer d'un canal à l'autre via _Mise à jour > Canal_ dans le menu Omarchy (ou `omarchy-channel-set` dans le terminal).

### Changer de noyau

Omarchy démarre avec son propre noyau `linux-omarchy`, mais vous pouvez en conserver d'autres installés à côté, comme le noyau Arch standard `linux` ou une version expérimentale que vous testez. Lorsqu'il y en a plus d'un, _Mise à jour > Noyau_ dans le menu Omarchy les répertorie avec une coche à côté de celui qui démarre par défaut. Choisissez-en un autre, saisissez votre mot de passe une fois, et il démarrera après le prochain redémarrage. Les autres noyaux restent dans le menu de démarrage, vous pouvez donc toujours en choisir un manuellement si le nouveau noyau par défaut vous pose problème. Dans le terminal, c'est `omarchy-kernel` pour voir le noyau par défaut actuel, `omarchy-kernel list` pour voir ceux qui sont installés, et `omarchy-kernel set <kernel>` pour en changer.

### Mises à jour du firmware

Vos paquets ne sont pas les seuls à devenir obsolètes. De nombreux ordinateurs portables et périphériques fournissent le firmware du BIOS, du SSD et des stations d'accueil via le Linux Vendor Firmware Service, et _Mise à jour > Firmware_ dans le menu Omarchy récupérera et installera tout ce qui attend pour votre matériel. Il installe `fwupd` la première fois que vous l'exécutez. De nombreux firmwares ne peuvent être écrits que pendant un redémarrage, ne soyez donc pas surpris si on vous en demande un.

Lorsque vous devez modifier un réglage dans le BIOS lui-même, maintenez `Alt` dans le menu système (`Super + Escape`) et _Redémarrer_ se transforme en _Redémarrer vers le BIOS_, ce qui redémarre directement dans la configuration du firmware sans avoir à appuyer sur la bonne touche au démarrage. Depuis le terminal, c'est `omarchy system firmware`.

### Avertissement concernant les mises à jour directes avec pacman/yay

Si vous connaissez déjà Arch, vous pourriez être tenté d'exécuter simplement `pacman -Syu` ou `yay -Syu` vous-même, mais si vous le faites, vous manquerez l'instantané, les migrations et les mises à jour de configuration qu'Omarchy exécute en même temps que les nouveaux paquets. C'est pourquoi Omarchy interrompra en fait une mise à niveau directe du système et vous orientera plutôt vers `omarchy update`. (Si vous savez vraiment ce que vous faites, la protection vous indiquera comment la contourner pour une seule transaction.)

### Revenir en arrière après une mauvaise mise à jour

Si vous rencontrez un jour un problème après une mise à jour, vous pouvez restaurer votre système à l'instantané pris avant la mise à jour. Redémarrez simplement et choisissez dans le menu de démarrage l'instantané datant d'avant le début de la mise à jour.

![bootloader](images/bootloader.webp)

Si vos fichiers de configuration ont été corrompus d'une manière ou d'une autre, vous pouvez également effectuer une réinstallation d'Omarchy à l'aide de `omarchy reinstall` dans le terminal. Cela réinstallera tous les paquets Omarchy par défaut, vous placera sur le canal stable et rétrogradera tous les paquets trop récents, et réinitialisera tous les fichiers de configuration. Notez que toutes vos modifications de configuration utilisateur par rapport aux valeurs par défaut d'Omarchy seront écrasées en faisant cela !
