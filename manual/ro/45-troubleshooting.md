# Depanare

### Mi-am stricat sistemul cu o actualizare!

Mai întâi încearcă să [revii la versiunea anterioară a sistemului](47-system-snapshots.md) dinaintea actualizării recente. Dacă nu funcționează, folosește `omarchy-debug` ca să-ți prezinți problema pe #omarchy-help în Discord. Și dacă nici asta nu merge, poți reinstala configurațiile și pachetele implicite folosind `omarchy-reinstall`.

### De ce sunt unele aplicații atât de mari pe ecranul meu?

Omarchy presupune un ecran de înaltă rezoluție 2x, ceea ce necesită setarea `GDK_SCALE` la 2 în `~/.config/hypr/monitors.lua`. Dar dacă ești pe un ecran 1x, poți schimba `local omarchy_gdk_scale = 2` în 1 (și apoi repornește orice aplicație supradimensionată). Vezi [manualul despre monitoare](33-monitors.md).

Pentru Spotify, poți folosi `Ctrl + Minus` ca să micșorezi interfața (și `Ctrl + Plus` ca s-o mărești).

### De ce au încetat să mai funcționeze toate combinațiile mele cu tasta Super?

Pe unele laptopuri ASUS ROG și TUF, `Fn + Super` este o combinație ușor de apăsat din greșeală care activează și dezactivează o blocare din firmware a tastei Windows (gândită pentru gaming, ca să nu ieși accidental dintr-un joc). Nimic de pe ecran nu-ți spune că s-a întâmplat. Cât timp blocarea este activă, Super nu emite absolut nimic — așa că orice combinație Omarchy care folosește Super pur și simplu nu mai funcționează și pare că s-a stricat Hyprland.

Apasă `Fn + Super` o dată înainte să te apuci să sapi prin `~/.config/hypr/`, iar dacă asta nu readuce Super, apasă din nou ca să nu lași blocarea activă. Aceasta nu este Fn-lock, care schimbă doar ce face rândul de taste F.

### Wi-Fi-ul, Bluetooth-ul, sunetul sau trackpadul meu tocmai au încetat să funcționeze

Înainte să repornești, încearcă să repornești singur subsistemul cu probleme. _Update > Hardware_ din meniul Omarchy are Wi-Fi, Bluetooth, Audio și Trackpad, iar reîncărcarea unuia dintre ele rezolvă majoritatea situațiilor de tipul „funcționa acum cinci minute” — niște căști Bluetooth care nu vor să se reconecteze, un trackpad care nu mai răspunde după o suspendare, un sunet care a dispărut când ai scos un monitor.

### De ce nu se aude nimic în difuzoarele mele externe?

Probabil pentru că nu sunt setate ca ieșire principală. Fă clic pe pictograma difuzorului din partea dreaptă a barei și se va deschide fereastra de volum, unde poți alege dispozitivul de ieșire (și poți regla și volumele separat pe aplicații).

### Difuzoarele laptopului meu sună ciudat

Pe unele laptopuri, Omarchy aplică automat o reglare a difuzoarelor care corectează răspunsul în frecvență al difuzoarelor încorporate. `omarchy audio tuning status` îți spune dacă este activă vreuna pe mașina ta, iar `omarchy audio tuning off` o dezactivează dacă preferi să auzi difuzoarele fără nicio corecție.

### De ce nu mă pot autentifica sau folosi sudo cu parola mea?

Probabil ai introdus-o greșit de prea multe ori și ai fost blocat. Dacă se întâmplă asta pe ecranul de blocare, poți apăsa `CTRL + ALT + F2` ca să pornești un TTY nou, unde te poți autentifica drept root, apoi rulează `faillock --reset --user [your-username]`. Asta va reseta blocarea și ești gata.

### De ce nu apar solicitările mele de autorizare 1Password pentru 1Password SSH Agent / CLI?

Acest lucru se poate întâmpla din 2 motive:

Pentru ca solicitarea detaliată de aprobare să apară, Settings > Advanced > Use Hardware Acceleration trebuie să fie activat. _Notă: Acest lucru necesită o repornire ca să înceapă să funcționeze._

 ![troubleshooting-1password](images/troubleshooting-1password.webp)

Sau, dacă nu ai lansat 1Password de când ai pornit sistemul, solicitarea nu va apărea.
