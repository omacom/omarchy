# Ensartet udklipsholder og historik

Normalt på Linux skal du bruge `Ctrl + Shift + C/V` til at kopiere og indsætte i terminalen og `Ctrl + C/V` til at gøre det alle andre steder. Det er svært at vænne sig til for alle, der ikke er født og opvokset med Linux! Det samme gælder skiftet fra super til ctrl, hvis du kommer fra Mac.

Omarchy løser begge problemer med ensartede genvejstaster til udklipsholderen, der virker (næsten) overalt. De er:

| Genvejstast | Kommando |
| ------- | ----------- |
| Super + A | Vælg alt |
| Super + C | Kopiér |
| Super + X | Klip |
| Super + V | Indsæt |
| Super + Ctrl + V | Udklipsholderhistorik |

_Bemærk, at de fleste agent-harnesses bruger `Ctrl + V` til at indsætte billeder, men `Super + V` til at indsætte tekst._

Brug `Super + A` og derefter `Super + C` til at kopiere alt i et fokuseret tekstfelt eller en anden app, der understøtter `Ctrl + A`. I en terminal flytter `Ctrl + A` til starten af kommandolinjen i stedet for at markere dens tekst.

### Udklipsholderhistorik

Udklipsholderhistorikken leveres af Omarchy-skallen og virker til både tekst og billeder. Du åbner den med `Super + Ctrl + V`, vælger dit opslag med return, og så bliver det lagt i udklipsholderen, klar til at sætte ind med `Super + V`.

 ![clipboard-history](images/clipboard-history.webp)

Du kan også søge i historikken bare ved at begynde at skrive:

 ![clipboard-history-search](images/clipboard-history-search.webp)
