# Obvestila

Obvestila pristanejo v zgornjem desnem kotu zaslona, ki je v fokusu. Z obvestili na bližnjice lahko hitro dostopate tudi do datuma in časa, stanja baterije in trenutnega vremena.

## Obvestila

Obvestila iste aplikacije ali spletnega mesta se zložijo v komplet, tako da klepetav kanal na Slacku ne potisne obvestila o neuspeli gradnji z zaslona. Zadržite kazalec nad kompletom, da ga razprete; medtem ko berete, pod kazalec ne zdrsne nič novega. Kliknite kartico, da skočite tja, od koder je prišla, kliknite jo z desnim ali srednjim gumbom ali pritisnite ✕, da jo opustite.

Kartice ponudijo, kar prinašajo: _Kopiraj kodo_ za potrditvene kode (ki se ne shranijo v [zgodovino odložišča](08-unified-clipboard-history.md) in se po eni minuti počistijo) ter vse gumbe, ki jih zagotovi aplikacija. Povezave v besedilu obvestila se odprejo ob kliku.

`Super + ,` opusti najnovejše obvestilo ali odpre tisto, na kar kaže, kadar to ponuja, `Super + Alt + ,` opusti samo zadnje, `Super + Shift + ,` opusti vsa, `Super + Shift + Alt + ,` pa odpre zgodovino. Če jih želite uporabljati brez miške, pritisnite `Super + Ctrl + ,`. Izbrano je najnovejše obvestilo, njegovi gumbi pa so oštevilčeni: pritisnite številko, da uporabite enega, `Enter`, da kliknete obvestilo, `↑` in `↓`, da se premaknete med obvestili, `Delete`, da eno opustite, in `Esc`, da vrnete tipkovnico. Po nekaj sekundah nedejavnosti se tudi samo sprosti.

Utišanje obvestil jih zadrži, razen Omarchyjevih lastnih potrditev, nujnih opozoril in potrditvenih kod, ki ste jih zahtevali pred trenutkom. Zadnjih nekaj, zadržanih ali ne, vrnete na zaslon z `Super + Shift + Alt + ,`. Zgodovina se hrani en dan.

## Obvestila na bližnjice

### Datum in čas

`Super + Ctrl + Alt + T`

 ![notice-datetime](images/notice-datetime.webp)

### Vreme

`Super + Ctrl + Alt + W`

 ![notice-weather](images/notice-weather.webp)

Lokacija se zazna iz vašega naslova IP, kar je običajno dovolj blizu, ni pa vedno. Določite jo lahko z `omarchy weather location --set Malibu` ali pa bodite natančni in dodajte koordinate: `omarchy weather location --set Malibu 34.0259,-118.7798`. Zaženite samo `omarchy weather location`, da vidite, kje meni, da ste, in `--clear`, da se vrnete na samodejno zaznavanje.

### Baterija

`Super + Ctrl + Alt + B`

 ![notice-battery](images/notice-battery.webp)
