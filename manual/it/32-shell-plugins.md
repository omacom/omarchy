# Plugin della shell

Il desktop Omarchy gira come un singolo processo Quickshell a lunga durata chiamato `omarchy-shell`, e quasi tutto ciò che vedi sullo schermo è un plugin al suo interno. La barra è un plugin. Lo sono anche i pannelli che scendono da essa, gli overlay a schermo intero come il selettore di emoji e il gestore degli appunti, il menu Omarchy stesso, la schermata di blocco, la finestra di dialogo polkit e i servizi headless che monitorano la batteria e riscaldano lo schermo di notte.

Non è solo un dettaglio di implementazione. Significa che puoi disattivare pezzi del desktop, sostituirli o scriverne di tuoi senza toccare una riga del sorgente di Omarchy.

I plugin di prima parte sono inclusi con Omarchy e vivono in `$OMARCHY_PATH/shell/plugins/`. Tutto ciò che aggiungi tu — i tuoi esperimenti o qualcosa che hai trovato su GitHub — vive in `~/.config/omarchy/plugins/`. Entrambi vengono scoperti allo stesso modo all'avvio, ma quelli integrati ricevono interfacce shell fidate mentre i plugin di terze parti ricevono un'interfaccia limitata circoscritta al proprio servizio e ciclo di vita. I cloni di quelli integrati conservano solo la configurazione specifica della sorgente e le chiamate UI necessarie per il comportamento originale.

## Vedere cosa hai

```
omarchy plugin list
```

Questo stampa ogni plugin scoperto con il suo id, se è abilitato, se è di prima o di terze parti, i suoi tipi e il suo nome visualizzato. Aggiungi `--json` se lo stai passando a qualcos'altro.

Gli id dei plugin hanno uno spazio dei nomi. Quelli integrati iniziano tutti con `omarchy.` — `omarchy.clock`, `omarchy.network`, `omarchy.notifications` — e quello spazio dei nomi è riservato, quindi un plugin di terze parti non potrà mai rivendicarlo.

## Attivarli e disattivarli

```
omarchy plugin enable omarchy.tailscale
omarchy plugin disable omarchy.weather
```

Oppure usa il menu: _Impostazioni > Plugin_ ha Attiva plugin, Disattiva plugin, Aggiungi plugin, Clona plugin e Rimuovi plugin, ognuno con un selettore che offre solo i plugin che hanno senso per quell'azione.

Lo stato abilitato è memorizzato in `~/.config/omarchy/shell.json`, e la regola differisce leggermente per i due tipi di plugin. Un plugin di terze parti è abilitato esattamente quando il suo id appare da qualche parte in quel file — come voce del layout della barra, come voce in `plugins[]` o come `bar.id`. I plugin di prima parte che non sono widget della barra funzionano al contrario: sono attivi per impostazione predefinita e si disattivano solo se elencati in `disabledPlugins[]`.

Un plugin barra completo non ha affatto uno stato disattivato. C'è sempre esattamente una barra, quindi la sostituisci abilitandone un'altra. Il posizionamento dei widget della barra è trattato in [la barra superiore](05-the-top-bar.md).

## Aggiungere un plugin da git

Un plugin di terze parti è semplicemente un repo git con un `manifest.json` nella sua radice.

```
omarchy plugin add https://github.com/acme/omarchy-weather.git --enable
```

Prima di fare qualsiasi cosa, ti dice chiaramente che i plugin girano come codice arbitrario e non in sandbox all'interno del tuo processo shell a lunga durata, ti mostra l'URL e ti chiede di confermare. Prendilo sul serio. L'interfaccia dei plugin di terze parti non espone direttamente i servizi di autenticazione, e una barra sostitutiva riceve solo funzionalità limitate per l'UI non di autenticazione configurata. I plugin visivi condividono comunque la scena QML della shell e possono percorrere normali oggetti padre, mentre tutto il codice dei plugin gira con tutto ciò a cui il tuo account utente può accedere. Lo stato di autenticazione è protetto separatamente mantenendo quei servizi fuori dal grafo di oggetti host raggiungibile. Aggiungi solo repo che sei disposto a eseguire, e leggili prima di abilitarli.

Una barra sostitutiva può renderizzare i widget installati, ma i widget di terze parti supportati da un servizio potrebbero avere funzionalità ridotte lì perché alla barra non è consentito richiedere l'oggetto servizio attivo di un altro plugin. Torna alla `omarchy.bar` integrata se un widget del genere ha bisogno del suo servizio compagno.

Poi clona il repo in una directory di staging, convalida il manifest, rifiuta l'installazione se un altro plugin rivendica già quell'id e lo sposta in `~/.config/omarchy/plugins/<id>/`. Senza `--enable` chiede se vuoi attivarlo ora, e puoi dire di no e andare prima a leggere il codice. Non esegue mai nulla dal plugin, non esegue mai un hook di installazione e non chiede mai sudo — clona file, controlla il manifest e commuta un bit via IPC.

