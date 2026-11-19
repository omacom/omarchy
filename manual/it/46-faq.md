# FAQ

### Come faccio a passare da un layout di tastiera all'altro?

Modifica il file `~/.config/hypr/input.lua` e aggiungi questo per passare da un layout all'altro con `Left Alt + Right Alt`:

```
hl.config({
  input = {
    -- Use multiple keyboard layouts and switch between them with Left Alt + Right Alt
    kb_layout = "us,fr",
    kb_options = "omarchy:shift_caps_compose,grp:alts_toggle",
  },
})
```

La barra mostrerà automaticamente il layout di tastiera attuale una volta configurati più layout (e puoi anche farci clic sopra per cambiarlo).

### Come faccio a cambiare il formato dell'orologio in 12 ore?

Fai clic con il pulsante destro sull'orologio nella barra per scorrere i formati comuni, inclusi quelli a 12 ore. Puoi anche impostare il formato direttamente:

```
omarchy bar set omarchy.clock format "dddd h:mm AP"
```

Verrà visualizzato domenica 10:55 AM.

### Come faccio a cambiare il mio fuso orario?

Avvia _Setup > Region > Timezone_ nel menu di Omarchy e scegli dall'elenco. Se il fuso orario è giusto ma l'orologio stesso è sfasato, _Update > Time_ riavvia per te la sincronizzazione dell'ora.

### Come faccio a cambiare i miei DNS, condividere il mio Wi-Fi o controllare la velocità della mia connessione?

Si trovano tutti in [rete](35-networking.md).

### Come faccio a controllare quanto è veloce il mio disco?

_Trigger > Speed Test > Disk Speed Test_ misura la velocità di lettura e scrittura in tempo reale sul tuo disco, oppure `omarchy disk speedtest` dal terminale.

### Come faccio ad aggiungere una stampante?

La stampa è configurata e funzionante fin da subito, e aggiungi ogni stampante tu stesso da _Print Settings_ nel launcher delle app (`Super + Space`).

Scegli _Add_ e dagli un momento per cercare: una stampante collegata via USB e la maggior parte delle stampanti di rete vengono trovate per te. Se la tua non è nell'elenco, scegli _Network Printer > Internet Printing Protocol (ipp)_ e inserisci il suo indirizzo — il display stesso della stampante o la sua pagina web ti diranno qual è, di solito qualcosa come `192.168.1.50` con una coda di `ipp/print`. _Forward_ offre poi un driver, dove una stampante moderna funziona al meglio con il profilo driverless _IPP Everywhere_ e una più vecchia vuole il driver proprio del modello.

Fai clic con il pulsante destro su una stampante e scegli _Set as Default_ per scegliere quale le tue app devono raggiungere per prima, e _Properties_ per impostare formato carta, fronte-retro e qualità.

La scoperta automatica, in cui le stampanti sulla rete compaiono senza essere aggiunte, è temporaneamente disattivata mentre viene rielaborata, ed è per questo che il primo passaggio qui sopra spetta a te invece di essere automatico. La stampa su un file PDF funziona anche senza alcuna stampante.

### Come faccio a cambiare dove vengono salvati gli screenshot o le registrazioni dello schermo?

Gli screenshot salvati vanno in `~/Pictures/Screenshots` per impostazione predefinita. Per usare un'altra directory, aggiungi questo a un file in `~/.config/uwsm/env.d/` (come `~/.config/uwsm/env.d/capture`):

```
export OMASNAP_SCREENSHOT_DIR="$HOME/Pictures/Captures"
```

Puoi fare lo stesso per le registrazioni dello schermo usando `OMARCHY_SCREENRECORD_DIR`.

Omasnap crea automaticamente la sua directory per gli screenshot. Crea tu stesso la directory per le registrazioni dello schermo, poi riavvia Omarchy perché una qualsiasi delle due modifiche all'ambiente abbia effetto.

### Come faccio a far funzionare gli altoparlanti + la webcam sul mio Apple Studio Display?

Si penserebbe che debba funzionare tutto semplicemente collegando l'USB C, ma purtroppo non è così. La soluzione che ho trovato per farlo funzionare in modo affidabile è usare [il cavo WJESOG DisplayPort + USB-A => USB-C](https://www.amazon.com/WJESOG-DisplayPort-Adapter-Converter-Thunderbolt/dp/B0BNX7MS6N/). Poi altoparlanti e webcam funzionano che è una meraviglia.

Ricorda che in Omarchy hai il controllo integrato della luminosità per gli Apple Display (sia Studio che XDR) usando i normali tasti della luminosità sulla tastiera.

### Come faccio a liberarmi di tutto il software extra?

Se non vuoi programmi come Obsidian o LibreOffice o qualsiasi altra cosa preinstallata, puoi rimuoverla molto facilmente.

Avvia _Remove > Package_ per vedere ogni pacchetto installato. Poi puoi selezionare con tab qualsiasi pacchetto che vuoi rimuovere e avviare la rimozione di tutto ciò che hai selezionato con return.

E puoi usare _Remove > Web App_ dal menu di Omarchy per rimuovere qualsiasi web app preinstallata che non vuoi.

Oppure avvia _Remove > Preinstalls_ per eliminare in un colpo solo tutti gli extra preinstallati — web app, TUIs e applicazioni opzionali. Le scorciatoie che le avviavano spariscono con loro, così ti resta una lavagna pulita di associazioni da riempire con le tue in `~/.config/hypr/bindings.lua`.

---

Per errori e cose rotte, vedi [la sezione Risoluzione dei problemi](45-troubleshooting.md).
