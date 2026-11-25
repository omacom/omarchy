# Egységes vágólap és előzmények

Linuxon általában `Ctrl + Shift + C/V` kell a másoláshoz és beillesztéshez a terminálban, mindenhol máshol pedig `Ctrl + C/V`. Ezt bárkinek nehéz megszoknia, aki nem Linuxon született és nevelkedett! Ahogy a Super helyett a Ctrl használatára való átállást is, ha Macről érkezel.

Az Omarchy mindkét problémát megoldja az egységes vágólap-gyorsbillentyűkkel, amelyek (szinte) mindenhol működnek. Ezek a következők:

| Gyorsbillentyű | Parancs |
| ------- | ----------- |
| Super + A | Mindent kijelöl |
| Super + C | Másolás |
| Super + X | Kivágás |
| Super + V | Beillesztés |
| Super + Ctrl + V | Vágólap-előzmények |

_Vedd figyelembe, hogy a legtöbb agent harness a `Ctrl + V` billentyűkombinációt használja képek beillesztéséhez, a `Super + V` kombinációt viszont szöveg beillesztéséhez._

Használd a `Super + A`, majd a `Super + C` billentyűkombinációt, ha mindent ki akarsz másolni egy fókuszban lévő szövegmezőből vagy más olyan alkalmazásból, amely támogatja a `Ctrl + A` kombinációt. Terminálban a `Ctrl + A` a parancssor elejére ugrik a szöveg kijelölése helyett.

### Vágólap-előzmények

A vágólap-előzményeket az Omarchy shell biztosítja, és szöveggel és képekkel is működik. A `Super + Ctrl + V` billentyűkombinációval hívhatod elő, majd a Return billentyűvel kiválasztod a kívánt bejegyzést, amely ezután egyenesen beillesztődik abba az alkalmazásba, amelyben éppen voltál. A `Shift + Return` kombinációval csak a vágólapra másolod, az `Alt + Return` kombinációval megnyithatod, a `Delete` billentyűvel eltávolíthatod az előzményekből, a `Shift + Delete` kombinációval pedig törölheted az összes előzményt.

 ![clipboard-history](images/clipboard-history.webp)

Az előzményekben egyszerűen úgy is kereshetsz, hogy elkezdesz gépelni:

 ![clipboard-history-search](images/clipboard-history-search.webp)
