# Interruttori, inattività e lo screensaver

Molto di ciò che modifichi giorno per giorno non è davvero un'impostazione. È una modalità che attivi per un'ora e poi disattivi di nuovo: la luce notturna mentre lavori fino a tardi, il non disturbare mentre fai una presentazione, resta attivo mentre guardi qualcosa. Omarchy li chiama interruttori, e funzionano tutti allo stesso modo: una scorciatoia, una voce di menu e un comando, tutti sullo stesso interruttore.

### Il menu degli interruttori

`Super + Ctrl + O` apre direttamente _Trigger > Toggle_, oppure puoi arrivarci dal menu di Omarchy (`Super + Space`). Tutto ciò che trovi in quell'elenco è un interruttore che puoi attivare o disattivare senza pensare a dove risiede lo stato. Gli interruttori per l'aspetto del desktop si trovano accanto, in _Appearance_.

Dal terminale, gli stessi interruttori sono `omarchy toggle <thing>`. Esegui `omarchy toggle` da solo per vedere l'intero gruppo.

| Interruttore | Scorciatoia | Comando |
| ------ | ------ | ------- |
| Luce notturna | — | `omarchy toggle nightlight` |
| Silenzia le notifiche | `Super + Ctrl + Alt + ,` | `omarchy toggle notification silencing` |
| Resta attivo (nessun blocco per inattività) | `Super + Ctrl + I` | `omarchy toggle idle` |
| Cattura dei crash | — | `omarchy toggle crash-capture` |
| Screensaver | — | `omarchy toggle screensaver` |
| [Herdr](https://herdr.dev) sincronizzazione del tema | — | `omarchy toggle theme sync` |
| Barra dei menu | `Super + Shift + Space` | `omarchy toggle bar` |
| Touchpad | `XF86TouchpadToggle` | `omarchy toggle touchpad` |
| Touchscreen | — | `omarchy toggle touchscreen` |
| Sospensione | — | `omarchy toggle suspend` |
| GPU ibrida | — | `omarchy toggle hybrid gpu` |

Gli interruttori per touchpad, touchscreen e GPU ibrida si trovano in _Trigger > Hardware_ (`Super + Ctrl + H`) invece che in Toggle, perché compaiono solo quando hai effettivamente quell'hardware. Quelli per touchpad e touchscreen sopravvivono a un ricaricamento di Hyprland: il nome del dispositivo disattivato viene salvato in un piccolo file di stato che Hyprland legge all'avvio per disattivarlo di nuovo.

_Appearance_ contiene la barra dei menu e le animazioni, oltre ad alcune cose che non sono comandi `omarchy toggle` ma si comportano allo stesso modo: la percentuale della batteria nella barra, il layout predefinito dell'area di lavoro e, in _Windows_, gli spazi tra le finestre (`Super + Shift + Backspace`) e le proporzioni quadrate per 1 finestra (`Super + Ctrl + Backspace`).

La maggior parte di questi è semplicemente un file flag in `~/.local/state/omarchy/toggles/`. Se vuoi usarne uno in uno script per una condizione, `omarchy-toggle-enabled` ti dà un codice di uscita invece di costringerti a cercarlo:

```bash
omarchy-toggle-enabled screensaver-off && echo "screensaver is off"
```

I flag prendono il nome dallo stato disattivato — `screensaver-off`, `suspend-off`, `bar-off` — quindi la loro presenza significa che la funzione è disattivata.

### Indicatori nella barra

Quando una modalità è attiva, vedi un piccolo glifo al centro della barra superiore, accanto all'orologio. È il widget degli indicatori e contiene dettatura, registrazione dello schermo, promemoria in sospeso, luce notturna, non disturbare e resta attivo.

Gli indicatori inattivi sono nascosti. Passa il mouse in un punto qualsiasi della barra e compaiono attenuati, così puoi far clic su uno per attivarlo senza conoscerne la scorciatoia. Facendo clic su uno attivo lo disattivi di nuovo. Se preferisci vederli tutti sempre, imposta `alwaysShow` su `true` nella voce `omarchy.indicators` in `~/.config/omarchy/shell.json`: vedi [la barra superiore](05-the-top-bar.md) per scoprire come si configurano i widget della barra.

### Luce notturna

La luce notturna riscalda lo schermo a 4000K e, attivandola di nuovo, lo riporta a 6500K. Attivala dal menu degli interruttori (`Super + Ctrl + O`) o con `omarchy toggle nightlight`. È gestita da hyprsunset, che l'interruttore avvia per te se non è già in esecuzione.

Per impostazione predefinita, hyprsunset non fa assolutamente nulla al tuo schermo. `~/.config/hypr/hyprsunset.conf` include un profilo identità proprio per lasciare il display intatto finché non chiedi un po' di calore. Se preferisci che cambi in base all'orologio, sostituiscilo con un profilo orario:

```
profile {
    time = 20:00
    temperature = 4000
}
```

Poi avvia hyprsunset all'accesso aggiungendo `o.launch_on_start("hyprsunset")` a `~/.config/hypr/autostart.lua`. La coppia 4000K/6500K usata dall'interruttore è fissa, quindi il file di configurazione è il posto giusto se vuoi una temperatura diversa.

### Non disturbare

`Super + Ctrl + Alt + ,` silenzia le notifiche. Mentre è attivo non compare nessun toast e l'indicatore della campana barrata resta nella barra per ricordarti perché il desktop è diventato silenzioso.

Non si perde nulla, però. Le notifiche silenziate vengono trattenute: rimetti le ultime sullo schermo con `Super + Shift + Alt + ,`. Vedi [avvisi](10-notices.md) per il resto.

Due tipi di messaggi riescono comunque a passare: i toast di conferma di Omarchy per qualcosa che hai appena fatto ("Theme changed", "Screenshot saved") e gli avvisi critici inviati da riga di comando. Le app di chat che contrassegnano tutto come critico per imporsi davanti a te non contano.

### Inattività

La shell di Omarchy gestisce il comportamento in inattività e i tempi sono un blocco `idle` di primo livello in `~/.config/omarchy/shell.json`:

```json
{
  "version": 1,
  "idle": {
    "screensaver": 150,
    "lock": 300
  }
}
```

Entrambi i numeri sono secondi contati dal momento in cui sei diventato inattivo, non l'uno dall'altro. Quindi, con le impostazioni predefinite, lo screensaver compare dopo due minuti e mezzo e la schermata di blocco subentra a cinque minuti, che lo screensaver sia partito o no. Salva il file e la shell acquisisce subito i nuovi tempi.

Se chiudi lo screensaver prima della scadenza del blocco, conta come attività e il blocco in sospeso viene annullato. Non vieni bloccato fuori solo per aver dato un'occhiata alla macchina.

Per smettere del tutto di bloccare in inattività, `Super + Ctrl + I` — oppure `omarchy toggle idle` — attiva resta attivo e nella barra compare l'indicatore della tazzina di caffè. È quello da premere prima di una lunga presentazione o di una build che vuoi osservare. Premilo di nuovo per tornare alla normalità. `omarchy toggle idle status` stampa lo stato attuale in JSON se ti serve da uno script.

Qui si parla di blocco e screensaver, non di alimentazione. Sospensione e ibernazione hanno la loro configurazione in [sospensione del sistema](36-system-sleep.md).

### Lo screensaver

Lo screensaver di Omarchy è arte ASCII sottoposta a effetti di testo casuali, un'istanza per monitor. Qualsiasi tasto o movimento del mouse lo chiude.

Puoi avviarlo su richiesta da _System > Screensaver_ (`Super + Esc`), che lo forza anche se hai disattivato lo screensaver per inattività. Per impostazione predefinita non ha una scorciatoia associata.

`omarchy toggle screensaver` è ciò che disattiva quello per inattività, se preferisci passare direttamente dal lavoro al blocco. Ha bisogno di un terminale che sa come configurare — Alacritty, Foot, Ghostty o Kitty — e te lo dirà se il tuo terminale predefinito è qualcos'altro.

Il logo che disegna puoi cambiarlo tu, in _Appearance > Branding > Screensaver_. Carica un png o un svg e Omarchy lo converte in ASCII. Vedi [identità visiva](41-branding.md).

### La schermata di blocco

`Super + Ctrl + L` blocca la macchina. Questo avvia la schermata di blocco dalla shell di Omarchy, oscura il display, reimposta il layout della tastiera sul primo in modo da non digitare la password nell'alfabeto sbagliato e, se è in esecuzione, blocca 1Password all'uscita.

La schermata di blocco accetta una password e accetterà anche un'impronta digitale una volta che ne avrai configurata una. Questo e gli altri modi per autenticarti sono trattati in [autenticazione hardware](37-hardware-authentication.md).
