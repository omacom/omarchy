# Tła

Każdy motyw jest dostarczany z własnym zestawem teł, a możesz dodać własne dodatki w `~/.config/omarchy/backgrounds/[theme]`. Jeśli chcesz dodać dodatkowe tło, powiedzmy, do motywu nord, po prostu umieść plik w `~/.config/omarchy/backgrounds/nord`.

Najłatwiej zrobisz to, przechodząc do _Install > Style > Background_ w Omarchy Menu. Spowoduje to wyświetlenie folderu, w którym przechowywane są tła dla tego motywu. Naciśnij `Super + Shift + F`, aby uruchomić kolejny menedżer plików, znajdź swoje tło i przekopiuj je tam. Teraz będzie ono uwzględnione wśród teł, między którymi możesz przełączać się za pomocą `Super + Ctrl + W`.

Tła mogą być również filmami, a nie tylko obrazami statycznymi. Wrzuć plik `mp4`, `m4v`, `mov`, `webm`, `mkv` lub `avi` do tego samego folderu, a pojawi się obok obrazów. Filmy są odtwarzane przez silnik tapet OWE. Dekoduje on film raz dla wszystkich monitorów i odtwarza jego dźwięk przez domyślne wyjście audio, a także zatrzymuje odtwarzanie zawsze, gdy nic nie może go zobaczyć. Tapeta filmowa nadal zużywa znacznie więcej energii niż statyczna.

Motywy mogą zawierać krótkie intro dla tła statycznego. Dla `backgrounds/road.webp` odpowiadający mu film znajduje się w `backgrounds/intros/road.mp4`. Odtwarza się on automatycznie przy rozruchu, przy przełączaniu na motyw z wybranym tym tłem oraz przy wybieraniu tego tła, a następnie wraca do obrazu statycznego. Filmy intro nie pojawiają się w selektorze teł i nigdy się nie zapętlają.

Wyłączenie _Appearance > Animations_ wyłącza również intra teł. Omarchy robi to domyślnie w maszynie wirtualnej. Polecenie `omarchy theme bg intro toggle` może przełączać intra osobno. Odświeżanie motywu nie odtwarza intra.

Ogromną kolekcję świetnych, starannie wybranych teł znajdziesz w [dharmx/walls](https://github.com/dharmx/walls).

Ekran blokady pokazuje statyczną klatkę tła filmowego, w ten sam sposób, w jaki pokazuje statyczną klatkę animowanego pliku GIF.
