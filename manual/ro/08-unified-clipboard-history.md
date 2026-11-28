# Clipboard unificat și istoric

De obicei pe Linux, ai nevoie de `Ctrl + Shift + C/V` ca să dai copy'n'paste în terminal și de `Ctrl + C/V` ca să faci asta peste tot în rest. E greu să te obișnuiești cu asta dacă nu te-ai născut și nu ai crescut pe Linux! La fel și trecerea de la super la ctrl, dacă vii de pe Mac.

Omarchy rezolvă ambele probleme cu scurtături unificate pentru clipboard care funcționează (aproape) peste tot. Acestea sunt:

| Scurtătură | Comandă |
| ------- | ----------- |
| Super + A | Selectează tot |
| Super + C | Copiază |
| Super + X | Taie |
| Super + V | Lipește |
| Super + Ctrl + V | Istoricul clipboardului |

_Reține că majoritatea harness-urilor de agenți vor folosi `Ctrl + V` pentru lipirea imaginilor, dar `Super + V` pentru lipirea textului._

Folosește `Super + A`, apoi `Super + C` ca să copiezi tot dintr-un câmp de text focalizat sau din altă aplicație care acceptă `Ctrl + A`. Într-un terminal, `Ctrl + A` mută la începutul liniei de comandă în loc să-i selecteze textul.

### Istoricul clipboardului

Istoricul clipboardului este oferit de shell-ul Omarchy și funcționează atât pentru text, cât și pentru imagini. Îl declanșezi cu `Super + Ctrl + V` și îți selectezi intrarea cu return, care o lipește direct în aplicația în care erai. Folosește `Shift + Return` doar ca să o copiezi în clipboard, `Alt + Return` ca să o deschizi, `Delete` ca să o elimini din istoric și `Shift + Delete` ca să ștergi tot istoricul.

 ![clipboard-history](images/clipboard-history.webp)

De asemenea, poți căuta în istoric pur și simplu începând să tastezi:

 ![clipboard-history-search](images/clipboard-history-search.webp)
