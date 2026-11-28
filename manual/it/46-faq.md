# FAQ

### Come passo da un layout di tastiera all'altro?

Modifica il tuo file `~/.config/hypr/input.lua` e aggiungi questo per passare da un layout all'altro con `Left Alt + Right Alt`:

```
hl.config({
  input = {
    -- Use multiple keyboard layouts and switch between them with Left Alt + Right Alt
    kb_layout = "us,fr",
    kb_options = "omarchy:shift_caps_compose,grp:alts_toggle",
  },
})
```

La barra mostrerà automaticamente il tuo layout di tastiera corrente una volta configurati più layout (e puoi anche farci clic sopra per cambiarlo).

### Come cambio il formato dell'orologio in 12 ore?

Fai clic con il pulsante destro sull'orologio nella barra per scorrere i formati più comuni, inclusi quelli a 12 ore. Puoi anche impostare il formato direttamente:

```
omarchy bar set omarchy.clock format "dddd h:mm AP"
```

Questo mostrerà Domenica 10:55 AM.

### Come cambio il mio fuso orario?

Avvia _Configurazione > Regione > Fuso orario_ nel menu Omarchy e scegli dall'elenco. Se il fuso orario è giusto ma l'orologio stesso è andato fuori sincrono, _Aggiorna > Ora_ riavvia per te la sincronizzazione dell'ora.

### Come cambio il mio DNS, condivido il mio Wi-Fi o controllo la velocità della mia connessione?

Si trovano tutte in [rete](35-networking.md).

### Come controllo quanto è veloce il mio disco?

_Attiva > Test di velocità > Test di velocità del disco_ misura in tempo reale la velocità di lettura e scrittura sul tuo disco, oppure `omarchy disk speedtest` dal terminale.

### Come aggiungo una stampante?

La stampa è configurata e attiva già da subito, e aggiungi tu stesso ogni stampante dalle _Impostazioni di stampa_ nell'avviatore di app (`Super + Alt + Space`).

Scegli _Aggiungi_ e dagli un momento per cercare: una stampante collegata via USB e la maggior parte delle stampanti di rete vengono trovate per te. Se la tua non è nell'elenco, scegli _Stampante di rete > Internet Printing Protocol (ipp)_ e inserisci il suo indirizzo — il display della stampante stessa o la sua pagina web ti diranno qual è, di solito qualcosa come `192.168.1.50` con una coda `ipp/print`. _Avanti_ ti offre poi un driver, in cui una stampante moderna funziona al meglio con il profilo senza driver _IPP Everywhere_ e una più vecchia vuole il driver del suo modello.

Fai clic con il pulsante destro su una stampante e scegli _Imposta come predefinita_ per scegliere quale le tue app devono raggiungere per prima, e _Proprietà_ per impostare formato carta, fronte-retro e qualità.

La scoperta automatica, in cui le stampanti sulla rete compaiono senza essere aggiunte, è temporaneamente disattivata mentre viene ripensata, ed è per questo che il primo passo sopra spetta a te invece di essere automatico. Stampare su un file PDF funziona anche senza alcuna stampante.

### Come cambio dove vengono salvati gli screenshot o le registrazioni dello schermo?

Gli screenshot salvati vanno in `~/Pictures/Screenshots` per impostazione predefinita. Per usare un'altra directory, aggiungi questo a un file sotto `~/.config/uwsm/env.d/` (come `~/.config/uwsm/env.d/capture`):

```
export OMASNAP_SCREENSHOT_DIR="$HOME/Pictures/Captures"
```

Puoi fare lo stesso per le registrazioni dello schermo usando `OMARCHY_SCREENRECORD_DIR`.

Omasnap crea automaticamente la sua directory per gli screenshot. Crea tu stesso la directory per le registrazioni dello schermo, poi riavvia Omarchy perché qualsiasi modifica all'ambiente abbia effetto.

### Come faccio a far funzionare altoparlanti + webcam sul mio Apple Studio Display?

Verrebbe da pensare che dovrebbe funzionare tutto semplicemente collegando l'USB C, ma purtroppo non è così. La soluzione che ho trovato per farlo funzionare in modo affidabile è usare [il cavo WJESOG DisplayPort + USB-A => USB-C](https://www.amazon.com/WJESOG-DisplayPort-Adapter-Converter-Thunderbolt/dp/B0BNX7MS6N/). Poi altoparlanti e webcam funzionano alla perfezione.

Ricorda che in Omarchy hai il controllo integrato della luminosità per gli Apple Display (sia Studio che XDR) usando i normali tasti di luminosità della tastiera.

### Come mi libero di tutto il software extra?

Se non vuoi programmi come Obsidian o LibreOffice o qualsiasi altra roba preinstallata, puoi rimuoverla molto facilmente.

Avvia _Rimuovi > Pacchetto_ per vedere ogni pacchetto installato. Poi puoi selezionare con tab qualsiasi pacchetto che vuoi rimuovere e iniziare a rimuovere tutto ciò che hai selezionato con return.

E puoi usare _Rimuovi > Web App_ dal menu Omarchy per rimuovere qualsiasi web app preinstallata che non vuoi.

Oppure avvia _Rimuovi > Preinstallati_ per spazzare via in un colpo solo tutti gli extra preinstallati — web app, TUI e applicazioni opzionali. Le scorciatoie che le lanciavano spariscono con loro, così ti resta una lavagna pulita di associazioni da riempire con le tue in `~/.config/hypr/bindings.lua`.

---

Per errori e parti rotte, vedi [la sezione Risoluzione dei problemi](45-troubleshooting.md).
