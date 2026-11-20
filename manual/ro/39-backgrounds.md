# Fundaluri

Fiecare temă vine cu propriul său set de fundaluri, iar tu poți adăuga unele suplimentare, ale tale, în `~/.config/omarchy/backgrounds/[theme]`. Dacă vrei să adaugi o imagine de fundal suplimentară, să zicem, la tema nord, pui pur și simplu fișierul în `~/.config/omarchy/backgrounds/nord`.

Cel mai ușor faci asta accesând _Install > Style > Background_ în Omarchy Menu. Asta va deschide folderul în care sunt stocate fundalurile pentru tema respectivă. Apasă `Super + Shift + F` pentru a porni un alt file manager, găsește-ți fundalul, copiază-l acolo. Acum va fi inclus în opțiunile de fundaluri între care poți alege folosind `Super + Ctrl + W`.

Fundalurile pot fi și videoclipuri, nu doar imagini statice. Pune un fișier `mp4`, `m4v`, `mov`, `webm`, `mkv` sau `avi` în același folder și va apărea alături de imagini. Videoclipurile sunt redate de motorul de wallpaper OWE. Acesta decodează videoclipul o singură dată pentru toate monitoarele și redă sunetul prin ieșirea audio implicită și oprește redarea ori de câte ori nimic nu îl poate vedea. Un fundal video consumă totuși mult mai multă energie decât unul static.

Temele pot include un scurt intro pentru un fundal static. Pentru `backgrounds/road.webp`, videoclipul corespunzător se află la `backgrounds/intros/road.mp4`. Acesta se redă automat la pornire, la trecerea la o temă cu acel fundal selectat și la alegerea acelui fundal, apoi revine la imaginea statică. Videoclipurile intro rămân în afara selectorului de fundaluri și nu se redau niciodată în buclă.

Dezactivarea _Appearance > Animations_ dezactivează și intro-urile de fundal. Omarchy face acest lucru în mod implicit într-o mașină virtuală. Comanda `omarchy theme bg intro toggle` poate comuta intro-urile separat. Reîmprospătarea unei teme nu redă un intro.

O imagine statică poate avea și o buclă, o versiune liniștită a aceleiași imagini care continuă să se miște, la `backgrounds/loops/road.mp4`. Acesta se redă în locul imaginii statice, după intro-ul acesteia, dacă are unul, și se oprește atunci când animațiile sunt dezactivate. Buclele rămân în afara selectorului de fundaluri și, la fel ca orice fundal video, consumă mai multă energie decât o imagine statică.

Poți găsi o colecție uriașă de fundaluri grozave, selectate cu grijă, în [dharmx/walls](https://github.com/dharmx/walls).

Ecranul de blocare arată un cadru static al unui fundal video, la fel cum arată un cadru static al unui GIF animat.
