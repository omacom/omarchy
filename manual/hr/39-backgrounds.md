# Pozadine

Svaka tema dolazi s vlastitim skupom pozadina, a svoje dodatne možete dodati u `~/.config/omarchy/backgrounds/[theme]`. Ako želite dodati dodatnu sliku pozadine, recimo, temi nord, samo stavite datoteku u `~/.config/omarchy/backgrounds/nord`.

To najlakše možete napraviti tako da u izborniku Omarchy odete na _Install > Style > Background_. Time će se prikazati mapa u kojoj se pohranjuju pozadine za tu temu. Pritisnite `Super + Shift + F` da biste pokrenuli drugi upravitelj datoteka, pronađite svoju pozadinu i kopirajte je ovamo. Sada će biti uključena u izbor pozadina među kojima možete birati pomoću `Super + Ctrl + W`.

Pozadine mogu biti i videozapisi, a ne samo statične slike. Ubacite datoteku `mp4`, `m4v`, `mov`, `webm`, `mkv` ili `avi` u istu mapu i pojavit će se uz slike. Videozapise reproducira OWE pogon za pozadine. Video dekodira jednom za sve monitore i reproducira njegov zvuk preko zadanog audioizlaza te zaustavlja reprodukciju kad god ga ništa ne može vidjeti. Video pozadina i dalje troši daleko više energije od statične.

Teme mogu sadržavati kratki uvod za statičnu pozadinu. Za `backgrounds/road.webp` odgovarajući videozapis nalazi se na `backgrounds/intros/road.mp4`. Reproducira se automatski pri pokretanju sustava, pri prelasku na temu s odabranom tom pozadinom i pri odabiru te pozadine, a zatim se vraća na statičnu sliku. Uvodni videozapisi ne pojavljuju se u biraču pozadina i nikada se ne reproduciraju u petlji.

Isključivanje opcije _Appearance > Animations_ također isključuje uvode za pozadine. Omarchy to prema zadanim postavkama čini u virtualnom stroju. Naredba `omarchy theme bg intro toggle` može zasebno uključivati i isključivati uvode. Osvježavanje teme ne reproducira uvod.

Statična slika može imati i petlju, tihu verziju iste slike koja se neprestano kreće, na `backgrounds/loops/road.mp4`. Reproducira se umjesto statične slike, nakon njezina uvoda ako ga ima, i zaustavlja se kada se animacije isključe. Petlje se ne pojavljuju u biraču pozadina i, kao i svaka video pozadina, troše više energije od statične slike.

Ogromnu zbirku sjajnih odabranih pozadina možete pronaći u [dharmx/walls](https://github.com/dharmx/walls).

Zaslon za zaključavanje prikazuje statični kadar video pozadine, na isti način na koji prikazuje statični kadar animiranog GIF-a.
