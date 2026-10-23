# Dépannage

### J'ai cassé mon système avec une mise à jour !

Essayez d'abord de [restaurer votre système](47-system-snapshots.md) à la version d'avant votre récente mise à jour. Si cela ne fonctionne pas, utilisez `omarchy-debug` pour partager votre problème sur #omarchy-help dans le Discord. Et si tout cela échoue, vous pouvez réinstaller les configurations et paquets par défaut avec `omarchy-reinstall`.

### Pourquoi certaines applications sont-elles si grandes sur mon écran ?

Omarchy suppose un écran haute résolution en 2x, ce qui nécessite de définir `GDK_SCALE` à 2 dans `~/.config/hypr/monitors.lua`. Mais si vous êtes sur un écran 1x, vous pouvez changer `local omarchy_gdk_scale = 2` en 1 (puis redémarrer toute application surdimensionnée). Voir [le manuel sur les écrans](33-monitors.md).

Pour Spotify, vous pouvez utiliser `Ctrl + Minus` pour rétrécir l'interface (et `Ctrl + Plus` pour l'agrandir).

### Mon Wi-Fi, mon Bluetooth, mon audio ou mon pavé tactile vient d'arrêter de fonctionner

Avant de redémarrer, essayez de redémarrer le sous-système fautif tout seul. _Mettre à jour > Matériel_ dans le menu Omarchy propose Wi-Fi, Bluetooth, Audio et Pavé tactile, et en recharger un résout la majorité des situations du type « ça marchait il y a cinq minutes » — un casque Bluetooth qui ne veut pas se reconnecter, un pavé tactile mort après une suspension, un son disparu quand vous avez débranché un écran.

### Pourquoi mes enceintes externes ne jouent-elles pas ?

Probablement parce qu'elles ne sont pas définies comme sortie principale. Cliquez sur l'icône haut-parleur à droite de la barre, et cela ouvrira la fenêtre contextuelle de volume où vous pouvez choisir le périphérique de sortie (et aussi mixer les volumes par application).

### Les enceintes de mon portable sonnent mal

Sur certains portables, Omarchy applique automatiquement un réglage d'enceintes qui corrige la réponse en fréquence des enceintes intégrées. `omarchy audio tuning status` vous dit si l'un est actif sur votre machine, et `omarchy audio tuning off` le désactive si vous préférez entendre les enceintes brutes.

### Pourquoi ne puis-je pas me connecter ni utiliser sudo avec mon mot de passe ?

Vous l'avez probablement mal tapé trop de fois et vous êtes verrouillé. Si cela se produit sur l'écran de verrouillage, vous pouvez appuyer sur `CTRL + ALT + F2` pour lancer un nouveau TTY où vous pouvez vous connecter en root, puis lancer `faillock --reset --user [your-username]`. Cela réinitialisera le verrouillage, et vous serez prêt à repartir.

### Pourquoi mes invites d'autorisation 1Password pour 1Password SSH Agent / CLI n'apparaissent-elles pas ?

Cela peut se produire pour deux raisons :

Pour que l'invite d'approbation riche apparaisse, Réglages > Avancé > Utiliser l'accélération matérielle doit être activé. _Remarque : cela nécessite un redémarrage pour commencer à fonctionner._

 ![troubleshooting-1password](images/troubleshooting-1password.webp)

Ou si vous n'avez pas lancé 1Password depuis le démarrage, l'invite n'apparaîtra pas.
