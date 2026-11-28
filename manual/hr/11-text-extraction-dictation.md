# Ekstrakcija teksta i diktiranje

### Ekstrakcija teksta

Pritisnite `Super + Ctrl + PrtScr` za odabir područja na zaslonu za ekstrakciju teksta. Otvoreni OCR model tesseract zatim će brzo pretvoriti taj odabir u tekst i smjestiti ga u međuspremnik. Zatim samo pritisnite `Super + V` za lijepljenje.

To je vrlo korisno za dohvaćanje adresa iz podnožja slika ili telefonskih brojeva ugrađenih u naslove web-mjesta.

 ![text-extraction](images/text-extraction.webp)

### Diktiranje

Na svježim instalacijama [Superwhisper](https://superwhisper.com/) je zadani backend za diktiranje, koji koristi obradu u oblaku bez preuzimanja izvanmrežnih modela. Odaberite Superwhisper, [Voxtype](https://voxtype.io/) ili [Hex](https://anoma.ly/hex/) kroz _Postavljanje > Zadane postavke > Diktiranje_ u izborniku Omarchy. Odabir backenda instalira ga ako je potrebno i postavlja ga kao zadanog za diktiranje. Voxtype učitava osnovni engleski model koji zauzima 150MB; promijenite model naredbom `voxtype setup model`, a ostale postavke kroz `~/.config/voxtype/config.toml`. Superwhisper otvara svoje postavke za odabir obrade u oblaku ili lokalne obrade, a OPR održava aplikaciju ažurnom. Hex preuzima svoj model govora na uređaju tijekom postavljanja i radi kao korisnička usluga `hex.service`; otvorite njegov prozor s ikone ladice na traci ili pokretanjem naredbe `hex` za promjenu modela i drugih postavki.

Diktirate tako da držite pritisnut `Right Alt` ili prebacujete s `Alt + Space`, a izdiktirani tekst pojavit će se u fokusiranom području za unos. Ovi prečaci koriste odabrani backend. Desni Alt također pokreće diktiranje kada se koristi u kombinaciji modifikatora; za te kombinacije koristite Lijevi Alt. Na rasporedima tipkovnice na kojima je Desni Alt AltGr, uključujući kada je takav raspored onaj na koji se prebacujete, držite ga samostalno na trenutak za diktiranje; AltGr pritisnut zajedno s drugom tipkom i dalje upisuje njezin znak. Instalacije iz razdoblja prije nego što je Alt + Space postao zadani zadržavaju `F9` za push-to-talk i `Super + Ctrl + X` za prebacivanje, dodane u `~/.config/hypr/bindings.lua`, gdje taj `Super + Ctrl + X` zauzima mjesto panela agenata; uklonite ih odande kako biste te tipke vratili aplikacijama i panelu.

Isti prečaci rade sa svakim backendom. Odaberite svoj backend kroz Postavljanje > Zadane postavke > Diktiranje. Instalacijski program backenda konfigurira ga i sprema odabir. Pokrenite `omarchy default dictation` da vidite koji je odabran. Odabir se sprema u `~/.config/omarchy/defaults/dictation`. Svježe instalacije automatski odabiru Superwhisper.

Omarchy automatski učitava integraciju s radnom površinom odabranog backenda. Nije potrebna nikakva konfiguracija za Superwhisper u `~/.config/hypr/`.

Prilagođena povezivanja i skripte mogu koristiti `omarchy dictation start`, `omarchy dictation stop` i `omarchy dictation toggle`. Odabrani backend upravlja snimanjem i transkripcijom. Odabir Superwhispera onemogućuje njegov izvorni prečac za držanje i postavlja njegovo izvorno prebacivanje na `Ctrl + Alt + Space`, držeći ga odvojenim od Omarchyjevih tipki za snimanje. Superwhisper zahtijeva barem jedan izvorni prečac za snimanje, a njegov prečac za otkazivanje ostaje dostupan.

Dodatni backendovi mogu se integrirati bez mijenjanja Omarchyja. Osigurajte izvršnu datoteku pod nazivom `omarchy-dictation-<backend>` na PATH koja prihvaća `start`, `stop` i `toggle` i brzo se vraća, s nenultim statusom u slučaju neuspjeha. Njezin instalacijski program konfigurira pružatelja i poziva `omarchy-dictation-use <backend>` nakon uspješnog postavljanja. To zaustavlja prethodni backend i atomarno sprema odabir; `stop` mora uspjeti kada je pružatelj neaktivan ili nedostupan. Nazivi backenda koriste mala slova, znamenke i crtice. Osigurajte `omarchy-install-dictation-<backend>` za postavljanje; `omarchy default dictation <backend>` pokreće ga. Dodajte unos u izbornik Zadane postavke kroz proširenje izbornika Omarchy kako biste pozvali taj odabir. Opcionalna integracija s radnom površinom može se nalaziti u `${XDG_CONFIG_HOME:-$HOME/.config}/<backend>/shortcuts.lua`.
