# Tła

Każdy motyw jest dostarczany z własnym zestawem teł, a własne dodatki możesz umieścić w `~/.config/omarchy/backgrounds/[theme]`. Jeśli chcesz dodać dodatkowe tło, na przykład do motywu nord, po prostu umieść plik w `~/.config/omarchy/backgrounds/nord`.

Najłatwiej zrobisz to, przechodząc do _Install > Style > Background_ w Menu Omarchy. Spowoduje to otwarcie folderu, w którym przechowywane są tła dla tego motywu. Naciśnij `Super + Shift + F`, aby uruchomić kolejny menedżer plików, znajdź swoje tło i skopiuj je tam. Teraz będzie ono dostępne wśród teł, między którymi możesz wybierać za pomocą `Super + Ctrl + W`.

Tła mogą być filmami, a nie tylko obrazami statycznymi. Umieść plik `mp4`, `m4v`, `mov`, `webm`, `mkv` lub `avi` w tym samym folderze, a pojawi się on obok obrazów. Filmy są odtwarzane przez silnik tapet OWE. Dekoduje on film raz dla wszystkich monitorów i odtwarza jego dźwięk przez domyślne wyjście audio, a także zatrzymuje odtwarzanie, gdy nic go nie widzi. Tapeta wideo nadal zużywa znacznie więcej energii niż statyczna.

Motywy mogą zawierać krótkie intro dla statycznego tła. Dla `backgrounds/road.webp` odpowiadający mu film znajduje się w `backgrounds/intros/road.mp4`. Jest on odtwarzany automatycznie podczas uruchamiania i po przełączeniu na motyw z wybranym tym tłem, a następnie wraca do obrazu statycznego. Filmy intro nie pojawiają się w selektorze teł i nigdy nie są zapętlane.

Wyłączenie _Appearance > Animations_ wyłącza również intra teł. Omarchy robi to domyślnie w maszynie wirtualnej. Polecenie `omarchy theme bg intro toggle` może przełączać intra osobno. Odświeżenie motywu lub wybranie innego tła w ramach tego samego motywu nie odtwarza intra.

Ogromną kolekcję świetnych, starannie wybranych teł znajdziesz na https://github.com/dharmx/walls.

Ekran blokady pokazuje nieruchomą klatkę tła wideo, w ten sam sposób, w jaki pokazuje nieruchomą klatkę animowanego GIF.
