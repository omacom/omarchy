# Suspendarea sistemului

Omarchy activează suspendarea și hibernarea în mod implicit, dar dacă ai probleme cu vreuna dintre ele pe mașina ta, le poți dezactiva.

Pe mașinile NVIDIA GB10, cum ar fi DGX Spark și ASUS Ascent GX10, suspendarea și hibernarea sunt dezactivate, la fel ca în DGX OS de la NVIDIA, deoarece încă nu s-a demonstrat că repausul funcționează pe acel hardware. Același lucru este valabil și pentru ASUS Zenbook A16 (UX3607OA), unde suspendarea încă nu pune cipul complet în repaus și poate rămâne blocat peste noapte. Comutatorul de suspendare și configurarea hibernării nu se aplică acolo. Pentru a reactiva repausul, șterge `/etc/systemd/sleep.conf.d/omarchy-sleep-disabled.conf` cu `sudo rm`; Suspend revine apoi în meniu, iar hibernarea poate fi configurată ca pe alte mașini. Rularea `sudo omarchy apply hardware --install-user "$USER"` pune fișierul la loc.

### Profiluri de alimentare

Pe un laptop, Omarchy reține profilul tău de alimentare separat pentru alimentarea la priză și pentru funcționarea pe baterie și comută între cele două pe măsură ce conectezi și deconectezi alimentarea. Implicit, asta înseamnă performanță pe AC și echilibrat pe baterie.

Poți vedea ce oferă mașina ta cu `omarchy powerprofiles list` și poți seta profilul dorit pentru starea în care te afli în prezent cu `omarchy powerprofiles set autodetect power-saver`. Pentru a seta cealaltă stare fără să deconectezi nimic, numește-o direct: `omarchy powerprofiles set battery power-saver`. Orice ai alege, asta vei primi data viitoare când te vei afla în starea respectivă.

### Comutarea suspendării

Comuți suspendarea rulând `omarchy toggle suspend` din terminal. Asta doar dezvăluie/ascunde opțiunea de sub _System_ (sau `Super + Esc`), iar apoi poți verifica dacă funcționează constant pe sistemul tău. Dacă nu, o poți ascunde din nou cu aceeași comandă.

### Comutarea hibernării

Configurezi hibernarea rulând `omarchy hibernation setup` din terminal. Hibernarea creează un subvolum /swap pe unitatea ta de boot de dimensiunea memoriei tale RAM fizice, așa că asigură-te că ai suficient spațiu liber. Pe o mașină cu 32GB, vei avea întotdeauna nevoie de 32GB+ liberi pentru acest volum. Hibernarea necesită, de asemenea, bootloaderul implicit Limine.

După configurare, vei vedea opțiunea de hibernare sub _System_ (sau `Super + Esc`), iar apoi poți verifica dacă funcționează constant pe sistemul tău. Dacă nu, o poți elimina din nou rulând `omarchy hibernation remove`.
