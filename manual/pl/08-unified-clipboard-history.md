# Ujednolicony schowek i historia

Zazwyczaj w systemie Linux potrzebujesz `Ctrl + Shift + C/V`, aby kopiować i wklejać w terminalu, oraz `Ctrl + C/V`, aby robić to wszędzie indziej. Trudno się do tego przyzwyczaić każdemu, kto nie urodził się i nie wychował na Linuksie! Podobnie jest z przejściem z super na ctrl, jeśli przechodzisz z Maca.

Omarchy rozwiązuje oba te problemy za pomocą ujednoliconych skrótów klawiszowych schowka, które działają (prawie) wszędzie. Są to:

| Hotkey | Command |
| ------- | ----------- |
| Super + A | Zaznacz wszystko |
| Super + C | Kopiuj |
| Super + X | Wytnij |
| Super + V | Wklej |
| Super + Ctrl + V | Historia schowka |

_Pamiętaj, że większość harnessów agentów używa `Ctrl + V` do wklejania obrazów, ale `Super + V` do wklejania tekstu._

Użyj `Super + A`, a następnie `Super + C`, aby skopiować wszystko w aktywnym polu tekstowym lub innej aplikacji obsługującej `Ctrl + A`. W terminalu `Ctrl + A` przenosi na początek wiersza poleceń zamiast zaznaczać jego tekst.

### Historia schowka

Historię schowka zapewnia powłoka Omarchy i działa ona zarówno dla tekstu, jak i obrazów. Wywołujesz ją za pomocą `Super + Ctrl + V` i wybierasz wpis klawiszem return, co wkleja go bezpośrednio do aplikacji, w której byłeś. Użyj `Shift + Return`, aby tylko skopiować go do schowka, `Alt + Return`, aby go otworzyć, `Delete`, aby usunąć go z historii, oraz `Shift + Delete`, aby wyczyścić całą historię.

 ![clipboard-history](images/clipboard-history.webp)

Możesz też przeszukiwać historię, po prostu zaczynając pisać:

 ![clipboard-history-search](images/clipboard-history-search.webp)
