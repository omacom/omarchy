# Interfacce grafiche

## Files

Files (Nautilus) è il file manager grafico. `Super + Shift + F` lo apre, e `Super + Shift + Alt + F` lo apre nella directory in cui si trova il tuo terminale, il che ti fa risparmiare un sacco di clic. `Ctrl + L` ti permette di digitare un percorso, e premere `Space` su un file qualsiasi ti offre un'anteprima rapida senza aprire nulla.

Collega una chiavetta USB o una scheda SD e viene montata automaticamente, così appare semplicemente nella barra laterale. Per operazioni più complesse — formattare un'unità, controllare lo stato SMART, creare partizioni — avvia _Disks_ dal lanciatore di applicazioni (`Super + Space`).

Il doppio clic segue impostazioni predefinite sensate: immagini, video e musica si aprono in Omaview, i PDF in Document Viewer, Markdown in Omawrite e il testo semplice nell'editor scelto in _Setup > Default > Editor_.

## Disktree

Quando l'unità si riempie e non hai idea di cosa se la stia mangiando, avvia [Disktree](https://github.com/tobi/disktree) dal lanciatore di applicazioni (`Super + Space`). Mostra una treemap grafica della tua directory home. I blocchi più grandi occupano più spazio; naviga nelle directory con la tastiera o il mouse, contrassegna ciò che deve sparire e rivedi le tue selezioni prima di rimuovere qualsiasi cosa. Esegui `disktree --disk` per scansionare l'intero disco.

## Obsidian

