# Ajustos comuns

Aquesta és una col·lecció d'ajustos habituals per a la configuració d'Omarchy. Tingues en compte que de tant en tant pot ser necessari que les actualitzacions del sistema restaurin determinades configuracions al seu estat original. Si això passa, els teus canvis no es perdran, sinó que es desaran en un fitxer `.bak.<timestamp>` al costat de l'original.

Si espatlles alguna cosa, pots restaurar configuracions individuals a la seva configuració original mitjançant _Actualització > Configuració_ al menú d'Omarchy. Si _realment_ ho espatlles tot, pots restablir totes les configuracions mitjançant `omarchy reinstall configs`, o reinstal·lar tots els paquets i configuracions per defecte amb `omarchy reinstall`.

### Mostra sempre totes les icones de la safata

Per defecte, les icones de la safata, com Dropbox, 1password o Steam, s'amaguen darrere de la fletxa d'expansió de la safata, que les mostra quan hi passes el cursor per sobre. Si vols que es vegin sempre, fes clic amb el botó dret a la fletxa d'expansió per obrir el gestor d'icones de la safata i fixa les icones que vols mantenir visibles (també pots amagar les que no vols veure mai).

### Cantonades de finestra arrodonides

El disseny per defecte d'Omarchy és de cantonades quadrades, però si t'agrada suavitzar-lo una mica, tria _Aparença > Finestres > Cantonades de finestra > Cantonades arrodonides_ al menú d'Omarchy, o executa `omarchy hyprland corners rounded`. _Cantonades del tema_ torna a les que utilitzi el tema. Per triar el teu propi radi, mantén _Cantonades del tema_ (`omarchy hyprland corners theme`), ja que Arrodonides i Rectes es carreguen després de la teva configuració i la sobreescriuen, i descomenta l'arrodoniment a `~/.config/hypr/looknfeel.lua`:

```
hl.config({
  decoration = {
    -- Use round window corners.
    rounding = 8,
  },
})
```

### Elimina els espais entre finestres

A les pantalles de portàtil, algunes persones prefereixen no malgastar cap píxel en espais entre finestres (ni tan sols en una barra superior, que pots desactivar amb `Super + Shift + Space`). Pots desactivar tots els espais i vores amb `Super + Shift + Backspace`, o eliminar-los permanentment traient els comentaris d'aquesta secció de `~/.config/hypr/looknfeel.lua`:

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
