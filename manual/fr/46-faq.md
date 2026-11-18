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

La barre affichera automatiquement votre disposition de clavier actuelle dès que vous aurez configuré plusieurs dispositions (et vous pouvez aussi cliquer dessus pour en changer).

### Comment passer l'horloge au format 12 heures ?

Faites un clic droit sur l'horloge dans la barre pour faire défiler les formats courants, y compris ceux en 12 heures. Vous pouvez aussi définir le format directement :

```
omarchy bar set omarchy.clock format "dddd h:mm AP"
```

Cela affichera dimanche 10:55 AM.

### Comment changer mon fuseau horaire ?

Lancez _Update > Timezone_ dans le menu Omarchy et choisissez dans la liste. Si le fuseau horaire est correct mais que l'horloge elle-même a dérivé, _Update > Time_ redémarre la synchronisation de l'heure pour vous.

### Comment changer mon DNS, partager mon Wi-Fi ou vérifier la vitesse de ma connexion ?

Tout cela se trouve dans [réseau](35-networking.md).

### Comment vérifier la vitesse de mon disque ?

_Trigger > Speed Test > Disk Speed Test_ mesure en direct la vitesse de lecture et d'écriture de votre disque, ou `omarchy disk speedtest` depuis le terminal.

### Comment ajouter une imprimante ?

L'impression est configurée et fonctionne dès l'installation, et vous ajoutez vous-même chaque imprimante depuis _Print Settings_ dans le lanceur d'applications (`Super + Space`).

Choisissez _Add_, et laissez-lui un moment pour chercher : une imprimante branchée en USB, et la plupart des imprimantes réseau, sont détectées pour vous. Si la vôtre ne figure pas dans la liste, choisissez _Network Printer > Internet Printing Protocol (ipp)_ et saisissez son adresse — l'écran de l'imprimante elle-même ou sa page web vous dira laquelle, généralement quelque chose comme `192.168.1.50` avec une file `ipp/print`. _Forward_ propose ensuite un pilote : une imprimante moderne fonctionne au mieux avec le profil sans pilote _IPP Everywhere_, tandis qu'une plus ancienne réclame le pilote propre au modèle.

Faites un clic droit sur une imprimante et choisissez _Set as Default_ pour définir celle que vos applications utiliseront en premier, et _Properties_ pour régler le format de papier, le recto-verso et la qualité.

La découverte automatique, qui fait apparaître les imprimantes du réseau sans avoir à les ajouter, est temporairement désactivée le temps d'être retravaillée ; c'est pourquoi la première étape ci-dessus vous revient plutôt que d'être automatique. Imprimer dans un fichier PDF fonctionne sans aucune imprimante.

### Comment changer l'endroit où sont enregistrés les captures d'écran ou les enregistrements d'écran ?

Par défaut, les captures d'écran enregistrées vont dans `~/Pictures/Screenshots`. Pour utiliser un autre dossier, ajoutez ceci à un fichier sous `~/.config/uwsm/env.d/` (comme `~/.config/uwsm/env.d/capture`) :

```
export OMASNAP_SCREENSHOT_DIR="$HOME/Pictures/Captures"
```

Vous pouvez faire de même pour les enregistrements d'écran avec `OMARCHY_SCREENRECORD_DIR`.

Omasnap crée automatiquement son dossier de captures d'écran. Créez vous-même le dossier des enregistrements d'écran, puis redémarrez Omarchy pour que l'un ou l'autre changement d'environnement prenne effet.

### Comment faire fonctionner les haut-parleurs + la webcam de mon Apple Studio Display ?

On pourrait croire qu'il suffit de brancher en USB C pour que tout fonctionne, mais malheureusement ce n'est pas le cas. La solution que j'ai trouvée pour que ça marche de façon fiable, c'est d'utiliser [le câble WJESOG DisplayPort + USB-A => USB-C](https://www.amazon.com/WJESOG-DisplayPort-Adapter-Converter-Thunderbolt/dp/B0BNX7MS6N/). Là, les haut-parleurs et la webcam fonctionnent à merveille.

N'oubliez pas que vous disposez d'un contrôle de luminosité intégré dans Omarchy pour les écrans Apple (Studio comme XDR) via les touches de luminosité habituelles du clavier.

### Comment me débarrasser de tous les logiciels en trop ?

Si vous ne voulez pas de programmes comme Obsidian ou LibreOffice ou de tout autre truc préinstallé, vous pouvez très facilement les supprimer.

Lancez _Remove > Package_ pour voir tous les paquets installés. Vous pouvez ensuite sélectionner avec tab n'importe quel paquet que vous souhaitez supprimer, et lancer la suppression de tout ce que vous avez sélectionné avec return.

Et vous pouvez utiliser _Remove > Web App_ depuis le menu Omarchy pour supprimer n'importe laquelle des applications web préinstallées dont vous ne voulez pas.

Ou lancez _Remove > Preinstalls_ pour balayer d'un coup tous les extras préinstallés — applications web, TUIs et applications optionnelles. Les raccourcis clavier qui les lançaient disparaissent avec eux ; il ne vous reste qu'une page blanche de raccourcis à remplir avec les vôtres dans `~/.config/hypr/bindings.lua`.

---

Pour les erreurs et les trucs cassés, voir [la section Dépannage](45-troubleshooting.md).
