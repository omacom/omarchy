# Fundaluri

Fiecare temă vine cu propriul set de fundaluri și poți adăuga altele, ale tale, în `~/.config/omarchy/backgrounds/[theme]`. Dacă vrei să adaugi o imagine de fundal suplimentară, să zicem, temei nord, trebuie doar să pui fișierul în `~/.config/omarchy/backgrounds/nord`.

Cel mai ușor poți face asta mergând la _Instalare > Stil > Fundal_ în meniul Omarchy. Asta va deschide folderul în care sunt stocate fundalurile pentru tema respectivă. Apasă `Super + Shift + F` pentru a porni alt manager de fișiere, găsește-ți fundalul și copiază-l acolo. Acum va fi inclus între variantele de fundaluri dintre care poți alege folosind `Super + Ctrl + W`.

Fundalurile pot fi și videoclipuri, nu doar imagini statice. Pune un fișier `mp4`, `m4v`, `mov`, `webm`, `mkv` sau `avi` în același folder și va apărea alături de imagini. Videoclipurile sunt redate de motorul de fundaluri OWE. Acesta decodează videoclipul o singură dată pentru toate monitoarele, redă sunetul prin ieșirea audio implicită și oprește redarea ori de câte ori nimic nu îl poate vedea. Un fundal video consumă totuși mult mai multă energie decât unul static.

Temele pot include o scurtă introducere pentru un fundal static. Pentru `backgrounds/road.webp`, videoclipul corespunzător se află la `backgrounds/intros/road.mp4`. Se redă automat la pornire și când se trece la o temă cu fundalul respectiv selectat, apoi revine la imaginea statică. Videoclipurile de introducere nu apar în selectorul de fundaluri și nu se repetă niciodată.

Dezactivarea _Aspect > Animații_ dezactivează și introducerile pentru fundaluri. Omarchy face asta implicit într-o mașină virtuală. Comanda `omarchy theme bg intro toggle` poate activa sau dezactiva separat introducerile. Reîmprospătarea unei teme sau alegerea altui fundal din aceeași temă nu redă o introducere.

Poți găsi o colecție uriașă de fundaluri faine, atent selecționate, pe https://github.com/dharmx/walls.

Ecranul de blocare afișează un cadru static dintr-un fundal video, la fel cum afișează un cadru static dintr-un GIF animat.
