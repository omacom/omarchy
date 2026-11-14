# Interruttori, inattività e lo screensaver

Molte delle cose che cambi giorno per giorno non sono davvero un'impostazione. Sono una modalità che attivi per un'ora e poi disattivi di nuovo: la luce notturna mentre lavori fino a tardi, il non disturbare mentre fai una presentazione, restare attivo mentre guardi qualcosa. Omarchy le chiama interruttori, e funzionano tutti allo stesso modo — una scorciatoia, una voce di menu e un comando, tutti sullo stesso interruttore.

### Il menu degli interruttori

`Super + Ctrl + O` apre direttamente _Trigger > Toggle_, oppure puoi arrivarci dal menu di Omarchy (`Super + Space`). Tutto ciò che trovi in quell'elenco è un interruttore che puoi attivare o disattivare senza pensare a dove vive lo stato. Gli interruttori per l'aspetto del desktop si trovano accanto, sotto _Appearance_.

Dal terminale, gli stessi interruttori sono `omarchy toggle <thing>`. Esegui `omarchy toggle` da solo per vedere l'intero gruppo.

| Interruttore | Scorciatoia | Comando |
| ------ | ------ | ------- |
| Luce notturna | — | `omarchy toggle nightlight` |
| Silenzia notifiche | `Super + Ctrl + Alt + ,` | `omarchy toggle notification silencing` |
| Resta attivo (nessun blocco per inattività) | `Super + Ctrl + I` | `omarchy toggle idle` |
| Cattura dei crash | — | `omarchy toggle crash-capture` |
| Screensaver | — | `omarchy toggle screensaver` |
| Sincronizzazione tema [Herdr](https://herdr.dev) | — | `omarchy toggle theme sync` |
| Barra dei menu | `Super + Shift + Space` | `omarchy toggle bar` |
| Touchpad | `XF86TouchpadToggle` | `omarchy toggle touchpad` |
| Touchscreen | — | `omarchy toggle touchscreen` |
| Sospensione | — | `omarchy toggle suspend` |
| GPU ibrida | — | `omarchy toggle hybrid gpu` |

Gli interruttori di touchpad, touchscreen e GPU ibrida si trovano sotto _Trigger > Hardware_ (`Super + Ctrl + H`) anziché sotto Toggle, perché compaiono solo quando hai davvero quell'hardware. Quelli di touchpad e touchscreen sopravvivono a un ricaricamento di Hyprland — il nome del dispositivo disabilitato viene salvato in un piccolo file di stato che Hyprland legge all'avvio per disabilitarlo di nuovo.

_Appearance_ contiene la barra dei menu e le animazioni, oltre a poche cose che non sono comandi `omarchy toggle` ma si comportano allo stesso modo: la percentuale della batteria nella barra, il layout predefinito degli spazi di lavoro e, sotto _Windows_, gli spazi tra le finestre (`Super + Shift + Backspace`) e l'aspetto quadrato a 1 finestra (`Super + Ctrl + Backspace`).

Quando Hyprland non ha una GPU con cui disegnare e renderizza invece sulla CPU (llvmpipe), come sui Mac la cui GPU non è ancora supportata, nella maggior parte delle macchine virtuali, o quando un driver grafico non si carica, Omarchy disattiva animazioni, sfocatura e ombre per quella sessione e te lo comunica una volta con una notifica. _Appearance > Animations On_ le riattiva, e Omarchy lo ricorda anche per le sessioni successive.

La maggior parte di questi è solo un file flag sotto `~/.local/state/omarchy/toggles/`. Se vuoi usarne uno in uno script, `omarchy-toggle-enabled` ti dà un codice di uscita invece di costringerti a cercarlo:

```bash
omarchy-toggle-enabled screensaver-off && echo "screensaver is off"
```

I flag prendono il nome dallo stato disattivato — `screensaver-off`, `suspend-off`, `bar-off` — quindi la loro presenza significa che la funzione è disabilitata.

### Indicatori nella barra

Quando una modalità è attiva, ottieni un piccolo glifo al centro della barra superiore, accanto all'orologio. È il widget degli indicatori, e contiene dettatura, registrazione dello schermo, promemoria in sospeso, luce notturna, non disturbare e resta attivo.

Gli indicatori inattivi sono nascosti. Passa il mouse in un punto qualsiasi della barra e compaiono attenuati, così puoi cliccarne uno per attivarlo senza conoscerne la scorciatoia. Cliccarne uno attivo lo disattiva di nuovo. Se preferisci vederli tutti sempre, imposta `alwaysShow` su `true` nella voce `omarchy.indicators` in `~/.config/omarchy/shell.json` — vedi [la barra superiore](05-the-top-bar.md) per come si configurano i widget della barra.

### Luce notturna

La luce notturna riscalda lo schermo a 4000K, e riattivandola lo riporta a 6500K. Attivala dal menu degli interruttori (`Super + Ctrl + O`) o con `omarchy toggle nightlight`. È gestita da hyprsunset, che l'interruttore avvia per te se non è già in esecuzione.

Per impostazione predefinita hyprsunset non fa assolutamente nulla al tuo schermo. `~/.config/hypr/hyprsunset.conf` viene fornito con un profilo identità proprio perché il display resti intatto finché non chiedi calore. Se preferisci che cambi in base all'orologio, sostituiscilo con un profilo orario:

```
profile {
    time = 20:00
    temperature = 4000
}
```

Avvia quindi hyprsunset all'accesso aggiungendo `o.launch_on_start("hyprsunset")` a `~/.config/hypr/autostart.lua`. La coppia 4000K/6500K usata dall'interruttore è fissa, quindi il file di configurazione è il posto giusto se vuoi una temperatura diversa.

### Non disturbare

`Super + Ctrl + Alt + ,` silenzia le notifiche. Mentre è attivo non compaiono toast, e l'indicatore con la campana barrata resta nella barra per ricordarti perché il desktop è diventato silenzioso.

Non si perde nulla, però. Le notifiche silenziate vengono trattenute: rimetti le ultime sullo schermo con `Super + Shift + Alt + ,`. Vedi [avvisi](10-notices.md) per il resto.

Due tipi di messaggi passano comunque: i toast di conferma di Omarchy per qualcosa che hai appena fatto ("Theme changed", "Screenshot saved"), e gli avvisi critici inviati da riga di comando. Le app di chat che marcano tutto come critico per forzarti la mano non rientrano in questa categoria.

### Inattività

La shell di Omarchy gestisce il comportamento in inattività, e i tempi sono un blocco `idle` di primo livello in `~/.config/omarchy/shell.json`:

```json
{
  "version": 1,
  "idle": {
    "screensaver": 150,
    "lock": 300
  }
}
```

Entrambi i numeri sono secondi contati dal momento in cui sei diventato inattivo — non l'uno dall'altro. Quindi, con i valori predefiniti, lo screensaver compare dopo due minuti e mezzo e la schermata di blocco subentra a cinque minuti, che lo screensaver sia partito o no. Salva il file e la shell acquisisce subito i nuovi tempi.

Se chiudi lo screensaver prima della scadenza del blocco, conta come attività e il blocco in sospeso viene annullato. Non resti bloccato fuori per aver dato un'occhiata alla macchina.

Per smettere del tutto di bloccare in inattività, `Super + Ctrl + I` — oppure `omarchy toggle idle` — attiva resta attivo, e nella barra compare l'indicatore con la tazzina di caffè. È quello da premere prima di una lunga presentazione o di una build che vuoi seguire. Premilo di nuovo per tornare alla normalità. `omarchy toggle idle status` stampa lo stato attuale come JSON se ti serve da uno script.

Qui si parla di blocco e screensaver, non di alimentazione. Sospensione e ibernazione hanno la loro configurazione in [sospensione del sistema](36-system-sleep.md).

### Lo screensaver

Lo screensaver di Omarchy è arte ASCII che passa attraverso effetti di testo casuali, un'istanza per monitor. Qualsiasi tasto o movimento del mouse lo chiude.

Puoi avviarlo su richiesta da _System > Screensaver_ (`Super + Esc`), che lo forza anche se hai disattivato lo screensaver per inattività. Per impostazione predefinita non c'è una scorciatoia associata.

`omarchy toggle screensaver` è ciò che disattiva quello per inattività, se preferisci passare direttamente dal lavoro al blocco. Qualsiasi tasto, clic, scorrimento o movimento del mouse lo chiude.

Il logo che disegna è tuo da cambiare, sotto _Appearance > Branding > Screensaver_. Carica un png o un svg e Omarchy lo converte in ASCII. Vedi [branding](41-branding.md).

### La schermata di blocco

`Super + Ctrl + L` blocca la macchina. Questo esegue la schermata di blocco dalla shell di Omarchy, oscura il display, reimposta il layout della tastiera sul primo in modo da non digitare la password nell'alfabeto sbagliato e — se lo hai in esecuzione — blocca 1Password all'uscita.

La schermata di blocco accetta una password, e accetterà anche un'impronta digitale una volta che ne avrai configurata una. Questo, e gli altri modi per autenticarti, sono trattati in [autenticazione hardware](37-hardware-authentication.md).
