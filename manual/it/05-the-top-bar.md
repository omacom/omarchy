<!-- upstream: omacom/omarchy@60663faf8764253646f1d6166e864b608d4a0fa1; sha256: 69456d1fbdc0f78fdaaf1197e67eb0bd0385edbe2b77136bcd181bb8954f3766 -->

# La barra superiore

La striscia lungo il bordo superiore dello schermo è la barra di Omarchy. Non è una barra di stato incollata a posteriori, ma fa parte della shell di Omarchy, l'unico processo Quickshell sempre in esecuzione che disegna anche il menu, le notifiche, i popup OSD e la schermata di blocco. Ecco perché si abbina perfettamente al tema di tutto il resto e perché un pannello si apre all'istante invece di avviare una nuova applicazione.

È anche l'unico elemento del desktop sempre sullo schermo, quindi vale la pena sapere cosa fanno tutti quei piccoli glifi.

## Cosa c'è di default

La barra ha tre sezioni. A sinistra c'è il logo di Omarchy (l'apri-menu) e gli indicatori dei workspace. Al centro trovi gli indicatori di stato, l'orologio, il layout della tastiera, il meteo e un badge di aggiornamento di Omarchy. A destra: il system tray, gli agenti, il Bluetooth, la rete, l'audio, il display e l'alimentazione.

Alcuni di questi compaiono solo quando hanno qualcosa da dire. Il layout della tastiera appare solo se hai configurato più di un layout. Il badge di aggiornamento appare solo quando c'è un aggiornamento di Omarchy in attesa. E l'icona degli agenti appare la prima volta che Omarchy rileva attività di coding con AI sulla macchina (vedi [AI](../17-ai.md)).

## Cliccare qua e là

Quasi ogni widget fa qualcosa con il clic sinistro, destro e centrale, e diversi rispondono allo scroll. Questa è la parte che sfugge: è nei tasti destro e centrale che si nasconde molta della roba buona.

| Widget | Sinistro | Destro | Centrale / scroll |
| --- | --- | --- | --- |
| Menu | Menu di Omarchy | Nuovo terminale | — |
| Workspace | Vai a quel workspace | — | — |
| Orologio | Popup del calendario | Cambia il formato dell'etichetta | Centrale: selettore del fuso orario |
| Meteo | Popup delle previsioni | Meteo completo come notifica | Centrale: aggiorna |
| Audio | Pannello audio | Muto | Centrale: pannello · scroll: volume |
| Microfono | Disattiva il microfono | — | Centrale: pannello audio · scroll: volume d'ingresso |
| Rete | Pannello rete | — | — |
| Bluetooth | Pannello Bluetooth | Attiva/disattiva la radio | — |
| Display | Pannello display | — | Scroll: luminosità |
| Alimentazione | Pannello alimentazione | Attiva/disattiva la percentuale della batteria | — |
| Media | Riproduci/pausa | Popup della copertina | Centrale: successivo · scroll: precedente/successivo |
| Agenti | Pannello agenti | Avvia il tuo agente | Centrale: abbonamento successivo |
| Tray | Passa sopra per aprire il cassetto | Destro sul chevron per gestire | — |
| Aggiornamento Omarchy | Esegui l'aggiornamento | — | — |

Non tutto ciò che è in questa tabella è sulla tua barra appena avviata. Il widget media (MPRIS in riproduzione, con brano e artista che scorrono) e il widget del microfono sono entrambi integrati ma disattivati di default: aggiungili se li vuoi, come descritto più sotto.

## I pannelli

Cliccando un'icona della barra si apre un pannello, cioè un vero popup con slider, elenchi e navigazione da tastiera, non un semplice tooltip. Ognuno ha anche una scorciatoia, così non devi mai mirare a un glifo di 16 pixel:

| Scorciatoia | Pannello |
| --- | --- |
| `Super + Ctrl + A` | Audio |
| `Super + Ctrl + W` | Rete |
| `Super + Ctrl + B` | Bluetooth |
| `Super + Ctrl + D` | Display |
| `Super + Ctrl + P` | Alimentazione |
| `Super + Ctrl + Alt + D` | Calendario |
| `Super + Ctrl + 1-9` | Attiva/disattiva l'n-esimo pannello nella sezione destra |

I pannelli non sono solo display. È lì che fai davvero le cose:

- **Audio** ha uno slider del volume principale, un selettore del dispositivo di uscita e un mixer per applicazione, così puoi abbassare quella singola scheda del browser senza toccare tutto il resto.
- **Rete** cerca reti Wi-Fi, mostra la potenza del segnale, si connette e ti lascia scegliere un provider DNS.
- **Bluetooth** elenca i tuoi dispositivi con connessione/disconnessione e livelli di batteria.
- **Alimentazione** mostra le statistiche della batteria, cambia profilo di alimentazione (ricorda una scelta separata per batteria e corrente) e mostra qualche informazione di sistema.
- **Display** offre uno slider della luminosità, la dimensione del testo, preset di scalatura del monitor e — quando hai più di uno schermo — controlli per singolo monitor. Per la storia completa vedi [monitor](../33-monitors.md).
- **Orologio** apre una griglia mensile con i numeri di settimana ISO e il passaggio da un mese all'altro.

Ogni pannello accetta la tastiera oltre al mouse: le frecce si muovono, Return attiva, Tab passa al pannello vicino ed Escape chiude.

`Super + Ctrl + 1-9` conta i pannelli da sinistra a destra nella sezione destra, saltando il tray perché non ha un pannello proprio. Così il numero corrisponde all'icona verso cui punteresti.

### Tailscale e Dropbox

