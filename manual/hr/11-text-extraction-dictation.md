# Izdvajanje teksta i diktiranje

### Izdvajanje teksta

Pritisnite `Super + Ctrl + PrtScr` za odabir područja na zaslonu za izdvajanje teksta. OCR model otvorenog koda tesseract zatim će brzo pretvoriti taj odabir u tekst i smjestiti ga u međuspremnik. Zatim samo pritisnite `Super + V` za lijepljenje.

To je vrlo korisno za kopiranje adresa iz podnožja slika ili telefonskih brojeva ugrađenih u naslove web-stranica.

 ![text-extraction](images/text-extraction.webp)

### Diktiranje

Na svježim instalacijama [Superwhisper](https://superwhisper.com/) je zadani pozadinski sustav za diktiranje, koji koristi obradu u oblaku bez preuzimanja modela za izvanmrežni rad. Odaberite Superwhisper, [Voxtype](https://voxtype.io/) ili [Hex](https://anoma.ly/hex/) putem _Setup > Defaults > Dictation_ u izborniku Omarchy. Odabir pozadinskog sustava instalira ga po potrebi i postavlja kao zadanog za diktiranje. Voxtype učitava osnovni engleski model koji zauzima 150MB; model promijenite naredbom `voxtype setup model`, a ostale postavke putem `~/.config/voxtype/config.toml`. Superwhisper otvara svoje postavke za odabir obrade u oblaku ili lokalne obrade, a OPR održava aplikaciju ažuriranom. Hex tijekom postavljanja preuzima svoj model govora na uređaju i radi kao korisnička usluga `hex.service`; otvorite njegov prozor s ikone u sistemskoj traci na traci ili pokretanjem naredbe `hex` za promjenu modela i ostalih postavki.

Diktirate držeći pritisnutu tipku `Right Alt` ili prebacivanjem pomoću `Alt + Space`, a izdiktirani tekst pojavit će se u fokusiranom području za unos. Ovi prečaci koriste odabrani pozadinski sustav. Right Alt također pokreće diktiranje kada se koristi u kombinaciji modifikatora; za te kombinacije koristite Left Alt. Na rasporedima tipkovnice na kojima je Right Alt ujedno AltGr, koristite `Alt + Space` kako bi AltGr ostao dostupan za tipkanje. Instalacije iz razdoblja prije nego što je Alt + Space postao zadani zadržavaju `F9` za pritisni-za-govor i `Super + Ctrl + X` za prebacivanje, dodane u `~/.config/hypr/bindings.lua`, gdje taj `Super + Ctrl + X` zauzima mjesto ploče agenata; uklonite ih odatle kako biste te tipke vratili aplikacijama i ploči.

Isti prečaci rade sa svakim pozadinskim sustavom. Odaberite svoj pozadinski sustav putem Setup > Defaults > Dictation. Instalacijski program pozadinskog sustava konfigurira ga i sprema odabir. Pokrenite `omarchy default dictation` da biste vidjeli koji je odabran. Odabir se sprema u `~/.config/omarchy/defaults/dictation`. Svježe instalacije automatski odabiru Superwhisper.

Omarchy automatski učitava integraciju odabranog pozadinskog sustava za radnu površinu. Nije potrebna nikakva konfiguracija za Superwhisper u `~/.config/hypr/`.

Prilagođena povezivanja tipki i skripte mogu koristiti `omarchy dictation start`, `omarchy dictation stop` i `omarchy dictation toggle`. Odabrani pozadinski sustav obavlja snimanje i transkripciju. Odabir Superwhispera onemogućuje njegov izvorni prečac za držanje i postavlja njegovo izvorno prebacivanje na `Ctrl + Alt + Space`, držeći ga odvojeno od Omarchy tipki za snimanje. Superwhisper zahtijeva barem jedan izvorni prečac za snimanje, a njegov prečac za otkazivanje ostaje dostupan.

Dodatni pozadinski sustavi mogu se integrirati bez mijenjanja Omarchyja. Osigurajte izvršnu datoteku naziva `omarchy-dictation-<backend>` na PATH koja prihvaća `start`, `stop` i `toggle` te se odmah vraća, s nenultim statusom u slučaju neuspjeha. Njegov instalacijski program konfigurira pružatelja i poziva `omarchy-dictation-use <backend>` nakon uspješnog postavljanja. Time se zaustavlja prethodni pozadinski sustav i odabir se sprema atomarno; `stop` mora uspjeti kada je pružatelj neaktivan ili nedostupan. Nazivi pozadinskih sustava koriste mala slova, znamenke i crtice. Za postavljanje osigurajte `omarchy-install-dictation-<backend>`; pokreće ga `omarchy default dictation <backend>`. Dodajte unos u izbornik Defaults putem proširenja izbornika Omarchy za pozivanje tog alata za odabir. Opcionalna integracija za radnu površinu može se nalaziti u `${XDG_CONFIG_HOME:-$HOME/.config}/<backend>/shortcuts.lua`.
