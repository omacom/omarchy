# Jedinstveni međuspremnik i povijest

Obično na Linuxu morate koristiti `Ctrl + Shift + C/V` za kopiranje i lijepljenje u terminalu i `Ctrl + C/V` da biste to napravili svugdje drugdje. Na to se teško naviknuti svatko tko nije rođen i odrastao na Linuxu! Isto vrijedi i za prelazak sa super na ctrl, ako dolazite s Maca.

Omarchy rješava oba problema jedinstvenim prečacima za međuspremnik koji rade (gotovo) svugdje. To su:

| Hotkey | Command |
| ------- | ----------- |
| Super + A | Odaberi sve |
| Super + C | Kopiraj |
| Super + X | Izreži |
| Super + V | Zalijepi |
| Super + Ctrl + V | Povijest međuspremnika |

_Imajte na umu da će većina harness alata za agente koristiti `Ctrl + V` za lijepljenje slika, ali `Super + V` za lijepljenje teksta._

Upotrijebite `Super + A`, zatim `Super + C` da biste kopirali sve u fokusiranom tekstualnom polju ili drugoj aplikaciji koja podržava `Ctrl + A`. U terminalu `Ctrl + A` pomiče na početak naredbenog retka umjesto da odabire njegov tekst.

### Povijest međuspremnika

Povijest međuspremnika pruža Omarchy shell i radi i za tekst i za slike. Pokrećete je pomoću `Super + Ctrl + V` i tipkom return odabirete svoj unos, čime ga lijepite izravno u aplikaciju u kojoj ste bili. Upotrijebite `Shift + Return` da biste ga samo kopirali u međuspremnik, `Alt + Return` da biste ga otvorili, `Delete` da biste ga uklonili iz povijesti i `Shift + Delete` da biste izbrisali cijelu povijest.

 ![clipboard-history](images/clipboard-history.webp)

Povijest možete pretraživati i tako da jednostavno počnete tipkati:

 ![clipboard-history-search](images/clipboard-history-search.webp)
