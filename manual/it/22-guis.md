# GUI

## Files

Files (Nautilus) è il file manager grafico. `Super + Shift + F` lo apre, e `Super + Shift + Alt + F` lo apre nella directory in cui si trova il tuo terminale, il che fa risparmiare molti clic. `Ctrl + L` ti permette di digitare un percorso, e premere `Space` su qualsiasi file ti dà un'anteprima rapida senza aprire nulla.

Collega una chiavetta USB o una scheda SD e verrà montata automaticamente, così apparirà semplicemente nella barra laterale. Per qualcosa di più complesso — formattare un'unità, controllare lo stato SMART, creare partizioni — avvia _Disks_ dal launcher delle app (`Super + Space`).

Il doppio clic segue impostazioni predefinite sensate: le immagini si aprono in imv, i video in mpv, i PDF in Document Viewer e il testo semplice in Neovim.

## Disktree

Quando l'unità si riempie e non hai idea di cosa la stia mangiando, avvia [Disktree](https://github.com/tobi/disktree) dal launcher delle app (`Super + Space`). Mostra una treemap grafica della tua directory home. I blocchi più grandi occupano più spazio; esplora le directory con tastiera o mouse, segna ciò che deve andare e rivedi le tue selezioni prima di rimuovere qualsiasi cosa. Esegui `disktree --disk` per scansionare l'intero disco.

## Obsidian

