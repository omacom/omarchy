# Depanare

### Mi-am stricat sistemul cu o actualizare!

Mai întâi încearcă să [revii la versiunea sistemului](47-system-snapshots.md) de dinaintea actualizării recente. Dacă nu merge, folosește `omarchy-debug` ca să împărtășești problema ta pe #omarchy-help în Discord. Și dacă nici asta nu merge, poți reinstala configurațiile și pachetele implicite folosind `omarchy-reinstall`.

### De ce sunt unele aplicații atât de mari pe ecranul meu?

Omarchy presupune un ecran de înaltă rezoluție la 2x, așa că setează `GDK_SCALE` la 2 până când alegi o scală în panoul monitorului. Dacă ai un ecran 1x și aplicațiile GTK sau X11 apar supradimensionate, alege 1x pentru el în panoul monitorului sau adaugă `hl.env("GDK_SCALE", "1")` în `~/.config/hypr/monitors.lua` (și apoi repornește orice aplicație supradimensionată). Vezi [manualul despre monitoare](33-monitors.md).

Pentru Spotify, poți folosi `Ctrl + Minus` ca să micșorezi interfața (și `Ctrl + Plus` ca să o mărești).

### De ce au încetat să mai funcționeze toate combinațiile mele cu tasta Super?

Pe unele laptopuri ASUS ROG și TUF, `Fn + Super` este o combinație ușor de apăsat din greșeală care activează sau dezactivează o blocare din firmware a tastei Windows (gândită pentru gaming, ca să nu ieși accidental dintr-un joc). Nimic de pe ecran nu îți spune că s-a întâmplat. Cât timp blocarea este activă, Super nu emite absolut nimic — așa că orice combinație Omarchy care folosește Super pur și simplu încetează să funcționeze și pare că s-a stricat Hyprland.

Apasă `Fn + Super` o dată înainte să sapi prin `~/.config/hypr/`, iar dacă asta nu readuce Super, apasă din nou ca să nu lași blocarea activă. Aceasta nu este Fn-lock, care schimbă doar ce face rândul de taste F.

### Wi-Fi-ul, Bluetooth-ul, sunetul sau trackpadul meu tocmai au încetat să funcționeze

Înainte să repornești, încearcă să repornești doar subsistemul cu probleme. _Update > Hardware_ din meniul Omarchy are Wi-Fi, Bluetooth, Audio și Trackpad, iar reîncărcarea unuia dintre ele rezolvă majoritatea situațiilor de tipul „mergea acum cinci minute” — căști Bluetooth care nu vor să se reconecteze, un trackpad care a murit după o suspendare, sunet care a dispărut când ai scos un monitor.

### De ce nu se aude nimic în difuzoarele mele externe?

Probabil pentru că nu sunt setate ca ieșire principală. Dă clic pe pictograma difuzorului din partea dreaptă a barei și se va deschide fereastra de volum, unde poți alege dispozitivul de ieșire (și poți regla și volumele separat pe aplicații).

### Difuzoarele laptopului meu sună ciudat

Pe unele laptopuri, Omarchy aplică automat o reglare a difuzoarelor care corectează răspunsul în frecvență al difuzoarelor încorporate. `omarchy audio tuning status` îți spune dacă una este activă pe mașina ta, iar `omarchy audio tuning off` o dezactivează dacă preferi să auzi difuzoarele fără nicio corecție.

### De ce nu mă pot autentifica sau folosi sudo cu parola mea?

Probabil ai tastat-o greșit de prea multe ori și ai fost blocat. Dacă asta se întâmplă pe ecranul de blocare, poți apăsa `CTRL + ALT + F2` ca să pornești un TTY nou unde te poți autentifica ca root, apoi rulezi `faillock --reset --user [your-username]`. Asta va reseta blocarea și ești gata de drum.

### Parola îmi este acceptată, dar revin la ecranul de autentificare

Un fișier de mediu al sesiunii defect poate împiedica pornirea desktopului chiar și atunci când parola este corectă. Merită verificat mai ales după ce ai editat `~/.config/uwsm/env.d/`.

Apasă `Ctrl + Alt + F2`, autentifică-te cu numele de utilizator și parola ta normale și inspectează jurnalul utilizatorului pentru bootarea curentă:

```bash
journalctl --user -b -t uwsm_env-preloader --no-pager
```

Caută o eroare care numește unul dintre fișierele tale de mediu, cum ar fi `bad substitution`, chiar înainte de un mesaj că marcajul de ieșire al mediului nu a fost găsit. Mută acel fișier din `env.d` înainte să încerci să te autentifici din nou. De exemplu, dacă eroarea numește `99-custom`:

```bash
mkdir -p ~/.config/uwsm/disabled
mv -i ~/.config/uwsm/env.d/99-custom ~/.config/uwsm/disabled/
```

UWSM sare peste un fișier cu o eroare de sintaxă, dar o eroare fatală care apare doar în timp ce fișierul rulează, cum ar fi `bad substitution`, poate totuși împiedica pornirea desktopului. O revenire la un snapshot al sistemului nu repară aceste fișiere, deoarece `/home` nu este derulat înapoi.

Odată ce te poți autentifica, repară copia salvată înainte să o muți înapoi. `sh -n` detectează erorile de sintaxă fără să ruleze fișierul, dar nu poate detecta toate erorile care apar atunci când este încărcat. Ține deschis un terminal funcțional în timp ce testezi modificările.

### De ce nu apar solicitările mele de autorizare 1Password pentru 1Password SSH Agent / CLI?

Acest lucru se poate întâmpla din 2 motive:

Pentru ca solicitarea bogată de aprobare să apară, Settings > Advanced > Use Hardware Acceleration trebuie să fie activată. _Notă: Acest lucru necesită o repornire ca să înceapă să funcționeze._

 ![troubleshooting-1password](images/troubleshooting-1password.webp)

Sau, dacă nu ai lansat 1Password de la pornire, solicitarea nu va apărea.
