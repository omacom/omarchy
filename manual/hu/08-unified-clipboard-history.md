# Egységes vágólap és előzmények

Linuxon a terminálban általában a `Ctrl + Shift + C/V` billentyűkombináció kell a másoláshoz és beillesztéshez, mindenhol máshol pedig a `Ctrl + C/V`. Nehéz ezt megszokni annak, aki nem Linuxon született és nőtt fel! Ugyanígy a Super billentyűről a Ctrl billentyűre váltást is, ha Macről jössz.

Az Omarchy mindkét problémát egységes vágólap-gyorsbillentyűkkel oldja meg, amelyek (szinte) mindenhol működnek. Ezek a következők:

| Gyorsbillentyű | Művelet |
| ------- | ----------- |
| Super + A | Összes kijelölése |
| Super + C | Másolás |
| Super + X | Kivágás |
| Super + V | Beillesztés |
| Super + Ctrl + V | Vágólap-előzmények |

_Vedd figyelembe, hogy a legtöbb agent harness a `Ctrl + V` billentyűkombinációt használja képek beillesztésére, a `Super + V` billentyűkombinációt pedig szöveg beillesztésére._

Használd a `Super + A`, majd a `Super + C` billentyűkombinációt, hogy mindent kimásolj egy fókuszban lévő szövegmezőből vagy más olyan appból, amely támogatja a `Ctrl + A` billentyűkombinációt. Terminálban a `Ctrl + A` a parancssor elejére ugrik a szöveg kijelölése helyett.

### Vágólap-előzmények

A vágólap-előzményeket az Omarchy shell biztosítja, és szövegekhez és képekhez is működik. A `Super + Ctrl + V` billentyűkombinációval hívod elő, a return billentyűvel kiválasztod a bejegyzést, az pedig felkerül a vágólapra, készen arra, hogy a `Super + V` billentyűkombinációval beilleszd.

 ![clipboard-history](images/clipboard-history.webp)

Az előzmények között úgy is kereshetsz, hogy egyszerűen elkezdesz gépelni:

 ![clipboard-history-search](images/clipboard-history-search.webp)
