# Fundaluri

Fiecare temă vine cu propriul set de fundaluri și poți adăuga unele suplimentare ale tale în `~/.config/omarchy/backgrounds/[theme]`. Dacă vrei să adaugi o imagine de fundal suplimentară, să zicem, la tema nord, pur și simplu pui fișierul în `~/.config/omarchy/backgrounds/nord`.

Poți face asta cel mai ușor mergând la _Install > Style > Background_ în Omarchy Menu. Asta va deschide folderul în care sunt stocate fundalurile pentru tema respectivă. Apasă `Super + Shift + F` pentru a porni alt manager de fișiere, găsește fundalul tău, copiază-l acolo. Acum va fi inclus în opțiunile de fundaluri între care poți alege folosind `Super + Ctrl + W`.

O temă fără fundaluri proprii primește unul desenat din culorile ei: sigla Omarchy în culoarea de accent a temei, pe culoarea ei de fundal. Adaugă-le pe ale tale pentru a-l înlocui.

Fundalurile pot fi și videoclipuri, nu doar imagini statice. Lasă un fișier `mp4`, `m4v`, `mov`, `webm`, `mkv` sau `avi` în același folder și va apărea alături de imagini. Videoclipurile sunt redate de motorul de fundal OWE. Acesta decodează videoclipul o singură dată pentru toate monitoarele și îi redă sunetul prin ieșirea audio implicită și oprește redarea ori de câte ori nimic nu-l poate vedea. Un fundal video consumă totuși mult mai multă energie decât unul static.

Temele pot include o scurtă introducere pentru un fundal static. Pentru `backgrounds/road.webp`, videoclipul corespunzător se află la `backgrounds/intros/road.mp4`. Se redă automat la pornire, la trecerea la o temă cu acel fundal selectat și la alegerea acelui fundal, apoi revine la imaginea statică. Videoclipurile de introducere nu apar în selectorul de fundaluri și nu se repetă niciodată în buclă.

Alegerea _Appearance > Animations Off_ dezactivează și introducerile de fundal. Omarchy face asta implicit într-o mașină virtuală. Comanda `omarchy theme bg intro toggle` poate comuta introducerile separat. Reîmprospătarea unei teme nu redă o introducere.

O imagine statică poate avea și o buclă, o versiune discretă a aceleiași imagini care continuă să se miște, la `backgrounds/loops/road.mp4`. Se redă în locul imaginii statice, după introducerea ei, dacă are una, și se oprește când animațiile sunt dezactivate. Pe baterie, în schimb este afișată imaginea statică, iar bucla revine de îndată ce conectezi alimentarea. Buclele nu apar în selectorul de fundaluri.

Poți găsi o colecție uriașă de fundaluri tari, selectate cu grijă, în [dharmx/walls](https://github.com/dharmx/walls).

Ecranul de blocare afișează un cadru static dintr-un fundal video, la fel cum afișează un cadru static dintr-un GIF animat.
