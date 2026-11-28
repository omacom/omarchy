# Ajustements courants

Voici une collection d'ajustements courants de la configuration d'Omarchy. Sachez qu'il peut parfois être nécessaire, lors de mises à jour du système, de restaurer certaines configurations dans leur état d'origine. Si cela se produit, vos modifications ne seront pas perdues, mais placées dans un fichier `.bak.<timestamp>` à côté de l'original.

Si vous cassez quelque chose, vous pouvez restaurer les configurations individuelles dans leur configuration d'origine via _Update > Config_ dans le menu Omarchy. Si vous cassez *vraiment* tout, vous pouvez réinitialiser toutes les configurations via `omarchy reinstall configs`, ou réinstaller tous les paquets et toutes les configurations par défaut avec `omarchy reinstall`.

### Afficher toutes les icônes de la zone de notification en permanence

Par défaut, les icônes de la zone de notification, comme Dropbox, 1password ou Steam, sont masquées derrière la flèche d'extension de la zone de notification, qui les révèle lorsque vous la survolez. Si vous souhaitez qu'elles restent affichées en permanence, cliquez avec le bouton droit sur la flèche d'extension pour ouvrir le gestionnaire d'icônes de la zone de notification, puis épinglez les icônes que vous voulez garder visibles (vous pouvez aussi masquer celles que vous ne voulez jamais voir).

### Coins de fenêtre arrondis

Le design par défaut d'Omarchy repose sur des coins carrés, mais si vous aimez adoucir un peu tout ça, choisissez _Appearance > Windows > Window Corners > Rounded Corners_ dans le menu Omarchy, ou exécutez `omarchy hyprland corners rounded`. _Theme Corners_ revient à ce que le thème utilise. Pour choisir votre propre rayon, restez sur _Theme Corners_ (`omarchy hyprland corners theme`), puisque Rounded et Sharp se chargent après votre configuration et la remplacent, et décommentez l'arrondi dans `~/.config/hypr/looknfeel.lua` :

```
hl.config({
  decoration = {
    -- Use round window corners.
    rounding = 8,
  },
})
```

### Supprimer les espaces entre les fenêtres

Sur les écrans d'ordinateurs portables, certaines personnes préfèrent ne gaspiller aucun pixel pour les espaces entre les fenêtres (ni même pour une barre supérieure, que vous pouvez désactiver avec `Super + Shift + Space`). Vous pouvez désactiver tous les espaces et toutes les bordures avec `Super + Shift + Backspace`, ou les supprimer définitivement en retirant les commentaires dans cette section de `~/.config/hypr/looknfeel.lua` :

```
hl.config({
  general = {
    -- No gaps between windows or borders.
    gaps_in = 0,
    gaps_out = 0,
    border_size = 0,
  },
})
```
