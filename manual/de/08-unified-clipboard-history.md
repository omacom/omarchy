# Einheitliche Zwischenablage & Verlauf

Normalerweise braucht man unter Linux `Ctrl + Shift + C/V`, um im Terminal zu kopieren und einzufügen, und `Ctrl + C/V`, um es überall sonst zu tun. Daran muss sich jeder erst einmal gewöhnen, der nicht mit Linux aufgewachsen ist! Dasselbe gilt für den Wechsel von Super zu Ctrl, wenn du vom Mac kommst.

Omarchy löst beide Probleme mit einheitlichen Tastenkürzeln für die Zwischenablage, die (fast) überall funktionieren. Sie lauten:

| Tastenkürzel | Befehl |
| ------- | ----------- |
| Super + C | Kopieren |
| Super + X | Ausschneiden |
| Super + V | Einfügen |
| Super + Ctrl + V | Zwischenablageverlauf |

_Beachte, dass die meisten Agent-Harnesses `Ctrl + V` zum Einfügen von Bildern verwenden, aber `Super + V` zum Einfügen von Text._

### Zwischenablageverlauf

Der Zwischenablageverlauf wird von der Omarchy-Shell bereitgestellt und funktioniert sowohl für Text als auch für Bilder. Du rufst ihn mit `Super + Ctrl + V` auf, wählst deinen Eintrag mit Return aus, und dieser wird dann in die Zwischenablage gelegt, bereit zum Einfügen mit `Super + V`.

 ![clipboard-history](images/clipboard-history.webp)

Du kannst den Verlauf auch durchsuchen, indem du einfach anfängst zu tippen:

 ![clipboard-history-search](images/clipboard-history-search.webp)
