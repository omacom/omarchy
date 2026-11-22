# Fundaluri

Fiecare temă vine cu propriul set de fundaluri, iar tu poți adăuga altele ale tale în `~/.config/omarchy/backgrounds/[theme]`. Dacă vrei să adaugi o imagine de fundal suplimentară, să zicem, pentru tema nord, pur și simplu pui fișierul în `~/.config/omarchy/backgrounds/nord`.

Cel mai ușor poți face asta accesând _Install > Style > Background_ în Meniul Omarchy. Astfel se va deschide folderul în care sunt stocate fundalurile pentru tema respectivă. Apasă `Super + Shift + F` pentru a porni un alt manager de fișiere, găsește fundalul tău și copiază-l acolo. Acum va fi inclus în opțiunile de fundaluri dintre care poți alege folosind `Super + Ctrl + W`.

Fundalurile pot fi și videoclipuri, nu doar imagini statice. Plasează un fișier `mp4`, `m4v`, `mov`, `webm`, `mkv` sau `avi` în același folder și va apărea alături de imagini. Videoclipurile sunt redate de motorul de fundal OWE. Acesta decodează videoclipul o singură dată pentru toate monitoarele, redă sunetul prin ieșirea audio implicită și oprește redarea ori de câte ori nu îl poate vedea nimeni. Un fundal video consumă totuși mult mai multă energie decât unul static.

Temele pot include o scurtă introducere pentru un fundal static. Pentru `backgrounds/road.webp`, videoclipul corespunzător se află la `backgrounds/intros/road.mp4`. Acesta este redat automat la pornire, la trecerea la o temă cu fundalul respectiv selectat și la alegerea fundalului respectiv, apoi revine la imaginea statică. Videoclipurile introductive nu apar în selectorul de fundaluri și nu se redau niciodată în buclă.

Alegerea opțiunii _Appearance > Animations Off_ dezactivează și introducerile de fundal. Omarchy face acest lucru implicit într-o mașină virtuală. Comanda `omarchy theme bg intro toggle` poate activa sau dezactiva introducerile separat. Reîmprospătarea unei teme nu redă o introducere.

O imagine statică poate avea și o buclă, o versiune discretă a aceleiași imagini care continuă să se miște, la `backgrounds/loops/road.mp4`. Aceasta este redată în locul imaginii statice, după introducerea acesteia, dacă are una, și se oprește când animațiile sunt dezactivate. Pe baterie, în locul ei este afișată imaginea statică, iar bucla revine odată ce conectezi alimentarea. Buclele nu apar în selectorul de fundaluri.

Poți găsi o colecție uriașă de fundaluri excelente, selectate cu grijă, în [dharmx/walls](https://github.com/dharmx/walls).

Ecranul de blocare afișează un cadru static al unui fundal video, la fel cum afișează un cadru static al unui GIF animat.
