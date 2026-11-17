# FAQ

### Come faccio a passare da un layout di tastiera a un altro?

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

La barra mostrerà automaticamente il layout di tastiera corrente una volta configurati più layout (e puoi anche farci clic sopra per cambiarlo).

### Come faccio a cambiare il formato dell'orologio in 12 ore?

Fai clic con il pulsante destro del mouse sull'orologio nella barra per scorrere i formati comuni, inclusi quelli a 12 ore. Puoi anche impostare il formato direttamente:

```
omarchy bar set omarchy.clock format "dddd h:mm AP"
```

Verrà visualizzato Domenica 10:55 AM.

### Come faccio a cambiare il mio fuso orario?

Esegui _Aggiorna > Fuso orario_ nel menu di Omarchy e scegli dall'elenco. Se il fuso orario è giusto ma l'orologio stesso è sfasato, _Aggiorna > Ora_ riavvia per te la sincronizzazione dell'ora.

### Come faccio a cambiare il mio DNS, condividere il mio Wi-Fi o controllare la velocità della mia connessione?

Si trovano tutti in [rete](35-networking.md).

### Come faccio a controllare quanto è veloce il mio disco?

_Attiva > Test di velocità > Test di velocità del disco_ misura la velocità di lettura e scrittura in tempo reale sul tuo disco, oppure `omarchy disk speedtest` dal terminale.

### Come faccio ad aggiungere una stampante?

La stampa è configurata e attiva fin da subito, e aggiungi tu stesso ogni stampante da _Impostazioni di stampa_ nel launcher delle applicazioni (`Super + Space`).

Scegli _Aggiungi_ e dagli un momento per cercare: una stampante collegata tramite USB e la maggior parte delle stampanti di rete vengono trovate per te. Se la tua non è nell'elenco, scegli _Stampante di rete > Internet Printing Protocol (ipp)_ e inserisci il suo indirizzo — il display stesso della stampante o la sua pagina web ti diranno qual è, di solito qualcosa come `192.168.1.50` con una coda di `ipp/print`. _Avanti_ offre poi un driver, dove una stampante moderna funziona meglio con il profilo driverless _IPP Everywhere_ e una più vecchia vuole il driver specifico del modello.

Fai clic con il pulsante destro del mouse su una stampante e scegli _Imposta come predefinita_ per scegliere quale le tue app usano per prima, e _Proprietà_ per impostare formato carta, fronte-retro e qualità.

Il rilevamento automatico, in cui le stampanti sulla rete compaiono senza essere aggiunte, è temporaneamente disattivato mentre viene rielaborato, ed è per questo che il primo passaggio qui sopra spetta a te invece di essere automatico. Stampare su un file PDF funziona senza alcuna stampante.

### Come faccio a cambiare dove vengono salvati gli screenshot o le registrazioni dello schermo?

Gli screenshot salvati vanno in `~/Pictures/Screenshots` per impostazione predefinita. Per usare un'altra directory, aggiungi questo a un file in `~/.config/uwsm/env.d/` (come `~/.config/uwsm/env.d/capture`):

```
export OMASNAP_SCREENSHOT_DIR="$HOME/Pictures/Captures"
```

Puoi fare lo stesso per le registrazioni dello schermo usando `OMARCHY_SCREENRECORD_DIR`.

Omasnap crea automaticamente la sua directory per gli screenshot. Crea tu stesso la directory per le registrazioni dello schermo, poi riavvia Omarchy affinché entrambe le modifiche alle variabili d'ambiente abbiano effetto.

### Come faccio a far funzionare altoparlanti + webcam sul mio Apple Studio Display?

Si penserebbe che debba funzionare tutto semplicemente collegando l'USB C, ma purtroppo non è così. La soluzione che ho trovato per farlo funzionare in modo affidabile è usare [il cavo WJESOG DisplayPort + USB-A => USB-C](https://www.amazon.com/WJESOG-DisplayPort-Adapter-Converter-Thunderbolt/dp/B0BNX7MS6N/). Allora altoparlanti e webcam funzionano alla perfezione.

Ricorda che in Omarchy hai il controllo integrato della luminosità per i display Apple (sia Studio che XDR) usando i normali tasti della luminosità sulla tastiera.

### Come faccio a sbarazzarmi di tutto il software extra?

Se non vuoi programmi come Obsidian o LibreOffice o qualsiasi altro software preinstallato, puoi rimuoverlo molto facilmente.

Esegui _Rimuovi > Pacchetto_ per vedere ogni pacchetto installato. Poi puoi selezionare qualsiasi pacchetto che desideri rimuovere con tab, e iniziare a rimuovere tutto ciò che hai selezionato con return.

E puoi usare _Rimuovi > Web App_ dal menu di Omarchy per rimuovere qualsiasi web app preinstallata che non vuoi.

Oppure esegui _Rimuovi > Preinstallati_ per eliminare in un colpo solo tutti gli extra preinstallati — web app, TUI e applicazioni opzionali. I tasti di scelta rapida che le avviavano spariscono con esse, così ti resta una serie pulita di associazioni da riempire con le tue in `~/.config/hypr/bindings.lua`.

---

Per errori e parti non funzionanti, vedi [la sezione Risoluzione dei problemi](45-troubleshooting.md).
