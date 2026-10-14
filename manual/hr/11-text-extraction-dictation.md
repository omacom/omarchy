# Izdvajanje teksta i diktiranje

### Izdvajanje teksta

Pritisnite `Super + Ctrl + PrtScr` da odaberete područje na zaslonu za izdvajanje teksta. OCR model otvorenoga koda tesseract zatim će brzo pretvoriti taj odabir u tekst i smjestiti ga u međuspremnik. Zatim jednostavno pritisnete `Super + V` za lijepljenje.

To je vrlo korisno za izvlačenje adresa iz podnožja slika ili telefonskih brojeva ugrađenih u naslove web stranica.

 ![text-extraction](images/text-extraction.webp)

### Diktiranje

Na svježim instalacijama [Superwhisper](https://superwhisper.com/) zadani je pozadinski sustav za diktiranje, koji koristi obradu u oblaku bez preuzimanja modela za rad izvan mreže. Odaberite Superwhisper ili [Voxtype](https://voxtype.io/) putem _Postavke > Zadane postavke > Diktiranje_ u Omarchy izborniku. Odabir pozadinskoga sustava instalira ga ako je potrebno i čini ga zadanim za diktiranje. Voxtype učitava osnovni engleski model koji zauzima 150 MB; model promijenite s `voxtype setup model`, a ostale postavke putem `~/.config/voxtype/config.toml`. Superwhisper otvara svoje postavke za odabir obrade u oblaku ili lokalne obrade, a OPR održava aplikaciju ažuriranom.

Diktirate držanjem tipke `Right Alt` ili `F9` ili prebacivanjem prečacom `Super + Ctrl + X`, a diktirani tekst pojavit će se u fokusiranome području za unos. Ti prečaci koriste odabrani pozadinski sustav. Right Alt također pokreće diktiranje kada se koristi u akordu modifikatora; za te akorde koristite Left Alt. Na rasporedima tipkovnice u kojima je Right Alt ujedno AltGr, koristite `F9` kako bi AltGr ostao dostupan za tipkanje.

Isti prečaci rade s oba pozadinska sustava. Pozadinski sustav odaberite putem Postavke > Zadane postavke > Diktiranje. Instalacijski program pozadinskoga sustava konfigurira ga i sprema odabir. Pokrenite `omarchy default dictation` da vidite koji je odabran. Odabir se sprema u `~/.config/omarchy/defaults/dictation`. Svježe instalacije automatski odabiru Superwhisper.

Omarchy automatski učitava integraciju odabranoga pozadinskoga sustava s radnom površinom. U `~/.config/hypr/` nije potrebna nikakva konfiguracija Superwhispera.

Prilagođene poveznice i skripte mogu koristiti `omarchy dictation start`, `omarchy dictation stop` i `omarchy dictation toggle`. Odabrani pozadinski sustav upravlja snimanjem i transkripcijom. Odabir Superwhispera onemogućuje njegov izvorni prečac za držanje i postavlja njegovo izvorno prebacivanje na `Alt + Space`, držeći ga odvojenim od Omarchyjevih tipki za snimanje. Superwhisper zahtijeva barem jedan izvorni prečac za snimanje, a njegov prečac za otkazivanje ostaje dostupan.

Dodatni pozadinski sustavi mogu se integrirati bez mijenjanja Omarchyja. Na PATH-u osigurajte izvršnu datoteku nazvanu `omarchy-dictation-<backend>` koja prihvaća `start`, `stop` i `toggle` i promptno se vraća, s statusom različitim od nule pri neuspjehu. Njezin instalacijski program konfigurira pružatelja i nakon uspješnoga postavljanja poziva `omarchy-dictation-use <backend>`. To zaustavlja prethodni pozadinski sustav i atomski sprema odabir; `stop` mora uspjeti kada je pružatelj neaktivan ili nedostupan. Nazivi pozadinskih sustava koriste mala slova, znamenke i crtice. Za postavljanje osigurajte `omarchy-install-dictation-<backend>`; `omarchy default dictation <backend>` ga pokreće. Unos u izbornik Zadane postavke dodajte putem proširenja Omarchy izbornika koje poziva taj selektor. Izborna integracija s radnom površinom može živjeti u `${XDG_CONFIG_HOME:-$HOME/.config}/<backend>/shortcuts.lua`.
