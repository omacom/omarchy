# Tła

Każdy motyw dostarcza własny zestaw teł, a własne dodatki możesz dodawać w `~/.config/omarchy/backgrounds/[theme]`. Jeśli chcesz dodać dodatkowe tło, powiedzmy, do motywu nord, po prostu umieszczasz plik w `~/.config/omarchy/backgrounds/nord`.

Najłatwiej zrobić to, przechodząc do _Instaluj > Styl > Tło_ w menu Omarchy. Otworzy to folder, w którym przechowywane są tła dla tego motywu. Naciśnij `Super + Shift + F`, aby uruchomić drugi menedżer plików, znajdź swoje tło i skopiuj je tam. Teraz będzie dostępne wśród teł, spośród których możesz wybierać skrótem `Super + Ctrl + Space`.

Tła mogą być filmami, a nie tylko nieruchomymi obrazami. Umieść plik `mp4`, `m4v`, `mov`, `webm`, `mkv` albo `avi` w tym samym folderze, a pojawi się obok obrazów. Filmy odtwarza silnik tapet OWE. Dekoduje on film raz dla wszystkich monitorów i odtwarza jego dźwięk przez domyślne wyjście audio, a odtwarzanie zatrzymuje zawsze, gdy nic go nie widzi. Ekran blokady rysuje to samo dekodowanie, wyciszone, przez OWE. Tapeta filmowa nadal kosztuje znacznie więcej energii niż nieruchoma.

Motywy mogą zawierać krótkie intro dla nieruchomego tła. Dla `backgrounds/road.webp` pasujący film mieszka w `backgrounds/intros/road.mp4`. Odtwarza się automatycznie przy rozruchu i przy przełączaniu na motyw z wybranym tym tłem, a potem wraca do nieruchomego obrazu. Filmy intro nie pojawiają się w wyborze teł i nigdy się nie zapętlają.

Wyłączenie _Akcje > Wygląd > Animacje_ wyłącza też intra teł. Omarchy robi to domyślnie w maszynie wirtualnej. Polecenie `omarchy theme bg intro toggle` może przełączać intra osobno. Odświeżenie motywu albo wybranie innego tła w ramach tego samego motywu nie odtwarza intra.

Ogromną kolekcję fajnych, starannie dobranych teł znajdziesz na https://github.com/dharmx/walls.

Tła filmowe zachowują na ekranie blokady buforowany nieruchomy obraz, gdy odtwarzanie jest wstrzymane albo niedostępne. Animowane GIF-y odtwarzają się na pulpicie i pokazują nieruchomą klatkę na ekranie blokady.
