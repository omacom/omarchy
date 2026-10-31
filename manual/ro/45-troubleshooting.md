# Depanare

### Mi-am stricat sistemul cu o actualizare!

Încearcă mai întâi să [revii la versiunea sistemului de dinaintea actualizării recente](47-system-snapshots.md). Dacă nu merge, folosește `omarchy-debug` ca să îți împărtășești problema pe #omarchy-help pe Discord. Și dacă nici asta nu merge, poți reinstala configurațiile și pachetele implicite folosind `omarchy-reinstall`.

### De ce sunt unele aplicații atât de mari pe ecranul meu?

Omarchy presupune un ecran de înaltă rezoluție cu scalare 2x, așa că setează `GDK_SCALE` la 2 până când alegi o scalare în panoul monitorului. Dacă ești pe un ecran 1x și aplicațiile GTK sau X11 ies supradimensionate, alege 1x pentru el în panoul monitorului sau adaugă `hl.env("GDK_SCALE", "1")` în `~/.config/hypr/monitors.lua` (și apoi repornește orice aplicație supradimensionată). Vezi [manualul despre monitoare](33-monitors.md).

Pentru Spotify, poți folosi `Ctrl + Minus` ca să micșorezi interfața (și `Ctrl + Plus` ca s-o mărești).

### De ce nu mai funcționează nicio combinație cu tasta Super?

Pe unele laptopuri ASUS ROG și TUF, `Fn + Super` este o combinație ușor de apăsat din greșeală care activează și dezactivează o blocare firmware a tastei Windows (gândită pentru gaming, ca să nu ieși dintr-un joc din greșeală). Nimic de pe ecran nu îți spune că s-a întâmplat. Cât timp blocarea este activă, Super nu emite absolut nimic — așa că fiecare combinație Omarchy care folosește Super pur și simplu nu mai funcționează și pare că s-a stricat Hyprland.

Apasă `Fn + Super` o dată înainte să te apuci să sapi prin `~/.config/hypr/`, iar dacă asta nu aduce Super înapoi, mai apasă o dată, ca să nu lași blocarea activă. Asta nu este Fn-lock, care schimbă doar ce face rândul de taste F.

### Mi s-au oprit Wi-Fi-ul, Bluetooth-ul, sunetul sau trackpad-ul

Înainte să repornești, încearcă să repornești separat subsistemul cu probleme. _Update > Hardware_ din meniul Omarchy are Wi-Fi, Bluetooth, Audio și Trackpad, iar reîncărcarea unuia dintre ele rezolvă majoritatea situațiilor de tipul „mergea acum cinci minute” — o cască Bluetooth care nu vrea să se reconecteze, un trackpad care a murit după o suspendare, un sunet care a dispărut când ai scos un monitor.

### De ce nu se aude nimic în boxele mele externe?

Probabil pentru că nu sunt setate ca ieșire principală. Dă clic pe pictograma difuzorului din partea dreaptă a barei și se va deschide fereastra de volum, de unde poți alege dispozitivul de ieșire (și poți regla și volumele separat, pe fiecare aplicație).

### Boxele laptopului meu sună ciudat

Pe unele laptopuri, Omarchy aplică automat o reglare a boxelor care corectează răspunsul în frecvență al boxelor încorporate. `omarchy audio tuning status` îți spune dacă este una activă pe mașina ta, iar `omarchy audio tuning off` o oprește dacă preferi să auzi boxele fără nicio corecție.

### De ce nu mă pot autentifica sau folosi sudo cu parola mea?

Probabil ai tastat-o greșit de prea multe ori și ai fost blocat. Dacă se întâmplă asta pe ecranul de blocare, poți apăsa `CTRL + ALT + F2` ca să pornești un TTY nou, unde te poți autentifica drept root, apoi poți rula `faillock --reset --user [your-username]`. Asta va reseta blocarea și ești gata.

### De ce nu îmi apar solicitările de autorizare 1Password pentru 1Password SSH Agent / CLI?

Acest lucru se poate întâmpla din 2 motive:

Pentru ca solicitarea detaliată de aprobare să apară, Settings > Advanced > Use Hardware Acceleration trebuie să fie activat. _Notă: Acest lucru necesită o repornire pentru a începe să funcționeze._

 ![troubleshooting-1password](images/troubleshooting-1password.webp)

Sau, dacă nu ai lansat 1Password de când ai pornit sistemul, solicitarea nu va apărea.
