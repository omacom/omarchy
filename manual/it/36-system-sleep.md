# Sospensione del sistema

Omarchy abilita la sospensione per impostazione predefinita, e l'ibernazione una volta configurata, ma se hai problemi con l'una o l'altra sulla tua macchina, puoi disattivarle.

Sulle macchine NVIDIA GB10, come DGX Spark e ASUS Ascent GX10, sospensione e ibernazione sono disattivate, come lo sono in DGX OS di NVIDIA, perché non è ancora stato dimostrato che la sospensione funzioni su quell'hardware. L'interruttore per la sospensione e la configurazione dell'ibernazione lì non si applicano. Per riattivare la sospensione, rimuovi `/etc/systemd/sleep.conf.d/omarchy-sleep-disabled.conf` con `sudo rm`; Sospendi torna quindi nel menu, e l'ibernazione può essere configurata come sulle altre macchine. Eseguire `sudo omarchy apply hardware --install-user "$USER"` rimette il file al suo posto.

### Profili energetici

Su un laptop, Omarchy ricorda il tuo profilo energetico separatamente per quando sei collegato alla corrente e per quando vai a batteria, e passa dall'uno all'altro mentre colleghi e scolleghi l'alimentazione. Di fabbrica significa performance con alimentazione AC e balanced a batteria.

Puoi vedere cosa offre la tua macchina con `omarchy powerprofiles list`, e impostare quello che vuoi per lo stato in cui ti trovi adesso con `omarchy powerprofiles set autodetect power-saver`. Per impostare l'altro stato senza scollegare niente, indicalo direttamente: `omarchy powerprofiles set battery power-saver`. Qualunque cosa tu scelga è quello che ritroverai la prossima volta che sarai in quello stato.

### Attiva/disattiva sospensione

Attivi/disattivi la sospensione eseguendo `omarchy toggle suspend` dal terminale. Questo si limita a mostrare/nascondere l'opzione sotto _Sistema_ (oppure `Super + Esc`), e così puoi vedere se funziona in modo affidabile sul tuo sistema. In caso contrario, puoi nasconderla di nuovo con lo stesso comando.

### Attiva/disattiva ibernazione

Configuri l'ibernazione eseguendo `omarchy hibernation setup` dal terminale (non è disponibile sui Mac Apple Silicon). L'ibernazione crea un sottovolume /swap sul tuo disco di avvio delle dimensioni della tua RAM fisica installata, quindi assicurati di avere abbondante spazio libero. Su una macchina da 32GB, ti serviranno sempre più di 32GB liberi per questo volume. L'ibernazione richiede inoltre il bootloader Limine predefinito.

Una volta configurata, vedrai l'opzione di ibernazione sotto _Sistema_ (oppure `Super + Esc`), e così puoi vedere se funziona in modo affidabile sul tuo sistema. In caso contrario, puoi rimuoverla di nuovo eseguendo `omarchy hibernation remove`.
