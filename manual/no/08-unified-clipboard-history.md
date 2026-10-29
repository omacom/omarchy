# Enhetlig utklippstavle og historikk

Vanligvis på Linux må du bruke `Ctrl + Shift + C/V` for å kopiere og lime inn i terminalen, og `Ctrl + C/V` for å gjøre det alle andre steder. Det er vanskelig å venne seg til for alle som ikke er født og oppvokst på Linux! Det samme gjelder byttet fra Super til Ctrl hvis du kommer fra Mac.

Omarchy løser begge problemene med enhetlige hurtigtaster for utklippstavlen som fungerer (nesten) overalt. De er:

| Hurtigtast | Kommando |
| ------- | ----------- |
| Super + A | Velg alt |
| Super + C | Kopier |
| Super + X | Klipp ut |
| Super + V | Lim inn |
| Super + Ctrl + V | Utklippstavlehistorikk |

_Merk at de fleste agent-harnessene bruker `Ctrl + V` til å lime inn bilder, men `Super + V` til å lime inn tekst._

Bruk `Super + A`, og deretter `Super + C`, for å kopiere alt i et fokusert tekstfelt eller en annen app som støtter `Ctrl + A`. I en terminal flytter `Ctrl + A` deg til starten av kommandolinjen i stedet for å velge teksten i den.

### Utklippstavlehistorikk

Utklippstavlehistorikken leveres av Omarchy-skallet og fungerer for både tekst og bilder. Du utløser den med `Super + Ctrl + V`, velger oppføringen din med Enter, og så legges den på utklippstavlen, klar til å limes inn med `Super + V`.

 ![clipboard-history](images/clipboard-history.webp)

Du kan også søke i historikken bare ved å begynne å skrive:

 ![clipboard-history-search](images/clipboard-history-search.webp)
