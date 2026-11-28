# Einheitliche Zwischenablage & Verlauf

Normalerweise braucht man unter Linux `Ctrl + Shift + C/V`, um im Terminal zu kopieren und einzufügen, und `Ctrl + C/V`, um das überall sonst zu tun. Daran muss sich erst einmal gewöhnen, wer nicht mit Linux aufgewachsen ist! Genauso wie an den Wechsel von Super zu Ctrl, wenn man vom Mac kommt.

Omarchy löst beide Probleme mit einheitlichen Tastenkombinationen für die Zwischenablage, die (fast) überall funktionieren. Das sind:

| Hotkey | Befehl |
| ------- | ----------- |
| Super + A | Alles auswählen |
| Super + C | Kopieren |
| Super + X | Ausschneiden |
| Super + V | Einfügen |
| Super + Ctrl + V | Zwischenablageverlauf |

_Beachte, dass die meisten Agent-Harnesses `Ctrl + V` zum Einfügen von Bildern verwenden, aber `Super + V` zum Einfügen von Text._

Verwende `Super + A` und dann `Super + C`, um alles in einem fokussierten Textfeld oder einer anderen App zu kopieren, die `Ctrl + A` unterstützt. In einem Terminal springt `Ctrl + A` an den Anfang der Befehlszeile, statt deren Text auszuwählen.

### Zwischenablageverlauf

Der Zwischenablageverlauf wird von der Omarchy-Shell bereitgestellt und funktioniert sowohl für Text als auch für Bilder. Du rufst ihn mit `Super + Ctrl + V` auf und wählst deinen Eintrag mit Return aus, wodurch er direkt in die App eingefügt wird, in der du gerade warst. Verwende `Shift + Return`, um ihn nur in die Zwischenablage zu kopieren, `Alt + Return`, um ihn zu öffnen, `Delete`, um ihn aus dem Verlauf zu entfernen, und `Shift + Delete`, um den gesamten Verlauf zu löschen.

 ![clipboard-history](images/clipboard-history.webp)

Du kannst den Verlauf auch durchsuchen, indem du einfach anfängst zu tippen:

 ![clipboard-history-search](images/clipboard-history-search.webp)
