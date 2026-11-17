# GUIs

## Files

Files (Nautilus) è il file manager grafico. `Super + Shift + F` lo apre, e `Super + Shift + Alt + F` lo apre nella directory in cui si trova il tuo terminale, il che ti risparmia un sacco di clic. `Ctrl + L` ti permette di digitare un percorso, e premendo `Space` su qualsiasi file ottieni un'anteprima rapida senza aprire nulla.

Collega una chiavetta USB o una scheda SD e viene montata automaticamente, quindi appare semplicemente nella barra laterale. Per qualcosa di più impegnativo — formattare un'unità, controllare lo stato SMART, creare partizioni — avvia _Disks_ dal launcher delle applicazioni (`Super + Space`).

Il doppio clic segue impostazioni predefinite sensate: immagini, video e musica si aprono in Omaview, i PDF in Document Viewer, il Markdown in Omawrite e il testo semplice nell'editor scelto in _Setup > Default > Editor_.

## Disktree

Quando l'unità si riempie e non hai idea di cosa la stia divorando, avvia [Disktree](https://github.com/tobi/disktree) dal launcher delle applicazioni (`Super + Space`). Mostra una treemap grafica della tua directory home. I blocchi più grandi occupano più spazio; naviga nelle directory con la tastiera o il mouse, marca ciò che deve sparire e rivedi le tue selezioni prima di rimuovere qualsiasi cosa. Esegui `disktree --disk` per scansionare l'intero disco.

## Obsidian

