# Clipboard unificat și istoric

De obicei, pe Linux, ai nevoie de `Ctrl + Shift + C/V` pentru a copia și lipi în terminal și de `Ctrl + C/V` pentru a face același lucru peste tot în rest. Este greu să te obișnuiești cu asta pentru oricine nu s-a născut și nu a crescut pe Linux! La fel este și trecerea de la super la ctrl, dacă vii de pe Mac.

Omarchy rezolvă ambele probleme cu taste rapide unificate pentru clipboard care funcționează (aproape) peste tot. Acestea sunt:

| Hotkey | Command |
| ------- | ----------- |
| Super + A | Selectează tot |
| Super + C | Copiază |
| Super + X | Taie |
| Super + V | Lipește |
| Super + Ctrl + V | Istoric clipboard |

_Reține că majoritatea harness-urilor pentru agenți vor folosi `Ctrl + V` pentru lipirea imaginilor, dar `Super + V` pentru lipirea textului._

Folosește `Super + A`, apoi `Super + C` pentru a copia tot conținutul dintr-un câmp de text focalizat sau dintr-o altă aplicație care acceptă `Ctrl + A`. Într-un terminal, `Ctrl + A` mută la începutul liniei de comandă în loc să îi selecteze textul.

### Istoricul clipboardului

Istoricul clipboardului este furnizat de shell-ul Omarchy și funcționează atât pentru text, cât și pentru imagini. Îl declanșezi cu `Super + Ctrl + V`, îți selectezi intrarea cu Return, iar aceasta va fi apoi plasată pe clipboard, gata de lipit cu `Super + V`.

 ![clipboard-history](images/clipboard-history.webp)

De asemenea, poți căuta în istoric pur și simplu începând să tastezi:

 ![clipboard-history-search](images/clipboard-history-search.webp)
