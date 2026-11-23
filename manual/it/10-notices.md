# Avvisi

Le notifiche compaiono nell'angolo in alto a destra del display attivo. Puoi anche accedere rapidamente a data e ora, stato della batteria e meteo attuale usando gli avvisi con tasto rapido.

## Notifiche

Le notifiche della stessa app o dello stesso sito si impilano in un mazzo, così un canale Slack chiacchierone non spinge fuori dallo schermo l'errore della tua build. Passa il mouse su un mazzo per aprirlo a ventaglio; mentre stai leggendo, niente di nuovo scivola sotto il puntatore. Fai clic su una scheda per saltare da dove è arrivata, fai clic destro, clic centrale o premi ✕ per ignorarla.

Le schede offrono ciò che contengono: _Copia codice_ per i codici di verifica (tenuti fuori dalla [cronologia degli appunti](08-unified-clipboard-history.md) e cancellati dopo un minuto), più eventuali pulsanti forniti dall'app. I link nel testo di una notifica si aprono quando fai clic.

`Super + ,` ignora la notifica più recente, oppure apre ciò a cui punta quando offre questa possibilità, `Super + Alt + ,` ignora solo l'ultima, `Super + Shift + ,` le ignora tutte e `Super + Shift + Alt + ,` apre la cronologia. Per usarle senza mouse, premi `Super + Ctrl + ,`. La notifica più recente viene selezionata e i suoi pulsanti numerati: premi un numero per usarne uno, `Enter` per fare clic sulla notifica, `↑` e `↓` per spostarti tra le notifiche, `Delete` per ignorarne una ed `Esc` per restituire la tastiera. Si rilascia anche da sola dopo alcuni secondi di inattività.

Silenziare le notifiche le trattiene, tranne le conferme di Omarchy, gli avvisi di emergenza e i codici di verifica, che hai chiesto un attimo fa. Rimetti le ultime sullo schermo, trattenute o no, con `Super + Shift + Alt + ,`. La cronologia viene conservata per un giorno.

## Avvisi con tasto rapido

### Data e ora

`Super + Ctrl + Alt + T`

 ![notice-datetime](images/notice-datetime.webp)

### Meteo

`Super + Ctrl + Alt + W`

 ![notice-weather](images/notice-weather.webp)

La posizione viene rilevata dal tuo indirizzo IP, che di solito è abbastanza precisa, ma non sempre. Puoi fissarla con `omarchy weather location --set Malibu`, o essere preciso aggiungendo le coordinate: `omarchy weather location --set Malibu 34.0259,-118.7798`. Esegui `omarchy weather location` da solo per vedere dove pensa che tu sia, e `--clear` per tornare al rilevamento automatico.

### Batteria

`Super + Ctrl + Alt + B`

 ![notice-battery](images/notice-battery.webp)
