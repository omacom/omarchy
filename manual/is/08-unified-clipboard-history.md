# Sameinað klippiborð og saga

Venjulega á Linux þarftu `Ctrl + Shift + C/V` til að afrita og líma í terminal og `Ctrl + C/V` til að gera það alls staðar annars staðar. Það er erfitt að venjast því fyrir alla sem hafa ekki fæðst og alist upp með Linux! Svo er líka skiptið frá super yfir í ctrl, ef þú ert að koma frá Mac.

Omarchy tekst á við bæði vandamálin með sameinuðum flýtilyklum fyrir klippiborð sem virka (nánast) alls staðar. Þeir eru:

| Hotkey | Command |
| ------- | ----------- |
| Super + A | Velja allt |
| Super + C | Afrita |
| Super + X | Klippa |
| Super + V | Líma |
| Super + Ctrl + V | Saga klippiborðs |

_Athugaðu að flest agent harnesses munu nota `Ctrl + V` til að líma myndir, en `Super + V` til að líma texta._

Notaðu `Super + A`, síðan `Super + C` til að afrita allt í textareit í fókus eða öðru forriti sem styður `Ctrl + A`. Í terminal færir `Ctrl + A` þig í byrjun skipanalínunnar í stað þess að velja textann hennar.

### Saga klippiborðs

Saga klippiborðs er veitt af Omarchy shell og virkar bæði fyrir texta og myndir. Þú virkjar hana með `Super + Ctrl + V`, velur færsluna þína með return, og þá verður hún sett á klippiborðið tilbúin til að límast inn með `Super + V`.

 ![clipboard-history](images/clipboard-history.webp)

Þú getur líka leitað í sögunni með því einfaldlega að byrja að skrifa:

 ![clipboard-history-search](images/clipboard-history-search.webp)
