# Ujednolicony schowek i historia

Zwykle w Linuksie musisz używać `Ctrl + Shift + C/V`, aby kopiować i wklejać w terminalu, oraz `Ctrl + C/V`, aby robić to wszędzie indziej. Każdemu, kto nie urodził się i nie wychował na Linuksie, trudno się do tego przyzwyczaić! Podobnie jest z przejściem z Super na Ctrl, jeśli przesiadasz się z Maca.

Omarchy rozwiązuje oba problemy za pomocą ujednoliconych skrótów klawiszowych schowka, które działają (prawie) wszędzie. Są to:

| Hotkey | Command |
| ------- | ----------- |
| Super + A | Zaznacz wszystko |
| Super + C | Kopiuj |
| Super + X | Wytnij |
| Super + V | Wklej |
| Super + Ctrl + V | Historia schowka |

_Zwróć uwagę, że większość harnessów agentów będzie używać `Ctrl + V` do wklejania obrazów, ale `Super + V` do wklejania tekstu._

Użyj `Super + A`, a następnie `Super + C`, aby skopiować wszystko w aktywnym polu tekstowym lub innej aplikacji, która obsługuje `Ctrl + A`. W terminalu `Ctrl + A` przenosi na początek wiersza poleceń zamiast zaznaczać jego tekst.

### Historia schowka

Historię schowka zapewnia powłoka Omarchy i działa ona zarówno dla tekstu, jak i obrazów. Wywołujesz ją za pomocą `Super + Ctrl + V`, wybierasz wpis klawiszem return, a następnie zostanie on umieszczony w schowku, gotowy do wklejenia za pomocą `Super + V`.

 ![clipboard-history](images/clipboard-history.webp)

Historię możesz też przeszukiwać, po prostu zaczynając pisać:

 ![clipboard-history-search](images/clipboard-history-search.webp)
