# Temi

Omarchy include ventitré splendidi temi. Puoi scegliere tra di essi tramite _Appearance > Theme_ nel Menu Omarchy (`Super + Space`) o passare direttamente al selettore dei temi usando `Super + Ctrl + T`.

Ogni tema definisce lo stile del desktop, del terminale, di neovim, della schermata delle attività (btop), del tuo browser (Chrome, Chromium, Edge o Brave) e dell'intera shell di Omarchy: barra superiore, menu, notifiche, OSD e schermata di blocco. (Per Obsidian, devi selezionare manualmente il tema Omarchy tramite _Appearance > Themes_ all'interno dell'app).

I temi hanno una serie di immagini di sfondo tra cui puoi scegliere usando `Super + Ctrl + W`.

Puoi trovare ancora più temi sulla [pagina dei temi extra](https://omarchy.org/themes/) o persino [creare il tuo tema](43-making-your-own-theme.md).

 ![tokyo-night](../themes/tokyo-night/preview.png)
_Tokyo Night_

 ![catppuccin](../themes/catppuccin/preview.png)
_Catppuccin_

 ![lumon](../themes/lumon/preview.png)
_Lumon_

 ![ethereal](../themes/ethereal/preview.png)
_Ethereal_

 ![everforest](../themes/everforest/preview.png)
_Everforest_

 ![gruvbox](../themes/gruvbox/preview.png)
_Gruvbox_

 ![miasma](../themes/miasma/preview.png)
_Miasma_

 ![hackerman](../themes/hackerman/preview.png)
_Hackerman_

 ![jade-horse](../themes/jade-horse/preview.png)
_Jade Horse_

 ![kanagawa](../themes/kanagawa/preview.png)
_Kanagawa_

 ![nord](../themes/nord/preview.png)
_Nord_

 ![matte-black](../themes/matte-black/preview.png)
_Matte Black_

 ![vantablack](../themes/vantablack/preview.png)
_Vantablack_

 ![ristretto](../themes/ristretto/preview.png)
_Ristretto_

 ![retro-82](../themes/retro-82/preview.png)
_Retro 82_

 ![flexoki-light](../themes/flexoki-light/preview.png)
_Flexoki Light_

 ![rose-pine](../themes/rose-pine/preview.png)
_Rose Pine_

 ![catppuccin-latte](../themes/catppuccin-latte/preview.png)
_Catppuccin Latte_

 ![white](../themes/white/preview.png)
_White_

 ![last-horizon](../themes/last-horizon/preview.png)
_Last Horizon_

 ![lupine](../themes/lupine/preview.png)
_Lupine_

 ![solitude](../themes/solitude/preview.png)
_Solitude_

 ![starship](../themes/starship/preview.png)
_Starship_

### Icone delle app

Le icone nel launcher delle app e nella dock sono disegnate con i colori del tuo tema, quindi cambiano insieme a esso. Provengono da un set di icone, che scegli separatamente dal tema in _Appearance > Icons_, dalle anteprime di ciascun set, nello stesso modo in cui scegli un tema:

- _Papercraft_ è il set predefinito: tutto ciò che viene installato, disegnato in un unico stile. Le app riconoscibili dal loro logo, come Chrome, HEY o YouTube, mantengono la propria forma e assumono i colori del tema.
- _Arcade_ disegna le stesse app in pixel art a 8 bit, come farebbe una vecchia console per videogiochi.
- _Original_ mostra ogni app con l'icona che le ha dato il suo creatore.

Puoi installare un set di icone realizzato da qualcun altro con _Install > Style > Icons_ (oppure `omarchy icons install <git url>`), e rimuoverlo di nuovo in _Remove > Icons_. _Update > Extra Icons_ scarica la versione più recente dei set che hai installato.

Per crearne uno tuo, inserisci le tue icone in `~/.config/omarchy/icons/<name>/`, un file per app, con il nome tratto dalla riga `Icon=` del file `.desktop` dell'app. Un file che termina in `.svg` viene mostrato così com'è. Un file che termina in `.svg.tpl` viene disegnato con i colori del tema: scrivi `{{ icon_main }}`, `{{ icon_mark }}`, `{{ icon_paper }}`, `{{ icon_body }}`, `{{ icon_edge }}`, `{{ icon_ink }}` o `{{ icon_shadow }}` nel punto in cui va un colore. Il set predefinito in `/usr/share/omarchy/icons/papercraft/` è un buon punto di partenza. Aggiungi un `preview.png` per mostrare il tuo set nel selettore; senza, Omarchy disegna un'anteprima a partire dalle tue icone. Per modificare una singola icona del set predefinito, inserisci la tua versione in `~/.config/omarchy/icons/papercraft/`.

### Avvio e accesso

Anche la schermata che chiede la password del disco all'avvio del computer e la schermata di accesso seguono il tema. Ogni volta che cambi tema, adottano i suoi colori di sfondo, testo, accento e rosso, quindi non c'è un design di sblocco separato da scegliere. Sui Mac Apple Silicon, la schermata della password del disco mantiene l'aspetto predefinito di Omarchy qualunque sia il tema.
