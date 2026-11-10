# Sospensione del sistema

Omarchy abilita sospensione e ibernazione per impostazione predefinita, ma se hai problemi con l'una o l'altra sulla tua macchina, puoi disattivarle.

Sulle macchine NVIDIA GB10, come il DGX Spark e l'ASUS Ascent GX10, sospensione e ibernazione sono disattivate, proprio come nel DGX OS di NVIDIA, perché non è ancora stato dimostrato che la sospensione funzioni su quell'hardware. Lo stesso vale per l'ASUS Zenbook A16 (UX3607OA), dove la sospensione non mette ancora il chip completamente in sospensione e può bloccarsi durante la notte. L'attivazione/disattivazione della sospensione e la configurazione dell'ibernazione non si applicano in questi casi. Per riattivare la sospensione, rimuovi `/etc/systemd/sleep.conf.d/omarchy-sleep-disabled.conf` con `sudo rm`; Sospensione tornerà quindi nel menu e l'ibernazione potrà essere configurata come sulle altre macchine. Eseguendo `sudo omarchy apply hardware --install-user "$USER"` il file viene ripristinato.

### Profili energetici

Su un laptop, Omarchy ricorda il tuo profilo energetico separatamente per quando sei collegato alla corrente e quando vai a batteria, e passa dall'uno all'altro quando colleghi e scolleghi l'alimentazione. Per impostazione predefinita, questo significa prestazioni quando sei collegato alla rete elettrica e bilanciato a batteria.

Puoi vedere cosa offre la tua macchina con `omarchy powerprofiles list` e impostare quello che desideri per lo stato in cui ti trovi attualmente con `omarchy powerprofiles set autodetect power-saver`. Per impostare l'altro stato senza scollegare nulla, indicalo direttamente: `omarchy powerprofiles set battery power-saver`. Qualunque tu scelga, è quello che ritroverai la prossima volta che sarai in quello stato.

### Attiva/disattiva sospensione

Attivi/disattivi la sospensione eseguendo `omarchy toggle suspend` dal terminale. Questo mostra/nasconde semplicemente l'opzione sotto _Sistema_ (o `Super + Esc`), così puoi verificare se funziona in modo affidabile sul tuo sistema. In caso contrario, puoi nasconderla di nuovo con lo stesso comando.

### Attiva/disattiva ibernazione

Configuri l'ibernazione eseguendo `omarchy hibernation setup` dal terminale. L'ibernazione crea un sottovolume /swap sull'unità di avvio delle dimensioni della tua RAM fisica, quindi assicurati di avere molto spazio libero. Su una macchina da 32GB, avrai sempre bisogno di oltre 32GB liberi per questo volume. L'ibernazione richiede inoltre il bootloader predefinito Limine.

Una volta configurata, vedrai l'opzione di ibernazione sotto _Sistema_ (o `Super + Esc`), così puoi verificare se funziona in modo affidabile sul tuo sistema. In caso contrario, puoi rimuoverla di nuovo eseguendo `omarchy hibernation remove`.
