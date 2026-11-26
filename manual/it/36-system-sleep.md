# Sospensione del sistema

Omarchy abilita la sospensione per impostazione predefinita, e l'ibernazione una volta configurata, ma se hai problemi con l'una o l'altra sulla tua macchina, puoi disattivarle.

Sulle macchine NVIDIA GB10, come DGX Spark e ASUS Ascent GX10, sospensione e ibernazione sono disattivate, come in DGX OS di NVIDIA, perché non è ancora stato dimostrato che lo sleep funzioni su quell'hardware. Lo stesso vale per ASUS Zenbook A16 (UX3607OA), dove la sospensione non mette ancora del tutto in sleep il chip e può bloccarsi durante la notte. L'interruttore della sospensione e la configurazione dell'ibernazione non si applicano in quel caso. Per riattivare lo sleep, rimuovi `/etc/systemd/sleep.conf.d/omarchy-sleep-disabled.conf` con `sudo rm`; la sospensione tornerà quindi nel menu, e l'ibernazione potrà essere configurata come sulle altre macchine. Eseguire `sudo omarchy apply hardware --install-user "$USER"` ripristina il file.

### Profili energetici

Su un portatile, Omarchy ricorda il tuo profilo energetico separatamente per quando sei collegato alla rete elettrica e per quando funzioni a batteria, e passa dall'uno all'altro quando colleghi e scolleghi l'alimentatore. Di fabbrica, questo significa performance con AC e balanced a batteria.

Puoi vedere cosa offre la tua macchina con `omarchy powerprofiles list`, e impostare quello che vuoi per lo stato in cui ti trovi attualmente con `omarchy powerprofiles set autodetect power-saver`. Per impostare l'altro stato senza scollegare nulla, indicalo direttamente: `omarchy powerprofiles set battery power-saver`. Qualunque tu scelga, è quello che ritroverai la prossima volta che sarai in quello stato.

### Attiva/disattiva sospensione

Attivi/disattivi la sospensione eseguendo `omarchy toggle suspend` dal terminale. Questo mostra/nasconde semplicemente l'opzione in _Sistema_ (o `Super + Esc`), così puoi vedere se funziona in modo costante sul tuo sistema. In caso contrario, puoi nasconderla di nuovo con lo stesso comando.

### Attiva/disattiva ibernazione

Configuri l'ibernazione eseguendo `omarchy hibernation setup` dal terminale (non è disponibile sui Mac Apple Silicon). L'ibernazione crea un sottovolume /swap sull'unità di avvio delle dimensioni della tua allocazione di RAM fisica, quindi assicurati di avere molto spazio libero a disposizione. Su una macchina da 32GB, avrai sempre bisogno di oltre 32GB liberi per questo volume. L'ibernazione richiede anche il bootloader predefinito Limine.

Una volta configurata, vedrai l'opzione di ibernazione in _Sistema_ (o `Super + Esc`), così puoi vedere se funziona in modo costante sul tuo sistema. In caso contrario, puoi rimuoverla di nuovo eseguendo `omarchy hibernation remove`.
