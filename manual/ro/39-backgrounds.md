# Fundaluri

Fiecare temă vine cu propriul set de fundaluri, iar tu poți adăuga extra ale tale în `~/.config/omarchy/backgrounds/[theme]`. Dacă vrei să adaugi o imagine de fundal suplimentară, să zicem, temei nord, pui pur și simplu fișierul în `~/.config/omarchy/backgrounds/nord`.

Poți face asta cel mai ușor mergând la _Instalează > Stil > Fundal_ în meniul Omarchy. Asta va deschide dosarul în care sunt stocate fundalurile pentru acea temă. Apasă `Super + Shift + F` ca să pornești alt manager de fișiere, găsește-ți fundalul, copiază-l acolo. Acum va fi inclus în opțiunile de fundaluri dintre care poți alege folosind `Super + Ctrl + Space`.

Fundalurile pot fi videoclipuri, precum și imagini statice. Pune un fișier `mp4`, `m4v`, `mov`, `webm`, `mkv` sau `avi` în același dosar și apare alături de imagini. Videoclipurile sunt redate de motorul de fundal OWE. Acesta decodează videoclipul o singură dată pentru toate monitoarele și îi redă sunetul prin ieșirea audio implicită, și oprește redarea ori de câte ori nimic nu îl poate vedea. Ecranul de blocare desenează aceeași decodare, fără sunet, prin OWE. Un fundal video costă totuși mult mai multă energie decât unul static.

Temele pot include o scurtă introducere pentru un fundal static. Pentru `backgrounds/road.webp`, videoclipul corespunzător trăiește la `backgrounds/intros/road.mp4`. Se redă automat la pornire și când treci la o temă cu acel fundal selectat, apoi revine la imaginea statică. Videoclipurile de introducere stau în afara selectorului de fundaluri și nu se repetă niciodată în buclă.

Dezactivarea _Declanșator > Aspect > Animații_ dezactivează și introducerile de fundal. Omarchy face asta implicit într-o mașină virtuală. Comanda `omarchy theme bg intro toggle` poate comuta introducerile separat. Reîmprospătarea unei teme sau alegerea altui fundal în cadrul aceleiași teme nu redă o introducere.

Poți găsi o colecție uriașă de fundaluri grozave, selectate cu grijă, la https://github.com/dharmx/walls.

Fundalurile video păstrează o imagine statică în cache pe ecranul de blocare cât timp redarea este întreruptă sau indisponibilă. GIF-urile animate se redau pe desktop și arată un cadru static pe ecranul de blocare.
