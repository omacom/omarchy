# Interfacce grafiche

## File

Files (Nautilus) è il gestore di file grafico. `Super + Shift + F` lo apre, e `Super + Shift + Alt + F` lo apre nella directory in cui si trova il tuo terminale, il che ti evita un sacco di clic. `Ctrl + L` ti permette di digitare un percorso, e premendo `Space` su qualsiasi file ottieni un'anteprima rapida senza aprire nulla.

Collega una chiavetta USB o una scheda SD e viene montata automaticamente, così appare semplicemente nella barra laterale. Per operazioni più complesse — formattare un'unità, controllare lo stato SMART, creare partizioni — avvia _Disks_ dal lanciatore di applicazioni (`Super + Space`).

Il doppio clic segue impostazioni predefinite sensate: le immagini si aprono in imv, i video in mpv, i PDF in Document Viewer e il testo semplice in Neovim.

## Disktree

Quando l'unità si riempie e non hai idea di cosa la stia divorando, avvia [Disktree](https://github.com/tobi/disktree) dal lanciatore di applicazioni (`Super + Space`). Mostra una treemap grafica della tua directory home. I blocchi più grandi occupano più spazio; esplora le directory con la tastiera o il mouse, contrassegna ciò che deve sparire e rivedi le tue selezioni prima di rimuovere qualsiasi cosa. Esegui `disktree --disk` per scansionare l'intero disco.

## Obsidian

