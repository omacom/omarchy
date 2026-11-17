# Ajustos habituals

Aquesta és una col·lecció de personalitzacions habituals de la configuració d'Omarchy. Tingues present que de vegades pot ser necessari que les actualitzacions del sistema restaurin certes configuracions a la seva condició original. Si això passa, els teus canvis no es perdran, sinó que quedaran en un fitxer `.bak` al mateix directori.

Si espatlles alguna cosa, pots restaurar configuracions individuals a la seva configuració original via _Actualitza > Configuració_ al menú d'Omarchy. Si ho espatlles _tot_ de debò, pots restablir totes les configuracions via `omarchy-reinstall`.

### Mostrar totes les icones de la safata sempre

Per defecte, les icones de la safata, com les de Dropbox, 1Password o Steam, queden amagades darrere de la fletxa desplegable de la safata, que les mostra quan hi passes el cursor per sobre. Si vols tenir-les visibles sempre, fes clic amb el botó dret a la fletxa desplegable per obrir el gestor d'icones de la safata i, a continuació, fixa les icones que vols mantenir visibles (també pots amagar les que no vulguis veure mai).

### Cantons de finestra arrodonits

El disseny per defecte d'Omarchy és de cantons rectes, però si t'agrada suavitzar-ho una mica, pots canviar `~/.config/hypr/looknfeel.lua` perquè l'arrodoniment ja no quedi comentat:

```
hl.config({
  decoration = {
    -- Use round window corners.
    rounding = 8,
  },
})
```

### Eliminar la separació entre finestres

A les pantalles de portàtil, hi ha gent que prefereix no malgastar cap píxel en separacions entre finestres (ni tan sols en una barra superior, que pots desactivar amb `Super + Shift + Space`). Pots desactivar totes les separacions i vores amb `Super + Shift + Backspace`, o eliminar-les permanentment traient els comentaris d'aquesta secció de `~/.config/hypr/looknfeel.lua`:

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
