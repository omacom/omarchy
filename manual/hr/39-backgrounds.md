# Pozadine

Svaka tema isporučuje se s vlastitim skupom pozadina, a možete dodati i vlastite dodatke u `~/.config/omarchy/backgrounds/[theme]`. Ako želite dodati dodatnu sliku pozadine, recimo, nord temi, samo stavite datoteku u `~/.config/omarchy/backgrounds/nord`.

To najlakše možete učiniti odlaskom na _Install > Style > Background_ u Omarchy Menu. To će otvoriti mapu u kojoj su pohranjene pozadine za tu temu. Pritisnite `Super + Shift + F` da biste pokrenuli drugi upravitelj datoteka, pronađite svoju pozadinu i kopirajte je. Sada će biti uključena u izbor pozadina između kojih možete birati pomoću `Super + Ctrl + W`.

Pozadine mogu biti i videozapisi, a ne samo statične slike. Ubacite datoteku `mp4`, `m4v`, `mov`, `webm`, `mkv` ili `avi` u istu mapu i pojavit će se uz slike. Videozapise reproducira OWE wallpaper engine. On dekodira videozapis jednom za sve monitore i reproducira njegov zvuk preko zadanog audioizlaza, a zaustavlja reprodukciju kad god ga ništa ne može vidjeti. Video pozadina i dalje troši daleko više energije od statične.

Teme mogu uključivati kratki uvod za statičnu pozadinu. Za `backgrounds/road.webp`, odgovarajući videozapis nalazi se na `backgrounds/intros/road.mp4`. Automatski se reproducira pri pokretanju sustava, pri prebacivanju na temu s odabranom tom pozadinom i pri odabiru te pozadine, a zatim se vraća na statičnu sliku. Uvodni videozapisi ne prikazuju se u biraču pozadina i nikada se ne ponavljaju u petlji.

Isključivanje opcije _Appearance > Animations_ također isključuje uvode za pozadine. Omarchy to prema zadanim postavkama radi u virtualnom stroju. Naredba `omarchy theme bg intro toggle` može zasebno uključiti ili isključiti uvode. Osvježavanje teme ne reproducira uvod.

Veliku zbirku cool odabranih pozadina možete pronaći u [dharmx/walls](https://github.com/dharmx/walls).

Zaključani zaslon prikazuje statični kadar video pozadine, na isti način na koji prikazuje statični kadar animiranog GIF-a.
