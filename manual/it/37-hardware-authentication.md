# Autenticazione hardware

### Autenticazione tramite impronta digitale

Molti laptop sono dotati di un sensore di impronte digitali per l'autenticazione. Puoi usarlo con Omarchy eseguendo _Setup > Security > Fingerprint_ nel menu di Omarchy (`Super + Space`).

Si apre un'impronta digitale a schermo intero che si riempie man mano che tocchi il sensore. Dietro le quinte, Omarchy installerà il pacchetto per le impronte digitali, registrerà la tua impronta, la verificherà e sarai pronto a usare l'impronta digitale per sbloccare dalla schermata di blocco (che puoi attivare con `Super + Ctrl + L`), entrare in modalità sudo e autorizzare le richieste di sistema.

Una volta che la schermata di blocco ha spento il display, il sensore si mette a riposo per risparmiare energia, quindi riattiva lo schermo con un tasto qualsiasi o con il touchpad prima di toccarlo.

Quando il coperchio del laptop è chiuso, la richiesta dell'impronta digitale viene saltata automaticamente, così passi direttamente alla richiesta della password invece di aspettare un sensore che non puoi raggiungere. Se invece devi lavorare su una tastiera esterna senza sensore, premi semplicemente `CTRL + C` quando ti viene chiesta l'impronta digitale durante `sudo`.

Puoi rimuovere l'autenticazione tramite impronta digitale in _Remove > Security > Fingerprint_ nel menu di Omarchy.

### Autenticazione Fido2

Se usi un dispositivo Fido2, puoi configurarlo per l'autenticazione `sudo` usando _Setup > Security > Fido2_ nel menu di Omarchy (`Super + Space`). Copre `sudo` e le richieste di autorizzazione di sistema, però, non lo sblocco del computer.

Puoi rimuovere l'autenticazione fido2 in _Remove > Security > Fido2_ nel menu di Omarchy.
