# Domande frequenti

### Come passo da un layout di tastiera all'altro?

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

La barra mostrerà automaticamente il tuo layout di tastiera attuale una volta configurati più layout (e puoi anche farci clic sopra per cambiarlo).

### Come cambio il formato dell'orologio a 12 ore?

Fai clic con il tasto destro sull'orologio nella barra per scorrere i formati comuni, inclusi quelli a 12 ore. Puoi anche impostare il formato direttamente:

```
omarchy bar set omarchy.clock format "dddd h:mm AP"
```

Questo mostrerà Sunday 10:55 AM.

### Come cambio il fuso orario?

Apri _Aggiorna > Fuso orario_ nel menu di Omarchy e scegli dalla lista. Se il fuso orario è giusto ma è l'orologio ad aver derivato, _Aggiorna > Ora_ riavvia la sincronizzazione dell'ora per te.

### Come cambio il DNS, condivido il Wi-Fi o controllo la velocità della connessione?

Tutto questo si trova in [rete](35-networking.md).

### Come controllo quanto è veloce il mio disco?

_Azioni > Test velocità > Test velocità disco_ misura la velocità di lettura e scrittura in tempo reale sul tuo disco, oppure `omarchy disk speedtest` dal terminale.

### Perché non riesco ad accedere al mio account Google in Chromium?

La semplice build open source di Chromium non include le credenziali OAuth che Google richiede per l'accesso all'account. Apri _Installa > Servizio > Account Chromium_ nel menu di Omarchy per aggiungerle, riavvia il browser e l'accesso andrà a buon fine.

### Come aggiungo una stampante?

La stampa è configurata e attiva di serie e aggiungi tu stesso ciascuna stampante da _Impostazioni di stampa_ nel launcher delle app (`Super + Space`).

Scegli _Aggiungi_ e dagli un momento per cercare: una stampante collegata via USB e la maggior parte delle stampanti di rete vengono trovate per te. Se la tua non è nella lista, scegli _Stampante di rete > Internet Printing Protocol (ipp)_ e inserisci il suo indirizzo: il display della stampante stessa o la sua pagina web ti diranno qual è, di solito qualcosa come `192.168.1.50` con una coda `ipp/print`. _Avanti_ offre poi un driver, dove una stampante moderna funziona meglio con il profilo senza driver _IPP Everywhere_ e una più vecchia vuole il driver proprio del modello.

Fai clic con il tasto destro su una stampante e scegli _Imposta come predefinita_ per decidere quale le tue app raggiungono per prima e _Proprietà_ per impostare formato carta, fronte-retro e qualità.

Il rilevamento automatico, in cui le stampanti in rete compaiono senza essere aggiunte, è temporaneamente disattivato mentre viene riprogettato, ed è per questo che il primo passaggio qui sopra spetta a te invece di essere automatico. Stampare su un file PDF funziona anche senza nessuna stampante.

### Come cambio dove vengono salvate le schermate o le registrazioni dello schermo?

Le schermate salvate vanno in `~/Pictures/Screenshots` per impostazione predefinita. Per usare un'altra directory, aggiungi questo a un file in `~/.config/uwsm/env.d/` (come `~/.config/uwsm/env.d/capture`):

```
export OMASNAP_SCREENSHOT_DIR="$HOME/Pictures/Captures"
```

Puoi fare lo stesso per le registrazioni dello schermo usando `OMARCHY_SCREENRECORD_DIR`.

Omasnap crea automaticamente la sua directory per le schermate. Crea tu stesso la directory per le registrazioni dello schermo, poi riavvia Omarchy affinché una delle due modifiche alle variabili d'ambiente abbia effetto.

### Come faccio funzionare altoparlanti e webcam sul mio Apple Studio Display?

Penseresti che dovrebbe funzionare tutto semplicemente collegando l'USB C, ma purtroppo non è così. La soluzione che ho trovato per farlo funzionare in modo affidabile è usare [il cavo WJESOG DisplayPort + USB-A => USB-C](https://www.amazon.com/WJESOG-DisplayPort-Adapter-Converter-Thunderbolt/dp/B0BNX7MS6N/). Allora altoparlanti e webcam funzionano a meraviglia.

Ricorda che in Omarchy hai il controllo integrato della luminosità per gli schermi Apple (sia Studio sia XDR) usando i normali tasti di luminosità della tastiera.

### Come mi libero di tutto il software extra?

Se non vuoi programmi come Obsidian o LibreOffice o qualsiasi altra cosa preinstallata, puoi rimuoverla molto facilmente.

Apri _Rimuovi > Pacchetto_ per vedere ogni pacchetto installato. Poi puoi selezionare con il tasto Tab qualsiasi pacchetto che vuoi rimuovere e iniziare a rimuovere tutto ciò che hai selezionato con Invio.

E puoi usare _Rimuovi > Web App_ dal menu di Omarchy per rimuovere qualsiasi web app preinstallata che non vuoi.

Oppure apri _Rimuovi > Preinstallati_ per spazzare via tutti gli extra preinstallati — web app, TUI e applicazioni opzionali — in un colpo solo. Le scorciatoie che le lanciavano spariscono con loro, così ti ritrovi con una serie pulita di associazioni da riempire con le tue in `~/.config/hypr/bindings.lua`.

---

Per errori e pezzi rotti, vedi [la sezione Risoluzione dei problemi](45-troubleshooting.md).
