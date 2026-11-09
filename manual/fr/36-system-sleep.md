# Veille du système

Omarchy active la veille et l'hibernation par défaut, mais si l'une ou l'autre pose problème sur votre machine, vous pouvez les désactiver.

Sur les machines NVIDIA GB10, comme le DGX Spark et l'ASUS Ascent GX10, la veille et l'hibernation sont désactivées, comme dans le DGX OS de NVIDIA, car il n'a pas encore été démontré que la veille fonctionne sur ce matériel. Il en va de même pour l'ASUS Zenbook A16 (UX3607OA), où la veille ne met pas encore complètement la puce en sommeil et peut se bloquer pendant la nuit. Le basculement de la veille et la configuration de l'hibernation ne s'appliquent pas dans ce cas. Pour réactiver la veille, supprimez `/etc/systemd/sleep.conf.d/omarchy-sleep-disabled.conf` avec `sudo rm` ; la veille réapparaît alors dans le menu, et l'hibernation peut être configurée comme sur les autres machines. Exécuter `sudo omarchy apply hardware --install-user "$USER"` rétablit le fichier.

### Profils d'alimentation

Sur un portable, Omarchy retient votre profil d'alimentation séparément pour le fonctionnement branché sur secteur et sur batterie, et bascule entre les deux lorsque vous branchez et débranchez. Par défaut, cela signifie performance sur secteur et équilibré sur batterie.

Vous pouvez voir ce que propose votre machine avec `omarchy powerprofiles list`, et définir celui que vous voulez pour l'état dans lequel vous vous trouvez actuellement avec `omarchy powerprofiles set autodetect power-saver`. Pour définir l'autre état sans rien débrancher, nommez-le directement : `omarchy powerprofiles set battery power-saver`. Quel que soit votre choix, c'est celui que vous retrouverez la prochaine fois que vous serez dans cet état.

### Activer/désactiver la veille

Vous activez/désactivez la veille en exécutant `omarchy toggle suspend` depuis le terminal. Cela affiche/masque simplement l'option sous _System_ (ou `Super + Esc`), et vous pouvez alors voir si elle fonctionne de manière fiable sur votre système. Si ce n'est pas le cas, vous pouvez la masquer à nouveau avec la même commande.

### Activer/désactiver l'hibernation

Vous configurez l'hibernation en exécutant `omarchy hibernation setup` depuis le terminal. L'hibernation crée un sous-volume /swap sur votre disque de démarrage de la taille de votre mémoire RAM physique, alors assurez-vous d'avoir largement assez de place disponible. Sur une machine de 32GB, vous aurez toujours besoin de plus de 32GB libres pour ce volume. L'hibernation nécessite aussi le chargeur de démarrage Limine par défaut.

Une fois configurée, vous verrez l'option d'hibernation sous _System_ (ou `Super + Esc`), et vous pourrez alors voir si elle fonctionne de manière fiable sur votre système. Si ce n'est pas le cas, vous pouvez la retirer à nouveau en exécutant `omarchy hibernation remove`.
