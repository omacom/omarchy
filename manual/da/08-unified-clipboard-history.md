# Samlet udklipsholder & historik

Normalt skal du på Linux bruge `Ctrl + Shift + C/V` til at kopiere og indsætte i terminalen og `Ctrl + C/V` til at gøre det alle andre steder. Det er svært at vænne sig til for alle, der ikke er født og opvokset med Linux! Det gælder også skiftet fra Super til Ctrl, hvis du kommer fra Mac.

Omarchy løser begge problemer med samlede genveje til udklipsholderen, der virker (næsten) overalt. De er:

| Genvej | Kommando |
| ------- | ----------- |
| Super + A | Markér alt |
| Super + C | Kopiér |
| Super + X | Klip |
| Super + V | Indsæt |
| Super + Ctrl + V | Historik for udklipsholderen |

_Bemærk, at de fleste agent harnesses bruger `Ctrl + V` til at indsætte billeder, men `Super + V` til at indsætte tekst._

Brug `Super + A` og derefter `Super + C` til at kopiere alt i et fokuseret tekstfelt eller en anden app, der understøtter `Ctrl + A`. I en terminal flytter `Ctrl + A` til starten af kommandolinjen i stedet for at markere dens tekst.

### Historik for udklipsholderen

Historikken for udklipsholderen leveres af Omarchy-skallen og virker til både tekst og billeder. Du aktiverer den med `Super + Ctrl + V` og vælger dit element med Return, hvorefter det indsættes direkte i den app, du var i. Brug `Shift + Return` til kun at kopiere det til udklipsholderen, `Alt + Return` til at åbne det, `Delete` til at fjerne det fra historikken og `Shift + Delete` til at rydde hele historikken.

 ![clipboard-history](images/clipboard-history.webp)

Du kan også søge i historikken ved bare at begynde at skrive:

 ![clipboard-history-search](images/clipboard-history-search.webp)
