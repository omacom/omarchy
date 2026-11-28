# Creare il tuo tema

Puoi aggiungere i tuoi temi a `~/.config/omarchy/themes`. Copia semplicemente uno di quelli esistenti come base (guarda in `/usr/share/omarchy/themes`), poi modificalo a tuo piacimento. Finché il tuo tema si trova dentro quella cartella, verrà incluso nel menu di selezione dei temi.

Il file principale da modificare è `colors.toml`. Definisce l'insieme di colori che viene poi usato per generare le configurazioni per il terminale (Foot/Alacritty/Ghostty/Kitty), btop, Chromium, Hyprland, Neovim, Helix, VSCode, Obsidian, le app Qt, la retroilluminazione della tastiera, il metodo di input, il selettore per la condivisione dello schermo, le icone delle app, diversi strumenti AI (Claude, Pi, Hermes, T3 Code, Herdr) e l'intera shell di Omarchy (barra superiore, menu, notifiche, OSD e schermata di blocco).

Puoi anche usare l'applicazione Aether inclusa per creare un nuovo tema usando una bella interfaccia GUI per giocare con i colori e cercare sfondi. Avviala semplicemente dalla griglia delle app con `Super + Alt + Space`.

### Cosa può contenere un tema installato

Un tema che scrivi tu in `~/.config/omarchy/themes` può contenere quello che vuoi — è la tua macchina e il tuo file, e Omarchy applica tutto.

Un tema che installi dal repo di qualcun altro con `omarchy theme install` conserva tutto ciò che è colore e perde la manciata di file che eseguirebbero codice sulla tua macchina: qualsiasi file `.lua`, le configurazioni del terminale (`alacritty.toml`, `foot.ini`, `ghostty.conf`, `kitty.conf`) e `vscode.json`. L'`hyprland.lua` di un tema è Lua che il tuo compositor esegue all'accesso, una configurazione del terminale indica il programma che il tuo terminale avvia e `vscode.json` indica un'estensione di VSCode da installare. Installare il tema di qualcuno dovrebbe cambiare l'aspetto del tuo desktop, mai ciò che esegue.

Tutto il resto funziona ancora esattamente come l'ha scritto l'autore del tema — `btop.theme`, `chromium.theme`, `helix.toml`, `shell.toml`, gli sfondi e le anteprime vengono tutti conservati. Solo ciò che è stato scartato viene rigenerato da `colors.toml` sulla tua macchina.

Omarchy distingue i due casi in base al fatto che il tema abbia o meno un proprio repo git al suo interno, che è ciò che `omarchy theme install` si lascia dietro quando clona. Così un tema che hai scritto resta tuo, e uno che hai preso da internet resta solo colori.

### Modalità chiara

Se stai creando un tema in modalità chiara, imposta `mode = "light"` all'inizio del tuo `colors.toml`. Poi verrà abbinato automaticamente alla modalità chiara per tutte le app. (Funziona ancora anche il vecchio metodo di lasciare un file vuoto chiamato `light.mode` nella radice del tuo tema.)

### Schermate di avvio e di accesso

La schermata che chiede la password del disco all'avvio e la schermata di accesso disegnano il logo di Omarchy nel colore `accent` del tuo tema sul suo `background`, con il campo della password nel suo `foreground` e `red` per una password sbagliata. Non c'è nulla di extra da includere per loro: Omarchy non usa più gli `unlock.png` o `preview-unlock.png` di un tema. Sui Mac Apple Silicon, la schermata della password del disco mantiene l'aspetto predefinito di Omarchy qualunque sia il tema.

### Applicare il tema ad app che Omarchy non copre

Se usi un'app che non è in quell'elenco, puoi insegnare a Omarchy ad applicarle il tema da solo con un template. Lascia un file in `~/.config/omarchy/themed/` chiamato come la configurazione che genera più un'estensione `.tpl`, e scrivi la configurazione con `{{ background }}`, `{{ foreground }}`, `{{ accent }}`, `{{ red }}`, `{{ color0 }}` fino a `{{ color15 }}` e il resto della palette come segnaposto. Ogni volta che cambi tema, il file viene rigenerato con i colori di quel tema.

In quella cartella c'è un `alacritty.toml.tpl.sample` completamente commentato da cui partire — elenca ogni variabile che puoi usare, più i modificatori `_strip` e `_rgb` per le app che vogliono i loro colori senza il `#` o come RGB decimale. I tuoi template hanno la precedenza su quelli di Omarchy, quindi puoi usarli anche per sovrascrivere il modo in cui viene applicato il tema a un'app integrata.

### Distribuire il tuo tema

Se vuoi distribuire il tuo tema in modo che altri possano usarlo, devi metterlo su un server git pubblico, come GitHub. Poi le persone potranno installarlo usando _Install > Style > Theme_ nel menu di Omarchy usando quell'URL. Si consiglia di seguire la convenzione di denominazione `omarchy-[themename]-theme`, perché il tema verrà mostrato correttamente come solo `[themename]` nel menu di selezione dei temi dopo l'installazione.

Quel `[themename]` rimanente diventa il nome della directory del tema, quindi deve essere uno che Omarchy può gestire in sicurezza: deve iniziare con una lettera, una cifra o un underscore, e il resto può contenere lettere, cifre, `.`, `_`, `+` e `-`. Le maiuscole vengono convertite in minuscole per te, ma qualsiasi altra cosa — uno spazio, una virgoletta, un carattere non inglese — viene rifiutata al momento dell'installazione invece di essere trasformata in un nome di directory. Quindi `omarchy-tokyo-night-theme`, `omarchy-flexoki_light-theme` e `omarchy-c++-theme` si installano tutti senza problemi.

Ricorda che una volta installato da un repo, qualsiasi `.lua`, configurazione del terminale o `vscode.json` che include viene scartato, quindi non costruire il tema intorno a quelli.

Puoi far aggiungere il tuo tema alla [pagina dei temi extra](https://omarchy.org/themes/) inviando una pull request al [repo omarchy-site](https://github.com/omacom-io/omarchy-site).
