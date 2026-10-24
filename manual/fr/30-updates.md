# Mises à jour

Omarchy et vos paquets sont maintenus à jour via _Mettre à jour > Omarchy_ dans le menu Omarchy (`Super + Space`).

Omarchy lui-même est installé sous forme de paquets pacman classiques depuis le [dépôt de paquets Omarchy](https://github.com/omacom-io/omarchy-pkgs), donc une mise à jour installe [la dernière version d'Omarchy](https://github.com/omacom/omarchy/releases), exécute toutes les migrations en attente pour synchroniser votre système avec la dernière version, et met à jour tous les paquets système depuis le [miroir Arch d'Omarchy](https://github.com/omacom-io/omarchy-mirror) et l'[AUR](https://aur.archlinux.org/) (si vous avez installé des paquets AUR).

Quand de nouvelles versions sont publiées, une icône en forme de flèche circulaire apparaît à droite de votre horloge. Cliquez dessus et le processus de mise à jour démarrera.

![update-available](images/update-available.webp)

### Quatre canaux

Omarchy est mis à jour selon quatre canaux : stable, RC, edge et dev. Les nouvelles installations commencent sur le canal stable, qui suit les [versions officielles](https://github.com/omacom/omarchy/releases/), ainsi que le [miroir Arch stable d'Omarchy](https://github.com/omacom-io/omarchy-mirror) qui tourne avec un mois de retard sur la dernière version, pour que nous puissions repérer toute nouvelle incompatibilité nécessitant des changements de configuration avant qu'elle ne cause des problèmes aux gens.

Mais si vous souhaitez aider à repérer ces problèmes potentiels, vous pouvez utiliser le canal edge. Cela maintiendra vos paquets Omarchy à jour avec les derniers builds de développement, et vous permettra de mettre à jour vers les derniers paquets Arch dès qu'ils sont disponibles. Vous ne devriez faire cela que si vous êtes expérimenté avec Linux, et que vous savez comment récupérer un système qui a des problèmes.

Avant chaque nouvelle version majeure, nous ferons la validation finale en utilisant le canal RC. Si vous souhaitez aider au peaufinage final, venez traîner dans #omarchy-release-candidates sur Discord.

Enfin, il y a le canal dev, qui lie Omarchy directement à un clone git du code source dans `~/omarchy`, combiné aux paquets edge. Vous ne devriez utiliser ce canal que si vous êtes un utilisateur Linux expérimenté, travaillant directement sur Omarchy, et prêt à tolérer des casse.

Vous pouvez basculer entre les canaux en utilisant _Mettre à jour > Canal_ depuis le menu Omarchy (ou `omarchy-channel-set` dans le terminal).

### Mises à jour du firmware

Vos paquets ne sont pas la seule chose qui devient obsolète. De nombreux ordinateurs portables et périphériques livrent des BIOS, des firmwares SSD et des firmwares de station d'accueil via le Linux Vendor Firmware Service, et _Mettre à jour > Firmware_ dans le menu Omarchy récupérera et installera tout ce que votre matériel a en attente. Il installe `fwupd` la première fois que vous le lancez. Beaucoup de firmwares ne peuvent être écrits que pendant un redémarrage, donc ne soyez pas surpris qu'on vous en demande un.

### Avertissement concernant les mises à jour directes pacman/yay

Si vous connaissez déjà Arch, vous pourriez être tenté de lancer simplement `pacman -Syu` ou `yay -Syu` vous-même, mais si vous faites cela, vous manquerez l'instantané, les migrations et les mises à jour de configuration qu'Omarchy exécute avec les nouveaux paquets. C'est pourquoi Omarchy arrêtera en fait une mise à niveau directe du système et vous orientera vers `omarchy update` à la place. (Si vous savez vraiment ce que vous faites, le garde-fou vous dira comment le contourner pour une seule transaction.)

### Revenir sur une mauvaise mise à jour

Si vous rencontrez un jour un problème après avoir fait une mise à jour, vous pouvez restaurer votre système à l'instantané pris avant la mise à jour. Redémarrez simplement et choisissez l'instantané dans le menu de démarrage d'avant le début de la mise à jour.

![bootloader](images/bootloader.webp)

Si d'une manière ou d'une autre vos fichiers de configuration ont été corrompus, vous pouvez aussi effectuer une réinstallation d'Omarchy en utilisant `omarchy reinstall` dans le terminal. Cela réinstallera tous les paquets Omarchy par défaut, vous remettra sur stable et rétrogradera tous les paquets trop récents, et réinitialisera tous les fichiers de configuration. Notez que tous vos changements de configuration utilisateur par rapport aux valeurs par défaut d'Omarchy seront écrasés en faisant cela !