Altri due widget compaiono sulla barra solo dopo aver installato il servizio corrispondente da **Install → Service**, e vale la pena conoscerli perché fanno più che riportare lo stato.

Il pannello **Tailscale** connette e disconnette la tailnet, cambia account e sceglie un exit node (le tue macchine e le regioni Mullvad compaiono entrambe nella lista). Naviga anche tra le tue macchine — e con una selezionata, `s` le invia file via Taildrop, il modo più veloce per spostare un file sul telefono o su un altro portatile. `c` copia l'IP della macchina, `n` il suo nome e `d` il suo nome DNS completo. C'è anche un pulsante di invio su ogni riga della macchina, se preferisci cliccare. La stessa cosa dal terminale è `omarchy tailscale send <machine> [file...]`.

Il pannello **Dropbox** gestisce l'accesso, mostra quanto spazio hai usato ed elenca i file sincronizzati di recente.

Rimuovere uno dei due servizi toglie il relativo widget dalla barra.

## Indicatori

Il piccolo gruppo al centro è il widget degli indicatori. Sono glifi di stato per le modalità che hai attivato: non disturbare, luce notturna, un [promemoria](../09-reminders.md) in coda, una registrazione dello schermo attiva, resta sveglio e [dettatura](../11-text-extraction-dictation.md). Si accendono quando la modalità è attiva e altrimenti restano fuori dai piedi — passa sopra il centro della barra per sbirciare quelli inattivi. Cliccando un indicatore si attiva o disattiva quella modalità.

Se preferisci che siano sempre visibili, imposta `alwaysShow` su `true` nel widget. E se te ne interessano solo alcuni, elenca quelli che vuoi in `items`: `["Dnd", "Reminder", "NightLight"]`. Puoi avere più di un widget indicatori, così sezioni diverse possono mostrarne sottoinsiemi diversi.

## Riordinare la barra

La barra si configura da sola. Non devi aprire un file di configurazione per spostare le cose.

Afferra una zona vuota della barra attorno al centro e trascinala verso un altro bordo dello schermo: la barra si sposta lì — sinistra, destra, alto o basso funzionano tutti, e ogni widget si adatta (le barre verticali ripiegano su forme compatte di sole icone). Un clic prolungato avvia lo stesso trascinamento. Fai doppio clic sinistro su quello stesso spazio vuoto per attivare o disattivare la trasparenza. E trascina un widget qualsiasi per riordinarlo o buttarlo in un'altra sezione.

Se preferisci scegliere da un menu, **Style → Menu Bar** ha sia la posizione sia la trasparenza.

Le stesse cose hanno dei comandi, ed è ciò che vuoi per una configurazione [dotfiles](../31-dotfiles.md):

```bash
omarchy bar position bottom
omarchy bar transparent toggle
omarchy bar move omarchy.clock --section center --index 0
omarchy bar set omarchy.clock format "HH:mm"
omarchy bar defaults          # back to the shipped layout
```

Per aggiungere o rimuovere del tutto un widget, usa i comandi dei plugin. `omarchy plugin list` mostra ogni widget che la shell conosce con il suo id, e poi:

```bash
omarchy plugin enable omarchy.media --section center
omarchy plugin disable omarchy.weather
```

## Nascondere la barra

`Super + Shift + Space` attiva e disattiva la barra senza terminare la shell — pannelli e scorciatoie continuano a funzionare, ti riprendi solo i pixel. È anche nel menu sotto **Trigger → Toggle → Menu Bar**.

## Il file di configurazione

Tutto è memorizzato in `~/.config/omarchy/shell.json`, sotto la chiave `bar`. Ecco una versione ridotta:

```json
{
  "version": 1,
  "bar": {
    "position": "top",
    "transparent": false,
    "centerAnchor": "omarchy.clock",
    "layout": {
      "left": [{ "id": "omarchy.menu" }, { "id": "omarchy.workspaces" }],
      "center": [{ "id": "omarchy.clock", "format": "HH:mm" }],
      "right": [{ "id": "omarchy.audio" }, { "id": "omarchy.power" }]
    }
  }
}
```

Ogni widget è una voce in uno dei tre array di layout, e le sue impostazioni stanno inline su quella voce — non c'è un file di impostazioni separato né un sotto-oggetto `config`. Il `format` dell'orologio, `formatAlt` (ciò su cui ruota il clic destro) e `verticalFormat` stanno proprio lì su `{ "id": "omarchy.clock" }`.

`centerAnchor` indica l'unico widget centrale che viene fissato al centro esatto dello schermo, con gli altri che gli fanno da fianchi. È così che l'orologio resta esattamente al centro anche quando meteo e badge di aggiornamento vanno e vengono. Impostalo su una stringa vuota e la lista centrale viene semplicemente centrata come gruppo.

Una regola da memorizzare: **una volta che hai il tuo `shell.json`, è quello canonico**. Finché non personalizzi nulla, la shell legge il file predefinito di Omarchy. Nel momento in cui trascini un widget, esegui `omarchy bar` o modifichi il file tu stesso, è tuo — non c'è un merge profondo, quindi i nuovi widget predefiniti delle future release di Omarchy non appariranno automaticamente sulla tua barra. `omarchy bar defaults` rimette il layout fornito ogni volta che vuoi ricominciare da zero.

Lo stesso file contiene anche i tuoi tempi di inattività al livello superiore, fuori dalla chiave `bar`: `idle.screensaver` e `idle.lock`, entrambi in secondi da quando sei andato inattivo. Quindi lo screensaver predefinito parte a 150 secondi e il blocco a 300.
