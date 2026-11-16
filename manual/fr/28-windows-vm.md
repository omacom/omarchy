# Machine virtuelle Windows

Omarchy offre un moyen facile de faire tourner Windows via une machine virtuelle Docker. Vous pouvez l'installer en utilisant _Installer > Windows_ depuis le menu Omarchy (`Super + Space`).

Votre machine a besoin de la virtualisation KVM pour cela, ce que la plupart ont — mais elle est parfois désactivée dans le BIOS, et l'installateur vous le dira si c'est le cas. Vous aurez aussi besoin d'espace disque : ce que vous donnez à Windows, plus environ 10 Go pour l'image elle-même.

L'installateur vous demande combien de RAM, combien de cœurs CPU et combien d'espace disque attribuer (64 Go ou plus est le plancher raisonnable), puis un nom d'utilisateur et un mot de passe Windows. Laissez-les vides et vous obtenez `docker` / `admin`. Le téléchargement prend un moment — 10 à 15 minutes, c'est normal — et vous pouvez suivre la progression dans le navigateur à `http://127.0.0.1:8006`. Le navigateur demande le même nom d'utilisateur et le même mot de passe avant d'ouvrir la console.

 ![windows-vm](images/windows-vm.webp)

## L'utiliser

Une fois qu'elle est installée, lancez _Windows_ depuis le lanceur d'applis. Cela démarre la machine virtuelle si elle ne tourne pas déjà et vous y connecte via RDP, en plein écran. Laissez-lui 15 à 30 secondes au démarrage à froid.

La session RDP transporte le son, votre micro et un presse-papiers partagé, donc copier du texte entre Linux et Windows fonctionne simplement. La résolution suit votre fenêtre, et Omarchy transmet votre mise à l'échelle d'affichage, donc ce n'est pas un flou immonde sur un écran HiDPI.

Quand vous fermez la fenêtre RDP, la machine virtuelle s'arrête automatiquement. Si vous préférez la laisser tourner — disons que vous avez quelque chose qui travaille dedans — lancez-la plutôt avec `omarchy windows vm launch --keep-alive`.

Le reste des contrôles est sur la même commande :

```bash
omarchy windows vm status    # is it running?
omarchy windows vm stop      # shut it down
omarchy windows vm launch    # start and connect
```

## Partager des fichiers

Le répertoire `~/Windows` dans votre répertoire personnel est automatiquement partagé avec la machine virtuelle. Mettez-y des fichiers si vous voulez qu'ils soient accessibles à Windows. La machine virtuelle n'a accès à aucune autre partie de votre système de fichiers, donc vous êtes à l'abri de tout ce qui pourrait être désagréable côté Windows. Son propre disque virtuel est disponible à `~/.windows`.

Ces chemins familiers restent sur leurs propres systèmes de fichiers. Ils peuvent aussi être des liens symboliques vers des répertoires qui vous appartiennent, ce qui est utile quand le disque virtuel vit sur un lecteur plus grand. L'installateur mesure l'espace libre sur le système de fichiers qui contient réellement `~/.windows`, pas nécessairement celui qui contient votre répertoire personnel.

Gardez les chemins du disque et du partage comme des répertoires séparés et qui ne se chevauchent pas. La suppression vide délibérément le répertoire du disque mais préserve le répertoire partagé. Juste avant la suppression, Omarchy effectue une vérification de confinement bornée et refuse de supprimer quoi que ce soit si cette vérification expire ou ne peut pas prouver que les deux arborescences sont séparées.

Avant que la machine virtuelle ne démarre, Omarchy ouvre et épingle ces deux répertoires, puis monte par liaison les inodes exacts des répertoires sur des ancres privées par utilisateur sous `/var/lib/omarchy/windows/mounts`. Docker ne voit que ces ancres protégées par root. Cela préserve les emplacements de disque personnalisés tout en empêchant un autre processus tournant sous votre compte de permuter un chemin vérifié avant que le conteneur privilégié ne le consomme. Les répertoires de disque et de partage existants sont resserrés en mode `0700` pendant la migration pour que d'autres comptes locaux ne puissent pas parcourir leur contenu.

Les ports de la machine virtuelle sont liés à localhost uniquement, donc rien sur votre réseau ne peut atteindre la machine Windows. La console web nécessite aussi le nom d'utilisateur et le mot de passe Windows configurés, empêchant un autre compte local de piloter la machine virtuelle via le port 8006.

## Limites et licence

Il n'y a pas de GPU passthrough avec cette configuration, donc elle ne convient pas aux jeux ni au montage vidéo. C'est un excellent moyen de faire tourner Microsoft Office ou tout autre chose dont vous avez absolument besoin.

La version installée est Windows 11 Pro, non activée. Vous aurez besoin de votre propre clé de licence pour utiliser les fonctionnalités verrouillées.

Si cet ordinateur a été livré avec Windows, la clé OEM est toujours dans le firmware même après l'installation d'Omarchy. Affichez-la avec `omarchy windows key`. Cette clé est liée à cette machine — elle activera Windows réinstallé sur ce matériel, mais elle n'activera généralement pas la machine virtuelle.

Vous pouvez changer l'allocation de ressources plus tard en relançant `omarchy-windows-vm install`, ce qui réécrit la configuration de la machine virtuelle à partir de vos réponses. Le fichier compose lui-même vit désormais à `/var/lib/omarchy/windows/docker-compose.yml` et appartient à root — c'est délibéré, pour qu'un processus tournant sous votre compte ne puisse pas le réécrire et faire monter tout votre disque dans le conteneur par le démarrage privilégié. Si vous devez le modifier à la main (par exemple pour monter un périphérique USB), modifiez-le avec `sudo` et voyez toutes les options sur [le projet Dockur Windows](https://github.com/dockur/windows).

Pour vous débarrasser de tout cela, utilisez _Supprimer > Windows_ depuis le menu Omarchy. Cela supprime le disque de la machine virtuelle et toutes ses données, donc assurez-vous que tout ce qui compte pour vous est sorti de `~/Windows` au préalable.
