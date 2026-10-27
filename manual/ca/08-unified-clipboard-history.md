# Porta-retalls unificat i historial

Normalment a Linux necessiteu `Ctrl + Shift + C/V` per copiar i enganxar al terminal i `Ctrl + C/V` per fer-ho a tot arreu. Això és difícil d'acostumar-hi per a qualsevol que no hagi nascut i crescut amb Linux! I també ho és el canvi de super a ctrl, si veniu del Mac.

Omarchy aborda tots dos problemes amb dreceres unificades de porta-retalls que funcionen (gairebé) a tot arreu. Són:

| Drecera | Ordre |
| ------- | ----------- |
| Super + C | Copia |
| Super + X | Retalla |
| Super + V | Enganxa |
| Super + Ctrl + V | Historial del porta-retalls |

_Tingueu en compte que la majoria d'arnesos d'agents faran servir `Ctrl + V` per enganxar imatges, però `Super + V` per enganxar text._

### Historial del porta-retalls

L'historial del porta-retalls el proporciona el shell d'Omarchy i funciona tant per a text com per a imatges. L'activeu amb `Super + Ctrl + V`, seleccioneu l'entrada amb return, i aquesta es col·locarà al porta-retalls a punt per enganxar-la amb `Super + V`.

 ![clipboard-history](images/clipboard-history.webp)

També podeu cercar a l'historial simplement començant a escriure:

 ![clipboard-history-search](images/clipboard-history-search.webp)
