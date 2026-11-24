# Mirovanje sustava

Omarchy prema zadanim postavkama omogućuje obustavu, a hibernaciju nakon što je postavite, ali ako na svom računalu imate problema s bilo kojom od njih, možete ih isključiti.

Na računalima NVIDIA GB10, kao što su DGX Spark i ASUS Ascent GX10, obustava i hibernacija isključene su, kao što su isključene i u NVIDIA-inom sustavu DGX OS, jer još nije dokazano da mirovanje radi na tom hardveru. Isto vrijedi i za ASUS Zenbook A16 (UX3607OA), na kojem obustava još ne uspavljuje čip u potpunosti i može se zaglaviti preko noći. Prekidač za obustavu i postavljanje hibernacije ondje se ne primjenjuju. Da biste mirovanje ponovno uključili, uklonite `/etc/systemd/sleep.conf.d/omarchy-sleep-disabled.conf` naredbom `sudo rm`; Obustava će se zatim vratiti u izbornik, a hibernacija se može postaviti kao i na drugim računalima. Pokretanjem naredbe `sudo omarchy apply hardware --install-user "$USER"` datoteka se vraća.

### Profili napajanja

Na prijenosnom računalu Omarchy vaš profil napajanja pamti odvojeno za rad kada je priključeno na struju i za rad na bateriji te se prebacuje između jednog i drugog dok ga priključujete i isključujete. Iz kutije to znači performanse na AC i uravnotežen način rada na bateriji.

Što vaše računalo nudi možete vidjeti naredbom `omarchy powerprofiles list`, a profil koji želite za stanje u kojem se trenutno nalazite postavite naredbom `omarchy powerprofiles set autodetect power-saver`. Da biste postavili drugo stanje bez ikakvog isključivanja, izravno ga imenujte: `omarchy powerprofiles set battery power-saver`. Što god odaberete, to ćete i dobiti natrag sljedeći put kada budete u tom stanju.

### Uključivanje/isključivanje obustave

Obustavu uključujete i isključujete pokretanjem naredbe `omarchy toggle suspend` iz terminala. Time se samo prikazuje/sakriva opcija pod _System_ (ili `Super + Esc`), pa zatim možete provjeriti radi li dosljedno na vašem sustavu. Ako ne radi, istom je naredbom možete ponovno sakriti.

### Uključivanje/isključivanje hibernacije

Hibernaciju postavljate pokretanjem naredbe `omarchy hibernation setup` iz terminala (nije dostupna na računalima Apple Silicon Macs). Hibernacija stvara podvolumen /swap na vašem pogonu za pokretanje, veličine dodijeljene vam fizičke memorije RAM, pa pripazite da imate dovoljno slobodnog prostora. Na računalu s 32GB uvijek ćete za taj volumen trebati više od 32GB+ slobodnog prostora. Hibernacija zahtijeva i zadani pokretački program Limine.

Kada je postavite, opciju hibernacije vidjet ćete pod _System_ (ili `Super + Esc`), pa zatim možete provjeriti radi li dosljedno na vašem sustavu. Ako ne radi, možete je ponovno ukloniti pokretanjem naredbe `omarchy hibernation remove`.
