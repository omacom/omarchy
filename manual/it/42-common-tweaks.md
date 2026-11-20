# Ritocchi comuni

Questa è una raccolta di personalizzazioni comuni della configurazione di Omarchy. Tieni presente che a volte gli aggiornamenti di sistema potrebbero dover riportare certe configurazioni allo stato originale. Se succede, le tue modifiche non andranno perse, ma finiranno in un file `.bak` nella stessa directory.

Se combini qualche pasticcio, puoi ripristinare le singole configurazioni alla loro impostazione originale tramite _Aggiorna > Configurazione_ nel menu di Omarchy. Se combini _davvero_ un pasticcio completo, puoi reimpostare tutte le configurazioni con `omarchy-reinstall`.

### Mostra sempre tutte le icone del vassoio

Per impostazione predefinita, le icone del vassoio, come Dropbox, 1Password o Steam, sono nascoste dietro la freccia di espansione del vassoio, che le rivela quando ci passi sopra. Se vuoi tenerle sempre visibili, fai clic con il tasto destro sulla freccia di espansione per aprire il gestore delle icone del vassoio, poi fissa le icone che vuoi mantenere visibili (puoi anche nascondere quelle che non vuoi mai vedere).

### Angoli delle finestre arrotondati

Il design predefinito di Omarchy è fatto di angoli squadrati, ma se vuoi ammorbidirlo un po', puoi modificare `~/.config/hypr/looknfeel.lua` togliendo il commento all'arrotondamento:

```
hl.config({
  decoration = {
    -- Use round window corners.
    rounding = 8,
  },
})
```

### Rimuovi gli spazi tra le finestre

Sugli schermi dei portatili, alcune persone preferiscono non sprecare neanche un pixel per gli spazi tra le finestre (o persino per una barra superiore, che puoi disattivare con `Super + Shift + Space`). Puoi disattivare tutti gli spazi e i bordi con `Super + Shift + Backspace`, oppure rimuoverli in modo permanente togliendo i commenti in questa sezione di `~/.config/hypr/looknfeel.lua`:

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
