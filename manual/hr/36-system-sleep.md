# Spavanje sustava

Omarchy prema zadanim postavkama omogućuje suspendiranje i hibernaciju, ali ako na svom računalu imate problema s bilo kojim od toga, možete ih isključiti.

Na računalima s NVIDIA GB10, kao što su DGX Spark i ASUS Ascent GX10, suspendiranje i hibernacija isključeni su, kao i u NVIDIA-inom DGX OS-u, jer još nije pokazano da spavanje radi na tom hardveru. Isto vrijedi i za ASUS Zenbook A16 (UX3607OA), gdje suspendiranje još ne uspavljuje čip u potpunosti i može se zamrznuti preko noći. Prekidač za suspendiranje i postavljanje hibernacije tamo se ne primjenjuju. Da biste ponovno uključili spavanje, uklonite `/etc/systemd/sleep.conf.d/omarchy-sleep-disabled.conf` pomoću `sudo rm`; Suspendiranje se tada vraća u izbornik, a hibernacija se može postaviti kao i na drugim računalima. Pokretanje `sudo omarchy apply hardware --install-user "$USER"` vraća datoteku natrag.

### Profili napajanja

Na prijenosnom računalu Omarchy pamti vaš profil napajanja zasebno za rad dok je priključen na struju i za rad na bateriji te se prebacuje između ta dva stanja dok priključujete i isključujete napajanje. Odmah po instalaciji to znači performanse na AC napajanju i uravnoteženo na bateriji.

Možete vidjeti što vaše računalo nudi pomoću `omarchy powerprofiles list`, a onaj koji želite za stanje u kojem se trenutno nalazite postavite pomoću `omarchy powerprofiles set autodetect power-saver`. Da biste postavili drugo stanje bez isključivanja ičega, izravno ga imenujte: `omarchy powerprofiles set battery power-saver`. Što god odaberete, to ćete dobiti natrag sljedeći put kada budete u tom stanju.

### Uključivanje i isključivanje suspendiranja

Suspendiranje uključujete i isključujete pokretanjem `omarchy toggle suspend` iz terminala. Time se samo otkriva/skriva opcija pod _Sustav_ (ili `Super + Esc`), pa zatim možete vidjeti radi li dosljedno na vašem sustavu. Ako ne radi, možete je ponovno sakriti istom naredbom.

### Uključivanje i isključivanje hibernacije

Hibernaciju postavljate pokretanjem `omarchy hibernation setup` iz terminala. Hibernacija stvara /swap podvolumen na vašem pogonu za pokretanje veličine vaše fizičke RAM memorije, pa se pobrinite da imate dovoljno slobodnog prostora. Na računalu s 32GB uvijek ćete za ovaj volumen trebati 32GB+ slobodnog prostora. Hibernacija također zahtijeva zadani Limine bootloader.

Kad je postavljena, vidjet ćete opciju hibernacije pod _Sustav_ (ili `Super + Esc`), pa zatim možete vidjeti radi li dosljedno na vašem sustavu. Ako ne radi, možete je ponovno ukloniti pokretanjem `omarchy hibernation remove`.
