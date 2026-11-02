# Ajustări obișnuite

Aceasta este o colecție de personalizări obișnuite ale configurației Omarchy. Să știi că ocazional ar putea fi necesar ca actualizările de sistem să restabilească anumite configurații la starea lor originală. Dacă se întâmplă asta, schimbările tale nu se vor pierde, ci vor fi puse într-un fișier `.bak` în același director.

Dacă strici ceva, poți restabili configurații individuale la configurația lor originală prin _Actualizează > Configurare_ în meniul Omarchy. Dacă strici _cu adevărat_ totul, poți reseta toate configurațiile prin `omarchy-reinstall`.

### Dezvăluirea permanentă a tuturor pictogramelor din tavă

Implicit, pictogramele din tavă, precum Dropbox, 1password sau Steam, sunt ascunse în spatele săgeții de extindere a tăvii, care le dezvăluie când treci cu indicatorul peste ea. Dacă ai vrea să le ai expuse tot timpul, fă clic dreapta pe săgeata de extindere ca să deschizi managerul de pictograme din tavă, apoi fixează pictogramele pe care vrei să le păstrezi vizibile (le poți ascunde și pe cele pe care nu vrei niciodată să le vezi).

### Colțuri rotunjite ale ferestrelor

Designul implicit al Omarchy este unul cu colțuri pătrate, dar dacă îți place să îndulcești puțin asta, poți schimba `~/.config/hypr/looknfeel.lua` astfel încât rotunjirea să nu mai fie comentată:

```
hl.config({
  decoration = {
    -- Use round window corners.
    rounding = 8,
  },
})
```

### Eliminarea spațiilor dintre ferestre

Pe afișajele de laptop, unii oameni preferă să nu irosească niciun pixel pe spațiile dintre ferestre (sau chiar pe o bară de sus, pe care o poți dezactiva cu `Super + Shift + Space`). Poți dezactiva toate spațiile și marginile cu `Super + Shift + Backspace` sau le poți elimina permanent ștergând comentariile din această secțiune a `~/.config/hypr/looknfeel.lua`:

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