L'aggiornamento è un pull fast-forward di quello stesso checkout:

```
omarchy plugin update acme.weather
omarchy plugin update
```

Senza id aggiorna ogni plugin gestito da git che hai. Ti mostra il diff prima di applicarlo, si rifiuta di aggiornare se hai modifiche locali che non può superare con un fast-forward e fa rollback se la nuova revisione non supera la convalida.

```
omarchy plugin remove acme.weather
```

La rimozione disabilita prima il plugin, poi lo elimina se è un checkout git (il repo è ancora upstream) o lo scollega se è un symlink. Una cartella plugin fatta a mano senza repo git viene spostata in un backup con timestamp all'interno della directory dei plugin invece di essere eliminata del tutto.

## Clonare un integrato per modificarlo

Questa è la mia parte preferita. Se vuoi cambiare il comportamento di un widget integrato, non modificare i file sotto `$OMARCHY_PATH` — appartengono al pacchetto e il prossimo aggiornamento li sovrascriverà. Clonalo invece:

```
omarchy plugin clone omarchy.clock
```

Questo copia l'intero plugin in `~/.config/omarchy/plugins/dhh.clock` (il tuo nome utente, non il mio), lo rinomina in "My Clock", lo abilita e fa passare la shell dall'integrato alla tua copia — mantenendo posizione e impostazioni di un widget della barra esistente. Aggiungi `--edit` per aprire subito la nuova directory nel tuo `$EDITOR`, che è ciò che fa per te _Impostazioni > Plugin > Clona plugin_ nel menu.

Il prefisso del nome utente mantiene tuo l'id del tuo clone, così condividerlo non collide con quello di nessun altro. Le chiamate fatte all'id integrato originale vengono instradate al tuo clone, quindi nulla che faceva riferimento a `omarchy.clock` ha bisogno di essere aggiornato. E se fai un pasticcio, `omarchy plugin remove dhh.clock` rimette a posto l'integrato.

Salvare un file ovunque sotto `~/.config/omarchy/plugins/` ricarica automaticamente il codice del plugin, così puoi lasciare l'editor aperto e guardare le tue modifiche arrivare.

## Scriverne uno tuo

Un plugin è una directory con un `manifest.json` e un po' di QML. Il manifest dichiara `schemaVersion: 1`, un `id`, `name`, `version`, uno o più `kinds` e un oggetto `entryPoints` che punta al file QML per ogni tipo:

| Tipo | Che cos'è |
|------|------------|
| `bar-widget` | Un componente che la barra attiva può inserire in una sezione |
| `panel` | Una finestra flottante persistente o richiamabile |
| `overlay` | Un overlay a schermo intero |
| `menu` | Una superficie di menu richiamabile |
| `service` | Un singleton headless senza UI |
| `bar` | Una barra completa che sostituisce quella integrata |

Un plugin può dichiarare più tipi contemporaneamente — il plugin media è sia un `service` sia un `bar-widget`. I widget della barra ricevono un blocco `barWidget` extra con un nome visualizzato, una categoria, un `defaultSection` opzionale e `allowMultiple`, che dice se ha senso averne più di uno sulla barra. La maggior parte dei widget lo imposta su `false`; spaziatori e indicatori lo impostano su `true`.

Prima di pubblicare qualsiasi cosa, controllala:

```
omarchy plugin validate ./my-plugin
```

Questo esegue gli stessi controlli che la shell fa al caricamento: la versione dello schema, i campi richiesti, un id che non sia riservato, entry point che siano percorsi relativi sicuri ed esistano effettivamente, un entry point per ogni tipo che hai dichiarato e nessun symlink da nessuna parte dentro la cartella.

Per lo sviluppo di plugin, vedi il [riferimento della shell](https://github.com/omacom/omarchy/blob/quattro/docs/omarchy-shell.md) e il [catalogo dei plugin di prima parte](https://github.com/omacom/omarchy/blob/quattro/shell/plugins/README.md).

## Condividere il tuo con il mondo

Una volta che hai creato qualcosa che ti piace, mettilo in un repo git pubblico. Questo è l'intero meccanismo di distribuzione — chiunque può poi eseguire `omarchy plugin add` contro il tuo URL e averlo in funzione in pochi secondi.

Per aiutare le persone a trovarlo davvero, elencalo su [plugins.omarchy.org](https://plugins.omarchy.org). È il marketplace per i plugin della shell Omarchy, ed è il primo posto dove guardare quando ti chiedi se qualcuno ha già costruito il widget che stai per scrivere. Dagli un'occhiata prima di iniziare!
