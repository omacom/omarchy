# Pozadine

Svaka tema isporučuje se s vlastitim skupom pozadina, a vlastite dodatne možete dodati u `~/.config/omarchy/backgrounds/[theme]`. Ako želite dodati dodatnu pozadinsku sliku, recimo, temi nord, samo stavite datoteku u `~/.config/omarchy/backgrounds/nord`.

To najlakše možete učiniti odlaskom na _Install > Style > Background_ u izborniku Omarchy Menu. Time će se otvoriti mapa u kojoj su pohranjene pozadine za tu temu. Pritisnite `Super + Shift + F` da pokrenete drugi upravitelj datoteka, pronađite svoju pozadinu i kopirajte je tamo. Sada će biti uključena u izbor pozadina među kojima možete birati pomoću `Super + Ctrl + W`.

Tema koja nema vlastitih pozadina dobiva jednu nacrtanu iz svojih boja: logotip Omarchy u naglasnoj boji teme na njezinoj boji pozadine. Dodajte vlastitu da je zamijenite.

Pozadine mogu biti videozapisi kao i statične slike. Ubacite datoteku `mp4`, `m4v`, `mov`, `webm`, `mkv` ili `avi` u istu mapu i pojavit će se uz slike. Videozapise reproducira OWE wallpaper engine. Dekodira videozapis jednom za sve monitore i reproducira njegov zvuk preko zadanog audio izlaza te zaustavlja reprodukciju kad god ga ništa ne može vidjeti. Videopozadina ipak troši daleko više energije od statične.

Teme mogu uključivati kratki uvod za statičnu pozadinu. Za `backgrounds/road.webp` odgovarajući videozapis nalazi se na `backgrounds/intros/road.mp4`. Reproducira se automatski pri pokretanju, pri prebacivanju na temu s odabranom tom pozadinom i pri odabiru te pozadine, a zatim se vraća na statičnu sliku. Uvodni videozapisi ne prikazuju se u biraču pozadina i nikada se ne vrte u petlji.

Odabir _Appearance > Animations Off_ također isključuje uvode pozadina. Omarchy to prema zadanim postavkama radi u virtualnom stroju. Naredba `omarchy theme bg intro toggle` može zasebno uključivati i isključivati uvode. Osvježavanje teme ne reproducira uvod.

Statična slika može imati i petlju, tihu verziju iste slike koja se stalno kreće, na `backgrounds/loops/road.mp4`. Reproducira se umjesto statične slike, nakon njezina uvoda ako ga ima, i zaustavlja se kad se animacije isključe. Na bateriji se umjesto nje prikazuje statična slika, a petlja se vraća čim priključite napajanje. Petlje se ne prikazuju u biraču pozadina.

Ogromnu zbirku sjajnih odabranih pozadina možete pronaći u [dharmx/walls](https://github.com/dharmx/walls).

Zaključani zaslon prikazuje statični kadar videopozadine, na isti način na koji prikazuje statični kadar animiranog GIF-a.
