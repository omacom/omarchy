# Veille du système

Par défaut, Omarchy active la suspension, et la veille prolongée une fois qu'elle est configurée, mais si vous rencontrez des problèmes avec l'une ou l'autre sur votre machine, vous pouvez les désactiver.

Sur les machines NVIDIA GB10, comme la DGX Spark et l'ASUS Ascent GX10, la suspension et la veille prolongée sont désactivées, comme dans DGX OS de NVIDIA, parce qu'il n'a pas encore été démontré que la veille fonctionne sur ce matériel. L'activation/désactivation de la suspension et la configuration de la veille prolongée ne s'appliquent pas là. Pour réactiver la veille, supprimez `/etc/systemd/sleep.conf.d/omarchy-sleep-disabled.conf` avec `sudo rm` ; la suspension réapparaît alors dans le menu, et la veille prolongée peut être configurée comme sur les autres machines. Exécuter `sudo omarchy apply hardware --install-user "$USER"` remet le fichier en place.

### Profils d'alimentation

Sur un ordinateur portable, Omarchy mémorise votre profil d'alimentation séparément selon que vous êtes branché ou sur batterie, et bascule entre les deux lorsque vous branchez et débranchez. Par défaut, cela signifie performance sur secteur et équilibré sur batterie.

Vous pouvez voir ce que propose votre machine avec `omarchy powerprofiles list`, et définir celui que vous voulez pour l'état dans lequel vous êtes actuellement avec `omarchy powerprofiles set autodetect power-saver`. Pour définir l'autre état sans rien débrancher, nommez-le directement : `omarchy powerprofiles set battery power-saver`. Quel que soit votre choix, c'est celui que vous retrouverez la prochaine fois que vous serez dans cet état.

### Activer/désactiver la suspension

Vous activez/désactivez la suspension en exécutant `omarchy toggle suspend` depuis le terminal. Cela révèle/masque simplement l'option sous _System_ (ou `Super + Esc`), et vous pouvez alors voir si elle fonctionne de manière fiable sur votre système. Sinon, vous pouvez la masquer à nouveau avec la même commande.

### Activer/désactiver la veille prolongée

Vous configurez la veille prolongée en exécutant `omarchy hibernation setup` depuis le terminal (elle n'est pas disponible sur les Mac Apple Silicon). La veille prolongée crée un sous-volume /swap sur votre disque de démarrage de la taille de votre mémoire vive physique, assurez-vous donc d'avoir largement assez de place. Sur une machine de 32GB, vous aurez toujours besoin de plus de 32GB libres pour ce volume. La veille prolongée nécessite également le chargeur de démarrage Limine par défaut.

Une fois configurée, vous verrez l'option de veille prolongée sous _System_ (ou `Super + Esc`), et vous pourrez alors voir si elle fonctionne de manière fiable sur votre système. Sinon, vous pouvez la supprimer à nouveau en exécutant `omarchy hibernation remove`.
