# VM Windows

Omarchy offre un moyen simple d'exécuter Windows via une VM Docker sur les machines x86_64. Vous pouvez l'installer via _Installation > Windows_ depuis le menu Omarchy (`Super + Space`).

Votre machine a besoin de la virtualisation KVM pour cela, ce qui est le cas de la plupart — mais elle est parfois désactivée dans le BIOS, et l'installateur vous le dira si c'est le cas. Vous aurez aussi besoin de l'espace disque : tout ce que vous donnez à Windows, plus environ 10GB pour l'image elle-même.

L'installateur demande combien de RAM, combien de cœurs CPU et combien d'espace disque allouer (64GB ou plus est le minimum sensé), puis un nom d'utilisateur et un mot de passe Windows. Laissez-les vides et vous obtiendrez `docker` / `admin`. Le téléchargement prend un moment — 10-15 minutes, c'est normal — et vous pouvez suivre la progression dans le navigateur à `http://127.0.0.1:8006`. Le navigateur demande le même nom d'utilisateur et le même mot de passe avant d'ouvrir la console.

 ![windows-vm](images/windows-vm.webp)

## Utilisation

Une fois installée, lancez _Windows_ depuis le lanceur d'applications. Cela démarre la VM si elle n'est pas déjà en cours d'exécution et vous connecte via RDP, en plein écran. Laissez-lui 15-30 secondes lors d'un démarrage à froid.

La session RDP transporte le son, votre microphone et un presse-papiers partagé, donc copier du texte entre Linux et Windows fonctionne tout simplement. La résolution suit votre fenêtre, et Omarchy transmet la mise à l'échelle de votre affichage, donc ce n'est pas un flou infâme sur un écran HiDPI.

Quand vous fermez la fenêtre RDP, la VM s'arrête automatiquement. Si vous préférez la laisser tourner — disons que vous avez quelque chose qui travaille là-dedans — lancez-la plutôt avec `omarchy windows vm launch --keep-alive`.

Le reste des contrôles se trouve sur la même commande :

```bash
omarchy windows vm status    # is it running?
omarchy windows vm stop      # shut it down
omarchy windows vm launch    # start and connect
```

## Partage de fichiers

Le répertoire `~/Windows` de votre répertoire personnel est automatiquement partagé avec la VM. Mettez-y des fichiers si vous voulez qu'ils soient accessibles à Windows. La VM n'a accès à aucune autre partie de votre système de fichiers, donc vous êtes à l'abri de tout ce qui pourrait être dangereux du côté Windows. Son propre disque virtuel est disponible à `~/.windows`.

Ces chemins familiers du répertoire personnel restent sur leurs propres systèmes de fichiers. Ils peuvent aussi être des liens symboliques vers des répertoires qui vous appartiennent, ce qui est utile quand le disque virtuel se trouve sur un lecteur plus grand. L'installateur mesure l'espace libre sur le système de fichiers qui contient réellement `~/.windows`, pas nécessairement le système de fichiers contenant votre répertoire personnel.

Gardez le disque et les chemins partagés comme des répertoires séparés et qui ne se chevauchent pas. La suppression vide délibérément le répertoire du disque, mais préserve le répertoire partagé. Juste avant la suppression, Omarchy effectue une vérification de confinement bornée et refuse de supprimer quoi que ce soit si cette vérification expire ou ne peut pas prouver que les deux arborescences sont séparées.

Avant le démarrage de la VM, Omarchy ouvre et épingle ces deux répertoires, puis monte par liaison les inodes exacts des répertoires sur des ancres privées par utilisateur sous `/var/lib/omarchy/windows/mounts`. Docker ne voit que ces ancres protégées par root. Cela préserve les emplacements de disque personnalisés tout en empêchant un autre processus exécuté sous votre compte d'échanger un chemin vérifié avant que le conteneur privilégié ne le consomme. Les répertoires de disque et partagés existants sont resserrés au mode `0700` pendant la migration afin que les autres comptes locaux ne puissent pas parcourir leur contenu.

Les ports de la VM sont liés à localhost uniquement, donc rien sur votre réseau ne peut atteindre la machine Windows. La console web exige aussi le nom d'utilisateur et le mot de passe Windows configurés, empêchant un autre compte local de piloter la VM via le port 8006.

## Limites et licence

Il n'y a pas de passthrough GPU avec cette configuration, donc elle ne convient ni au jeu ni au montage vidéo. C'est un excellent moyen d'exécuter Microsoft Office ou tout autre logiciel dont vous avez absolument besoin.

La version installée est Windows 11 Pro, non activée. Vous aurez besoin de votre propre clé de licence pour utiliser les fonctionnalités restreintes.

Si cet ordinateur a été livré avec Windows, la clé OEM est toujours dans le firmware même après l'installation d'Omarchy. Affichez-la avec `omarchy windows key`. Cette clé est liée à cette machine — elle activera Windows réinstallé sur ce matériel, mais elle n'activera généralement pas la VM.

Vous pouvez modifier l'allocation des ressources plus tard en exécutant `omarchy windows vm install` dans un terminal, ce qui réécrit la configuration de la VM à partir de vos réponses. Le fichier compose lui-même se trouve désormais à `/var/lib/omarchy/windows/docker-compose.yml` et appartient à root — c'est délibéré, afin qu'un processus exécuté sous votre compte ne puisse pas le réécrire et faire monter tout votre disque dans le conteneur par le démarrage privilégié. Si vous devez le modifier à la main (par exemple pour monter un périphérique USB), modifiez-le avec `sudo` et voyez toutes les options sur [le projet Dockur Windows](https://github.com/dockur/windows).

Pour vous débarrasser de tout cela, utilisez _Suppression > Windows_ depuis le menu Omarchy. Cela supprime le disque de la VM dans `~/.windows` et tout ce qui est installé à l'intérieur de Windows, donc copiez d'abord hors de la VM tout ce dont vous avez besoin. Votre dossier partagé `~/Windows` est laissé tranquille.
