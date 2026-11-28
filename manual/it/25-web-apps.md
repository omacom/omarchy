# App web

Puoi aggiungere le tue app web usando _Installa > App Web_ nel menu Omarchy (`Super + Space`). Ti chiederà il nome dell'app, l'URL dell'app e l'URL dell'icona, se non riesce a recuperarla tramite favicon. Puoi trovare ottime icone PNG per molte app web popolari su [Dashboard Icons](https://dashboardicons.com).

Saranno poi accessibili tramite il launcher delle applicazioni (`Super + Space`) e useranno la splendida finestra dell'app web senza cornice.

Se desideri rimuovere un'app web, vai semplicemente su _Rimuovi > App Web_ nel menu Omarchy.

Conviene accedere a tutti i tuoi account usando un normale browser prima di usare le scorciatoie delle app web. Il sottile frame wrapper non funziona bene con 1password, quindi è semplicemente più facile aver già effettuato l'accesso diretto.

Tutte le scorciatoie da tastiera per queste app web possono essere modificate in `~/.config/hypr/bindings.lua`.

Quando sei in un'app web, puoi copiare l'URL attuale negli appunti usando `Shift + Alt + L`.

Per impostazione predefinita, Omarchy include già una selezione di app predefinite:

## HEY

[HEY](https://www.hey.com/) è un servizio di email e calendario che rappresenta un'ottima alternativa per chi è stanco di Gmail, Outlook o Apple Mail. È realizzato da [37signals](https://37signals.com/), dove è nato Omarchy.

Puoi avviare HEY Email usando `Super + Shift + E`, passare direttamente alla composizione di una nuova email usando `Super + Shift + Alt + E` e avviare HEY Calendar usando `Super + Shift + C`.

## Basecamp

[Basecamp](https://basecamp.com/) è un servizio di gestione progetti che aiuta i piccoli team a muoversi più velocemente e a fare più progressi. Invece di mettere insieme un miscuglio di Trello, Slack, Asana, Notion o chissà cos'altro, con Basecamp puoi avere tutto in un unico posto. È realizzato da [37signals](https://37signals.com/), dove è nato Omarchy.

Puoi avviare Basecamp usando il launcher delle applicazioni (`Super + Space`)

## ChatGPT

[ChatGPT](https://chatgpt.com) è il chatbot AI più popolare al mondo.

Puoi avviare ChatGPT usando `Super + Shift + A`.

## Grok

[Grok](https://grok.com) è il chatbot di xAI.

Puoi avviare Grok usando `Super + Shift + Alt + A`.

## WhatsApp

[WhatsApp](https://www.whatsapp.com/) è uno dei servizi di messaggistica più popolari al mondo, e la versione web è un'ottima opzione per Linux.

Puoi avviare WhatsApp usando `Super + Shift + Alt + G`. Si apre con l'estensione WhatsApp Slim di Omarchy, che lo fa seguire il tuo tema e comprime l'elenco delle chat quando la finestra è stretta.

## App Google

Google Messages, Google Photos, Google Maps e Google Contacts sono inclusi anche come app web.

Puoi avviare Google Messages usando `Super + Shift + Ctrl + G`, Google Photos usando `Super + Shift + P` e Google Maps usando `Super + Shift + S`. Google Contacts è disponibile tramite il launcher delle applicazioni (`Super + Space`).

## X

X è dove scoppiano le notizie.

Puoi avviare X usando `Super + Shift + X` e passare direttamente a scrivere un nuovo post con `Super + Shift + Alt + X`.

## YouTube

[YouTube](https://youtube.com/) è la piattaforma video più popolare al mondo.

Puoi avviare YouTube usando `Super + Shift + Y`.

## Netflix

[Netflix](https://www.netflix.com/) è incluso come app web nelle nuove installazioni.

Avvii Netflix usando il launcher delle applicazioni (`Super + Space`).

## Zoom

[Zoom](https://zoom.us/) è il sistema di videochat più popolare usato negli Stati Uniti. Ottime connessioni in tutto il mondo. E le riunioni da 40 minuti possono essere tenute senza un account a pagamento. Omarchy racchiude il client web di Zoom, e i link alle riunioni Zoom si apriranno direttamente al suo interno.

Avvii Zoom usando il launcher delle applicazioni (`Super + Space`).

## Discord

[Discord](https://discord.com/) è dove si ritrovano la maggior parte delle comunità di gaming e open source, inclusa [quella di Omarchy](https://discord.gg/tXFUdasqhY).

Avvii Discord usando il launcher delle applicazioni (`Super + Space`).

## App Microsoft

Seleziona _Installa > Servizio > Microsoft_ per aggiungere Outlook, Word, Excel, PowerPoint, Teams e OneDrive come app web. Ogni app ha il proprio launcher e si apre direttamente, usando gli URL commerciali di Microsoft 365 e il tuo profilo browser esistente. Si aprono nelle stesse finestre delle app browser delle altre app web di Omarchy; non installano il client separato Teams for Linux.

Rimuovi il pacchetto con _Rimuovi > Servizi > Microsoft_, oppure rimuovi le singole app con _Rimuovi > App Web_. Puoi anche installare solo le app che vuoi tramite _Installa > App Web_.

Per un cloud governativo o sovrano, modifica l'URL nella riga `Exec=` nel launcher pertinente sotto `~/.local/share/applications/`, ad esempio `Microsoft Teams.desktop`, usando l'URL fornito dalla tua organizzazione. Scrivi qualsiasi `%` letterale in quella riga come `%%`. Le modifiche hanno effetto al prossimo avvio. Eseguire di nuovo il programma di installazione del pacchetto sostituisce i suoi launcher con gli URL predefiniti.

Per mantenere separati gli accessi di lavoro, aggiungi una directory dei dati del browser alla riga `Exec=` di ciascun launcher:

```ini
Exec=omarchy-launch-webapp "https://teams.cloud.microsoft/" --user-data-dir=/absolute/path/to/work-browser-profile
```

Sostituisci la directory di esempio con un percorso assoluto a tua scelta e usa lo stesso percorso per tutti e sei i launcher per condividere tra loro gli accessi di lavoro. Le app web usano il browser supportato selezionato da Omarchy, ripiegando su Chrome quando il browser predefinito non è supportato.
