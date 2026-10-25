# Obavijesti

Obavijesti se pojavljuju u gornjem desnom kutu zaslona u fokusu. Pomoću obavijesti putem tipkovničkih prečaca možete i brzo pristupiti datumu i vremenu, stanju baterije i trenutnim vremenskim prilikama.

## Obavijesti

Obavijesti iz iste aplikacije ili web-mjesta slažu se u špil, tako da brbljavi Slack kanal neće izgurati obavijest o neuspjelom buildu s ekrana. Zadržite pokazivač iznad špila da biste ga raširili; dok čitate, ništa novo neće kliznuti pod vaš pokazivač. Kliknite karticu da biste skočili na mjesto odakle je došla, a kliknite je desnom tipkom, srednjom tipkom ili pritisnite ✕ da biste je odbacili.

Kartice nude ono što nose: _Kopiraj kod_ za verifikacijske kodove (koji se ne spremaju u [povijest međuspremnika](08-unified-clipboard-history.md) i brišu se nakon minute), uz sve gumbe koje aplikacija pruži. Poveznice u tekstu obavijesti otvaraju se klikom.

Da biste ih koristili bez miša, pritisnite `Super + Ctrl + ,`. Odabire se najnovija obavijest, a njezini su gumbi numerirani: pritisnite broj da biste upotrijebili jedan od njih, `Enter` da biste kliknuli obavijest, `↑` i `↓` za kretanje između obavijesti, `Delete` da biste jednu odbacili i `Esc` da biste vratili tipkovnicu. Nakon nekoliko sekundi neaktivnosti i sama se otpušta.

Utišavanjem obavijesti zadržavate ih, osim Omarchyjevih vlastitih potvrda, hitnih upozorenja i verifikacijskih kodova, koje ste zatražili prije trenutak. Posljednjih nekoliko vratite na ekran, zadržane ili ne, pomoću `Super + Shift + Alt + ,`. Povijest se čuva jedan dan.

## Obavijesti putem tipkovničkih prečaca

### Datum i vrijeme

`Super + Ctrl + Alt + T`

 ![notice-datetime](images/notice-datetime.webp)

### Vremenske prilike

`Super + Ctrl + Alt + W`

 ![notice-weather](images/notice-weather.webp)

Lokacija se otkriva na temelju vaše IP adrese, što je obično dovoljno točno, ali ne uvijek. Možete je precizirati pomoću `omarchy weather location --set Malibu` ili biti posve precizni dodavanjem koordinata: `omarchy weather location --set Malibu 34.0259,-118.7798`. Pokrenite `omarchy weather location` samostalno da biste vidjeli gdje misli da se nalazite, a `--clear` za povratak na automatsko otkrivanje.

### Baterija

`Super + Ctrl + Alt + B`

 ![notice-battery](images/notice-battery.webp)
