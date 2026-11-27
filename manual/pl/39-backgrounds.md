# Tła

Każdy motyw zawiera własny zestaw teł, a możesz dodać własne w `~/.config/omarchy/backgrounds/[theme]`. Jeśli chcesz dodać dodatkowe tło do, powiedzmy, motywu nord, po prostu umieść plik w `~/.config/omarchy/backgrounds/nord`.

Najłatwiej zrobisz to, przechodząc do _Install > Style > Background_ w Omarchy Menu. Otworzy się folder, w którym przechowywane są tła dla tego motywu. Naciśnij `Super + Shift + F`, aby uruchomić kolejny menedżer plików, znajdź swoje tło i skopiuj je tam. Teraz będzie dostępne wśród teł, między którymi możesz przełączać się za pomocą `Super + Ctrl + W`.

Motyw, który nie ma własnych teł, dostaje jedno wygenerowane na podstawie swoich kolorów: logo Omarchy w kolorze akcentu motywu na jego kolorze tła. Dodaj własne, aby je zastąpić.

Tła mogą być filmami, a nie tylko obrazami statycznymi. Umieść plik `mp4`, `m4v`, `mov`, `webm`, `mkv` lub `avi` w tym samym folderze, a pojawi się obok obrazów. Filmy są odtwarzane przez silnik tapet OWE. Dekoduje on film raz dla wszystkich monitorów i odtwarza jego dźwięk przez domyślne wyjście audio, a także wstrzymuje odtwarzanie, gdy nic nie może go zobaczyć. Tapeta wideo nadal zużywa znacznie więcej energii niż statyczna.

Motywy mogą zawierać krótkie intro dla statycznego tła. Dla `backgrounds/road.webp` odpowiadający mu film znajduje się w `backgrounds/intros/road.mp4`. Odtwarza się automatycznie przy starcie systemu, przy przełączeniu na motyw z wybranym tym tłem oraz przy wyborze tego tła, a następnie wraca do obrazu statycznego. Filmy intro nie pojawiają się w selektorze teł i nigdy nie są zapętlane.

Wybranie _Appearance > Animations Off_ wyłącza również intra teł. Omarchy robi to domyślnie w maszynie wirtualnej. Polecenie `omarchy theme bg intro toggle` pozwala przełączać intra osobno. Odświeżenie motywu nie odtwarza intra.

Obraz statyczny może mieć również pętlę, cichą wersję tego samego obrazu, która pozostaje w ruchu, w `backgrounds/loops/road.mp4`. Odtwarza się zamiast obrazu statycznego, po jego intrze, jeśli je ma, i zatrzymuje się po wyłączeniu animacji. Przy zasilaniu z baterii zamiast niej wyświetlany jest obraz statyczny, a pętla wraca po podłączeniu zasilania. Pętle nie pojawiają się w selektorze teł.

Ogromną kolekcję ciekawych, starannie dobranych teł znajdziesz w [dharmx/walls](https://github.com/dharmx/walls).

Ekran blokady pokazuje nieruchomą klatkę filmowego tła, w ten sam sposób, w jaki pokazuje nieruchomą klatkę animowanego pliku GIF.
