# FAQ

### Comment basculer entre les dispositions de clavier ?

Modifiez votre fichier `~/.config/hypr/input.lua` et ajoutez ceci pour basculer entre les dispositions sur `Left Alt + Right Alt` :

```
hl.config({
  input = {
    -- Use multiple keyboard layouts and switch between them with Left Alt + Right Alt
    kb_layout = "us,fr",
    kb_options = "omarchy:shift_caps_compose,grp:alts_toggle",
  },
})
```

La barre affichera automatiquement votre disposition de clavier actuelle dès que vous aurez configuré plusieurs dispositions (et vous pouvez aussi cliquer dessus pour basculer).

### Comment passer le format d'horloge en 12 heures ?

Cliquez droit sur l'horloge dans la barre pour parcourir les formats courants, y compris ceux en 12 heures. Vous pouvez aussi définir le format directement :

```
omarchy bar set omarchy.clock format "dddd h:mm AP"
```

Cela affichera Sunday 10:55 AM.

### Comment changer mon fuseau horaire ?

Lancez _Mettre à jour > Fuseau horaire_ dans le menu Omarchy et choisissez dans la liste. Si le fuseau horaire est correct mais que l'horloge elle-même a dérivé, _Mettre à jour > Heure_ redémarre la synchronisation de l'heure pour vous.

### Comment changer mon DNS, partager mon Wi-Fi ou vérifier la vitesse de ma connexion ?

Tout cela se trouve dans [réseau](35-networking.md).

### Comment vérifier la vitesse de mon disque ?

_Déclencher > Test de vitesse > Test débit disque_ mesure en direct la vitesse de lecture et d'écriture sur votre disque, ou `omarchy disk speedtest` depuis le terminal.

### Pourquoi ne puis-je pas me connecter à mon compte Google dans Chromium ?

La version ouverte ordinaire de Chromium n'est pas livrée avec les identifiants OAuth que Google exige pour la connexion au compte. Lancez _Installer > Service > Chromium Account_ dans le menu Omarchy pour les ajouter, redémarrez le navigateur, et la connexion passera.

### Comment ajouter une imprimante ?

L'impression est configurée et fonctionne d'emblée, et vous ajoutez chaque imprimante vous-même depuis _Réglages d'impression_ dans le lanceur d'applications (`Super + Space`).

Choisissez _Ajouter_, et laissez-lui un moment pour chercher : une imprimante branchée en USB, et la plupart des imprimantes réseau, sont trouvées pour vous. Si la vôtre n'est pas dans la liste, choisissez _Imprimante réseau > Internet Printing Protocol (ipp)_ et saisissez son adresse — l'écran de l'imprimante ou sa page web vous dira ce que c'est, en général quelque chose comme `192.168.1.50` avec une file `ipp/print`. _Suivant_ propose ensuite un pilote, où une imprimante moderne fonctionne au mieux avec le profil sans pilote _IPP Everywhere_ et une plus ancienne veut le pilote propre au modèle.

Cliquez droit sur une imprimante et choisissez _Définir comme imprimante par défaut_ pour choisir celle que vos applications utilisent en premier, et _Propriétés_ pour définir le format de papier, le recto verso et la qualité.

La découverte automatique, où les imprimantes du réseau apparaissent sans être ajoutées, est temporairement désactivée pendant son remaniement, c'est pourquoi la première étape ci-dessus vous incombe plutôt qu'elle n'est automatique. L'impression dans un fichier PDF fonctionne sans aucune imprimante.

### Comment changer l'endroit où sont enregistrées les captures d'écran ou les enregistrements d'écran ?

Les captures d'écran enregistrées vont par défaut dans `~/Pictures/Screenshots`. Pour utiliser un autre répertoire, ajoutez ceci à un fichier sous `~/.config/uwsm/env.d/` (comme `~/.config/uwsm/env.d/capture`) :

```
export OMASNAP_SCREENSHOT_DIR="$HOME/Pictures/Captures"
```

Vous pouvez faire la même chose pour les enregistrements d'écran avec `OMARCHY_SCREENRECORD_DIR`.

Omasnap crée son répertoire de captures d'écran automatiquement. Créez le répertoire d'enregistrement d'écran vous-même, puis redémarrez Omarchy pour que l'un ou l'autre changement d'environnement prenne effet.

### Comment faire fonctionner les enceintes + la webcam de mon Apple Studio Display ?

On penserait que tout devrait fonctionner simplement en branchant l'USB C, mais malheureusement ce n'est pas le cas. La solution que j'ai trouvée pour que ça fonctionne de façon fiable est d'utiliser [le câble WJESOG DisplayPort + USB-A => USB-C](https://www.amazon.com/WJESOG-DisplayPort-Adapter-Converter-Thunderbolt/dp/B0BNX7MS6N/). Les enceintes et la webcam marchent alors à merveille.

Rappelez-vous que vous disposez dans Omarchy d'un contrôle de luminosité intégré pour les écrans Apple (Studio et XDR) avec les boutons de luminosité habituels du clavier.

### Comment me débarrasser de tous les logiciels supplémentaires ?

Si vous ne voulez pas de programmes comme Obsidian ou LibreOffice ou tout le reste du préinstallé, vous pouvez très facilement les retirer.

Lancez _Supprimer > Paquet_ pour voir chaque paquet installé. Vous pouvez ensuite sélectionner tout paquet que vous voulez retirer avec la tabulation, et commencer à retirer tout ce que vous avez sélectionné avec entrée.

Et vous pouvez utiliser _Supprimer > Application web_ depuis le menu Omarchy pour retirer toute application web préinstallée que vous ne voulez pas.

Ou lancez _Supprimer > Préinstallations_ pour balayer tous les extras préinstallés — applications web, TUI et applications optionnelles — en une fois. Les raccourcis qui les lançaient disparaissent avec eux, il vous reste donc une ardoise vierge de raccourcis à remplir avec les vôtres dans `~/.config/hypr/bindings.lua`.

---

Pour les erreurs et les morceaux cassés, voir [la section Dépannage](45-troubleshooting.md).
