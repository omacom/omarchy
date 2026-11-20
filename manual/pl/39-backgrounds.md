# Tła

Każdy motyw jest dostarczany z własnym zestawem teł, a własne dodatki możesz dodać w `~/.config/omarchy/backgrounds/[theme]`. Jeśli chcesz dodać dodatkowe tło, powiedzmy, do motywu nord, po prostu umieść plik w `~/.config/omarchy/backgrounds/nord`.

Najłatwiej zrobisz to, przechodząc do _Instalacja > Styl > Tło_ w Menu Omarchy. Spowoduje to otwarcie folderu, w którym przechowywane są tła dla tego motywu. Naciśnij `Super + Shift + F`, aby uruchomić kolejny menedżer plików, znajdź swoje tło i skopiuj je tam. Teraz znajdzie się wśród teł, między którymi możesz wybierać za pomocą `Super + Ctrl + W`.

Tła mogą być filmami, a nie tylko nieruchomymi obrazami. Wrzuć plik `mp4`, `m4v`, `mov`, `webm`, `mkv` lub `avi` do tego samego folderu, a pojawi się obok obrazów. Filmy są odtwarzane przez silnik tapet OWE. Dekoduje on film raz dla wszystkich monitorów i odtwarza jego dźwięk przez domyślne wyjście audio, a także zatrzymuje odtwarzanie, gdy nic go nie widzi. Tapeta wideo nadal zużywa znacznie więcej energii niż nieruchoma.

Motywy mogą zawierać krótkie intro dla nieruchomego tła. Dla `backgrounds/road.webp` odpowiadający mu film znajduje się w `backgrounds/intros/road.mp4`. Odtwarza się automatycznie przy uruchomieniu systemu, przy przełączeniu na motyw z wybranym tym tłem oraz przy wyborze tego tła, a następnie wraca do nieruchomego obrazu. Filmy intro nie pojawiają się w selektorze teł i nigdy nie są zapętlane.

Wyłączenie _Wygląd > Animacje_ wyłącza również intra teł. Omarchy robi to domyślnie w maszynie wirtualnej. Polecenie `omarchy theme bg intro toggle` może przełączać intra osobno. Odświeżenie motywu nie odtwarza intra.

Nieruchomy obraz może mieć również zapętlenie, spokojną wersję tego samego obrazu, która pozostaje w ruchu, w `backgrounds/loops/road.mp4`. Odtwarza się w miejscu nieruchomego obrazu, po jego intrze, jeśli je ma, i zatrzymuje się po wyłączeniu animacji. Przy zasilaniu z baterii zamiast tego wyświetlany jest nieruchomy obraz, a zapętlenie wraca po podłączeniu zasilania. Zapętlenia nie pojawiają się w selektorze teł.

Ogromną kolekcję świetnych, starannie dobranych teł znajdziesz w [dharmx/walls](https://github.com/dharmx/walls).

Ekran blokady pokazuje nieruchomą klatkę tła wideo, w taki sam sposób, w jaki pokazuje nieruchomą klatkę animowanego pliku GIF.
