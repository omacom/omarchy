# Rețele

Rețelele în Omarchy sunt gestionate de NetworkManager, iar tu le controlezi din pictograma de rețea din [bara de sus](05-the-top-bar.md) sau cu `Super + Ctrl + N`.

Panoul respectiv caută rețele Wi-Fi, arată puterea semnalului și se conectează. Ethernet nu are nevoie de nimic — îl conectezi și funcționează. Dacă preferi să rămâi în terminal, `nmtui` îți oferă aceleași comenzi și există și un grup de comenzi `omarchy network`.

## Cum îți partajezi Wi-Fi-ul

În loc să citești cu voce tare o parolă lungă, rulează _Setup > Network > QR Code_ în timp ce ești conectat la Wi-Fi. Asta afișează pe ecran un cod QR pe care orice cameră de telefon îl poate scana pentru a se alătura rețelei. Este unul dintre acele lucruri pe care le vei folosi mai des decât te-ai aștepta odată ce știi că există.

Dacă ai nevoie de parola în sine, `omarchy network password <interface>` o afișează.

## DNS

Omarchy folosește DNS-ul pe care rețeaua ta îl furnizează prin DHCP. Poți înlocui această setare pentru întregul sistem în _Setup > Network > DNS_, unde Cloudflare și Google sunt la un clic distanță. Alege _Custom_ pentru a introduce propriile servere.

Din terminal, `omarchy dns` afișează furnizorul actual, iar `omarchy dns Cloudflare` setează unul.

## Fixarea benzii Wi-Fi

Dacă routerul tău pune 2.4GHz, 5GHz și 6GHz sub același nume de rețea, laptopul se va agăța uneori de banda lentă. `omarchy network band` arată pe ce bandă ești, iar `omarchy network band 5` o fixează. Folosește `auto` pentru a-l lăsa din nou să aleagă.

Aceasta fixează banda, nu un anumit punct de acces, așa că te poți deplasa în continuare normal între AP-uri.

## Cât de rapid este?

_Trigger > Speed Test > Network Speed Test_ măsoară viteza reală de descărcare și încărcare cu ajutorul a două cadrane. Din terminal este `omarchy network speedtest down` sau `up`. (Lângă el în acel meniu se află un test de viteză a discului, dacă testezi performanța celuilalt blocaj.)

## Firewallul

Firewallul este activat implicit și blochează tot traficul primit, cu o singură excepție: portul 53317, astfel încât [LocalSend](22-guis.md) funcționează imediat. 

SSH este dezactivat până când îl activezi din _Setup > Security > SSHD_, care pornește demonul, deschide portul 22 cu limitare a ratei împotriva atacurilor brute force și autorizează o cheie. Și Docker este securizat, astfel încât containerele nu se pot expune accidental lumii. Vezi [securitatea](48-security.md) pentru întreaga poveste.

## Tailscale

[Tailscale](https://tailscale.com/) este un VPN mesh care simplifică și securizează accesul la toate computerele și serverele tale prin internet. Instalează-l din _Install > Service > Tailscale_.

Asta îți oferă un panou Tailscale în bară, care conectează și deconectează tailnetul, schimbă conturile și alege un nod de ieșire — atât propriile mașini, cât și regiunile Mullvad apar în listă. De asemenea, navighează prin mașinile tale, iar acolo se află Taildrop: selectează o mașină și apasă `s` pentru a-i trimite fișiere sau `c`, `n` și `d` pentru a-i copia IP-ul, numele sau numele DNS complet. Echivalentul în terminal este `omarchy tailscale send <machine> [file...]`, iar fișierele trimise către tine ajung automat în `~/Downloads`. Notificarea care anunță o sosire așteaptă până când dai clic pe ea pentru a o deschide sau o închizi, astfel încât un fișier care apare în timp ce ești departe de mașină este încă acolo pentru a i se răspunde atunci când te întorci.

Instalarea adaugă și o aplicație web pentru consola de administrare Tailscale.

## Când nu mai funcționează

Înainte de a reporni sistemul, încearcă să repornești doar componenta problematică. _Update > Hardware_ include Wi-Fi, Bluetooth, Audio și Trackpad, iar reîncărcarea uneia dintre ele rezolvă majoritatea situațiilor de tipul „a funcționat acum cinci minute”. Vezi [depanarea](45-troubleshooting.md).
