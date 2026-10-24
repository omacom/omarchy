# Depanare

### Mi-am stricat sistemul cu o actualizare!

Mai întâi încearcă să [revii la versiunea anterioară a sistemului](47-system-snapshots.md) dinaintea actualizării recente. Dacă asta nu funcționează, folosește `omarchy-debug` ca să împărtășești problema ta pe #omarchy-help în Discord. Și dacă toate astea eșuează, poți reinstala configurațiile și pachetele implicite folosind `omarchy-reinstall`.

### De ce sunt unele aplicații atât de mari pe afișajul meu?

Omarchy presupune un afișaj de înaltă rezoluție 2x, ceea ce necesită setarea `GDK_SCALE` la 2 în `~/.config/hypr/monitors.lua`. Dar dacă ești pe un afișaj 1x, poți schimba `local omarchy_gdk_scale = 2` la 1 (și apoi să repornești orice aplicație supradimensionată). Vezi [manualul despre monitoare](33-monitors.md).

Pentru Spotify, poți folosi `Ctrl + Minus` ca să micșorezi interfața (și `Ctrl + Plus` ca să o mărești).

### Wi-Fi-ul, Bluetooth-ul, sunetul sau trackpadul meu tocmai au încetat să funcționeze

Înainte să repornești, încearcă să repornești separat subsistemul vinovat. _Actualizează > Hardware_ în meniul Omarchy are Wi-Fi, Bluetooth, Audio și Trackpad, iar reîncărcarea unuia dintre acestea rezolvă majoritatea situațiilor de tipul „funcționa acum cinci minute” — o pereche de căști Bluetooth care nu se reconectează, un trackpad care a murit după o suspendare, sunet care a dispărut când ai deconectat un monitor.

### De ce nu redau nimic difuzoarele mele externe?

Probabil pentru că nu sunt setate ca ieșire principală. Fă clic pe pictograma difuzorului din partea dreaptă a barei, și se va deschide pop-upul de volum unde poți alege dispozitivul de ieșire (și poți mixa și volumele pe aplicație).

### Difuzoarele laptopului meu sună ciudat

Pe unele laptopuri, Omarchy aplică automat o reglare a difuzoarelor care corectează răspunsul în frecvență al difuzoarelor integrate. `omarchy audio tuning status` îți spune dacă una este activă pe mașina ta, iar `omarchy audio tuning off` o dezactivează dacă preferi să auzi difuzoarele în stare brută.

### De ce nu mă pot autentifica sau folosi sudo cu parola mea?

Probabil ai tastat-o greșit de prea multe ori și ai fost blocat. Dacă asta se întâmplă pe ecranul de blocare, poți apăsa `CTRL + ALT + F2` ca să pornești un TTY nou unde te poți autentifica ca root, apoi să rulezi `faillock --reset --user [your-username]`. Asta va reseta blocarea și ești gata de drum.

### De ce nu apar solicitările mele de autorizare 1Password pentru 1Password SSH Agent / CLI?

Asta se poate întâmpla din 2 motive:

Pentru ca solicitarea bogată de aprobare să apară, Settings > Advanced > Use Hardware Acceleration trebuie să fie activată. _Notă: Asta necesită o repornire ca să înceapă să funcționeze._

 ![troubleshooting-1password](images/troubleshooting-1password.webp)

Sau, dacă nu ai lansat 1Password de la pornire, solicitarea nu va apărea.
