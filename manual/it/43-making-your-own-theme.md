# Creare il tuo tema

Puoi aggiungere i tuoi temi in `~/.config/omarchy/themes`. Copia semplicemente uno di quelli esistenti come base (guarda in `/usr/share/omarchy/themes`), poi modificalo a tuo piacimento. Finché il tuo tema si trova in quella cartella, sarà incluso nel menu di selezione dei temi.

Il file principale che devi modificare è `colors.toml`. Definisce la palette di colori che viene poi usata per generare le configurazioni per il terminale (Foot/Alacritty/Ghostty/Kitty), btop, Chromium, Hyprland, Neovim, Helix, VSCode, Obsidian, e l'intera shell di Omarchy (barra superiore, menu, notifiche, OSD, e schermata di blocco).

Puoi anche usare l'applicazione Aether inclusa per creare un nuovo tema usando una splendida interfaccia GUI con cui giocare con i colori e cercare sfondi. Basta avviarla dalla griglia delle app con `Super + Alt + Space`.

### Cosa può contenere un tema installato

Un tema che scrivi tu in `~/.config/omarchy/themes` può contenere quello che vuoi — è la tua macchina e il tuo file, e Omarchy applica tutto.

Un tema che installi dal repo di qualcun altro con `omarchy theme install` conserva tutto ciò che è colore, e perde quella manciata di file che eseguirebbero codice sulla tua macchina: qualsiasi file `.lua`, le configurazioni del terminale (`alacritty.toml`, `foot.ini`, `ghostty.conf`, `kitty.conf`), e `vscode.json`. La `hyprland.lua` di un tema è Lua che il tuo compositor esegue all'accesso, una configurazione del terminale indica il programma che il tuo terminale avvia, e `vscode.json` indica un'estensione di VSCode da installare. Installare il tema di qualcuno dovrebbe cambiare l'aspetto del tuo desktop, mai ciò che esegue.

Tutto il resto continua a funzionare esattamente come l'ha scritto l'autore del tema — `btop.theme`, `chromium.theme`, `helix.toml`, `icons.theme`, `shell.toml`, gli sfondi e le anteprime vengono tutti conservati. Solo ciò che è stato rimosso viene rigenerato da `colors.toml` sulla tua macchina.

Omarchy distingue i due casi in base al fatto che il tema contenga o meno il suo repo git, che è ciò che `omarchy theme install` lascia dietro di sé quando clona. Così un tema che hai scritto resta tuo, e uno che hai scaricato da internet resta solo colori.

### Modalità chiara

Se stai creando un tema in modalità chiara, imposta `mode = "light"` all'inizio del tuo `colors.toml`. Così verrà abbinato automaticamente alla modalità chiara per tutte le app. (Funziona ancora anche il vecchio metodo: lasciare un file vuoto chiamato `light.mode` nella radice del tuo tema.)

### Colori delle icone

Se vuoi abbinare i colori delle icone del file manager al tuo tema, aggiungi un file chiamato `icons.theme` con il nome del set di icone che vuoi usare. Per impostazione predefinita, le opzioni sono: `Yaru Yaru-blue Yaru-dark Yaru-magenta Yaru-olive Yaru-prussiangreen Yaru-purple Yaru-red Yaru-sage Yaru-wartybrown Yaru-yellow`.

### Immagine di sblocco

I temi forniti con le immagini `unlock.png` e `preview-unlock.png` saranno elencati in _Aspetto > Sblocco_. La tua `unlock.png` dovrebbe preferibilmente essere un png trasparente. E puoi creare l'immagine di anteprima usando `omarchy plymouth preview`.

### Applicare il tema ad app che Omarchy non copre

Se usi un'app che non è in quell'elenco, puoi insegnare a Omarchy ad applicarle il tema da solo con un template. Lascia un file in `~/.config/omarchy/themed/` chiamato come la configurazione che genera più un'estensione `.tpl`, e scrivi la configurazione usando `{{ background }}`, `{{ foreground }}`, `{{ accent }}`, `{{ red }}`, `{{ color0 }}` fino a `{{ color15 }}`, e il resto della palette come placeholder. Ogni volta che cambi tema, il file viene rigenerato con i colori di quel tema.

In quella cartella c'è un `alacritty.toml.tpl.sample` completamente commentato da cui copiare — elenca ogni variabile che puoi usare, più i modificatori `_strip` e `_rgb` per le app che vogliono i loro colori senza il `#` o come RGB decimale. I tuoi template hanno la precedenza su quelli di Omarchy, quindi puoi usare questo metodo anche per sovrascrivere il modo in cui viene applicato il tema a un'app integrata.

### Distribuire il tuo tema

Se vuoi distribuire il tuo tema perché altri possano usarlo, devi metterlo su un server git pubblico, come GitHub. Così le persone possono installarlo usando _Installa > Stile > Tema_ nel menu di Omarchy usando quell'URL. È consigliato seguire la convenzione di denominazione `omarchy-[themename]-theme`, perché il tema verrà mostrato correttamente come semplice `[themename]` nel menu di selezione dei temi dopo l'installazione.

Quel `[themename]` restante diventa il nome della directory del tema, quindi deve essere uno che Omarchy può gestire in sicurezza: deve iniziare con una lettera, una cifra o un underscore, e il resto può contenere lettere, cifre, `.`, `_`, `+` e `-`. Le maiuscole vengono convertite in minuscole per te, ma qualsiasi altra cosa — uno spazio, una virgoletta, un carattere non inglese — viene rifiutata al momento dell'installazione invece di essere trasformata in un nome di directory. Quindi `omarchy-tokyo-night-theme`, `omarchy-flexoki_light-theme` e `omarchy-c++-theme` si installano tutti senza problemi.

Ricorda che una volta installato da un repo, qualsiasi `.lua`, configurazione del terminale o `vscode.json` che include viene rimosso, quindi non costruire il tema intorno a quelli.

Puoi far aggiungere il tuo tema alla [pagina dei temi extra](https://omarchy.org/themes/) inviando una pull request al [repo omarchy-site](https://github.com/omacom-io/omarchy-site).