[Obsidian](https://obsidian.md/) è un'applicazione per prendere appunti gratuita e altamente estensibile che usa semplici file Markdown per l'archiviazione.

Obsidian è gratuita per tutti gli scopi, inclusi uso personale, commerciale e non-profit.

Obsidian offre anche un [componente aggiuntivo commerciale per la sincronizzazione](https://obsidian.md/sync) con le app mobili su iOS e Android. (https://obsidian.md/pricing).

Avvii Obsidian con `Super + Shift + O`. Per usare la sincronizzazione del tema, devi selezionare il tema `Omarchy` nelle impostazioni.

## Omawrite

[Omawrite](https://github.com/omacom-io/omawrite) è l'app di scrittura Markdown semplicissima di Omarchy. Niente vault, niente plugin, solo tu e le parole.

Avvii Omawrite con `Super + Shift + W`.

## Pinta

[Pinta](https://www.pinta-project.com/) è uno strumento di editing di immagini di base, ottimo per ritagliare, ridimensionare e altre manipolazioni di base. Non aspettarti però un'alternativa a Photoshop. Ma ha comunque la Bacchetta magica e i livelli!

Avvii Pinta tramite il launcher delle applicazioni (`Super + Space`).

## Aether

[Aether](https://github.com/bjarneo/aether) è un'applicazione per i temi che può estrarre i colori da un'immagine di sfondo e trasformarli in un tema completo e coerente. È il modo più semplice per [creare il tuo tema](43-making-your-own-theme.md).

Avvii Aether tramite il launcher delle applicazioni (`Super + Space`).

## LocalSend

[LocalSend](https://localsend.org/) ti permette di inviare file ad altri dispositivi sulla stessa rete che eseguono l'app, come AirDrop di Apple. È però multipiattaforma, quindi puoi inviare file da e verso Windows, macOS, Android, iOS e, naturalmente, Linux.

Puoi aprire il menu Share con `Super + Ctrl + S` o in _Trigger > Share_ nel menu di Omarchy. Ti offre quattro opzioni:

- **Clipboard** invia tutto ciò che hai copiato come file di testo. Ottimo per portare un link o uno snippet sul tuo telefono senza doverti inviare un'email.
- **File** apre un selettore di file in cui puoi selezionarne diversi alla volta.
- **Folder** invia un'intera directory.
- **Receive** apre LocalSend vero e proprio, così un altro dispositivo può inviarti qualcosa.

La stessa cosa funziona dal terminale con `omarchy share clipboard`, `omarchy share file [path]` e `omarchy share folder [path]`. Ometti il percorso e ottieni il selettore.

Puoi anche inviare direttamente dal file manager: fai clic con il pulsante destro del mouse su una selezione in Nautilus e scegli _Send via LocalSend_.

Il firewall di Omarchy è chiuso per impostazione predefinita, tranne che per la porta di LocalSend, quindi funziona subito su un'installazione fresca. Vedi [sicurezza](48-security.md).

## LibreOffice

[LibreOffice](https://www.libreoffice.org/) è un pacchetto office completo con elaboratore di testi, foglio di calcolo, presentazioni, applicazione per il disegno e altro ancora. È compatibile con i file di Microsoft Office, quindi è un ottimo modo per poter aprire quei documenti Word.

Avvii LibreOffice tramite il launcher delle applicazioni (`Super + Space`).

## Hype

[Hype](https://github.com/omacom/hype) è l'app per presentazioni semplicissima di Omarchy. La tua presentazione è un singolo file Markdown con le sue immagini e i suoi video accanto: scrivi ogni diapositiva sotto un'anteprima dal vivo, trascina le diapositive nell'ordine desiderato, poi presenta a schermo intero o esporta in PDF e PowerPoint. Rileva persino il tuo tema Omarchy.

Avvii Hype tramite il launcher delle applicazioni (`Super + Space`). Premi `?` al suo interno per vedere tutte le scorciatoie.

## Signed

[Signed](https://github.com/omacom/signed) è il modo semplicissimo di Omarchy per firmare i PDF e compilarli. Posiziona la tua firma salvata, del testo e la data di oggi ovunque su una pagina, poi salva una copia firmata accanto all'originale. Vedi [Compilare i PDF](27-filling-out-pdfs.md) per scoprire come.

Avvii Signed tramite il launcher delle applicazioni (`Super + Space`), oppure apri un PDF con esso dal file manager.

## Checkmate

[Checkmate](https://github.com/omacom/checkmate) è il gioco di scacchi 3D di Omarchy. Gioca contro un amico sullo stesso computer o contro l'avversario integrato a tre livelli, con quattro set scolpiti che si muovono ciascuno a modo proprio: veicoli orbitali, legno intagliato e avorio, creature dei boschi e caramelle. Le partite non hanno orologio e vengono salvate dopo ogni mossa.

Avvii Checkmate tramite il launcher delle applicazioni (`Super + Space`), dove è elencato come Chess. Premi `?` al suo interno per vedere tutte le scorciatoie.

## Cards

[Cards](https://github.com/omacom/cards) è il solitario Klondike di Omarchy. Pesca tre carte, senza limite di passaggi, in quattro serie di carte: una disegnata con i colori del tuo tema e tre con un aspetto proprio. Fai clic su una carta e poi nel punto in cui deve andare, trascinala oppure fai doppio clic per inviarla nel posto migliore. Le partite vengono salvate dopo ogni mossa.

Avvii Cards tramite il launcher delle applicazioni (`Super + Space`). Fai clic sul suo nome, oppure premi `?`, per vedere tutte le scorciatoie.

## Omacalc

[Omacalc](https://github.com/omacom-io/omacalc) è la calcolatrice semplicissima di Omarchy, che si apre in una finestra mobile.

Avvii Omacalc con `Super + Shift + Q` (o con il tasto della calcolatrice, se la tua tastiera ne ha uno).

## Signal

[Signal](https://signal.org/) è il pioniere della messaggistica con crittografia E2E ed è un'ottima opzione di comunicazione per chiunque preferisca non passare attraverso uno dei grandi conglomerati tecnologici.

Avvii Signal con `Super + Shift + G`. Non fa parte dell'installazione di base, quindi la prima volta che premi quella combinazione, Omarchy ti offrirà di installarlo per te (si trova anche in _Install > Service_ nel menu di Omarchy).

## Omaview

[Omaview](https://github.com/omacom/omaview) è il visualizzatore di immagini e lettore multimediale semplicissimo di Omarchy: una sola finestra per le tue foto, i tuoi video e la tua musica. Apri una foto e i tasti freccia scorrono il resto della sua cartella, `N` e `P` lo fanno per qualsiasi cosa e `Ctrl + M` mostra l'intera cartella come griglia. Mostra anche foto HEIC, AVIF e JPEG XL e riprende dal punto in cui avevi interrotto qualsiasi contenuto lungo.

Premi `F` per lo schermo intero, `E` per modificare un'immagine in Omasnap o tagliare un video in Omacut, `Ctrl + P` per stampare un'immagine e `Delete` per spostare un file nel Cestino (`Ctrl + Z` lo riporta indietro). Premi `?` al suo interno per vedere tutte le scorciatoie.

Avvii Omaview come _Media Viewer_ tramite il launcher delle applicazioni (`Super + Space`), oppure fai semplicemente doppio clic su un'immagine, un video o un brano nel file manager.

## Omacut

[Omacut](https://github.com/omacom-io/omacut) è lo strumento semplicissimo di Omarchy per tagliare i video. Quando tutto ciò che ti serve è tagliare l'inizio e la fine di una clip, batte l'avvio di un editor video completo.

Avvii Omacut tramite il launcher delle applicazioni (`Super + Space`).

## Monologue

[Monologue](https://github.com/omacom/monologue) è il registratore da webcam semplicissimo di Omarchy. Scegli una volta la tua fotocamera e il tuo microfono, poi premi `Space` per registrare e di nuovo per mettere in pausa e riprendere la stessa registrazione. Registra sempre alla risoluzione più alta della tua fotocamera, con un indicatore del microfono dal vivo così puoi controllare i livelli prima di iniziare.

Interrompi la registrazione e si apre subito in un editor integrato. Fai doppio clic su una clip per dividerla, trascina le maniglie per tagliare ogni pezzo e rimuovi le parti che non vuoi. Poi salvala come MP4. La registrazione originale viene conservata finché non la scarti, così puoi sempre tornare indietro e tagliarla in modo diverso.

Avvii Monologue tramite il launcher delle applicazioni (`Super + Space`).
