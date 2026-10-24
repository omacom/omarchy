# Pozadine

Svaka tema dolazi s vlastitim skupom pozadina, a možete dodati i vlastite dodatke u `~/.config/omarchy/backgrounds/[theme]`. Ako želite dodati dodatnu sliku pozadine, recimo, temi nord, samo stavite datoteku u `~/.config/omarchy/backgrounds/nord`.

To najlakše možete učiniti odlaskom na _Instaliraj > Style > Background_ u Omarchy izborniku. Time se otvara mapa u kojoj su pohranjene pozadine za tu temu. Pritisnite `Super + Shift + F` za pokretanje drugog upravitelja datoteka, pronađite svoju pozadinu i kopirajte je. Sada će biti uključena u izbor pozadina između kojih možete birati pomoću `Super + Ctrl + Space`.

Pozadine mogu biti videozapisi kao i nepomične slike. Stavite datoteku `mp4`, `m4v`, `mov`, `webm`, `mkv` ili `avi` u istu mapu i pojavit će se uz slike. Videozapise reproducira OWE mehanizam za pozadine. Dekodira videozapis jednom za sve monitore i reproducira njegov zvuk kroz zadani audio izlaz te zaustavlja reprodukciju kad god ga ništa ne može vidjeti. Zaslon za zaključavanje prikazuje isto dekodiranje, bez zvuka, kroz OWE. Video pozadina i dalje troši daleko više energije od nepomične.

Teme mogu uključivati kratki uvod za nepomičnu pozadinu. Za `backgrounds/road.webp` odgovarajući videozapis živi na `backgrounds/intros/road.mp4`. Automatski se reproducira pri pokretanju i pri prebacivanju na temu s odabranom tom pozadinom, a zatim se vraća na nepomičnu sliku. Uvodni videozapisi ostaju izvan birača pozadina i nikada se ne ponavljaju u petlji.

Isključivanje _Pokreni > Appearance > Animations_ također isključuje uvode pozadina. Omarchy to prema zadanim postavkama čini u virtualnom stroju. Naredba `omarchy theme bg intro toggle` može uvode prebacivati odvojeno. Osvježavanje teme ili odabir druge pozadine unutar iste teme ne reproducira uvod.

Ogromnu zbirku sjajnih uređenih pozadina možete pronaći na https://github.com/dharmx/walls.

Video pozadine zadržavaju predmemoriranu nepomičnu sliku na zaslonu za zaključavanje dok je reprodukcija pauzirana ili nedostupna. Animirani GIF-ovi reproduciraju se na radnoj površini i prikazuju nepomični kadar na zaslonu za zaključavanje.
