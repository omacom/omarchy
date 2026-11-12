# La barra superiore

La striscia lungo la parte superiore dello schermo è la barra di Omarchy. Non è una barra di stato aggiunta alla bell'e meglio, ma parte della shell di Omarchy, l'unico processo Quickshell a esecuzione prolungata che disegna anche il menu, le notifiche, i popup OSD e la schermata di blocco. Ecco perché si abbina perfettamente a tutto il resto e perché un pannello si apre all'istante invece di avviare una nuova app.

È anche l'unico pezzo del desktop sempre visibile sullo schermo, quindi vale la pena sapere cosa fanno tutti quei piccoli glifi.

## Cosa contiene per impostazione predefinita

La barra ha tre sezioni. A sinistra si trovano il logo di Omarchy (il lanciatore del menu) e gli indicatori dei workspace. Al centro trovi gli indicatori di stato, l'orologio, Elsewhen (un orologio mondiale), il meteo e un badge di aggiornamento di Omarchy. A destra: il tray di sistema, il layout di tastiera (quando ne è configurato più di uno), gli agenti, Bluetooth, rete, audio, schermo e alimentazione.

Alcuni di questi compaiono solo quando hanno qualcosa da dire. Il layout di tastiera compare solo se hai configurato più di un layout. Il badge di aggiornamento compare solo quando c'è un aggiornamento di Omarchy in attesa. E l'icona degli agenti compare la prima volta che Omarchy trova un utilizzo di AI coding sulla macchina (vedi [AI](17-ai.md)).

## Clic in giro

Quasi ogni widget fa qualcosa con il clic sinistro, destro e centrale, e diversi rispondono allo scorrimento. Questa è la parte che sfugge alla gente: i pulsanti destro e centrale sono dove si nasconde buona parte delle cose migliori.

| Widget | Sinistro | Destro | Centrale / scorrimento |
| --- | --- | --- | --- |
| Menu | Menu di Omarchy | Nuovo terminale | — |
| Workspace | Porta in primo piano quel workspace su questo monitor | — | Scorrimento: workspace successivo/precedente |
| Orologio | Popup del calendario | Passa da un formato dell'etichetta all'altro | Centrale: selettore del fuso orario |
| Meteo | Popup delle previsioni | Meteo completo come notifica | Centrale: aggiorna |
| Audio | Pannello audio | Silenzia | Centrale: pannello · scorrimento: volume |
| Microfono | Silenzia il microfono | — | Centrale: pannello audio · scorrimento: volume in ingresso |
| Rete | Pannello di rete | — | — |
| Bluetooth | Pannello Bluetooth | Attiva/disattiva la radio | — |
| Schermo | Pannello schermo | — | Scorrimento: luminosità |
| Alimentazione | Pannello alimentazione | Mostra/nascondi la percentuale della batteria | — |
| Media | Riproduci/pausa | Popup della copertina | Centrale: successivo · scorrimento: precedente/successivo |
| Agenti | Pannello Agenti | Avvia il tuo agent | Centrale: abbonamento successivo |
| Tray | Passa il mouse sopra per mostrare il cassetto | Tasto destro sullo chevron per gestire | — |
| Aggiornamento Omarchy | Esegui l'aggiornamento | — | — |

Non tutto in quella tabella è sulla tua barra fin dall'inizio. Il widget media (MPRIS in riproduzione, con brano e artista a scorrimento) e il widget microfono sono entrambi integrati ma disattivati per impostazione predefinita: aggiungili se li vuoi, come descritto di seguito.

## I pannelli

Facendo clic su un'icona della barra si apre un pannello, che è un vero popup con cursori, elenchi e navigazione da tastiera invece di un tooltip. Ognuno ha anche una scorciatoia, così non devi mai mirare a un glifo da 16 pixel:

| Scorciatoia | Pannello |
| --- | --- |
| `Super + Ctrl + A` | Audio |
| `Super + Ctrl + N` | Rete |
| `Super + Ctrl + B` | Bluetooth |
| `Super + Ctrl + D` | Schermo |
| `Super + Ctrl + P` | Alimentazione |
| `Super + Ctrl + Alt + D` | Calendario |
| `Super + Ctrl + Alt + E` | Orologio mondiale |
| `Super + Ctrl + 1-9` | Attiva/disattiva l'ennesimo pannello nella sezione destra |

I pannelli non sono semplici display di sola lettura. Sono il punto in cui fai davvero le cose:

