# GUIs

## Files

Files (Folio) è il file manager grafico. `Super + Shift + F` lo apre, e `Super + Shift + Alt + F` lo apre nella directory in cui si trova il tuo terminale, il che fa risparmiare un sacco di clic. `Ctrl + L` ti permette di digitare un percorso, e premendo `Space` su qualsiasi file lo vedi in anteprima a dimensione intera senza aprirlo.

Collega una chiavetta USB o una scheda SD e viene montata automaticamente, così appare semplicemente nella barra laterale. Per qualcosa di più impegnativo — formattare un'unità, controllare lo stato SMART, creare partizioni — avvia _Disks_ dal launcher delle applicazioni (`Super + Space`).

Il doppio clic segue impostazioni predefinite sensate: immagini, video e musica si aprono in Omaview, i PDF in Document Viewer, il Markdown in Omawrite e il testo semplice nel tuo editor, Plain a meno che tu non ne scelga un altro in _Setup > Defaults > Editor_.

## Disktree

Quando l'unità si riempie e non hai idea di cosa la stia occupando, avvia [Disktree](https://github.com/tobi/disktree) dal launcher delle applicazioni (`Super + Space`). Mostra una treemap grafica della tua directory home. I blocchi più grandi occupano più spazio; attraversa le directory con la tastiera o il mouse, marca ciò che deve andare ed esamina le tue selezioni prima di rimuovere qualsiasi cosa. Esegui `disktree --disk` per scansionare l'intero disco.

## Obsidian

