# Tła

Każdy motyw jest dostarczany z własnym zestawem teł, a własne dodatkowe tła możesz dodać w `~/.config/omarchy/backgrounds/[theme]`. Jeśli chcesz dodać dodatkowe zdjęcie tła, powiedzmy, do motywu nord, po prostu umieszczasz plik w `~/.config/omarchy/backgrounds/nord`.

Najłatwiej zrobisz to, przechodząc do _Install > Style > Background_ w Omarchy Menu. Spowoduje to otwarcie folderu, w którym przechowywane są tła dla tego motywu. Naciśnij `Super + Shift + F`, aby uruchomić kolejny menedżer plików, znajdź swoje tło i skopiuj je tam. Teraz będzie ono uwzględnione wśród teł, spośród których możesz wybierać za pomocą `Super + Ctrl + W`.

Tła mogą być również filmami, a nie tylko obrazami statycznymi. Wrzuć plik `mp4`, `m4v`, `mov`, `webm`, `mkv` lub `avi` do tego samego folderu, a pojawi się on obok obrazów. Filmy są odtwarzane przez silnik tapet OWE. Dekoduje on film raz dla wszystkich monitorów i odtwarza jego dźwięk przez domyślne wyjście audio oraz zatrzymuje odtwarzanie, gdy nic nie może go zobaczyć. Tapeta filmowa nadal zużywa znacznie więcej energii niż statyczna.

Motywy mogą zawierać krótkie intro dla statycznego tła. Dla `backgrounds/road.webp` pasujący film znajduje się w `backgrounds/intros/road.mp4`. Odtwarza się automatycznie przy uruchamianiu systemu oraz przy przełączaniu na motyw z wybranym tym tłem, a następnie wraca do obrazu statycznego. Filmy intro nie pojawiają się w selektorze teł i nigdy się nie zapętlają.

Wyłączenie _Appearance > Animations_ wyłącza również intra teł. Omarchy robi to domyślnie w maszynie wirtualnej. Polecenie `omarchy theme bg intro toggle` może przełączać intra osobno. Odświeżenie motywu lub wybranie innego tła w ramach tego samego motywu nie odtwarza intra.

Ogromną kolekcję fajnych, starannie wybranych teł znajdziesz w [dharmx/walls](https://github.com/dharmx/walls).

Ekran blokady pokazuje statyczną klatkę filmowego tła, w taki sam sposób, w jaki pokazuje statyczną klatkę animowanego pliku GIF.
