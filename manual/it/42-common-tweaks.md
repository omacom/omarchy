# Modifiche comuni

Questa è una raccolta di personalizzazioni comuni alla configurazione di Omarchy. Tieni presente che occasionalmente potrebbe essere necessario che gli aggiornamenti di sistema ripristinino alcune configurazioni allo stato originale. Se succede, le tue modifiche non andranno perse, ma verranno messe in un file `.bak.<timestamp>` accanto all'originale.

Se combini un pasticcio, puoi ripristinare le singole configurazioni alla loro impostazione originale tramite _Update > Config_ nel menu di Omarchy. Se combini *davvero* un disastro, puoi reimpostare tutte le configurazioni tramite `omarchy reinstall configs`, oppure reinstallare ogni pacchetto e configurazione predefiniti con `omarchy reinstall`.

### Mostra sempre tutte le icone della barra di sistema

Per impostazione predefinita, le icone della barra di sistema, come Dropbox, 1password o Steam, sono nascoste dietro la freccia di espansione della barra di sistema, che le rivela quando ci passi sopra. Se vuoi tenerle sempre esposte, fai clic con il pulsante destro del mouse sulla freccia di espansione per aprire il gestore delle icone della barra di sistema, quindi fissa le icone che vuoi mantenere visibili (puoi anche nascondere quelle che non vuoi mai vedere).

### Angoli delle finestre arrotondati

Il design predefinito di Omarchy prevede angoli squadrati, ma se vuoi ammorbidirlo un po', scegli _Appearance > Windows > Window Corners > Rounded Corners_ nel menu di Omarchy, oppure esegui `omarchy hyprland corners rounded`. _Theme Corners_ torna a ciò che usa il tema. Per scegliere un raggio personalizzato, resta su _Theme Corners_ (`omarchy hyprland corners theme`), poiché Rounded e Sharp vengono caricati dopo la tua configurazione e la sostituiscono, e decommenta rounding in `~/.config/hypr/looknfeel.lua`:

```
hl.config({
  decoration = {
    -- Use round window corners.
    rounding = 8,
  },
})
```

### Rimuovi gli spazi tra le finestre

Sugli schermi dei laptop, alcune persone preferiscono non sprecare neanche un pixel per gli spazi tra le finestre (o persino per una barra superiore, che puoi disattivare con `Super + Shift + Space`). Puoi disattivare tutti gli spazi e i bordi con `Super + Shift + Backspace`, oppure rimuoverli in modo permanente rimuovendo i commenti in questa sezione di `~/.config/hypr/looknfeel.lua`:

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
