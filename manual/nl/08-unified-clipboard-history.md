# Uniform klembord & geschiedenis

Normaal gesproken heb je op Linux `Ctrl + Shift + C/V` nodig om te kopiëren en plakken in de terminal en `Ctrl + C/V` om dat overal elders te doen. Dat is moeilijk om aan te wennen voor iedereen die niet op Linux is geboren en getogen! Dat geldt ook voor de overstap van super naar ctrl als je van de Mac komt.

Omarchy pakt beide problemen aan met uniforme klembordsneltoetsen die (bijna) overal werken. Dat zijn:

| Sneltoets | Opdracht |
| ------- | ----------- |
| Super + A | Alles selecteren |
| Super + C | Kopiëren |
| Super + X | Knippen |
| Super + V | Plakken |
| Super + Ctrl + V | Klembordgeschiedenis |

_Let op dat de meeste agent harnesses `Ctrl + V` gebruiken voor het plakken van afbeeldingen, maar `Super + V` voor het plakken van tekst._

Gebruik `Super + A` en daarna `Super + C` om alles te kopiëren in een gefocust tekstveld of een andere app die `Ctrl + A` ondersteunt. In een terminal ga je met `Ctrl + A` naar het begin van de commandoregel in plaats van de tekst ervan te selecteren.

### Klembordgeschiedenis

De klembordgeschiedenis wordt geleverd door de Omarchy shell en werkt voor zowel tekst als afbeeldingen. Je activeert hem met `Super + Ctrl + V`, selecteert je item met return, en dat wordt dan op het klembord geplaatst, klaar om te plakken met `Super + V`.

 ![clipboard-history](images/clipboard-history.webp)

Je kunt ook in de geschiedenis zoeken door gewoon te beginnen met typen:

 ![clipboard-history-search](images/clipboard-history-search.webp)
