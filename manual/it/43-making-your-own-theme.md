# Creare un tema personalizzato

Puoi aggiungere i tuoi temi in `~/.config/omarchy/themes`. Copia semplicemente uno di quelli esistenti come base (li trovi in `/usr/share/omarchy/themes`), poi ritoccalo a tuo piacimento. Finché il tuo tema si trova in quella cartella, verrà incluso nel menu di selezione dei temi.

Il file principale da modificare è `colors.toml`. Definisce la serie di colori che viene poi usata per generare le configurazioni per il terminale (Foot/Alacritty/Ghostty/Kitty), btop, Chromium, Hyprland, Neovim, Helix, VSCode, Obsidian e l'intera shell di Omarchy (barra superiore, menu, notifiche, OSD e schermata di blocco).

Puoi anche usare l'applicazione Aether inclusa per creare un nuovo tema usando un'amabile interfaccia grafica per giocare con i colori e cercare sfondi. Avviala dalla griglia delle app con `Super + Alt + Space`.

### Cosa può contenere un tema installato

Un tema che scrivi tu in `~/.config/omarchy/themes` può contenere quello che vuoi: è la tua macchina e il tuo file, e Omarchy applica tutto.

Un tema che installi dal repository di qualcun altro con `omarchy theme install` conserva tutto ciò che è colore e perde la manciata di file che eseguirebbe codice sulla tua macchina: qualsiasi file `.lua`, le configurazioni del terminale (`alacritty.toml`, `foot.ini`, `ghostty.conf`, `kitty.conf`) e `vscode.json`. L'`hyprland.lua` di un tema è Lua che il tuo compositore esegue all'accesso, una configurazione del terminale nomina il programma che il tuo terminale avvia e `vscode.json` nomina un'estensione VSCode da installare. Installare il tema di qualcuno deve cambiare l'aspetto del tuo desktop, mai quello che esegue.

Tutto il resto funziona ancora esattamente come l'ha scritto l'autore del tema: `btop.theme`, `chromium.theme`, `helix.toml`, `icons.theme`, `shell.toml`, gli sfondi e le anteprime vengono tutti conservati. Solo ciò che è stato scartato viene rigenerato da `colors.toml` sulla tua macchina.

Omarchy distingue i due casi dal fatto che il tema abbia o meno un proprio repository git al suo interno, che è ciò che `omarchy theme install` lascia dietro di sé quando clona. Così un tema scritto da te resta tuo e uno scaricato da internet resta solo colori.

### Modalità chiara

Se stai creando un tema in modalità chiara, imposta `mode = "light"` in cima al tuo `colors.toml`. Verrà così abbinato automaticamente alla modalità chiara per tutte le app. (Funziona ancora anche il vecchio metodo di mettere un file vuoto chiamato `light.mode` nella radice del tuo tema.)

### Colori delle icone

Se vuoi abbinare i colori delle icone del file manager al tuo tema, aggiungi un file chiamato `icons.theme` con il nome del set di icone che vuoi usare. Per impostazione predefinita, le opzioni sono: `Yaru Yaru-blue Yaru-dark Yaru-magenta Yaru-olive Yaru-prussiangreen Yaru-purple Yaru-red Yaru-sage Yaru-wartybrown Yaru-yellow`.

### Immagine di sblocco

I temi forniti con le immagini `unlock.png` e `preview-unlock.png` verranno elencati in _Stile > Sblocca_. La tua `unlock.png` dovrebbe preferibilmente essere un png trasparente. E puoi creare l'immagine di anteprima usando `omarchy plymouth preview`.

### Applicare il tema ad app che Omarchy non copre

Se usi un'app che non è in quella lista, puoi insegnare tu stesso a Omarchy ad applicarle il tema con un modello. Metti un file in `~/.config/omarchy/themed/` con il nome della configurazione che genera più l'estensione `.tpl` e scrivi la configurazione con `{{ background }}`, `{{ foreground }}`, `{{ accent }}`, `{{ red }}`, da `{{ color0 }}` a `{{ color15 }}` e il resto della tavolozza come segnaposto. Ogni volta che cambi tema, il file viene rigenerato con i colori di quel tema.

In quella cartella c'è un `alacritty.toml.tpl.sample` completamente commentato da cui copiare: elenca ogni variabile che puoi usare, più i modificatori `_strip` e `_rgb` per le app che vogliono i colori senza il `#` o in formato RGB decimale. I tuoi modelli hanno la priorità su quelli di Omarchy, quindi puoi usarli anche per sostituire il modo in cui a un'app integrata viene applicato il tema.

### Distribuire il tuo tema

Se vuoi distribuire il tuo tema perché altri possano usarlo, devi metterlo su un server git pubblico, come GitHub. Poi le persone potranno installarlo usando _Installa > Stile > Tema_ nel menu di Omarchy con quell'URL. È consigliabile seguire la convenzione di denominazione `omarchy-[nome tema]-theme`, perché dopo l'installazione il tema apparirà correttamente come semplice `[nome tema]` nel menu di selezione dei temi.

Quel `[nome tema]` residuo diventa il nome della directory del tema, quindi deve essere uno che Omarchy possa passare in giro in sicurezza: deve iniziare con una lettera, una cifra o un trattino basso, e il resto può contenere lettere, cifre, `.`, `_`, `+` e `-`. Le maiuscole vengono convertite in minuscole per te, ma qualsiasi altra cosa — uno spazio, un apice, un carattere non inglese — viene rifiutata al momento dell'installazione invece di essere trasformata in un nome di directory. Quindi `omarchy-tokyo-night-theme`, `omarchy-flexoki_light-theme` e `omarchy-c++-theme` si installano tutti senza problemi.

Ricorda che una volta installato da un repository, qualsiasi `.lua`, configurazione del terminale o `vscode.json` che contiene viene scartato, quindi non costruire il tema attorno a quelli.

Puoi far aggiungere il tuo tema alla [pagina dei temi extra](https://omarchy.org/themes/) inviando una pull request al [repository omarchy-site](https://github.com/omacom-io/omarchy-site).
