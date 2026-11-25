# Teated

Teavitused ilmuvad fokuseeritud ekraani ülemisse paremasse nurka. Kiirklahvide teadetega pääsed kiiresti ligi ka kuupäevale ja kellaajale, aku olekule ja praegusele ilmale.

## Teavitused

Sama rakenduse või saidi teavitused kuhjuvad üheks pakiks, nii et jutukas Slacki kanal ei lükka sinu ehituse ebaõnnestumist ekraanilt välja. Hõlju paki kohal, et see laiali lehvitada; lugemise ajal ei libise midagi uut sinu kursori alla. Klõpsa kaardil, et hüpata sinna, kust see pärit on, selle sulgemiseks tee paremklõps, keskmine klõps või vajuta ✕.

Kaardid pakuvad seda, mida nad endaga kannavad: kinnituskoodide puhul _Kopeeri kood_ (hoitakse eemal [lõikepuhvri ajaloost](08-unified-clipboard-history.md) ja kustutatakse minuti pärast), lisaks kõik nupud, mida rakendus pakub. Teavituse tekstis olevad lingid avanevad klõpsamisel.

`Super + ,` sulgeb uusima teavituse või avab selle, millele see viitab, kui see seda võimaldab, `Super + Alt + ,` sulgeb ainult viimase, `Super + Shift + ,` sulgeb need kõik ja `Super + Shift + Alt + ,` avab ajaloo. Ilma hiireta kasutamiseks vajuta `Super + Ctrl + ,`. Uusim teavitus on valitud ja selle nupud nummerdatud: vajuta numbrit, et mõnda kasutada, `Enter`, et teavitust klõpsata, `↑` ja `↓`, et teavituste vahel liikuda, `Delete`, et üks sulgeda, ja `Esc`, et klaviatuur tagasi anda. See laseb mõne jõudeoleku sekundi järel ka ise lahti.

Teavituste vaigistamine hoiab neid tagasi, välja arvatud Omarchy enda kinnitused, hädaolukorra hoiatused ja kinnituskoodid, mida sa just hetk tagasi palusid. Pane viimased paar uuesti ekraanile, kinni hoitud või mitte, klahvikombinatsiooniga `Super + Shift + Alt + ,`. Ajalugu säilitatakse ühe päeva.

## Kiirklahvide teated

### Kuupäev ja kellaaeg

`Super + Ctrl + Alt + T`

 ![notice-datetime](images/notice-datetime.webp)

### Ilm

`Super + Ctrl + Alt + W`

 ![notice-weather](images/notice-weather.webp)

Asukoht tuvastatakse sinu IP-aadressi järgi, mis on tavaliselt piisavalt lähedal, kuid mitte alati. Saad selle paika panna käsuga `omarchy weather location --set Malibu` või olla täpne, lisades koordinaadid: `omarchy weather location --set Malibu 34.0259,-118.7798`. Käivita `omarchy weather location` omaette, et näha, kus see sinu arvates oled, ja `--clear`, et minna tagasi automaatse tuvastamise juurde.

### Aku

`Super + Ctrl + Alt + B`

 ![notice-battery](images/notice-battery.webp)
