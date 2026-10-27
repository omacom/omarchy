# Fundaluri

Fiecare temă vine cu propriul set de fundaluri, iar tu poți adăuga altele ale tale în `~/.config/omarchy/backgrounds/[theme]`. Dacă vrei să adaugi o imagine de fundal suplimentară, să zicem, temei nord, pui pur și simplu fișierul în `~/.config/omarchy/backgrounds/nord`.

Poți face asta cel mai ușor mergând la _Install > Style > Background_ în Omarchy Menu. Asta va deschide folderul în care sunt stocate fundalurile pentru tema respectivă. Apasă `Super + Shift + F` pentru a porni alt manager de fișiere, găsește-ți fundalul și copiază-l acolo. Acum va fi inclus în fundalurile dintre care poți alege folosind `Super + Ctrl + W`.

Fundalurile pot fi și videoclipuri, nu doar imagini statice. Pune un fișier `mp4`, `m4v`, `mov`, `webm`, `mkv` sau `avi` în același folder și va apărea alături de imagini. Videoclipurile sunt redate de motorul de wallpaper OWE. Acesta decodează videoclipul o singură dată pentru toate monitoarele și îi redă sunetul prin ieșirea audio implicită și oprește redarea ori de câte ori nimic nu îl poate vedea. Un fundal video tot costă mult mai multă energie decât unul static.

Temele pot include o scurtă introducere pentru un fundal static. Pentru `backgrounds/road.webp`, videoclipul corespunzător se află la `backgrounds/intros/road.mp4`. Acesta se redă automat la pornire și la comutarea la o temă cu acel fundal selectat, apoi revine la imaginea statică. Videoclipurile introductive nu apar în selectorul de fundaluri și nu se repetă niciodată în buclă.

Dezactivarea _Appearance > Animations_ dezactivează și introducerile de fundal. Omarchy face asta în mod implicit într-o mașină virtuală. Comanda `omarchy theme bg intro toggle` poate comuta introducerile separat. Reîmprospătarea unei teme sau alegerea altui fundal din aceeași temă nu redă o introducere.

Poți găsi o colecție uriașă de fundaluri tari, selectate cu grijă, în [dharmx/walls](https://github.com/dharmx/walls).

Ecranul de blocare afișează un cadru static dintr-un fundal video, la fel cum afișează un cadru static dintr-un GIF animat.