- **Audio** ha un cursore per il volume principale, un selettore del dispositivo di uscita e un mixer per app, così puoi abbassare quella singola scheda del browser senza toccare tutto il resto.
- **Rete** cerca reti Wi-Fi, mostra l'intensità del segnale, si connette e ti permette di scegliere un provider DNS.
- **Bluetooth** elenca i tuoi dispositivi con connessione/disconnessione e livelli della batteria.
- **Alimentazione** mostra le statistiche della batteria, cambia i profili di alimentazione (ricorda una scelta separata per batteria e AC) e stampa alcune informazioni di sistema.
- **Schermo** include un cursore per la luminosità, la dimensione del testo, preset per il ridimensionamento dei monitor e, quando hai più di uno schermo, controlli per singolo monitor. Vedi [monitor](33-monitors.md) per la storia più approfondita.
- **Orologio** apre una griglia mensile con numeri di settimana ISO e avanzamento tra i mesi.
- **Orologio mondiale** mantiene una riga per città, con il suo meteo e come sta andando la sua giornata. La ricerca trova le cittadine oltre ai fusi orari, quindi Fort Lauderdale è Fort Lauderdale e non New York. Se la riga in alto indica la città sbagliata, fai clic su di essa e di' dove sei; scegli un posto in un altro fuso orario e anche l'orologio di sistema si sposta lì, il che è comodo quando viaggi. Passa il mouse sopra una città e fai clic sul pulsante con la persona per dire chi ci abita: nomi semplici, oppure handle GitHub con `@` per portare con sé anche i loro volti.

Ogni pannello accetta anche la tastiera oltre al mouse: le frecce si spostano, Return attiva, Tab passa al pannello vicino ed Escape chiude.

`Super + Ctrl + 1-9` conta i pannelli da sinistra a destra nella sezione destra, saltando il tray perché non ha un pannello suo. Quindi il numero corrisponde all'icona che indicheresti.

### Tailscale e Dropbox

Altri due widget compaiono sulla barra solo dopo che hai installato il servizio corrispondente da **Installa → Servizio**, ed entrambi vale la pena conoscerli perché fanno più che segnalare uno stato.

Il pannello **Tailscale** connette e disconnette la tailnet, passa da un account all'altro e sceglie un nodo di uscita (in quell'elenco compaiono sia le tue macchine sia le regioni Mullvad). Sfoglia anche le tue macchine e, con una selezionata, `s` le invia file tramite Taildrop, che è il modo più veloce per spostare un file sul tuo telefono o su un altro laptop. `c` copia l'IP della macchina, `n` il suo nome e `d` il suo nome DNS completo. Su ogni riga di macchina c'è anche un pulsante di invio, se preferisci fare clic. La stessa cosa dal terminale è `omarchy tailscale send <machine> [file...]`.

Il pannello **Dropbox** gestisce l'accesso, mostra quanto spazio di archiviazione hai usato ed elenca i file sincronizzati di recente.

Rimuovere uno dei due servizi toglie di nuovo il suo widget dalla barra.

## Indicatori

Il piccolo gruppo al centro è il widget degli indicatori. Sono glifi di stato per le modalità che hai attivato: non disturbare, luce notturna, un [promemoria](09-reminders.md) in coda, una registrazione dello schermo attiva, resta sveglio e [dettatura](11-text-extraction-dictation.md). Si illuminano quando la modalità è attiva e altrimenti restano in disparte: passa il mouse proprio accanto a loro, dove si troverebbero quelli inattivi, per dare un'occhiata a questi ultimi. Facendo clic su un indicatore si attiva o disattiva quella modalità. Ce n'è uno in più di solo stato: una sessione remota si illumina di rosso mentre qualcuno è collegato a questa macchina tramite gliff.

Se preferisci che siano sempre visibili, imposta `alwaysShow` su `true` sul widget. E se ti interessano solo alcuni di loro, elenca quelli che vuoi in `items`: `["Dnd", "Reminder", "NightLight"]`. Puoi avere più di un widget indicatori, così sezioni diverse possono mostrare sottoinsiemi diversi.

## Riorganizzare la barra

La barra si configura da sola. Non devi aprire un file di configurazione per spostare le cose.

Afferra un tratto vuoto della barra intorno al centro e trascinalo verso un altro bordo dello schermo, e la barra si sposta lì: sinistra, destra, alto o basso funzionano tutti, e ogni widget si adatta (le barre verticali ripiegano su forme compatte con sole icone). Un clic prolungato avvia lo stesso trascinamento. Fai doppio clic sinistro su quello stesso spazio vuoto per far passare in ciclo lo sfondo della barra da trasparente a vitreo a opaco. E trascina qualsiasi widget per riordinarlo o lanciarlo in un'altra sezione; gli altri widget si allontanano scorrendo per fare spazio nel punto in cui atterrerà.

