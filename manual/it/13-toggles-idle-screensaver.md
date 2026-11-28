# I toggle, l'inattività e il salvaschermo

Molto di ciò che modifichi giorno per giorno non è davvero un'impostazione. È una modalità che attivi per un'ora e poi disattivi di nuovo: la luce notturna mentre lavori fino a tardi, non disturbare mentre fai una presentazione, resta attivo mentre guardi qualcosa. Omarchy li chiama toggle, e funzionano tutti allo stesso modo — un tasto di scelta rapida, una voce di menu e un comando, tutti sullo stesso interruttore.

### Il menu dei toggle

`Super + Ctrl + O` apre direttamente _Trigger > Toggle_, oppure puoi arrivarci dal menu di Omarchy (`Super + Space`). Tutto in quell'elenco è un interruttore che puoi attivare o disattivare senza pensare a dove risiede lo stato. Gli interruttori per l'aspetto del desktop si trovano accanto, sotto _Appearance_.

Dal terminale, gli stessi interruttori sono `omarchy toggle <thing>`. Esegui `omarchy toggle` da solo per vedere l'intero gruppo.

| Toggle | Tasto di scelta rapida | Comando |
| ------ | ------ | ------- |
| Luce notturna | — | `omarchy toggle nightlight` |
| Silenzia le notifiche | `Super + Ctrl + Alt + ,` | `omarchy toggle notification silencing` |
| Resta attivo (nessun blocco per inattività) | `Super + Ctrl + I` | `omarchy toggle idle` |
| Cattura dei crash | — | `omarchy toggle crash-capture` |
| Salvaschermo | — | `omarchy toggle screensaver` |
| Sincronizzazione del tema di [Herdr](https://herdr.dev) | — | `omarchy toggle theme sync` |
| Barra dei menu | `Super + Shift + Space` | `omarchy toggle bar` |
| Desktop a schermo intero (nessuna barra, nessun margine) | `Super + Ctrl + Alt + F` | `omarchy toggle fullscreen desktop` |
| Animazioni, sfocatura e ombre | — | `omarchy toggle animations` |
| Touchpad | `XF86TouchpadToggle` | `omarchy device touchpad` |
| Touchscreen | — | `omarchy device touchscreen` |
| Sospensione | — | `omarchy toggle suspend` |
| GPU ibrida | — | `omarchy device gpu hybrid` |

Gli interruttori per touchpad, touchscreen e GPU ibrida si trovano sotto _Trigger > Hardware_ (`Super + Ctrl + H`) anziché sotto Toggle, perché compaiono solo quando hai effettivamente quell'hardware. Quelli per touchpad e touchscreen sopravvivono a un ricaricamento di Hyprland — il nome del dispositivo disabilitato viene salvato in un piccolo file di stato che Hyprland legge all'avvio per disabilitarlo di nuovo.

_Appearance_ contiene la barra dei menu e le animazioni, oltre ad alcune cose che non sono comandi `omarchy toggle` ma si comportano allo stesso modo: la percentuale della batteria nella barra, il layout predefinito dell'area di lavoro e, sotto _Windows_, i margini tra le finestre (`Super + Shift + Backspace`) e l'aspetto quadrato a 1 finestra (`Super + Ctrl + Backspace`).

Quando Hyprland non ha una GPU con cui disegnare e renderizza invece sulla CPU (llvmpipe), come sui Mac la cui GPU non è ancora supportata, nella maggior parte delle macchine virtuali o quando un driver grafico non si carica, Omarchy disattiva animazioni, sfocatura e ombre per quella sessione e te lo dice una volta con una notifica. _Appearance > Animations On_ le riattiva, e Omarchy lo ricorda anche per le sessioni successive.

La maggior parte di questi è semplicemente un file flag sotto `~/.local/state/omarchy/toggles/`. Se vuoi usarne uno per una diramazione in uno script, `omarchy-toggle-enabled` ti dà un codice di uscita invece di costringerti ad andare a cercarlo:

```bash
omarchy-toggle-enabled screensaver-off && echo "screensaver is off"
```

I flag sono nominati per lo stato disattivato — `screensaver-off`, `suspend-off`, `bar-off` — quindi la loro presenza significa che la funzionalità è disabilitata.

### Gli indicatori nella barra

Quando una modalità è attiva, ottieni un piccolo glifo al centro della barra superiore accanto all'orologio. È il widget degli indicatori, e contiene la registrazione dello schermo, i promemoria in sospeso, la luce notturna, non disturbare e resta attivo, oltre ad avvisi mentre sudo senza password è attivo o qualcuno è connesso a una sessione remota.

Gli indicatori inattivi sono nascosti. Passa il mouse in un punto qualsiasi della barra e compaiono attenuati, così puoi cliccarne uno per attivarlo senza conoscerne il tasto di scelta rapida. Cliccare su uno attivo lo disattiva di nuovo. Se preferisci vederli sempre tutti, imposta `alwaysShow` a `true` sulla voce `omarchy.indicators` in `~/.config/omarchy/shell.json` — vedi [la barra superiore](05-the-top-bar.md) per come si configurano i widget della barra.

### Luce notturna

La luce notturna riscalda lo schermo a 4000K, e attivarla di nuovo lo riporta a 6500K. Attivala dal menu dei toggle (`Super + Ctrl + O`) o con `omarchy toggle nightlight`. È gestita da hyprsunset, che il toggle avvia per te se non è già in esecuzione.

Per impostazione predefinita hyprsunset non fa assolutamente nulla al tuo schermo. `~/.config/hypr/hyprsunset.conf` viene fornito con un profilo identità proprio perché il display resti intatto finché non chiedi calore. Se preferisci che cambi in base all'orologio, sostituisci quello con un profilo a tempo:

```
profile {
    time = 20:00
    temperature = 4000
}
```

Poi avvia hyprsunset all'accesso aggiungendo `o.launch_on_start("hyprsunset")` a `~/.config/hypr/autostart.lua`. La coppia 4000K/6500K usata dal toggle è fissa, quindi il file di configurazione è dove andare se vuoi una temperatura diversa.

### Non disturbare

`Super + Ctrl + Alt + ,` silenzia le notifiche. Non compare nessun toast mentre è attivo, e l'indicatore con la campana barrata sta nella barra per ricordarti perché il desktop è diventato silenzioso.

Non si perde nulla, però. Le notifiche silenziate vengono trattenute: rimetti le ultime sullo schermo con `Super + Shift + Alt + ,`. Vedi [avvisi](10-notices.md) per il resto.

Tre tipi di messaggio passano comunque: i toast di conferma di Omarchy per qualcosa che hai appena fatto ("Theme changed", "Screenshot saved"), gli avvisi critici inviati da riga di comando e i codici di verifica. Le app di chat che marcano tutto come critico per forzarsi davanti a te non rientrano.

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

Entrambi i numeri sono secondi contati dal momento in cui sei diventato inattivo — non l'uno dall'altro. Quindi con le impostazioni predefinite, il salvaschermo compare dopo due minuti e mezzo e la schermata di blocco subentra a cinque minuti, che il salvaschermo sia partito o no. Salva il file e la shell acquisisce subito i nuovi tempi.

Se chiudi il salvaschermo prima della scadenza del blocco, conta come attività e il blocco in sospeso viene annullato. Non vieni bloccato fuori per aver dato un'occhiata alla tua macchina.

Per smettere del tutto di bloccare in inattività, `Super + Ctrl + I` — o `omarchy toggle idle` — attiva resta attivo, e nella barra compare l'indicatore con la tazzina di caffè. È quello da premere prima di una lunga presentazione o di una build che vuoi osservare. Premilo di nuovo per tornare alla normalità. `omarchy toggle idle status` stampa lo stato corrente come JSON se ti serve da uno script.

Qui si parla di blocco e salvaschermo, non di alimentazione. Sospensione e ibernazione hanno la loro configurazione in [sospensione del sistema](36-system-sleep.md).

### Il salvaschermo

Il salvaschermo di Omarchy è arte ASCII che passa attraverso effetti di testo casuali, un'istanza per monitor. Qualsiasi tasto o movimento del mouse lo chiude.

Puoi avviarlo su richiesta da _System > Screensaver_ (`Super + Esc`), che lo forza anche se hai disattivato il salvaschermo per inattività. Per impostazione predefinita non gli è assegnato nessun tasto di scelta rapida.

`omarchy toggle screensaver` è quello che disattiva quello per inattività, se preferisci passare direttamente dal lavoro al blocco. Qualsiasi tasto, clic, scorrimento o movimento del mouse lo chiude.

Il logo che disegna puoi cambiarlo tu, sotto _Appearance > Branding > Screensaver_. Carica un png o svg e Omarchy lo converte in ASCII. Vedi [branding](41-branding.md).

### La schermata di blocco

`Super + Ctrl + L` blocca la macchina. Questo avvia la schermata di blocco dalla shell di Omarchy, oscura il display, reimposta il layout della tastiera al primo così non digiti la password con l'alfabeto sbagliato e — se ce l'hai in esecuzione — blocca 1Password all'uscita.

La schermata di blocco accetta una password, e accetterà anche un'impronta digitale una volta che ne avrai configurata una. Questo, e gli altri modi per autenticarsi, sono trattati in [autenticazione hardware](37-hardware-authentication.md).
