# Clipboard unificat și istoric

De obicei, pe Linux, ai nevoie de `Ctrl + Shift + C/V` ca să copiezi și să lipești în terminal și de `Ctrl + C/V` ca să o faci peste tot în rest. Asta e greu de deprins pentru oricine n-a fost născut și crescut pe Linux! La fel e și trecerea de la Super la Ctrl, dacă vii de pe Mac.

Omarchy abordează ambele probleme cu scurtături de clipboard unificate, care funcționează (aproape) peste tot. Acestea sunt:

| Scurtătură | Comandă |
| ------- | ----------- |
| Super + C | Copiază |
| Super + X | Taie |
| Super + V | Lipește |
| Super + Ctrl + V | Istoric clipboard |

_Reține că majoritatea harnessurilor de agenți vor folosi `Ctrl + V` pentru lipirea imaginilor, dar `Super + V` pentru lipirea textului._

### Istoric clipboard

Istoricul clipboard este oferit de shellul Omarchy și funcționează atât pentru text, cât și pentru imagini. Îl declanșezi cu `Super + Ctrl + V`, selectezi intrarea cu Return, iar aceasta va fi pusă pe clipboard, gata de lipit cu `Super + V`.

 ![clipboard-history](images/clipboard-history.webp)

Poți căuta și în istoric începând pur și simplu să tastezi:

 ![clipboard-history-search](images/clipboard-history-search.webp)