[Obsidian](https://obsidian.md/) è un'applicazione per prendere appunti gratuita e altamente estensibile che usa semplici file Markdown per l'archiviazione.

Obsidian è gratuito per tutti gli usi, inclusi uso personale, commerciale e non-profit.

Obsidian offre anche un [componente aggiuntivo commerciale per la sincronizzazione](https://obsidian.md/sync) con le app mobili su iOS e Android. (https://obsidian.md/pricing).

Avvii Obsidian con `Super + Shift + O`. Per usare la sincronizzazione del tema, devi selezionare il tema `Omarchy` nelle impostazioni.

## Omawrite

[Omawrite](https://github.com/omacom-io/omawrite) è l'app di scrittura Markdown semplicissima di Omarchy. Niente vault, niente plugin, solo tu e le parole.

Avvii Omawrite con `Super + Shift + W`.

## Pinta

[Pinta](https://www.pinta-project.com/) è uno strumento di modifica delle immagini di base, ottimo per ritagliare, ridimensionare e altre manipolazioni di base. Non aspettarti un'alternativa a Photoshop. Ma ha comunque la Bacchetta magica e i livelli!

Avvii Pinta tramite il launcher delle applicazioni (`Super + Space`).

## Aether

[Aether](https://github.com/bjarneo/aether) è un'applicazione per i temi che può estrarre i colori da un'immagine di sfondo e trasformarli in un tema completo e coerente. È il modo più semplice per [creare il tuo tema](43-making-your-own-theme.md).

Avvii Aether tramite il launcher delle applicazioni (`Super + Space`).

## LocalSend

[LocalSend](https://localsend.org/) ti permette di inviare file ad altri dispositivi sulla stessa rete che eseguono l'app, come AirDrop di Apple. È però multipiattaforma, quindi puoi inviare file da e verso Windows, macOS, Android, iOS e ovviamente Linux.

Puoi aprire il menu Share su `Super + Ctrl + S` o in _Trigger > Share_ nel menu di Omarchy. Ti offre quattro opzioni:

- **Clipboard** invia tutto ciò che hai copiato come file di testo. Ottimo per portare un link o uno snippet sul telefono senza doverti mandare un'e-mail.
- **File** apre un selettore di file in cui puoi selezionarne diversi alla volta.
- **Folder** invia un'intera directory.
- **Receive** apre LocalSend vero e proprio, così un altro dispositivo può inviarti qualcosa.

La stessa cosa funziona dal terminale con `omarchy share clipboard`, `omarchy share file [path]` e `omarchy share folder [path]`. Ometti il percorso e ottieni il selettore.

Puoi anche inviare direttamente dal file manager: fai clic con il pulsante destro del mouse su una selezione in Files e condividila con LocalSend.

Il firewall di Omarchy è chiuso per impostazione predefinita, tranne che per la porta di LocalSend, quindi funziona subito su un'installazione fresca. Vedi [sicurezza](48-security.md).

## LibreOffice

[LibreOffice](https://www.libreoffice.org/) è un pacchetto office completo con elaboratore di testi, foglio di calcolo, presentazioni, applicazione di disegno e altro ancora. È compatibile con i file di Microsoft Office, quindi è un ottimo modo per poter aprire quei documenti Word.

Avvii LibreOffice tramite il launcher delle applicazioni (`Super + Space`).

## Hype

[Hype](https://github.com/omacom/hype) è l'app per presentazioni semplicissima di Omarchy. La tua presentazione è un singolo file Markdown con le sue immagini e i suoi video accanto: scrivi ogni diapositiva sotto un'anteprima live, trascina le diapositive nell'ordine desiderato, poi presenta a schermo intero o esporta in PDF e PowerPoint. Rileva persino il tuo tema Omarchy.

Avvii Hype tramite il launcher delle applicazioni (`Super + Space`). Premi `?` al suo interno per vedere tutte le scorciatoie.

## Signed

[Signed](https://github.com/omacom/signed) è il modo semplicissimo di Omarchy per firmare i PDF e compilarli. Posiziona la firma salvata, del testo e la data di oggi ovunque su una pagina, poi salva una copia firmata accanto all'originale. Vedi [Compilare i PDF](27-filling-out-pdfs.md) per sapere come fare.

Avvii Signed tramite il launcher delle applicazioni (`Super + Space`), oppure apri un PDF con esso dal file manager.

## Game Vibes

Game Vibes, nel launcher delle applicazioni (`Super + Space`), è dove vivono i piccoli giochi di Omarchy: Checkmate, una partita a scacchi 3D contro un amico o l'avversario integrato; Cards, il solitario Klondike; Death Wish, un platformer di precisione al pixel composto da dieci stanze piene di spuntoni e seghe; e Neon Swarm, uno sparatutto arcade. Ognuno è una singola pagina web che segue il tuo tema. Scegline uno con le frecce e `Enter`, e torna all'elenco con `Esc` dalla schermata del titolo di un gioco o con `Q` mentre è in pausa. Si apre a schermo intero: `Super + F` lo trasforma in una finestra e `Super + W` lo chiude.

Anche i giochi che crei con un agent appaiono qui: scegli _Make something cool → Game_ nel pannello degli agent e descrivine uno, oppure indica un gioco già presente in Game Vibes per continuare a lavorarci. L'agent lo copia in `~/Games/vibes`, dove è tuo e puoi modificarlo, e lo apre quando ha finito. Puoi fare tu stesso quella copia con `omarchy games vibes copy <game>`. Un gioco condiviso da qualcun altro si installa come un tema: scegli _Install > Gaming > Game Vibes_ e incolla il suo indirizzo git, oppure esegui `omarchy games vibes install <git-repo-url>`. _Remove > Gaming_ ne rimuove uno, e _Update > Game Vibes Games_ ne scarica le nuove versioni. I giochi caricano three.js dal web, quindi hanno bisogno di una connessione per avviarsi.

## Omacalc

[Omacalc](https://github.com/omacom-io/omacalc) è la calcolatrice semplicissima di Omarchy, che si apre in una finestra mobile.

Avvii Omacalc con `Super + Shift + Q` (o con il tasto calcolatrice, se la tua tastiera ne ha uno).

## Signal

[Signal](https://signal.org/) è il pioniere della messaggistica con crittografia E2E, e un'ottima opzione di comunicazione per chiunque preferisca non passare da uno dei grandi conglomerati tecnologici.

Avvii Signal con `Super + Shift + G`. Non fa parte dell'installazione di base, quindi la prima volta che premi quella combinazione, Omarchy si offrirà di installarlo per te (si trova anche in _Install > Service_ nel menu di Omarchy).

## Omaview

[Omaview](https://github.com/omacom/omaview) è il visualizzatore di immagini e lettore multimediale semplicissimo di Omarchy: una finestra per foto, video e musica. Apri una foto e i tasti freccia scorrono il resto della sua cartella, `N` e `P` lo fanno per qualsiasi cosa e `Ctrl + M` mostra l'intera cartella come griglia. Mostra anche foto HEIC, AVIF e JPEG XL, e riprende da dove avevi interrotto qualsiasi contenuto lungo.

Premi `F` per lo schermo intero, `E` per modificare un'immagine in Omasnap o tagliare un video in Omacut, `Ctrl + P` per stampare un'immagine e `Delete` per spostare un file nel Cestino (`Ctrl + Z` lo riporta indietro). Premi `?` al suo interno per vedere tutte le scorciatoie.

Avvii Omaview come _Media Viewer_ tramite il launcher delle applicazioni (`Super + Space`), oppure fai semplicemente doppio clic su un'immagine, un video o un brano nel file manager.

## Omacut

[Omacut](https://github.com/omacom-io/omacut) è il trimmer video semplicissimo di Omarchy. Quando ti serve solo tagliare l'inizio e la fine di una clip, batte l'avvio di un editor video completo.

Avvii Omacut tramite il launcher delle applicazioni (`Super + Space`).

## Monologue

[Monologue](https://github.com/omacom/monologue) è il registratore webcam semplicissimo di Omarchy. Scegli una volta la fotocamera e il microfono, poi premi `Space` per registrare, e di nuovo per mettere in pausa e riprendere la stessa ripresa. Registra sempre alla massima risoluzione della fotocamera, con un indicatore del microfono in tempo reale così puoi controllare i livelli prima di iniziare.

Interrompi la ripresa e si apre subito in un editor integrato. Fai doppio clic su una clip per dividerla, trascina le maniglie per tagliare ogni pezzo e rimuovi le parti che non vuoi. Poi salvala come MP4. La registrazione originale viene conservata finché non la scarti, così puoi sempre tornare indietro e tagliarla in modo diverso.

Avvii Monologue tramite il launcher delle applicazioni (`Super + Space`).
