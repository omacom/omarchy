# Modifiche comuni

Questa è una raccolta di personalizzazioni comuni della configurazione di Omarchy. Tieni presente che a volte gli aggiornamenti di sistema potrebbero dover riportare certe configurazioni allo stato originale. Se succede, le tue modifiche non andranno perse, ma finiranno in un file `.bak.<timestamp>` accanto all'originale.

Se combini un pasticcio, puoi ripristinare le singole configurazioni alla loro impostazione originale tramite _Aggiorna > Configurazione_ nel menu di Omarchy. Se combini *davvero* un disastro, puoi reimpostare tutte le configurazioni tramite `omarchy reinstall configs`, oppure reinstallare ogni pacchetto e configurazione predefiniti con `omarchy reinstall`.

### Mostra sempre tutte le icone del vassoio

Per impostazione predefinita, le icone del vassoio, come Dropbox, 1password o Steam, sono nascoste dietro la freccia di espansione del vassoio, che le rivela quando ci passi sopra. Se vuoi tenerle sempre esposte, fai clic con il pulsante destro del mouse sulla freccia di espansione per aprire il gestore delle icone del vassoio, quindi fissa le icone che vuoi mantenere visibili (puoi anche nascondere quelle che non vuoi mai vedere).

### Angoli delle finestre arrotondati

Il design predefinito di Omarchy prevede angoli squadrati, ma se vuoi ammorbidirlo un po', scegli _Aspetto > Finestre > Angoli finestre > Angoli arrotondati_ nel menu di Omarchy, oppure esegui `omarchy hyprland corners rounded`. _Angoli tema_ torna a ciò che usa il tema. Per scegliere un raggio personalizzato, resta su _Angoli tema_ (`omarchy hyprland corners theme`), poiché Angoli arrotondati e Angoli netti vengono caricati dopo la tua configurazione e la sostituiscono, e togli il commento all'arrotondamento in `~/.config/hypr/looknfeel.lua`:

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
