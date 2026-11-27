# Spavanje sustava

Omarchy prema zadanim postavkama omogućuje obustavu, a hibernaciju nakon što je postavite, ali ako na vašem računalu imate problema s bilo čime od toga, možete ih isključiti.

Na NVIDIA GB10 računalima, kao što su DGX Spark i ASUS Ascent GX10, obustava i hibernacija isključene su, kao i u NVIDIA-inom DGX OS-u, jer još nije pokazano da spavanje radi na tom hardveru. Prekidač za obustavu i postavljanje hibernacije tamo se ne primjenjuju. Da biste ponovno uključili spavanje, uklonite `/etc/systemd/sleep.conf.d/omarchy-sleep-disabled.conf` pomoću `sudo rm`; Obustava se tada vraća u izbornik, a hibernacija se može postaviti kao i na drugim računalima. Pokretanje `sudo omarchy apply hardware --install-user "$USER"` vraća datoteku.

### Profili napajanja

Na prijenosnom računalu Omarchy zasebno pamti vaš profil napajanja za rad dok je priključeno na struju i za rad na bateriju te se prebacuje između njih dvoje kako ga priključujete i isključujete. Odmah nakon instalacije to znači performanse na AC i uravnoteženo na bateriji.

Možete vidjeti što vaše računalo nudi pomoću `omarchy powerprofiles list`, a onaj koji želite za stanje u kojem se trenutačno nalazite postavite pomoću `omarchy powerprofiles set autodetect power-saver`. Da biste postavili drugo stanje bez ikakvog isključivanja, izravno ga imenujte: `omarchy powerprofiles set battery power-saver`. Što god odaberete, to ćete dobiti natrag sljedeći put kad budete u tom stanju.

### Prebacivanje obustave

Obustavu prebacujete pokretanjem `omarchy toggle suspend` iz terminala. Time se samo otkriva/skriva opcija pod _Sustav_ (ili `Super + Esc`), pa zatim možete vidjeti radi li dosljedno na vašem sustavu. Ako ne radi, možete je ponovno sakriti istom naredbom.

### Prebacivanje hibernacije

Hibernaciju postavljate pokretanjem `omarchy hibernation setup` iz terminala (nije dostupna na Apple Silicon Mac računalima). Hibernacija stvara /swap podvolumen na vašem pogonu za pokretanje veličine vaše dodjele fizičkog RAM-a, pa provjerite imate li dovoljno slobodnog prostora. Na računalu s 32GB za ovaj ćete volumen uvijek trebati 32GB+ slobodnog prostora. Hibernacija također zahtijeva zadani Limine bootloader.

Kad je postavljena, vidjet ćete opciju hibernacije pod _Sustav_ (ili `Super + Esc`), pa zatim možete vidjeti radi li dosljedno na vašem sustavu. Ako ne radi, možete je ponovno ukloniti pokretanjem `omarchy hibernation remove`.
