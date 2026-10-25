# Ajustements courants

Voici une collection d'adaptations courantes de la configuration Omarchy. Sachez qu'il peut occasionnellement être nécessaire pour les mises à jour système de restaurer certaines configurations dans leur état d'origine. Si cela se produit, vos changements ne seront pas perdus, mais placés dans un fichier `.bak` dans le même répertoire.

Si vous cassez quelque chose, vous pouvez restaurer les configurations individuelles dans leur état d'origine via _Mettre à jour > Config_ dans le menu Omarchy. Si vous cassez _vraiment_ tout, vous pouvez réinitialiser toutes les configurations via `omarchy-reinstall`.

### Révéler toutes les icônes de la zone de notification en permanence

Par défaut, les icônes de la zone de notification, comme Dropbox, 1Password ou Steam, sont cachées derrière la flèche d'expansion, qui les révèle quand vous la survolez. Si vous voulez les avoir exposées en permanence, cliquez droit sur la flèche d'expansion pour ouvrir le gestionnaire d'icônes, puis épinglez les icônes que vous voulez garder visibles (vous pouvez aussi masquer celles que vous ne voulez jamais voir).

### Coins de fenêtres arrondis

Le design par défaut d'Omarchy mise sur les coins carrés, mais si vous voulez adoucir un peu cela, vous pouvez modifier `~/.config/hypr/looknfeel.lua` pour que l'arrondi ne soit plus commenté :

```
hl.config({
  decoration = {
    -- Use round window corners.
    rounding = 8,
  },
})
```

### Retirer les espacements entre fenêtres

Sur les écrans de portable, certains préfèrent ne gaspiller aucun pixel dans les espacements entre fenêtres (ni même une barre du haut, que vous pouvez masquer avec `Super + Shift + Space`). Vous pouvez désactiver tous les espacements et bordures avec `Super + Shift + Backspace`, ou les retirer définitivement en enlevant les commentaires de cette section de `~/.config/hypr/looknfeel.lua` :

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
