# Fundaluri

Fiecare temă vine cu propriul set de fundaluri și poți adăuga și altele de ale tale în `~/.config/omarchy/backgrounds/[theme]`. Dacă vrei să adaugi o imagine de fundal suplimentară, să zicem, la tema nord, pur și simplu pui fișierul în `~/.config/omarchy/backgrounds/nord`.

Cel mai ușor faci asta accesând _Instalare > Stil > Fundal_ în Meniul Omarchy. Se va deschide folderul în care sunt stocate fundalurile pentru tema respectivă. Apasă `Super + Shift + F` pentru a porni alt manager de fișiere, găsește fundalul tău și copiază-l acolo. Acum va fi inclus între opțiunile de fundaluri între care poți alege folosind `Super + Ctrl + W`.

Fundalurile pot fi și videoclipuri, nu doar imagini statice. Plasează un fișier `mp4`, `m4v`, `mov`, `webm`, `mkv` sau `avi` în același folder și va apărea alături de imagini. Videoclipurile sunt redate de motorul de fundaluri OWE. Acesta decodează videoclipul o singură dată pentru toate monitoarele, redă sunetul prin ieșirea audio implicită și oprește redarea ori de câte ori nimic nu-l poate vedea. Un fundal video consumă totuși mult mai multă energie decât unul static.

Temele pot include un scurt intro pentru un fundal static. Pentru `backgrounds/road.webp`, videoclipul corespunzător se află la `backgrounds/intros/road.mp4`. Acesta este redat automat la pornire, la trecerea la o temă cu acel fundal selectat și la alegerea acelui fundal, apoi revine la imaginea statică. Videoclipurile intro rămân în afara selectorului de fundaluri și nu se repetă niciodată în buclă.

Dezactivarea opțiunii _Aspect > Animații_ dezactivează și intro-urile de fundal. Omarchy face acest lucru în mod implicit într-o mașină virtuală. Comanda `omarchy theme bg intro toggle` poate activa sau dezactiva intro-urile separat. Reîmprospătarea unei teme nu redă un intro.

O imagine statică poate avea și o buclă, o versiune discretă a aceleiași imagini care continuă să se miște, la `backgrounds/loops/road.mp4`. Aceasta este redată în locul imaginii statice, după intro-ul acesteia, dacă are unul, și se oprește când animațiile sunt dezactivate. Pe baterie, în locul ei este afișată imaginea statică, iar bucla revine de îndată ce conectezi alimentarea. Buclele rămân în afara selectorului de fundaluri.

Poți găsi o colecție uriașă de fundaluri grozave, atent selectate, în [dharmx/walls](https://github.com/dharmx/walls).

Ecranul de blocare afișează un cadru static dintr-un fundal video, la fel cum afișează un cadru static dintr-un GIF animat.
