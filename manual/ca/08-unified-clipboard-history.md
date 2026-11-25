# Portaretalls unificat i historial

Normalment, al Linux, necessites `Ctrl + Shift + C/V` per copiar i enganxar al terminal i `Ctrl + C/V` per fer-ho a tot arreu. Això costa d'habituar-s'hi a qui no ha nascut i crescut amb Linux! I també costa el canvi de super a ctrl, si vens del Mac.

Omarchy resol tots dos problemes amb dreceres de portaretalls unificades que funcionen (gairebé) a tot arreu. Són:

| Drecera | Acció |
| ------- | ----------- |
| Super + A | Selecciona-ho tot |
| Super + C | Copia |
| Super + X | Retalla |
| Super + V | Enganxa |
| Super + Ctrl + V | Historial del portaretalls |

_Tingues en compte que la majoria d'entorns d'agents utilitzaran `Ctrl + V` per enganxar imatges, però `Super + V` per enganxar text._

Fes servir `Super + A` i després `Super + C` per copiar-ho tot en un camp de text amb el focus o en una altra aplicació que admeti `Ctrl + A`. En un terminal, `Ctrl + A` va a l'inici de la línia d'ordres en lloc de seleccionar-ne el text.

### Historial del portaretalls

L'historial del portaretalls el proporciona la shell d'Omarchy i funciona tant per a text com per a imatges. L'actives amb `Super + Ctrl + V` i selecciones l'entrada amb la tecla de retorn, que l'enganxa directament a l'aplicació on eres. Fes servir `Shift + Return` per copiar-lo només al portaretalls, `Alt + Return` per obrir-lo, `Delete` per eliminar-lo de l'historial i `Shift + Delete` per esborrar tot l'historial.

 ![clipboard-history](images/clipboard-history.webp)

També pots cercar a l'historial només començant a escriure:

 ![clipboard-history-search](images/clipboard-history-search.webp)
