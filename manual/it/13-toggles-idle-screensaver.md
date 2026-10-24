# Attiva/Disattiva, inattività e salvaschermo

Gran parte di ciò che cambi giorno per giorno non è davvero un'impostazione. È una modalità che attivi per un'ora e poi disattivi: luce notturna mentre lavori fino a tardi, non disturbare mentre presenti, resta attivo mentre guardi qualcosa. Omarchy li chiama attiva/disattiva, e funzionano tutti allo stesso modo — una scorciatoia, una voce di menu e un comando, tutti che colpiscono lo stesso interruttore.

### Il menu attiva/disattiva

`Super + Ctrl + O` apre direttamente _Azioni > Attiva/Disattiva_, oppure puoi arrivarci dal menu Omarchy (`Super + Space`). Tutto in quell'elenco è un interruttore che puoi azionare senza pensare a dove vive lo stato. Gli interruttori per l'aspetto del desktop stanno accanto, sotto _Azioni > Aspetto_.

Da terminale, gli stessi interruttori sono `omarchy toggle <thing>`. Esegui `omarchy toggle` da solo per vedere l'intero gruppo.

| Attiva/Disattiva | Scorciatoia | Comando |
| ------ | ------ | ------- |
| Luce notturna | `Super + Ctrl + N` | `omarchy toggle nightlight` |
| Silenzia notifiche | `Super + Ctrl + ,` | `omarchy toggle notification silencing` |
| Resta attivo (nessun blocco su inattività) | `Super + Ctrl + I` | `omarchy toggle idle` |
| Cattura crash | — | `omarchy toggle crash-capture` |
| Salvaschermo | — | `omarchy toggle screensaver` |
| Sincronia tema [Herdr](https://herdr.dev) | — | `omarchy toggle theme sync` |
| Barra menu | `Super + Shift + Space` | `omarchy toggle bar` |
| Touchpad | `XF86TouchpadToggle` | `omarchy toggle touchpad` |
| Touchscreen | — | `omarchy toggle touchscreen` |
| Sospendi | — | `omarchy toggle suspend` |
| Hybrid GPU | — | `omarchy toggle hybrid gpu` |

Gli interruttori touchpad, touchscreen e Hybrid GPU vivono sotto _Azioni > Hardware_ (`Super + Ctrl + H`) invece che sotto Attiva/Disattiva, poiché compaiono solo quando hai effettivamente quell'hardware. Quelli touchpad e touchscreen sopravvivono a un ricaricamento di Hyprland — il nome del dispositivo disabilitato viene salvato in un piccolo file di stato che Hyprland legge all'avvio per disabilitarlo di nuovo.

_Azioni > Aspetto_ contiene la barra menu e le animazioni, più alcune cose che non sono comandi `omarchy toggle` ma si comportano allo stesso modo: percentuale batteria nella barra, il layout workspace predefinito, gli spazi finestre (`Super + Shift + Backspace`) e la proporzione quadrata a 1 finestra (`Super + Ctrl + Backspace`).

La maggior parte di questi è solo un file flag sotto `~/.local/state/omarchy/toggles/`. Se vuoi diramare su uno in uno script, `omarchy-toggle-enabled` ti dà un codice di uscita invece di farti andare a cercare:

```bash
omarchy-toggle-enabled screensaver-off && echo "screensaver is off"
```

I flag sono chiamati per lo stato spento — `screensaver-off`, `suspend-off`, `bar-off` — quindi la loro presenza significa che la funzione è disabilitata.

### Indicatori nella barra

Quando una modalità è attiva, ottieni un piccolo glifo al centro della barra superiore accanto all'orologio. Quello è il widget indicatori, e trasporta dettatura, registrazione schermo, promemoria in sospeso, luce notturna, non disturbare e resta attivo.

Gli indicatori inattivi sono nascosti. Passa il mouse nell'area attorno a essi e compaiono attenuati, così puoi cliccarne uno per attivarlo senza conoscerne la scorciatoia. Cliccando uno attivo lo spegne di nuovo. Se preferisci vederli tutti sempre, imposta `alwaysShow` a `true` sulla voce `omarchy.indicators` in `~/.config/omarchy/shell.json` — vedi [la barra superiore](05-the-top-bar.md) per come si configurano i widget della barra.

### Luce notturna

`Super + Ctrl + N` riscalda lo schermo a 4000K, e premerlo di nuovo lo riporta a 6500K. È guidato da hyprsunset, che l'interruttore avvia per te se non è già in esecuzione.

Per impostazione predefinita hyprsunset non fa assolutamente nulla allo schermo. `~/.config/hypr/hyprsunset.conf` viene fornito con un profilo identità proprio perché il display resti intatto finché non chiedi calore. Se preferisci che cambi in base all'orologio, sostituiscilo con un profilo orario:

```
profile {
    time = 20:00
    temperature = 4000
}
```

Poi avvia hyprsunset all'accesso aggiungendo `o.launch_on_start("hyprsunset")` a `~/.config/hypr/autostart.lua`. La coppia 4000K/6500K usata dall'interruttore è fissa, quindi il file di configurazione è dove vai se vuoi una temperatura diversa.

### Non disturbare

`Super + Ctrl + ,` silenzia le notifiche. Nessun toast compare mentre è attivo, e l'indicatore campana barrata sta nella barra per ricordarti perché il desktop è diventato silenzioso.

Nulla va perso, però. Una notifica silenziata viene scritta direttamente nella cronologia notifiche, che è esattamente il registro che vuoi quando torni e ti chiedi cosa ti sei perso. Aprila con `Super + Shift + Alt + ,`. Vedi [avvisi](10-notices.md) per il resto della storia delle notifiche.

Due tipi di messaggio passano comunque: i toast di conferma di Omarchy per qualcosa che hai appena fatto ("Theme changed", "Screenshot saved"), e gli avvisi critici inviati da riga di comando. Le app di chat che segnano tutto come critico per farsi strada davanti a te non rientrano.

### Inattività

La shell di Omarchy possiede il comportamento di inattività, e le tempistiche sono un blocco `idle` di livello superiore in `~/.config/omarchy/shell.json`:

```json
{
  "version": 1,
  "idle": {
    "screensaver": 150,
    "lock": 300
  }
}
```

Entrambi i numeri sono secondi contati dal momento in cui sei diventato inattivo — non l'uno dall'altro. Quindi con le impostazioni predefinite, il salvaschermo compare dopo due minuti e mezzo e la schermata di blocco subentra a cinque minuti, che il salvaschermo sia partito o no. Salva il file e la shell raccoglie subito le nuove tempistiche.

Se chiudi il salvaschermo prima della scadenza del blocco, quello conta come attività e il blocco in sospeso viene annullato. Non vieni bloccato fuori per aver dato un'occhiata alla macchina.

Per smettere del tutto di bloccare su inattività, `Super + Ctrl + I` — o `omarchy toggle idle` — attiva resta attivo, e l'indicatore tazza di caffè appare nella barra. È quello da premere prima di una lunga presentazione o di una build che vuoi guardare. Premilo di nuovo per tornare alla normalità. `omarchy toggle idle status` stampa lo stato corrente come JSON se ti serve da uno script.

Questo riguarda blocco e salvaschermo, non l'alimentazione. Sospensione e ibernazione hanno la loro configurazione in [sospensione di sistema](36-system-sleep.md).

### Il salvaschermo

Il salvaschermo di Omarchy è arte ASCII che scorre attraverso effetti di testo casuali, un'istanza per monitor. Qualsiasi tasto o movimento del mouse ne esce.

Puoi avviarlo su richiesta da _Sistema > Salvaschermo_ (`Super + Esc`), che lo forza anche se hai disattivato il salvaschermo su inattività. Non c'è nessuna scorciatoia legata a esso per impostazione predefinita.

`omarchy toggle screensaver` è ciò che spegne quello su inattività, se preferisci andare dritto dal lavorare al bloccato. Ha bisogno di un terminale che sa configurare — Alacritty, Foot, Ghostty o Kitty — e te lo dirà se il tuo terminale predefinito è qualcos'altro.

Il logo che disegna è tuo da cambiare, sotto _Stile > Salvaschermo_. Carica un png o svg e Omarchy lo converte in ASCII. Vedi [branding](41-branding.md).

### La schermata di blocco

`Super + Ctrl + L` blocca la macchina. Questo esegue la schermata di blocco dalla shell di Omarchy, oscura il display, reimposta il layout tastiera al primo così non digiti la password nell'alfabeto sbagliato e — se lo hai in esecuzione — blocca 1Password all'uscita.

La schermata di blocco accetta una password, e accetterà anche un'impronta digitale una volta configurata. Ciò, e gli altri modi per autenticarti, sono trattati in [autenticazione hardware](37-hardware-authentication.md).
