# Teated

Teavitused maanduvad fokuseeritud ekraani paremas ülanurgas. Kiirklahvi teadete abil pääsed kiiresti ligi ka kuupäevale ja kellaajale, aku olekule ning praegusele ilmale.

## Teavitused

Teavitused samalt rakenduselt või saidilt kuhjuvad ühte pakki, nii et jutukas Slacki kanal ei lükka sinu ehituse ebaõnnestumist ekraanilt minema. Hõlju hiirega paki kohal, et see lehvikuna lahti laotada; sel ajal kui loed, ei libise midagi uut sinu kursori alla. Klõpsa kaardil, et hüpata selle allika juurde, paremklõps, keskmine klõps või ✕ sulgeb selle.

Kaardid pakuvad seda, mida nad endaga kannavad: _Kopeeri kood_ kinnituskoodide jaoks (jäetakse välja [lõikelaua ajaloost](08-unified-clipboard-history.md) ja kustutatakse minuti pärast), pluss kõik nupud, mida rakendus pakub. Lingid teavituse tekstis avanevad klõpsamisel.

Et kasutada neid ilma hiireta, vajuta `Super + Ctrl + ,`. Uusim teavitus on valitud ja selle nupud nummerdatud: vajuta numbrit, et mõnda neist kasutada, `Enter`, et teavitust klõpsata, `↑` ja `↓`, et liikuda teavituste vahel, `Delete`, et mõni neist sulgeda, ja `Esc`, et klaviatuur tagasi anda. See laseb ka ise mõne jõudeoleku sekundi järel lahti.

Teavituste vaigistamine hoiab need tagasi, välja arvatud Omarchy enda kinnitused, hädaolukorra hoiatused ja kinnituskoodid, mida sa just hetk tagasi küsisid. Too viimased paar uuesti ekraanile, olgu need tagasi hoitud või mitte, klahvikombinatsiooniga `Super + Shift + Alt + ,`. Ajalugu säilitatakse üks päev.

## Kiirklahvi teated

### Kuupäev ja kellaaeg

`Super + Ctrl + Alt + T`

 ![notice-datetime](images/notice-datetime.webp)

### Ilm

`Super + Ctrl + Alt + W`

 ![notice-weather](images/notice-weather.webp)

Asukoht tuvastatakse sinu IP-aadressi järgi, mis on tavaliselt piisavalt lähedal, kuid mitte alati. Saad selle paika panna käsuga `omarchy weather location --set Malibu`, või olla selle suhtes täpne, lisades koordinaadid: `omarchy weather location --set Malibu 34.0259,-118.7798`. Käivita `omarchy weather location` omaette, et näha, kus see sinu arvates asud, ja `--clear`, et naasta automaatse tuvastamise juurde.

### Aku

`Super + Ctrl + Alt + B`

 ![notice-battery](images/notice-battery.webp)
