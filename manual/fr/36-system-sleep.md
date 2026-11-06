# Veille du système

Omarchy active la mise en veille et l'hibernation par défaut, mais si l'une ou l'autre pose problème sur votre machine, vous pouvez les désactiver.

Sur les machines NVIDIA GB10, comme le DGX Spark et l'ASUS Ascent GX10, la mise en veille et l'hibernation sont désactivées, comme dans le DGX OS de NVIDIA, car il n'a pas encore été démontré que la veille fonctionne sur ce matériel. Le basculement de la mise en veille et la configuration de l'hibernation ne s'y appliquent pas. Pour réactiver la veille, supprimez `/etc/systemd/sleep.conf.d/omarchy-sleep-disabled.conf` avec `sudo rm` ; la mise en veille revient alors dans le menu, et l'hibernation peut être configurée comme sur les autres machines. Exécuter `sudo omarchy apply hardware --install-user "$USER"` remet le fichier en place.

### Profils d'alimentation

Sur un ordinateur portable, Omarchy mémorise votre profil d'alimentation séparément pour le fonctionnement branché et sur batterie, et bascule entre les deux lorsque vous branchez et débranchez. Par défaut, cela signifie performance sur secteur et balanced sur batterie.

Vous pouvez voir ce que votre machine propose avec `omarchy powerprofiles list`, et définir celui que vous voulez pour l'état dans lequel vous vous trouvez actuellement avec `omarchy powerprofiles set autodetect power-saver`. Pour définir l'autre état sans rien débrancher, nommez-le directement : `omarchy powerprofiles set battery power-saver`. Quel que soit votre choix, c'est celui que vous retrouverez la prochaine fois que vous serez dans cet état.

### Basculer la mise en veille

Vous basculez la mise en veille en exécutant `omarchy toggle suspend` depuis le terminal. Cela ne fait qu'afficher/masquer l'option sous _Système_ (ou `Super + Esc`), et vous pouvez alors voir si elle fonctionne de manière fiable sur votre système. Si ce n'est pas le cas, vous pouvez la masquer à nouveau avec la même commande.

### Basculer l'hibernation

Vous configurez l'hibernation en exécutant `omarchy hibernation setup` depuis le terminal. L'hibernation crée un sous-volume /swap sur votre disque de démarrage de la taille de votre allocation de RAM physique, alors assurez-vous d'avoir largement assez de place disponible. Sur une machine de 32GB, vous aurez toujours besoin de 32GB+ libres pour ce volume. L'hibernation requiert aussi le chargeur de démarrage Limine par défaut.

Une fois configurée, vous verrez l'option d'hibernation sous _Système_ (ou `Super + Esc`), et vous pouvez alors voir si elle fonctionne de manière fiable sur votre système. Si ce n'est pas le cas, vous pouvez la retirer à nouveau en exécutant `omarchy hibernation remove`.
