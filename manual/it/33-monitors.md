# Monitor

Omarchy presuppone per impostazione predefinita che tu stia usando un display di classe retina con capacità 2x. È ciò che ti serve per ottenere quei bei caratteri da programmatore nitidi. È ciò per cui sono ottimizzati quasi tutti i nuovi laptop premium con schermi ad alta risoluzione. È ciò che vorresti usare su un 27" 5K [Apple Studio Display](https://www.apple.com/studio-display/)/[ProArt PA27JCV](https://www.asus.com/us/displays-desktops/monitors/proart/proart-display-5k-pa27jcv/)/[Samsung S9](https://www.samsung.com/us/computing/monitors/5k/27-viewfinity-s9-5k-monitor-with-thunderbolt-4-matte-display-and-smart-features-ls27c900panxza/)/[Kuycon G27P](https://kuycon.us/monitors/G27P/) o 32" 6K [Apple XDR](https://www.apple.com/pro-display-xdr/)/[ProArt PA32QCV](https://www.asus.com/displays-desktops/monitors/proart/proart-display-6k-pa32qcv/)/[Kuycon G32P](https://kuycon.us/monitors/G32P/).

Ma se non stai usando un display con un PPI pari o superiore a 218, vorrai modificare le impostazioni del monitor. Ad esempio, se hai un 4K da 27" o 32", puoi scegliere una scala frazionaria per esso dal pannello del monitor nella barra superiore, oppure impostare il valore predefinito per ogni monitor aprendo `~/.config/hypr/monitors.lua` e passando alla raccomandazione per quella combinazione:

```lua
hl.monitor({ output = "", mode = "preferred", position = "auto", scale = 1.6 })
```

Se stai usando un display 1080p o 1440p, probabilmente vorrai semplicemente usare la scala 1x, e lo stesso per le app GTK e X11, quindi puoi usare:

```lua
hl.monitor({ output = "", mode = "preferred", position = "auto", scale = 1 })
hl.env("GDK_SCALE", "1")
```

Le modifiche a `GDK_SCALE` si applicano alle applicazioni avviate dopo la modifica (e GTK accetta solo numeri interi, quindi mantienilo all'intero più vicino alla scala del tuo monitor). Assicurati quindi di chiudere le finestre che hai sovradimensionate dopo la modifica (o chiudi tutte le finestre con `Ctrl + Alt + Del`!).

Puoi anche scorrere rapidamente i principali rapporti di scala del monitor (1x, 1.25x, 1.6x, 2x, 3x, 4x) usando `Super + /` per aumentare e `Super + Alt + /` per diminuire, oppure sceglierne uno dal pannello del monitor nella barra superiore. Questi modificano solo il monitor su cui sei focalizzato, quindi lo schermo di un laptop e un display esterno possono ciascuno avere la propria scala. Il pannello imposta anche la risoluzione, la frequenza di aggiornamento e la rotazione di ciascun monitor. Le tue scelte vengono salvate per quel monitor fisico in `~/.local/state/omarchy/monitors/settings`, quindi persistono dopo il riavvio e seguono il monitor in qualunque porta o dock venga collegato successivamente. Hanno la precedenza su qualsiasi regola per lo stesso monitor in `~/.config/hypr/monitors.lua`, che Omarchy non modifica mai. Se preferisci impostare i tuoi monitor interamente in quel file, aggiungi `omarchy_monitor_panel_settings = false` al suo interno, e le modifiche del pannello dureranno solo fino al ricaricamento di Hyprland. Poiché `GDK_SCALE` è un unico valore per tutti gli schermi, una scala scelta lo imposta a partire dal monitor con la scala più bassa, in modo che le app X11 risultino un po' piccole sullo schermo più denso anziché sovradimensionate sull'altro.

### Ingrandire o rimpicciolire il testo

La scala del monitor modifica la dimensione di tutto. Se tutto ciò che vuoi è un _testo_ più grande o più piccolo, c'è un'unica manopola per farlo:

```
omarchy display text size 14
```

Richiede una dimensione in pixel compresa tra 9 e 20, e sposta insieme la shell di Omarchy, le applicazioni GTK e il tuo terminale, in modo che l'intero desktop resti in proporzione. Eseguilo senza argomenti per vedere a che punto sei, e `omarchy display text size reset` per tornare al valore predefinito. Foot è l'unico ritardatario: non ha modo di ricaricare la sua configurazione, quindi i terminali in esecuzione mantengono la vecchia dimensione finché non ne apri uno nuovo.

### Estendere e duplicare gli schermi del laptop

Quando colleghi uno schermo esterno al tuo laptop, il display viene automaticamente esteso. Ma puoi invece cambiarlo in duplicazione con _Extend_ | _Mirror_ nel pannello del monitor nella barra superiore, _Trigger > Hardware_ nel menu di Omarchy, o `Super + Ctrl + Alt + Delete`. Questo è particolarmente utile se quello schermo esterno è un proiettore, e vuoi mostrare qualcosa mentre lavori.

Quando stai estendendo, chiudere il coperchio del laptop spegnerà automaticamente lo schermo interno. Aprendo il coperchio lo riaccenderai. Puoi anche controllarlo manualmente usando _Trigger > Hardware_ nel menu di Omarchy o `Super + Ctrl + Delete`.

### Disporre più schermi

Hyprland funziona benissimo con più schermi. Il pannello del monitor nella barra superiore li disegna dove si trovano: trascinane uno contro il lato di un altro per spostarlo lì, e la disposizione viene salvata insieme alle altre impostazioni di ciascun monitor. Per qualsiasi cosa il pannello non copra, leggi di più su come disporli nella [documentazione sui monitor di Hyprland](https://wiki.hypr.land/Configuring/Basics/Monitors/). In Omarchy, questi vanno in `~/.config/hypr/monitors.lua` come voci `hl.monitor` — il file viene fornito con esempi commentati per mantenere un monitor spento, modalità che il pannello non offre, colore a 10-bit e frequenza di aggiornamento variabile.

Ogni monitor ha i propri spazi di lavoro da 1 a 10, quindi `Super + 1` significa sempre il primo spazio di lavoro del monitor su cui ti trovi. Dietro le quinte, Hyprland numera comunque gli spazi di lavoro su tutti i monitor: lo schermo del tuo laptop (o il primo monitor) ottiene 1–10, il monitor successivo 11–20, e così via, e ciascun monitor mantiene il suo blocco ogni volta che lo colleghi. Usa quei numeri se scrivi [regole per gli spazi di lavoro](https://wiki.hypr.land/Configuring/Basics/Workspace-Rules/) o regole per le finestre per un monitor specifico, così lo spazio di lavoro 12 è il secondo spazio di lavoro del tuo secondo monitor. `~/.local/state/omarchy/monitors/workspaces` elenca quale blocco ha ciascun monitor.

I tasti freccia funzionano tra monitor che condividono un bordo nella tua disposizione. Gli schermi che si toccano solo in un angolo, o che hanno uno spazio tra loro, non sono vicini, quindi usa `Ctrl + Alt + Tab` per spostarti tra loro.

| Scorciatoia | Tra i monitor |
| --- | --- |
| `Super + Arrow` | Sposta il focus sul monitor su quel lato una volta che non c'è più nessuna finestra in quella direzione |
| `Super + Shift + Arrow` | Scambia con una finestra sul monitor su quel lato |
| `Super + Alt + Arrow` | Sposta la finestra in un gruppo sul monitor su quel lato |
| `Super + Shift + Ctrl + Arrow` | Sposta la finestra sul monitor su quel lato, sullo spazio di lavoro che sta mostrando |
| `Super + Shift + Alt + Arrow` | Sposta lo spazio di lavoro sul monitor su quel lato, mantenendone il numero se è libero |
| `Ctrl + Alt + Tab` / `Ctrl + Alt + Shift + Tab` | Sposta il focus sul monitor successivo o precedente, qualunque sia la disposizione |
| `Super + 1-0`, `Super + Tab`, `Super + Scroll Wheel` | Restano sul monitor su cui ti trovi |

Puoi anche dare un'occhiata a [Hyprmon](https://github.com/erans/hyprmon/), se vuoi una TUI che ti aiuti con il posizionamento di più schermi.

### Controllare la luminosità

La luminosità del monitor è controllata dai tasti funzione dedicati per aumentare/diminuire la luminosità. Se tieni premuto shift mentre premi questi tasti, andrai alla luminosità massima o minima. I tasti controllano il display su cui sei focalizzato, quindi i monitor esterni che parlano DDC/CI vengono regolati allo stesso modo dello schermo del laptop.

### Display Apple

Se stai usando un display Apple, i normali tasti della tastiera per la luminosità funzioneranno anche automaticamente, se sei focalizzato sul display Apple. Questo avviene tramite il comando `asdcontrol`.

Nota che se stai usando un display Apple 6K XDR, potresti vedere uno schermo fantasma nel tuo elenco `hyprctl monitors`. Puoi disattivarlo con qualcosa come `hl.monitor({ output = "DP-2", disabled = true })` in `~/.config/hypr/monitors.lua`.

Sulle macchine Intel, dovresti collegarti ai display Apple usando un normale cavo Thunderbolt. Sulle altre macchine senza Thunderbolt, in genere dovrai usare un [cavo DP + USB-A -> USB-C](https://www.amazon.com/dp/B0BNX7MS6N) per farlo funzionare.
