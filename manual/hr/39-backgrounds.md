# Pozadine

Svaka tema dolazi s vlastitim skupom pozadina, a svoje dodatne pozadine možete dodati u `~/.config/omarchy/backgrounds/[theme]`. Ako želite dodati dodatnu sliku pozadine, recimo, temi nord, jednostavno stavite datoteku u `~/.config/omarchy/backgrounds/nord`.

To najlakše možete napraviti tako da u izborniku Omarchy odete na _Install > Style > Background_. Time će se otvoriti mapa u kojoj su pohranjene pozadine za tu temu. Pritisnite `Super + Shift + F` kako biste pokrenuli drugi upravitelj datoteka, pronađite svoju pozadinu i kopirajte je ovamo. Sada će biti uključena u pozadine između kojih možete birati pomoću `Super + Ctrl + W`.

Pozadine mogu biti videozapisi, a ne samo nepomične slike. U istu mapu stavite datoteku `mp4`, `m4v`, `mov`, `webm`, `mkv` ili `avi` i pojavit će se uz slike. Videozapise reproducira OWE mehanizam za pozadine. Videozapis dekodira jednom za sve monitore, njegov zvuk reproducira putem zadanog audioizlaza i zaustavlja reprodukciju kad god ga ništa ne može vidjeti. Videopozadina i dalje troši daleko više energije nego nepomična pozadina.

Teme mogu uključivati kratki uvod za nepomičnu pozadinu. Za `backgrounds/road.webp` odgovarajući videozapis nalazi se na `backgrounds/intros/road.mp4`. Automatski se reproducira pri pokretanju sustava, pri prelasku na temu s odabranom tom pozadinom i pri odabiru te pozadine, a zatim se vraća na nepomičnu sliku. Uvodni videozapisi ne pojavljuju se u biraču pozadina i nikada se ne reproduciraju u petlji.

Odabir _Appearance > Animations Off_ također isključuje uvode za pozadine. Omarchy to prema zadanim postavkama radi u virtualnom stroju. Naredba `omarchy theme bg intro toggle` može zasebno uključiti i isključiti uvode. Osvježavanje teme ne reproducira uvod.

Nepomična slika može imati i petlju, mirnu verziju iste slike koja se neprestano kreće, na `backgrounds/loops/road.mp4`. Reproducira se umjesto nepomične slike, nakon njezina uvoda ako ga ima, i zaustavlja se kad se isključe animacije. Pri radu na bateriji umjesto nje prikazuje se nepomična slika, a petlja se vraća čim priključite napajanje. Petlje se ne pojavljuju u biraču pozadina.

Ogromnu zbirku sjajnih pomno odabranih pozadina možete pronaći u [dharmx/walls](https://github.com/dharmx/walls).

Zaključani zaslon prikazuje nepomični kadar videopozadine, na isti način na koji prikazuje nepomični kadar animiranog GIF-a.