[Obsidian](https://obsidian.md/) è un'applicazione per prendere appunti gratuita e altamente estensibile che usa semplici file Markdown per l'archiviazione.

Obsidian è gratuito per qualsiasi scopo, incluso l'uso personale, commerciale e senza scopo di lucro.

Obsidian offre anche un [componente aggiuntivo commerciale per la sincronizzazione](https://obsidian.md/sync) con le app mobili su iOS e Android. (https://obsidian.md/pricing).

Avvii Obsidian con `Super + Shift + O`. Per usare la sincronizzazione del tema, devi selezionare il tema `Omarchy` nelle impostazioni.

## Omawrite

[Omawrite](https://github.com/omacom-io/omawrite) è l'app di scrittura Markdown di una semplicità disarmante, creata da Omarchy. Nessun vault, nessun plugin, solo tu e le parole.

Avvii Omawrite con `Super + Shift + W`.

## Pinta

[Pinta](https://www.pinta-project.com/) è uno strumento di modifica delle immagini di base, ottimo per ritagliare, ridimensionare e altre manipolazioni di base. Non aspettarti però un'alternativa a Photoshop. Ma ha persino la Bacchetta magica e i livelli!

Avvii Pinta tramite il lanciatore di applicazioni (`Super + Space`).

## Aether

[Aether](https://github.com/bjarneo/aether) è un'applicazione per i temi che può estrarre i colori da un'immagine di sfondo e trasformarli in un tema completo e coerente. È il modo più semplice per [creare il tuo tema](43-making-your-own-theme.md).

Avvii Aether tramite il lanciatore di applicazioni (`Super + Space`).

## LocalSend

[LocalSend](https://localsend.org/) ti permette di inviare file ad altri dispositivi sulla stessa rete che eseguono l'app, come AirDrop di Apple. È però multipiattaforma, quindi puoi inviare file da e verso Windows, macOS, Android, iOS e, naturalmente, Linux.

Puoi aprire il menu Condividi con `Super + Ctrl + S` o in _Trigger > Share_ nel menu di Omarchy. Ti offre quattro opzioni:

- **Clipboard** invia qualsiasi cosa tu abbia copiato come file di testo. Ottimo per trasferire un link o uno snippet sul telefono senza doverti inviare un'email.
- **File** apre un selettore di file in cui puoi selezionarne diversi contemporaneamente.
- **Folder** invia un'intera directory.
- **Receive** apre LocalSend vero e proprio, in modo che un altro dispositivo possa inviarti qualcosa.

La stessa cosa funziona dal terminale con `omarchy share clipboard`, `omarchy share file [path]` e `omarchy share folder [path]`. Ometti il percorso e ottieni il selettore.

Puoi anche inviare direttamente dal gestore di file: fai clic con il pulsante destro del mouse su qualsiasi selezione in Nautilus e scegli _Send via LocalSend_.

Il firewall di Omarchy è chiuso per impostazione predefinita, tranne che per la porta di LocalSend, quindi tutto questo funziona immediatamente su un'installazione fresca. Vedi [sicurezza](48-security.md).

## LibreOffice

[LibreOffice](https://www.libreoffice.org/) è un pacchetto per ufficio completo con elaboratore di testi, foglio di calcolo, presentazioni, applicazione di disegno e altro ancora. È compatibile con i file di Microsoft Office, quindi è un ottimo modo per poter aprire quei documenti Word.

Avvii LibreOffice tramite il lanciatore di applicazioni (`Super + Space`).

## Hype

[Hype](https://github.com/omacom/hype) è l'app per presentazioni di una semplicità disarmante, creata da Omarchy. La tua presentazione è un singolo file Markdown con le sue immagini e i suoi video accanto: scrivi ogni diapositiva sotto un'anteprima dal vivo, trascina le diapositive nell'ordine desiderato, poi presenta a schermo intero o esporta in PDF e PowerPoint. Rileva persino il tuo tema Omarchy.

Avvii Hype tramite il lanciatore di applicazioni (`Super + Space`). Premi `?` al suo interno per vedere tutte le scorciatoie.

## Signed

[Signed](https://github.com/omacom/signed) è il modo di una semplicità disarmante, creato da Omarchy, per firmare i PDF e compilarli. Metti la tua firma salvata, del testo e la data di oggi ovunque su una pagina, poi salva una copia firmata accanto all'originale. Vedi [Compilare i PDF](27-filling-out-pdfs.md) per sapere come fare.

Avvii Signed tramite il lanciatore di applicazioni (`Super + Space`), oppure apri un PDF con esso dal gestore di file.

## Omacalc

[Omacalc](https://github.com/omacom-io/omacalc) è la calcolatrice di una semplicità disarmante, creata da Omarchy, che si apre in una finestra mobile.

Avvii Omacalc con `Super + Shift + Q` (o con il tasto della calcolatrice, se la tua tastiera ne ha uno).

## Signal

[Signal](https://signal.org/) è il pioniere della messaggistica con crittografia E2E, e un'ottima opzione di comunicazione per chiunque preferisca non passare attraverso uno dei grandi conglomerati tecnologici.

Avvii Signal con `Super + Shift + G`. Non fa parte dell'installazione di base, quindi la prima volta che premi quella combinazione, Omarchy ti offrirà di installarlo per te (si trova anche in _Install > Service_ nel menu di Omarchy).

## mpv

[mpv](https://mpv.io/) è un lettore multimediale semplice e veloce che riprodurrà quasi qualsiasi cosa da qualsiasi sorgente. Ottimo per guardare video.

Avvii mpv tramite il lanciatore di applicazioni (`Super + Space`) o semplicemente facendo doppio clic su un video nel gestore di file.

## Omacut

[Omacut](https://github.com/omacom-io/omacut) è il trimmer video di una semplicità disarmante, creato da Omarchy. Quando tutto ciò che ti serve è tagliare l'inizio e la fine di una clip, batte l'avvio di un editor video completo.

Avvii Omacut tramite il lanciatore di applicazioni (`Super + Space`).

## Monologue

[Monologue](https://github.com/omacom/monologue) è il registratore da webcam di una semplicità disarmante, creato da Omarchy. Scegli una volta la videocamera e il microfono, poi premi `Space` per registrare, e di nuovo per mettere in pausa e riprendere la stessa ripresa. Registra sempre alla massima risoluzione della tua videocamera, con un indicatore del microfono in tempo reale, così puoi controllare i livelli prima di iniziare.

Interrompi la ripresa e si apre subito in un editor integrato. Fai doppio clic su una clip per dividerla, trascina le maniglie per tagliare ogni pezzo e rimuovi le parti che non vuoi. Poi salvala come MP4. La registrazione originale viene conservata finché non la scarti, quindi puoi sempre tornare indietro e tagliarla in modo diverso.

Avvii Monologue tramite il lanciatore di applicazioni (`Super + Space`).
