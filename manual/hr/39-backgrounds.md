# Pozadine

Svaka tema dolazi s vlastitim skupom pozadina, a u `~/.config/omarchy/backgrounds/[theme]` možete dodati i vlastite dodatke. Ako, recimo, temi nord želite dodati dodatnu sliku pozadine, datoteku samo stavite u `~/.config/omarchy/backgrounds/nord`.

To najlakše možete učiniti tako da u izborniku Omarchy odete na _Install > Style > Background_. Time ćete otvoriti mapu u kojoj su pohranjene pozadine za tu temu. Pritisnite `Super + Shift + F` za pokretanje drugog upravitelja datoteka, pronađite svoju pozadinu i kopirajte je preko. Sada će biti uključena među pozadine koje možete birati pomoću `Super + Ctrl + W`.

Pozadine mogu biti i videozapisi, a ne samo statične slike. Ubacite datoteku `mp4`, `m4v`, `mov`, `webm`, `mkv` ili `avi` u istu mapu i pojavit će se uz slike. Videozapise reproducira pogon za pozadine OWE. Dekodira videozapis jednom za sve monitore i reproducira njegov zvuk preko zadanog audio izlaza, a zaustavlja reprodukciju kad god ga ništa ne može vidjeti. Videopozadina i dalje troši daleko više energije od statične pozadine.

Teme mogu sadržavati kratki uvod za statičnu pozadinu. Za `backgrounds/road.webp` odgovarajući videozapis nalazi se na `backgrounds/intros/road.mp4`. Reproducira se automatski pri pokretanju sustava, pri prelasku na temu s odabranom tom pozadinom i pri odabiru te pozadine, a zatim se vraća na statičnu sliku. Uvodni videozapisi ne prikazuju se u biraču pozadina i nikada se ne ponavljaju u petlji.

Isključivanje opcije _Appearance > Animations_ isključuje i uvode pozadina. Omarchy to prema zadanim postavkama čini u virtualnom stroju. Naredba `omarchy theme bg intro toggle` može zasebno uključiti ili isključiti uvode. Osvježavanje teme ne reproducira uvod.

Statična slika može imati i petlju, mirnu verziju iste slike koja se neprestano kreće, na `backgrounds/loops/road.mp4`. Reproducira se umjesto statične slike, nakon njezina uvoda ako ga ima, i zaustavlja se kada se animacije isključe. Na bateriji se umjesto nje prikazuje statična slika, a petlja se vraća čim priključite napajanje. Petlje se ne prikazuju u biraču pozadina.

Veliku zbirku sjajnih odabranih pozadina možete pronaći u [dharmx/walls](https://github.com/dharmx/walls).

Zaključani zaslon prikazuje statični kadar videopozadine, na isti način na koji prikazuje statični kadar animiranog GIF-a.
