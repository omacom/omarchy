# Tła

Każdy motyw ma własny zestaw teł, a własne dodatki możesz dodać w `~/.config/omarchy/backgrounds/[theme]`. Jeśli chcesz dodać dodatkowe tło, na przykład do motywu nord, po prostu umieść plik w `~/.config/omarchy/backgrounds/nord`.

Najłatwiej zrobisz to, przechodząc do _Instaluj > Styl > Tło_ w menu Omarchy. Spowoduje to otwarcie folderu, w którym przechowywane są tła dla tego motywu. Naciśnij `Super + Shift + F`, aby uruchomić kolejny menedżer plików, znajdź swoje tło i skopiuj je tam. Teraz będzie ono uwzględnione wśród teł, między którymi możesz przełączać się za pomocą `Super + Ctrl + W`.

Tła mogą być również filmami, a nie tylko obrazami statycznymi. Umieść plik `mp4`, `m4v`, `mov`, `webm`, `mkv` lub `avi` w tym samym folderze, a pojawi się on obok obrazów. Filmy są odtwarzane przez silnik tapet OWE. Dekoduje on film raz dla wszystkich monitorów i odtwarza jego dźwięk przez domyślne wyjście audio, a także zatrzymuje odtwarzanie, gdy nic go nie widzi. Tapeta filmowa nadal zużywa znacznie więcej energii niż statyczna.

Motywy mogą zawierać krótkie intro dla statycznego tła. Dla `backgrounds/road.webp` odpowiadający mu film znajduje się w `backgrounds/intros/road.mp4`. Jest on odtwarzany automatycznie podczas uruchamiania, przy przełączaniu na motyw z wybranym tym tłem oraz przy wyborze tego tła, a następnie wraca do obrazu statycznego. Filmy intro nie pojawiają się w selektorze teł i nigdy się nie zapętlają.

Wyłączenie _Wygląd > Animacje_ wyłącza również intra teł. Omarchy robi to domyślnie w maszynie wirtualnej. Polecenie `omarchy theme bg intro toggle` może przełączać intra osobno. Odświeżenie motywu nie odtwarza intra.

Statyczny obraz może mieć również zapętlenie, spokojną wersję tego samego obrazu, która pozostaje w ruchu, w `backgrounds/loops/road.mp4`. Jest ono odtwarzane zamiast obrazu statycznego, po jego intro, jeśli takie istnieje, i zatrzymuje się, gdy animacje są wyłączone. Zapętlenia nie pojawiają się w selektorze teł i, jak każde tło filmowe, zużywają więcej energii niż obraz statyczny.

Ogromną kolekcję fajnych, wyselekcjonowanych teł znajdziesz w [dharmx/walls](https://github.com/dharmx/walls).

Ekran blokady pokazuje nieruchomą klatkę tła filmowego, w ten sam sposób, w jaki pokazuje nieruchomą klatkę animowanego pliku GIF.
