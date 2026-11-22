# Tła

Każdy motyw jest dostarczany z własnym zestawem teł, a możesz dodać własne dodatkowe tła w `~/.config/omarchy/backgrounds/[theme]`. Jeśli chcesz dodać dodatkowe zdjęcie tła do, powiedzmy, motywu nord, po prostu umieść plik w `~/.config/omarchy/backgrounds/nord`.

Najłatwiej zrobisz to, przechodząc do _Install > Style > Background_ w Omarchy Menu. Spowoduje to otwarcie folderu, w którym przechowywane są tła dla tego motywu. Naciśnij `Super + Shift + F`, aby uruchomić kolejny menedżer plików, znajdź swoje tło i skopiuj je. Teraz będzie ono uwzględnione wśród teł, które możesz wybierać za pomocą `Super + Ctrl + W`.

Tła mogą być również filmami, a nie tylko obrazami statycznymi. Upuść plik `mp4`, `m4v`, `mov`, `webm`, `mkv` lub `avi` w tym samym folderze, a pojawi się obok obrazów. Filmy są odtwarzane przez silnik tapet OWE. Dekoduje on film raz dla wszystkich monitorów i odtwarza jego dźwięk przez domyślne wyjście audio, a także zatrzymuje odtwarzanie, gdy nic nie może go zobaczyć. Tapeta filmowa nadal zużywa znacznie więcej energii niż statyczna.

Motywy mogą zawierać krótkie intro dla statycznego tła. Dla `backgrounds/road.webp` odpowiadający mu film znajduje się w `backgrounds/intros/road.mp4`. Odtwarza się automatycznie przy starcie systemu, przy przełączaniu na motyw z wybranym tym tłem oraz przy wyborze tego tła, a następnie wraca do obrazu statycznego. Filmy intro nie pojawiają się w selektorze teł i nigdy się nie zapętlają.

Wybranie _Appearance > Animations Off_ wyłącza również intra teł. Omarchy robi to domyślnie w maszynie wirtualnej. Polecenie `omarchy theme bg intro toggle` może przełączać intra osobno. Odświeżenie motywu nie odtwarza intra.

Obraz statyczny może mieć również pętlę, cichą wersję tego samego obrazu, która pozostaje w ruchu, w `backgrounds/loops/road.mp4`. Odtwarza się ona w miejsce obrazu statycznego, po jego intrze, jeśli je ma, i zatrzymuje się, gdy animacje są wyłączone. Przy zasilaniu z baterii zamiast tego pokazuje się obraz statyczny, a pętla wraca po podłączeniu zasilania. Pętle nie pojawiają się w selektorze teł.

Ogromną kolekcję fajnych, starannie wybranych teł znajdziesz w [dharmx/walls](https://github.com/dharmx/walls).

Ekran blokady pokazuje statyczną klatkę tła filmowego, w ten sam sposób, w jaki pokazuje statyczną klatkę animowanego pliku GIF.
