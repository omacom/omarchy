# Fundaluri

Fiecare temă vine cu propriul set de fundaluri, iar tu poți adăuga altele proprii în `~/.config/omarchy/backgrounds/[theme]`. Dacă vrei să adaugi o imagine de fundal suplimentară, să spunem, temei nord, pui pur și simplu fișierul în `~/.config/omarchy/backgrounds/nord`.

Cel mai ușor poți face asta accesând _Instalare > Stil > Fundal_ în meniul Omarchy. Asta va deschide folderul în care sunt stocate fundalurile pentru tema respectivă. Apasă `Super + Shift + F` pentru a porni un alt manager de fișiere, găsește fundalul tău și copiază-l acolo.  Acum va fi inclus printre fundalurile dintre care poți alege folosind `Super + Ctrl + W`.

Fundalurile pot fi și videoclipuri, nu doar imagini statice. Pune un fișier `mp4`, `m4v`, `mov`, `webm`, `mkv` sau `avi` în același folder și va apărea alături de imagini. Videoclipurile sunt redate de motorul de fundal OWE. Acesta decodează videoclipul o singură dată pentru toate monitoarele și îi redă sunetul prin ieșirea audio implicită, și oprește redarea de fiecare dată când nimic nu îl poate vedea. Un fundal video costă totuși mult mai multă energie decât unul static.

Temele pot include o scurtă introducere pentru un fundal static. Pentru `backgrounds/road.webp`, videoclipul corespunzător se află la `backgrounds/intros/road.mp4`. Acesta rulează automat la pornire, la trecerea la o temă cu fundalul respectiv selectat și la alegerea acelui fundal, apoi revine la imaginea statică. Videoclipurile de introducere nu apar în selectorul de fundaluri și nu rulează niciodată în buclă.

Dezactivarea opțiunii _Aspect > Animații_ dezactivează și introducerile de fundal. Omarchy face asta implicit într-o mașină virtuală. Comanda `omarchy theme bg intro toggle` poate comuta introducerile separat. Reîmprospătarea unei teme nu redă o introducere.

Poți găsi o colecție uriașă de fundaluri cool, atent selecționate, în [dharmx/walls](https://github.com/dharmx/walls).

Ecranul de blocare afișează un cadru static al unui fundal video, la fel cum afișează un cadru static al unui GIF animat.
