# Repausul sistemului

Omarchy activează suspendarea în mod implicit, și hibernarea odată ce este configurată, dar dacă ai probleme cu oricare dintre ele pe mașina ta, le poți dezactiva.

Pe mașinile NVIDIA GB10, cum sunt DGX Spark și ASUS Ascent GX10, suspendarea și hibernarea sunt dezactivate, la fel ca în DGX OS de la NVIDIA, pentru că încă nu s-a demonstrat că repausul funcționează pe acel hardware. Comutatorul pentru suspendare și configurarea hibernării nu se aplică acolo. Ca să reactivezi repausul, șterge `/etc/systemd/sleep.conf.d/omarchy-sleep-disabled.conf` cu `sudo rm`; Suspend revine apoi în meniu, iar hibernarea poate fi configurată ca pe alte mașini. Rularea `sudo omarchy apply hardware --install-user "$USER"` pune fișierul la loc.

### Profiluri de alimentare

Pe un laptop, Omarchy ține minte profilul tău de alimentare separat pentru alimentarea la priză și pentru funcționarea pe baterie și comută între cele două pe măsură ce conectezi și deconectezi alimentarea. Implicit, asta înseamnă performance pe AC și balanced pe baterie.

Poți vedea ce oferă mașina ta cu `omarchy powerprofiles list` și poți seta profilul dorit pentru starea în care te afli în prezent cu `omarchy powerprofiles set autodetect power-saver`. Ca să setezi cealaltă stare fără să deconectezi nimic, numește-o direct: `omarchy powerprofiles set battery power-saver`. Orice alegi este ce vei primi data viitoare când te vei afla în acea stare.

### Comutarea suspendării

Comuți suspendarea rulând `omarchy toggle suspend` din terminal. Asta doar afișează/ascunde opțiunea de sub _System_ (sau `Super + Esc`), iar apoi poți vedea dacă funcționează consecvent pe sistemul tău. Dacă nu, o poți ascunde din nou cu aceeași comandă.

### Comutarea hibernării

Configurezi hibernarea rulând `omarchy hibernation setup` din terminal (nu este disponibilă pe Mac-urile Apple Silicon). Hibernarea creează un subvolum /swap pe unitatea ta de boot, de dimensiunea memoriei tale RAM fizice alocate, așa că asigură-te că ai destul spațiu liber la dispoziție. Pe o mașină de 32GB, vei avea întotdeauna nevoie de 32GB+ liberi pentru acest volum. Hibernarea necesită și bootloaderul implicit Limine.

Odată configurată, vei vedea opțiunea de hibernare sub _System_ (sau `Super + Esc`), iar apoi poți vedea dacă funcționează consecvent pe sistemul tău. Dacă nu, o poți elimina din nou rulând `omarchy hibernation remove`.
