# Depanare

### Mi-am stricat sistemul cu o actualizare!

Încearcă mai întâi să [revii la un snapshot de sistem](47-system-snapshots.md) la versiunea dinaintea actualizării recente. Dacă asta nu funcționează, folosește `omarchy-debug` pentru a împărtăși problema ta pe #omarchy-help în Discord. Și dacă toate astea eșuează, poți reinstala configurațiile și pachetele implicite folosind `omarchy-reinstall`.

### De ce sunt unele aplicații atât de mari pe ecranul meu?

Omarchy presupune un ecran de înaltă rezoluție cu scalare 2x, așa că setează `GDK_SCALE` la 2 până când alegi o scalare în panoul pentru monitoare. Dacă ești pe un ecran 1x și aplicațiile GTK sau X11 apar supradimensionate, alege 1x pentru el în panoul pentru monitoare sau adaugă `hl.env("GDK_SCALE", "1")` în `~/.config/hypr/monitors.lua` (și apoi repornește orice aplicație supradimensionată). Vezi [manualul despre monitoare](33-monitors.md).

Pentru Spotify, poți folosi `Ctrl + Minus` pentru a micșora interfața (și `Ctrl + Plus` pentru a o mări).

### De ce au încetat să funcționeze toate combinațiile mele de taste cu Super?

Pe unele laptopuri ASUS ROG și TUF, `Fn + Super` este o combinație ușor de apăsat din greșeală care comută o blocare firmware a tastei Windows (gândită pentru gaming, ca să nu ieși dintr-un joc din greșeală). Nimic de pe ecran nu îți spune că s-a întâmplat. Cât timp blocarea este activă, Super nu emite absolut nimic — așa că orice combinație Omarchy care folosește Super pur și simplu nu mai merge, și pare că s-a stricat Hyprland.

Apasă `Fn + Super` o dată înainte să te apuci să sapi prin `~/.config/hypr/`, iar dacă asta nu aduce Super înapoi, apasă din nou ca să nu lași blocarea activată. Asta nu este Fn-lock, care schimbă doar ce face rândul de taste F.

### Wi-Fi-ul, Bluetooth-ul, sunetul sau trackpadul meu tocmai au încetat să funcționeze

Înainte să repornești, încearcă să repornești separat subsistemul cu probleme. _Update > Hardware_ din meniul Omarchy are Wi-Fi, Bluetooth, Audio și Trackpad, iar reîncărcarea unuia dintre ele rezolvă majoritatea situațiilor de tipul „funcționa acum cinci minute” — o cască Bluetooth care nu se reconectează, un trackpad care a murit după o suspendare, sunet care a dispărut când ai deconectat un monitor.

### De ce nu redau nimic difuzoarele mele externe?

Probabil pentru că nu sunt setate ca ieșire principală. Dă clic pe pictograma difuzorului din partea dreaptă a barei și se va deschide fereastra pop-up de volum, unde poți alege dispozitivul de ieșire (și poți regla și volumele per aplicație).

### Difuzoarele laptopului meu sună ciudat

Pe unele laptopuri, Omarchy aplică automat o reglare a difuzoarelor care corectează răspunsul în frecvență al difuzoarelor încorporate. `omarchy audio tuning status` îți spune dacă una este activă pe mașina ta, iar `omarchy audio tuning off` o dezactivează dacă preferi să auzi difuzoarele fără nicio corecție.

### De ce nu mă pot autentifica sau folosi sudo cu parola mea?

Probabil ai tastat-o greșit de zece ori și ai fost blocat. Blocarea se ridică singură după două minute. Dacă nu poți aștepta și asta se întâmplă pe ecranul de blocare, poți apăsa `CTRL + ALT + F2` pentru a porni un nou TTY unde te poți autentifica ca root, apoi rulează `faillock --reset --user [your-username]`. Asta va reseta blocarea și ești gata de treabă.

### Parola mea este acceptată, dar mă întorc la ecranul de autentificare

Un fișier de mediu de sesiune defect poate împiedica pornirea desktopului, chiar și atunci când parola este corectă. Merită mai ales să verifici asta după ce ai editat `~/.config/uwsm/env.d/`.

Apasă `Ctrl + Alt + F2`, autentifică-te cu numele tău de utilizator și parola obișnuite și inspectează jurnalul de utilizator al pornirii curente:

```bash
journalctl --user -b -t uwsm_env-preloader --no-pager
```

Caută o eroare care numește unul dintre fișierele tale de mediu, cum ar fi `bad substitution`, chiar înaintea unui mesaj care spune că marcajul de ieșire al mediului nu a fost găsit. Mută acel fișier afară din `env.d` înainte să încerci să te autentifici din nou. De exemplu, dacă eroarea numește `99-custom`:

```bash
mkdir -p ~/.config/uwsm/disabled
mv -i ~/.config/uwsm/env.d/99-custom ~/.config/uwsm/disabled/
```

UWSM sare peste un fișier cu o eroare de sintaxă, dar o eroare fatală care apare doar în timp ce fișierul rulează, cum ar fi `bad substitution`, poate totuși să împiedice pornirea desktopului. Revenirea la un snapshot de sistem nu repară aceste fișiere, pentru că `/home` nu este derulat înapoi.

Odată ce te poți autentifica, repară copia salvată înainte să o muți înapoi. `sh -n` detectează erorile de sintaxă fără să ruleze fișierul, dar nu poate detecta toate erorile care apar atunci când fișierul este încărcat cu source. Ține un terminal funcțional deschis în timp ce testezi modificările.

### De ce nu apar mesajele mele de autorizare 1Password pentru 1Password SSH Agent / CLI?

Asta se poate întâmpla din 2 motive:

Pentru ca mesajul complet de aprobare să apară, Settings > Advanced > Use Hardware Acceleration trebuie să fie activat. _Notă: Asta necesită o repornire ca să înceapă să funcționeze._

 ![troubleshooting-1password](images/troubleshooting-1password.webp)

Sau, dacă nu ai lansat 1Password de când ai pornit sistemul, mesajul nu va apărea.
