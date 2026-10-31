# Izdvajanje teksta i diktiranje

### Izdvajanje teksta

Pritisnite `Super + Ctrl + PrtScr` da biste odabrali područje na zaslonu za izdvajanje teksta. OCR model otvorenog koda tesseract potom će brzo pretvoriti taj odabir u tekst i smjestiti ga u međuspremnik. Zatim samo pritisnite `Super + V` za lijepljenje.

To je vrlo korisno za preuzimanje adresa iz podnožja slika ili telefonskih brojeva ugrađenih u naslove web-stranica.

 ![text-extraction](images/text-extraction.webp)

### Diktiranje

Na svježim instalacijama, [Superwhisper](https://superwhisper.com/) je zadani backend za diktiranje, koji koristi obradu u oblaku bez preuzimanja izvanmrežnih modela. Odaberite Superwhisper ili [Voxtype](https://voxtype.io/) putem _Setup > Defaults > Dictation_ u izborniku Omarchy. Odabir backenda instalira ga po potrebi i postavlja ga kao zadani za diktiranje. Voxtype učitava osnovni engleski model koji zauzima 150MB; model promijenite naredbom `voxtype setup model`, a ostale postavke putem `~/.config/voxtype/config.toml`. Superwhisper otvara svoje postavke za odabir obrade u oblaku ili lokalne obrade, a OPR održava aplikaciju ažurnom.

Diktirate tako da držite pritisnut `Right Alt` ili prebacivanjem pomoću `Alt + Space`, a izdiktirani tekst pojavit će se u fokusiranom području za unos. Ovi prečaci koriste odabrani backend. Right Alt također pokreće diktiranje kada se koristi u akordu modifikatora; za te akorde koristite Left Alt. Na rasporedima tipkovnice na kojima je Right Alt AltGr, koristite `Alt + Space` kako bi AltGr ostao dostupan za tipkanje. Instalacije iz vremena prije nego što je Alt + Space postao zadani zadržavaju `F9` za push-to-talk i `Super + Ctrl + X` za prebacivanje, dodane u `~/.config/hypr/bindings.lua`; uklonite ih tamo kako biste te tipke vratili aplikacijama.

Isti prečaci rade s oba backenda. Odaberite backend putem Setup > Defaults > Dictation. Instalacijski program backenda konfigurira ga i sprema odabir. Pokrenite `omarchy default dictation` da biste vidjeli koji je odabran. Odabir se sprema u `~/.config/omarchy/defaults/dictation`. Svježe instalacije automatski odabiru Superwhisper.

Omarchy automatski učitava integraciju s radnom površinom odabranog backenda. Nije potrebna nikakva konfiguracija Superwhispera u `~/.config/hypr/`.

Prilagođena povezivanja i skripte mogu koristiti `omarchy dictation start`, `omarchy dictation stop` i `omarchy dictation toggle`. Odabrani backend upravlja snimanjem i transkripcijom. Odabir Superwhispera onemogućuje njegov izvorni prečac za držanje i postavlja njegovo izvorno prebacivanje na `Ctrl + Alt + Space`, držeći ga odvojenim od tipki za snimanje u Omarchyju. Superwhisper zahtijeva barem jedan izvorni prečac za snimanje, a njegov prečac za otkazivanje ostaje dostupan.

Dodatni backendovi mogu se integrirati bez mijenjanja Omarchyja. Osigurajte izvršnu datoteku pod nazivom `omarchy-dictation-<backend>` na PATH-u koja prihvaća `start`, `stop` i `toggle` te se brzo vraća, s nenultim statusom pri neuspjehu. Njegov instalacijski program konfigurira pružatelja i poziva `omarchy-dictation-use <backend>` nakon uspješnog postavljanja. Time se zaustavlja prethodni backend i odabir se sprema atomarno; `stop` mora uspjeti kada je pružatelj u mirovanju ili nedostupan. Nazivi backendova koriste mala slova, znamenke i crtice. Osigurajte `omarchy-install-dictation-<backend>` za postavljanje; `omarchy default dictation <backend>` pokreće ga. Dodajte unos u izbornik Defaults putem proširenja izbornika Omarchy za pozivanje tog birača. Neobavezna integracija s radnom površinom može se nalaziti u `${XDG_CONFIG_HOME:-$HOME/.config}/<backend>/shortcuts.lua`.