[Obsidian](https://obsidian.md/) è un'applicazione gratuita e altamente estensibile per prendere appunti che usa semplici file Markdown per l'archiviazione.

Obsidian è gratuito per qualsiasi scopo, incluso l'uso personale, commerciale e non-profit.

Obsidian offre anche un [componente aggiuntivo commerciale per la sincronizzazione](https://obsidian.md/sync) con le app mobili su iOS e Android. (https://obsidian.md/pricing).

Avvii Obsidian con `Super + Shift + O`. Per usare la sincronizzazione del tema, devi selezionare il tema `Omarchy` nelle impostazioni.

## Omawrite

[Omawrite](https://github.com/omacom-io/omawrite) è l'app di scrittura Markdown semplicissima di Omarchy. Niente vault, niente plugin, solo tu e le parole.

Avvii Omawrite con `Super + Shift + W`.

## Pinta

[Pinta](https://www.pinta-project.com/) è uno strumento di base per modificare le immagini, ottimo per ritagliare, ridimensionare e altre manipolazioni di base. Non aspettarti però un'alternativa a Photoshop. Ma ha comunque la bacchetta magica e i livelli!

Avvii Pinta tramite il lanciatore di applicazioni (`Super + Space`).

## Aether

[Aether](https://github.com/bjarneo/aether) è un'applicazione per i temi che può estrarre i colori da un'immagine di sfondo e trasformarli in un tema completo e coerente. È il modo più semplice per [creare un tema tutto tuo](43-making-your-own-theme.md).

Avvii Aether tramite il lanciatore di applicazioni (`Super + Space`).

## LocalSend

[LocalSend](https://localsend.org/) ti permette di inviare file ad altri dispositivi sulla stessa rete che eseguono l'app, come AirDrop di Apple. È però multipiattaforma, quindi puoi inviare file da e verso Windows, macOS, Android, iOS e, naturalmente, Linux.

Puoi aprire il menu Share con `Super + Ctrl + S` o da _Trigger > Share_ nel menu di Omarchy. Ti offre quattro opzioni:

- **Clipboard** invia tutto ciò che hai copiato come file di testo. Ottimo per portare un link o un frammento di codice sul telefono senza doverti mandare un'e-mail.
- **File** apre un selettore di file in cui puoi selezionarne diversi alla volta.
- **Folder** invia un'intera directory.
- **Receive** apre LocalSend vero e proprio, così un altro dispositivo può inviarti qualcosa.

La stessa cosa funziona dal terminale con `omarchy share clipboard`, `omarchy share file [path]` e `omarchy share folder [path]`. Ometti il percorso e si apre il selettore.

Puoi anche inviare direttamente dal file manager: fai clic con il pulsante destro del mouse su qualsiasi selezione in Nautilus e scegli _Send via LocalSend_.

Il firewall di Omarchy è chiuso per impostazione predefinita, tranne che per la porta di LocalSend, quindi funziona immediatamente su un'installazione fresca. Vedi [sicurezza](48-security.md).

## LibreOffice

[LibreOffice](https://www.libreoffice.org/) è un pacchetto per l'ufficio completo, con elaboratore di testi, foglio di calcolo, presentazioni, applicazione per il disegno e altro ancora. È compatibile con i file di Microsoft Office, quindi è un ottimo modo per poter aprire quei documenti Word.

Avvii LibreOffice tramite il lanciatore di applicazioni (`Super + Space`).

## Hype

[Hype](https://github.com/omacom/hype) è l'app per presentazioni semplicissima di Omarchy. La tua presentazione è un singolo file Markdown con le sue immagini e i suoi video accanto: scrivi ogni diapositiva sotto un'anteprima in tempo reale, trascina le diapositive nell'ordine desiderato, poi presenta a schermo intero o esporta in PDF e PowerPoint. Riprende persino il tuo tema Omarchy.

Avvii Hype tramite il lanciatore di applicazioni (`Super + Space`). Premi `?` al suo interno per vedere ogni scorciatoia.

## Signed

[Signed](https://github.com/omacom/signed) è il modo semplicissimo di Omarchy per firmare i PDF e compilarli. Posiziona la tua firma salvata, del testo e la data di oggi in qualsiasi punto di una pagina, poi salva una copia firmata accanto all'originale. Vedi [Compilare i PDF](27-filling-out-pdfs.md) per scoprire come.

Avvii Signed tramite il lanciatore di applicazioni (`Super + Space`), oppure apri un PDF con esso dal file manager.

## Omacalc

[Omacalc](https://github.com/omacom-io/omacalc) è la calcolatrice semplicissima di Omarchy, che si apre in una finestra flottante.

Avvii Omacalc con `Super + Shift + Q` (o con il tasto della calcolatrice, se la tua tastiera ne ha uno).

## Signal

[Signal](https://signal.org/) è il pioniere della messaggistica con crittografia E2E ed è un'ottima opzione di comunicazione per chiunque preferisca non passare da uno dei grandi conglomerati tecnologici.

Avvii Signal con `Super + Shift + G`. Non fa parte dell'installazione di base, quindi la prima volta che premi quella combinazione, Omarchy ti proporrà di installarlo per te (si trova anche in _Install > Service_ nel menu di Omarchy).

## Omaview

[Omaview](https://github.com/omacom/omaview) è il visualizzatore di immagini e lettore multimediale semplicissimo di Omarchy: una sola finestra per foto, video e musica. Apri una foto e i tasti freccia scorrono il resto della sua cartella, `N` e `P` fanno lo stesso per qualsiasi cosa e `Ctrl + M` mostra l'intera cartella come griglia. Mostra anche foto HEIC, AVIF e JPEG XL e riprende da dove eri rimasto in qualsiasi contenuto lungo.

Premi `F` per lo schermo intero, `E` per modificare un'immagine in Omasnap o tagliare un video in Omacut, `Ctrl + P` per stampare un'immagine e `Delete` per spostare un file nel Cestino (`Ctrl + Z` lo riporta indietro). Premi `?` al suo interno per vedere ogni scorciatoia.

Avvii Omaview come _Media Viewer_ tramite il lanciatore di applicazioni (`Super + Space`), oppure fai semplicemente doppio clic su un'immagine, un video o un brano nel file manager.

## Omacut

[Omacut](https://github.com/omacom-io/omacut) è il semplicissimo strumento di Omarchy per tagliare i video. Quando ti serve solo tagliare l'inizio e la fine di una clip, batte l'avvio di un editor video completo.

Avvii Omacut tramite il lanciatore di applicazioni (`Super + Space`).

## Monologue

[Monologue](https://github.com/omacom/monologue) è il registratore webcam semplicissimo di Omarchy. Scegli videocamera e microfono una volta sola, poi premi `Space` per registrare, e di nuovo per mettere in pausa e riprendere la stessa ripresa. Registra sempre alla massima risoluzione della tua videocamera, con un indicatore del microfono in tempo reale, così puoi controllare i tuoi livelli prima di iniziare.

Interrompi la ripresa e si apre subito in un editor integrato. Fai doppio clic su una clip per dividerla, trascina le maniglie per tagliare ogni pezzo e rimuovi le parti che non vuoi. Poi salvala come MP4. La registrazione originale viene conservata finché non la scarti, così puoi sempre tornare indietro e tagliarla in modo diverso.

Avvii Monologue tramite il lanciatore di applicazioni (`Super + Space`).
