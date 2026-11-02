# Rețea

Rețeaua în Omarchy este gestionată de NetworkManager, iar o controlezi din pictograma de rețea din [bara de sus](05-the-top-bar.md) sau cu `Super + Ctrl + N`.

Acel panou scanează rețelele Wi-Fi, arată puterea semnalului și se conectează. Ethernet nu are nevoie de nimic — îl conectezi și funcționează. Dacă preferi să rămâi în terminal, `nmtui` îți oferă aceleași comenzi, și există și un grup de comenzi `omarchy network`.

## Partajarea rețelei Wi-Fi

În loc să citești cu voce tare o parolă lungă, rulează _Setup > Network > QR Code_ cât timp ești conectat la Wi-Fi. Asta afișează pe ecran un cod QR pe care orice cameră de telefon îl poate scana pentru a se conecta. Este unul dintre acele lucruri pe care le vei folosi mai mult decât te-ai aștepta odată ce știi că există.

Dacă ai nevoie de fapt de parola în sine, `omarchy network password <interface>` o afișează.

## DNS

Omarchy folosește DNS-ul pe care rețeaua ta îl furnizează prin DHCP. Îl poți înlocui pentru întregul sistem în _Setup > Network > DNS_, unde Cloudflare și Google sunt la un clic distanță. Alege _Custom_ pentru a introduce propriile tale servere.

Din terminal, `omarchy dns` afișează furnizorul curent, iar `omarchy dns Cloudflare` setează unul.

## Fixarea benzii Wi-Fi

Dacă routerul tău pune 2.4GHz, 5GHz și 6GHz sub același nume de rețea, laptopul tău se va agăța uneori de cea lentă. `omarchy network band` arată pe ce bandă ești, iar `omarchy network band 5` o fixează. Folosește `auto` pentru a-l lăsa să aleagă din nou.

Asta fixează banda, nu un anumit punct de acces, așa că te poți deplasa în continuare normal între AP-uri.

## Cât de rapidă este?

_Trigger > Speed Test > Network Speed Test_ măsoară viteza ta reală de descărcare și încărcare cu o pereche de indicatoare. Din terminal este `omarchy network speedtest down` sau `up`. Măsoară față de serviciul propriu al Omarchy și ia în calcul doar transferurile sale de test. Alte descărcări pot concura pentru lățimea de bandă, dar nu sunt adăugate la rezultatul testului de viteză. (Există un test de viteză pentru disc chiar lângă el în acel meniu, dacă vrei să testezi celălalt blocaj.)

## Firewall-ul

Firewall-ul este activat implicit și blochează tot traficul de intrare, cu o singură excepție: portul 53317, astfel încât [LocalSend](22-guis.md) funcționează din prima.

SSH este dezactivat până când îl activezi cu _Setup > Security > SSHD_, ceea ce pornește daemonul, deschide portul 22 cu limitare de rată împotriva atacurilor brute force și autorizează o cheie. Și Docker este securizat, astfel încât containerele să nu se poată expune accidental lumii. Vezi [securitate](48-security.md) pentru toată povestea.

## Tailscale

[Tailscale](https://tailscale.com/) este un VPN mesh care face accesarea tuturor computerelor și serverelor tale prin internet simplă și sigură. Îl instalezi cu _Install > Service > Tailscale_.

Asta îți oferă un panou Tailscale în bară, care conectează și deconectează tailnet-ul, schimbă conturile și alege un exit node — atât propriile tale mașini, cât și regiunile Mullvad apar în listă. De asemenea, navighează prin mașinile tale, și acolo se află Taildrop: selectează o mașină și apasă `s` pentru a-i trimite fișiere sau `c`, `n` și `d` pentru a-i copia adresa IP, numele sau numele DNS complet. Echivalentul în terminal este `omarchy tailscale send <machine> [file...]`, iar fișierele trimise ție ajung automat în `~/Downloads`. Notificarea care anunță o sosire așteaptă până când dai clic pe ea pentru a o deschide sau o închizi, astfel încât un fișier care apare cât timp ești departe de mașină este încă acolo pentru a-i răspunde când te întorci.

Instalarea lui adaugă și o aplicație web pentru consola de administrare Tailscale.

## Când încetează să funcționeze

Înainte să repornești, încearcă să repornești doar componenta problematică. _Update > Hardware_ conține Wi-Fi, Bluetooth, Audio și Trackpad, iar reîncărcarea uneia dintre ele rezolvă majoritatea situațiilor de tipul „funcționa acum cinci minute”. Vezi [depanare](45-troubleshooting.md).
