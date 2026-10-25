# Pozadine

Svaka tema dolazi s vlastitim skupom pozadina, a možete dodati i vlastite dodatke u `~/.config/omarchy/backgrounds/[theme]`. Ako želite dodati dodatnu sliku pozadine, recimo, temi nord, samo stavite datoteku u `~/.config/omarchy/backgrounds/nord`.

To najlakše možete učiniti tako da u izborniku Omarchy odete na _Instaliraj > Stil > Pozadina_. To će otvoriti mapu u kojoj su pohranjene pozadine za tu temu. Pritisnite `Super + Shift + F` da biste pokrenuli još jedan upravitelj datoteka, pronađite svoju pozadinu i kopirajte je onamo. Sada će biti uključena u izbor pozadina između kojih možete birati pomoću `Super + Ctrl + W`.

Pozadine mogu biti i videozapisi, a ne samo statične slike. Ubacite datoteku `mp4`, `m4v`, `mov`, `webm`, `mkv` ili `avi` u istu mapu i pojavit će se uz slike. Videozapise reproducira OWE mehanizam za pozadine. Dekodira videozapis jednom za sve monitore i reproducira njegov zvuk preko zadanog audioizlaza te zaustavlja reprodukciju kad god ga ništa ne može vidjeti. Video pozadina i dalje troši daleko više energije od statične.

Teme mogu sadržavati kratki uvod za statičnu pozadinu. Za `backgrounds/road.webp`, odgovarajući videozapis nalazi se na `backgrounds/intros/road.mp4`. Reproducira se automatski pri pokretanju i pri prebacivanju na temu s odabranom tom pozadinom, a zatim se vraća na statičnu sliku. Uvodni videozapisi ne prikazuju se u biraču pozadine i nikada se ne ponavljaju u petlji.

Isključivanje opcije _Izgled > Animacije_ također isključuje uvode pozadine. Omarchy to prema zadanim postavkama čini u virtualnom stroju. Naredba `omarchy theme bg intro toggle` može zasebno uključiti ili isključiti uvode. Osvježavanje teme ili odabir druge pozadine unutar iste teme ne reproducira uvod.

Ogromnu zbirku sjajnih odabranih pozadina možete pronaći na https://github.com/dharmx/walls.

Zaključani zaslon prikazuje statični kadar video pozadine, na isti način na koji prikazuje statični kadar animiranog GIF-a.
