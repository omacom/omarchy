# Repausul sistemului

Omarchy activează implicit suspendarea și hibernarea, dar dacă ai probleme cu vreuna dintre ele pe mașina ta, le poți dezactiva.

Pe mașinile NVIDIA GB10, cum ar fi DGX Spark și ASUS Ascent GX10, suspendarea și hibernarea sunt dezactivate, la fel ca în DGX OS de la NVIDIA, deoarece nu s-a demonstrat încă faptul că repausul funcționează pe acel hardware. Comutarea suspendării și configurarea hibernării nu se aplică acolo. Pentru a reactiva repausul, elimină `/etc/systemd/sleep.conf.d/omarchy-sleep-disabled.conf` cu `sudo rm`; Suspend revine apoi în meniu, iar hibernarea poate fi configurată ca pe alte mașini. Rularea comenzii `sudo omarchy apply hardware --install-user "$USER"` pune fișierul la loc.

### Profiluri de alimentare

Pe un laptop, Omarchy reține profilul tău de alimentare separat pentru alimentarea la priză și pentru funcționarea pe baterie și comută între cele două atunci când conectezi și deconectezi alimentarea. Implicit, asta înseamnă performanță pe AC și echilibrat pe baterie.

Poți vedea ce oferă mașina ta cu `omarchy powerprofiles list` și poți seta profilul dorit pentru starea în care te afli în prezent cu `omarchy powerprofiles set autodetect power-saver`. Pentru a seta cealaltă stare fără să deconectezi nimic, numește-o direct: `omarchy powerprofiles set battery power-saver`. Orice ai alege este ceea ce vei primi înapoi data viitoare când te vei afla în acea stare.

### Comutarea suspendării

Comuți suspendarea rulând `omarchy toggle suspend` din terminal. Asta doar afișează/ascunde opțiunea de sub _System_ (sau `Super + Esc`), iar apoi poți vedea dacă funcționează constant pe sistemul tău. Dacă nu, o poți ascunde din nou cu aceeași comandă.

### Comutarea hibernării

Configurezi hibernarea rulând `omarchy hibernation setup` din terminal. Hibernarea creează un subvolum /swap pe unitatea ta de boot, cu dimensiunea alocării tale de RAM fizic, așa că asigură-te că ai destul spațiu liber. Pe o mașină cu 32GB, vei avea întotdeauna nevoie de 32GB+ liberi pentru acest volum. Hibernarea necesită, de asemenea, bootloaderul implicit Limine.

Odată configurată, vei vedea opțiunea de hibernare sub _System_ (sau `Super + Esc`), iar apoi poți vedea dacă funcționează constant pe sistemul tău. Dacă nu, o poți elimina din nou rulând `omarchy hibernation remove`.
