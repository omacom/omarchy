# Ajustări frecvente

Aceasta este o colecție de personalizări frecvente ale configurației Omarchy. Reține că, ocazional, ar putea fi necesar ca actualizările de sistem să restaureze anumite configurații la starea lor originală. Dacă se întâmplă acest lucru, modificările tale nu se vor pierde, ci vor fi puse într-un fișier `.bak.<timestamp>` lângă original.

Dacă strici ceva, poți restaura configurațiile individuale la configurația lor originală prin _Update > Config_ din meniul Omarchy. Dacă strici _chiar_ totul, poți reseta toate configurațiile prin `omarchy reinstall configs` sau poți reinstala fiecare pachet și configurație implicite cu `omarchy reinstall`.

### Afișează permanent toate pictogramele din tray

În mod implicit, pictogramele din tray, precum Dropbox, 1password sau Steam, sunt ascunse în spatele săgeții de extindere a tray-ului, care le dezvăluie atunci când treci cursorul peste ea. Dacă vrei să fie expuse tot timpul, fă clic dreapta pe săgeata de extindere pentru a deschide managerul de pictograme din tray, apoi fixează pictogramele pe care vrei să le menții vizibile (le poți ascunde și pe cele pe care nu vrei să le vezi niciodată).

### Colțuri rotunjite ale ferestrelor

Designul implicit al Omarchy folosește colțuri pătrate, dar dacă vrei să îndulcești puțin acest aspect, alege _Appearance > Windows > Window Corners > Rounded Corners_ din meniul Omarchy sau rulează `omarchy hyprland corners rounded`. _Theme Corners_ revine la valoarea folosită de temă. Pentru a-ți alege propria rază, rămâi pe _Theme Corners_ (`omarchy hyprland corners theme`), deoarece Rounded și Sharp se încarcă după configurația ta și o suprascriu, și decomentează rotunjirea în `~/.config/hypr/looknfeel.lua`:

```
hl.config({
  decoration = {
    -- Use round window corners.
    rounding = 8,
  },
})
```

### Elimină spațiile dintre ferestre

Pe ecranele de laptop, unii oameni preferă să nu irosească niciun pixel pe spațiile dintre ferestre (sau chiar pe o bară superioară, pe care o poți dezactiva cu `Super + Shift + Space`). Poți dezactiva toate spațiile și marginile cu `Super + Shift + Backspace` sau le poți elimina permanent ștergând comentariile din această secțiune a `~/.config/hypr/looknfeel.lua`:

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
