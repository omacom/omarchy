# Temi

Omarchy include ventidue bellissimi temi. Puoi scegliere tra di essi tramite _Aspetto > Tema_ nel Menu Omarchy (`Super + Space`) o passare direttamente al selettore dei temi usando `Super + Ctrl + T`.

Ogni tema personalizza il desktop, il terminale, neovim, la schermata delle attività (btop), Chromium e l'intera shell di Omarchy: barra superiore, menu, notifiche, OSD e schermata di blocco. (Per Obsidian, devi selezionare manualmente il tema Omarchy tramite _Aspetto > Temi_ all'interno dell'app).

I temi hanno una serie di immagini di sfondo tra cui puoi scegliere usando `Super + Ctrl + W`.

Puoi trovare ancora più temi sulla [pagina dei temi extra](https://omarchy.org/themes/) o persino [creare un tema tutto tuo](43-making-your-own-theme.md).

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

### Icone delle app

Le icone nel launcher delle app e nel dock sono disegnate con i colori del tuo tema, quindi cambiano insieme a esso. Provengono da un set di icone, che scegli separatamente dal tema in _Aspetto > Icone_, dalle anteprime di ciascun set, nello stesso modo in cui scegli un tema:

- _Papercraft_ è il set predefinito: tutto ciò che viene installato, disegnato in un unico stile. Le app conosciute per il loro logo, come Chrome, HEY o YouTube, ne mantengono la forma e assumono i colori del tema.
- _Arcade_ disegna le stesse app in pixel art a 8 bit, come farebbe una vecchia console da gioco.
- _Original_ mostra ogni app con l'icona che le ha dato il suo creatore.

Puoi installare un set di icone creato da qualcun altro con _Installa > Stile > Icone_ (oppure `omarchy icons install <git url>`), e rimuoverlo di nuovo da _Rimuovi > Icone_. _Aggiorna > Icone extra_ recupera l'ultima versione dei set che hai installato.

Per creare il tuo set, inserisci le tue icone in `~/.config/omarchy/icons/<name>/`, un file per app, con il nome tratto dalla riga `Icon=` del file `.desktop` dell'app. Un file che termina con `.svg` viene mostrato così com'è. Un file che termina con `.svg.tpl` viene disegnato con i colori del tema: scrivi `{{ icon_main }}`, `{{ icon_mark }}`, `{{ icon_paper }}`, `{{ icon_body }}`, `{{ icon_edge }}`, `{{ icon_ink }}` o `{{ icon_shadow }}` dove va un colore. Il set predefinito in `/usr/share/omarchy/icons/papercraft/` è un buon punto di partenza. Aggiungi un `preview.png` per mostrare il tuo set nel selettore; senza di esso, Omarchy disegna un'anteprima a partire dalle tue icone. Per cambiare una singola icona del set predefinito, inserisci la tua versione in `~/.config/omarchy/icons/papercraft/`.

### Sblocco

I temi possono anche avere un design di sblocco personalizzato, usato per il processo di decrittazione all'avvio. Puoi selezionarne uno in _Aspetto > Sblocco_. Ecco come appaiono:

 ![catppuccin](../themes/catppuccin/preview-unlock.png)
_Catppuccin_

 ![catppuccin-latte](../themes/catppuccin-latte/preview-unlock.png)
_Catppuccin Latte_

 ![ethereal](../themes/ethereal/preview-unlock.png)
_Ethereal_

 ![everforest](../themes/everforest/preview-unlock.png)
_Everforest_

 ![flexoki-light](../themes/flexoki-light/preview-unlock.png)
_Flexoki Light_

 ![gruvbox](../themes/gruvbox/preview-unlock.png)
_Gruvbox_

 ![hackerman](../themes/hackerman/preview-unlock.png)
_Hackerman_

 ![jade-horse](../themes/jade-horse/preview-unlock.png)
_Jade Horse_

 ![kanagawa](../themes/kanagawa/preview-unlock.png)
_Kanagawa_

 ![lumon](../themes/lumon/preview-unlock.png)
_Lumon_

 ![matte-black](../themes/matte-black/preview-unlock.png)
_Matte Black_

![miasma](../themes/miasma/preview-unlock.png)
_Miasma_

 ![nord](../themes/nord/preview-unlock.png)
_Nord_

 ![retro-82](../themes/retro-82/preview-unlock.png)
_Retro 82_

 ![ristretto](../themes/ristretto/preview-unlock.png)
_Ristretto_

![rose-pine](../themes/rose-pine/preview-unlock.png)
_Rose Pine_

 ![tokyo-night](../themes/tokyo-night/preview-unlock.png)
_Tokyo Night_

 ![vantablack](../themes/vantablack/preview-unlock.png)
_Vantablack_

 ![white](../themes/white/preview-unlock.png)
_White_
