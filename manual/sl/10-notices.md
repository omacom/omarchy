# Obvestila

Obvestila pristanejo v zgornjem desnem kotu zaslona v fokusu. Z obvestili z bližnjicami lahko hitro dostopate tudi do datuma in časa, stanja baterije in trenutnega vremena.

## Obvestila

Obvestila iz iste aplikacije ali spletnega mesta se zložijo v komplet, tako da klepetav kanal Slack ne potisne obvestila o neuspelem grajenju z zaslona. Zadržite kazalec nad kompletom, da ga razpnete; medtem ko berete, pod vaš kazalec ne zdrsne nič novega. Kliknite kartico, da skočite tja, od koder je prišla, za zavrnitev pa kliknite z desno tipko, srednjo tipko ali pritisnite ✕.

Kartice ponujajo, kar prinašajo: _Kopiraj kodo_ za potrditvene kode (ne shranijo se v [zgodovino odložišča](08-unified-clipboard-history.md) in se po minuti počistijo) ter vse gumbe, ki jih zagotovi aplikacija. Povezave v besedilu obvestila se odprejo ob kliku.

Za uporabo brez miške pritisnite `Super + Ctrl + ,`. Izbrano je najnovejše obvestilo, njegovi gumbi pa so oštevilčeni: pritisnite številko, da uporabite enega, `Enter`, da kliknete obvestilo, `↑` in `↓`, da se premikate med obvestili, `Delete`, da zavrnete enega, in `Esc`, da vrnete tipkovnico. Po nekaj sekundah nedejavnosti se tudi samo sprosti.

Utišanje obvestil jih zadrži, razen Omarchyjevih lastnih potrditev, nujnih opozoril in potrditvenih kod, ki ste jih zahtevali pred trenutkom. Zadnjih nekaj jih vrnete na zaslon, zadržanih ali ne, s `Super + Shift + Alt + ,`. Zgodovina se hrani en dan.

## Obvestila z bližnjicami

### Datum in čas

`Super + Ctrl + Alt + T`

 ![notice-datetime](images/notice-datetime.webp)

### Vreme

`Super + Ctrl + Alt + W`

 ![notice-weather](images/notice-weather.webp)

Lokacija se zazna na podlagi vašega naslova IP, kar je običajno dovolj blizu, a ne vedno. Pritrdite jo lahko z `omarchy weather location --set Malibu`, ali bodite natančni z dodajanjem koordinat: `omarchy weather location --set Malibu 34.0259,-118.7798`. Zaženite `omarchy weather location` samo po sebi, da vidite, kje meni, da ste, in `--clear`, da se vrnete na samodejno zaznavanje.

### Baterija

`Super + Ctrl + Alt + B`

 ![notice-battery](images/notice-battery.webp)
