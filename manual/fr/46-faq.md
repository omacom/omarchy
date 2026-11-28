# FAQ

### Comment passer d'une disposition de clavier à l'autre ?

Modifiez votre fichier `~/.config/hypr/input.lua` et ajoutez ceci pour basculer entre les dispositions avec `Left Alt + Right Alt` :

```
hl.config({
  input = {
    -- Use multiple keyboard layouts and switch between them with Left Alt + Right Alt
    kb_layout = "us,fr",
    kb_options = "omarchy:shift_caps_compose,grp:alts_toggle",
  },
})
```

La barre affichera automatiquement votre disposition de clavier actuelle dès que vous aurez configuré plusieurs dispositions (et vous pouvez aussi cliquer dessus pour en changer).

### Comment passer l'horloge au format 12 heures ?

Cliquez avec le bouton droit sur l'horloge dans la barre pour faire défiler les formats courants, y compris ceux en 12 heures. Vous pouvez aussi définir le format directement :

```
omarchy bar set omarchy.clock format "dddd h:mm AP"
```

Cela affichera dimanche 10:55 AM.

### Comment changer de fuseau horaire ?

Lancez _Setup > Region > Timezone_ dans le menu Omarchy et choisissez dans la liste. Si le fuseau horaire est correct mais que l'horloge elle-même a dérivé, _Update > Time_ redémarre la synchronisation de l'heure pour vous.

### Comment changer mon DNS, partager mon Wi-Fi ou vérifier la vitesse de ma connexion ?

Tout cela se trouve dans [réseau](35-networking.md).

### Comment vérifier la vitesse de mon disque ?

_Trigger > Speed Test > Disk Speed Test_ mesure la vitesse de lecture et d'écriture en temps réel sur votre disque, ou `omarchy disk speedtest` depuis le terminal.

### Comment ajouter une imprimante ?

L'impression est configurée et fonctionne dès l'installation, et vous ajoutez vous-même chaque imprimante depuis _Print Settings_ dans le lanceur d'applications (`Super + Alt + Space`).

Choisissez _Add_, et laissez-lui un moment pour chercher : une imprimante branchée en USB, et la plupart des imprimantes réseau, sont détectées pour vous. Si la vôtre ne figure pas dans la liste, choisissez _Network Printer > Internet Printing Protocol (ipp)_ et saisissez son adresse — l'écran de l'imprimante ou sa page web vous dira ce que c'est, généralement quelque chose comme `192.168.1.50` avec une file `ipp/print`. _Forward_ propose ensuite un pilote, où une imprimante moderne fonctionne au mieux avec le profil sans pilote _IPP Everywhere_ et une plus ancienne préfère le pilote propre à son modèle.

Cliquez avec le bouton droit sur une imprimante et choisissez _Set as Default_ pour définir celle que vos applications utiliseront en premier, et _Properties_ pour régler le format de papier, le recto-verso et la qualité.

La découverte automatique, où les imprimantes du réseau apparaissent sans être ajoutées, est temporairement désactivée pendant qu'elle est retravaillée, c'est pourquoi la première étape ci-dessus vous revient plutôt que d'être automatique. L'impression dans un fichier PDF fonctionne sans aucune imprimante.

### Comment changer l'endroit où les captures d'écran ou les enregistrements d'écran sont enregistrés ?

Les captures d'écran enregistrées vont dans `~/Pictures/Screenshots` par défaut. Pour utiliser un autre répertoire, ajoutez ceci à un fichier sous `~/.config/uwsm/env.d/` (comme `~/.config/uwsm/env.d/capture`) :

```
export OMASNAP_SCREENSHOT_DIR="$HOME/Pictures/Captures"
```

Vous pouvez faire de même pour les enregistrements d'écran en utilisant `OMARCHY_SCREENRECORD_DIR`.

Omasnap crée automatiquement son répertoire de captures d'écran. Créez vous-même le répertoire des enregistrements d'écran, puis redémarrez Omarchy pour que l'un ou l'autre changement d'environnement prenne effet.

### Comment faire fonctionner les haut-parleurs + la webcam sur mon Apple Studio Display ?

On pourrait croire qu'il suffit de brancher l'USB C pour que tout fonctionne, mais ce n'est malheureusement pas le cas. La solution que j'ai trouvée pour que cela fonctionne de manière fiable est d'utiliser [le câble WJESOG DisplayPort + USB-A => USB-C](https://www.amazon.com/WJESOG-DisplayPort-Adapter-Converter-Thunderbolt/dp/B0BNX7MS6N/). Ensuite, les haut-parleurs et la webcam fonctionnent à merveille.

N'oubliez pas que vous disposez d'une commande de luminosité intégrée dans Omarchy pour les écrans Apple (Studio et XDR) à l'aide des touches de luminosité habituelles du clavier.

### Comment me débarrasser de tous les logiciels superflus ?

Si vous ne voulez pas de programmes comme Obsidian ou LibreOffice ou de toutes les autres choses préinstallées, vous pouvez les supprimer très facilement.

Lancez _Remove > Package_ pour voir tous les paquets installés. Vous pouvez ensuite sélectionner n'importe quel paquet que vous souhaitez supprimer avec tab, et commencer à supprimer tout ce que vous avez sélectionné avec return.

Et vous pouvez utiliser _Remove > Web App_ depuis le menu Omarchy pour supprimer n'importe laquelle des applications web préinstallées que vous ne voulez pas.

Ou lancez _Remove > Preinstalls_ pour balayer tous les extras préinstallés — applications web, TUI et applications optionnelles — en une seule fois. Les raccourcis clavier qui les lançaient disparaissent avec elles, vous vous retrouvez donc avec une ardoise vierge de raccourcis à remplir avec les vôtres dans `~/.config/hypr/bindings.lua`.

---

Pour les erreurs et les éléments cassés, consultez [la section Dépannage](45-troubleshooting.md).
