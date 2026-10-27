# Pozadine

Svaka tema dolazi s vlastitim skupom pozadina, a svoje dodatne pozadine možete dodati u `~/.config/omarchy/backgrounds/[theme]`. Ako, primjerice, želite dodati dodatnu sliku pozadine temi nord, jednostavno stavite datoteku u `~/.config/omarchy/backgrounds/nord`.

Najlakše to možete učiniti tako da u izborniku Omarchy odete na _Instalacija > Stil > Pozadina_. To će otvoriti mapu u kojoj su pohranjene pozadine za tu temu. Pritisnite `Super + Shift + F` kako biste pokrenuli drugi upravitelj datoteka, pronađite svoju pozadinu i kopirajte je ovamo. Sada će biti uključena među pozadine između kojih možete birati pomoću `Super + Ctrl + W`.

Pozadine mogu biti i videozapisi, a ne samo statične slike. U istu mapu stavite datoteku `mp4`, `m4v`, `mov`, `webm`, `mkv` ili `avi` i pojavit će se uz slike. Videozapise reproducira OWE pogon za pozadine. On dekodira videozapis jednom za sve monitore, reproducira njegov zvuk preko zadanog audio izlaza i zaustavlja reprodukciju kad god ga ništa ne može vidjeti. Videopozadina i dalje troši daleko više energije od statične pozadine.

Teme mogu uključivati kratki uvod za statičnu pozadinu. Za `backgrounds/road.webp` odgovarajući videozapis nalazi se na `backgrounds/intros/road.mp4`. Automatski se reproducira pri pokretanju sustava i pri prebacivanju na temu s odabranom tom pozadinom, a zatim se vraća na statičnu sliku. Uvodni videozapisi ne prikazuju se u biraču pozadina i nikada se ne ponavljaju u petlji.

Isključivanje opcije _Izgled > Animacije_ također isključuje uvode za pozadine. Omarchy to prema zadanim postavkama čini u virtualnom stroju. Naredba `omarchy theme bg intro toggle` može zasebno uključiti ili isključiti uvode. Osvježavanje teme ili odabir druge pozadine unutar iste teme ne reproducira uvod.

Veliku zbirku sjajnih, pažljivo odabranih pozadina možete pronaći u [dharmx/walls](https://github.com/dharmx/walls).

Zaslon za zaključavanje prikazuje statični kadar videopozadine, na isti način na koji prikazuje statični kadar animiranog GIF-a.
