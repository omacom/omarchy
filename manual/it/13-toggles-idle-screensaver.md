# Toggle, inattività e screensaver

Gran parte di quello che cambi giorno per giorno non è davvero un'impostazione. È una modalità che attivi per un'ora e poi disattivi di nuovo: la luce notturna mentre lavori fino a tardi, il non disturbare mentre fai una presentazione, il resta attivo mentre guardi qualcosa. Omarchy li chiama toggle, e funzionano tutti allo stesso modo — un tasto rapido, una voce di menu e un comando, tutti sullo stesso interruttore.

### Il menu dei toggle

`Super + Ctrl + O` apre direttamente _Trigger > Toggle_, oppure ci arrivi dal menu di Omarchy (`Super + Space`). Tutto in quell'elenco è un interruttore che puoi attivare senza pensare a dove vive lo stato. Gli interruttori per l'aspetto del desktop stanno accanto, sotto _Appearance_.

Dal terminale, gli stessi interruttori sono `omarchy toggle <thing>`. Esegui `omarchy toggle` da solo per vedere l'intero gruppo.

| Toggle | Tasto rapido | Comando |
| ------ | ------ | ------- |
| Luce notturna | — | `omarchy toggle nightlight` |
| Silenzia notifiche | `Super + Ctrl + Alt + ,` | `omarchy toggle notification silencing` |
| Resta attivo (nessun blocco per inattività) | `Super + Ctrl + I` | `omarchy toggle idle` |
| Cattura dei crash | — | `omarchy toggle crash-capture` |
| Screensaver | — | `omarchy toggle screensaver` |
| Sincronizzazione del tema di [Herdr](https://herdr.dev) | — | `omarchy toggle theme sync` |
| Barra dei menu | `Super + Shift + Space` | `omarchy toggle bar` |
| Touchpad | `XF86TouchpadToggle` | `omarchy device touchpad` |
| Touchscreen | — | `omarchy device touchscreen` |
| Sospensione | — | `omarchy toggle suspend` |
| GPU ibrida | — | `omarchy toggle hybrid gpu` |

Gli interruttori di touchpad, touchscreen e GPU ibrida stanno sotto _Trigger > Hardware_ (`Super + Ctrl + H`) anziché sotto Toggle, visto che compaiono solo quando hai davvero quell'hardware. Quelli di touchpad e touchscreen sopravvivono a un ricaricamento di Hyprland — il nome del dispositivo disabilitato viene salvato in un piccolo file di stato che Hyprland legge all'avvio per disabilitarlo di nuovo.

_Appearance_ contiene la barra dei menu e le animazioni, più alcune cose che non sono comandi `omarchy toggle` ma si comportano allo stesso modo: la percentuale della batteria nella barra, il layout predefinito del workspace e, sotto _Windows_, gli spazi tra le finestre (`Super + Shift + Backspace`) e il formato quadrato a 1 finestra (`Super + Ctrl + Backspace`).

Quando Hyprland non ha una GPU con cui disegnare e renderizza invece sulla CPU (llvmpipe), come sui Mac la cui GPU non è ancora supportata, nella maggior parte delle macchine virtuali o quando un driver grafico non riesce a caricarsi, Omarchy disattiva animazioni, sfocatura e ombre per quella sessione e te lo dice una volta con una notifica. _Appearance > Animations On_ le riattiva, e Omarchy lo ricorda anche per le sessioni successive.

La maggior parte di questi è semplicemente un file flag sotto `~/.local/state/omarchy/toggles/`. Se vuoi farci un branch in uno script, `omarchy-toggle-enabled` ti dà un codice di uscita invece di costringerti ad andare a cercare:

```bash
omarchy-toggle-enabled screensaver-off && echo "screensaver is off"
```

I flag sono chiamati in base allo stato disattivato — `screensaver-off`, `suspend-off`, `bar-off` — quindi la loro presenza significa che la funzione è disabilitata.

### Indicatori nella barra

Quando una modalità è attiva, vedi un piccolo glifo al centro della barra superiore, accanto all'orologio. È il widget degli indicatori, e contiene dettatura, registrazione dello schermo, promemoria in sospeso, luce notturna, non disturbare e resta attivo.

Gli indicatori inattivi sono nascosti. Passa il mouse in un punto qualsiasi della barra e compaiono attenuati, così puoi cliccarne uno per attivarlo senza conoscerne il tasto rapido. Cliccare su uno attivo lo disattiva di nuovo. Se preferisci vederli tutti sempre, imposta `alwaysShow` su `true` nella voce `omarchy.indicators` in `~/.config/omarchy/shell.json` — vedi [la barra superiore](05-the-top-bar.md) per come si configurano i widget della barra.

### Luce notturna

La luce notturna scalda lo schermo a 4000K, e riattivando il toggle lo riporta a 6500K. Attivala dal menu dei toggle (`Super + Ctrl + O`) o con `omarchy toggle nightlight`. È gestita da hyprsunset, che il toggle avvia per te se non è già in esecuzione.

Per impostazione predefinita hyprsunset non fa assolutamente nulla al tuo schermo. `~/.config/hypr/hyprsunset.conf` viene fornito con un profilo identità proprio perché il display resti intatto finché non chiedi calore. Se preferisci che cambi in base all'orologio, sostituiscilo con un profilo a tempo:

```
profile {
    time = 20:00
    temperature = 4000
}
```

Poi avvia hyprsunset all'accesso aggiungendo `o.launch_on_start("hyprsunset")` a `~/.config/hypr/autostart.lua`. La coppia 4000K/6500K usata dal toggle è fissa, quindi il file di configurazione è dove vai se vuoi una temperatura diversa.

### Non disturbare

`Super + Ctrl + Alt + ,` silenzia le notifiche. Mentre è attivo non compare nessun toast, e l'indicatore della campana barrata sta nella barra per ricordarti perché il desktop è diventato silenzioso.

Non si perde nulla, però. Le notifiche silenziate vengono trattenute: rimettine le ultime sullo schermo con `Super + Shift + Alt + ,`. Vedi [avvisi](10-notices.md) per il resto.

Due tipi di messaggio passano comunque: i toast di conferma di Omarchy per qualcosa che hai appena fatto ("Tema cambiato", "Screenshot salvato"), e gli avvisi critici inviati dalla riga di comando. Le app di chat che marcano tutto come critico per forzarsi davanti a te non rientrano.

### Inattività

La shell di Omarchy gestisce il comportamento in inattività, e le tempistiche stanno in un blocco `idle` di primo livello in `~/.config/omarchy/shell.json`:

```json
{
  "version": 1,
  "idle": {
    "screensaver": 150,
    "lock": 300
  }
}
```

Entrambi i numeri sono secondi contati dal momento in cui sei diventato inattivo — non l'uno dall'altro. Quindi con le impostazioni predefinite, lo screensaver compare dopo due minuti e mezzo e la schermata di blocco subentra a cinque minuti, che lo screensaver sia partito o no. Salva il file e la shell acquisisce subito le nuove tempistiche.

Se chiudi lo screensaver prima della scadenza del blocco, conta come attività e il blocco in sospeso viene annullato. Non resti bloccato fuori per aver dato un'occhiata alla macchina.

Per smettere del tutto di bloccare in inattività, `Super + Ctrl + I` — oppure `omarchy toggle idle` — attiva il resta attivo, e nella barra compare l'indicatore della tazzina di caffè. È quello da premere prima di una lunga presentazione o di una build che vuoi guardare. Premilo di nuovo per tornare alla normalità. `omarchy toggle idle status` stampa lo stato attuale come JSON se ti serve da uno script.

Qui si parla di blocco e screensaver, non di alimentazione. Sospensione e ibernazione hanno la loro configurazione in [sospensione del sistema](36-system-sleep.md).

### Lo screensaver

Lo screensaver di Omarchy è arte ASCII che passa attraverso effetti di testo casuali, un'istanza per monitor. Qualsiasi tasto o movimento del mouse lo chiude.

Puoi avviarlo su richiesta da _System > Screensaver_ (`Super + Esc`), che lo forza anche se hai disattivato lo screensaver da inattività. Per impostazione predefinita non ha nessun tasto rapido associato.

`omarchy toggle screensaver` è ciò che disattiva quello da inattività, se preferisci passare dritto dal lavoro al blocco. Qualsiasi tasto, clic, scroll o movimento del mouse lo chiude.

Il logo che disegna puoi cambiarlo tu, sotto _Appearance > Branding > Screensaver_. Carica un png o svg e Omarchy lo converte in ASCII. Vedi [branding](41-branding.md).

### La schermata di blocco

`Super + Ctrl + L` blocca la macchina. Questo avvia la schermata di blocco della shell di Omarchy, oscura il display, reimposta il layout della tastiera sul primo così non digiti la password nell'alfabeto sbagliato e — se ce l'hai in esecuzione — blocca 1Password all'uscita.

La schermata di blocco accetta una password, e accetterà anche un'impronta digitale una volta che ne hai configurata una. Questo, e gli altri modi per autenticarsi, sono trattati in [autenticazione hardware](37-hardware-authentication.md).
