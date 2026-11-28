# Obavijesti

Obavijesti se pojavljuju u gornjem desnom kutu zaslona u fokusu. Datum i vrijeme, stanje baterije i trenutačno vrijeme možete brzo provjeriti i pomoću obavijesti prečacima.

## Obavijesti

Obavijesti iz iste aplikacije ili s istog mjesta slažu se u snop, pa preopširan Slack kanal neće izgurati obavijest o neuspjelom buildu sa zaslona. Zadržite pokazivač iznad snopa da ga raširite; dok čitate, ništa novo neće kliznuti pod vaš pokazivač. Kliknite karticu da skočite na mjesto odakle je došla, kliknite je desnom tipkom, srednjom tipkom ili pritisnite ✕ da je odbacite.

Kartice nude ono što nose: _Kopiraj kod_ za verifikacijske kodove (ne ulaze u [povijest međuspremnika](08-unified-clipboard-history.md) i brišu se nakon minute) te sve gumbe koje aplikacija pruži. Poveznice u tekstu obavijesti otvaraju se klikom.

`Super + ,` odbacuje najnoviju obavijest ili otvara ono na što upućuje kada to nudi, `Super + Alt + ,` odbacuje samo posljednju, `Super + Shift + ,` odbacuje sve, a `Super + Shift + Alt + ,` otvara povijest. Da ih koristite bez miša, pritisnite `Super + Ctrl + ,`. Odabire se najnovija obavijest i njezini se gumbi numeriraju: pritisnite broj da upotrijebite jedan, `Enter` da kliknete obavijest, `↑` i `↓` da se pomičete između obavijesti, `Delete` da odbacite jednu i `Esc` da vratite tipkovnicu. Nakon nekoliko sekundi mirovanja i sama je pušta.

Utišavanje obavijesti zadržava ih, osim Omarchyjevih vlastitih potvrda, hitnih upozorenja i verifikacijskih kodova, koje ste zatražili prije trenutak. Posljednjih nekoliko vratite na zaslon, zadržane ili ne, pomoću `Super + Shift + Alt + ,`. Povijest se čuva jedan dan.

## Obavijesti prečacima

### Datum i vrijeme

`Super + Ctrl + Alt + T`

 ![notice-datetime](images/notice-datetime.webp)

### Vrijeme

`Super + Ctrl + Alt + W`

 ![notice-weather](images/notice-weather.webp)

Lokacija se određuje prema vašoj IP adresi, što je obično dovoljno točno, ali ne uvijek. Možete je precizirati pomoću `omarchy weather location --set Malibu` ili biti posve precizni dodavanjem koordinata: `omarchy weather location --set Malibu 34.0259,-118.7798`. Pokrenite `omarchy weather location` samostalno da vidite gdje misli da se nalazite, a `--clear` da se vratite na automatsko otkrivanje.

### Baterija

`Super + Ctrl + Alt + B`

 ![notice-battery](images/notice-battery.webp)
