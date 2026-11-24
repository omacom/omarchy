# Veille du système

Omarchy active la suspension par défaut, et l'hibernation une fois qu'elle est configurée, mais si vous rencontrez des problèmes avec l'une ou l'autre sur votre machine, vous pouvez les désactiver.

Sur les machines NVIDIA GB10, comme le DGX Spark et l'ASUS Ascent GX10, la suspension et l'hibernation sont désactivées, comme dans le DGX OS de NVIDIA, car la mise en veille n'a pas encore fait ses preuves sur ce matériel. Il en va de même pour l'ASUS Zenbook A16 (UX3607OA), où la suspension ne met pas encore complètement la puce en veille et peut se bloquer pendant la nuit. Le basculement de la suspension et la configuration de l'hibernation ne s'appliquent pas dans ce cas. Pour réactiver la veille, supprimez `/etc/systemd/sleep.conf.d/omarchy-sleep-disabled.conf` avec `sudo rm` ; la suspension réapparaît alors dans le menu, et l'hibernation peut être configurée comme sur les autres machines. L'exécution de `sudo omarchy apply hardware --install-user "$USER"` remet le fichier en place.

### Profils d'alimentation

Sur un ordinateur portable, Omarchy mémorise votre profil d'alimentation séparément pour le fonctionnement branché sur secteur et sur batterie, et bascule entre les deux lorsque vous branchez et débranchez. Par défaut, cela signifie le mode performance sur secteur et le mode équilibré sur batterie.

Vous pouvez voir ce que votre machine propose avec `omarchy powerprofiles list`, et définir celui que vous voulez pour l'état dans lequel vous vous trouvez actuellement avec `omarchy powerprofiles set autodetect power-saver`. Pour définir l'autre état sans rien débrancher, nommez-le directement : `omarchy powerprofiles set battery power-saver`. Quel que soit votre choix, c'est celui que vous retrouverez la prochaine fois que vous serez dans cet état.

### Activer/désactiver la suspension

Vous basculez la suspension en exécutant `omarchy toggle suspend` depuis le terminal. Cela ne fait qu'afficher/masquer l'option sous _System_ (ou `Super + Esc`), et vous pouvez ensuite voir si elle fonctionne de manière fiable sur votre système. Si ce n'est pas le cas, vous pouvez la masquer à nouveau avec la même commande.

### Activer/désactiver l'hibernation

Vous configurez l'hibernation en exécutant `omarchy hibernation setup` depuis le terminal (elle n'est pas disponible sur les Mac Apple Silicon). L'hibernation crée un sous-volume /swap sur votre disque de démarrage de la taille de votre allocation de RAM physique, alors assurez-vous d'avoir largement assez de place disponible. Sur une machine de 32GB, il vous faudra toujours plus de 32GB d'espace libre pour ce volume. L'hibernation nécessite également le bootloader Limine par défaut.

Une fois configurée, vous verrez l'option d'hibernation sous _System_ (ou `Super + Esc`), et vous pourrez ensuite voir si elle fonctionne de manière fiable sur votre système. Si ce n'est pas le cas, vous pouvez la supprimer à nouveau en exécutant `omarchy hibernation remove`.
