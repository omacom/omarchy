# Repausul sistemului

Omarchy activează suspendarea în mod implicit și hibernarea după ce este configurată, dar dacă ai probleme cu oricare dintre ele pe mașina ta, le poți dezactiva.

Pe mașinile cu NVIDIA GB10, cum ar fi DGX Spark și ASUS Ascent GX10, suspendarea și hibernarea sunt dezactivate, la fel ca în DGX OS de la NVIDIA, deoarece încă nu s-a demonstrat că repausul funcționează pe acel hardware. Același lucru este valabil și pentru ASUS Zenbook A16 (UX3607OA), unde suspendarea încă nu trece complet cipul în repaus și se poate bloca peste noapte. Comutatorul pentru suspendare și configurarea hibernării nu se aplică acolo. Ca să reactivezi repausul, șterge `/etc/systemd/sleep.conf.d/omarchy-sleep-disabled.conf` cu `sudo rm`; Suspend revine apoi în meniu, iar hibernarea poate fi configurată ca pe celelalte mașini. Dacă rulezi `sudo omarchy apply hardware --install-user "$USER"`, fișierul este pus la loc.

### Profiluri de alimentare

Pe un laptop, Omarchy reține profilul tău de alimentare separat pentru alimentarea la priză și pentru funcționarea pe baterie și comută între cele două pe măsură ce conectezi și deconectezi alimentarea. Implicit, asta înseamnă performanță pe AC și echilibrat pe baterie.

Poți vedea ce oferă mașina ta cu `omarchy powerprofiles list` și poți seta profilul dorit pentru starea în care te afli acum cu `omarchy powerprofiles set autodetect power-saver`. Ca să setezi cealaltă stare fără să deconectezi nimic, numește-o direct: `omarchy powerprofiles set battery power-saver`. Orice alegi este ce vei primi înapoi data viitoare când te vei afla în acea stare.

### Activare/dezactivare suspendare

Comuți suspendarea rulând `omarchy toggle suspend` din terminal. Asta doar afișează/ascunde opțiunea de sub _Sistem_ (sau `Super + Esc`), iar apoi poți vedea dacă funcționează constant pe sistemul tău. Dacă nu, o poți ascunde din nou cu aceeași comandă.

### Activare/dezactivare hibernare

Configurezi hibernarea rulând `omarchy hibernation setup` din terminal (nu este disponibilă pe Mac-urile cu Apple Silicon). Hibernarea creează un subvolum /swap pe unitatea ta de pornire, de dimensiunea alocării tale de RAM fizic, așa că asigură-te că ai destul spațiu la dispoziție. Pe o mașină cu 32GB, vei avea întotdeauna nevoie de peste 32GB liberi pentru acest volum. Hibernarea necesită și bootloaderul implicit Limine.

După configurare, vei vedea opțiunea de hibernare sub _Sistem_ (sau `Super + Esc`), iar apoi poți vedea dacă funcționează constant pe sistemul tău. Dacă nu, o poți elimina din nou rulând `omarchy hibernation remove`.
