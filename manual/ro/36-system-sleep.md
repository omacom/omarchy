# Repausul sistemului

Omarchy activează suspendarea și hibernarea implicit, dar dacă ai probleme cu oricare dintre ele pe mașina ta, le poți dezactiva.

### Profiluri de alimentare

Pe un laptop, Omarchy reține profilul de alimentare separat pentru alimentarea de la priză și pentru funcționarea pe baterie și comută între cele două pe măsură ce conectezi și deconectezi alimentarea. Implicit, asta înseamnă performanță la priză și echilibrat pe baterie.

Poți vedea ce oferă mașina ta cu `omarchy powerprofiles list` și poți seta profilul dorit pentru starea în care te afli în prezent cu `omarchy powerprofiles set autodetect power-saver`. Ca să setezi cealaltă stare fără să deconectezi nimic, numește-o direct: `omarchy powerprofiles set battery power-saver`. Orice alegi este ceea ce vei primi înapoi data viitoare când vei fi în acea stare.

### Comutarea suspendării

Comuți suspendarea rulând `omarchy toggle suspend` din terminal. Asta doar dezvăluie/ascunde opțiunea sub _System_ (sau `Super + Esc`), iar apoi poți vedea dacă funcționează constant pe sistemul tău. Dacă nu, o poți ascunde din nou cu aceeași comandă.

### Comutarea hibernării

Configurezi hibernarea rulând `omarchy hibernation setup` din terminal. Hibernarea creează un subvolum /swap pe unitatea de pornire de dimensiunea alocării tale de RAM fizic, așa că asigură-te că ai mult spațiu de rezervă. Pe o mașină cu 32GB, vei avea întotdeauna nevoie de 32GB+ liberi pentru acest volum. Hibernarea necesită și încărcătorul de pornire implicit Limine.

Când este configurată, vei vedea opțiunea de hibernare sub _System_ (sau `Super + Esc`), iar apoi poți vedea dacă funcționează constant pe sistemul tău. Dacă nu, o poți elimina din nou rulând `omarchy hibernation remove`.
