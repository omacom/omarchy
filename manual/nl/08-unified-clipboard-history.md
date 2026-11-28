# Uniform klembord & geschiedenis

Normaal gesproken heb je op Linux `Ctrl + Shift + C/V` nodig om te kopiëren en plakken in de terminal en `Ctrl + C/V` om dat overal elders te doen. Dat is moeilijk te wennen voor iedereen die niet met Linux is geboren en getogen! Dat geldt ook voor de overstap van super naar ctrl, als je van de Mac komt.

Omarchy pakt beide problemen aan met uniforme klembord-sneltoetsen die (bijna) overal werken. Dat zijn:

| Sneltoets | Opdracht |
| ------- | ----------- |
| Super + A | Alles selecteren |
| Super + C | Kopiëren |
| Super + X | Knippen |
| Super + V | Plakken |
| Super + Ctrl + V | Klembordgeschiedenis |

_Let op: de meeste agent harnesses gebruiken `Ctrl + V` om afbeeldingen te plakken, maar `Super + V` om tekst te plakken._

Gebruik `Super + A` en daarna `Super + C` om alles te kopiëren in een gefocust tekstveld of een andere app die `Ctrl + A` ondersteunt. In een terminal gaat `Ctrl + A` naar het begin van de commandoregel in plaats van de tekst ervan te selecteren.

### Klembordgeschiedenis

De klembordgeschiedenis wordt geleverd door de Omarchy shell en werkt voor zowel tekst als afbeeldingen. Je opent hem met `Super + Ctrl + V` en selecteert je item met return, waarmee het direct wordt geplakt in de app waar je in zat. Gebruik `Shift + Return` om het alleen naar het klembord te kopiëren, `Alt + Return` om het te openen, `Delete` om het uit de geschiedenis te verwijderen en `Shift + Delete` om de hele geschiedenis te wissen.

 ![clipboard-history](images/clipboard-history.webp)

Je kunt de geschiedenis ook doorzoeken door gewoon te beginnen met typen:

 ![clipboard-history-search](images/clipboard-history-search.webp)
