# Autenticazione hardware

### Autenticazione con impronta digitale

Molti laptop sono dotati di un sensore di impronte digitali per l'autenticazione. Puoi usarlo con Omarchy eseguendo _Setup > Security > Fingerprint_ nel menu Omarchy (`Super + Space`).

Verrà installato il pacchetto per le impronte digitali, verrà acquisita la tua impronta e verrà verificata, e potrai iniziare a usare la tua impronta digitale per sbloccare dalla schermata di blocco (che puoi attivare con `Super + Ctrl + L`), entrare in modalità sudo e autorizzare le richieste di sistema.

Una volta che la schermata di blocco ha spento il display, il sensore si mette a riposo per risparmiare energia, quindi risveglia lo schermo con un tasto qualsiasi o con il touchpad prima di toccarlo.

Quando il coperchio del tuo laptop è chiuso, la richiesta dell'impronta digitale viene saltata automaticamente, così vai dritto alla richiesta della password invece di aspettare un sensore che non puoi raggiungere. Se invece devi lavorare con una tastiera esterna che non ha un sensore, premi semplicemente `CTRL + C` quando ti viene chiesta l'impronta digitale durante `sudo`.

Puoi rimuovere l'autenticazione con impronta digitale in _Remove > Security > Fingerprint_ nel menu Omarchy.

### Autenticazione Fido2

Se usi un dispositivo Fido2, puoi configurarlo per l'autenticazione `sudo` usando _Setup > Security > Fido2_ nel menu Omarchy (`Super + Space`). Copre però `sudo` e le richieste di autorizzazione di sistema, non lo sblocco del computer.

Puoi rimuovere l'autenticazione fido2 in _Remove > Security > Fido2_ nel menu Omarchy.
