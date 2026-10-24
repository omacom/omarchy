# Rețea

Rețeaua în Omarchy este gestionată de NetworkManager, iar tu o conduci din pictograma de rețea din [bara de sus](05-the-top-bar.md) sau cu `Super + Ctrl + W`.

Acel panou scanează rețelele Wi-Fi, arată puterea semnalului și te conectează. Ethernet nu are nevoie de nimic — îl conectezi și funcționează. Dacă preferi să rămâi în terminal, `nmtui` îți oferă aceleași controale, și există și un grup de comenzi `omarchy network`.

## Partajarea rețelei Wi-Fi

În loc să citești o parolă lungă cu voce tare, rulează _Configurare > Rețea > Cod QR_ cât timp ești pe Wi-Fi. Asta pune pe ecran un cod QR pe care orice cameră de telefon îl poate scana ca să se alăture rețelei. Este unul dintre acele lucruri pe care le vei folosi mai mult decât te-ai aștepta odată ce știi că există.

Dacă ai nevoie chiar de parola însăși, `omarchy network password <interface>` o tipărește.

## DNS

Omarchy folosește DNS-ul pe care rețeaua ta îl distribuie prin DHCP. Poți suprascrie asta pentru întreaga mașină sub _Configurare > Rețea > DNS_, unde Cloudflare și Google sunt la un clic distanță. Alege _Personalizat_ ca să introduci propriile servere.

Din terminal, `omarchy dns` tipărește furnizorul curent, iar `omarchy dns Cloudflare` setează unul.

## Fixarea benzii Wi-Fi

Dacă routerul tău pune 2.4GHz, 5GHz și 6GHz pe același nume de rețea, laptopul tău se va agăța uneori de cea lentă. `omarchy network band` arată pe ce bandă ești, iar `omarchy network band 5` o fixează. Folosește `auto` ca să o lași să aleagă din nou.

Asta fixează banda, nu un punct de acces anume, așa că continui să te deplasezi normal între punctele de acces.

## Cât de rapidă este?

_Declanșator > Test viteză > Test viteză rețea_ măsoară viteza reală de încărcare și descărcare cu o pereche de cadrane. Din terminal este `omarchy network speedtest down` sau `up`. (Există și un test de viteză a discului chiar lângă el în acel meniu, dacă măsori celălalt blocaj.)

## Firewallul

Firewallul este pornit implicit și blochează tot traficul de intrare, cu o singură excepție: portul 53317, astfel încât [LocalSend](22-guis.md) funcționează imediat.

SSH este oprit până când îl pornești cu _Configurare > Securitate > SSHD_, care pornește daemonul, deschide portul 22 cu limitare a ratei împotriva atacurilor prin forță brută și autorizează o cheie. Și Docker este blocat, astfel încât containerele să nu se poată expune accidental lumii. Vezi [securitate](48-security.md) pentru toată povestea.

## Tailscale

[Tailscale](https://tailscale.com/) este un VPN mesh care face simplă și sigură ajungerea la toate computerele și serverele tale prin internet. Instalează-l cu _Instalează > Serviciu > Tailscale_.

Asta îți oferă un panou Tailscale în bară, care conectează și deconectează tailnetul, schimbă conturile și alege un nod de ieșire — atât mașinile tale, cât și regiunile Mullvad apar în listă. De asemenea, îți răsfoiește mașinile, și acolo trăiește Taildrop: selectează o mașină și apasă `s` ca să-i trimiți fișiere, sau `c`, `n` și `d` ca să-i copiezi adresa IP, numele sau numele DNS complet. Echivalentul din terminal este `omarchy tailscale send <machine> [file...]`, iar fișierele trimise ție ajung automat în `~/Downloads`. Notificarea care anunță o sosire așteaptă până când faci clic pe ea ca să o deschizi sau o respingi, astfel încât un fișier care apare cât timp ești departe de mașină este încă acolo ca să-i răspunzi când te întorci.

Instalarea adaugă și o aplicație web pentru consola de administrare Tailscale.

## Când nu mai funcționează

Înainte să repornești, încearcă să repornești separat bucata vinovată. _Actualizează > Hardware_ are Wi-Fi, Bluetooth, Audio și Trackpad, iar reîncărcarea unuia dintre acestea rezolvă majoritatea situațiilor de tipul „funcționa acum cinci minute”. Vezi [depanare](45-troubleshooting.md).
