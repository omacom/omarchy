# Monitor

Omarchy presuppone per impostazione predefinita che tu stia usando un display di classe retina con supporto 2x. È ciò che ti serve per ottenere quei bei caratteri da programmatore nitidi. È ciò per cui sono ottimizzati quasi tutti i nuovi laptop premium con schermi ad alta risoluzione. È ciò che vorresti usare su un [Apple Studio Display](https://www.apple.com/studio-display/)/[ProArt PA27JCV](https://www.asus.com/us/displays-desktops/monitors/proart/proart-display-5k-pa27jcv/)/[Samsung S9](https://www.samsung.com/us/computing/monitors/5k/27-viewfinity-s9-5k-monitor-with-thunderbolt-4-matte-display-and-smart-features-ls27c900panxza/)/[Kuycon G27P](https://kuycon.us/monitors/G27P/) da 27" 5K o un [Apple XDR](https://www.apple.com/pro-display-xdr/)/[ProArt PA32QCV](https://www.asus.com/displays-desktops/monitors/proart/proart-display-6k-pa32qcv/)/[Kuycon G32P](https://kuycon.us/monitors/G32P/) da 32" 6K.

Ma se non stai usando un display con un PPI di 218 o superiore, vorrai cambiare le impostazioni del monitor. Ad esempio, se hai un 4K da 27" o 32", puoi usare il ridimensionamento frazionario aprendo `~/.config/hypr/monitors.lua` (tramite _Setup > Monitors_ nel menu di Omarchy) e passando alla raccomandazione per quella combinazione:

```lua
local omarchy_gdk_scale = 2
local omarchy_monitor_scale = 1.6
```

Se stai usando un display 1080p o 1440p, probabilmente vorrai semplicemente usare il ridimensionamento 1x, quindi puoi usare:

```lua
local omarchy_gdk_scale = 1
local omarchy_monitor_scale = 1
```

Le modifiche a `GDK_SCALE` si applicano alle applicazioni avviate dopo la modifica (e GTK accetta solo numeri interi, quindi mantienilo al numero intero più vicino alla scala del tuo monitor). Assicurati quindi di chiudere le finestre che hai sovradimensionate dopo la modifica (o chiudi tutte le finestre con `Ctrl + Alt + Del`!).

Puoi anche scorrere rapidamente i principali rapporti di ridimensionamento del monitor (1x, 1.25x, 1.6x, 2x, 3x, 4x) usando `Super + /` per salire e `Super + Alt + /` per scendere, oppure sceglierne uno dal pannello del monitor nella barra superiore. Questi modificano solo il monitor su cui sei focalizzato, quindi lo schermo di un laptop e un display esterno possono ciascuno avere la propria scala. La scelta viene salvata in `~/.config/hypr/monitors.lua` come regola `hl.monitor` per quel monitor, quindi persiste dopo il riavvio e ha la precedenza su `omarchy_monitor_scale`, che rimane la scala per ogni monitor senza una regola propria.

### Ingrandire o rimpicciolire il testo

Il ridimensionamento del monitor cambia la dimensione di tutto. Se tutto ciò che vuoi è un _testo_ più grande o più piccolo, c'è una singola manopola per quello:

```
omarchy display text size 14
```

Accetta una dimensione in pixel tra 9 e 20, e sposta insieme la shell di Omarchy, le applicazioni GTK e il tuo terminale, così l'intero desktop resta in proporzione. Eseguilo senza argomenti per vedere a che punto sei, e `omarchy display text size reset` per tornare al valore predefinito. Foot è l'unico ritardatario: non ha modo di ricaricare la sua configurazione, quindi i terminali in esecuzione mantengono la loro vecchia dimensione finché non ne apri uno nuovo.

### Estendere e duplicare gli schermi del laptop

Quando colleghi uno schermo esterno al tuo laptop, il display viene esteso automaticamente. Ma puoi cambiarlo in duplicazione usando invece _Trigger > Hardware_ nel menu di Omarchy o `Super + Ctrl + Alt + Delete`. Questo è particolarmente utile se quello schermo esterno è un proiettore, e vuoi mostrare qualcosa mentre lavori.

Quando stai estendendo, chiudere il coperchio del laptop spegnerà automaticamente lo schermo interno. Aprire il coperchio lo riaccenderà. Puoi anche controllarlo manualmente usando _Trigger > Hardware_ nel menu di Omarchy o `Super + Ctrl + Delete`.

### Disporre più schermi

Hyprland funziona benissimo con più schermi. Leggi di più su come disporli nella [documentazione sui monitor di Hyprland](https://wiki.hypr.land/Configuring/Basics/Monitors/). In Omarchy, questi vanno in `~/.config/hypr/monitors.lua` come voci `hl.monitor` — il file viene fornito con esempi commentati per fissare un monitor specifico a una risoluzione, posizione e rotazione.

Ogni monitor ha i propri workspace da 1 a 10, quindi `Super + 1` significa sempre il primo workspace del monitor su cui ti trovi. Dietro le quinte, Hyprland numera comunque i workspace su tutti i monitor: lo schermo del tuo laptop (o il primo monitor) riceve 1–10, il monitor successivo 11–20, e così via, e ogni monitor mantiene il suo blocco ogni volta che lo colleghi. Usa quei numeri se scrivi [regole per i workspace](https://wiki.hypr.land/Configuring/Basics/Workspace-Rules/) o regole per le finestre per un monitor specifico, quindi il workspace 12 è il secondo workspace del tuo secondo monitor. `~/.local/state/omarchy/monitor-workspaces` elenca quale blocco ha ciascun monitor.

I tasti freccia funzionano tra monitor che condividono un bordo nella tua disposizione. Gli schermi che si toccano solo in un angolo, o che hanno uno spazio tra loro, non sono vicini, quindi usa `Ctrl + Alt + Tab` per passare da uno all'altro.

| Tasto di scelta rapida | Tra monitor |
| --- | --- |
| `Super + Arrow` | Sposta il focus sul monitor su quel lato quando non c'è più nessuna finestra in quella direzione |
| `Super + Shift + Arrow` | Scambia con una finestra sul monitor su quel lato |
| `Super + Alt + Arrow` | Sposta la finestra in un gruppo sul monitor su quel lato |
| `Super + Shift + Ctrl + Arrow` | Sposta la finestra sul monitor su quel lato, sul workspace che sta mostrando |
| `Super + Shift + Alt + Arrow` | Sposta il workspace sul monitor su quel lato, mantenendo il suo numero se è libero |
| `Ctrl + Alt + Tab` / `Ctrl + Alt + Shift + Tab` | Sposta il focus sul monitor successivo o precedente, qualunque sia la disposizione |
| `Super + 1-0`, `Super + Tab`, `Super + Scroll Wheel` | Restano sul monitor su cui ti trovi |

Puoi anche dare un'occhiata a [Hyprmon](https://github.com/erans/hyprmon/), se vuoi una TUI che ti aiuti con il posizionamento di più schermi.

### Controllare la luminosità

La luminosità del monitor è controllata dai tasti funzione dedicati per aumentare/diminuire la luminosità. Se tieni premuto shift mentre premi questi tasti, andrai alla luminosità massima o minima. I tasti controllano il display su cui sei focalizzato, quindi i monitor esterni che parlano DDC/CI vengono regolati allo stesso modo dello schermo del laptop.

### Display Apple

Se stai usando un display Apple, i normali tasti di luminosità della tastiera funzioneranno anche automaticamente, se sei focalizzato sul display Apple. Questo avviene tramite il comando `asdcontrol`.

Nota che se stai usando un display Apple 6K XDR, potresti vedere uno schermo fantasma nel tuo elenco `hyprctl monitors`. Puoi disattivarlo con qualcosa come `hl.monitor({ output = "DP-2", disabled = true })` tramite _Setup > Monitors_.

Sulle macchine Intel, dovresti collegarti ai display Apple usando un normale cavo Thunderbolt. Su altre macchine senza Thunderbolt, in genere dovrai usare un [cavo DP + USB-A -> USB-C](https://www.amazon.com/dp/B0BNX7MS6N) per farlo funzionare.
