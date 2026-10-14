# La barra superiore

La striscia lungo la parte superiore dello schermo è la barra di Omarchy. Non è una barra di stato aggiunta in un secondo momento, ma parte della shell di Omarchy, l'unico processo Quickshell a lunga esecuzione che disegna anche il menu, le notifiche, i popup OSD e la schermata di blocco. Ecco perché si tematizza perfettamente con tutto il resto e perché un pannello si apre istantaneamente invece di avviare una nuova app.

È anche l'unico pezzo del desktop sempre sullo schermo, quindi vale la pena sapere cosa fanno tutti quei piccoli glifi.

## Cosa c'è per impostazione predefinita

La barra ha tre sezioni. A sinistra sta il logo Omarchy (l'avviatore del menu) e gli indicatori dei workspace. Al centro hai gli indicatori di stato, l'orologio, Elsewhen (un orologio mondiale), il meteo e un distintivo di aggiornamento Omarchy. A destra: il layout tastiera (quando ne è configurato più di uno), l'area di notifica, gli agenti, il bluetooth, la rete, l'audio, il display e l'alimentazione.

Alcuni di questi compaiono solo quando hanno qualcosa da dire. Il layout tastiera appare solo se ne hai configurato più di uno. Il distintivo di aggiornamento appare solo quando c'è un aggiornamento Omarchy in attesa. E l'icona degli agenti appare la prima volta che Omarchy trova un utilizzo di codifica AI sulla macchina (vedi [AI](17-ai.md)).

## Cliccare in giro

Quasi ogni widget fa qualcosa con clic sinistro, destro e centrale, e diversi rispondono allo scorrimento. Questa è la parte che la gente si perde — i pulsanti destro e centrale sono dove si nasconde gran parte delle cose buone.

| Widget | Sinistro | Destro | Centrale / scorrimento |
| --- | --- | --- | --- |
| Menu | Menu Omarchy | Nuovo terminale | — |
| Workspace | Focalizza quel workspace | — | Scorrimento: workspace successivo/precedente |
| Orologio | Popup calendario | Cambia formato etichetta a ciclo | Centrale: selettore fuso orario |
| Meteo | Popup previsioni | Meteo completo come notifica | Centrale: aggiorna |
| Audio | Pannello audio | Silenzia | Centrale: pannello · scorrimento: volume |
| Microfono | Silenzia il microfono | — | Centrale: pannello audio · scorrimento: volume in ingresso |
| Rete | Pannello rete | — | — |
| Bluetooth | Pannello Bluetooth | Attiva/disattiva la radio | — |
| Display | Pannello display | — | Scorrimento: luminosità |
| Alimentazione | Pannello alimentazione | Attiva/disattiva percentuale batteria | — |
| Media | Riproduci/pausa | Popup copertina | Centrale: successivo · scorrimento: prec./succ. |
| Agenti | Pannello agenti | Avvia il tuo agente | Centrale: abbonamento successivo |
| Area di notifica | Passa sopra per mostrare il cassetto | Destro sulla freccia per gestirla | — |
| Aggiornamento Omarchy | Esegui l'aggiornamento | — | — |

Non tutto ciò che è in quella tabella è sulla barra di serie. Il widget media (MPRIS in riproduzione, con brano e artista a scorrimento) e il widget microfono sono entrambi integrati ma disattivati per impostazione predefinita — aggiungili se li vuoi, come descritto sotto.

## I pannelli

Cliccando un'icona della barra si apre un pannello, che è un vero popup con cursori, elenchi e navigazione da tastiera invece di un suggerimento. Ognuno ha anche una scorciatoia, così non devi mai mirare a un glifo di 16 pixel:

| Scorciatoia | Pannello |
| --- | --- |
| `Super + Ctrl + A` | Audio |
| `Super + Ctrl + W` | Rete |
| `Super + Ctrl + B` | Bluetooth |
| `Super + Ctrl + D` | Display |
| `Super + Ctrl + P` | Alimentazione |
| `Super + Ctrl + Alt + D` | Calendario |
| `Super + Ctrl + Alt + E` | Orologio mondiale |
| `Super + Ctrl + 1-9` | Attiva/disattiva l'ennesimo pannello nella sezione destra |

I pannelli non sono letture di sola visualizzazione. È lì che fai davvero la cosa:

- **Audio** ha un cursore volume principale, un selettore del dispositivo di uscita e un mixer per app, così puoi abbassare quella scheda del browser senza toccare tutto il resto.
- **Rete** cerca reti Wi-Fi, mostra l'intensità del segnale, si connette e ti permette di scegliere un provider DNS.
- **Bluetooth** elenca i tuoi dispositivi con connessione/disconnessione e livelli batteria.
- **Alimentazione** mostra le statistiche batteria, cambia i profili di alimentazione (ricorda una scelta separata per batteria e rete elettrica) e stampa alcune informazioni di sistema.
- **Display** contiene un cursore luminosità, dimensione testo, predefiniti di scalatura monitor e — quando hai più di uno schermo — controlli per monitor. Vedi [monitor](33-monitors.md) per la storia più approfondita.
- **Orologio** apre una griglia mensile con numeri di settimana ISO e scorrimento dei mesi.

Ogni pannello accetta la tastiera oltre al mouse: le frecce muovono, Return attiva, Tab passa al pannello vicino ed Escape chiude.

`Super + Ctrl + 1-9` conta i pannelli da sinistra a destra nella sezione destra, saltando l'area di notifica poiché non ha un pannello proprio. Quindi il numero corrisponde all'icona che indicheresti.

### Tailscale e Dropbox

Altri due widget compaiono sulla barra solo una volta installato il servizio corrispondente da **Installa → Servizio**, ed entrambi vale la pena conoscerli perché fanno più che riportare lo stato.

Il pannello **Tailscale** connette e disconnette la tailnet, cambia account e sceglie un nodo di uscita (le tue macchine e le regioni Mullvad compaiono entrambe in quell'elenco). Sfoglia anche le tue macchine — e con una selezionata, `s` le invia file tramite Taildrop, che è il modo più veloce per spostare un file sul telefono o su un altro portatile. `c` copia l'IP della macchina, `n` il suo nome e `d` il suo nome DNS completo. C'è anche un pulsante di invio su ogni riga macchina, se preferisci cliccare. La stessa cosa da terminale è `omarchy tailscale send <machine> [file...]`.

Il pannello **Dropbox** gestisce l'accesso, mostra quanto spazio hai usato ed elenca i file sincronizzati di recente.

Rimuovere uno dei due servizi toglie il suo widget dalla barra.

## Indicatori

Il piccolo gruppo al centro è il widget indicatori. Questi sono glifi di stato per le modalità che hai attivato: non disturbare, luce notturna, un [promemoria](09-reminders.md) in coda, una registrazione schermo attiva, resta attivo e [dettatura](11-text-extraction-dictation.md). Si illuminano quando la modalità è attiva e altrimenti restano fuori dai piedi — passa il mouse a sinistra dell'orologio (sopra di esso su una barra verticale) per sbirciare quelli inattivi. Cliccando un indicatore si attiva/disattiva quella modalità. Un altro è solo di stato: una sessione remota si illumina di rosso mentre qualcuno è connesso a questa macchina tramite gliff.

Se preferisci che siano sempre visibili, imposta `alwaysShow` a `true` sul widget. E se ti interessano solo alcuni di essi, elenca quelli che vuoi in `items`: `["Dnd", "Reminder", "NightLight"]`. Puoi avere più di un widget indicatori, così sezioni diverse possono mostrare sottoinsiemi diversi.

## Riorganizzare la barra

La barra si configura da sola. Non devi aprire un file di configurazione per spostare le cose.

Afferra una zona vuota della barra attorno al centro e trascinala verso un altro bordo dello schermo, e la barra si sposta lì — sinistra, destra, alto o basso funzionano tutti, e ogni widget si adatta (le barre verticali ripiegano su forme compatte solo icona). Un clic tenuto premuto avvia lo stesso trascinamento. Fai doppio clic sinistro su quello stesso spazio vuoto per cambiare a ciclo lo sfondo della barra da trasparente a vetro a opaco. E trascina qualsiasi widget per riordinarlo o buttarlo in un'altra sezione.

Un widget che vuoi tenere a portata di mano ma non sempre in vista può finire nel cassetto dell'area di notifica: trascinalo sull'area di notifica e il cassetto si apre per accoglierlo. Sta lì dopo le icone delle app, compare ogni volta che compare il cassetto e mantiene il suo cassetto aperto mentre il suo pannello è attivo. Trascinalo di nuovo sulla barra per rimetterlo a posto.

Se preferisci scegliere da un menu, **Azioni → Aspetto → Barra menu** ha la posizione, e **Sfondo barra** sceglie come viene disegnata la barra: **Barra opaca**, **Barra vetro** (trasparente, con ciò che sta dietro sfocato) o **Barra trasparente**.

Le stesse cose hanno comandi, che è ciò che vuoi per una configurazione [dotfiles](31-dotfiles.md):

```bash
omarchy bar position bottom
omarchy bar background glassy  # opaque, glassy, none, or cycle
omarchy bar move omarchy.clock --section center --index 0
omarchy bar move omarchy.bluetooth --section tray  # into the tray's drawer
omarchy bar set omarchy.clock format "HH:mm"
omarchy bar defaults          # back to the shipped layout
```

Per aggiungere o rimuovere del tutto un widget, usa i comandi plugin. `omarchy plugin list` stampa ogni widget che la shell conosce con il suo id, e poi:

```bash
omarchy plugin enable omarchy.media --section center
omarchy plugin disable omarchy.weather
```

## Nascondere la barra

`Super + Shift + Space` spegne e riaccende la barra senza uccidere la shell — pannelli e scorciatoie continuano a funzionare, riottieni solo i pixel. È anche nel menu sotto **Azioni → Aspetto → Barra menu → Nascondi barra**.

## Il file di configurazione

Tutto è memorizzato in `~/.config/omarchy/shell.json`, sotto la chiave `bar`. Ecco una versione ridotta:

```json
{
  "version": 1,
  "bar": {
    "position": "top",
    "background": "opaque",
    "centerAnchor": "omarchy.clock",
    "layout": {
      "left": [{ "id": "omarchy.menu" }, { "id": "omarchy.workspaces" }],
      "center": [{ "id": "omarchy.clock", "format": "HH:mm" }],
      "right": [{ "id": "omarchy.audio" }, { "id": "omarchy.power" }]
    }
  }
}
```

Ogni widget è una voce in uno dei tre array di layout, e le sue impostazioni stanno in linea su quella voce — non c'è un file di impostazioni separato né un sotto-oggetto `config`. Il `format` dell'orologio, `formatAlt` (ciò a cui il clic destro passa a ciclo) e `verticalFormat` vivono tutti proprio lì su `{ "id": "omarchy.clock" }`.

`centerAnchor` nomina l'unico widget centrale che viene fissato al centro esatto dello schermo, con gli altri ai suoi lati. È così che l'orologio resta morto al centro anche mentre il meteo e il distintivo di aggiornamento vanno e vengono. Impostalo a una stringa vuota e l'elenco centrale viene semplicemente centrato come gruppo.

Una regola che vale la pena interiorizzare: **una volta che hai il tuo `shell.json`, è canonico**. Finché non personalizzi nulla, la shell legge il file predefinito di Omarchy. Nell'istante in cui trascini un widget, esegui `omarchy bar` o modifichi tu stesso il file, è tuo — non c'è unione profonda, quindi i nuovi widget predefiniti nelle future versioni di Omarchy non appariranno automaticamente sulla tua barra. `omarchy bar defaults` rimette il layout fornito ogni volta che vuoi ripartire da zero.

Lo stesso file contiene anche le tempistiche di inattività al livello superiore, fuori dalla chiave `bar`: `idle.screensaver` e `idle.lock`, entrambi in secondi da quando sei diventato inattivo. Quindi il salvaschermo predefinito entra a 150 secondi e il blocco a 300.
