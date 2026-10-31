# Interruttori, inattività e lo screensaver

Molto di ciò che cambi giorno per giorno non è davvero un'impostazione. È una modalità che attivi per un'ora e poi disattivi di nuovo: luce notturna mentre lavori fino a tardi, non disturbare mentre fai una presentazione, resta sveglio mentre guardi qualcosa. Omarchy le chiama interruttori, e funzionano tutti allo stesso modo — un tasto di scelta rapida, una voce di menu e un comando, tutti sullo stesso interruttore.

### Il menu degli interruttori

`Super + Ctrl + O` apre direttamente _Trigger > Toggle_, oppure puoi arrivarci dal menu di Omarchy (`Super + Space`). Tutto ciò che trovi in quell'elenco è un interruttore che puoi attivare senza pensare a dove risiede lo stato. Gli interruttori per l'aspetto del desktop si trovano accanto, sotto _Appearance_.

Dal terminale, gli stessi interruttori sono `omarchy toggle <thing>`. Esegui `omarchy toggle` da solo per vedere l'intero gruppo.

| Interruttore | Tasto di scelta rapida | Comando |
| ------ | ------ | ------- |
| Luce notturna | — | `omarchy toggle nightlight` |
| Silenzia notifiche | `Super + Ctrl + Alt + ,` | `omarchy toggle notification silencing` |
| Resta sveglio (nessun blocco per inattività) | `Super + Ctrl + I` | `omarchy toggle idle` |
| Cattura crash | — | `omarchy toggle crash-capture` |
| Screensaver | — | `omarchy toggle screensaver` |
| Sincronizzazione del tema di [Herdr](https://herdr.dev) | — | `omarchy toggle theme sync` |
| Barra del menu | `Super + Shift + Space` | `omarchy toggle bar` |
| Touchpad | `XF86TouchpadToggle` | `omarchy toggle touchpad` |
| Touchscreen | — | `omarchy toggle touchscreen` |
| Sospensione | — | `omarchy toggle suspend` |
| GPU ibrida | — | `omarchy toggle hybrid gpu` |

Gli interruttori per touchpad, touchscreen e GPU ibrida si trovano sotto _Trigger > Hardware_ (`Super + Ctrl + H`) anziché sotto Toggle, dato che compaiono solo quando hai effettivamente quell'hardware. Quelli per touchpad e touchscreen sopravvivono a un ricaricamento di Hyprland — il nome del dispositivo disabilitato viene salvato in un piccolo file di stato che Hyprland legge all'avvio per disabilitarlo di nuovo.

_Appearance_ contiene la barra del menu e le animazioni, oltre ad alcune cose che non sono comandi `omarchy toggle` ma si comportano allo stesso modo: la percentuale della batteria nella barra, il layout predefinito dello spazio di lavoro e, sotto _Windows_, gli spazi tra le finestre (`Super + Shift + Backspace`) e l'aspetto quadrato a 1 finestra (`Super + Ctrl + Backspace`).

La maggior parte di questi è semplicemente un file flag sotto `~/.local/state/omarchy/toggles/`. Se vuoi diramare in base a uno di essi in uno script, `omarchy-toggle-enabled` ti dà un codice di uscita invece di costringerti ad andarlo a cercare:

```bash
omarchy-toggle-enabled screensaver-off && echo "screensaver is off"
```

I flag prendono il nome dallo stato disattivato — `screensaver-off`, `suspend-off`, `bar-off` — quindi la loro presenza significa che la funzionalità è disabilitata.

### Indicatori nella barra

Quando una modalità è attiva, ottieni un piccolo glifo al centro della barra superiore, accanto all'orologio. È il widget degli indicatori, e contiene dettatura, registrazione dello schermo, promemoria in sospeso, luce notturna, non disturbare e resta sveglio.

Gli indicatori inattivi sono nascosti. Passa il mouse in un punto qualsiasi della barra e compaiono sbiaditi, così puoi cliccarne uno per attivarlo senza conoscerne il tasto di scelta rapida. Cliccando su un indicatore attivo lo disattivi di nuovo. Se preferisci vederli tutti in ogni momento, imposta `alwaysShow` su `true` nella voce `omarchy.indicators` in `~/.config/omarchy/shell.json` — vedi [la barra superiore](05-the-top-bar.md) per scoprire come si configurano i widget della barra.

### Luce notturna

La luce notturna riscalda lo schermo a 4000K, e attivandola di nuovo lo riporta a 6500K. Attivala dal menu degli interruttori (`Super + Ctrl + O`) o con `omarchy toggle nightlight`. È gestita da hyprsunset, che l'interruttore avvia per te se non è già in esecuzione.

Per impostazione predefinita, hyprsunset non fa assolutamente nulla al tuo schermo. `~/.config/hypr/hyprsunset.conf` viene fornito con un profilo identità proprio perché il display resti intatto finché non chiedi il calore. Se preferisci che cambi in base all'orologio, sostituisci quel profilo con un profilo orario:

```
profile {
    time = 20:00
    temperature = 4000
}
```

Poi avvia hyprsunset all'accesso aggiungendo `o.launch_on_start("hyprsunset")` a `~/.config/hypr/autostart.lua`. La coppia 4000K/6500K usata dall'interruttore è fissa, quindi il file di configurazione è dove vai se vuoi una temperatura diversa.

### Non disturbare

`Super + Ctrl + Alt + ,` silenzia le notifiche. Mentre è attivo non compaiono toast, e l'indicatore della campana barrata si trova nella barra per ricordarti perché il desktop è diventato silenzioso.

Niente va perso, però. Le notifiche silenziate vengono trattenute: rimettine sullo schermo le ultime con `Super + Shift + Alt + ,`. Vedi [avvisi](10-notices.md) per il resto.

Due tipi di messaggio passano comunque: i toast di conferma di Omarchy per qualcosa che hai appena fatto ("Theme changed", "Screenshot saved"), e gli avvisi critici inviati da riga di comando. Le app di chat che contrassegnano tutto come critico per imporsi davanti a te non rientrano in questa categoria.

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

Entrambi i numeri sono secondi contati dal momento in cui sei diventato inattivo — non l'uno dall'altro. Quindi, con i valori predefiniti, lo screensaver compare dopo due minuti e mezzo e la schermata di blocco subentra a cinque minuti, che lo screensaver sia partito o meno. Salva il file e la shell recepisce subito i nuovi tempi.

Se chiudi lo screensaver prima della scadenza del blocco, questo conta come attività e il blocco in attesa viene annullato. Non vieni bloccato fuori per aver dato un'occhiata alla tua macchina.

Per interrompere del tutto il blocco per inattività, `Super + Ctrl + I` — o `omarchy toggle idle` — attiva la modalità resta sveglio, e l'indicatore della tazzina di caffè compare nella barra. È quello da premere prima di una lunga presentazione o di una build che vuoi guardare. Premilo di nuovo per tornare alla normalità. `omarchy toggle idle status` stampa lo stato corrente come JSON se ti serve da uno script.

Qui si parla di blocco e screensaver, non di alimentazione. Sospensione e ibernazione hanno la loro configurazione in [sospensione del sistema](36-system-sleep.md).

### Lo screensaver

Lo screensaver di Omarchy è arte ASCII che passa attraverso effetti di testo casuali, un'istanza per monitor. Qualsiasi tasto o movimento del mouse lo chiude.

Puoi avviarlo su richiesta da _System > Screensaver_ (`Super + Esc`), che lo forza anche se hai disattivato lo screensaver per inattività. Per impostazione predefinita non ha un tasto di scelta rapida associato.

`omarchy toggle screensaver` è ciò che disattiva quello per inattività, se preferisci passare direttamente dal lavoro al blocco. Qualsiasi tasto, clic, scorrimento o movimento del mouse lo chiude.

Il logo che disegna puoi cambiarlo tu, sotto _Appearance > Branding > Screensaver_. Carica un png o svg e Omarchy lo converte in ASCII. Vedi [branding](41-branding.md).

### La schermata di blocco

`Super + Ctrl + L` blocca la macchina. Questo esegue la schermata di blocco dalla shell di Omarchy, oscura il display, reimposta il layout della tastiera sul primo, così non digiti la password con l'alfabeto sbagliato, e — se lo hai in esecuzione — blocca 1Password all'uscita.

La schermata di blocco accetta una password, e accetterà anche un'impronta digitale una volta che ne avrai configurata una. Questo, e gli altri modi per autenticarti, sono trattati in [autenticazione hardware](37-hardware-authentication.md).
