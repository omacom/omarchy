# FAQ

### Comment passer d'une disposition de clavier à l'autre ?

Modifiez votre fichier `~/.config/hypr/input.lua` et ajoutez ceci pour passer d'une disposition à l'autre avec `Left Alt + Right Alt` :

```
hl.config({
  input = {
    -- Use multiple keyboard layouts and switch between them with Left Alt + Right Alt
    kb_layout = "us,fr",
    kb_options = "omarchy:shift_caps_compose,grp:alts_toggle",
  },
})
```

La barre affichera automatiquement votre disposition de clavier actuelle dès que vous aurez configuré plusieurs dispositions (et vous pouvez aussi cliquer dessus pour changer).

### Comment passer l'horloge au format 12 heures ?

Cliquez avec le bouton droit sur l'horloge dans la barre pour parcourir les formats courants, y compris ceux en 12 heures. Vous pouvez aussi définir le format directement :

```
omarchy bar set omarchy.clock format "dddd h:mm AP"
```

Cela affichera dimanche 10:55 AM.

### Comment changer mon fuseau horaire ?

Lancez _Configuration > Région > Fuseau horaire_ dans le menu Omarchy et choisissez dans la liste. Si le fuseau horaire est correct mais que l'horloge elle-même a dérivé, _Mise à jour > Heure_ relance la synchronisation de l'heure pour vous.

### Comment changer mon DNS, partager mon Wi-Fi ou vérifier la vitesse de ma connexion ?

Tout cela se trouve dans [réseau](35-networking.md).

### Comment vérifier la vitesse de mon disque ?

_Déclencheur > Test de vitesse > Test de vitesse du disque_ mesure la vitesse de lecture et d'écriture en direct sur votre disque, ou `omarchy disk speedtest` depuis le terminal.

### Comment ajouter une imprimante ?

L'impression est configurée et fonctionne dès l'installation, et vous ajoutez vous-même chaque imprimante depuis _Paramètres d'impression_ dans le lanceur d'applications (`Super + Space`).

Choisissez _Ajouter_, et laissez-lui un moment pour chercher : une imprimante branchée en USB, et la plupart des imprimantes réseau, sont détectées pour vous. Si la vôtre n'est pas dans la liste, choisissez _Imprimante réseau > Internet Printing Protocol (ipp)_ et saisissez son adresse — l'écran de l'imprimante elle-même ou sa page web vous dira ce que c'est, généralement quelque chose comme `192.168.1.50` avec une file `ipp/print`. _Suivant_ propose ensuite un pilote, où une imprimante moderne fonctionne au mieux avec le profil sans pilote _IPP Everywhere_ et une plus ancienne voudra le pilote propre à son modèle.

Cliquez avec le bouton droit sur une imprimante et choisissez _Définir par défaut_ pour choisir celle que vos applications utilisent en premier, et _Propriétés_ pour définir la taille du papier, le recto verso et la qualité.

La découverte automatique, où les imprimantes du réseau apparaissent sans être ajoutées, est temporairement désactivée pendant qu'elle est retravaillée, ce qui explique pourquoi la première étape ci-dessus vous revient plutôt qu'elle soit automatique. L'impression dans un fichier PDF fonctionne sans aucune imprimante.

### Comment changer l'endroit où les captures d'écran ou les enregistrements d'écran sont enregistrés ?

Les captures d'écran enregistrées vont par défaut dans `~/Pictures/Screenshots`. Pour utiliser un autre répertoire, ajoutez ceci à un fichier sous `~/.config/uwsm/env.d/` (comme `~/.config/uwsm/env.d/capture`) :

```
export OMASNAP_SCREENSHOT_DIR="$HOME/Pictures/Captures"
```

Vous pouvez faire la même chose pour les enregistrements d'écran en utilisant `OMARCHY_SCREENRECORD_DIR`.

Omasnap crée automatiquement son répertoire de captures d'écran. Créez vous-même le répertoire des enregistrements d'écran, puis redémarrez Omarchy pour que l'un ou l'autre changement d'environnement prenne effet.

### Comment faire fonctionner les haut-parleurs + la webcam sur mon Apple Studio Display ?

On pourrait penser que tout devrait fonctionner simplement en branchant l'USB C, mais malheureusement, ce n'est pas le cas. La solution que j'ai trouvée pour que ça fonctionne de manière fiable est d'utiliser [le câble WJESOG DisplayPort + USB-A => USB-C](https://www.amazon.com/WJESOG-DisplayPort-Adapter-Converter-Thunderbolt/dp/B0BNX7MS6N/). Ensuite, les haut-parleurs et la webcam fonctionnent à merveille.

N'oubliez pas que vous disposez d'une commande intégrée de la luminosité dans Omarchy pour les écrans Apple (à la fois Studio et XDR) en utilisant les touches habituelles de luminosité du clavier.

### Comment me débarrasser de tous les logiciels supplémentaires ?

Si vous ne voulez pas de programmes comme Obsidian ou LibreOffice ou n'importe lequel des autres trucs préinstallés, vous pouvez très facilement les supprimer.

Lancez _Suppression > Paquet_ pour voir tous les paquets installés. Vous pouvez ensuite sélectionner n'importe quel paquet que vous souhaitez supprimer avec tab, et commencer à supprimer tout ce que vous avez sélectionné avec return.

Et vous pouvez utiliser _Suppression > Application web_ depuis le menu Omarchy pour supprimer n'importe laquelle des applications web préinstallées que vous ne voulez pas.

Ou lancez _Suppression > Préinstallés_ pour balayer tous les extras préinstallés — applications web, TUI et applications optionnelles — en une seule fois. Les raccourcis clavier qui les lançaient disparaissent avec eux, il ne vous reste donc qu'une ardoise vierge de raccourcis à remplir avec les vôtres dans `~/.config/hypr/bindings.lua`.

---

Pour les erreurs et les éléments cassés, voir [la section Dépannage](45-troubleshooting.md).
