# Creare il tuo tema

Puoi aggiungere i tuoi temi in `~/.config/omarchy/themes`. Copia semplicemente uno di quelli esistenti come base (guardali in `/usr/share/omarchy/themes`), poi modificalo come preferisci. Finché il tuo tema si trova dentro quella cartella, verrà incluso nel menu di selezione dei temi.

Il file principale da modificare è `colors.toml`. Definisce la serie di colori che viene poi usata per generare le configurazioni per il terminale (Foot/Alacritty/Ghostty/Kitty), btop, Chromium, Hyprland, Neovim, Helix, VSCode, Obsidian e l'intera shell di Omarchy (barra superiore, menu, notifiche, OSD e schermata di blocco).

Puoi anche usare l'applicazione Aether inclusa per creare un nuovo tema usando una piacevole interfaccia GUI con cui giocare con i colori e cercare sfondi. Avviala semplicemente dalla griglia delle app con `Super + Alt + Space`.

### Cosa può contenere un tema installato

Un tema che scrivi tu in `~/.config/omarchy/themes` può contenere quello che vuoi — è la tua macchina e il tuo file, e Omarchy applica tutto.

Un tema che installi dal repository di qualcun altro con `omarchy theme install` conserva tutto ciò che riguarda i colori e perde la manciata di file che eseguirebbero codice sulla tua macchina: qualsiasi file `.lua`, le configurazioni del terminale (`alacritty.toml`, `foot.ini`, `ghostty.conf`, `kitty.conf`) e `vscode.json`. Il file `hyprland.lua` di un tema è codice Lua che il tuo compositor esegue all'accesso, una configurazione del terminale indica il programma che il tuo terminale avvia e `vscode.json` indica un'estensione di VSCode da installare. Installare il tema di qualcuno dovrebbe cambiare l'aspetto del tuo desktop, mai ciò che esegue.

Tutto il resto continua a funzionare esattamente come l'ha scritto l'autore del tema — `btop.theme`, `chromium.theme`, `helix.toml`, `shell.toml`, gli sfondi e le anteprime vengono tutti conservati. Solo ciò che è stato rimosso viene rigenerato sulla tua macchina a partire da `colors.toml`.

Omarchy distingue i due casi verificando se il tema ha al suo interno un proprio repository git, che è ciò che `omarchy theme install` lascia quando clona. Così un tema che hai scritto resta tuo, e uno che hai scaricato da internet resta solo colori.

### Modalità chiara

Se stai creando un tema in modalità chiara, imposta `mode = "light"` all'inizio del tuo `colors.toml`. Verrà quindi associato automaticamente alla modalità chiara per tutte le app. (Funziona ancora anche il vecchio metodo: lasciare un file vuoto chiamato `light.mode` nella cartella principale del tuo tema.)

### Immagine di sblocco

I temi forniti con le immagini `unlock.png` e `preview-unlock.png` verranno elencati in _Aspetto > Sblocco_. Il tuo `unlock.png` dovrebbe preferibilmente essere un png trasparente. E puoi creare l'immagine di anteprima usando `omarchy plymouth preview`.

### Applicare il tema ad app non coperte da Omarchy

Se usi un'app che non è in quell'elenco, puoi insegnare a Omarchy ad applicarle il tema da solo con un modello. Lascia un file in `~/.config/omarchy/themed/` con il nome della configurazione che genera più un'estensione `.tpl`, e scrivi la configurazione usando `{{ background }}`, `{{ foreground }}`, `{{ accent }}`, `{{ red }}`, da `{{ color0 }}` a `{{ color15 }}` e il resto della tavolozza come segnaposto. Ogni volta che cambi tema, il file viene rigenerato con i colori di quel tema.

In quella cartella c'è un `alacritty.toml.tpl.sample` interamente commentato da cui partire — elenca ogni variabile che puoi usare, più i modificatori `_strip` e `_rgb` per le app che vogliono i colori senza `#` o come RGB decimale. I tuoi modelli hanno la priorità su quelli di Omarchy, quindi puoi usare questo metodo anche per sostituire il modo in cui viene applicato il tema a un'app integrata.

### Distribuire il tuo tema

Se vuoi distribuire il tuo tema affinché altri possano usarlo, devi metterlo su un server git pubblico, come GitHub. Gli altri potranno quindi installarlo usando _Installa > Stile > Tema_ nel menu di Omarchy usando quell'URL. Si consiglia di seguire la convenzione di denominazione `omarchy-[themename]-theme`, perché dopo l'installazione il tema apparirà correttamente semplicemente come `[themename]` nel menu di selezione dei temi.

Quel `[themename]` rimanente diventa il nome della directory del tema, quindi deve essere un nome che Omarchy può passare in giro in sicurezza: deve iniziare con una lettera, una cifra o un trattino basso, e il resto può contenere lettere, cifre, `.`, `_`, `+` e `-`. Le maiuscole vengono convertite in minuscole per te, ma qualsiasi altra cosa — uno spazio, una virgoletta, un carattere non inglese — viene rifiutata al momento dell'installazione invece di essere trasformata in un nome di directory. Quindi `omarchy-tokyo-night-theme`, `omarchy-flexoki_light-theme` e `omarchy-c++-theme` si installano tutti senza problemi.

Ricorda che, una volta installato da un repository, qualsiasi file `.lua`, configurazione del terminale o `vscode.json` incluso viene rimosso, quindi non costruire il tema intorno a quelli.

Puoi far aggiungere il tuo tema alla [pagina dei temi extra](https://omarchy.org/themes/) inviando una pull request al [repository omarchy-site](https://github.com/omacom-io/omarchy-site).
