# App web

Puoi aggiungere le tue app web usando _Install > Web App_ nel menu di Omarchy (`Super + Space`). Ti chiederà il nome dell'app, l'URL dell'app e l'URL dell'icona, se non riesce a recuperarla tramite favicon. Puoi trovare ottime icone PNG per molte app web popolari su [Dashboard Icons](https://dashboardicons.com).

Saranno poi accessibili tramite il launcher delle applicazioni (`Super + Space`) e useranno la bellissima finestra senza cornice delle app web.

Se vuoi rimuovere un'app web, vai semplicemente su _Remove > Web App_ nel menu di Omarchy.

È meglio accedere a tutti i tuoi account usando un browser normale prima di usare le scorciatoie delle app web. La sottile cornice che fa da wrapper non funziona bene con 1password, quindi è semplicemente più facile aver già effettuato l'accesso direttamente prima.

Tutti i tasti di scelta rapida da tastiera per queste app web possono essere modificati in `~/.config/hypr/bindings.lua`.

Quando sei in un'app web, puoi copiare l'URL corrente negli appunti usando `Shift + Alt + L`.

Per impostazione predefinita, Omarchy include già un assortimento di app predefinite:

## HEY

[HEY](https://www.hey.com/) è un servizio di email e calendario che rappresenta un'ottima alternativa per chi è stanco di Gmail, Outlook o Apple Mail. È realizzato da [37signals](https://37signals.com/), dove è nato Omarchy.

Puoi avviare HEY Email usando `Super + Shift + E`, passare direttamente a comporre una nuova email usando `Super + Shift + Alt + E` e avviare HEY Calendar usando `Super + Shift + C`.

## Basecamp

[Basecamp](https://basecamp.com/) è un servizio di gestione dei progetti che aiuta i piccoli team a muoversi più velocemente e a fare più progressi. Invece di mettere insieme alla bell'e meglio un miscuglio di Trello, Slack, Asana, Notion o chissà cos'altro, puoi avere tutto in un unico posto con Basecamp. È realizzato da [37signals](https://37signals.com/), dove è nato Omarchy.

Puoi avviare Basecamp usando il launcher delle applicazioni (`Super + Space`)

## ChatGPT

[ChatGPT](https://chatgpt.com) è il chatbot AI più popolare al mondo.

Puoi avviare ChatGPT usando `Super + Shift + A`.

## Grok

[Grok](https://grok.com) è il chatbot di xAI.

Puoi avviare Grok usando `Super + Shift + Alt + A`.

## WhatsApp

[WhatsApp](https://www.whatsapp.com/) è uno dei servizi di messaggistica più popolari al mondo, e la versione web è un'ottima opzione per Linux.

Puoi avviare WhatsApp usando `Super + Shift + Alt + G`.

## App Google

Google Messages, Google Photos, Google Maps e Google Contacts sono inclusi anche come app web.

Puoi avviare Google Messages usando `Super + Shift + Ctrl + G`, Google Photos usando `Super + Shift + P` e Google Maps usando `Super + Shift + S`. Google Contacts è disponibile tramite il launcher delle applicazioni (`Super + Space`).

## X

X è dove le notizie esplodono per prime.

Puoi avviare X usando `Super + Shift + X` e passare direttamente a scrivere un nuovo post con `Super + Shift + Alt + X`.

## YouTube

[YouTube](https://youtube.com/) è la piattaforma video più popolare al mondo.

Puoi avviare YouTube usando `Super + Shift + Y`.

## Zoom

[Zoom](https://zoom.us/) è il sistema di videochat più popolare usato negli US. Ottime connessioni in tutto il mondo. E riunioni di 40 minuti possono essere tenute senza un account a pagamento. Omarchy racchiude il client web di Zoom, e i link delle riunioni Zoom si apriranno direttamente al suo interno.

Avvii Zoom usando il launcher delle applicazioni (`Super + Space`).

## Discord

[Discord](https://discord.com/) è dove si ritrovano la maggior parte delle comunità di gaming e open source, inclusa [quella di Omarchy](https://discord.gg/tXFUdasqhY).

Avvii Discord usando il launcher delle applicazioni (`Super + Space`).

## App Microsoft

Seleziona _Install > Service > Microsoft_ per aggiungere Outlook, Word, Excel, PowerPoint, Teams e OneDrive come app web. Ogni app ha il suo launcher e si apre direttamente, usando gli URL commerciali di Microsoft 365 e il tuo profilo browser esistente. Si aprono nelle stesse finestre app del browser delle altre app web di Omarchy; non installano il client separato Teams for Linux.

Rimuovi il pacchetto con _Remove > Service > Microsoft_, oppure rimuovi le singole app con _Remove > Web App_. Puoi anche installare solo le app che vuoi tramite _Install > Web App_.

Per un cloud governativo o sovrano, modifica l'URL sulla riga `Exec=` nel launcher pertinente sotto `~/.local/share/applications/`, come `Microsoft Teams.desktop`, usando l'URL fornito dalla tua organizzazione. Scrivi qualsiasi `%` letterale in quella riga come `%%`. Le modifiche si applicano al prossimo avvio. Eseguire di nuovo il programma di installazione del pacchetto sostituisce i suoi launcher con gli URL predefiniti.

Per mantenere separati gli accessi di lavoro, aggiungi una directory dei dati del browser alla riga `Exec=` di ciascun launcher:

```ini
Exec=omarchy-launch-webapp "https://teams.cloud.microsoft/" --user-data-dir=/absolute/path/to/work-browser-profile
```

Sostituisci la directory di esempio con un percorso assoluto a tua scelta e usa lo stesso percorso per tutti e sei i launcher per condividere tra loro gli accessi di lavoro. Le app web usano il browser supportato selezionato da Omarchy, ripiegando su Chrome quando il browser predefinito non è supportato.