[Obsidian](https://obsidian.md/) è un'applicazione per prendere appunti gratuita e altamente estensibile che usa semplici file Markdown per l'archiviazione.

Obsidian è gratuito per tutti gli scopi, incluso l'uso personale, commerciale e senza scopo di lucro.

Obsidian offre anche un [componente aggiuntivo commerciale per la sincronizzazione](https://obsidian.md/sync) con app mobili su iOS e Android. (https://obsidian.md/pricing).

Avvii Obsidian con `Super + Shift + O`. Per usare la sincronizzazione del tema, devi selezionare il tema `Omarchy` nelle impostazioni.

## Omawrite

[Omawrite](https://github.com/omacom-io/omawrite) è l'app di scrittura Markdown semplicissima di Omarchy. Niente vault, niente plugin, solo tu e le parole.

Avvii Omawrite con `Super + Shift + W`.

## Pinta

[Pinta](https://www.pinta-project.com/) è uno strumento di modifica delle immagini di base, ottimo per ritagliare, ridimensionare e altre manipolazioni di base. Non aspettarti però un'alternativa a Photoshop. Ma ha comunque la Bacchetta magica e i livelli!

Avvii Pinta dal launcher delle app (`Super + Space`).

## Aether

[Aether](https://github.com/bjarneo/aether) è un'applicazione per i temi che può estrarre colori da un'immagine di sfondo e trasformarli in un tema completo e coerente. È il modo più semplice per [creare il tuo tema](43-making-your-own-theme.md).

Avvii Aether dal launcher delle app (`Super + Space`).

## LocalSend

[LocalSend](https://localsend.org/) ti permette di inviare file ad altri dispositivi sulla stessa rete che eseguono l'app, come AirDrop di Apple. È però multipiattaforma, quindi puoi inviare file da e verso Windows, macOS, Android, iOS e naturalmente Linux.

Puoi aprire il menu Condividi con `Super + Ctrl + S` oppure in _Azioni > Condividi_ nel menu Omarchy. Ti offre quattro opzioni:

- **Appunti** invia ciò che hai copiato come file di testo. Ottimo per portare un link o uno snippet sul telefono senza inviarti un'email.
- **File** apre un selettore di file in cui puoi selezionarne diversi contemporaneamente.
- **Cartella** invia un'intera directory.
- **Ricevi** apre LocalSend vero e proprio così un altro dispositivo può inviarti qualcosa.

La stessa cosa funziona dal terminale con `omarchy share clipboard`, `omarchy share file [path]` e `omarchy share folder [path]`. Ometti il percorso e otterrai il selettore.

Puoi anche inviare direttamente dal file manager: fai clic con il tasto destro su qualsiasi selezione in Nautilus e scegli _Send via LocalSend_.

Il firewall di Omarchy è chiuso per impostazione predefinita tranne che per la porta di LocalSend, quindi funziona subito su un'installazione nuova. Vedi [sicurezza](48-security.md).

## LibreOffice

[LibreOffice](https://www.libreoffice.org/) è una suite per ufficio completa con elaboratore di testi, foglio di calcolo, presentazioni, applicazione di disegno e altro. È compatibile con i file di Microsoft Office, quindi è un ottimo modo per poter aprire quei documenti Word.

Avvii LibreOffice dal launcher delle app (`Super + Space`).

## Hype

[Hype](https://github.com/omacom/hype) è l'app di presentazioni semplicissima di Omarchy. La tua presentazione è un singolo file Markdown con le sue immagini e i suoi video accanto: scrivi ogni diapositiva sotto un'anteprima dal vivo, trascina le diapositive nell'ordine giusto, poi presenta a schermo intero o esporta in PDF e PowerPoint. Riprende persino il tuo tema Omarchy.

Avvii Hype dal launcher delle app (`Super + Space`). Premi `?` al suo interno per vedere ogni scorciatoia.

## Signed

[Signed](https://github.com/omacom/signed) è il modo semplicissimo di Omarchy per firmare i PDF e compilarli. Posiziona la firma salvata, del testo e la data di oggi ovunque su una pagina, poi salva una copia firmata accanto all'originale. Vedi [Compilare i PDF](27-filling-out-pdfs.md) per sapere come.

Avvii Signed dal launcher delle app (`Super + Space`), oppure apri un PDF con esso dal file manager.

## Omacalc

[Omacalc](https://github.com/omacom-io/omacalc) è la calcolatrice semplicissima di Omarchy, che si apre in una finestra flottante.

Avvii Omacalc con `Super + Ctrl + Q` (o con il tasto calcolatrice, se la tua tastiera ne ha uno).

## Signal

[Signal](https://signal.org/) è il pioniere della messaggistica con crittografia end-to-end, e un'ottima opzione di comunicazione per chi preferisce non passare da uno dei grandi conglomerati tecnologici.

Avvii Signal con `Super + Shift + G`. Non fa parte dell'installazione di base, quindi la prima volta che premi quella combinazione Omarchy ti offrirà di installarlo per te (si trova anche in _Installa > Servizio_ nel menu Omarchy).

## mpv

[mpv](https://mpv.io/) è un lettore multimediale semplice e veloce che riproduce quasi tutto da qualsiasi sorgente. Ottimo per guardare video.

Avvii mpv dal launcher delle app (`Super + Space`) oppure fai semplicemente doppio clic su un video nel file manager.

## Omacut

[Omacut](https://github.com/omacom-io/omacut) è il taglia-video semplicissimo di Omarchy. Quando ti serve solo tagliare l'inizio e la fine di una clip, batte l'avvio di un editor video completo.

Avvii Omacut dal launcher delle app (`Super + Space`).

## Monologue

[Monologue](https://github.com/omacom/monologue) è il registratore webcam semplicissimo di Omarchy. Scegli una volta fotocamera e microfono, poi premi `Space` per registrare, e di nuovo per mettere in pausa e riprendere la stessa ripresa. Registra sempre alla risoluzione più alta della tua fotocamera, con un indicatore del microfono dal vivo così puoi controllare i livelli prima di iniziare.

Ferma la ripresa e si apre subito in un editor integrato. Fai doppio clic su una clip per dividerla, trascina le maniglie per tagliare ogni pezzo e rimuovi le parti che non vuoi. Poi salvala come MP4. La registrazione originale viene conservata finché non la scarti, così puoi sempre tornare indietro e tagliarla diversamente.

Avvii Monologue dal launcher delle app (`Super + Space`).
