# Einheitliche Zwischenablage & Verlauf

Normalerweise brauchst du unter Linux `Ctrl + Shift + C/V` zum Kopieren und Einfügen im Terminal und `Ctrl + C/V`, um es überall sonst zu tun. Daran muss sich erst einmal gewöhnen, wer nicht mit Linux geboren und aufgewachsen ist! Ebenso an den Wechsel von Super zu Ctrl, wenn du vom Mac kommst.

Omarchy löst beide Probleme mit einheitlichen Tastenkürzeln für die Zwischenablage, die (fast) überall funktionieren. Sie lauten:

| Hotkey | Command |
| ------- | ----------- |
| Super + A | Alles auswählen |
| Super + C | Kopieren |
| Super + X | Ausschneiden |
| Super + V | Einfügen |
| Super + Ctrl + V | Verlauf der Zwischenablage |

_Beachte, dass die meisten Agent-Harnesses `Ctrl + V` zum Einfügen von Bildern verwenden, aber `Super + V` zum Einfügen von Text._

Verwende `Super + A` und dann `Super + C`, um alles in einem fokussierten Textfeld oder einer anderen App zu kopieren, die `Ctrl + A` unterstützt. In einem Terminal springt `Ctrl + A` an den Anfang der Befehlszeile, anstatt deren Text auszuwählen.

### Verlauf der Zwischenablage

Der Verlauf der Zwischenablage wird von der Omarchy-Shell bereitgestellt und funktioniert sowohl für Text als auch für Bilder. Du rufst ihn mit `Super + Ctrl + V` auf, wählst deinen Eintrag mit Return aus, und dieser wird dann in die Zwischenablage gelegt, bereit zum Einfügen mit `Super + V`.

 ![clipboard-history](images/clipboard-history.webp)

Du kannst den Verlauf auch durchsuchen, indem du einfach anfängst zu tippen:

 ![clipboard-history-search](images/clipboard-history-search.webp)
