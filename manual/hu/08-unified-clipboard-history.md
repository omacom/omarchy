# Egységes vágólap és előzmények

Linuxon általában `Ctrl + Shift + C/V` kell a másoláshoz-beillesztéshez terminálban és `Ctrl + C/V` mindenhol máshol. Ezt nehéz megszokni bárkinek, aki nem Linuxon született és nevelkedett! Ugyanígy a super→ctrl váltást is, ha Macről érkezel.

Az Omarchy mindkét problémát olyan egységes vágólap-billentyűparancsokkal kezeli, amelyek (szinte) mindenhol működnek. Ezek:

| Billentyűparancs | Parancs |
| ------- | ----------- |
| Super + C | Másolás |
| Super + X | Kivágás |
| Super + V | Beillesztés |
| Super + Ctrl + V | Vágólap-előzmények |

_Figyelj arra, hogy a legtöbb agent-harness a `Ctrl + V` kombinációt használja képek beillesztésére, de a `Super + V` kombinációt szöveg beillesztésére._

### Vágólap-előzmények

A vágólap-előzményeket az Omarchy shell biztosítja, és szöveggel és képekkel egyaránt működnek. A `Super + Ctrl + V` kombinációval indítod, a Return billentyűvel kiválasztod a bejegyzésedet, és az ezután a vágólapra kerül, készen arra, hogy a `Super + V` kombinációval beilleszd.

 ![clipboard-history](images/clipboard-history.webp)

Az előzményekben kereshetsz is, csak kezdj el gépelni:

 ![clipboard-history-search](images/clipboard-history-search.webp)