Il centro della barra è un riquadro: tutto ciò che contiene resta centrato come un unico gruppo, e i widget su entrambi i lati si agganciano ai suoi bordi. Mentre trascini un widget, il riquadro si mostra come un contorno, o come una linea attraverso la barra quando è vuoto, e puoi rilasciare dentro di esso o accanto ad esso. Quando un rilascio atterrerebbe nel riquadro, il riquadro si allarga per accogliere il widget.

Un widget che vuoi a portata di mano ma non sempre in vista può andare nel cassetto del tray: trascinalo sul tray e il cassetto si apre per accoglierlo. Sta lì dopo le icone delle app, compare ogni volta che compare il cassetto e mantiene il suo cassetto aperto mentre il suo pannello è visibile. Trascinalo di nuovo fuori sulla barra per rimetterlo al suo posto.

Se preferisci scegliere da un menu, **Aspetto → Barra dei menu** ha la posizione, e **Sfondo della barra** sceglie come viene disegnata la barra: **Barra opaca**, **Barra vitrea** (trasparente, con ciò che sta dietro sfocato) o **Barra trasparente**.

Le stesse cose hanno comandi, che è ciò che vuoi per una configurazione con [dotfiles](31-dotfiles.md):

```bash
omarchy bar position bottom
omarchy bar background glassy  # opaque, glassy, none, or cycle
omarchy bar move omarchy.weather --section centerBegin --index 0
omarchy bar move omarchy.bluetooth --section tray  # into the tray's drawer
omarchy bar set omarchy.clock format "HH:mm"
omarchy bar defaults          # back to the shipped layout
```

Per aggiungere o rimuovere completamente un widget, usa i comandi dei plugin. `omarchy plugin list` stampa ogni widget che la shell conosce con il suo id, e poi:

```bash
omarchy plugin enable omarchy.media --section centerEnd
omarchy plugin disable omarchy.weather
```

## Nascondere la barra

`Super + Shift + Space` nasconde la barra e la mostra di nuovo senza uccidere la shell: pannelli e scorciatoie continuano a funzionare, riottieni solo i pixel. Si trova anche nel menu sotto **Aspetto → Barra dei menu → Nascondi barra**.

## Il file di configurazione

Tutto viene memorizzato in `~/.config/omarchy/shell.json`, sotto la chiave `bar`. Ecco una versione ridotta:

```json
{
  "version": 1,
  "bar": {
    "position": "top",
    "background": "opaque",
    "layout": {
      "left": [{ "id": "omarchy.menu" }, { "id": "omarchy.workspaces" }],
      "centerBegin": [{ "id": "omarchy.indicators" }],
      "center": [{ "id": "omarchy.clock", "format": "HH:mm" }],
      "centerEnd": [{ "id": "omarchy.weather" }],
      "right": [{ "id": "omarchy.audio" }, { "id": "omarchy.power" }]
    }
  }
}
```

Ogni widget è una voce in uno dei cinque array di layout, e le sue impostazioni si trovano in linea su quella voce: non c'è un file di impostazioni separato né un sotto-oggetto `config`. `format`, `formatAlt` (ciò a cui passa il clic destro) e `verticalFormat` dell'orologio vivono tutti proprio lì su `{ "id": "omarchy.clock" }`.

`center` è il riquadro al centro della barra: tutto ciò che contiene è centrato sullo schermo come un unico gruppo. `centerBegin` e `centerEnd` si agganciano ai due lati del riquadro, ed è così che l'orologio resta perfettamente al centro anche mentre il meteo e il badge di aggiornamento vanno e vengono. Metti più di un widget in `center` e verranno centrati insieme; lascialo vuoto e `centerBegin` e `centerEnd` si incontrano al centro della barra.

Una regola che vale la pena interiorizzare: **quando hai un tuo `shell.json`, è quello canonico**. Finché non personalizzi nulla, la shell legge il file predefinito di Omarchy. Nel momento in cui trascini un widget, esegui `omarchy bar` o modifichi tu stesso il file, diventa tuo: non c'è alcuna fusione profonda, quindi i nuovi widget predefiniti nelle future versioni di Omarchy non compariranno automaticamente sulla tua barra. `omarchy bar defaults` rimette il layout fornito di serie ogni volta che vuoi ripartire da zero.

Lo stesso file conserva anche i tuoi tempi di inattività al livello superiore, fuori dalla chiave `bar`: `idle.screensaver` e `idle.lock`, entrambi in secondi da quando sei diventato inattivo. Quindi lo screensaver predefinito parte dopo 150 secondi e il blocco dopo 300.
