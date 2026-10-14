# Monitor

Omarchy presuppone per impostazione predefinita che tu stia usando un display di classe retina con capacità 2x. È ciò che ti serve per ottenere quei bei caratteri da programmatore nitidi. È ciò per cui sono ottimizzati quasi tutti i nuovi portatili premium con schermi ad alta risoluzione. È ciò che vorresti usare su un 27" 5K [Apple Studio Display](https://www.apple.com/studio-display/)/[ProArt PA27JCV](https://www.asus.com/us/displays-desktops/monitors/proart/proart-display-5k-pa27jcv/)/[Samsung S9](https://www.samsung.com/us/computing/monitors/5k/27-viewfinity-s9-5k-monitor-with-thunderbolt-4-matte-display-and-smart-features-ls27c900panxza/)/[Kuycon G27P](https://kuycon.us/monitors/G27P/) o un 32" 6K [Apple XDR](https://www.apple.com/pro-display-xdr/)/[ProArt PA32QCV](https://www.asus.com/displays-desktops/monitors/proart/proart-display-6k-pa32qcv/)/[Kuycon G32P](https://kuycon.us/monitors/G32P/).

Ma se non stai usando un display con un PPI di 218 o superiore, vorrai cambiare le impostazioni del monitor. Ad esempio, se hai un 4K da 27" o 32", puoi usare il ridimensionamento frazionario aprendo `~/.config/hypr/monitors.lua` (tramite _Impostazioni > Monitor_ nel menu Omarchy) e passando alla raccomandazione per quella combinazione:

```lua
local omarchy_gdk_scale = 2
local omarchy_monitor_scale = 1.6
```

Se stai usando un display 1080p o 1440p, probabilmente vorrai semplicemente usare il ridimensionamento 1x, quindi puoi usare:

```lua
local omarchy_gdk_scale = 1
local omarchy_monitor_scale = 1
```

Le modifiche a `GDK_SCALE` si applicano alle applicazioni avviate dopo la modifica (e GTK onora solo numeri interi, quindi mantienilo all'intero più vicino alla scala del tuo monitor). Assicurati quindi di chiudere le finestre sovradimensionate che hai dopo la modifica (oppure chiudi tutte le finestre con `Ctrl + Alt + Del`!).

Puoi anche scorrere rapidamente i principali rapporti di ridimensionamento del monitor (1x, 1.25x, 1.6x, 2x, 3x, 4x) usando `Super + /` per salire e `Super + Alt + /` per scendere. Se hai la configurazione predefinita, queste modifiche persisteranno anche dopo il riavvio.

### Ingrandire o rimpicciolire il testo

Il ridimensionamento del monitor cambia la dimensione di tutto. Se tutto ciò che vuoi è un _testo_ più grande o più piccolo, c'è una singola manopola per questo:

```
omarchy display text size 14
```

Questo accetta una dimensione in pixel tra 9 e 20 e sposta insieme la shell Omarchy, le applicazioni GTK e il tuo terminale, così l'intero desktop resta in proporzione. Eseguila senza argomenti per vedere dove sei, e `omarchy display text size reset` per tornare al predefinito. Foot è l'unico ritardatario: non ha modo di ricaricare la sua configurazione, quindi i terminali in esecuzione mantengono la vecchia dimensione finché non ne apri uno nuovo.

### Estendere e duplicare gli schermi dei portatili

Quando colleghi uno schermo esterno al tuo portatile, il display viene esteso automaticamente. Ma puoi cambiare questa impostazione in duplicazione usando _Azioni > Hardware_ nel menu Omarchy oppure `Super + Ctrl + Alt + Delete`. Questo è particolarmente utile se quello schermo esterno è un proiettore e vuoi mostrare qualcosa mentre lavori.

Quando stai estendendo, chiudere il coperchio del portatile spegnerà automaticamente lo schermo interno. Aprire il coperchio lo riaccenderà. Puoi anche controllare questo manualmente usando _Azioni > Hardware_ nel menu Omarchy oppure `Super + Ctrl + Delete`.

### Disporre più schermi

Hyprland funziona ottimamente con più schermi. Leggi di più su come disporli nella [documentazione sui monitor di Hyprland](https://wiki.hypr.land/Configuring/Basics/Monitors/). Puoi anche [associare workspace specifici a monitor specifici](https://wiki.hypr.land/Configuring/Basics/Workspace-Rules/). In Omarchy, queste regole vanno in `~/.config/hypr/monitors.lua` come voci `hl.monitor` — il file viene fornito con esempi commentati per fissare un monitor specifico a una risoluzione, posizione e rotazione.

Puoi anche dare un'occhiata a [Hyprmon](https://github.com/erans/hyprmon/), se vuoi una TUI che ti aiuti con il posizionamento di più schermi.

### Controllare la luminosità

La luminosità del monitor è controllata dai tasti funzione dedicati per aumentare/diminuire la luminosità. Se tieni premuto shift mentre li premi, andrai alla luminosità massima o minima. I tasti controllano il display su cui sei focalizzato, quindi i monitor esterni che parlano DDC/CI vengono regolati allo stesso modo dello schermo del portatile.

### Display Apple

Se stai usando un display Apple, i normali tasti di luminosità della tastiera funzioneranno anche automaticamente, se sei focalizzato sul display Apple. Questo avviene tramite il comando `asdcontrol`.

Nota che se stai usando un display Apple 6K XDR, potresti vedere uno schermo fantasma nell'elenco di `hyprctl monitors`. Puoi disattivarlo con qualcosa come `hl.monitor({ output = "DP-2", disabled = true })` tramite _Impostazioni > Monitor_.

Sulle macchine Intel, dovresti collegarti ai display Apple usando un normale cavo Thunderbolt. Su altre macchine senza Thunderbolt, in genere dovrai usare un [cavo DP + USB-A -> USB-C](https://www.amazon.com/dp/B0BNX7MS6N) per farlo funzionare.
