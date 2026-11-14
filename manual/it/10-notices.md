# Avvisi

Le notifiche compaiono nell'angolo in alto a destra dello schermo attivo. Puoi anche accedere rapidamente a data e ora, stato della batteria e meteo attuale usando gli avvisi con scorciatoie.

## Notifiche

Le notifiche della stessa app o dello stesso sito si impilano in un mazzo, così un canale Slack chiacchierone non spinge fuori dallo schermo l'errore della tua build. Passa il mouse su un mazzo per aprirlo a ventaglio; mentre leggi, niente di nuovo scivola sotto il puntatore. Fai clic su una scheda per saltare da dove proviene, fai clic con il pulsante destro, con il pulsante centrale, oppure premi ✕ per chiuderla.

Le schede offrono ciò che contengono: _Copia codice_ per i codici di verifica (tenuti fuori dalla [cronologia degli appunti](08-unified-clipboard-history.md) e cancellati dopo un minuto), più tutti i pulsanti forniti dall'app. I link nel testo di una notifica si aprono con un clic.

Per usarle senza mouse, premi `Super + Ctrl + ,`. Viene selezionata la notifica più recente e i suoi pulsanti vengono numerati: premi un numero per usarne uno, `Enter` per fare clic sulla notifica, `↑` e `↓` per spostarti tra le notifiche, `Delete` per chiuderne una ed `Esc` per restituire il controllo alla tastiera. Si rilascia anche da sola dopo qualche secondo di inattività.

Silenziare le notifiche le trattiene, tranne le conferme di Omarchy, gli avvisi di emergenza e i codici di verifica, che hai chiesto un attimo fa. Riporta le ultime sullo schermo, trattenute o no, con `Super + Shift + Alt + ,`. La cronologia viene conservata per un giorno.

## Avvisi con scorciatoie

### Data e ora

`Super + Ctrl + Alt + T`

 ![notice-datetime](images/notice-datetime.webp)

### Meteo

`Super + Ctrl + Alt + W`

 ![notice-weather](images/notice-weather.webp)

La posizione viene rilevata dal tuo indirizzo IP, il che di solito è abbastanza preciso, ma non sempre. Puoi fissarla con `omarchy weather location --set Malibu`, oppure essere preciso aggiungendo le coordinate: `omarchy weather location --set Malibu 34.0259,-118.7798`. Esegui `omarchy weather location` da solo per vedere dove pensa che tu sia, e `--clear` per tornare al rilevamento automatico.

### Batteria

`Super + Ctrl + Alt + B`

 ![notice-battery](images/notice-battery.webp)
